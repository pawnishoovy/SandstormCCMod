function Create(self)

	self.parentSet = false;

	-- Sounds --
	self.addSounds = {["Start"] = nil, ["Loop"] = nil};
	self.addSounds.Start = {["Variations"] = 4,
	["Path"] = "SandstormSecurity.rte/Devices/Weapons/Handheld/M249/CompliSoundV2/AddStart"};
	self.addSounds.Loop = {["Variations"] = 15,
	["Path"] = "SandstormSecurity.rte/Devices/Weapons/Handheld/M249/CompliSoundV2/Add"};
	
	self.bassSounds = {["Loop"] = nil};
	self.bassSounds.Loop = {["Variations"] = 15,
	["Path"] = "SandstormSecurity.rte/Devices/Weapons/Handheld/M249/CompliSoundV2/Bass"};
	
	self.mechSounds = {["Loop"] = nil, ["End"] = nil};
	self.mechSounds.Loop = {["Variations"] = 14,
	["Path"] = "SandstormSecurity.rte/Devices/Weapons/Handheld/M249/CompliSoundV2/Mech"};
	self.mechSounds.End = {["Variations"] = 4,
	["Path"] = "SandstormSecurity.rte/Devices/Weapons/Handheld/M249/CompliSoundV2/MechEnd"};
	
	self.noiseSounds = {["Outdoors"] = {["Loop"] = nil, ["End"] = nil},
	["Indoors"] = {["Loop"] = nil, ["End"] = nil},
	["bigIndoors"] = {["Loop"] = nil, ["End"] = nil}};
	self.noiseSounds.Outdoors.Loop = {["Variations"] = 13,
	["Path"] = "SandstormSecurity.rte/Devices/Weapons/Handheld/M249/CompliSoundV2/NoiseOutdoors"};
	self.noiseSounds.Outdoors.End = {["Variations"] = 4,
	["Path"] = "SandstormSecurity.rte/Devices/Weapons/Handheld/M249/CompliSoundV2/NoiseOutdoorsEnd"};
	self.noiseSounds.Indoors.Loop = {["Variations"] = 5,
	["Path"] = "SandstormSecurity.rte/Devices/Weapons/Handheld/M249/CompliSoundV2/NoiseIndoors"};
	self.noiseSounds.Indoors.End = {["Variations"] = 4,
	["Path"] = "SandstormSecurity.rte/Devices/Weapons/Handheld/M249/CompliSoundV2/NoiseIndoorsEnd"};
	self.noiseSounds.bigIndoors.Loop = {["Variations"] = 5,
	["Path"] = "SandstormSecurity.rte/Devices/Weapons/Handheld/M249/CompliSoundV2/NoiseBigIndoors"};
	self.noiseSounds.bigIndoors.End = {["Variations"] = 4,
	["Path"] = "SandstormSecurity.rte/Devices/Weapons/Handheld/M249/CompliSoundV2/NoiseBigIndoorsEnd"};
	
	self.reflectionSounds = {["Outdoors"] = nil};
	self.reflectionSounds.Outdoors = {["Variations"] = 3,
	["Path"] = "SandstormSecurity.rte/Devices/Weapons/Handheld/M249/CompliSoundV2/ReflectionOutdoors"};
	
	self.originalStanceOffset = Vector(math.abs(self.StanceOffset.X), self.StanceOffset.Y)
	self.originalSharpStanceOffset = Vector(math.abs(self.SharpStanceOffset.X), self.SharpStanceOffset.Y)
	
	self.rotation = 0
	self.rotationTarget = 0
	self.rotationSpeed = 5
	
	self.horizontalAnim = 0
	self.verticalAnim = 0
	
	self.MagFrame = 1
	
	self.angVel = 0
	self.lastRotAngle = self.RotAngle
	
	self.smokeTimer = Timer();
	self.smokeDelayTimer = Timer();
	self.canSmoke = false
	
	self.reloadTimer = Timer();
	
	self.boltBackPrepareDelay = 1000;
	self.boltBackAfterDelay = 100;
	self.boltForwardPrepareDelay = 200;
	self.boltForwardAfterDelay = 400;
	self.coverUpPrepareDelay = 1000;
	self.coverUpAfterDelay = 500;
	self.magOutPrepareDelay = 1000;
	self.magOutAfterDelay = 500;
	self.magInPrepareDelay = 1200;
	self.magInAfterDelay = 500;
	self.beltOnPrepareDelay = 400;
	self.beltOnAfterDelay = 500;
	self.coverDownPrepareDelay = 1000;
	self.coverDownAfterDelay = 500;
	self.shoulderPrepareDelay = 600;
	self.shoulderAfterDelay = 100;
	
	-- phases:
	-- 0 boltback
	-- 1 boltforward
	-- 2 magout
	-- 3 coverup
	-- 4 magin
	-- 5 belton
	-- 6 coverdown
	-- 7 shoulder
	
	self.reloadPhase = 0;
	
	self.ReloadTime = 19999;

	local actor = MovableMan:GetMOFromID(self.RootID);
	if actor and IsAHuman(actor) then
		self.parent = ToAHuman(actor);
	end
	
	self.originalSharpLength = self.SharpLength
	self.recoilTimer = Timer();
	self.recoilTimeMS = 30
	self.recoilAcc = 0 -- for sinous
	self.recoilStr = 0 -- for accumulator
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
	
	self.SharpLength = self.originalSharpLength * (0.9 + math.pow(math.min(self.recoilTimer.ElapsedSimTimeMS / (self.recoilTimeMS * 3), 1), 2.0) * 0.1)
	--PrimitiveMan:DrawTextPrimitive(self.Pos + Vector(-20, 20), "Angular Velocity = "..self.angVel, true, 0);
	--PrimitiveMan:DrawLinePrimitive(self.Pos, self.Pos + Vector(15 * self.FlipFactor,0):RadRotate(self.RotAngle),  13);
	--PrimitiveMan:DrawLinePrimitive(self.Pos, self.Pos + Vector(15 * self.FlipFactor,0):RadRotate(self.RotAngle + (self.angVel * 0.05)),  5);
	
	if self:IsReloading() then
		if self.parent then
			self.parent:GetController():SetState(Controller.AIM_SHARP,false);
		end
		
		if not self:NumberValueExists("MagRemoved") and self.parent:IsPlayerControlled() then
			local color = (self.reloadPhase < 4 and 105 or 120)
			local offset = Vector(0, 36)
			local position = self.parent.AboveHUDPos + offset
			
			local mini = 0
			local maxi = 4
			
			local lastVecA = Vector(0, 0)
			local lastVecB = Vector(0, 0)
			
			local bend = 0--math.rad(9)
			local step = 2
			local width = 3
			
			position = position + Vector(0, step * maxi * -0.5)
			for i = mini, maxi do
				
				local vecA = Vector(width, 0):RadRotate(bend * i) + Vector(0, step * i):RadRotate(bend * i)
				local vecB = Vector(-width, 0):RadRotate(bend * i) + Vector(0, step * i):RadRotate(bend * i)
				
				-- Jitter fix
				vecA = Vector(math.floor(vecA.X), math.floor(vecA.Y))
				vecB = Vector(math.floor(vecB.X), math.floor(vecB.Y))
				position = Vector(math.floor(position.X), math.floor(position.Y))
				
				if i ~= mini then
					PrimitiveMan:DrawLinePrimitive(position + vecA, position + lastVecA, color);
					PrimitiveMan:DrawLinePrimitive(position + vecB, position + lastVecB, color);
				end
				if i == mini or i == maxi then
					PrimitiveMan:DrawLinePrimitive(position + vecA, position + vecB, color);
				end
				
				lastVecA = Vector(vecA.X, vecA.Y)
				lastVecB = Vector(vecB.X, vecB.Y)
			end
		end
		
		if self.reloadPhase == 0 then
			self.reloadDelay = self.boltBackPrepareDelay;
			self.afterDelay = self.boltBackAfterDelay;
			
			self.prepareSoundPath = 
			"SandstormSecurity.rte/Devices/Weapons/Handheld/M249/Sounds/BoltBackPrepare";
			self.afterSoundPath = 
			"SandstormSecurity.rte/Devices/Weapons/Handheld/M249/Sounds/BoltBack";
			
			self.rotationTarget = 5
		elseif self.reloadPhase == 1 then
			self.Frame = 3;
			self.reloadDelay = self.boltForwardPrepareDelay;
			self.afterDelay = self.boltForwardAfterDelay;
			
			self.prepareSoundPath = nil;
			self.afterSoundPath = 
			"SandstormSecurity.rte/Devices/Weapons/Handheld/M249/Sounds/BoltForward";
			
			self.rotationTarget = -5
		elseif self.reloadPhase == 2 then
			self.reloadDelay = self.coverUpPrepareDelay;
			self.afterDelay = self.coverUpAfterDelay;
			
			self.prepareSoundPath = 
			"SandstormSecurity.rte/Devices/Weapons/Handheld/M249/Sounds/CoverOpenPrepare";
			self.afterSoundPath = 
			"SandstormSecurity.rte/Devices/Weapons/Handheld/M249/Sounds/CoverOpen";
			
			self.rotationTarget = 0
		elseif self.reloadPhase == 3 then
			self.reloadDelay = self.magOutPrepareDelay;
			self.afterDelay = self.magOutAfterDelay;
			
			self.prepareSoundPath = 
			"SandstormSecurity.rte/Devices/Weapons/Handheld/M249/Sounds/MagOutPrepare";
			self.afterSoundPath = 
			"SandstormSecurity.rte/Devices/Weapons/Handheld/M249/Sounds/MagOut";
			
			self.rotationTarget = -5
		elseif self.reloadPhase == 4 then
			self.MagFrame = 8;
			self.reloadDelay = self.magInPrepareDelay;
			self.afterDelay = self.magInAfterDelay;
			
			self.prepareSoundPath = "SandstormSecurity.rte/Devices/Weapons/Handheld/M249/Sounds/MagInPrepare";
			self.afterSoundPath = 
			"SandstormSecurity.rte/Devices/Weapons/Handheld/M249/Sounds/MagIn";
			
			self.rotationTarget = 5
		elseif self.reloadPhase == 5 then
			self.reloadDelay = self.beltOnPrepareDelay;
			self.afterDelay = self.beltOnAfterDelay;
			
			self.prepareSoundPath = "SandstormSecurity.rte/Devices/Weapons/Handheld/M249/Sounds/BeltOnPrepare";
			self.afterSoundPath = 
			"SandstormSecurity.rte/Devices/Weapons/Handheld/M249/Sounds/BeltOn";
			
			self.rotationTarget = -5
		elseif self.reloadPhase == 6 then
			self.reloadDelay = self.coverDownPrepareDelay;
			self.afterDelay = self.coverDownAfterDelay;
			
			self.prepareSoundPath = 
			"SandstormSecurity.rte/Devices/Weapons/Handheld/M249/Sounds/CoverClosePrepare";
			self.afterSoundPath = 
			"SandstormSecurity.rte/Devices/Weapons/Handheld/M249/Sounds/CoverClose";
			
			self.rotationTarget = 5
		elseif self.reloadPhase == 7 then
			self.reloadDelay = self.shoulderPrepareDelay;
			self.afterDelay = self.shoulderAfterDelay;
			
			self.prepareSoundPath = 
			"SandstormSecurity.rte/Devices/Weapons/Handheld/M249/Sounds/ShoulderPrepare";
			self.afterSoundPath = 
			"SandstormSecurity.rte/Devices/Weapons/Handheld/M249/Sounds/Shoulder";	
			
			self.rotationTarget = 0
		end
		
		if self.prepareSoundPlayed ~= true then
			self.prepareSoundPlayed = true;
			if self.prepareSoundPath then
				self.prepareSound = AudioMan:PlaySound(self.prepareSoundPath .. ".ogg", self.Pos, -1, 0, 130, 1, 250, false);
			end
		end
	
		if self.reloadTimer:IsPastSimMS(self.reloadDelay) then
		
			if self.reloadPhase == 0 then
			
				if self.reloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay/5)*2)) then
					self.Frame = 3;
				elseif self.reloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay/5)*1.5)) then
					self.Frame = 2;
				elseif self.reloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay/5)*1)) then
					self.Frame = 1;
				end			
				
			elseif self.reloadPhase == 1 then
			
				if self.reloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay/5)*2)) then
					self.Frame = 1;
				elseif self.reloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay/5)*1.5)) then
					self.Frame = 2;
				elseif self.reloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay/5)*1)) then
					self.Frame = 3;
				end		
			
			elseif self.reloadPhase == 2 then

				if self.reloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay/5)*2.5)) then
					self.Frame = 7;
				elseif self.reloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay/5)*2)) then
					self.Frame = 6;
				elseif self.reloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay/5)*1.5)) then
					self.Frame = 5;
				elseif self.reloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay/5)*1)) then
					self.Frame = 4;
				end

			elseif self.reloadPhase == 3 then
				
				self:SetNumberValue("MagRemoved", 1);
				self.reloadMagRemoved = true;
				
			elseif self.reloadPhase == 4 then
			
				self:RemoveNumberValue("MagRemoved");
				self.reloadMagPlaced = true;
				
			elseif self.reloadPhase == 5 then
			
				if self.reloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay/5)*2.5)) then
					self.MagFrame = 11;
				elseif self.reloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay/5)*2)) then
					self.MagFrame = 10;
				elseif self.reloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay/5)*1.5)) then
					self.MagFrame = 9;
				end

			elseif self.reloadPhase == 6 then
			
				if self.reloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay/5)*1.75)) then
					self.Frame = 1;
				elseif self.reloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay/5)*1.5)) then
					self.Frame = 4;
				elseif self.reloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay/5)*1.25)) then
					self.Frame = 5;
				elseif self.reloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay/5)*1)) then
					self.Frame = 6;
				end
				
			end
			
			if self.afterSoundPlayed ~= true then
				
				if self.reloadPhase == 1 then
					self.verticalAnim = self.verticalAnim + 1
				elseif self.reloadPhase == 2 then
					self.horizontalAnim = self.horizontalAnim - 1
				elseif self.reloadPhase == 3 then
					self.horizontalAnim = self.horizontalAnim + 1
				elseif self.reloadPhase == 4 then
					self.horizontalAnim = self.horizontalAnim - 1
				elseif self.reloadPhase == 6 then
					self.horizontalAnim = self.horizontalAnim + 1
				end
			
				if self.reloadPhase == 0 then
				
					self.phaseOnStop = 0;
					
				elseif self.reloadPhase == 2 then

					self.phaseOnStop = 2;			
			
				elseif self.reloadPhase == 3 then
					local fake
					-- TODO: add box mag mosrotating with a little belt sticking out for reloading when not empty
					fake = CreateMOSRotating("Fake Magazine MOSRotating M249");
					fake.Pos = self.Pos + Vector(0, 2):RadRotate(self.RotAngle);
					fake.Vel = self.Vel + Vector(0.5*self.FlipFactor, 3):RadRotate(self.RotAngle);
					fake.RotAngle = self.RotAngle;
					fake.AngularVel = self.AngularVel + (-1*self.FlipFactor);
					fake.HFlipped = self.HFlipped;
					MovableMan:AddParticle(fake);
					
				elseif self.reloadPhase == 6 then
					self.phaseOnStop = nil;
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
				if self.reloadPhase == 2 then
					self.reloadPhase = 3;
					if self.reloadMagRemoved then
						self.reloadPhase = 4;
					end
					if self.reloadMagPlaced then
						self.reloadPhase = 5;
					end
					if self.reloadBeltPlaced then
						self.reloadPhase = 6;
					end
				elseif self.reloadPhase == 5 then
					self.reloadBeltPlaced = true;
					self.reloadPhase = self.reloadPhase + 1;
				elseif self.reloadPhase == 7 then
					self.ReloadTime = 0;
					self.reloadPhase = 0;
					self.reloadMagRemoved = false;
					self.reloadMagPlaced = false;
					self.reloadBeltPlaced = false;
				else
					self.reloadPhase = self.reloadPhase + 1;
				end
			end
		end
	else
		
		self.Frame = 1;
		if self.reloadMagRemoved then
			self.MagFrame = self.reloadBeltPlaced and 11 or 8;
		end
		if self.reloadBeltPlaced then
			self.coverDownPrepareDelay = 200;
		else
			self.coverDownPrepareDelay = 1000;
		end
		self.reloadTimer:Reset();
		self.prepareSoundPlayed = false;
		self.afterSoundPlayed = false;
		if self.reloadPhase == 3 then
			self.reloadPhase = 2;
		end
		if self.phaseOnStop then
			self.reloadPhase = self.phaseOnStop;
			self.phaseOnStop = nil;
		end
		self.ReloadTime = 19999;
	end
	
	if self:DoneReloading() then
		self.chamberOnReload = false;
	end
	
	if self.FiredFrame then	
		self.canSmoke = true
		self.smokeTimer:Reset()
		self.recoilTimer:Reset()
		
		local postureMultiplier = (self.parent and self.parent:GetController():IsState(Controller.BODY_CROUCH) and 1.0 or 2.0)
		
		self.horizontalAnim = self.horizontalAnim + 0.3
		--self.recoilStr = self.recoilStr + 1.0
		self.recoilStr = self.recoilStr + math.random(1,1.5) * 0.5 * postureMultiplier
		self.angVel = self.angVel + RangeRand(-1,1) * 3 * postureMultiplier
		self.Frame = 1
		
		local chain
		chain = CreateMOSParticle("Belt Connection M249");
		chain.Pos = self.Pos+Vector(0,-3):RadRotate(self.RotAngle);
		chain.Vel = self.Vel+Vector(-math.random(2,4)*self.FlipFactor,-math.random(3,4)):RadRotate(self.RotAngle);
		MovableMan:AddParticle(chain);
		
		if self.Magazine then
			if self.Magazine.RoundCount <= 0 then
				self.reloadPhase = 0;
			else
				self.reloadPhase = 2;
				self.beltLeft = true;
			end
			
			if self.Magazine.RoundCount <= 1 then
				self.MagFrame = 8
			elseif self.Magazine.RoundCount < 2 then
				self.MagFrame = 7
			elseif self.Magazine.RoundCount < 3 then
				self.MagFrame = 6
			elseif self.Magazine.RoundCount < 4 then
				self.MagFrame = 5
			elseif self.Magazine.RoundCount < 5 then
				self.MagFrame = 4
			else
				self.MagFrame = (self.MagFrame % 3) + 1
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
		
		if self.mechEndSound then
			if self.mechEndSound:IsBeingPlayed() then
				self.mechEndSound:Stop(-1)
			end
		end
		
		--local Effect = CreateMOSParticle("Tiny Smoke Ball 1", "Base.rte")
		--Effect.Pos = self.MuzzlePos;
		--Effect.Vel = (self.Vel + Vector(RangeRand(-20,20), RangeRand(-20,20)) + Vector(150*self.FlipFactor,0):RadRotate(self.RotAngle)) / 30
		--MovableMan:AddParticle(Effect)

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
			self.noiseSound = AudioMan:PlaySound(self.noiseSounds.Outdoors.Loop.Path .. math.random(1, self.noiseSounds.Outdoors.Loop.Variations) .. ".ogg", self.Pos, -1, 0, 130, 1, 450, false);
			self.noiseEndSound = AudioMan:PlaySound(self.noiseSounds.Outdoors.End.Path .. math.random(1, self.noiseSounds.Outdoors.End.Variations) .. ".ogg", self.Pos, -1, 0, 130, 1, 450, false);
			self.reflectionSound = AudioMan:PlaySound(self.reflectionSounds.Outdoors.Path .. math.random(1, self.reflectionSounds.Outdoors.Variations) .. ".ogg", self.Pos, -1, 0, 130, 1, 450, false);
		elseif math.max(outdoorRays, bigIndoorRays, indoorRays) == indoorRays then
			self.noiseSound = AudioMan:PlaySound(self.noiseSounds.Indoors.Loop.Path .. math.random(1, self.noiseSounds.Indoors.Loop.Variations) .. ".ogg", self.Pos, -1, 0, 130, 1, 450, false);
			self.noiseEndSound = AudioMan:PlaySound(self.noiseSounds.Indoors.End.Path .. math.random(1, self.noiseSounds.Indoors.End.Variations) .. ".ogg", self.Pos, -1, 0, 130, 1, 450, false);
		else -- bigIndoor
			self.noiseSound = AudioMan:PlaySound(self.noiseSounds.bigIndoors.Loop.Path .. math.random(1, self.noiseSounds.bigIndoors.Loop.Variations) .. ".ogg", self.Pos, -1, 0, 130, 1, 450, false);
			self.noiseEndSound = AudioMan:PlaySound(self.noiseSounds.bigIndoors.End.Path .. math.random(1, self.noiseSounds.bigIndoors.End.Variations) .. ".ogg", self.Pos, -1, 0, 130, 1, 450, false);
		end

		self.mechSound = AudioMan:PlaySound(self.mechSounds.Loop.Path .. math.random(1, self.mechSounds.Loop.Variations) .. ".ogg", self.Pos, -1, 0, 130, 1, 450, false);
		
		if self.firstShot == true then
			self.firstShot = false;
			
			self.addSound = AudioMan:PlaySound(self.addSounds.Start.Path .. math.random(1, self.addSounds.Start.Variations) .. ".ogg", self.Pos, -1, 0, 130, 1, 450, false);
		else
			self.addSound = AudioMan:PlaySound(self.addSounds.Loop.Path .. math.random(1, self.addSounds.Loop.Variations) .. ".ogg", self.Pos, -1, 0, 130, 1, 450, false);
		end
		
		self.mechEndSound = AudioMan:PlaySound(self.mechSounds.End.Path .. math.random(1, self.mechSounds.End.Variations) .. ".ogg", self.Pos, -1, 0, 130, 1, 450, false);

	end
	
	if not self:IsActivated() then
		self.firstShot = true;
	end	
	
	-- Animation
	if self.parent then
		self.horizontalAnim = math.floor(self.horizontalAnim / (1 + TimerMan.DeltaTimeSecs * 12.0) * 1000) / 1000
		self.verticalAnim = math.floor(self.verticalAnim / (1 + TimerMan.DeltaTimeSecs * 8.0) * 1000) / 1000
		
		self.recoilStr = math.floor(self.recoilStr / (1 + TimerMan.DeltaTimeSecs * 8.0) * 1000) / 1000
		self.recoilAcc = (self.recoilAcc + self.recoilStr * TimerMan.DeltaTimeSecs) % (math.pi * 4)
		
		local stance = Vector()
		stance = stance + Vector(-5,0) * self.horizontalAnim -- Horizontal animation
		stance = stance + Vector(0,6) * self.verticalAnim -- Vertical animation
		
		self.rotationTarget = self.rotationTarget - (self.angVel * 6) -- aim sway/smoothing
		local recoilA = (math.sin(self.recoilAcc) * self.recoilStr) * 0.5
		local recoilB = (math.sin(self.recoilAcc * 0.5) * self.recoilStr) * 0.1
		self.rotationTarget = self.rotationTarget + recoilA + recoilB -- recoil
		
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
	end
	
	self:SetNumberValue("MagFrame", self.MagFrame);
	
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