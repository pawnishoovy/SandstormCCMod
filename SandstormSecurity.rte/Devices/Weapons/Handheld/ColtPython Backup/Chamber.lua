function Create(self)

	self.parentSet = false;
	
	-- Sounds --
	self.addSounds = {["Loop"] = nil};
	self.addSounds.Loop = {["Variations"] = 4,
	["Path"] = "SandstormSecurity.rte/Devices/Weapons/Handheld/ColtPython/CompliSoundV2/Add"};
	
	self.noiseSounds = {["Outdoors"] = {["Loop"] = nil, ["End"] = nil},
	["Indoors"] = {["Loop"] = nil, ["End"] = nil},
	["bigIndoors"] = {["Loop"] = nil, ["End"] = nil}};
	self.noiseSounds.Outdoors.End = {["Variations"] = 4,
	["Path"] = "SandstormSecurity.rte/Devices/Weapons/Handheld/ColtPython/CompliSoundV2/NoiseOutdoorsEnd"};
	self.noiseSounds.Indoors.End = {["Variations"] = 4,
	["Path"] = "SandstormSecurity.rte/Devices/Weapons/Handheld/ColtPython/CompliSoundV2/NoiseIndoorsEnd"};
	self.noiseSounds.bigIndoors.End = {["Variations"] = 4,
	["Path"] = "SandstormSecurity.rte/Devices/Weapons/Handheld/ColtPython/CompliSoundV2/NoiseBigIndoorsEnd"};
	
	self.reflectionSounds = {["Outdoors"] = nil};
	self.reflectionSounds.Outdoors = {["Variations"] = 3,
	["Path"] = "SandstormSecurity.rte/Devices/Weapons/Handheld/ColtPython/CompliSoundV2/ReflectionOutdoors"};
	
	self.lastAge = self.Age
	
	self.delayedFire = false
	self.delayedFireTimer = Timer();
	self.delayedFireTimeMS = 50
	
	self.originalSharpLength = self.SharpLength
	
	self.originalStanceOffset = Vector(math.abs(self.StanceOffset.X), self.StanceOffset.Y)
	self.originalSharpStanceOffset = Vector(self.SharpStanceOffset.X, self.SharpStanceOffset.Y)
	
	self.shellsToEject = self.Magazine.Capacity
	self.ejectedShell = false
	
	self.rotation = 0
	self.rotationTarget = 0
	self.rotationSpeed = 9
	
	self.horizontalAnim = 0
	self.verticalAnim = 0
	
	self.angVel = 0
	self.lastRotAngle = self.RotAngle
	
	self.smokeTimer = Timer();
	self.smokeDelayTimer = Timer();
	self.canSmoke = false
	
	self.reloadTimer = Timer();
	
	self.cylinderOpenPrepareDelay = 500;
	self.cylinderOpenAfterDelay = 300;
	self.ejectorRodPrepareDelay = 600;
	self.ejectorRodAfterDelay = 1000;
	self.speedLoaderPrepareDelay = 350;
	self.speedLoaderAfterDelay = 400;
	self.cylinderClosePrepareDelay = 500;
	self.cylinderCloseAfterDelay = 300;
	
	-- phases:
	-- 0 cylinderopen
	-- 1 ejectorrod
	-- 2 speedloader
	-- 3 cylinderclose
	
	self.reloadPhase = 0;
	
	self.ReloadTime = 9999;
	
	self.swayAcc = 0 -- for sinous
	self.swayStr = 0 -- for accumulator
	
	self.cocked = false -- precision mode
	self.cockTimer = Timer()
	self.cockDelay = self.delayedFireTimeMS * 2
	self.cockedAimFocus = 300 -- how long it takes to focus
	self.activated = false
	
	self.originalRotAngle = self.RotAngle
	self.lastAnimRotAngle = self.RotAngle
	
	self.fireRateTimer = Timer()
	
	self.reloadHUDAmmo = 0
	self.reloadHUDAmmoMax = 6
	
	local ms = 1 / (self.RateOfFire / 60) * 1000
	ms = ms + self.delayedFireTimeMS
	self.RateOfFire = 1 / (ms / 1000) * 60
	self.canShoot = true -- Prevent "automatic" bug, force semi-auto
end

function Update(self)
	self.rotationTarget = 0 -- ZERO IT FIRST AAAA!!!!!
	self.originalRotAngle = self.RotAngle -- Important Stuff
	
	if self.ID == self.RootID then
		self.parent = nil;
		self.parentSet = false;
	elseif self.parentSet == false then
		local actor = MovableMan:GetMOFromID(self.RootID);
		if actor and IsAHuman(actor) then
			self.parent = ToAHuman(actor);
			self.parentSet = true;
		end
	end
	
	-- Check if switched weapons/hide in the inventory, etc.
	if self.Age > (self.lastAge + TimerMan.DeltaTimeSecs * 2000) then
		if self.delayedFire then
			self.delayedFire = false
			--if self.Magazine then
			--	self.Magazine.RoundCount = self.Magazine.RoundCount + 1
			--end
		end
	end
	self.lastAge = self.Age + 0
	
    -- Smoothing
    local min_value = -math.pi;
    local max_value = math.pi;
    local value = self.RotAngle - self.lastRotAngle
    local result;
    local ret = 0
    
    local range = max_value - min_value;
    if range <= 0 then
        result = min_value;
    else
        ret = (value - min_value) % range;
        if ret < 0 then ret = ret + range end
        result = ret + min_value;
    end
    
    self.lastRotAngle = self.RotAngle
    self.angVel = (result / TimerMan.DeltaTimeSecs) * self.FlipFactor
    
    if self.lastHFlipped ~= nil then
        if self.lastHFlipped ~= self.HFlipped then
            self.lastHFlipped = self.HFlipped
            self.angVel = 0
        end
    else
        self.lastHFlipped = self.HFlipped
    end
	
	local sharpRecoil = (0.9 + math.pow(math.min(self.delayedFireTimer.ElapsedSimTimeMS / (250), 1), 2.0) * 0.1)
	local sharpFocus = math.pow(math.min(self.cockTimer.ElapsedSimTimeMS / (self.cockDelay + self.cockedAimFocus), 1), 2)
	
	--self.SharpLength = self.originalSharpLength * sharpRecoil * (1 + sharpFocus * 0.5)
	local sharpSpeed = 15
	self.SharpLength = (self.SharpLength + (self.originalSharpLength * sharpRecoil * (1 + sharpFocus * 0.5)) * TimerMan.DeltaTimeSecs * sharpSpeed) / (1 + TimerMan.DeltaTimeSecs * sharpSpeed)
	
	if not self:IsActivated() then
		self.canShoot = true
	end
	
	if not self.canShoot then
		self:Deactivate()
	end
	
	local shot = false
	if self.parent and not self:IsReloading() then
		self:Deactivate()
		
		local active = self.parent:GetController():IsState(Controller.WEAPON_FIRE) == true
		if active then
			if not self.activated then
				self.activated = true
				self.cockTimer:Reset()
			end
			
			if not self.Magazine or self.Magazine.RoundCount < 1 then
				if self.Magazine then
					self.reloadHUDAmmo = self.Magazine.RoundCount
				end
				self:Reload();
			else
				if self.cockTimer:IsPastSimMS(self.cockDelay) then
					if not self.cocked then
						AudioMan:PlaySound("SandstormSecurity.rte/Devices/Weapons/Handheld/ColtPython/Sounds/PrecisionPre"..math.random(1,4)..".ogg", self.Pos, -1, 0, 130, 1, 250, false);
						self.cocked = true
						self.angVel = self.angVel - RangeRand(0.7,1.1) * 5
						self.swayAcc = 0
						self.Frame = 1;
					end
					
					-- Cool awesome precision mode focus hud cosshair
					if self.parent:IsPlayerControlled() then
						local color = 120
						local dist = 250 - 10 * math.sin(sharpFocus * math.pi * 2)
						
						local q = 5
						local an = 15 * 0.5
						for i = -q, q do
							local fac = i / q
							local pos = self.Pos + Vector(dist * self.FlipFactor,0):RadRotate(self.originalRotAngle + math.rad(an) * fac)
							--PrimitiveMan:DrawCirclePrimitive(pos, 1, color);
							PrimitiveMan:DrawLinePrimitive(pos, pos, color);
							--PrimitiveMan:DrawCirclePrimitive(self.Pos + Vector(dist * self.FlipFactor,0):RadRotate(self.originalRotAngle + math.rad(15) * fac), 1, color);
						end
						--PrimitiveMan:DrawCirclePrimitive(self.Pos + Vector(dist * self.FlipFactor,0):RadRotate(self.lastAnimRotAngle), 1, color);
						PrimitiveMan:DrawLinePrimitive(self.Pos + Vector((dist - 5) * self.FlipFactor,0):RadRotate(self.lastAnimRotAngle), self.Pos + Vector((dist + 5) * self.FlipFactor,0):RadRotate(self.lastAnimRotAngle), color);
					end
				end
			end
		else
			if self.activated then
				if self.Magazine and self.Magazine.RoundCount > 0 and self.delayedFire == false and self.fireRateTimer:IsPastSimMS(1 / (self.RateOfFire / 60) * 1000) then
					shot = true
					self.fireRateTimer:Reset()
					self.cockTimer:Reset()
				end
				self.activated = false
			end
			self.cockTimer:Reset()
		end
	else
		self.activated = false
	end
	
	--if self.FiredFrame then
	if shot then
		self.delayedFire = true
		self.delayedFireTimer:Reset()
		
		if not self.cocked then
			AudioMan:PlaySound("SandstormSecurity.rte/Devices/Weapons/Handheld/ColtPython/CompliSoundV2/Pre"..math.random(1,6)..".ogg", self.Pos, -1, 0, 130, 1, 250, false);
			self.Frame = 1;
		end
		
		--self.angVel = self.angVel - RangeRand(0.7,1.1) * 5 * (math.random(0,1) - 0.5) * 2.0
	end
	
	if self.Magazine and not self:IsReloading() then
		self.reloadHUDAmmo = self.Magazine.RoundCount
	end
	
	-- PAWNIS RELOAD ANIMATION HERE
	if self:IsReloading() then
	
		if self.parent:IsPlayerControlled() then
			for i = 1, self.reloadHUDAmmoMax do
				local position = Vector(math.floor(self.parent.AboveHUDPos.X), math.floor(self.parent.AboveHUDPos.Y)) + Vector(0, 37)
				local color = 105
				if i <= self.reloadHUDAmmo then
					color = 120
				end
				
				position = position + Vector(5,0):RadRotate(math.pi * 2 * i / self.reloadHUDAmmoMax)
				position = Vector(math.floor(position.X), math.floor(position.Y))
				PrimitiveMan:DrawCirclePrimitive(position, 1, color);
			end
		end
	
		self.Reloading = true;
		if self.parent then
			self.parent:GetController():SetState(Controller.AIM_SHARP,false);
		end

		if self.reloadPhase == 0 then
			self.reloadDelay = self.cylinderOpenPrepareDelay;
			self.afterDelay = self.cylinderOpenAfterDelay;			
			self.prepareSoundPath = 
			"SandstormSecurity.rte/Devices/Weapons/Handheld/ColtPython/Sounds/CylinderOpenPrepare";
			self.prepareSoundVars = 2;
			self.afterSoundPath = 
			"SandstormSecurity.rte/Devices/Weapons/Handheld/ColtPython/Sounds/CylinderOpen";
			self.afterSoundVars = 2;
			
			self.rotationTarget = 5;
			self.ejectedShell = false
		elseif self.reloadPhase == 1 then
			self.reloadDelay = self.ejectorRodPrepareDelay;
			self.afterDelay = self.ejectorRodAfterDelay;
			self.prepareSoundPath = 
			"SandstormSecurity.rte/Devices/Weapons/Handheld/ColtPython/Sounds/EjectorRodPrepare";
			self.prepareSoundVars = 2;
			self.afterSoundPath = 
			"SandstormSecurity.rte/Devices/Weapons/Handheld/ColtPython/Sounds/EjectorRod";
			self.afterSoundVars = 2;
			
			self.rotationTarget = 45;
			
		elseif self.reloadPhase == 2 then
			self.reloadDelay = self.speedLoaderPrepareDelay;
			self.afterDelay = self.speedLoaderAfterDelay;
			self.prepareSoundPath = 
			"SandstormSecurity.rte/Devices/Weapons/Handheld/ColtPython/Sounds/SpeedLoaderPrepare";
			self.prepareSoundVars = 2;
			self.afterSoundPath = 
			"SandstormSecurity.rte/Devices/Weapons/Handheld/ColtPython/Sounds/SpeedLoader";
			self.afterSoundVars = 2;
			
			self.rotationTarget = -25;
			
		elseif self.reloadPhase == 3 then
			self.reloadDelay = self.cylinderClosePrepareDelay;
			self.afterDelay = self.cylinderCloseAfterDelay;		
			self.prepareSoundPath = nil;
			self.afterSoundPath = 
			"SandstormSecurity.rte/Devices/Weapons/Handheld/ColtPython/Sounds/CylinderClose";
			self.afterSoundVars = 2;
			
			self.rotationTarget = -5;
			--self.rotationTarget = -360 * 2; -- meme reload
		end
		
		if self.prepareSoundPlayed ~= true then
			self.prepareSoundPlayed = true;
			if self.prepareSoundPath then
				self.prepareSound = AudioMan:PlaySound(self.prepareSoundPath .. math.random(1, self.prepareSoundVars) .. ".ogg", self.Pos, -1, 0, 130, 1, 250, false);
			end
		end
	
		if self.reloadTimer:IsPastSimMS(self.reloadDelay) then
		
			self.phasePrepareFinished = true;
		
			if self.reloadPhase == 0 then
			
				if self.reloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay/5)*1.6)) then
					self.Frame = 3;
				elseif self.reloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay/5)*0.8)) then
					self.Frame = 2;
				end
			elseif self.reloadPhase == 1 then
			
				if self.reloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay/5)*2)) then
					self.Frame = 3;
				elseif self.reloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay/5)*1.5)) then
					self.Frame = 4;
				elseif self.reloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay/5)*1)) then
					self.Frame = 5;
				elseif self.reloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay/5)*0.5)) then
					self.Frame = 4;
				end
				
			elseif self.reloadPhase == 2 then
				self.reloadHUDAmmo = self.reloadHUDAmmoMax
			elseif self.reloadPhase == 3 then
			
				if self.reloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay/5)*1.6)) then
					self.Frame = 0;
				elseif self.reloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay/5)*0.8)) then
					self.Frame = 2;
				end
			end
			
			if self.afterSoundPlayed ~= true then
			
				if self.reloadPhase == 0 then
				
					self.phaseOnStop = nil;
					
				elseif self.reloadPhase == 1 then
					self.reloadHUDAmmo = 0
					self.phaseOnStop = 2;
					
					if self.ejectedShell == false then
						self.ejectedShell = true;
						for i = 1, self.shellsToEject do
							local shell = CreateMOSParticle("Casing Pistol");
							shell.Pos = self.Pos;
							shell.Vel = Vector(math.random() * (-3) * self.FlipFactor, 0):RadRotate(self.RotAngle):DegRotate((math.random() * 32) - 16);
							MovableMan:AddParticle(shell);
						end
					end
					
					self.verticalAnim = self.verticalAnim + 1
					self.horizontalAnim = self.horizontalAnim - 2
					
				elseif self.reloadPhase == 2 then
				
					self.phaseOnStop = nil;
					
					self.horizontalAnim = self.horizontalAnim + 2
				elseif self.reloadPhase == 3 then
				
					self.phaseOnStop = nil;
					
					self.verticalAnim = self.verticalAnim - 1
				else
					self.phaseOnStop = nil;
				end
			
				self.afterSoundPlayed = true;
				if self.afterSoundPath then
					self.afterSound = AudioMan:PlaySound(self.afterSoundPath .. math.random(1, self.afterSoundVars) .. ".ogg", self.Pos, -1, 0, 130, 1, 250, false);
				end
			end
			if self.reloadTimer:IsPastSimMS(self.reloadDelay + self.afterDelay) then
				self.reloadTimer:Reset();
				self.prepareSoundPlayed = false;
				self.afterSoundPlayed = false;
				if self.reloadPhase == 3 then
					self.ReloadTime = 0;
					self.reloadPhase = 0;
					self.Reloading = false;
				else
					self.reloadPhase = self.reloadPhase + 1;
				end
			end
		else
			self.phasePrepareFinished = false;
		end
	else
		if self.Reloading then
			if self.phasePrepareFinished then
				if self.reloadPhase == 0 then
					self.Frame = 3;
				elseif self.reloadPhase == 1 then
					self.Frame = 3;
				elseif self.reloadPhase == 2 then
					self.Frame = 3;
				elseif self.reloadPhase == 3 then
					self.Frame = 0;
				end
			else
				if self.reloadPhase == 0 then
					self.Frame = 0;
				elseif self.reloadPhase == 1 then
					self.Frame = 3;
				elseif self.reloadPhase == 2 then
					self.Frame = 3;
				elseif self.reloadPhase == 3 then
					self.Frame = 3;
				end
			end
		end
		self.reloadTimer:Reset();
		self.prepareSoundPlayed = false;
		self.afterSoundPlayed = false;
		if self.phaseOnStop then
			self.reloadPhase = self.phaseOnStop;
			self.phaseOnStop = nil;
		end
		self.ReloadTime = 9999;
	end

	-- PAWNIS RELOAD ANIMATION HERE
	
	-- Animation
	if self.parent then
		self.horizontalAnim = math.floor(self.horizontalAnim / (1 + TimerMan.DeltaTimeSecs * 24.0) * 1000) / 1000
		self.verticalAnim = math.floor(self.verticalAnim / (1 + TimerMan.DeltaTimeSecs * 15.0) * 1000) / 1000
		
		local str = math.min(self.Vel.Magnitude, 20) + (self.swayStr + 4) * (1 - sharpFocus)
		self.swayStr = math.floor(self.swayStr / (1 + TimerMan.DeltaTimeSecs * 6.0) * 1000) / 1000
		self.swayAcc = (self.swayAcc + str * TimerMan.DeltaTimeSecs) % (math.pi * 4)
		
		local stance = Vector()
		stance = stance + Vector(-1,0) * self.horizontalAnim -- Horizontal animation
		stance = stance + Vector(0,5) * self.verticalAnim -- Vertical animation
		
		self.rotationTarget = self.rotationTarget - (self.angVel * 3) -- aim sway/smoothing
		local swayA = (math.sin(self.swayAcc) * str) * 0.5
		local swayB = (math.sin(self.swayAcc * 0.5) * str) * 0.1
		
		self.rotationTarget = self.rotationTarget + (swayA + swayB) -- sway
		
		self.rotationTarget = self.rotationTarget + (self.cocked and ((1 - sharpFocus) * 15) or 0) -- cock anim
		
		self.rotation = (self.rotation + self.rotationTarget * TimerMan.DeltaTimeSecs * self.rotationSpeed) / (1 + TimerMan.DeltaTimeSecs * self.rotationSpeed)
		local total = math.rad(self.rotation) * self.FlipFactor
		
		self.RotAngle = self.RotAngle + total;
		self:SetNumberValue("MagRotation", total);
		
		local jointOffset = Vector(self.JointOffset.X * self.FlipFactor, self.JointOffset.Y):RadRotate(self.RotAngle);
		local offsetTotal = Vector(jointOffset.X, jointOffset.Y):RadRotate(-total) - jointOffset
		self.Pos = self.Pos + offsetTotal;
		self:SetNumberValue("MagOffsetX", offsetTotal.X);
		self:SetNumberValue("MagOffsetY", offsetTotal.Y);
		
		self.StanceOffset = Vector(self.originalStanceOffset.X, self.originalStanceOffset.Y) + stance
		self.SharpStanceOffset = Vector(self.originalSharpStanceOffset.X, self.originalSharpStanceOffset.Y) + stance
		
		self.lastAnimRotAngle = self.RotAngle
	end
	
	if self.delayedFire then
		self:Deactivate()
		self.horizontalAnim = self.horizontalAnim + TimerMan.DeltaTimeSecs / self.delayedFireTimeMS * 1000
		if self.delayedFireTimer:IsPastSimMS(self.delayedFireTimeMS) or self.cocked then
			self.swayStr = self.swayStr + 15
			
			self.Frame = 0;
			
			if self.Magazine then
				self.Magazine.RoundCount = self.Magazine.RoundCount - 1
			end
			
			self.canSmoke = true
			self.smokeTimer:Reset()
			
			local muzzleFlash = CreateAttachable("Muzzle Flash Shotgun", "Base.rte");
			muzzleFlash.ParentOffset = self.MuzzleOffset
			muzzleFlash.Lifetime = TimerMan.DeltaTimeSecs * 1300
			muzzleFlash.Frame = math.random(0, muzzleFlash.FrameCount - 1);
			self:AddAttachable(muzzleFlash);
			
			if self.noiseEndSound then
				if self.noiseEndSound:IsBeingPlayed() then
					self.noiseEndSound:Stop(-1)
				end
			end
			
			if self.reflectionSound then
				if self.reflectionSound:IsBeingPlayed() then
					self.reflectionSound:Stop(-1)
				end
			end

			local outdoorRays = 0;
			
			local indoorRays = 0;
			
			local bigIndoorRays = 0;

			if self.parent:IsPlayerControlled() then
				self.rayThreshold = 2; -- this is the first ray check to decide whether we play outdoors
				local Vector2 = Vector(0,-700); -- straight up
				local Vector2Left = Vector(0,-700):RadRotate(45*(math.pi/180));
				local Vector2Right = Vector(0,-700):RadRotate(-45*(math.pi/180));			
				local Vector2SlightLeft = Vector(0,-700):RadRotate(22.5*(math.pi/180));
				local Vector2SlightRight = Vector(0,-700):RadRotate(-22.5*(math.pi/180));		
				local Vector3 = Vector(0,0); -- dont need this but is needed as an arg
				local Vector4 = Vector(0,0); -- dont need this but is needed as an arg

				self.ray = SceneMan:CastObstacleRay(self.Pos, Vector2, Vector3, Vector4, self.RootID, self.Team, 128, 7);
				self.rayRight = SceneMan:CastObstacleRay(self.Pos, Vector2Right, Vector3, Vector4, self.RootID, self.Team, 128, 7);
				self.rayLeft = SceneMan:CastObstacleRay(self.Pos, Vector2Left, Vector3, Vector4, self.RootID, self.Team, 128, 7);			
				self.raySlightRight = SceneMan:CastObstacleRay(self.Pos, Vector2SlightRight, Vector3, Vector4, self.RootID, self.Team, 128, 7);
				self.raySlightLeft = SceneMan:CastObstacleRay(self.Pos, Vector2SlightLeft, Vector3, Vector4, self.RootID, self.Team, 128, 7);
				
				self.rayTable = {self.ray, self.rayRight, self.rayLeft, self.raySlightRight, self.raySlightLeft};
			else
				self.rayThreshold = 1; -- has to be different for AI
				local Vector2 = Vector(0,-700); -- straight up
				local Vector3 = Vector(0,0); -- dont need this but is needed as an arg
				local Vector4 = Vector(0,0); -- dont need this but is needed as an arg		
				self.ray = SceneMan:CastObstacleRay(self.Pos, Vector2, Vector3, Vector4, self.RootID, self.Team, 128, 7);
				
				self.rayTable = {self.ray};
			end
			
			for _, rayLength in ipairs(self.rayTable) do
				if rayLength < 0 then
					outdoorRays = outdoorRays + 1;
				elseif rayLength > 170 then
					bigIndoorRays = bigIndoorRays + 1;
				else
					indoorRays = indoorRays + 1;
				end
			end
			
			if outdoorRays >= self.rayThreshold then
				self.noiseEndSound = AudioMan:PlaySound(self.noiseSounds.Outdoors.End.Path .. math.random(1, self.noiseSounds.Outdoors.End.Variations) .. ".ogg", self.Pos, -1, 0, 130, 1, 450, false);
				self.reflectionSound = AudioMan:PlaySound(self.reflectionSounds.Outdoors.Path .. math.random(1, self.reflectionSounds.Outdoors.Variations) .. ".ogg", self.Pos, -1, 0, 130, 1, 450, false);
			elseif math.max(outdoorRays, bigIndoorRays, indoorRays) == indoorRays then
				self.noiseEndSound = AudioMan:PlaySound(self.noiseSounds.Indoors.End.Path .. math.random(1, self.noiseSounds.Indoors.End.Variations) .. ".ogg", self.Pos, -1, 0, 130, 1, 450, false);
			else -- bigIndoor
				self.noiseEndSound = AudioMan:PlaySound(self.noiseSounds.bigIndoors.End.Path .. math.random(1, self.noiseSounds.bigIndoors.End.Variations) .. ".ogg", self.Pos, -1, 0, 130, 1, 450, false);
			end

		
			self.addSound = AudioMan:PlaySound(self.addSounds.Loop.Path .. math.random(1, self.addSounds.Loop.Variations) .. ".ogg", self.Pos, -1, 0, 130, 1, 450, false);
			
			local bullet = CreateMOSRotating("Bullet ColtPython");
			bullet.Pos = self.Pos + Vector(self.MuzzleOffset.X * self.FlipFactor, self.MuzzleOffset.Y):RadRotate(self.RotAngle);
			bullet.Vel = self.Vel + Vector(1 * self.FlipFactor,0):RadRotate(self.RotAngle) * 180; -- BULLET SPEED
			bullet.RotAngle = self.RotAngle + (math.pi * (-self.FlipFactor + 1) / 2)
			bullet:SetNumberValue("WoundDamageMultiplier", 2.0)
			bullet:SetNumberValue("Wounds", math.random(2,3))
			bullet:SetNumberValue("AlwaysTracer", math.random(0,1))
			bullet:SetNumberValue("NoSmoke", 1)
			if self.parent then
				bullet.Team = self.parent.Team;
				bullet.IgnoresTeamHits = true;
			end
			MovableMan:AddParticle(bullet);
			
			self.delayedFire = false
			
			self.canShoot = false
			self.cocked = false
		end
	end
	
	if self.canSmoke and not self.smokeTimer:IsPastSimMS(1500) then
		--[[
		local poof = CreateMOPixel("Real Bullet Micro Smoke Ball "..math.random(1,4), "Sandstorm.rte");
		poof.Pos = self.Pos + Vector(self.MuzzleOffset.X * self.FlipFactor, self.MuzzleOffset.Y):RadRotate(self.RotAngle) + Vector(RangeRand(-1,1), RangeRand(-1,1));
		poof.Lifetime = poof.Lifetime * RangeRand(0.2, 1.3) * 0.9;
		poof.Vel = self.Vel * 0.1
		poof.GlobalAccScalar = RangeRand(0.9, 1.0) * -0.4; -- Go up and down
		MovableMan:AddParticle(poof);
		]]
		if self.smokeDelayTimer:IsPastSimMS(120) then
			
			local poof = math.random(1,2) < 2 and CreateMOSParticle("Tiny Smoke Ball 1") or CreateMOPixel("Real Bullet Micro Smoke Ball "..math.random(1,4), "Sandstorm.rte");
			poof.Pos = self.Pos + Vector(self.MuzzleOffset.X * self.FlipFactor, self.MuzzleOffset.Y):RadRotate(self.RotAngle);
			poof.Lifetime = poof.Lifetime * RangeRand(0.3, 1.3) * 0.9;
			poof.Vel = self.Vel * 0.1
			poof.GlobalAccScalar = RangeRand(0.9, 1.0) * -0.4; -- Go up and down
			MovableMan:AddParticle(poof);
			self.smokeDelayTimer:Reset()
			
			--[[
			for i = 0, 2 do
				local poof = i == 0 and CreateMOSParticle("Tiny Smoke Ball 1") or CreateMOPixel("Real Bullet Micro Smoke Ball "..math.random(1,4), "Sandstorm.rte");
				poof.Pos = self.Pos + Vector(self.MuzzleOffset.X * self.FlipFactor, self.MuzzleOffset.Y):RadRotate(self.RotAngle) + Vector(RangeRand(-1,1), RangeRand(-1,1));
				poof.Lifetime = poof.Lifetime * RangeRand(0.7, 1.7) * 0.9;
				--poof.Vel = Vector(RangeRand(-1,1), RangeRand(-1,1)) * 0.5
				poof.GlobalAccScalar = RangeRand(0.9, 1.0) * -0.4; -- Go up and down
				MovableMan:AddParticle(poof);
				self.smokeDelayTimer:Reset()
			end]]
		end
	end
end