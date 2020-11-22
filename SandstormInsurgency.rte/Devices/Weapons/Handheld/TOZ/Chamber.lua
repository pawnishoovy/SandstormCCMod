function Create(self)

	self.parentSet = false;
	
	-- Sounds --
	self.preSounds = {["Variations"] = 4,
	["Path"] = "SandstormInsurgency.rte/Devices/Weapons/Handheld/TOZ/CompliSoundV2/Pre"};
	
	self.addSounds = {["Loop"] = nil};
	self.addSounds.Loop = {["Variations"] = 4,
	["Path"] = "SandstormInsurgency.rte/Devices/Weapons/Handheld/TOZ/CompliSoundV2/Add"};
	
	self.bassSounds = {["Loop"] = nil};
	self.bassSounds.Loop = {["Variations"] = 1,
	["Path"] = "SandstormInsurgency.rte/Devices/Weapons/Handheld/TOZ/CompliSoundV2/Bass"};

	self.noiseSounds = {["Outdoors"] = {["Loop"] = nil, ["End"] = nil},
	["Indoors"] = {["Loop"] = nil, ["End"] = nil},
	["bigIndoors"] = {["Loop"] = nil, ["End"] = nil}};
	self.noiseSounds.Outdoors.End = {["Variations"] = 5,
	["Path"] = "SandstormInsurgency.rte/Devices/Weapons/Handheld/TOZ/CompliSoundV2/NoiseOutdoorsEnd"};
	self.noiseSounds.Indoors.End = {["Variations"] = 6,
	["Path"] = "SandstormInsurgency.rte/Devices/Weapons/Handheld/TOZ/CompliSoundV2/NoiseIndoorsEnd"};
	self.noiseSounds.bigIndoors.End = {["Variations"] = 6,
	["Path"] = "SandstormInsurgency.rte/Devices/Weapons/Handheld/TOZ/CompliSoundV2/NoiseBigIndoorsEnd"};
	
	self.reflectionSounds = {["Outdoors"] = nil};
	self.reflectionSounds.Outdoors = {["Variations"] = 3,
	["Path"] = "SandstormInsurgency.rte/Devices/Weapons/Handheld/TOZ/CompliSoundV2/ReflectionOutdoors"};
	
	self.FireTimer = Timer();
	self:SetNumberValue("DelayedFireTimeMS", 25)
	
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
	
	self.boltBackPrepareDelay = 200;
	self.boltBackAfterDelay = 50;
	self.firstShellInPrepareDelay = 750;
	self.firstShellInAfterDelay = 700;
	self.boltForwardFirstShellPrepareDelay = 200;
	self.boltForwardFirstShellAfterDelay = 200;
	self.shellInPrepareDelay = 400;
	self.shellInAfterDelay = 400;
	self.boltForwardPrepareDelay = 200;
	self.boltForwardAfterDelay = 200;
	
	-- phases:
	-- 0 boltback
	-- 1 firstshellin
	-- 2 boltforwardfirstshell
	-- 3 shellin
	-- 4 boltforward
	
	self.reloadPhase = 0;
	
	self.ReloadTime = 19999;
	
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
end

function Update(self)
	self.rotationTarget = 0 -- ZERO IT FIRST AAAA!!!!!
		self.delayedFireEnabled = true -- IMPORTANT
	
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
		self.horizontalAnim = self.horizontalAnim + 2
		
		self.angVel = self.angVel + RangeRand(0.7,1.1) * 30
		
		if self.parent then
			local controller = self.parent:GetController();		
		
			if controller:IsState(Controller.BODY_CROUCH) then
				self.recoilStrength = 11
				self.recoilPowStrength = 2.5
				self.recoilRandomUpper = 1
				self.recoilDamping = 0.4
				
				self.recoilMax = 20
			else
				self.recoilStrength = 13
				self.recoilPowStrength = 3.4
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
		
		self.canSmoke = true
		self.smokeTimer:Reset()
		
		self.reloadTimer:Reset();
		self.reChamber = true;
		
		if self.Magazine then
			self.ammoCount = 0 + self.Magazine.RoundCount; -- +0 to avoid reference bullshit and save it as a number properly
			if self.ammoCount == 0 then
				self.breechShellReload = true;
				self:Reload();
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
	
	-- PAWNIS RELOAD ANIMATION HERE
	if self.reChamber then
		if self:IsReloading() then
			self.Reloading = true;
			self.reloadCycle = true;
			if self.ammoCount == 0 then
				self.reloadPhase = 0;
			else
				self.reloadPhase = 3;
			end
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
		if self.breechShellReload then
			self.reloadPhase = 0;
		else
			self.reloadPhase = 3;
		end
	end
	
	if self.parent then
	
		local ctrl = self.parent:GetController();
		local screen = ActivityMan:GetActivity():ScreenOfPlayer(ctrl.Player);
	
		if self:IsReloading() then
			self.parent:GetController():SetState(Controller.AIM_SHARP,false);
			self.afterReloadTimer:Reset();
		elseif not self.afterReloadTimer:IsPastSimMS(self.afterReloadDelay) then
			self:Deactivate();
			self.delayedFireEnabled = false -- IMPORTANT
		end
			
		
		if self.resumeReload then
			self:Reload();
			self.resumeReload = false;
			if self.reloadPhase == 3 and self.ammoCount == 8 then
				self.reloadPhase = 4;
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
						PrimitiveMan:DrawLinePrimitive(position + Vector(1,-3), position + Vector(1,3), color);
						PrimitiveMan:DrawLinePrimitive(position + Vector(-1,-3), position + Vector(-1,3), color);
						PrimitiveMan:DrawLinePrimitive(position + Vector(1,3), position + Vector(-1,3), color);
					end
				end
				
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
				self.reloadDelay = self.boltBackPrepareDelay;
				self.afterDelay = self.boltBackAfterDelay;
				
				self.prepareSoundPath = nil;
				self.prepareSoundVars = 1;
				if self:IsReloading() then
					self.afterSoundPath = 
					"SandstormInsurgency.rte/Devices/Weapons/Handheld/TOZ/Sounds/BoltBackReload";
					self.afterSoundVars = 1;
					self.rotationTarget = 5
				else
					self.afterSoundPath = 
					"SandstormInsurgency.rte/Devices/Weapons/Handheld/TOZ/Sounds/BoltBack";
					self.afterSoundVars = 1;
					self.rotationTarget = 2
				end
				
			elseif self.reloadPhase == 1 then
				self.reloadDelay = self.firstShellInPrepareDelay
				self.afterDelay = self.firstShellInAfterDelay
				self.prepareSoundPath = nil;
				self.prepareSoundVars = 1;
				self.afterSoundPath = 
				"SandstormInsurgency.rte/Devices/Weapons/Handheld/TOZ/Sounds/ShellInsertBreech";
				self.afterSoundVars = 1;
				
			elseif self.reloadPhase == 2 then
				self.reloadDelay = self.boltForwardFirstShellPrepareDelay;
				self.afterDelay = self.boltForwardFirstShellAfterDelay;
				self.prepareSoundPath = nil;
				self.prepareSoundVars = 1;
				self.afterSoundPath = 
				"SandstormInsurgency.rte/Devices/Weapons/Handheld/TOZ/Sounds/BoltForwardReload";
				self.afterSoundVars = 1;
				
				self.rotationTarget = -10
			elseif self.reloadPhase == 3 then
				self.reloadDelay = self.shellInPrepareDelay;
				self.afterDelay = self.shellInAfterDelay;
				self.prepareSoundPath = nil;
				self.prepareSoundVars = 1;
				self.afterSoundPath = 
				"SandstormInsurgency.rte/Devices/Weapons/Handheld/TOZ/Sounds/ShellInsert";
				self.afterSoundVars = 6;
				
				self.rotationTarget = 10 * self.reloadTimer.ElapsedSimTimeMS / (self.reloadDelay + self.afterDelay)
			elseif self.reloadPhase == 4 then
				self.reloadDelay = self.boltForwardPrepareDelay;
				self.afterDelay = self.boltForwardAfterDelay;
				self.prepareSoundPath = nil;
				self.prepareSoundVars = 1;
				self.afterSoundPath = 
				"SandstormInsurgency.rte/Devices/Weapons/Handheld/TOZ/Sounds/BoltForward";
				self.afterSoundVars = 1;
				
				self.rotationTarget = -5
			end
			
			if self.prepareSoundPlayed ~= true then
				self.prepareSoundPlayed = true;
				if self.prepareSoundPath then
					self.prepareSound = AudioMan:PlaySound(self.prepareSoundPath .. math.random(1, self.prepareSoundVars) .. ".ogg", self.Pos, -1, 0, 130, 1, 250, false);
				end
			end
			
			if self.reloadTimer:IsPastSimMS(self.reloadDelay) then
				--[[
				if self.reloadPhase == 0 and self.Casing then
					local shell
					shell = CreateMOSParticle("Shell Shotgun");
					shell.Pos = self.Pos+Vector(0,-3):RadRotate(self.RotAngle);
					shell.Vel = self.Vel+Vector(-math.random(2,4)*self.FlipFactor,-math.random(3,4)):RadRotate(self.RotAngle);
					MovableMan:AddParticle(shell);
					
					self.Casing = false
				end]]
				if self.reloadPhase == 0 then
					self.horizontalAnim = self.horizontalAnim + TimerMan.DeltaTimeSecs * self.afterDelay
				end
			
				self.phasePrepareFinished = true;
			
				if self.afterSoundPlayed ~= true then
					if self.reloadPhase == 1 or self.reloadPhase == 3 then
						self.horizontalAnim = self.horizontalAnim + 1
						self.verticalAnim = self.verticalAnim - 1
					end
				
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
				
					if self.parent:GetController():IsState(Controller.WEAPON_FIRE) then
						self.reloadCycle = false;
						PrimitiveMan:DrawTextPrimitive(screen, self.parent.AboveHUDPos + Vector(0, 30), "Interrupting...", true, 1);
					end
				
					if self.ammoCountRaised ~= true then
						self.ammoCountRaised = true;
						if self.ammoCount < 8 then
							self.ammoCount = self.ammoCount + 1;
							if self.ammoCount == 8 then
								self.reloadCycle = false;
							end
						else
							self.reloadCycle = false;
						end
					end
					
					self.phaseOnStop = 2;
					
				elseif self.reloadPhase == 2 then
					
					if self.reloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay/5)*1.5)) then
						self.Frame = 0;
					elseif self.reloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay/5)*1)) then
						self.Frame = 1;
					end
					
				elseif self.reloadPhase == 3 then
					
					self.phaseOnStop = 3;
				
					if self.parent:GetController():IsState(Controller.WEAPON_FIRE) then
						self.reloadCycle = false;
						PrimitiveMan:DrawTextPrimitive(screen, self.parent.AboveHUDPos + Vector(0, 30), "Interrupting...", true, 1);
					end

					if self.ammoCountRaised ~= true then
						self.ammoCountRaised = true;
						if self.ammoCount < 8 then
							self.ammoCount = self.ammoCount + 1;
							if self.ammoCount == 8 then
								self.reloadCycle = false;
							end
						else
							self.reloadCycle = false;
						end
					end

				elseif self.reloadPhase == 4 then
					
					if self.reloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay/5)*1.5)) then
						self.Frame = 0;
					elseif self.reloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay/5)*1)) then
						self.Frame = 1;
					end

				end
				
				if self.reloadTimer:IsPastSimMS(self.reloadDelay + self.afterDelay) then
					self.reloadTimer:Reset();
					self.prepareSoundPlayed = false;
					self.afterSoundPlayed = false;
					if self.reloadPhase == 0 then

						if not self:IsReloading() then
							self.reloadPhase = 4;
						elseif self.breechShellReload == true then
							self.reloadPhase = self.reloadPhase + 1;
						else
							self.reloadPhase = 4;
						end
						if self.Casing then
							local shell
							shell = CreateMOSParticle("Shell Shotgun");
							shell.Pos = self.Pos+Vector(-3 * self.FlipFactor,-1):RadRotate(self.RotAngle);
							shell.Vel = self.Vel+Vector(-math.random(2,4)*self.FlipFactor,-math.random(3,4)):RadRotate(self.RotAngle);
							MovableMan:AddParticle(shell);
							
							self.Casing = false
						end
					
					elseif self.reloadPhase == 1 then
					
						self.ammoCountRaised = false;
					
						self.reloadPhase = self.reloadPhase + 1;
						
					elseif self.reloadPhase == 2 then
					
						if self.reloadCycle then
							self.reloadPhase = 3; -- same phase baby the ride never ends (except at 8 rounds)
						else
							self.ReloadTime = 0;
							self.reloadPhase = 0;
							self.Chamber = false;
							self.Reloading = false;
							self.phaseOnStop = nil;
						end
						
					elseif self.reloadPhase == 3 then
					
						self.ammoCountRaised = false;
					
						if self.reloadCycle then
							self.reloadPhase = 3; -- same phase baby the ride never ends (except at 8 rounds)
						else
							self.ReloadTime = 0;
							self.reloadPhase = 0;
							self.Chamber = false;
							self.Reloading = false;
							self.phaseOnStop = nil;
						end
					
					elseif self.reloadPhase == 4 then
					
						if self:IsReloading() then
							if self.ammoCount < 8 then
								self.reloadPhase = 3;
							else
								self.ReloadTime = 0;
								self.reloadPhase = 0;
								self.Chamber = false;
								self.Reloading = false;
								self.phaseOnStop = nil;
							end
						else
							self.ReloadTime = 0;
							self.reloadPhase = 0;
							self.Chamber = false;
							self.Reloading = false;
							self.phaseOnStop = nil;
						end
						
					else
						self.reloadPhase = self.reloadPhase + 1;
					end
				end				
			else
				self.phasePrepareFinished = false;
			end
			
		else
			local f = math.max(1 - math.min((self.FireTimer.ElapsedSimTimeMS - 25) / 200, 1), 0)
			self.JointOffset = self.originalJointOffset + Vector(1, 0) * f
			
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
		if self.phaseOnStop then
			self.reloadPhase = self.phaseOnStop;
			self.phaseOnStop = nil;
		end
		self.reloadTimer:Reset();
		self.prepareSoundPlayed = false;
		self.afterSoundPlayed = false;
		self.ReloadTime = 19999;
	end
	
	if self:DoneReloading() then
		self.breechShellReload = false;
		self.Magazine.RoundCount = self.ammoCount;
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
		if self.parent:GetController():IsState(Controller.AIM_SHARP) == true and self.parent:GetController():IsState(Controller.MOVE_LEFT) == false and self.parent:GetController():IsState(Controller.MOVE_RIGHT) == false then
			supportOffset = supportOffset + Vector(-1,0)
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