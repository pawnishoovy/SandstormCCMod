function Create(self)

	self.parentSet = false;

	-- Sounds --
	self.addSounds = {["Start"] = nil, ["Loop"] = nil};
	self.addSounds.Loop = {["Variations"] = 4,
	["Path"] = "SandstormSecurity.rte/Devices/Weapons/Handheld/M3MAAWS/CompliSoundV2/Add"};
	
	self.bassSounds = {["Loop"] = nil};
	self.bassSounds.Loop = {["Variations"] = 1,
	["Path"] = "SandstormSecurity.rte/Devices/Weapons/Handheld/M3MAAWS/CompliSoundV2/Bass"};
	
	self.noiseSounds = {["Outdoors"] = {["End"] = nil},
	["Indoors"] = {["End"] = nil},
	["bigIndoors"] = {["End"] = nil}};
	self.noiseSounds.Outdoors.End = {["Variations"] = 4,
	["Path"] = "SandstormSecurity.rte/Devices/Weapons/Handheld/M3MAAWS/CompliSoundV2/NoiseOutdoorsEnd"};
	self.noiseSounds.Indoors.End = {["Variations"] = 4,
	["Path"] = "SandstormSecurity.rte/Devices/Weapons/Handheld/M3MAAWS/CompliSoundV2/NoiseIndoorsEnd"};
	self.noiseSounds.bigIndoors.End = {["Variations"] = 4,
	["Path"] = "SandstormSecurity.rte/Devices/Weapons/Handheld/M3MAAWS/CompliSoundV2/NoiseBigIndoorsEnd"};
	
	self.reflectionSounds = {["Outdoors"] = nil};
	self.reflectionSounds.Outdoors = {["Variations"] = 3,
	["Path"] = "SandstormSecurity.rte/Devices/Weapons/Handheld/M3MAAWS/CompliSoundV2/ReflectionOutdoors"};
	
	self.originalStanceOffset = Vector(math.abs(self.StanceOffset.X), self.StanceOffset.Y)
	self.originalSharpStanceOffset = Vector(math.abs(self.SharpStanceOffset.X), self.SharpStanceOffset.Y)
	
	self.rotation = 0
	self.rotationTarget = 0
	self.rotationSpeed = 5
	
	self.horizontalAnim = 0
	self.verticalAnim = 0
	
	self.angVel = 0
	self.lastRotAngle = self.RotAngle
	
	self.smokeTimer = Timer();
	self.smokeDelayTimer = Timer();
	self.canSmoke = false
	
	self.reloadTimer = Timer();
	
	self.raisePrepareDelay = 750;
	self.raiseAfterDelay = 800;
	self.openTubePrepareDelay = 550;
	self.openTubeAfterDelay = 540;
	self.removeRoundPrepareDelay = 200;
	self.removeRoundAfterDelay = 500;
	self.insertRoundPrepareDelay = 1800;
	self.insertRoundAfterDelay = 730;
	self.closeTubePrepareDelay = 120;
	self.closeTubeAfterDelay = 700;
	self.shoulderPrepareDelay = 760;
	self.shoulderAfterDelay = 400;
	
	-- phases:
	-- 0 raise
	-- 1 opentube
	-- 2 removeround
	-- 3 insertround
	-- 4 closetube
	-- 5 shoulder
	
	self.reloadPhase = 0;
	
	self.ReloadTime = 19999;

	local actor = MovableMan:GetMOFromID(self.RootID);
	if actor and IsAHuman(actor) then
		self.parent = ToAHuman(actor);
	end
	
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
	--PrimitiveMan:DrawTextPrimitive(self.Pos + Vector(-20, 20), "Angular Velocity = "..self.angVel, true, 0);
	--PrimitiveMan:DrawLinePrimitive(self.Pos, self.Pos + Vector(15 * self.FlipFactor,0):RadRotate(self.RotAngle),  13);
	--PrimitiveMan:DrawLinePrimitive(self.Pos, self.Pos + Vector(15 * self.FlipFactor,0):RadRotate(self.RotAngle + (self.angVel * 0.05)),  5);
	
	if self:IsReloading() then
		if self.parent and self.reloadPhase > 0 and  self.reloadPhase < 5 then
			self.parent:GetController():SetState(Controller.AIM_SHARP,false);
		end
		
		self.phaseOnStop = 0; -- ALWAYS 0
		
		if not self:NumberValueExists("MagRemoved") and self.parent:IsPlayerControlled() then
			local color = (self.reloadPhase < 3 and 105 or 120)
			local position = self.parent.AboveHUDPos + Vector(0, 36)
			PrimitiveMan:DrawCirclePrimitive(position + Vector(0,-3), 2, color);
			PrimitiveMan:DrawLinePrimitive(position + Vector(2,-2), position + Vector(2,4), color);
			PrimitiveMan:DrawLinePrimitive(position + Vector(-2,-2), position + Vector(-2,4), color);
			PrimitiveMan:DrawLinePrimitive(position + Vector(2,4), position + Vector(-2,4), color);
		end

		if self.reloadPhase == 0 then
			self.reloadDelay = self.raisePrepareDelay;
			self.afterDelay = self.raiseAfterDelay;			
			self.prepareSoundPath = 
			"SandstormSecurity.rte/Devices/Weapons/Handheld/M3MAAWS/Sounds/RaisePrepare1";
			self.afterSoundPath = 
			"SandstormSecurity.rte/Devices/Weapons/Handheld/M3MAAWS/Sounds/Raise1";
			
		elseif self.reloadPhase == 1 then
			self.reloadDelay = self.openTubePrepareDelay;
			self.afterDelay = self.openTubeAfterDelay;
			self.prepareSoundPath = 
			"SandstormSecurity.rte/Devices/Weapons/Handheld/M3MAAWS/Sounds/OpenTubePrepare1";
			self.afterSoundPath = 
			"SandstormSecurity.rte/Devices/Weapons/Handheld/M3MAAWS/Sounds/OpenTube1";
			
			self.rotationTarget = -45;
			
		elseif self.reloadPhase == 2 then
			self.reloadDelay = self.removeRoundPrepareDelay;
			self.afterDelay = self.removeRoundAfterDelay;
			self.prepareSoundPath = nil;
			self.afterSoundPath = 
			"SandstormSecurity.rte/Devices/Weapons/Handheld/M3MAAWS/Sounds/RemoveRound1";
			
			self.rotationTarget = -45;
			
		elseif self.reloadPhase == 3 then
			self.reloadDelay = self.insertRoundPrepareDelay;
			self.afterDelay = self.insertRoundAfterDelay;
			self.prepareSoundPath = nil;
			self.afterSoundPath = 
			"SandstormSecurity.rte/Devices/Weapons/Handheld/M3MAAWS/Sounds/InsertRound1";
			
			self.rotationTarget = -45;
			
		elseif self.reloadPhase == 4 then
			self.reloadDelay = self.closeTubePrepareDelay;
			self.afterDelay = self.closeTubeAfterDelay;
			self.prepareSoundPath = 
			"SandstormSecurity.rte/Devices/Weapons/Handheld/M3MAAWS/Sounds/CloseTubePrepare1";
			self.afterSoundPath = 
			"SandstormSecurity.rte/Devices/Weapons/Handheld/M3MAAWS/Sounds/CloseTube1";
			
			self.rotationTarget = -45;
			
		elseif self.reloadPhase == 5 then
			self.reloadDelay = self.shoulderPrepareDelay;
			self.afterDelay = self.shoulderAfterDelay;
			self.prepareSoundPath = 
			"SandstormSecurity.rte/Devices/Weapons/Handheld/M3MAAWS/Sounds/ShoulderPrepare1";
			self.afterSoundPath = 
			"SandstormSecurity.rte/Devices/Weapons/Handheld/M3MAAWS/Sounds/Shoulder1";

			self.rotationTarget = -45;
		end
		
		if self.prepareSoundPlayed ~= true then
			self.prepareSoundPlayed = true;
			if self.prepareSoundPath then
				self.prepareSound = AudioMan:PlaySound(self.prepareSoundPath .. ".ogg", self.Pos, -1, 0, 130, 1, 250, false);
			end
		end
	
		if self.reloadTimer:IsPastSimMS(self.reloadDelay) then
		
			self.phasePrepareFinished = true;
			
			if self.reloadPhase == 0 then
			
				if self.reloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay/5)*2)) then
					self.reloadingVector = Vector(8, 7);
				elseif self.reloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay/5)*1.5)) then
					self.reloadingVector = Vector(3, 3);
				elseif self.reloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay/5)*1)) then
					self.reloadingVector = Vector(0, 0);
				end
			
				self.rotationTarget = -45;

			elseif self.reloadPhase == 1 then
			
				if self.reloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay/5)*3)) then
					self.Frame = 4;
					self.tubeOpened = true;
				elseif self.reloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay/5)*2)) then
					self.Frame = 3;
				elseif self.reloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay/5)*1.5)) then
					self.Frame = 2;
				elseif self.reloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay/5)*1)) then
					self.Frame = 1;
				end

			elseif self.reloadPhase == 2 then
			
				if self.reloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay/5)*2.5)) then
					self.Frame = 4;
					--[[
					if not self.roundRemoved then
						self.roundRemoved = true;
						local fake
						fake = CreateMOSRotating("Casing M3MAAWS");
						fake.Pos = self.Pos + Vector(-9*self.FlipFactor, 2):RadRotate(self.RotAngle);
						fake.Vel = self.Vel + Vector(-4*self.FlipFactor, 0):RadRotate(self.RotAngle);
						fake.RotAngle = self.RotAngle;
						--fake.AngularVel = self.AngularVel + (-1*self.FlipFactor);
						fake.HFlipped = self.HFlipped;
						MovableMan:AddParticle(fake);
						
					end]]
				elseif self.reloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay/5)*2.2)) then
					self.Frame = 5;
				elseif self.reloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay/5)*1.9)) then
					self.Frame = 6;
				elseif self.reloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay/5)*1.6)) then
					self.Frame = 7;
				elseif self.reloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay/5)*1.3)) then
					self.Frame = 8;
				elseif self.reloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay/5)*1)) then
					self.Frame = 9;
				end

			elseif self.reloadPhase == 3 then
			
				if self.reloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay/5)*2.5)) then
					self.Frame = 4;
					self.roundInserted = true;
				elseif self.reloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay/5)*2.2)) then
					self.Frame = 9;
				elseif self.reloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay/5)*1.9)) then
					self.Frame = 8;
				elseif self.reloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay/5)*1.6)) then
					self.Frame = 7;
				elseif self.reloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay/5)*1.3)) then
					self.Frame = 6;
				elseif self.reloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay/5)*1)) then
					self.Frame = 5;
				end
			
			elseif self.reloadPhase == 4 then
			
				if self.reloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay/5)*1.6)) then
					self.Frame = 0;
					self.tubeClosed = true;
				elseif self.reloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay/5)*1.4)) then
					self.Frame = 1;
				elseif self.reloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay/5)*1.2)) then
					self.Frame = 2;
				elseif self.reloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay/5)*1)) then
					self.Frame = 3;
				end
			
			elseif self.reloadPhase == 5 then
			
				if self.reloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay/5)*2)) then
					self.reloadingVector = Vector(0, 0);
				elseif self.reloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay/5)*1.5)) then
					self.reloadingVector = Vector(3, 3);
				elseif self.reloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay/5)*1)) then
					self.reloadingVector = Vector(8, 7);
				end			
			
				self.rotationTarget = -5;

			end
			
			if self.afterSoundPlayed ~= true then
			
				if self.reloadPhase == 2 then
					
				elseif self.reloadPhase == 4 then

				else
					--self.phaseOnStop = nil;
				end
			
				self.afterSoundPlayed = true;
				if self.afterSoundPath then
					self.afterSound = AudioMan:PlaySound(self.afterSoundPath .. ".ogg", self.Pos, -1, 0, 130, 1, 250, false);
				end
			end
			if self.reloadTimer:IsPastSimMS(self.reloadDelay + self.afterDelay) then
				self.reloadTimer:Reset();
				self.prepareSoundPlayed = false;
				self.afterSoundPlayed = false;
				if self.reloadPhase == 0 then
					if self.tubeClosed then
						self.reloadPhase = 5;
					elseif self.roundInserted then
						self.reloadPhase = 4;
					elseif self.roundRemoved then
						self.reloadPhase = 3;
					elseif self.tubeOpened then
						self.reloadPhase = 2;
					else
						self.reloadPhase = 1;
					end
				elseif self.reloadPhase == 5 then
					self.tubeOpened = false;
					self.roundRemoved = false;
					self.roundInserted = false;
					self.tubeClosed = false;
					self.ReloadTime = 0;
					self.reloadPhase = 0;
					self.phaseOnStop = nil;
					self.reloadingVector = nil;
				else
					self.reloadPhase = self.reloadPhase + 1;
				end
			end
		else
			self.phasePrepareFinished = false;
		end
	else
		self.reloadingVector = nil;
		self.rotationTarget = 0
		
		self.reloadTimer:Reset();
		self.prepareSoundPlayed = false;
		self.afterSoundPlayed = false;
		if self.phaseOnStop then
			self.reloadPhase = self.phaseOnStop;
			self.phaseOnStop = nil;
		end
		if self.tubeClosed then
			self.Frame = 0;
		elseif self.tubeOpened then
			self.Frame = 4;
		else
			self.Frame = 0;
		end
		self.ReloadTime = 9999;
	end
	
	if self.FiredFrame then	
		self.canSmoke = true
		self.smokeTimer:Reset()
		
		self.horizontalAnim = self.horizontalAnim + 0.2
		self.angVel = self.angVel - RangeRand(0,1) * 6
		
		if self.Magazine then
			if self.Magazine.RoundCount > 0 then			
			else
				self.chamberOnReload = true;
			end
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
		
		-- Back Blast
		local effectNames = {"Small Smoke Ball 1", "Tiny Smoke Ball 1", "Blast Ball Small 1", "Tracer Smoke Ball 1"}
		for i = 1, 23 do
		
			local effect = CreateMOSParticle(effectNames[math.random(1, #effectNames)])
			effect.Pos = self.Pos + Vector(-13 * self.FlipFactor, -1):RadRotate(self.RotAngle) + Vector(RangeRand(-1,1), RangeRand(-1,1));
			effect.Vel = self.Vel + Vector(-30 * self.FlipFactor,0):RadRotate(self.RotAngle + RangeRand(-1,1) * 0.15 * math.random(1,3)) * RangeRand(0.1,1.5) * math.random(1,3)
			effect.Lifetime = effect.Lifetime * RangeRand(1.0,3.0)
			effect.AirResistance = effect.AirResistance * RangeRand(0.5,0.8)
			MovableMan:AddParticle(effect)
		end
		
		-- Ground Smoke
		local maxi = 70
		for i = 1, maxi do
			
			local effect = CreateMOSRotating("Ground Smoke Particle 1", "Sandstorm.rte")
			effect.Pos = self.Pos + Vector(RangeRand(-1,1), RangeRand(-1,1)) * 3
			effect.Vel = self.Vel + Vector(math.random(90,150),0):RadRotate(math.pi * 2 / maxi * i + RangeRand(-2,2) / maxi)
			effect.Lifetime = effect.Lifetime * RangeRand(0.5,2.0)
			effect.AirResistance = effect.AirResistance * RangeRand(0.5,0.8)
			MovableMan:AddParticle(effect)
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
	
	if not self:IsActivated() then
		self.firstShot = true;
	end	
	
	-- Animation
	if self.parent then
		self.horizontalAnim = math.floor(self.horizontalAnim / (1 + TimerMan.DeltaTimeSecs * 12.0) * 1000) / 1000
		self.verticalAnim = math.floor(self.verticalAnim / (1 + TimerMan.DeltaTimeSecs * 8.0) * 1000) / 1000
		
		local stance = Vector()
		stance = stance + Vector(-5,0) * self.horizontalAnim -- Horizontal animation
		stance = stance + Vector(0,6) * self.verticalAnim -- Vertical animation
		
		self.rotationTarget = self.rotationTarget - (self.angVel * 4)
		self.rotation = (self.rotation + self.rotationTarget * TimerMan.DeltaTimeSecs * self.rotationSpeed) / (1 + TimerMan.DeltaTimeSecs * self.rotationSpeed)
		local total = math.rad(self.rotation) * self.FlipFactor
		
		self.RotAngle = self.RotAngle + total;
		self:SetNumberValue("MagRotation", total);
		
		local jointOffset = Vector(self.JointOffset.X * self.FlipFactor, self.JointOffset.Y):RadRotate(self.RotAngle);
		local offsetTotal = Vector(jointOffset.X, jointOffset.Y):RadRotate(-total) - jointOffset
		self.Pos = self.Pos + offsetTotal;
		self:SetNumberValue("MagOffsetX", offsetTotal.X);
		self:SetNumberValue("MagOffsetY", offsetTotal.Y);
		
		if self.reloadingVector then
			self.StanceOffset = self.reloadingVector + stance
			self.SharpStanceOffset = self.reloadingVector + stance
		else
			self.StanceOffset = Vector(self.originalStanceOffset.X, self.originalStanceOffset.Y) + stance
			self.SharpStanceOffset = Vector(self.originalSharpStanceOffset.X, self.originalSharpStanceOffset.Y) + stance
		end
		
		-- Dirty Fix
		if self.reloadPhase == 2 then
			
			if self.reloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay/5)*2.5)) then
				self.Frame = 4;
				
				if not self.roundRemoved then
					self.roundRemoved = true;
					local fake
					fake = CreateMOSRotating("Casing M3MAAWS");
					fake.Pos = self.Pos + Vector(-9*self.FlipFactor, 2):RadRotate(self.RotAngle);
					fake.Vel = self.Vel + Vector(-4*self.FlipFactor, 0):RadRotate(self.RotAngle);
					fake.RotAngle = self.RotAngle;
					--fake.AngularVel = self.AngularVel + (-1*self.FlipFactor);
					fake.HFlipped = self.HFlipped;
					MovableMan:AddParticle(fake);
					
				end
			end
			
		end
	end
	
	if self.canSmoke and not self.smokeTimer:IsPastSimMS(3000) then
		--[[
		local poof = CreateMOPixel("Real Bullet Micro Smoke Ball "..math.random(1,4), "Sandstorm.rte");
		poof.Pos = self.Pos + Vector(self.MuzzleOffset.X * self.FlipFactor, self.MuzzleOffset.Y):RadRotate(self.RotAngle) + Vector(RangeRand(-1,1), RangeRand(-1,1));
		poof.Lifetime = poof.Lifetime * RangeRand(0.2, 1.3) * 0.9;
		poof.Vel = self.Vel * 0.1
		poof.GlobalAccScalar = RangeRand(0.9, 1.0) * -0.4; -- Go up and down
		MovableMan:AddParticle(poof);
		]]
		if self.smokeDelayTimer:IsPastSimMS(80) then
			
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