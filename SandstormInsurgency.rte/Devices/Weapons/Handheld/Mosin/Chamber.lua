function Create(self)

	self.parentSet = false;

	-- Sounds --
	self.preSounds = {["Variations"] = 1,
	["Path"] = "SandstormInsurgency.rte/Devices/Weapons/Handheld/Mosin/CompliSoundV2/Pre"};	
	
	self.addSounds = {["Loop"] = nil};
	self.addSounds.Loop = {["Variations"] = 4,
	["Path"] = "SandstormInsurgency.rte/Devices/Weapons/Handheld/Mosin/CompliSoundV2/Add"};
	
	self.bassSounds = {["Loop"] = nil};
	self.bassSounds.Loop = {["Variations"] = 1,
	["Path"] = "SandstormInsurgency.rte/Devices/Weapons/Handheld/Mosin/CompliSoundV2/Bass"};
	
	self.mechSounds = {["Loop"] = nil};
	self.mechSounds.Loop = {["Variations"] = 1,
	["Path"] = "SandstormInsurgency.rte/Devices/Weapons/Handheld/Mosin/CompliSoundV2/Mech"};
	
	self.noiseSounds = {["Outdoors"] = {["Loop"] = nil, ["End"] = nil},
	["Indoors"] = {["Loop"] = nil, ["End"] = nil},
	["bigIndoors"] = {["Loop"] = nil, ["End"] = nil}};
	self.noiseSounds.Outdoors.End = {["Variations"] = 5,
	["Path"] = "SandstormInsurgency.rte/Devices/Weapons/Handheld/Mosin/CompliSoundV2/NoiseOutdoorsEnd"};
	self.noiseSounds.Indoors.End = {["Variations"] = 6,
	["Path"] = "SandstormInsurgency.rte/Devices/Weapons/Handheld/Mosin/CompliSoundV2/NoiseIndoorsEnd"};
	self.noiseSounds.bigIndoors.End = {["Variations"] = 6,
	["Path"] = "SandstormInsurgency.rte/Devices/Weapons/Handheld/Mosin/CompliSoundV2/NoiseBigIndoorsEnd"};
	
	self.reflectionSounds = {["Outdoors"] = nil};
	self.reflectionSounds.Outdoors = {["Variations"] = 3,
	["Path"] = "SandstormInsurgency.rte/Devices/Weapons/Handheld/Mosin/CompliSoundV2/ReflectionOutdoors"};
	
	self.FireTimer = Timer();
	self:SetNumberValue("DelayedFireTimeMS", 25)
	
	self.originalStanceOffset = Vector(math.abs(self.StanceOffset.X), self.StanceOffset.Y)
	self.originalSharpStanceOffset = Vector(self.SharpStanceOffset.X, self.SharpStanceOffset.Y)
	
	self.originalSupportOffset = Vector(self.SupportOffset.X, self.SupportOffset.Y)

	local actor = MovableMan:GetMOFromID(self.RootID);
	if actor and IsAHuman(actor) then
		self.parent = ToAHuman(actor);
	end
	
	self.angVel = 0
	self.lastRotAngle = self.RotAngle
	
	self.rotation = 0
	self.rotationTarget = 0
	self.rotationSpeed = 5
	
	self.reloadTimer = Timer();
	
	self.boltUpPrepareDelay = 700;
	self.boltUpAfterDelay = 50;
	self.boltBackPrepareDelay = 100;
	self.boltBackAfterDelay = 150;
	self.shellInPrepareDelay = 500;
	self.shellInAfterDelay = 500;
	self.boltForwardPrepareDelay = 150;
	self.boltForwardAfterDelay = 100;
	self.boltDownPrepareDelay = 100;
	self.boltDownAfterDelay = 250;
	self.stripperClipOnPrepareDelay = 450;
	self.stripperClipOnAfterDelay = 450;
	self.stripperClipInPrepareDelay = 450;
	self.stripperClipInAfterDelay = 450;
	self.stripperClipOffPrepareDelay = 450;
	self.stripperClipOffAfterDelay = 450;
	
	-- phases:
	-- 0: bolt up
	-- 1: bolt back
	-- 2: special repeating reload phase
	-- 3: bolt forward
	-- 4: bolt down
	-- 5: stripper clip on
	-- 6: stripper clip in
	-- 7: stripper clip off
	
	self.reloadPhase = 0;
	self.ReloadTime = 19999;
	
	self.smokeTimer = Timer();
	self.smokeDelayTimer = Timer();
	self.canSmoke = false
	
	-- Strap
	self.beltStartPoint = Vector(-9,3)
	self.beltEndPoint = Vector(11,0)
	self.beltLengthMax = 15
	
	self.beltPointPosX = self.Pos.X
	self.beltPointPosY = self.Pos.Y
	
	self.beltPointVelX = 0
	self.beltPointVelY = 0
	
	self.color = 55
end

function Update(self)
	self.rotationTarget = 0 -- ZERO IT FIRST AAAA!!!!!

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
	
	if self.reChamber then
		if self:IsReloading() then
			self.Reloading = true;
			self.reloadCycle = true;
		end
		self.reChamber = false;
		self.Chamber = true;
		self.Casing = true;
	end
	
	if self:IsReloading() and (not self.Chamber) then -- if we start reloading from "scratch"
		self.Chamber = true;
		self.ReloadTime = 19999;
		self.Reloading = true;
		self.reloadCycle = true;
	end
	
	if self.parent then
		local ctrl = self.parent:GetController();
		local screen = ActivityMan:GetActivity():ScreenOfPlayer(ctrl.Player);
	
		if self:IsReloading() then
			self.parent:GetController():SetState(Controller.AIM_SHARP,false);
		end
		
		if self.resumeReload then
			self:Reload();
			self.resumeReload = false;
			if self.reloadPhase == 2 and self.ammoCount == 5 then
				self.reloadPhase = 3;
			end
		end
		if self.Chamber then
			self:Deactivate();
			
			if self:IsReloading() then
				-- Fancy Reload Progress GUI
				if not (not self.reloadCycle and self.parent:GetController():IsState(Controller.WEAPON_FIRE)) and self.parent:IsPlayerControlled() then
					for i = 1, self.ammoCount do
						local color = 120
						local spacing = 4
						local offset = Vector(0 - spacing * 0.5 + spacing * (i) - spacing * self.ammoCount / 2, (self.ammoCountRaised and i == self.ammoCount) and 35 or 36)
						local position = self.parent.AboveHUDPos + offset
						PrimitiveMan:DrawCirclePrimitive(position + Vector(0,-2), 1, color);
						PrimitiveMan:DrawLinePrimitive(position + Vector(1,-2), position + Vector(1,3), color);
						PrimitiveMan:DrawLinePrimitive(position + Vector(-1,-2), position + Vector(-1,3), color);
						PrimitiveMan:DrawLinePrimitive(position + Vector(1,3), position + Vector(-1,3), color);
					end
				end
				
				if self.Reloading == false then --change phases accordingly if we're already doing bolty stuff when we start reloading
					self.reloadCycle = true;
					self.ReloadTime = 19999;
					self.Reloading = true;
					self.reloadTimer:Reset();
					if self.reloadPhase == 3 then
						self.prepareSoundPlayed = false;
						self.afterSoundPlayed = false;
						self.reloadPhase = self.phasePrepareFinished and 1 or 2;
					elseif self.reloadPhase == 4 then
						self.prepareSoundPlayed = false;
						self.afterSoundPlayed = false;
						self.reloadPhase = self.phasePrepareFinished and 0 or 1;
					end
				end
				
			else
				self.Reloading = false;
			end
			
			if self.reloadPhase == 0 then
				self.reloadDelay = self.boltUpPrepareDelay;
				self.afterDelay = self.boltUpAfterDelay;
				
				self.prepareSoundPath = nil;
				self.prepareSoundVars = 1;
				self.afterSoundPath = 
				"SandstormInsurgency.rte/Devices/Weapons/Handheld/Mosin/Sounds/BoltUp";
				self.afterSoundVars = 1;
				
			elseif self.reloadPhase == 1 then
				self.reloadDelay = self.boltBackPrepareDelay;
				self.afterDelay = self.boltBackAfterDelay;
				self.prepareSoundPath = nil;
				self.prepareSoundVars = 1;
				if self:IsReloading() then
					self.afterSoundPath = 
					"SandstormInsurgency.rte/Devices/Weapons/Handheld/Mosin/Sounds/BoltBackReload";
					self.afterSoundVars = 1;
				else
					self.afterSoundPath = 
					"SandstormInsurgency.rte/Devices/Weapons/Handheld/Mosin/Sounds/BoltBack";
					self.afterSoundVars = 1;
				end
				
			elseif self.reloadPhase == 2 then
				self.reloadDelay = self.shellInPrepareDelay;
				self.afterDelay = self.shellInAfterDelay;
				self.prepareSoundPath = nil;
				self.prepareSoundVars = 1;
				self.afterSoundPath = 
				"SandstormInsurgency.rte/Devices/Weapons/Handheld/Mosin/Sounds/RoundIn";
				self.afterSoundVars = 5;
				
			elseif self.reloadPhase == 3 then
				self.reloadDelay = self.boltForwardPrepareDelay;
				self.afterDelay = self.boltForwardAfterDelay;
				self.prepareSoundPath = nil;
				self.prepareSoundVars = 1;
				self.afterSoundPath = 
				"SandstormInsurgency.rte/Devices/Weapons/Handheld/Mosin/Sounds/BoltForward";
				self.afterSoundVars = 1;
				
			elseif self.reloadPhase == 4 then
				self.Frame = 2;
				self.reloadDelay = self.boltDownPrepareDelay;
				self.afterDelay = self.boltDownAfterDelay;
				self.prepareSoundPath = nil;
				self.prepareSoundVars = 1;
				self.afterSoundPath = 
				"SandstormInsurgency.rte/Devices/Weapons/Handheld/Mosin/Sounds/BoltDown";
				self.afterSoundVars = 1;
				
			elseif self.reloadPhase == 5 then
				self.Frame = 5;
				self.reloadDelay = self.stripperClipOnPrepareDelay;
				self.afterDelay = self.stripperClipOnAfterDelay;
				self.prepareSoundPath = nil;
				self.prepareSoundVars = 1;
				self.afterSoundPath = 
				"SandstormInsurgency.rte/Devices/Weapons/Handheld/Mosin/Sounds/ClipOn";
				self.afterSoundVars = 1;
				
			elseif self.reloadPhase == 6 then
				self.Frame = 10;
				self.reloadDelay = self.stripperClipInPrepareDelay;
				self.afterDelay = self.stripperClipInAfterDelay;
				self.prepareSoundPath = nil;
				self.prepareSoundVars = 1;
				self.afterSoundPath = 
				"SandstormInsurgency.rte/Devices/Weapons/Handheld/Mosin/Sounds/ClipIn";
				self.afterSoundVars = 1;
				
			elseif self.reloadPhase == 7 then
				self.Frame = 13;
				self.reloadDelay = self.stripperClipOffPrepareDelay;
				self.afterDelay = self.stripperClipOffAfterDelay;
				self.prepareSoundPath = nil;
				self.prepareSoundVars = 1;
				self.afterSoundPath = 
				"SandstormInsurgency.rte/Devices/Weapons/Handheld/Mosin/Sounds/ClipOff";
				self.afterSoundVars = 1;
				
			end
			
			if self.prepareSoundPlayed ~= true then
				self.prepareSoundPlayed = true;
				if self.prepareSoundPath then
					self.prepareSound = AudioMan:PlaySound(self.prepareSoundPath .. math.random(1, self.prepareSoundVars) .. ".ogg", self.Pos, -1, 0, 130, 1, 250, false);
				end
			end
			
			if self.reloadTimer:IsPastSimMS(self.reloadDelay) then
			
				self.phasePrepareFinished = true;
			
				if self.afterSoundPlayed ~= true then
				
					self.afterSoundPlayed = true;
					if self.afterSoundPath then
						self.afterSound = AudioMan:PlaySound(self.afterSoundPath .. math.random(1, self.afterSoundVars) .. ".ogg", self.Pos, -1, 0, 130, 1, 250, false);
					end
				end
			
				if self.reloadPhase == 0 then
					
					if self.reloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay/5)*2)) then
						self.Frame = 2;
					elseif self.reloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay/5)*1)) then
						self.Frame = 1;
					end
					
				elseif self.reloadPhase == 1 then
					
					if self.reloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay/5)*2)) then
						self.Frame = 5;
					elseif self.reloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay/5)*1.5)) then
						self.Frame = 4;
					elseif self.reloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay/5)*1)) then
						self.Frame = 3;
					end
					
				elseif self.reloadPhase == 2 then
				
					if self.reloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay/5)*2.5)) then
						self.Frame = 5;
					elseif self.reloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay/5)*2)) then
						self.Frame = 8;
					elseif self.reloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay/5)*1.5)) then
						self.Frame = 7;
					elseif self.reloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay/5)*1)) then
						self.Frame = 6;
					end
				
					if self.parent:GetController():IsState(Controller.WEAPON_FIRE) then
						self.reloadCycle = false;
						PrimitiveMan:DrawTextPrimitive(screen, self.parent.AboveHUDPos + Vector(0, 30), "Interrupting...", true, 1);
					end
				
					if self.ammoCountRaised ~= true then
						self.ammoCountRaised = true;
						if self.ammoCount < 5 then
							self.ammoCount = self.ammoCount + 1;
							if self.ammoCount == 5 then
								self.reloadCycle = false;
							end
						else
							self.reloadCycle = false;
						end
					end
					
				elseif self.reloadPhase == 3 then

					if self.reloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay/5)*2)) then
						self.Frame = 2;
					elseif self.reloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay/5)*1.5)) then
						self.Frame = 3;
					elseif self.reloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay/5)*1)) then
						self.Frame = 4;
					end

				elseif self.reloadPhase == 4 then
					
					if self.reloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay/5)*2)) then
						self.Frame = 0;
					elseif self.reloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay/5)*1.5)) then
						self.Frame = 1;
					elseif self.reloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay/5)*1)) then
						self.Frame = 2;
					end
					
				elseif self.reloadPhase == 5 then
					
					if self.reloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay/5)*2)) then
						self.Frame = 10;
					elseif self.reloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay/5)*1.5)) then
						self.Frame = 9;
					end
					
				elseif self.reloadPhase == 6 then
					
					if self.reloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay/5)*2)) then
						self.Frame = 13;
					elseif self.reloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay/5)*1.5)) then
						self.Frame = 12;
					elseif self.reloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay/5)*1)) then
						self.Frame = 11;
					end
					
				elseif self.reloadPhase == 7 then
					
					self.Frame = 5;
					
					self.ammoCount = 5;

				end
				
				if self.reloadTimer:IsPastSimMS(self.reloadDelay + self.afterDelay) then
					self.reloadTimer:Reset();
					self.prepareSoundPlayed = false;
					self.afterSoundPlayed = false;
					if self.reloadPhase == 1 then

						if not self:IsReloading() then
							self.reloadPhase = 3;
						elseif self.ammoCount == 0 then
							self.reloadPhase = 5;
						else
							self.reloadPhase = self.reloadPhase + 1;
						end
								
						if self.Casing == true then
							local casing
							casing = CreateAEmitter("Sandstorm Mosin Rifle Casing");
							casing.Pos = self.Pos+Vector(-5*self.FlipFactor,-2):RadRotate(self.RotAngle);
							casing.Vel = self.Vel+Vector(-math.random(2,4)*self.FlipFactor,-math.random(3,4)):RadRotate(self.RotAngle);
							MovableMan:AddParticle(casing);

							self.Casing = false;
						end					
					
					elseif self.reloadPhase == 2 then
					
						self.ammoCountRaised = false;
					
						if self.reloadCycle then
							self.reloadPhase = 2; -- same phase baby the ride never ends (except at 5 rounds)
						else
							self.reloadPhase = self.reloadPhase + 1;
						end
					
					elseif self.reloadPhase == 4 then
					
						self.ReloadTime = 0;
						self.reloadPhase = 0;
						self.Chamber = false;
						
					elseif self.reloadPhase == 7 then
					
						self.reloadPhase = 3;
						
					else
						self.reloadPhase = self.reloadPhase + 1;
					end
				end				
			else
				self.phasePrepareFinished = false;
			end
			
		else
			
			self.reloadTimer:Reset();
			self.prepareSoundPlayed = false;
			self.afterSoundPlayed = false;
			self.ReloadTime = 19999;
		end
	else
		self.ammoCountRaised = false;
		if self.Reloading then
			self.resumeReload = true;
		end
		if self.reloadPhase == 2 or self.reloadPhase == 5 or self.reloadPhase == 6 or self.reloadPhase == 7 then
			self.Frame = 5;
		end
		if self.reloadPhase == 6 or self.reloadPhase == 7 then
			self.reloadPhase = 5;
		end
		self.reloadTimer:Reset();
		self.prepareSoundPlayed = false;
		self.afterSoundPlayed = false;
		self.ReloadTime = 19999;
	end
	
	--print(self.ammoCount)
	
	if self:DoneReloading() then
		self.Magazine.RoundCount = self.ammoCount;
		self.Reloading = false;
	end
	
	if self.FiredFrame then	
		self.canSmoke = true
		self.smokeTimer:Reset()
		
		self.angVel = self.angVel - RangeRand(0.7,1.1) * 6
		
		self.reloadTimer:Reset();
		self.reChamber = true;
		
		if self.Magazine then
			self.ammoCount = 0 + self.Magazine.RoundCount; -- +0 to avoid reference bullshit and save it as a number properly
		end
		
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
		
		self.mechSound = AudioMan:PlaySound(self.mechSounds.Loop.Path .. math.random(1, self.mechSounds.Loop.Variations) .. ".ogg", self.Pos, -1, 0, 130, 1, 450, false);
		
		self.bassSound = AudioMan:PlaySound(self.bassSounds.Loop.Path .. math.random(1, self.bassSounds.Loop.Variations) .. ".ogg", self.Pos, -1, 0, 130, 1, 450, false);
		
		if outdoorRays >= self.rayThreshold then
			self.noiseEndSound = AudioMan:PlaySound(self.noiseSounds.Outdoors.End.Path .. math.random(1, self.noiseSounds.Outdoors.End.Variations) .. ".ogg", self.Pos, -1, 0, 130, 1, 450, false);
			self.reflectionSound = AudioMan:PlaySound(self.reflectionSounds.Outdoors.Path .. math.random(1, self.reflectionSounds.Outdoors.Variations) .. ".ogg", self.Pos, -1, 0, 130, 1, 450, false);
		elseif math.max(outdoorRays, bigIndoorRays, indoorRays) == indoorRays then
			self.noiseEndSound = AudioMan:PlaySound(self.noiseSounds.Indoors.End.Path .. math.random(1, self.noiseSounds.Indoors.End.Variations) .. ".ogg", self.Pos, -1, 0, 130, 1, 450, false);
		else -- bigIndoor
			self.noiseEndSound = AudioMan:PlaySound(self.noiseSounds.bigIndoors.End.Path .. math.random(1, self.noiseSounds.bigIndoors.End.Variations) .. ".ogg", self.Pos, -1, 0, 130, 1, 450, false);
		end

	
		self.addSound = AudioMan:PlaySound(self.addSounds.Loop.Path .. math.random(1, self.addSounds.Loop.Variations) .. ".ogg", self.Pos, -1, 0, 130, 1, 450, false);

	end
	
	-- Animation
	if self.parent then
		local chamberOffset = self.Frame ~= 0 and Vector(-self.originalSupportOffset.X, -self.originalSupportOffset.Y) or Vector(0,0)
		local chamberAnim = {Vector(0, 0), Vector(-5, -1), Vector(-5, -2), Vector(-6, -2), Vector(-7, -2), Vector(-8, -2), Vector(-3, -2), Vector(-3, -2), Vector(-3, -2)}
		chamberOffset = chamberOffset + chamberAnim[self.Frame + 1]
		
		self.rotationTarget = self.rotationTarget - (self.angVel * 5.5) -- aim sway/smoothing
		
		local offset = chamberOffset
		self.SupportOffset = self.originalSupportOffset + offset
		
		local stance = Vector(0, 0)
		if self.Chamber then
			stance = stance + Vector(2,0)
		end
		
		self.rotation = (self.rotation + self.rotationTarget * TimerMan.DeltaTimeSecs * self.rotationSpeed) / (1 + TimerMan.DeltaTimeSecs * self.rotationSpeed)
		local total = math.rad(self.rotation) * self.FlipFactor
		
		self.RotAngle = self.RotAngle + total;
		
		local jointOffset = Vector(self.JointOffset.X * self.FlipFactor, self.JointOffset.Y):RadRotate(self.RotAngle);
		local offsetTotal = Vector(jointOffset.X, jointOffset.Y):RadRotate(-total) - jointOffset
		self.Pos = self.Pos + offsetTotal;
		
		self.StanceOffset = Vector(self.originalStanceOffset.X, self.originalStanceOffset.Y) + stance
		self.SharpStanceOffset = Vector(self.originalSharpStanceOffset.X, self.originalSharpStanceOffset.Y) + stance
	end
	
	if self.canSmoke and not self.smokeTimer:IsPastSimMS(2000) then
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
	
	-- Strap
	local posA = Vector(self.Pos.X, self.Pos.Y) + Vector(self.beltStartPoint.X * self.FlipFactor, self.beltStartPoint.Y):RadRotate(self.RotAngle)
	local posB = Vector(self.Pos.X, self.Pos.Y) + Vector(self.beltEndPoint.X * self.FlipFactor, self.beltEndPoint.Y):RadRotate(self.RotAngle)
	--PrimitiveMan:DrawLinePrimitive(self.Pos, self.Pos + self.beltPointA, 5);
	--PrimitiveMan:DrawLinePrimitive(posA, posB, 5);
	-- Physics
	local v = Vector(self.beltPointVelX, self.beltPointVelY) + SceneMan.GlobalAcc * TimerMan.DeltaTimeSecs -- Gravity
	
	-- Pull the point to belt Stat and End points
	for i, point in ipairs({self.beltStartPoint, self.beltEndPoint}) do
		point = Vector(self.Pos.X, self.Pos.Y) + Vector(point.X * self.FlipFactor, point.Y):RadRotate(self.RotAngle)
		local dif = SceneMan:ShortestDistance(Vector(self.beltPointPosX, self.beltPointPosY), point,SceneMan.SceneWrapsX)
		v = v + dif * math.min(math.max((dif.Magnitude / 5) - 1, 0), 6) * TimerMan.DeltaTimeSecs
	end
	
	v = v / (1 + TimerMan.DeltaTimeSecs * 6.0) -- Air Friction
	
	self.beltPointVelX = v.X
	self.beltPointVelY = v.Y
	
	self.beltPointPosX = self.beltPointPosX + self.beltPointVelX * rte.PxTravelledPerFrame
	self.beltPointPosY = self.beltPointPosY + self.beltPointVelY * rte.PxTravelledPerFrame
	
	-- Limit Position
	local posCenter = (posA + posB) * 0.5
	local newPos = SceneMan:ShortestDistance(posCenter, Vector(self.beltPointPosX, self.beltPointPosY), SceneMan.SceneWrapsX)
	newPos = posCenter + newPos:SetMagnitude(math.min(newPos.Magnitude, self.beltLengthMax))
	self.beltPointPosX = newPos.X
	self.beltPointPosY = newPos.Y
	
	-- DEBUG
	--PrimitiveMan:DrawLinePrimitive(posA, posA, 13);
	--PrimitiveMan:DrawLinePrimitive(posB, posB, 13);
	local pos = Vector(self.beltPointPosX, self.beltPointPosY)
	--PrimitiveMan:DrawLinePrimitive(pos, pos + SceneMan:ShortestDistance(pos,posA,SceneMan.SceneWrapsX), 5);
	--PrimitiveMan:DrawLinePrimitive(pos, pos + SceneMan:ShortestDistance(pos,posB,SceneMan.SceneWrapsX), 5);
	
	local maxi = 5
	local pointLast = Vector(0,0)
	for i = 0, maxi do
		local fac = i / maxi
		local p1 =  posA - self.Pos
		local p2 =  pos - self.Pos
		local p3 =  posB - self.Pos
		
		local point = p1 * math.pow(1 - fac, 2) + p2 * 2 * (1 - fac) * fac + p3 * math.pow(fac, 2)
		
		--PrimitiveMan:DrawLinePrimitive(self.Pos + p1, self.Pos + p2, 13)
		--PrimitiveMan:DrawLinePrimitive(self.Pos + p3, self.Pos + p2, 13)
		if i > 0 then
			PrimitiveMan:DrawLinePrimitive(self.Pos + point, self.Pos + pointLast, self.color)
		end
		pointLast = point
		
		--PrimitiveMan:DrawCirclePrimitive(self.Pos + p1, 1, 13);
		--PrimitiveMan:DrawCirclePrimitive(self.Pos + p2, 1, 13);
		--PrimitiveMan:DrawCirclePrimitive(self.Pos + p3, 1, 13);
	end
	
	-- Simple fix for scene wrapping
	
	if SceneMan.SceneWrapsX then
		if self.beltPointPosX > SceneMan.SceneWidth then
			self.beltPointPosX = self.beltPointPosX - SceneMan.SceneWidth
		elseif self.beltPointPosX < 0 then
			self.beltPointPosX = self.beltPointPosX + SceneMan.SceneWidth
		end
	end
end