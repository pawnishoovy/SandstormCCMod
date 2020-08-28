
function stringInsert(str1, str2, pos)
    return str1:sub(1,pos)..str2..str1:sub(pos+1)
end

function animationPlay(self, ID)
	
	self.animationID = ID
	self.animationPhase = 1
	self.animationPhaseStart = false
	self.animationTimer:Reset()
	self.animationIsPlaying = true
	return
end

function animationGetDuration(self, ID)
	local duration = 0
	local animation = self.animationContainer[ID]
	for i, phase in ipairs(animation) do
		duration = duration + phase.waitMS + phase.durationMS
	end
	return duration
end

function Create(self)
	-- Sounds --
	self.addSounds = {["Start"] = nil, ["Loop"] = nil};
	self.addSounds.Start = {["Variations"] = 4,
	["Path"] = "SandstormSecurity.rte/Devices/Weapons/Handheld/GalilSAR/CompliSoundV2/AddStart"};
	self.addSounds.Loop = {["Variations"] = 14,
	["Path"] = "SandstormSecurity.rte/Devices/Weapons/Handheld/GalilSAR/CompliSoundV2/Add"};
	
	self.bassSounds = {["Loop"] = nil};
	self.bassSounds.Loop = {["Variations"] = 15,
	["Path"] = "SandstormSecurity.rte/Devices/Weapons/Handheld/GalilSAR/CompliSoundV2/Bass"};
	
	self.mechSounds = {["Start"] = nil, ["Loop"] = nil, ["End"] = nil};
	self.mechSounds.Start = {["Variations"] = 4,
	["Path"] = "SandstormSecurity.rte/Devices/Weapons/Handheld/GalilSAR/CompliSoundV2/MechStart"};
	self.mechSounds.Loop = {["Variations"] = 14,
	["Path"] = "SandstormSecurity.rte/Devices/Weapons/Handheld/GalilSAR/CompliSoundV2/Mech"};
	self.mechSounds.End = {["Variations"] = 4,
	["Path"] = "SandstormSecurity.rte/Devices/Weapons/Handheld/GalilSAR/CompliSoundV2/MechEnd"};
	
	self.noiseSounds = {["Outdoors"] = {["Loop"] = nil, ["End"] = nil},
	["Indoors"] = {["Loop"] = nil, ["End"] = nil},
	["bigIndoors"] = {["Loop"] = nil, ["End"] = nil}};
	self.noiseSounds.Outdoors.Loop = {["Variations"] = 13,
	["Path"] = "SandstormSecurity.rte/Devices/Weapons/Handheld/GalilSAR/CompliSoundV2/NoiseOutdoors"};
	self.noiseSounds.Outdoors.End = {["Variations"] = 4,
	["Path"] = "SandstormSecurity.rte/Devices/Weapons/Handheld/GalilSAR/CompliSoundV2/NoiseOutdoorsEnd"};
	self.noiseSounds.Indoors.Loop = {["Variations"] = 5,
	["Path"] = "SandstormSecurity.rte/Devices/Weapons/Handheld/GalilSAR/CompliSoundV2/NoiseIndoors"};
	self.noiseSounds.Indoors.End = {["Variations"] = 4,
	["Path"] = "SandstormSecurity.rte/Devices/Weapons/Handheld/GalilSAR/CompliSoundV2/NoiseIndoorsEnd"};
	self.noiseSounds.bigIndoors.Loop = {["Variations"] = 5,
	["Path"] = "SandstormSecurity.rte/Devices/Weapons/Handheld/GalilSAR/CompliSoundV2/NoiseBigIndoors"};
	self.noiseSounds.bigIndoors.End = {["Variations"] = 4,
	["Path"] = "SandstormSecurity.rte/Devices/Weapons/Handheld/GalilSAR/CompliSoundV2/NoiseBigIndoorsEnd"};
	
	self.reflectionSounds = {["Outdoors"] = nil};
	self.reflectionSounds.Outdoors = {["Variations"] = 3,
	["Path"] = "SandstormSecurity.rte/Devices/Weapons/Handheld/GalilSAR/CompliSoundV2/ReflectionOutdoors"};

	local Vector2 = Vector(0,-700); -- straight up

	local Vector2Left = Vector(0,-700):RadRotate(45*(math.pi/180));

	local Vector2Right = Vector(0,-700):RadRotate(-45*(math.pi/180));
	
	local Vector2SlightLeft = Vector(0,-700):RadRotate(22.5*(math.pi/180));

	local Vector2SlightRight = Vector(0,-700):RadRotate(-22.5*(math.pi/180));
	
	local Vector2FarLeft = Vector(0,-700):RadRotate(67.5*(math.pi/180));

	local Vector2FarRight = Vector(0,-700):RadRotate(-67.5*(math.pi/180));

	local Vector3 = Vector(0,0); -- dont need this but is needed as an arg

	local Vector4 = Vector(0,0); -- dont need this but is needed as an arg

	self.ray = SceneMan:CastObstacleRay(self.Pos, Vector2, Vector3, Vector4, self.RootID, self.Team, 128, 7);

	self.rayRight = SceneMan:CastObstacleRay(self.Pos, Vector2Right, Vector3, Vector4, self.RootID, self.Team, 128, 7);

	self.rayLeft = SceneMan:CastObstacleRay(self.Pos, Vector2Left, Vector3, Vector4, self.RootID, self.Team, 128, 7);
	
	self.raySlightRight = SceneMan:CastObstacleRay(self.Pos, Vector2SlightRight, Vector3, Vector4, self.RootID, self.Team, 128, 7);

	self.raySlightLeft = SceneMan:CastObstacleRay(self.Pos, Vector2SlightLeft, Vector3, Vector4, self.RootID, self.Team, 128, 7);
	
	self.rayFarRight = SceneMan:CastObstacleRay(self.Pos, Vector2FarRight, Vector3, Vector4, self.RootID, self.Team, 128, 7);

	self.rayFarLeft = SceneMan:CastObstacleRay(self.Pos, Vector2FarLeft, Vector3, Vector4, self.RootID, self.Team, 128, 7);
	
	self.rayTable = {self.ray, self.rayRight, self.rayLeft, self.raySlightRight, self.raySlightLeft, self.rayFarRight, self.rayFarLeft};
	
	self.rayTableAI = {self.ray};
	-- Sounds End --
	
	-- Animation --
	self.originalStanceOffset = Vector(self.StanceOffset.X * self.FlipFactor, self.StanceOffset.Y)
	self.originalSharpStanceOffset = Vector(self.SharpStanceOffset.X, self.SharpStanceOffset.Y)
	
	local animationReloadMagazine = {
		-- Phase 1 Mag Out
		{
			name = "Mag out",
			waitMS = 200,
			durationMS = 200,
			resetsTo = 1,
			
			magazine = false,
			
			angleStart = -5,
			angleEnd = -15,
			
			frameStart = 0,
			frameEnd = 0,
			
			offsetStart = Vector(0, 0),
			offsetEnd = Vector(0, 0),
			
			offsetSupportStart = Vector(0, 0),
			offsetSupportEnd = Vector(0, 0),
			
			--soundStart = "SandstormSecurity.rte/Devices/Weapons/Handheld/GalilSAR/Sounds/MagOut.wav",
			soundStart = {["Variations"] = 0,
			["Path"] = "SandstormSecurity.rte/Devices/Weapons/Handheld/GalilSAR/Sounds/MagOut.wav"},
			soundEnd = nil
		},
		-- Phase 2 Mag In
		{
			name = "Mag in",
			waitMS = 400,
			durationMS = 400,
			resetsTo = 2,
			
			magazine = true,
			
			angleStart = -15,
			angleEnd = 0,
			
			frameStart = 0,
			frameEnd = 0,
			
			offsetStart = Vector(0, 0),
			offsetEnd = Vector(0, 0),
			
			offsetSupportStart = Vector(0, 0),
			offsetSupportEnd = Vector(0, 0),
			
			soundStart = {["Variations"] = 0,
			["Path"] = "SandstormSecurity.rte/Devices/Weapons/Handheld/GalilSAR/Sounds/MagIn.wav"},
		},
	}
	local animationReloadChamber = {
		-- Phase 1 Bolt Prepare
		{
			name = "Bolt Grab",
			waitMS = 0,
			durationMS = 200,
			resetsTo = 1,
			
			magazine = true,
			
			angleStart = 0,
			angleEnd = 10,
			
			frameStart = 0,
			frameEnd = 0,
			
			offsetStart = Vector(0, 0),
			offsetEnd = Vector(0, 0),
			
			offsetSupportStart = Vector(0, 0),
			offsetSupportEnd = Vector(0, 0),
			
			soundStart = {["Variations"] = 0,
			["Path"] = "SandstormSecurity.rte/Devices/Weapons/Handheld/GalilSAR/Sounds/BoltGrab.wav"},
		},
		-- Phase 2 Bolt Back
		{
			name = "Bolt Back",
			waitMS = 0,
			durationMS = 200,
			resetsTo = 1,
			
			magazine = true,
			
			angleStart = 10,
			angleEnd = 0,
			
			frameStart = 0,
			frameEnd = 0,
			
			offsetStart = Vector(0, 0),
			offsetEnd = Vector(0, 0),
			
			offsetSupportStart = Vector(0, 0),
			offsetSupportEnd = Vector(0, 0),
			
			soundStart = {["Variations"] = 0,
			["Path"] = "SandstormSecurity.rte/Devices/Weapons/Handheld/GalilSAR/Sounds/BoltBack.wav"},
		},
		-- Phase 3 Bolt Forward
		{
			name = "Bolt Forward",
			waitMS = 0,
			durationMS = 300,
			resetsTo = 1,
			
			magazine = true,
			
			angleStart = 0,
			angleEnd = 16,
			
			frameStart = 0,
			frameEnd = 0,
			
			offsetStart = Vector(0, 0),
			offsetEnd = Vector(0, 0),
			
			offsetSupportStart = Vector(0, 0),
			offsetSupportEnd = Vector(0, 0),
			
			soundStart = {["Variations"] = 0,
			["Path"] = "SandstormSecurity.rte/Devices/Weapons/Handheld/GalilSAR/Sounds/BoltForward.wav"},
		},
	}
	-- 0 reload with chamber, 1 reload without chamber
	self.animationContainer = {animationReloadMagazine, animationReloadChamber} -- Animation container
	self.animationTimer = Timer();
	self.animationID = 0 -- Current animation's ID/index
	self.animationIsPlaying = false
	self.animationPhase = 0 -- Current animation's phase
	self.animationPhaseStart = false
	-- Animation End --
	
	self.rotation = 0
	self.rotationTarget = 0
	self.rotationInterpolation = 1 -- 0 instant, 1 smooth, 2 wiggly smooth
	self.rotationInterpolationSpeed = 50
	
	self.stance = Vector(0, 0)
	self.stanceTarget = Vector(0, 0)
	self.stanceInterpolation = 0 -- 0 instant, 1 smooth
	self.stanceInterpolationSpeed = 25
	
	-- Reload Logic --
	self.magazineName = "Fake Magazine GalilSAR"
	self.magazine = CreateAttachable(self.magazineName);
	self:AddAttachable(self.magazine);
	
	self.isReloading = false
	self.reloadDurationCalculated = false
	self.reloadChamber = false
	self.reloadMag = false
	self.chamber = false

	local actor = MovableMan:GetMOFromID(self.RootID);
	if actor and IsAHuman(actor) then
		self.parent = ToAHuman(actor);
	end
	
	if self.Magazine then
		self.ammoCounter = self.Magazine.RoundCount;
		self.ammoCounterMax = self.ammoCounter;
	else
		self.ammoCounter = 0;
		self.ammoCounterMax = 1;
		print("ERROR AUTO RIFLE MAGAZINE BULLSHITTERY!")
	end
	
end

function Update(self)

	local actor = MovableMan:GetMOFromID(self.RootID);
	if actor and IsAHuman(actor) then
		self.parent = ToAHuman(actor);
	else
		self.parent = nil;
	end
	
	if self.Magazine then
		self.ammoCounter = self.Magazine.RoundCount;
	end
	
	if self.FiredFrame then	
		if self.ammoCounter < 1 then
			self.chamber = true
		end
		self.reloadDurationCalculated = false
		
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
		
		local Effect = CreateMOSParticle("Tiny Smoke Ball 1", "Base.rte")
		Effect.Pos = self.MuzzlePos;
		Effect.Vel = (self.Vel + Vector(RangeRand(-20,20), RangeRand(-20,20)) + Vector(150*self.FlipFactor,0):RadRotate(self.RotAngle)) / 30
		MovableMan:AddParticle(Effect)

		local outdoorRays = 0;
		
		local indoorRays = 0;
		
		local bigIndoorRays = 0;

		if self.parent:IsPlayerControlled() then
			local Vector2 = Vector(0,-700); -- straight up
			local Vector2Left = Vector(0,-700):RadRotate(45*(math.pi/180));
			local Vector2Right = Vector(0,-700):RadRotate(-45*(math.pi/180));			
			local Vector2SlightLeft = Vector(0,-700):RadRotate(22.5*(math.pi/180));
			local Vector2SlightRight = Vector(0,-700):RadRotate(-22.5*(math.pi/180));		
			local Vector2FarLeft = Vector(0,-700):RadRotate(67.5*(math.pi/180));
			local Vector2FarRight = Vector(0,-700):RadRotate(-67.5*(math.pi/180));
			local Vector3 = Vector(0,0); -- dont need this but is needed as an arg
			local Vector4 = Vector(0,0); -- dont need this but is needed as an arg

			self.ray = SceneMan:CastObstacleRay(self.Pos, Vector2, Vector3, Vector4, self.RootID, self.Team, 128, 7);
			self.rayRight = SceneMan:CastObstacleRay(self.Pos, Vector2Right, Vector3, Vector4, self.RootID, self.Team, 128, 7);
			self.rayLeft = SceneMan:CastObstacleRay(self.Pos, Vector2Left, Vector3, Vector4, self.RootID, self.Team, 128, 7);			
			self.raySlightRight = SceneMan:CastObstacleRay(self.Pos, Vector2SlightRight, Vector3, Vector4, self.RootID, self.Team, 128, 7);
			self.raySlightLeft = SceneMan:CastObstacleRay(self.Pos, Vector2SlightLeft, Vector3, Vector4, self.RootID, self.Team, 128, 7);
			self.rayFarRight = SceneMan:CastObstacleRay(self.Pos, Vector2FarRight, Vector3, Vector4, self.RootID, self.Team, 128, 7);
			self.rayFarLeft = SceneMan:CastObstacleRay(self.Pos, Vector2FarLeft, Vector3, Vector4, self.RootID, self.Team, 128, 7);
			
			self.rayTable = {self.ray, self.rayRight, self.rayLeft, self.raySlightRight, self.raySlightLeft, self.rayFarRight, self.rayFarLeft};
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
			self.noiseSound = AudioMan:PlaySound(self.noiseSounds.Outdoors.Loop.Path .. math.random(1, self.noiseSounds.Outdoors.Loop.Variations) .. ".wav", self.Pos, -1, 0, 130, 1, 450, false);
			self.noiseEndSound = AudioMan:PlaySound(self.noiseSounds.Outdoors.End.Path .. math.random(1, self.noiseSounds.Outdoors.End.Variations) .. ".wav", self.Pos, -1, 0, 130, 1, 450, false);
			self.reflectionSound = AudioMan:PlaySound(self.reflectionSounds.Outdoors.Path .. math.random(1, self.reflectionSounds.Outdoors.Variations) .. ".wav", self.Pos, -1, 0, 130, 1, 450, false);
		elseif math.max(outdoorRays, bigIndoorRays, indoorRays) == indoorRays then
			self.noiseSound = AudioMan:PlaySound(self.noiseSounds.Indoors.Loop.Path .. math.random(1, self.noiseSounds.Indoors.Loop.Variations) .. ".wav", self.Pos, -1, 0, 130, 1, 450, false);
			self.noiseEndSound = AudioMan:PlaySound(self.noiseSounds.Indoors.End.Path .. math.random(1, self.noiseSounds.Indoors.End.Variations) .. ".wav", self.Pos, -1, 0, 130, 1, 450, false);
		else -- bigIndoor
			self.noiseSound = AudioMan:PlaySound(self.noiseSounds.bigIndoors.Loop.Path .. math.random(1, self.noiseSounds.bigIndoors.Loop.Variations) .. ".wav", self.Pos, -1, 0, 130, 1, 450, false);
			self.noiseEndSound = AudioMan:PlaySound(self.noiseSounds.bigIndoors.End.Path .. math.random(1, self.noiseSounds.bigIndoors.End.Variations) .. ".wav", self.Pos, -1, 0, 130, 1, 450, false);
		end

		
		if self.firstShot == true then
			self.firstShot = false;
			
			self.mechSound = AudioMan:PlaySound(self.mechSounds.Start.Path .. math.random(1, self.mechSounds.Start.Variations) .. ".wav", self.Pos, -1, 0, 130, 1, 450, false);
			self.addSound = AudioMan:PlaySound(self.addSounds.Start.Path .. math.random(1, self.addSounds.Start.Variations) .. ".wav", self.Pos, -1, 0, 130, 1, 450, false);
		else
			self.mechSound = AudioMan:PlaySound(self.mechSounds.Loop.Path .. math.random(1, self.mechSounds.Loop.Variations) .. ".wav", self.Pos, -1, 0, 130, 1, 450, false);
			self.addSound = AudioMan:PlaySound(self.addSounds.Loop.Path .. math.random(1, self.addSounds.Loop.Variations) .. ".wav", self.Pos, -1, 0, 130, 1, 450, false);
		end
		
		self.mechEndSound = AudioMan:PlaySound(self.mechSounds.End.Path .. math.random(1, self.mechSounds.End.Variations) .. ".wav", self.Pos, -1, 0, 130, 1, 450, false);
		
	end
	
	if self:IsReloading() then
		if not self.isReloading then
			self.reloadMag = true
			self.reloadChamber = false
			animationPlay(self, 1)
			
			self.isReloading = true
			self.reloadDurationCalculated = false
		end
		
		if self.reloadMag then
			--
		elseif self.chamber and not self.reloadChamber then
			--
			animationPlay(self, 2)
			self.reloadChamber = true
		end
	else
		if self.isReloading then
			self.isReloading = false
			self.reloadDurationCalculated = false
		end
		
		if not self.reloadDurationCalculated then
			local reloadMagazine = animationGetDuration(self, 1)
			local reloadChamber = animationGetDuration(self, 2)
			self.ReloadTime = reloadMagazine + (self.chamber and reloadChamber or 0) + TimerMan.DeltaTimeSecs * 2000
			self.reloadDurationCalculated = true
		end
	end
	
	if self.parent then
		if self.animationIsPlaying and self.animationPhase ~= 0 and self.animationID ~= 0 then
			local animation = self.animationContainer[self.animationID]
			local phase = animation[self.animationPhase]
			
			if self.animationID == 1 or self.animationID == 2 then
				self.parent:GetController():SetState(Controller.WEAPON_RELOAD,true);
			end
			
			if self.animationTimer:IsPastSimMS(phase.waitMS) then
			
				if not self.animationPhaseStart then
					if phase.soundStart then
						AudioMan:PlaySound(stringInsert(phase.soundStart.Path, phase.soundStart.Variations > 1 and math.random(1, phase.soundStart.Variations) or "", -5), self.Pos);
					end
					self.animationPhaseStart = true
					
					-- Drop/Attach Mag
					if phase.magazine == true and self.magazine == nil then
						self.magazine = CreateAttachable(self.magazineName);
						self:AddAttachable(self.magazine);
					elseif phase.magazine == false and self.magazine then
						--self:RemoveAttachable(self.magazine)
						self.magazine.JointStrength = -1
						self.magazine = nil
					end
				end
				
				-- Animate
				local factor = (self.animationTimer.ElapsedSimTimeMS - phase.waitMS) / phase.durationMS
				self.rotationTarget = (phase.angleStart * (1 - factor) + phase.angleEnd * factor) / 180 * math.pi
				self.stanceTarget = (phase.offsetStart * (1 - factor) + phase.offsetEnd * factor)
				
				local frameChange = phase.frameEnd - phase.frameStart
				self.Frame = math.floor(phase.frameStart + math.floor(frameChange * factor, 0.55))
				
				PrimitiveMan:DrawTextPrimitive(self.Pos + Vector(-20, 20), "sequence = "..self.animationPhase, true, 0);
				PrimitiveMan:DrawTextPrimitive(self.Pos + Vector(-20, 30), "factor = "..math.floor(factor * 100).."/100", true, 0);
				PrimitiveMan:DrawTextPrimitive(self.Pos + Vector(-20, 40), "animation = "..phase.name, true, 0);
				
				if self.animationTimer:IsPastSimMS(phase.durationMS + phase.waitMS) then
					if (self.animationPhase+1) <= #animation then
						self.animationPhase = self.animationPhase + 1
					else
						-- --
						if self.animationID == 1 then
							self.reloadMag = false
						elseif self.animationID == 2 then
							self.chamber = false
						end
						-- --
						
						self.animationID = 0
						self.animationPhase = 0
						self.animationIsPlaying = false
						self.rotationTarget = 0
						self.stanceTarget = Vector(0,0)
					end
					
					if phase.soundEnd then
						AudioMan:PlaySound(stringInsert(phase.soundEnd.Path, phase.soundEnd.Variations > 1 and math.random(1, phase.soundEnd.Variations) or "", -5), self.Pos);
					end
					
					self.animationPhaseStart = false
					self.animationTimer:Reset()
				end
			else
				PrimitiveMan:DrawTextPrimitive(self.Pos + Vector(-20, 20), "sequence = "..self.animationPhase, true, 0);
				PrimitiveMan:DrawTextPrimitive(self.Pos + Vector(-20, 30), "WAIT", true, 0);
				PrimitiveMan:DrawTextPrimitive(self.Pos + Vector(-20, 40), "animation = "..phase.name, true, 0);
			end
			self:Deactivate()
		end
	else
		self.animationTimer:Reset()
	end
	
	if self.parent then
		self.rotationTarget = self.rotationTarget
		if self.rotationInterpolation == 0 then
			self.rotation = self.rotationTarget * self.FlipFactor
		elseif self.rotationInterpolation == 1 then
			self.rotation = (self.rotation + self.rotationTarget * self.FlipFactor * TimerMan.DeltaTimeSecs * self.rotationInterpolationSpeed) / (1 + TimerMan.DeltaTimeSecs * self.rotationInterpolationSpeed);
		end
		if self.stanceInterpolation == 0 then
			self.stance = self.stanceTarget
		elseif self.stanceInterpolation == 1 then
			self.stance = (self.stance + self.stanceTarget * TimerMan.DeltaTimeSecs * self.stanceInterpolationSpeed) / (1 + TimerMan.DeltaTimeSecs * self.stanceInterpolationSpeed);
		end
		
		self.RotAngle = self.RotAngle + self.rotation
		local jointOffset = Vector(self.JointOffset.X * self.FlipFactor, self.JointOffset.Y):RadRotate(self.RotAngle);
		self.Pos = self.Pos - jointOffset + Vector(jointOffset.X, jointOffset.Y):RadRotate(-self.rotation);
		
		
		self.StanceOffset = self.originalStanceOffset + self.stance
		self.SharpStanceOffset = self.originalSharpStanceOffset + self.stance
	end
	
	if not self:IsActivated() then
		self.firstShot = true;
	end	

end