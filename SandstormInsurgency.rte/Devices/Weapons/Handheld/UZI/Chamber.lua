function Create(self)

	self.parentSet = false;
	
	self.Frame = 2;

	-- Sounds --
	
	self.sharpAimSounds = {["In"] = nil, ["Out"] = nil};
	self.sharpAimSounds.In = CreateSoundContainer("SharpAimIn UZI", "SandstormInsurgency.rte");
	self.sharpAimSounds.Out = CreateSoundContainer("SharpAimOut UZI", "SandstormInsurgency.rte");	
	
	self.preSound = CreateSoundContainer("Pre UZI", "SandstormInsurgency.rte");
	self.boltDropSound = CreateSoundContainer("BoltDrop UZI", "SandstormInsurgency.rte");
	
	self.addSounds = {["Start"] = nil, ["Loop"] = nil};
	self.addSounds.Start = CreateSoundContainer("AddStart UZI", "SandstormInsurgency.rte");
	self.addSounds.Loop = CreateSoundContainer("Add UZI", "SandstormInsurgency.rte");
	
	self.bassSounds = {["Start"] = nil, ["Loop"] = nil};
	self.bassSounds.Start = CreateSoundContainer("BassStart UZI", "SandstormInsurgency.rte");
	self.bassSounds.Loop = CreateSoundContainer("Bass UZI", "SandstormInsurgency.rte");
	
	self.mechSounds = {["Start"] = nil, ["Loop"] = nil, ["End"] = nil};
	self.mechSounds.Start = CreateSoundContainer("MechStart UZI", "SandstormInsurgency.rte");
	self.mechSounds.Loop = CreateSoundContainer("Mech UZI", "SandstormInsurgency.rte");
	self.mechSounds.End = CreateSoundContainer("MechEnd UZI", "SandstormInsurgency.rte");
	
	self.noiseSounds = {["Outdoors"] = {["Loop"] = nil, ["End"] = nil},
	["Indoors"] = {["Loop"] = nil, ["End"] = nil},
	["bigIndoors"] = {["Loop"] = nil, ["End"] = nil}};
	self.noiseSounds.Outdoors.Loop = CreateSoundContainer("Noise Outdoors", "Sandstorm.rte");
	self.noiseSounds.Outdoors.Loop.Pitch = 1.2;
	self.noiseSounds.Outdoors.End = CreateSoundContainer("Noise OutdoorsEnd", "Sandstorm.rte");
	self.noiseSounds.Outdoors.End.Pitch = 1.2;
	self.noiseSounds.Indoors.Loop = CreateSoundContainer("Noise Indoors", "Sandstorm.rte");
	self.noiseSounds.Indoors.Loop.Pitch = 1.2;
	self.noiseSounds.Indoors.End = CreateSoundContainer("Noise IndoorsEnd", "Sandstorm.rte");
	self.noiseSounds.Indoors.End.Pitch = 1.2;
	self.noiseSounds.bigIndoors.Loop = CreateSoundContainer("Noise BigIndoors", "Sandstorm.rte");
	self.noiseSounds.bigIndoors.Loop.Pitch = 1.2;
	self.noiseSounds.bigIndoors.End = CreateSoundContainer("Noise BigIndoorsEnd", "Sandstorm.rte");
	self.noiseSounds.bigIndoors.End.Pitch = 1.2;
	
	self.reflectionSounds = {["Outdoors"] = nil};
	self.reflectionSounds.Outdoors = CreateSoundContainer("Noise ReflectionOutdoors", "Sandstorm.rte");
	self.reflectionSounds.Outdoors.Pitch = 1.2
	
	self.reloadPrepareSounds = {["MagOut"] = nil, ["MagIn"] = nil, ["BoltBack"] = nil, ["BoltForward"] = nil}
	self.reloadPrepareSounds.MagOut = CreateSoundContainer("MagOutPrepare UZI", "SandstormInsurgency.rte");
	self.reloadPrepareSounds.MagIn = CreateSoundContainer("MagInPrepare UZI", "SandstormInsurgency.rte");
	self.reloadPrepareSounds.BoltBack = CreateSoundContainer("BoltBackPrepare UZI", "SandstormInsurgency.rte");
	
	self.reloadPrepareLengths = {["MagOut"] = nil, ["MagIn"] = nil, ["BoltBack"] = nil, ["BoltForward"] = nil}
	self.reloadPrepareLengths.MagOut = 500;
	self.reloadPrepareLengths.MagIn = 100;
	self.reloadPrepareLengths.BoltBack = 120;
	
	self.reloadAfterSounds = {["MagOut"] = nil, ["MagIn"] = nil, ["BoltBack"] = nil, ["BoltForward"] = nil}
	self.reloadAfterSounds.MagOut = CreateSoundContainer("MagOut UZI", "SandstormInsurgency.rte");
	self.reloadAfterSounds.MagIn = CreateSoundContainer("MagIn UZI", "SandstormInsurgency.rte");
	self.reloadAfterSounds.BoltBack = CreateSoundContainer("BoltBack UZI", "SandstormInsurgency.rte");
	self.reloadAfterSounds.BoltForward = CreateSoundContainer("BoltForward UZI", "SandstormInsurgency.rte");

	self.originalStanceOffset = Vector(math.abs(self.StanceOffset.X), self.StanceOffset.Y)
	self.originalSharpStanceOffset = Vector(self.SharpStanceOffset.X, self.SharpStanceOffset.Y)
	
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
	
	self.fireTime = 1 / (self.RateOfFire / 60) * 1000
	
	self.ROFNum = self.fireTime * 0.65
	self.ROFNum2 = self.fireTime * 0.10
	self.boltDelay = 20
	
	self.boltDelayNum = self.boltDelay
	
	self.delayedFiring = false
	self.delayedFireTimer = Timer()
	self.delayedFireDelay = self.boltDelay
	self.triggerPulled = false
	
	self.boltAnimTimer = Timer()
	self.miscTimer = Timer() -- i know, not descriptive :(
	
	self.reloadTimer = Timer();
	
	self.magOutPrepareDelay = 500;
	self.magOutAfterDelay = 100;
	self.magInPrepareDelay = 950;
	self.magInAfterDelay = 500;
	self.boltBackPrepareDelay = 550;
	self.boltBackAfterDelay = 250;
	self.boltForwardPrepareDelay = 100;
	self.boltForwardAfterDelay = 500;
	
	-- phases:
	-- 0 magout
	-- 1 magin
	-- 2 boltback
	-- 3 boltforward
	
	self.reloadPhase = 0;
	
	self.ReloadTime = 9999;

	local actor = MovableMan:GetMOFromID(self.RootID);
	if actor and IsAHuman(actor) then
		self.parent = ToAHuman(actor);
	end
	
	-- Progressive Recoil System 
	self.recoilAcc = 0 -- for sinous
	self.recoilStr = 0 -- for accumulator
	self.recoilStrength = 5 -- multiplier for base recoil added to the self.recoilStr when firing
	self.recoilPowStrength = 0.5 -- multiplier for self.recoilStr when firing
	self.recoilRandomUpper = 1.8 -- upper end of random multiplier (1 is lower)
	self.recoilDamping = 1.0
	
	self.recoilMax = 20 -- in deg.
	self.originalSharpLength = self.SharpLength
	-- Progressive Recoil System 
	
	self.delayedFiring = false;
	self.delayedFireTimer = Timer();
	self.delayedFireDelay = 25;
	self.triggerPulled = false;
	
	self.boltAnimTimer = Timer();
	
end

function Update(self)

	if self.boltFire then
		self:Activate();
		self.firingAnim = true;
	end

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
	--PrimitiveMan:DrawTextPrimitive(self.Pos + Vector(-20, 20), "Angular Velocity = "..self.angVel, true, 0);
	--PrimitiveMan:DrawLinePrimitive(self.Pos, self.Pos + Vector(15 * self.FlipFactor,0):RadRotate(self.RotAngle),  13);
	--PrimitiveMan:DrawLinePrimitive(self.Pos, self.Pos + Vector(15 * self.FlipFactor,0):RadRotate(self.RotAngle + (self.angVel * 0.05)),  5);
	
	if (not self.backFrame) and (not self.delayedFiring) and (not self.firingAnim) and (not self:IsReloading()) then
		if self.boltFire == true then
			self.firingAnim = true
		else
			self.Frame = 2
		end
	end
	
	if self:IsReloading() then
	
		if self.boltFire then
			self.boltFire = false;
			if self.boltDropSound then
				self.boltDropSound:Play(self.Pos);
			end
			self.chamberOnReload = true;
		end
		
		if (not self.chamberOnReload) and (not self.boltFirstShot) and (not self.boltFire) and activated and self.miscTimer:IsPastSimMS(self.ROFNum) then
			self.firingAnim = true;
			self.boltAnimTimer:Reset();
			self.boltFire = true;
		end
		
		if self.chamberOnReload and (not self.firingAnim) then
			self.Frame = 0;
		end
		
		if self.parent then
			self.parent:GetController():SetState(Controller.AIM_SHARP,false);
			if not self:NumberValueExists("MagRemoved") and self.parent:IsPlayerControlled() then
				local color = (self.reloadPhase == 0 and 105 or 120)
				local offset = Vector(0, 36)
				local position = self.parent.AboveHUDPos + offset
				
				local mini = 0
				local maxi = 4
				
				local lastVecA = Vector(0, 0)
				local lastVecB = Vector(0, 0)
				
				local bend = math.rad(9)
				local step = 2.5
				local width = 2
				
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
		end
	
		if self.reloadPhase == 0 then
			self.reloadDelay = self.magOutPrepareDelay;
			self.afterDelay = self.magOutAfterDelay;
			
			self.prepareSound = self.reloadPrepareSounds.MagOut;
			self.prepareSoundLength = self.reloadPrepareLengths.MagOut;
			self.afterSound = self.reloadAfterSounds.MagOut;
			
			self.rotationTarget = -5 * self.reloadTimer.ElapsedSimTimeMS / (self.reloadDelay + self.afterDelay)
			
		elseif self.reloadPhase == 1 then
			self.reloadDelay = self.magInPrepareDelay;
			self.afterDelay = self.magInAfterDelay;

			self.prepareSound = self.reloadPrepareSounds.MagIn;
			self.prepareSoundLength = self.reloadPrepareLengths.MagIn;
			self.afterSound = self.reloadAfterSounds.MagIn;
			
			self.rotationTarget = 15-- * self.reloadTimer.ElapsedSimTimeMS / (self.reloadDelay + self.afterDelay)
			
		elseif self.reloadPhase == 2 then
			self.Frame = 0;
			self.reloadDelay = self.boltBackPrepareDelay;
			self.afterDelay = self.boltBackAfterDelay;

			self.prepareSound = self.reloadPrepareSounds.BoltBack;
			self.prepareSoundLength = self.reloadPrepareLengths.BoltBack;
			self.afterSound = self.reloadAfterSounds.BoltBack;
			
			self.rotationTarget = 15-- * self.reloadTimer.ElapsedSimTimeMS / (self.reloadDelay + self.afterDelay)
			
		elseif self.reloadPhase == 3 then
			self.Frame = 4;
			self.reloadDelay = self.boltForwardPrepareDelay;
			self.afterDelay = self.boltForwardAfterDelay;

			self.prepareSound = nil;
			self.prepareSoundLength = 0;
			self.afterSound = self.reloadAfterSounds.BoltForward;
			
			self.rotationTarget = 15-- * self.reloadTimer.ElapsedSimTimeMS / (self.reloadDelay + self.afterDelay)

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
		
			if self.reloadPhase == 0 then
				self:SetNumberValue("MagRemoved", 1);
			elseif self.reloadPhase == 1 then
				self:RemoveNumberValue("MagRemoved");
			elseif self.reloadPhase == 2 then
				if self.reloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay/5)*2)) then
					self.Frame = 4;
					self.rotationTarget = -5
				elseif self.reloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay/5)*1.5)) then
					self.Frame = 3;
					self.rotationTarget = -5
				elseif self.reloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay/5)*1)) then
					self.Frame = 0;
					self.rotationTarget = -5
				end
			elseif self.reloadPhase == 3 then
				if self.reloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay/5)*1)) then
					self.Frame = 2;
					self.rotationTarget = -5
				elseif self.reloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay/5)*0.5)) then
					self.Frame = 5;
					self.rotationTarget = -5
				end
			end
			
			if self.afterSoundPlayed ~= true then
			
				if self.reloadPhase == 0 then
					self.phaseOnStop = 1;
					local fake
					fake = CreateMOSRotating("Fake Magazine MOSRotating SandstormUZI");
					fake.Pos = self.Pos + Vector(-2.5*self.FlipFactor, 3):RadRotate(self.RotAngle);
					fake.Vel = self.Vel + Vector(0.5*self.FlipFactor, 3):RadRotate(self.RotAngle);
					fake.RotAngle = self.RotAngle;
					fake.AngularVel = self.AngularVel + (-1*self.FlipFactor);
					fake.HFlipped = self.HFlipped;
					fake:SetStringValue("MagazineType", "Small Metal");
					MovableMan:AddParticle(fake);
					
					self.verticalAnim = self.verticalAnim + 1
				elseif self.reloadPhase == 1 then
					if self.chamberOnReload then
						self.phaseOnStop = 2;
					end
					self:RemoveNumberValue("MagRemoved");
					
					self.verticalAnim = self.verticalAnim - 1
				elseif self.reloadPhase == 3 then
					self.phaseOnStop = 2;
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
				if self.chamberOnReload and self.reloadPhase == 1 then
					self.reloadPhase = self.reloadPhase + 1;
				elseif self.reloadPhase == 1 or self.reloadPhase == 3 then
					self.ReloadTime = 0;
					self.reloadPhase = 0;
					self.phaseOnStop = nil;
				else
					self.reloadPhase = self.reloadPhase + 1;
				end
			end
		end
	else
		if self.chamberOnReload then
			self.Frame = 0;
		elseif (not self.backFrame) and (not self.firingAnim) then
			self.Frame = 2;
		end	
		self.rotationTarget = 0
		self.reloadTimer:Reset();
		self.prepareSoundPlayed = false;
		self.afterSoundPlayed = false;
		if self.phaseOnStop then
			self.reloadPhase = self.phaseOnStop;
			self.phaseOnStop = nil;
		end
		self.ReloadTime = 9999;
	end
	
	if self:DoneReloading() == true then
		self.chamberOnReload = false
		self:Deactivate(); -- fix a few weirdnesses
	end
	
	local activated = self:IsActivated();
	
	if self.delayedFiring == true then
		if self.delayedFireTimer:IsPastSimMS(self.delayedFireDelay) then   
			self:Activate()
			self.delayedFiring = false
		else            
			self:Deactivate()
		end
	elseif self.Magazine and self.Magazine.RoundCount > 0 and activated and (not self:IsReloading()) and self.boltFirstShot == true then      
		if self.triggerPulled == false then        
			self:Deactivate()     
			self.delayedFiring = true       
			self.triggerPulled = true   
			self.delayedFireTimer:Reset()  
			self.firingAnim = true
			self.boltDelayNum = self.delayedFireDelay--self.boltDelay / self.boltSpeedShotFirst
			self.boltAnimTimer:Reset()
			self.preSound:Play(self.Pos)
		end
	else    
		self.triggerPulled = false;
	end
	
	if self.backFrame == true then
		self.firingAnim = false;
		local minTime = 0
		local maxTime = self.ROFNum2 * 5
		
		local factor = math.pow(math.min(math.max(self.boltAnimTimer.ElapsedSimTimeMS - minTime, 0) / maxTime, 1), 1)

		self.Frame = 0 + math.floor((factor) * 6 + 0.5)
		
		if self.Frame >= 2 then
			self.backFrame = false
			if activated then
				self.firingAnim = true
				self.boltFire = true
			end
			self.boltAnimTimer:Reset()
		end
	end
	
	if self.FiredFrame then
		self.canSmoke = true
		self.smokeTimer:Reset()
		
		self.horizontalAnim = self.horizontalAnim + 0.2
		self.angVel = self.angVel + RangeRand(0,1) * 3
		
		if self.parent then
			local controller = self.parent:GetController();	
			
			if controller:IsState(Controller.BODY_CROUCH) then
				self.recoilStrength = 5
				self.recoilPowStrength = 0.5
				self.recoilRandomUpper = 1.8
				self.recoilDamping = 1.1
				
				self.recoilMax = 20
			else
				self.recoilStrength = 5
				self.recoilPowStrength = 0.5
				self.recoilRandomUpper = 1.8
				self.recoilDamping = 1.0
				
				self.recoilMax = 20
			end
			if (not controller:IsState(Controller.AIM_SHARP))
			or (controller:IsState(Controller.MOVE_LEFT)
			or controller:IsState(Controller.MOVE_RIGHT)) then
				self.recoilDamping = self.recoilDamping * 0.9;
			end
		end
		
		self.boltDelayNum = self.fireTime * 0.6--self.boltDelay / self.boltSpeedShot
	
		self.Frame = 0;
		
		self.boltFire = false;
		self.miscTimer:Reset();
		self.boltAnimTimer:Reset();
		
		self.backFrame = true;
		
		--local Effect = CreateMOSParticle("Tiny Smoke Ball 1", "Base.rte")
		--Effect.Pos = self.MuzzlePos;
		--Effect.Vel = (self.Vel + Vector(RangeRand(-20,20), RangeRand(-20,20)) + Vector(150*self.FlipFactor,0):RadRotate(self.RotAngle)) / 30
		--MovableMan:AddParticle(Effect)

		local outdoorRays = 0;
		
		local indoorRays = 0;
		
		local bigIndoorRays = 0;

		if self.parent and self.parent:IsPlayerControlled() then
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
			self.noiseSounds.Outdoors.Loop:Play(self.Pos);
			self.noiseSounds.Outdoors.End:Play(self.Pos);
		elseif math.max(outdoorRays, bigIndoorRays, indoorRays) == indoorRays then
			self.noiseSounds.Indoors.Loop:Play(self.Pos);
			self.noiseSounds.Indoors.End:Play(self.Pos);
		else -- bigIndoor
			self.noiseSounds.bigIndoors.Loop:Play(self.Pos);
			self.noiseSounds.bigIndoors.End:Play(self.Pos);
		end

		
		if self.firstShot == true then
			self.firstShot = false;
			
			self.mechSounds.Start:Play(self.Pos);
			self.addSounds.Start:Play(self.Pos);
			self.bassSounds.Start:Play(self.Pos);
		else
			self.mechSounds.Loop:Play(self.Pos);
			self.addSounds.Loop:Play(self.Pos);
			self.bassSounds.Loop:Play(self.Pos);
		end

	end
	
	if self.toMechEnd == true and (not self:IsActivated()) then
		self.toMechEnd = false;
		self.mechSounds.End:Play(self.Pos);
	end

	if not activated and self.miscTimer:IsPastSimMS(100) then
		self.boltFirstShot = true;
		if self.toMechEnd == true then
			self.toMechEnd = false;
			self.mechSounds.End:Play(self.Pos);
		end
	elseif (not self.chamberOnReload) and (not self.boltFirstShot) and (not self.boltFire) and activated and self.miscTimer:IsPastSimMS(self.ROFNum) then
		self.boltFire = true;
		self.firingAnim = true;
		self.boltAnimTimer:Reset();
	else
		self.boltFirstShot = false;
	end
	
	if self.firingAnim == true and (not self.backFrame) then
		local minTime = 0
		local maxTime = self.boltDelayNum
		
		local factor = math.pow(math.min(math.max(self.boltAnimTimer.ElapsedSimTimeMS - minTime, 15) / maxTime, 1), 1)
		
		--PrimitiveMan:DrawLinePrimitive(parent.Pos + Vector(0, -25), parent.Pos + Vector(0, -25) + Vector(0, -25):RadRotate(math.pi * (factor - 0.5)), 122);
		
		--self.FrameLocal = self.FrameRange - math.floor((factor) * self.FrameRange + 0.5)
		self.Frame = 1 + math.floor((1 - factor) * 6 + 0.5)
		--self.FrameLocal = math.floor((1 - factor) * (self.FrameRange) + 0.5)
		
		if self.Frame == 1 then
			self.firingAnim = false
			self.boltAnimTimer:Reset()
		end
	end
	
	if not self.backFrame and not self.firingAnim then
		self.boltAnimTimer:Reset()
	end
	
	-- Animation
	if self.parent then
	
		self.horizontalAnim = math.floor(self.horizontalAnim / (1 + TimerMan.DeltaTimeSecs * 12.0) * 1000) / 1000
		self.verticalAnim = math.floor(self.verticalAnim / (1 + TimerMan.DeltaTimeSecs * 8.0) * 1000) / 1000
		
		local stance = Vector()
		stance = stance + Vector(-5,0) * self.horizontalAnim -- Horizontal animation
		stance = stance + Vector(0,6) * self.verticalAnim -- Vertical animation
		
		self.rotationTarget = self.rotationTarget + (self.angVel * 3)
		
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
		
		self.SharpLength = math.max(self.originalSharpLength - (self.recoilStr * 3 + math.abs(recoilFinal)), 0)
		
		self.rotationTarget = self.rotationTarget + recoilFinal -- apply the recoil
		-- Progressive Recoil Update
		
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
	-- -- DEBUG GIZMOS
	-- if self.parent and self.parent:IsPlayerControlled() then
		
		-- -- RECOIL DEBUG GRAPH
		-- -- graoh setup
		-- if not self.debugRecoilGraphIni then
			-- self.debugRecoilGraphIni = true
			-- self.debugRecoilGraphValues = {}
			-- self.debugRecoilGraphValuesMax = 200
			-- self.debugRecoilGraphMaximum = 1
		-- end
		-- self.debugRecoilGraphVar = self.recoilStr
		
		-- -- 6 --> F key
		-- --if not (UInputMan:KeyPressed(6)) then -- capture new data but only when freeze key IS NOT pressed
		-- table.insert(self.debugRecoilGraphValues, self.debugRecoilGraphVar)
		-- self.debugRecoilGraphMaximum = math.max(self.debugRecoilGraphMaximum, self.debugRecoilGraphVar)
		
		-- if #self.debugRecoilGraphValues > self.debugRecoilGraphValuesMax then
			-- table.remove(self.debugRecoilGraphValues, 1)
		-- end
		-- --end
		
		-- local pos = self.Pos + Vector(0,-120)
		-- local width = self.debugRecoilGraphValuesMax * 0.5
		-- local height = 50 * 0.5
		
		-- PrimitiveMan:DrawBoxFillPrimitive(pos +  Vector(-width, -height), pos +  Vector(width, height + 1), 240)
		
		-- -- GRAPH LINES
		-- local lastPixelPos = nil
		-- -- BG
		-- for i, value in ipairs(self.debugRecoilGraphValues) do
			-- local pixelPos = pos + Vector(-width + i, height - (value / self.debugRecoilGraphMaximum * height * 2.0))
			-- if lastPixelPos == nil then lastPixelPos = pixelPos end
			-- PrimitiveMan:DrawLinePrimitive(pixelPos + Vector(0,2), lastPixelPos + Vector(0,2), 245);
			
			-- lastPixelPos = pixelPos
		-- end
		
		-- lastPixelPos = nil
		-- -- FG
		-- for i, value in ipairs(self.debugRecoilGraphValues) do
			-- local pixelPos = pos + Vector(-width + i, height - (value / self.debugRecoilGraphMaximum * height * 2.0))
			-- if lastPixelPos == nil then lastPixelPos = pixelPos end
			-- PrimitiveMan:DrawLinePrimitive(pixelPos, lastPixelPos, 244);
			
			-- lastPixelPos = pixelPos
		-- end
		-- -- GRAPH LINES
		
		-- PrimitiveMan:DrawBoxFillPrimitive(pos +  Vector(-width, -height), pos +  Vector(width, -height - 7), 220)
		-- PrimitiveMan:DrawTextPrimitive(pos + Vector(-width, -height - 8), "Current value: "..tostring(math.floor(self.debugRecoilGraphVar * 1000) / 1000), true, 0)
		-- PrimitiveMan:DrawTextPrimitive(pos + Vector(-width + 110, -height - 8), "Max value: "..tostring(math.floor(self.debugRecoilGraphMaximum * 1000) / 1000), true, 0)
		
		-- PrimitiveMan:DrawTextPrimitive(pos + Vector(-width + 60, height + 7), "Recoil Debug Graph", true, 0)
		
		-- PrimitiveMan:DrawBoxPrimitive(pos +  Vector(-width - 1, -height - 8), pos + Vector(width + 1, -height), 96)
		
		-- PrimitiveMan:DrawBoxPrimitive(pos +  Vector(-width - 1, height + 2), pos + Vector(width + 1, -height - 8), 96)
		-- -- GRAPH END
		
		-- -- ROTATION DEBUG GIZMO
		-- pos = self.Pos + Vector(width + 30,-120)
		-- local radius = 24
		
		-- PrimitiveMan:DrawCircleFillPrimitive(pos, radius + 1, 96)
		-- PrimitiveMan:DrawCircleFillPrimitive(pos, radius, 240)
		
		-- PrimitiveMan:DrawCirclePrimitive(pos, 1, 244);
		
		-- PrimitiveMan:DrawLinePrimitive(pos, pos + Vector(radius, 0):DegRotate(self.recoilMax), 161);
		-- PrimitiveMan:DrawLinePrimitive(pos, pos + Vector(radius, 0):DegRotate(-self.recoilMax), 161);
		
		-- PrimitiveMan:DrawLinePrimitive(pos, pos + Vector(radius, 0):DegRotate(self.rotationTarget), 46);
		-- PrimitiveMan:DrawLinePrimitive(pos, pos + Vector(radius, 0):DegRotate(self.rotation), 244);
		-- -- ROTATION GIZMO END
	-- end
end