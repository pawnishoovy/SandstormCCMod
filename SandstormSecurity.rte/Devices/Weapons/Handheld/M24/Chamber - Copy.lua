function Create(self)
	-- Sounds --
	self.addSounds = {["Loop"] = nil};
	self.addSounds.Loop = {["Variations"] = 4,
	["Path"] = "SandstormSecurity.rte/Devices/Weapons/Handheld/M24/CompliSoundV2/Add"};
	
	self.bassSounds = {["Loop"] = nil};
	self.bassSounds.Loop = {["Variations"] = 1,
	["Path"] = "SandstormSecurity.rte/Devices/Weapons/Handheld/M24/CompliSoundV2/Bass"};
	
	self.noiseSounds = {["Outdoors"] = {["Loop"] = nil, ["End"] = nil},
	["Indoors"] = {["Loop"] = nil, ["End"] = nil},
	["bigIndoors"] = {["Loop"] = nil, ["End"] = nil}};
	self.noiseSounds.Outdoors.End = {["Variations"] = 5,
	["Path"] = "SandstormSecurity.rte/Devices/Weapons/Handheld/M24/CompliSoundV2/NoiseOutdoorsEnd"};
	self.noiseSounds.Indoors.End = {["Variations"] = 6,
	["Path"] = "SandstormSecurity.rte/Devices/Weapons/Handheld/M24/CompliSoundV2/NoiseIndoorsEnd"};
	self.noiseSounds.bigIndoors.End = {["Variations"] = 6,
	["Path"] = "SandstormSecurity.rte/Devices/Weapons/Handheld/M24/CompliSoundV2/NoiseBigIndoorsEnd"};
	
	self.reflectionSounds = {["Outdoors"] = nil};
	self.reflectionSounds.Outdoors = {["Variations"] = 3,
	["Path"] = "SandstormSecurity.rte/Devices/Weapons/Handheld/M24/CompliSoundV2/ReflectionOutdoors"};

	local actor = MovableMan:GetMOFromID(self.RootID);
	if actor and IsAHuman(actor) then
		self.parent = ToAHuman(actor);
	end
	
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
	self.boltDownAfterDelay = 1500;
	
	-- phases:
	-- 0: bolt up
	-- 1: bolt back
	-- 2: special repeating reload phase
	-- 3: bolt forward
	-- 4: bolt down
	
	self.reloadPhase = 0;
	
	self.ReloadTime = 19999;
	
	
end

function Update(self)

	local actor = MovableMan:GetMOFromID(self.RootID);
	if actor and IsAHuman(actor) then
		self.parent = ToAHuman(actor);
	else
		self.parent = nil;
	end
	
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
				"SandstormSecurity.rte/Devices/Weapons/Handheld/M24/Sounds/BoltUp";
				self.afterSoundVars = 1;
				
			elseif self.reloadPhase == 1 then
				self.reloadDelay = self.boltBackPrepareDelay;
				self.afterDelay = self.boltBackAfterDelay;
				self.prepareSoundPath = nil;
				self.prepareSoundVars = 1;
				if self:IsReloading() then
					self.afterSoundPath = 
					"SandstormSecurity.rte/Devices/Weapons/Handheld/M24/Sounds/BoltBackReload";
					self.afterSoundVars = 1;
				else
					self.afterSoundPath = 
					"SandstormSecurity.rte/Devices/Weapons/Handheld/M24/Sounds/BoltBack";
					self.afterSoundVars = 1;
				end
				
			elseif self.reloadPhase == 2 then
				self.reloadDelay = self.shellInPrepareDelay;
				self.afterDelay = self.shellInAfterDelay;
				self.prepareSoundPath = nil;
				self.prepareSoundVars = 1;
				self.afterSoundPath = 
				"SandstormSecurity.rte/Devices/Weapons/Handheld/M24/Sounds/RoundIn";
				self.afterSoundVars = 5;
				
			elseif self.reloadPhase == 3 then
				self.reloadDelay = self.boltForwardPrepareDelay;
				self.afterDelay = self.boltForwardAfterDelay;
				self.prepareSoundPath = nil;
				self.prepareSoundVars = 1;
				self.afterSoundPath = 
				"SandstormSecurity.rte/Devices/Weapons/Handheld/M24/Sounds/BoltForward";
				self.afterSoundVars = 1;
				
			elseif self.reloadPhase == 4 then
				self.Frame = 4;
				self.reloadDelay = self.boltDownPrepareDelay;
				self.afterDelay = self.boltForwardAfterDelay;
				self.prepareSoundPath = nil;
				self.prepareSoundVars = 1;
				self.afterSoundPath = 
				"SandstormSecurity.rte/Devices/Weapons/Handheld/M24/Sounds/BoltDown";
				self.afterSoundVars = 1;
				
			end
			
			if self.prepareSoundPlayed ~= true then
				self.prepareSoundPlayed = true;
				if self.prepareSoundPath then
					self.prepareSound = AudioMan:PlaySound(self.prepareSoundPath .. math.random(1, self.prepareSoundVars) .. ".wav", self.Pos, -1, 0, 130, 1, 250, false);
				end
			end
			
			if self.reloadTimer:IsPastSimMS(self.reloadDelay) then
			
				self.phasePrepareFinished = true;
			
				if self.afterSoundPlayed ~= true then
				
					self.afterSoundPlayed = true;
					if self.afterSoundPath then
						self.afterSound = AudioMan:PlaySound(self.afterSoundPath .. math.random(1, self.afterSoundVars) .. ".wav", self.Pos, -1, 0, 130, 1, 250, false);
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

				end
				
				if self.reloadTimer:IsPastSimMS(self.reloadDelay + self.afterDelay) then
					self.reloadTimer:Reset();
					self.prepareSoundPlayed = false;
					self.afterSoundPlayed = false;
					if self.reloadPhase == 1 then

						if not self:IsReloading() then
							self.reloadPhase = 3;
						else
							self.reloadPhase = self.reloadPhase + 1;
						end
								
						if self.Casing == true then
							local casing
							casing = CreateAEmitter("Sandstorm M24 Rifle Casing");
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
		if self.reloadPhase == 2 then
			self.Frame = 5;
		end
		self.reloadTimer:Reset();
		self.prepareSoundPlayed = false;
		self.afterSoundPlayed = false;
		self.ReloadTime = 19999;
	end
	
	if self:DoneReloading() then
		self.Magazine.RoundCount = self.ammoCount;
	end
	
	if self.FiredFrame then	
		
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

end