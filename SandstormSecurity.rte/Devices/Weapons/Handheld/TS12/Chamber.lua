function Create(self)

	self.parentSet = false;
	
	-- Sounds --
	
	self.sharpAimSounds = {["In"] = nil, ["Out"] = nil};
	self.sharpAimSounds.In = CreateSoundContainer("SharpAimIn TS12", "SandstormSecurity.rte");
	self.sharpAimSounds.Out = CreateSoundContainer("SharpAimOut TS12", "SandstormSecurity.rte");
	
	self.bassSounds = {["Start"] = nil, ["Loop"] = nil};
	self.bassSounds.Loop = CreateSoundContainer("Bass TS12", "SandstormSecurity.rte");
	
	self.addSounds = {["Start"] = nil, ["Loop"] = nil};
	self.addSounds.Loop = CreateSoundContainer("Add TS12", "SandstormSecurity.rte");
	
	self.mechSounds = {["Start"] = nil, ["Loop"] = nil};
	self.mechSounds.Loop = CreateSoundContainer("Mech TS12", "SandstormSecurity.rte");
	
	self.noiseSounds = {["Outdoors"] = {["Loop"] = nil, ["End"] = nil},
	["Indoors"] = {["Loop"] = nil, ["End"] = nil},
	["bigIndoors"] = {["Loop"] = nil, ["End"] = nil}};
	self.noiseSounds.Outdoors.End = CreateSoundContainer("NoiseOutdoorsEnd TS12", "SandstormSecurity.rte");
	self.noiseSounds.Outdoors.End.Pitch = 1.0;
	self.noiseSounds.Indoors.End = CreateSoundContainer("NoiseIndoorsEnd TS12", "SandstormSecurity.rte");
	self.noiseSounds.Indoors.End.Pitch = 1.0;
	self.noiseSounds.bigIndoors.End = CreateSoundContainer("NoiseBigIndoorsEnd TS12", "SandstormSecurity.rte");
	self.noiseSounds.bigIndoors.End.Pitch = 1.0;
	
	self.reflectionSounds = {["Outdoors"] = nil};
	self.reflectionSounds.Outdoors = CreateSoundContainer("Noise ReflectionOutdoors", "Sandstorm.rte");
	self.reflectionSounds.Outdoors.Pitch = 0.9
	
	self.reloadPrepareSounds = {}
	self.reloadPrepareSounds.SwitchSide = CreateSoundContainer("SwitchSidePrepare TS12", "SandstormSecurity.rte");
	
	self.reloadPrepareLengths = {}
	self.reloadPrepareLengths.SwitchSide = 600;
	
	self.reloadAfterSounds = {}
	self.reloadAfterSounds.RotateChamber = CreateSoundContainer("RotateChamber TS12", "SandstormSecurity.rte");
	self.reloadAfterSounds.Rotate = CreateSoundContainer("Rotate TS12", "SandstormSecurity.rte");
	self.reloadAfterSounds.ShellInsert = CreateSoundContainer("ShellInsert TS12", "SandstormSecurity.rte");
	self.reloadAfterSounds.SwitchSide = CreateSoundContainer("SwitchSide TS12", "SandstormSecurity.rte");
	
	self.FireTimer = Timer();
	
	self.tube1AmmoCount = 4;
	self.tube2AmmoCount = 4;
	self.tube3AmmoCount = 4;
	
	self.roundChambered = true;
	
	self.originalSharpLength = self.SharpLength
	
	self.originalStanceOffset = Vector(math.abs(self.StanceOffset.X), self.StanceOffset.Y)
	self.originalSharpStanceOffset = Vector(self.SharpStanceOffset.X, self.SharpStanceOffset.Y)
	
	self.originalJointOffset = Vector(self.JointOffset.X, self.JointOffset.Y)
	self.originalSupportOffset = Vector(math.abs(self.SupportOffset.X), self.SupportOffset.Y)
	
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
	
	self.afterReloadDelay = 400;
	self.afterReloadTimer = Timer();
	
	self.turnChamberPrepareDelay = 300;
	self.turnChamberAfterDelay = 500;
	self.TurnPrepareDelay = 300;
	self.TurnAfterDelay = 500;
	self.shellInPrepareDelay = 200;
	self.shellInAfterDelay = 250;
	self.boltBackPrepareDelay = 400;
	self.boltBackAfterDelay = 400;
	self.boltForwardPrepareDelay = 200;
	self.boltForwardAfterDelay = 200;
	self.switchSidePrepareDelay = 600;
	self.switchSideAfterDelay = 500;
	
	-- phases:
	-- 0 TurnChamber
	-- 1 Turn
	-- 2 ShellIn
	-- 3 BoltBack
	-- 4 BoltForward
	-- 5 SwitchSide
	
	self.reloadPhase = 0;
	
	-- Progressive Recoil System 
	self.recoilAcc = 0 -- for sinous
	self.recoilStr = 0 -- for accumulator
	self.recoilStrength = 14 -- multiplier for base recoil added to the self.recoilStr when firing
	self.recoilPowStrength = 1 -- multiplier for self.recoilStr when firing
	self.recoilRandomUpper = 1.2 -- upper end of random multiplier (1 is lower)
	self.recoilDamping = 0.9
	
	self.recoilMax = 20 -- in deg.
	self.originalSharpLength = self.SharpLength
	-- Progressive Recoil System 	
end

function Update(self)

	--print("tube1: " .. self.tube1AmmoCount)
	--print("tube2: " .. self.tube2AmmoCount)
	--print("tube3: " .. self.tube3AmmoCount)
	--print(self.roundChambered)

	self.rotationTarget = 0 -- ZERO IT FIRST AAAA!!!!!
	if self.roundChambered then
		self.Frame = 0;
	else
		self.Frame = 2;
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
	
	self.SharpLength = self.originalSharpLength * (0.9 + math.pow(math.min(self.FireTimer.ElapsedSimTimeMS / 125, 1), 2.0) * 0.1)
	
	if self.FiredFrame then
		self.roundChambered = false;
		self.Frame = 2;
		self.horizontalAnim = self.horizontalAnim + 2
		
		self.angVel = self.angVel + RangeRand(0.7,1.1) * 20
		
		self.canSmoke = true
		self.smokeTimer:Reset()	
		
		if self.parent then
			local controller = self.parent:GetController();		
		
			if controller:IsState(Controller.BODY_CROUCH) then
				self.recoilStrength = 12
				self.recoilPowStrength = 1
				self.recoilRandomUpper = 1
				self.recoilDamping = 1
				
				self.recoilMax = 20
			else
				self.recoilStrength = 14
				self.recoilPowStrength = 1
				self.recoilRandomUpper = 1.2
				self.recoilDamping = 0.9
				
				self.recoilMax = 20
			end
			if (not controller:IsState(Controller.AIM_SHARP))
			or (controller:IsState(Controller.MOVE_LEFT)
			or controller:IsState(Controller.MOVE_RIGHT)) then
				self.recoilDamping = self.recoilDamping * 0.9;
			end
		end
		
		if self.tube3AmmoCount == 0 then
			if self.tube2AmmoCount == 0 and self.tube1AmmoCount == 0 then
				self:Reload();
				self.Reloading = true;
				self.Chamber = true;
				self.reloadPhase = 2;
				self.reloadCycle = true;
			else
				self.Chamber = true;
				self.reloadPhase = 0;
				self.reChamber = true;
			end
		else
			self.tube3AmmoCount = self.tube3AmmoCount -1;
			self.roundChambered = true;
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
			self.reflectionSounds.Outdoors:Play(self.Pos);
		elseif math.max(outdoorRays, bigIndoorRays, indoorRays) == indoorRays then
			self.noiseSounds.Indoors.End:Play(self.Pos);
		else -- bigIndoor
			self.noiseSounds.bigIndoors.End:Play(self.Pos);
		end
		
	end
	
	-- PAWNIS RELOAD ANIMATION HERE
	
	if self.Magazine then
		self.Magazine.RoundCount = self.tube1AmmoCount + self.tube2AmmoCount + self.tube3AmmoCount;
		if self.roundChambered then
			self.Magazine.RoundCount = self.Magazine.RoundCount + 1;
		end
	end
	
	if self:IsReloading() and (not self.Chamber) then -- if we start reloading from "scratch"
		self.Chamber = true;
		self.ReloadTime = 19999;
		self.Reloading = true;
		self.reloadCycle = true;
		if (self.tube1AmmoCount < 4) or (self.tube2AmmoCount < 4) then
			self.reloadPhase = 2;
		else
			local Tube1 = self.tube1AmmoCount + 0;
			local Tube2 = self.tube2AmmoCount + 0;
			local Tube3 = self.tube3AmmoCount + 0;
			
			self.tube1AmmoCount = Tube3;
			self.tube2AmmoCount = Tube1;
			self.tube3AmmoCount = Tube2;
			self.reloadPhase = 1;
		end
	end
	
	if self.parent then
		
		if self.resumeReload then
			self:Reload();
			self.resumeReload = false;
		end
	
		local ctrl = self.parent:GetController();
		local screen = ActivityMan:GetActivity():ScreenOfPlayer(ctrl.Player);
		
		if self:IsReloading() then
			self.parent:GetController():SetState(Controller.AIM_SHARP,false);
			self.afterReloadTimer:Reset();
		elseif not self.afterReloadTimer:IsPastSimMS(self.afterReloadDelay) then
			self:Deactivate();
		end		
	
		if self.Chamber then
			self:Deactivate();
			if self:IsReloading() then				
				if self.Reloading == false then
					self.reloadCycle = true;
					self.ReloadTime = 19999;
					self.Reloading = true;
					-- self.reloadTimer:Reset();
					-- self.prepareSoundPlayed = false;
					-- self.afterSoundPlayed = false;
				end				
			else
				self.Reloading = false;
			end
			
			if self.reloadPhase == 0 then
				self.reloadDelay = self.turnChamberPrepareDelay;
				self.afterDelay = self.turnChamberAfterDelay;
				
				self.prepareSound = nil
				self.prepareSoundLength = 0
				self.afterSound = self.reloadAfterSounds.RotateChamber;
			
				self.rotationTarget = 2
				
			elseif self.reloadPhase == 1 then
				self.reloadDelay = self.TurnPrepareDelay
				self.afterDelay = self.TurnAfterDelay
				
				self.prepareSound = nil
				self.prepareSoundLength = 0
				self.afterSound = self.reloadAfterSounds.Rotate;
				
			elseif self.reloadPhase == 2 then
				self.reloadDelay = self.shellInPrepareDelay;
				self.afterDelay = self.shellInAfterDelay;
				
				self.prepareSound = nil
				self.prepareSoundLength = 0
				self.afterSound = self.reloadAfterSounds.ShellInsert;
				
				self.rotationTarget = -10
			elseif self.reloadPhase == 3 then
				self.reloadDelay = self.boltBackPrepareDelay;
				self.afterDelay = self.boltBackAfterDelay;
				
				self.prepareSound = nil
				self.prepareSoundLength = 0
				self.afterSound = self.reloadAfterSounds.BoltBack; -- unused undefined
				
				self.rotationTarget = 10 * self.reloadTimer.ElapsedSimTimeMS / (self.reloadDelay + self.afterDelay)
			elseif self.reloadPhase == 4 then
				self.reloadDelay = self.boltForwardPrepareDelay;
				self.afterDelay = self.boltForwardAfterDelay;

				self.prepareSound = nil
				self.prepareSoundLength = 0
				self.afterSound = self.reloadAfterSounds.BoltForward; -- unused undefined
				
				self.rotationTarget = -5
			elseif self.reloadPhase == 5 then
				self.reloadDelay = self.switchSidePrepareDelay;
				self.afterDelay = self.switchSideAfterDelay;

				self.prepareSound = self.reloadPrepareSounds.SwitchSide;
				self.prepareSoundLength = self.reloadPrepareLengths.SwitchSide;
				self.afterSound = self.reloadAfterSounds.SwitchSide;
				
				self.rotationTarget = 3;
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
			
			
				if self.afterSoundPlayed ~= true then			
					self.afterSoundPlayed = true;
					if self.afterSound then
						self.afterSound:Play(self.Pos);
					end
				end
			
				if self.reloadPhase == 0 then
				
					self.roundChambered = true;
					if self.reChamber then
						local Tube1 = self.tube1AmmoCount + 0;
						local Tube2 = self.tube2AmmoCount + 0;
						local Tube3 = self.tube3AmmoCount + 0;
						
						self.tube1AmmoCount = Tube3;
						self.tube2AmmoCount = Tube1;
						self.tube3AmmoCount = Tube2 - 1;
						
						self.reChamber = false;
					end
					
					if self.reloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay/5)*3.5)) then
						self.Frame = 0;
					elseif self.reloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay/5)*2.5)) then
						self.Frame = 1;
					elseif self.reloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay/5)*1.5)) then
						self.Frame = 6;
					elseif self.reloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay/5)*0.5)) then
						self.Frame = 5;
					end
					
				elseif self.reloadPhase == 1 then			
			
					if self.reloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay/5)*2.5)) then
						self.Frame = 0;
					elseif self.reloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay/5)*1.5)) then
						self.Frame = 4;
					elseif self.reloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay/5)*0.5)) then
						self.Frame = 3;
					end
					
				elseif self.reloadPhase == 2 then
				
					if self.parent:GetController():IsState(Controller.WEAPON_FIRE) then
						self.reloadCycle = false;
						PrimitiveMan:DrawTextPrimitive(screen, self.parent.AboveHUDPos + Vector(0, 30), "Interrupting...", true, 1);
						if self.tube3AmmoCount == 0 and self.roundChambered == false then
							self.reChamber = true;
							self.reloadPhase = 0;
							self.reloadTimer:Reset();
							self.afterSoundPlayed = false;
							self.prepareSoundPlayed = false;
						end
						self.nextPhase = nil;
					end
					
					if not self.shellInDone then
						self.shellInDone = true;
						-- AAAAAAAHHHHHHHHHHHH
						if not (self.tube1AmmoCount == 0 and self.tube2AmmoCount == 0 and self.tube3AmmoCount == 0) then
							if self.tube2AmmoCount < 4 then
								self.tube2AmmoCount = self.tube2AmmoCount + 1;
								if self.tube2AmmoCount == 4 then
									self.nextPhase = 5;
								end
							elseif self.tube1AmmoCount < 4 then
								self.tube1AmmoCount = self.tube1AmmoCount + 1;
								if self.tube1AmmoCount == 4 then
									if self.tube3AmmoCount == 0 and self.roundChambered == false then
										self.nextPhase = 0;
										local Tube1 = self.tube1AmmoCount + 0;
										local Tube2 = self.tube2AmmoCount + 0;
										local Tube3 = self.tube3AmmoCount + 0;
										
										self.tube1AmmoCount = Tube3;
										self.tube2AmmoCount = Tube1;
										self.tube3AmmoCount = Tube2 - 1;
										
										self.reloadCycle = true;
									elseif self.tube3AmmoCount < 4 then
										self.nextPhase = 1;
										local Tube1 = self.tube1AmmoCount + 0;
										local Tube2 = self.tube2AmmoCount + 0;
										local Tube3 = self.tube3AmmoCount + 0;
										
										self.tube1AmmoCount = Tube3;
										self.tube2AmmoCount = Tube1;
										self.tube3AmmoCount = Tube2;
										
										self.reloadCycle = true;
									else
										self.reloadCycle = false;
									end
								end
							end
						else
							if self.tube2AmmoCount < 4 then
								self.tube2AmmoCount = self.tube2AmmoCount + 1;
								if self.tube2AmmoCount == 4 then
									self.nextPhase = 0;
									local Tube1 = self.tube1AmmoCount + 0;
									local Tube2 = self.tube2AmmoCount + 0;
									local Tube3 = self.tube3AmmoCount + 0;
									
									self.tube1AmmoCount = Tube3;
									self.tube2AmmoCount = Tube1;
									self.tube3AmmoCount = Tube2 - 1;
									
									self.reloadCycle = true;
								end
							end
						end
					end

				elseif self.reloadPhase == 3 then


				elseif self.reloadPhase == 4 then
					

				end
				
				if self.reloadTimer:IsPastSimMS(self.reloadDelay + self.afterDelay) then
					self.reloadTimer:Reset();
					self.prepareSoundPlayed = false;
					self.afterSoundPlayed = false;
					self.shellInDone = false;
						
					if self.nextPhase then
						self.reloadPhase = self.nextPhase
						self.nextPhase = nil;
					elseif self.reloadCycle == true then
						self.reloadPhase = 2;
					else
						self.ReloadTime = 0;
						self.reloadPhase = 0;
						self.Chamber = false;
						self.Reloading = false;
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
		self.shellInDone = false;
		if self.Reloading then
			self.resumeReload = true;
		end
		self.reloadTimer:Reset();
		self.prepareSoundPlayed = false;
		self.afterSoundPlayed = false;
		self.ReloadTime = 19999;
	end
	
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
		--self:SetNumberValue("MagRotation", total);
		
		local supportOffset = Vector(0,0)
		if self.Frame == 1 then
			supportOffset = Vector(-1,0)
		elseif self.Frame == 2 then
			supportOffset = Vector(-3,0)
		end
		self.SupportOffset = self.originalSupportOffset + supportOffset
		
		local jointOffset = Vector(self.JointOffset.X * self.FlipFactor, self.JointOffset.Y):RadRotate(self.RotAngle);
		local offsetTotal = Vector(jointOffset.X, jointOffset.Y):RadRotate(-total) - jointOffset
		self.Pos = self.Pos + offsetTotal;
		--self:SetNumberValue("MagOffsetX", offsetTotal.X);
		--self:SetNumberValue("MagOffsetY", offsetTotal.Y);
		
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
		if self.smokeDelayTimer:IsPastSimMS(60) then
			
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