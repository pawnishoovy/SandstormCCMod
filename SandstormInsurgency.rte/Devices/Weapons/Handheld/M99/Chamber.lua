function Create(self)

	self.parentSet = false;
	
	-- Sounds --
	self.preSounds = {["Variations"] = 1,
	["Path"] = "SandstormInsurgency.rte/Devices/Weapons/Handheld/M99/CompliSoundV2/Pre"};		
	
	self.addSounds = {["Loop"] = nil};
	self.addSounds.Loop = {["Variations"] = 4,
	["Path"] = "SandstormInsurgency.rte/Devices/Weapons/Handheld/M99/CompliSoundV2/Add"};
	
	self.bassSounds = {["Outdoors"] = {["Loop"] = nil},
	["Indoors"] = {["Loop"] = nil}};
	self.bassSounds.Outdoors.Loop = {["Variations"] = 1,
	["Path"] = "SandstormInsurgency.rte/Devices/Weapons/Handheld/M99/CompliSoundV2/Bass"};
	self.bassSounds.Indoors.Loop = {["Variations"] = 1,
	["Path"] = "SandstormInsurgency.rte/Devices/Weapons/Handheld/M99/CompliSoundV2/BassIndoors"};
	
	self.mechSounds = {["Loop"] = nil};
	self.mechSounds.Loop = {["Variations"] = 4,
	["Path"] = "SandstormInsurgency.rte/Devices/Weapons/Handheld/M99/CompliSoundV2/Mech"};
	
	self.noiseSounds = {["Outdoors"] = {["Loop"] = nil, ["End"] = nil},
	["Indoors"] = {["Loop"] = nil, ["End"] = nil},
	["bigIndoors"] = {["Loop"] = nil, ["End"] = nil}};
	self.noiseSounds.Outdoors.End = {["Variations"] = 4,
	["Path"] = "SandstormInsurgency.rte/Devices/Weapons/Handheld/M99/CompliSoundV2/NoiseOutdoorsEnd"};
	self.noiseSounds.Indoors.End = {["Variations"] = 5,
	["Path"] = "SandstormInsurgency.rte/Devices/Weapons/Handheld/M99/CompliSoundV2/NoiseIndoorsEnd"};
	self.noiseSounds.bigIndoors.End = {["Variations"] = 5,
	["Path"] = "SandstormInsurgency.rte/Devices/Weapons/Handheld/M99/CompliSoundV2/NoiseBigIndoorsEnd"};
	
	self.reflectionSounds = {["Outdoors"] = nil};
	self.reflectionSounds.Outdoors = {["Variations"] = 7,
	["Path"] = "SandstormInsurgency.rte/Devices/Weapons/Handheld/M99/CompliSoundV2/ReflectionOutdoors"};
	
	self.FireTimer = Timer();
	self:SetNumberValue("DelayedFireTimeMS", 35);
	
	self.lastAge = self.Age
	
	self.originalSharpLength = self.SharpLength
	
	self.originalJointOffset = Vector(self.JointOffset.X, self.JointOffset.Y)
	self.originalStanceOffset = Vector(math.abs(self.StanceOffset.X), self.StanceOffset.Y)
	self.originalSharpStanceOffset = Vector(self.SharpStanceOffset.X, self.SharpStanceOffset.Y)
	
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
	
	self.magOutPrepareDelay = 1300;
	self.magOutAfterDelay = 300;
	self.magInPrepareDelay = 1200;
	self.magInAfterDelay = 200;
	self.magHitPrepareDelay = 200;
	self.magHitAfterDelay = 300;
	self.boltBackPrepareDelay = 1200;
	self.boltBackAfterDelay = 200;
	self.boltForwardPrepareDelay = 350;
	self.boltForwardAfterDelay = 700;
	
	-- phases:
	-- 0 magout
	-- 1 magin
	-- 2 maghit
	-- 3 boltback
	-- 4 boltforward
	
	self.reloadPhase = 0;
	
	self.ReloadTime = 19999;

	-- F U N
	self.recoilTimer = Timer();
	self.recoilTimeMS = 60
end

function Update(self)
	self.rotationTarget = 0 -- ZERO IT FIRST AAAA!!!!!
	self.Frame = 0;
	
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
    
    if self.lastHFlipped ~= nil then
        if self.lastHFlipped ~= self.HFlipped then
            self.lastHFlipped = self.HFlipped
            self.angVel = 0
        end
    else
        self.lastHFlipped = self.HFlipped
    end
	
	local recoilFactor = math.pow(math.min(self.recoilTimer.ElapsedSimTimeMS / (self.recoilTimeMS * 4), 1), 2.0)
	self.SharpLength = self.originalSharpLength * (0.9 + recoilFactor * 0.1)
	self.rotationTarget = math.sin(recoilFactor * math.pi) * -10
	
	if self.FiredFrame then
		self.Frame = 2;
		self.angVel = self.angVel - RangeRand(0.7,1.1) * 10
		--self.rotationTarget = -10
		
		self.recoilTimer:Reset()
		
		self.canSmoke = true
		self.smokeTimer:Reset()
		
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
		
		if outdoorRays >= self.rayThreshold then
			self.bassSound = AudioMan:PlaySound(self.bassSounds.Outdoors.Loop.Path .. math.random(1, self.bassSounds.Outdoors.Loop.Variations) .. ".ogg", self.Pos, -1, 0, 130, 1, 450, false);
			self.noiseEndSound = AudioMan:PlaySound(self.noiseSounds.Outdoors.End.Path .. math.random(1, self.noiseSounds.Outdoors.End.Variations) .. ".ogg", self.Pos, -1, 0, 130, 1, 450, false);
			self.reflectionSound = AudioMan:PlaySound(self.reflectionSounds.Outdoors.Path .. math.random(1, self.reflectionSounds.Outdoors.Variations) .. ".ogg", self.Pos, -1, 0, 130, 1, 450, false);
		elseif math.max(outdoorRays, bigIndoorRays, indoorRays) == indoorRays then
			self.bassSound = AudioMan:PlaySound(self.bassSounds.Indoors.Loop.Path .. math.random(1, self.bassSounds.Indoors.Loop.Variations) .. ".ogg", self.Pos, -1, 0, 130, 1, 450, false);
			self.noiseEndSound = AudioMan:PlaySound(self.noiseSounds.Indoors.End.Path .. math.random(1, self.noiseSounds.Indoors.End.Variations) .. ".ogg", self.Pos, -1, 0, 130, 1, 450, false);
		else -- bigIndoor
			self.bassSound = AudioMan:PlaySound(self.bassSounds.Indoors.Loop.Path .. math.random(1, self.bassSounds.Indoors.Loop.Variations) .. ".ogg", self.Pos, -1, 0, 130, 1, 450, false);
			self.noiseEndSound = AudioMan:PlaySound(self.noiseSounds.bigIndoors.End.Path .. math.random(1, self.noiseSounds.bigIndoors.End.Variations) .. ".ogg", self.Pos, -1, 0, 130, 1, 450, false);
		end

	
		self.addSound = AudioMan:PlaySound(self.addSounds.Loop.Path .. math.random(1, self.addSounds.Loop.Variations) .. ".ogg", self.Pos, -1, 0, 130, 1, 450, false);
	end
	
	-- PAWNIS RELOAD ANIMATION HERE
	if self:IsReloading() then
	
		if not self:NumberValueExists("MagRemoved") and self.parent:IsPlayerControlled() then
			local color = (self.reloadPhase == 0 and 105 or 120)
			local offset = Vector(0, 36)
			local position = self.parent.AboveHUDPos + offset
			
			local mini = 0
			local maxi = 4
			
			local lastVecA = Vector(0, 0)
			local lastVecB = Vector(0, 0)
			
			local bend = 0
			local step = 1.5
			local width = 4
			
			position = position + Vector(0, step * maxi * -0.5)
			for i = mini, maxi do
				
				local vecA = Vector(width, 0):RadRotate(bend * i) + Vector(0, step * i * 0.75):RadRotate(bend * i)
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
	
		if self.parent then
			self.parent:GetController():SetState(Controller.AIM_SHARP,false);
		end

		if self.reloadPhase == 0 then
			self.reloadDelay = self.magOutPrepareDelay;
			self.afterDelay = self.magOutAfterDelay;			
			self.prepareSoundPath = 
			"SandstormInsurgency.rte/Devices/Weapons/Handheld/M99/Sounds/MagOutPrepare";
			self.afterSoundPath = 
			"SandstormInsurgency.rte/Devices/Weapons/Handheld/M99/Sounds/MagOut";
			
			self.rotationTarget = 15;
			
		elseif self.reloadPhase == 1 then
			self.reloadDelay = self.magInPrepareDelay;
			self.afterDelay = self.magInAfterDelay;
			self.prepareSoundPath = 
			"SandstormInsurgency.rte/Devices/Weapons/Handheld/M99/Sounds/MagInPrepare";
			self.afterSoundPath = 
			"SandstormInsurgency.rte/Devices/Weapons/Handheld/M99/Sounds/MagIn";
			
			self.rotationTarget = 15;
			
		elseif self.reloadPhase == 2 then
			self.reloadDelay = self.magHitPrepareDelay;
			self.afterDelay = self.magHitAfterDelay;
			self.prepareSoundPath = nil;
			self.afterSoundPath = 
			"SandstormInsurgency.rte/Devices/Weapons/Handheld/M99/Sounds/MagHit";
			
			self.rotationTarget = 15;
			
		elseif self.reloadPhase == 3 then
			self.Frame = 0;
			self.reloadDelay = self.boltBackPrepareDelay;
			self.afterDelay = self.boltBackAfterDelay;
			self.prepareSoundPath = 
			"SandstormInsurgency.rte/Devices/Weapons/Handheld/M99/Sounds/BoltBackPrepare";
			self.afterSoundPath = 
			"SandstormInsurgency.rte/Devices/Weapons/Handheld/M99/Sounds/BoltBack";	

			self.rotationTarget = 7;
		
		elseif self.reloadPhase == 4 then
			self.Frame = 2;
			self.reloadDelay = self.boltForwardPrepareDelay;
			self.afterDelay = self.boltForwardAfterDelay;
			self.prepareSoundPath = nil;
			self.afterSoundPath = 
			"SandstormInsurgency.rte/Devices/Weapons/Handheld/M99/Sounds/BoltForward";
			
			self.rotationTarget = 7;
			
		end
		
		if self.prepareSoundPlayed ~= true then
			self.prepareSoundPlayed = true;
			if self.prepareSoundPath then
				self.prepareSound = AudioMan:PlaySound(self.prepareSoundPath .. ".ogg", self.Pos, -1, 0, 130, 1, 250, false);
			end
		end
	
		if self.reloadTimer:IsPastSimMS(self.reloadDelay) then
		
			if self.reloadPhase == 0 then
				self:SetNumberValue("MagRemoved", 1);
			elseif self.reloadPhase == 1 then
				self:RemoveNumberValue("MagRemoved");
			elseif self.reloadPhase == 3 then
				if self.reloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay/5)*1.5)) then
					self.Frame = 2;
				elseif self.reloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay/5)*1)) then
					self.Frame = 1;
				end
			elseif self.reloadPhase == 4 then
				if self.reloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay/5)*1.5)) then
					self.Frame = 0;
				elseif self.reloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay/5)*1)) then
					self.Frame = 1;
				end
			end
			
			if self.afterSoundPlayed ~= true then
				
				if self.reloadPhase == 3 then
					self.horizontalAnim = self.horizontalAnim - 3
				end
			
				if self.reloadPhase == 0 then
					self.phaseOnStop = 1;
					local fake
					fake = CreateMOSRotating("Fake Magazine MOSRotating M99");
					fake.Pos = self.Pos + Vector(-3 * self.FlipFactor, 3):RadRotate(self.RotAngle);
					fake.Vel = self.Vel + Vector(0.5*self.FlipFactor, 3):RadRotate(self.RotAngle);
					fake.RotAngle = self.RotAngle;
					fake.AngularVel = self.AngularVel + (-1*self.FlipFactor);
					fake.HFlipped = self.HFlipped;
					MovableMan:AddParticle(fake);
					
				elseif self.reloadPhase == 1 then
					if self.chamberOnReload then
						self.phaseOnStop = 3;
					else
						self.phaseOnStop = 2;
					end
					self:RemoveNumberValue("MagRemoved");
				elseif self.reloadPhase == 2 then
					self.angVel = self.angVel - 5;
					self.phaseOnStop = 3;
				elseif self.reloadPhase == 3 then
					self.phaseOnStop = 3;
				else
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
				if self.chamberOnReload and self.reloadPhase == 2 then
					self.reloadPhase = self.reloadPhase + 1;
				elseif self.reloadPhase == 2 or self.reloadPhase == 4 then
					self.ReloadTime = 0;
					self.reloadPhase = 0;
					self.phaseOnStop = nil;
				else
					self.reloadPhase = self.reloadPhase + 1;
				end
			end
		end		
	else
		local f = math.max(1 - math.min((self.recoilTimer.ElapsedSimTimeMS - self.recoilTimeMS) / 300, 1), 0)
		self.JointOffset = self.originalJointOffset + Vector(2, 0) * f
		
		self.reloadTimer:Reset();
		self.prepareSoundPlayed = false;
		self.afterSoundPlayed = false;
		if self.reloadPhase == 4 then
			self.reloadPhase = 3;
		end
		if self.phaseOnStop then
			self.reloadPhase = self.phaseOnStop;
			self.phaseOnStop = nil;
		end
		self.ReloadTime = 19999;
	end
	
	if self:DoneReloading() == true and self.chamberOnReload then
		self.Magazine.RoundCount = 5;
		self.chamberOnReload = false;
	elseif self:DoneReloading() then
		self.Magazine.RoundCount = 6;
		self.chamberOnReload = false;
	end	
	-- PAWNIS RELOAD ANIMATION HERE
	
	-- Animation
	if self.parent then
		self.horizontalAnim = math.floor(self.horizontalAnim / (1 + TimerMan.DeltaTimeSecs * 24.0) * 1000) / 1000
		self.verticalAnim = math.floor(self.verticalAnim / (1 + TimerMan.DeltaTimeSecs * 15.0) * 1000) / 1000
		
		local stance = Vector()
		stance = stance + Vector(-1,0) * self.horizontalAnim -- Horizontal animation
		stance = stance + Vector(0,5) * self.verticalAnim -- Vertical animation
		
		self.rotationTarget = self.rotationTarget - (self.angVel * 9)
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