function Create(self)

	self.parentSet = false;
	
	-- Sounds --
	
	self.addSounds = {["Loop"] = nil};
	self.addSounds.Loop = {["Variations"] = 4,
	["Path"] = "SandstormSecurity.rte/Devices/Weapons/Handheld/TS12/CompliSoundV2/Add"};
	
	self.bassSounds = {["Loop"] = nil};
	self.bassSounds.Loop = {["Variations"] = 1,
	["Path"] = "SandstormSecurity.rte/Devices/Weapons/Handheld/TS12/CompliSoundV2/Bass"};
	
	self.mechSounds = {["Loop"] = nil};
	self.mechSounds.Loop = {["Variations"] = 4,
	["Path"] = "SandstormSecurity.rte/Devices/Weapons/Handheld/TS12/CompliSoundV2/Mech"};
	
	self.noiseSounds = {["Outdoors"] = {["Loop"] = nil, ["End"] = nil},
	["Indoors"] = {["Loop"] = nil, ["End"] = nil},
	["bigIndoors"] = {["Loop"] = nil, ["End"] = nil}};
	self.noiseSounds.Outdoors.End = {["Variations"] = 5,
	["Path"] = "SandstormSecurity.rte/Devices/Weapons/Handheld/TS12/CompliSoundV2/NoiseOutdoorsEnd"};
	self.noiseSounds.Indoors.End = {["Variations"] = 6,
	["Path"] = "SandstormSecurity.rte/Devices/Weapons/Handheld/TS12/CompliSoundV2/NoiseIndoorsEnd"};
	self.noiseSounds.bigIndoors.End = {["Variations"] = 6,
	["Path"] = "SandstormSecurity.rte/Devices/Weapons/Handheld/TS12/CompliSoundV2/NoiseBigIndoorsEnd"};
	
	self.reflectionSounds = {["Outdoors"] = nil};
	self.reflectionSounds.Outdoors = {["Variations"] = 3,
	["Path"] = "SandstormSecurity.rte/Devices/Weapons/Handheld/TS12/CompliSoundV2/ReflectionOutdoors"};
	
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
	
	-- phases:
	-- 0 TurnChamber
	-- 1 Turn
	-- 2 ShellIn
	-- 3 BoltBack
	-- 4 BoltForward
	
	self.reloadPhase = 0;
	
end

function Update(self)

	print("tube1: " .. self.tube1AmmoCount)
	print("tube2: " .. self.tube2AmmoCount)
	print("tube3: " .. self.tube3AmmoCount)
	print(self.roundChambered)

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
	
	self.SharpLength = self.originalSharpLength * (0.9 + math.pow(math.min(self.FireTimer.ElapsedSimTimeMS / 125, 1), 2.0) * 0.1)
	
	if self.FiredFrame then
		self.roundChambered = false;
		self.horizontalAnim = self.horizontalAnim + 2
		
		self.angVel = self.angVel + RangeRand(0.7,1.1) * 30
		
		self.canSmoke = true
		self.smokeTimer:Reset()	
		
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
		
		self.bassSound = AudioMan:PlaySound(self.bassSounds.Loop.Path .. math.random(1, self.bassSounds.Loop.Variations) .. ".wav", self.Pos, -1, 0, 130, 1, 450, false);			
		self.mechSound = AudioMan:PlaySound(self.mechSounds.Loop.Path .. math.random(1, self.mechSounds.Loop.Variations) .. ".wav", self.Pos, -1, 0, 130, 1, 450, false);
		
		if outdoorRays >= 2 then
			self.noiseEndSound = AudioMan:PlaySound(self.noiseSounds.Outdoors.End.Path .. math.random(1, self.noiseSounds.Outdoors.End.Variations) .. ".wav", self.Pos, -1, 0, 130, 1, 450, false);
			self.reflectionSound = AudioMan:PlaySound(self.reflectionSounds.Outdoors.Path .. math.random(1, self.reflectionSounds.Outdoors.Variations) .. ".wav", self.Pos, -1, 0, 130, 1, 450, false);
		elseif math.max(outdoorRays, bigIndoorRays, indoorRays) == indoorRays then
			self.noiseEndSound = AudioMan:PlaySound(self.noiseSounds.Indoors.End.Path .. math.random(1, self.noiseSounds.Indoors.End.Variations) .. ".wav", self.Pos, -1, 0, 130, 1, 450, false);
		else -- bigIndoor
			self.noiseEndSound = AudioMan:PlaySound(self.noiseSounds.bigIndoors.End.Path .. math.random(1, self.noiseSounds.bigIndoors.End.Variations) .. ".wav", self.Pos, -1, 0, 130, 1, 450, false);
		end

	
		self.addSound = AudioMan:PlaySound(self.addSounds.Loop.Path .. math.random(1, self.addSounds.Loop.Variations) .. ".wav", self.Pos, -1, 0, 130, 1, 450, false);
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
				
				self.prepareSoundPath = nil;
				self.prepareSoundVars = 1;
				self.afterSoundPath = 
				"SandstormSecurity.rte/Devices/Weapons/Handheld/TS12/Sounds/RotateChamber";
				self.afterSoundVars = 3;
				self.rotationTarget = 2
				
			elseif self.reloadPhase == 1 then
				self.reloadDelay = self.TurnPrepareDelay
				self.afterDelay = self.TurnAfterDelay
				
				self.prepareSoundPath = nil;
				self.prepareSoundVars = 1;
				self.afterSoundPath = 
				"SandstormSecurity.rte/Devices/Weapons/Handheld/TS12/Sounds/Rotate";
				self.afterSoundVars = 3;
				
			elseif self.reloadPhase == 2 then
				self.reloadDelay = self.shellInPrepareDelay;
				self.afterDelay = self.shellInAfterDelay;
				
				self.prepareSoundPath = nil;
				self.prepareSoundVars = 1;
				self.afterSoundPath = 
				"SandstormSecurity.rte/Devices/Weapons/Handheld/TS12/Sounds/ShellInsert";
				self.afterSoundVars = 4;
				
				self.rotationTarget = -10
			elseif self.reloadPhase == 3 then
				self.reloadDelay = self.boltBackPrepareDelay;
				self.afterDelay = self.boltBackAfterDelay;
				
				self.prepareSoundPath = nil;
				self.prepareSoundVars = 1;
				self.afterSoundPath = 
				"SandstormSecurity.rte/Devices/Weapons/Handheld/TS12/Sounds/BoltBack";
				self.afterSoundVars = 1;
				
				self.rotationTarget = 10 * self.reloadTimer.ElapsedSimTimeMS / (self.reloadDelay + self.afterDelay)
			elseif self.reloadPhase == 4 then
				self.reloadDelay = self.boltForwardPrepareDelay;
				self.afterDelay = self.boltForwardAfterDelay;
				self.prepareSoundPath = nil;
				self.prepareSoundVars = 1;
				self.afterSoundPath = 
				"SandstormSecurity.rte/Devices/Weapons/Handheld/TS12/Sounds/BoltForward";
				self.afterSoundVars = 1;
				
				self.rotationTarget = -5
			end
			
			if self.prepareSoundPlayed ~= true then
				self.prepareSoundPlayed = true;
				if self.prepareSoundPath then
					self.prepareSound = AudioMan:PlaySound(self.prepareSoundPath .. math.random(1, self.prepareSoundVars) .. ".wav", self.Pos, -1, 0, 130, 1, 250, false);
				end
			end
			
			if self.reloadTimer:IsPastSimMS(self.reloadDelay) then
			
			
				if self.afterSoundPlayed ~= true then			
					self.afterSoundPlayed = true;
					if self.afterSoundPath then
						self.afterSound = AudioMan:PlaySound(self.afterSoundPath .. math.random(1, self.afterSoundVars) .. ".wav", self.Pos, -1, 0, 130, 1, 250, false);
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
					
				elseif self.reloadPhase == 1 then			
					
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
					end
					
					if not self.shellInDone then
						self.shellInDone = true;
						-- AAAAAAAHHHHHHHHHHHH
						if not (self.tube1AmmoCount == 0 and self.tube2AmmoCount == 0 and self.tube3AmmoCount == 0) then
							if self.tube2AmmoCount < 4 then
								self.tube2AmmoCount = self.tube2AmmoCount + 1;
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
end