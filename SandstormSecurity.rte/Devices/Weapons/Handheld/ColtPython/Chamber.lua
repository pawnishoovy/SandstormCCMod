function Create(self)

	self.parentSet = false;
	
	-- Sounds --
	
	self.preSounds = {["Normal"] = nil, ["Precision"] = nil};
	self.preSounds.Normal = CreateSoundContainer("Pre ColtPython", "SandstormSecurity.rte");
	self.preSounds.Precision = CreateSoundContainer("PrecisionPre ColtPython", "SandstormSecurity.rte");
	
	self.sharpAimSounds = {["In"] = nil, ["Out"] = nil};
	self.sharpAimSounds.In = CreateSoundContainer("SharpAimIn ColtPython", "SandstormSecurity.rte");
	self.sharpAimSounds.Out = CreateSoundContainer("SharpAimOut ColtPython", "SandstormSecurity.rte");
	
	self.addSounds = {["Start"] = nil, ["Loop"] = nil};
	self.addSounds.Loop = CreateSoundContainer("Add ColtPython", "SandstormSecurity.rte");
	
	self.noiseSounds = {["Outdoors"] = {["Loop"] = nil, ["End"] = nil},
	["Indoors"] = {["Loop"] = nil, ["End"] = nil},
	["bigIndoors"] = {["Loop"] = nil, ["End"] = nil}};
	self.noiseSounds.Outdoors.End = CreateSoundContainer("NoiseOutdoorsEnd ColtPython", "SandstormSecurity.rte");
	self.noiseSounds.Outdoors.End.Pitch = 1.0;
	self.noiseSounds.Indoors.End = CreateSoundContainer("NoiseIndoorsEnd ColtPython", "SandstormSecurity.rte");
	self.noiseSounds.Indoors.End.Pitch = 1.0;
	self.noiseSounds.bigIndoors.End = CreateSoundContainer("NoiseBigIndoorsEnd ColtPython", "SandstormSecurity.rte");
	self.noiseSounds.bigIndoors.End.Pitch = 1.0;
	
	self.reflectionSounds = {["Outdoors"] = nil};
	self.reflectionSounds.Outdoors = CreateSoundContainer("Noise ReflectionOutdoors", "Sandstorm.rte");
	self.reflectionSounds.Outdoors.Pitch = 1.0
	
	self.reloadPrepareSounds = {["CylinderOpen"] = nil, ["EjectorRod"] = nil, ["SpeedLoader"] = nil, ["CylinderClose"] = nil}
	self.reloadPrepareSounds.CylinderOpen = CreateSoundContainer("CylinderOpenPrepare ColtPython", "SandstormSecurity.rte");
	self.reloadPrepareSounds.EjectorRod = CreateSoundContainer("EjectorRodPrepare ColtPython", "SandstormSecurity.rte");
	self.reloadPrepareSounds.SpeedLoader = CreateSoundContainer("SpeedLoaderPrepare ColtPython", "SandstormSecurity.rte");
	
	self.reloadPrepareLengths = {["CylinderOpen"] = nil, ["EjectorRod"] = nil, ["SpeedLoader"] = nil, ["CylinderClose"] = nil}
	self.reloadPrepareLengths.CylinderOpen = 400;
	self.reloadPrepareLengths.EjectorRod = 100;
	self.reloadPrepareLengths.SpeedLoader = 400;
	
	self.reloadAfterSounds = {["CylinderOpen"] = nil, ["EjectorRod"] = nil, ["SpeedLoader"] = nil, ["CylinderClose"] = nil}
	self.reloadAfterSounds.CylinderOpen = CreateSoundContainer("CylinderOpen ColtPython", "SandstormSecurity.rte");
	self.reloadAfterSounds.EjectorRod = CreateSoundContainer("EjectorRod ColtPython", "SandstormSecurity.rte");
	self.reloadAfterSounds.SpeedLoader = CreateSoundContainer("SpeedLoader ColtPython", "SandstormSecurity.rte");
	self.reloadAfterSounds.CylinderClose = CreateSoundContainer("CylinderClose ColtPython", "SandstormSecurity.rte");
	
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
	
	-- Progressive Recoil System 
	self.recoilAcc = 0 -- for sinous
	self.recoilStr = 0 -- for accumulator
	self.recoilStrength = 13 -- multiplier for base recoil added to the self.recoilStr when firing
	self.recoilPowStrength = 0.4 -- multiplier for self.recoilStr when firing
	self.recoilRandomUpper = 1.2 -- upper end of random multiplier (1 is lower)
	self.recoilDamping = 0.9
	
	self.recoilMax = 20 -- in deg.
	self.originalSharpLength = self.SharpLength
	-- Progressive Recoil System 	
	
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
						self.preSounds.Precision:Play(self.Pos);
						self.cocked = true
						self.angVel = self.angVel - RangeRand(0.7,1.1) * 5
						self.swayAcc = 0
						self.Frame = 1;
					end
					
					-- Cool awesome precision mode focus hud cosshair
					--[[
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
					end]]
					-- rip Cool awesome precision mode focus hud crosshair ;-(
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
			self.preSounds.Normal:Play(self.Pos);
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
			
			self.prepareSound = self.reloadPrepareSounds.CylinderOpen;
			self.prepareSoundLength = self.reloadPrepareLengths.CylinderOpen;
			self.afterSound = self.reloadAfterSounds.CylinderOpen;
			
			self.rotationTarget = 5;
			self.ejectedShell = false
		elseif self.reloadPhase == 1 then
			self.reloadDelay = self.ejectorRodPrepareDelay;
			self.afterDelay = self.ejectorRodAfterDelay;
			
			self.prepareSound = self.reloadPrepareSounds.EjectorRod;
			self.prepareSoundLength = self.reloadPrepareLengths.EjectorRod;
			self.afterSound = self.reloadAfterSounds.EjectorRod;
			
			self.rotationTarget = 45;
			
		elseif self.reloadPhase == 2 then
			self.reloadDelay = self.speedLoaderPrepareDelay;
			self.afterDelay = self.speedLoaderAfterDelay;
			
			self.prepareSound = self.reloadPrepareSounds.SpeedLoader;
			self.prepareSoundLength = self.reloadPrepareLengths.SpeedLoader;
			self.afterSound = self.reloadAfterSounds.SpeedLoader;
			
			self.rotationTarget = -25;
			
		elseif self.reloadPhase == 3 then
			self.reloadDelay = self.cylinderClosePrepareDelay;
			self.afterDelay = self.cylinderCloseAfterDelay;		
			
			self.prepareSound = nil;
			self.prepareSoundLength = 0;
			self.afterSound = self.reloadAfterSounds.CylinderClose;
			
			self.rotationTarget = -5;
			--self.rotationTarget = -360 * 2; -- meme reload
		end
		
		if self.prepareSoundPlayed ~= true
		and self.reloadTimer:IsPastSimMS(self.reloadDelay - self.prepareSoundLength) then
			self.prepareSoundPlayed = true;
			if self.prepareSound then
				self.prepareSound:Play(self.Pos);
			end
		end
		
		if self.prepareSound then self.prepareSound.Pos = self.Pos; end
		self.afterSound.Pos = self.Pos;
	
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
				if self.afterSound then
					self.afterSound:Play(self.Pos);
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
	
	if self.delayedFire then
		if self.delayedFireTimer:IsPastSimMS(self.delayedFireTimeMS) or self.cocked then
			self:Activate()
		end
	end
	
	if self.FiredFrame then
		self.horizontalAnim = self.horizontalAnim + 6
		
		if self.parent then
			local controller = self.parent:GetController();		
		
			if controller:IsState(Controller.BODY_CROUCH) or self.cocked then
				self.recoilStrength = 11
				self.recoilPowStrength = 1.5
				self.recoilRandomUpper = 1
				self.recoilDamping = 0.4
				
				self.recoilMax = 20
			else
				self.recoilStrength = 13
				self.recoilPowStrength = 1.4
				self.recoilRandomUpper = 1.2
				self.recoilDamping = 0.25
				
				self.recoilMax = 20
			end
			if (not controller:IsState(Controller.AIM_SHARP))
			or (controller:IsState(Controller.MOVE_LEFT)
			or controller:IsState(Controller.MOVE_RIGHT)) then
				self.recoilDamping = self.recoilDamping * 0.9;
			end
		end
		
		self.Frame = 0;
		
		--if self.Magazine then
		--	self.Magazine.RoundCount = self.Magazine.RoundCount - 1
		--end
		
		self.canSmoke = true
		self.smokeTimer:Reset()

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
			self.noiseSounds.Outdoors.End:Play(self.Pos);
			self.reflectionSounds.Outdoors:Play(self.Pos);
		elseif math.max(outdoorRays, bigIndoorRays, indoorRays) == indoorRays then
			self.noiseSounds.Indoors.End:Play(self.Pos);
		else -- bigIndoor
			self.noiseSounds.bigIndoors.End:Play(self.Pos);
		end

	
		self.addSounds.Loop:Play(self.Pos);
		
		self.delayedFire = false
		
		self.canShoot = false
		self.cocked = false
	end
	
	-- Animation
	if self.parent then
		self.horizontalAnim = math.floor(self.horizontalAnim / (1 + TimerMan.DeltaTimeSecs * 24.0) * 1000) / 1000
		self.verticalAnim = math.floor(self.verticalAnim / (1 + TimerMan.DeltaTimeSecs * 15.0) * 1000) / 1000
		
		local stance = Vector()
		stance = stance + Vector(-1,0) * self.horizontalAnim -- Horizontal animation
		stance = stance + Vector(0,5) * self.verticalAnim -- Vertical animation
		
		-- Progressive Recoil Update
		if self.FiredFrame then
			self.recoilStr = self.recoilStr + ((math.random(10, self.recoilRandomUpper * 10) / 10) * 0.5 * self.recoilStrength) + (self.recoilStr * 0.6 * self.recoilPowStrength)
			self:SetNumberValue("recoilStrengthBase", self.recoilStrength * (1 + self.recoilPowStrength) / self.recoilDamping)
		end
		self:SetNumberValue("recoilStrengthCurrent", self.recoilStr)
		
		self.recoilStr = math.floor(self.recoilStr / (1 + TimerMan.DeltaTimeSecs * 8.0 * self.recoilDamping) * 1000) / 1000
		self.recoilAcc = (self.recoilAcc + self.recoilStr * TimerMan.DeltaTimeSecs) % (math.pi * 4)
		
		local recoilA = (math.sin(self.recoilAcc) * self.recoilStr) * 0.05 * self.recoilStr
		local recoilB = (math.sin(self.recoilAcc * 0.5) * self.recoilStr) * 0.01 * self.recoilStr
		local recoilC = (math.sin(self.recoilAcc * 0.25) * self.recoilStr) * 0.05 * self.recoilStr
		
		local recoilFinal = math.max(math.min(recoilA + recoilB + recoilC, self.recoilMax), -self.recoilMax)
		
		local sharpRecoil = (0.9 + math.pow(math.min(self.delayedFireTimer.ElapsedSimTimeMS / (250), 1), 2.0) * 0.1)
		local sharpFocus = math.pow(math.min(self.cockTimer.ElapsedSimTimeMS / (self.cockDelay + self.cockedAimFocus), 1), 2)
		
		--self.SharpLength = self.originalSharpLength * sharpRecoil * (1 + sharpFocus * 0.5)
		--local sharpSpeed = 15
		--self.SharpLength = (self.SharpLength + (self.originalSharpLength * sharpRecoil * (1 + sharpFocus * 0.5)) * TimerMan.DeltaTimeSecs * sharpSpeed) / (1 + TimerMan.DeltaTimeSecs * sharpSpeed)
		self.SharpLength = math.max(self.originalSharpLength * (1 + sharpFocus * 0.5) - (self.recoilStr * 3 + math.abs(recoilFinal)), 0)
		
		self.rotationTarget = self.rotationTarget + recoilFinal -- apply the recoil
		-- Progressive Recoil Update	
		
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