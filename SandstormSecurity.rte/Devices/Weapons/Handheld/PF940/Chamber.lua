function Create(self)

	self.parentSet = false;
	
	-- Sounds --
	
	self.sharpAimSounds = {["In"] = nil, ["Out"] = nil};
	self.sharpAimSounds.In = CreateSoundContainer("SharpAimIn PF940", "SandstormSecurity.rte");
	self.sharpAimSounds.Out = CreateSoundContainer("SharpAimOut PF940", "SandstormSecurity.rte");
	
	self.bassSounds = {["Start"] = nil, ["Loop"] = nil};
	self.bassSounds.Loop = CreateSoundContainer("Bass PF940", "SandstormSecurity.rte");
	
	self.addSounds = {["Start"] = nil, ["Loop"] = nil};
	self.addSounds.Loop = CreateSoundContainer("Add PF940", "SandstormSecurity.rte");
	
	self.mechSounds = {["Start"] = nil, ["Loop"] = nil};
	self.mechSounds.Loop = CreateSoundContainer("Mech PF940", "SandstormSecurity.rte");
	
	self.noiseSounds = {["Outdoors"] = {["Loop"] = nil, ["End"] = nil},
	["Indoors"] = {["Loop"] = nil, ["End"] = nil},
	["bigIndoors"] = {["Loop"] = nil, ["End"] = nil}};
	self.noiseSounds.Outdoors.End = CreateSoundContainer("NoiseOutdoorsEnd PF940", "SandstormSecurity.rte");
	self.noiseSounds.Outdoors.End.Pitch = 1.0;
	self.noiseSounds.Indoors.End = CreateSoundContainer("NoiseIndoorsEnd PF940", "SandstormSecurity.rte");
	self.noiseSounds.Indoors.End.Pitch = 1.0;
	self.noiseSounds.bigIndoors.End = CreateSoundContainer("NoiseBigIndoorsEnd PF940", "SandstormSecurity.rte");
	self.noiseSounds.bigIndoors.End.Pitch = 1.0;
	
	self.reloadPrepareSounds = {["MagOut"] = nil, ["MagIn"] = nil, ["BoltForward"] = nil}
	self.reloadPrepareSounds.MagOut = CreateSoundContainer("MagOutPrepare PF940", "SandstormSecurity.rte");
	self.reloadPrepareSounds.MagIn = CreateSoundContainer("MagInPrepare PF940", "SandstormSecurity.rte");
	
	self.reloadPrepareLengths = {["MagOut"] = nil, ["MagIn"] = nil, ["BoltForward"] = nil}
	self.reloadPrepareLengths.MagOut = 400;
	self.reloadPrepareLengths.MagIn = 490;
	
	self.reloadAfterSounds = {["MagOut"] = nil, ["MagIn"] = nil, ["BoltForward"] = nil}
	self.reloadAfterSounds.MagOut = CreateSoundContainer("MagOut PF940", "SandstormSecurity.rte");
	self.reloadAfterSounds.MagIn = CreateSoundContainer("MagIn PF940", "SandstormSecurity.rte");
	self.reloadAfterSounds.BoltForward = CreateSoundContainer("BoltForward PF940", "SandstormSecurity.rte");
	
	self.FireTimer = Timer();
	
	self.originalSharpLength = self.SharpLength
	
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
	
	self.magOutPrepareDelay = 400;
	self.magOutAfterDelay = 300;
	self.magInPrepareDelay = 500;
	self.magInAfterDelay = 200;
	self.boltForwardPrepareDelay = 350;
	self.boltForwardAfterDelay = 400;
	
	-- phases:
	-- 0 magout
	-- 1 magin
	-- 2 boltforward
	
	self.reloadPhase = 0;
	
	self.ReloadTime = 9999;
	
	-- Progressive Recoil System 
	self.recoilAcc = 0 -- for sinous
	self.recoilStr = 0 -- for accumulator
	self.recoilStrength = 3 -- multiplier for base recoil added to the self.recoilStr when firing
	self.recoilPowStrength = 0.4 -- multiplier for self.recoilStr when firing
	self.recoilRandomUpper = 1.5 -- upper end of random multiplier (1 is lower)
	self.recoilDamping = 1.0
	
	self.recoilMax = 20 -- in deg.
	self.originalSharpLength = self.SharpLength
	-- Progressive Recoil System 	
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
    
    if self.lastHFlipped ~= nil then
        if self.lastHFlipped ~= self.HFlipped then
            self.lastHFlipped = self.HFlipped
            self.angVel = 0
        end
    else
        self.lastHFlipped = self.HFlipped
    end
	
	self.SharpLength = self.originalSharpLength * (0.9 + math.pow(math.min(self.FireTimer.ElapsedSimTimeMS / 250, 1), 2.0) * 0.1)
	
	if self.FiredFrame then
		self.FireTimer:Reset();
	
		self.angVel = self.angVel + RangeRand(0.7,1.1) * 20
		
		self.canSmoke = true
		self.smokeTimer:Reset()
		
		if self.parent then
			local controller = self.parent:GetController();		
		
			if controller:IsState(Controller.BODY_CROUCH) then
				self.recoilStrength = 4
				self.recoilPowStrength = 0.5
				self.recoilRandomUpper = 1.3
				self.recoilDamping = 0.9
				
				self.recoilMax = 20
			else
				self.recoilStrength = 4
				self.recoilPowStrength = 0.4
				self.recoilRandomUpper = 1.5
				self.recoilDamping = 0.75
				
				self.recoilMax = 20
			end
			if (not controller:IsState(Controller.AIM_SHARP))
			or (controller:IsState(Controller.MOVE_LEFT)
			or controller:IsState(Controller.MOVE_RIGHT)) then
				self.recoilDamping = self.recoilDamping * 0.9;
			end
		end
		
		if self.noiseEndSound then
			if self.noiseEndSound:IsBeingPlayed() then
				self.noiseEndSound:Stop(-1)
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
		
		self.mechSounds.Loop:Play(self.Pos);
		self.addSounds.Loop:Play(self.Pos);
		self.bassSounds.Loop:Play(self.Pos);
		
		if outdoorRays >= self.rayThreshold then
			self.noiseSounds.Outdoors.End:Play(self.Pos);
		elseif math.max(outdoorRays, bigIndoorRays, indoorRays) == indoorRays then
			self.noiseSounds.Indoors.End:Play(self.Pos);
		else -- bigIndoor
			self.noiseSounds.bigIndoors.End:Play(self.Pos);
		end
		
	end
	
	-- PAWNIS RELOAD ANIMATION HERE
	if self:IsReloading() then
	
		if self.parent then
			self.parent:GetController():SetState(Controller.AIM_SHARP,false);
		end

		if self.reloadPhase == 0 then
			self.reloadDelay = self.magOutPrepareDelay;
			self.afterDelay = self.magOutAfterDelay;			

			self.prepareSound = self.reloadPrepareSounds.MagOut;
			self.prepareSoundLength = self.reloadPrepareLengths.MagOut;
			self.afterSound = self.reloadAfterSounds.MagOut;

			
		elseif self.reloadPhase == 1 then
			self.reloadDelay = self.magInPrepareDelay;
			self.afterDelay = self.magInAfterDelay;

			self.prepareSound = self.reloadPrepareSounds.MagIn;
			self.prepareSoundLength = self.reloadPrepareLengths.MagIn;
			self.afterSound = self.reloadAfterSounds.MagIn;
			
		elseif self.reloadPhase == 2 then
			self.Frame = 2;
			self.reloadDelay = self.boltForwardPrepareDelay;
			self.afterDelay = self.boltForwardAfterDelay;

			self.prepareSound = nil
			self.prepareSoundLength = 0
			self.afterSound = self.reloadAfterSounds.BoltForward;
			
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
				if self.reloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay/5)*1.5)) then
					self.Frame = 0;
				elseif self.reloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay/5)*1)) then
					self.Frame = 1;
				end
			end
			
			if self.afterSoundPlayed ~= true then
				
				if self.reloadPhase == 2 then
					self.horizontalAnim = self.horizontalAnim - 3
					self.angVel = self.angVel - 37
				end
			
				if self.reloadPhase == 0 then
					self.phaseOnStop = 1;
					local fake
					fake = CreateMOSRotating("Fake Magazine MOSRotating PF940");
					fake.Pos = self.Pos + Vector(-3 * self.FlipFactor, 3):RadRotate(self.RotAngle);
					fake.Vel = self.Vel + Vector(0.5*self.FlipFactor, 3):RadRotate(self.RotAngle);
					fake.RotAngle = self.RotAngle;
					fake.AngularVel = self.AngularVel + (-1*self.FlipFactor);
					fake.HFlipped = self.HFlipped;
					fake:SetStringValue("MagazineType", "Pistol Poly");
					MovableMan:AddParticle(fake);
					
					self.verticalAnim = self.verticalAnim + 1
				elseif self.reloadPhase == 1 then
					if self.chamberOnReload then
						self.phaseOnStop = 2;
					end
					self:RemoveNumberValue("MagRemoved");
					
					self.horizontalAnim = self.horizontalAnim + 3
					self.verticalAnim = self.verticalAnim - 1
					self.angVel = self.angVel + 15
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
				elseif self.reloadPhase == 1 or self.reloadPhase == 2 then
					self.ReloadTime = 0;
					self.reloadPhase = 0;
					self.phaseOnStop = nil;
				else
					self.reloadPhase = self.reloadPhase + 1;
				end
			end
		end		
	else
		
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
		self.ReloadTime = 9999;
		-- SLIDE animation when firing
		-- don't ask, math magic
		if self.Magazine and self.Magazine.RoundCount < 1 or not self.Magazine then
			self.chamberOnReload = true;
			self.Frame = 2;
		else
			local f = math.max(1 - math.min((self.FireTimer.ElapsedSimTimeMS) / 100, 1), 0)
			self.Frame = math.floor(f * 2 + 0.55);
		end
	end
	
	if self:DoneReloading() == true and self.chamberOnReload then
		self.Magazine.RoundCount = 17
		self.chamberOnReload = false;
	elseif self:DoneReloading() then
		self.Magazine.RoundCount = 18
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