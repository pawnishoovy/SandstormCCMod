SecurityAIBehaviours = {};

function SecurityAIBehaviours.createSoundEffect(self, effectName, variations)
	if effectName ~= nil then
		self.soundEffect = AudioMan:PlaySound(effectName .. math.random(1, variations) .. ".wav", self.Pos, -1, 0, 130, 1, 400, false);	
	end
end

function SecurityAIBehaviours.createEmotion(self, emotion, priority, duration, canOverridePriority)
	if canOverridePriority == nil then
		canOverridePriority = false;
	end
	local usingPriority
	if canOverridePriority == false then
		usingPriority = priority - 1;
	else
		usingPriority = priority;
	end
	if emotion then
		
			self.emotionApplied = false; -- applied later in handleheadframes
			self.Emotion = emotion;
			if duration then
				self.emotionTimer:Reset();
				self.emotionDuration = duration;
			else
				self.emotionDuration = 0; -- will follow voiceSound length
			end
			self.lastEmotionPriority = priority;
	end
end

function SecurityAIBehaviours.createVoiceSoundEffect(self, effectName, variations, priority, emotion, canOverridePriority)
	if canOverridePriority == nil then
		canOverridePriority = false;
	end
	local usingPriority
	if canOverridePriority == false then
		usingPriority = priority - 1;
	else
		usingPriority = priority;
	end
	if self.Head and effectName ~= nil then
		if self.voiceSound then
			if self.voiceSound:IsBeingPlayed() then
				if self.lastPriority <= usingPriority then
					if emotion then
						SecurityAIBehaviours.createEmotion(self, emotion, priority, 0, canOverridePriority);
					end
					self.voiceSound:Stop();
					self.voiceSound = AudioMan:PlaySound(effectName .. math.random(1, variations) .. ".wav", self.Pos, -1, 0, 130, 1, 450, false);
					self.lastPriority = usingPriority;
					return true;
				end
			else
				if emotion then
					SecurityAIBehaviours.createEmotion(self, emotion, priority, 0, canOverridePriority);
				end
				self.voiceSound = AudioMan:PlaySound(effectName .. math.random(1, variations) .. ".wav", self.Pos, -1, 0, 130, 1, 450, false);
				self.lastPriority = priority;
				return true;
			end
		else
			if emotion then
				SecurityAIBehaviours.createEmotion(self, emotion, priority, 0, canOverridePriority);
			end
			self.voiceSound = AudioMan:PlaySound(effectName .. math.random(1, variations) .. ".wav", self.Pos, -1, 0, 130, 1, 450, false);
			self.lastPriority = priority;
			return true;
		end
	end
end

function SecurityAIBehaviours.createExertionSoundEffect(self)
	if self.Stamina < 20 then
		self.exertionSound = self.voiceSounds.seriousExertion
		self.exertionSoundVar = self.voiceSoundVariations.seriousExertion
		
		-- experimental
		SecurityAIBehaviours.createEmotion(self, 2, 1, 700);
	elseif self.Stamina < 65 then
		self.exertionSound = self.voiceSounds.Exertion
		self.exertionSoundVar = self.voiceSoundVariations.Exertion
		
		-- experimental
		if math.random(1,4) < 2 then
			SecurityAIBehaviours.createEmotion(self, 2, 1, 600);
		end
	else
		self.exertionSound = nil
		self.exertionSoundVar = nil
	end
	if (self.exertionSound) and (self.exertionSoundTimer:IsPastSimMS(3000)) then
		self.exertionSoundTimer:Reset();
		if (self.Head) then
			if self.voiceSound then
				if not self.voiceSound:IsBeingPlayed()then
					self.voiceSound = AudioMan:PlaySound(self.exertionSound .. math.random(1, self.exertionSoundVar) .. ".wav", self.Pos, -1, 0, 130, 1, 450, false);
					self.lastPriority = 0;
				end
			else
				self.voiceSound = AudioMan:PlaySound(self.exertionSound .. math.random(1, self.exertionSoundVar) .. ".wav", self.Pos, -1, 0, 130, 1, 450, false);
				self.lastPriority = 0;
			end
		end
	end
end

function SecurityAIBehaviours.handleDeadAirAndFalling(self)
	-- self.altitude = SceneMan:FindAltitude(self.Pos, 100, 3);
	
	-- if (self.TravelImpulse.Magnitude > self.ImpulseDamageThreshold/3) then
		-- self.impactSound = AudioMan:PlaySound("SandstormSecurity.rte/Actors/Sounds/DeathBodyImpact" .. math.random(1, 5) .. ".wav", self.Pos);
		-- SecurityAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.bodyImpactGrunt, self.voiceSoundVariations.bodyImpactGrunt, 2)
	-- end
	
	-- if (self.wasInAir and self.altitude < 25) then
		-- self.fallingScreamCount = 0;
		-- self.wasInAir = false;
		-- if self.voiceSound and self.voiceSound:IsBeingPlayed() then
			-- self.voiceSound:Stop(-1);
		-- end
		-- SecurityAIBehaviours.createVoiceSoundEffect(self, "SandstormSecurity.rte/Actors/Sounds/DeathImpact", 10, 2)
	-- elseif (self.wasInAir) then
		-- if SecurityAIBehaviours.createVoiceSoundEffect(self, "SandstormSecurity.rte/Actors/Sounds/DeathFalling", 10, 2) then
			-- self.fallingScreamCount = self.fallingScreamCount + 1;
		-- end
		-- -- if we scream two times in the same fall to completion, we're probably stuck somewhere.
		-- -- let's get unstuck so we don't keep spamming
		-- if (self.fallingScreamCount >= 3) and (self.Vel.Magnitude < 5) then
			-- self.Vel = self.Vel + Vector(math.random(self.fallingScreamCount*-1, self.fallingScreamCount),
										-- math.random(self.fallingScreamCount*-1, self.fallingScreamCount));
		-- end
	-- end
	
	-- if self.altitude > 60 then
		-- self.wasInAir = true;
	-- end
end

function SecurityAIBehaviours.handleLiveAirAndFalling(self)
	--PrimitiveMan:DrawTextPrimitive(self.Pos + Vector(-20, 20), "vel = ".. math.floor(self.Vel.Y), true, 0);
	-- Lose balance while falling
	if self.Vel.Y > 15.5 and self.Status == 0 then
		self.Status = 1
		SecurityAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.Pain, self.voiceSoundVariations.Pain, 5, 2, true)
		SecurityAIBehaviours.createEmotion(self, 4, 4, 1000);
		--HitWhatTerrMaterial
	end

	if (self.TravelImpulse.Magnitude > self.ImpulseDamageThreshold) then
		SecurityAIBehaviours.createSoundEffect(self, self.miscSounds.Impact, self.miscSoundVariations.Impact);
		local damage = (self.TravelImpulse.Magnitude - self.ImpulseDamageThreshold) / 50
		--print(damage)
		self.Health = self.Health - damage
		SecurityAIBehaviours.createEmotion(self, 4, 4, 1000);
	end
	
	if (self.wasInAir and self.Vel.Y < 10) then
		self.altitude = SceneMan:FindAltitude(self.Pos, 100, 3);
		if self.altitude < 25 then
			--self.wasInAir = false;
			if self.Status == 0 then
				-- SecurityAIBehaviours.createSoundEffect(self, self.movementSounds.Land, self.movementSoundVariations.Land);
				-- if self.footPixel ~= 0 then
					-- if self.terrainProneSounds[self.footPixel] ~= nil then
						-- SecurityAIBehaviours.createSoundEffect(self, self.terrainLandSounds[self.footPixel], self.terrainLandSoundVariations[self.footPixel]);
					-- else
						-- SecurityAIBehaviours.createSoundEffect(self, self.terrainLandSounds[12], self.terrainLandSoundVariations[12]); -- default concrete
					-- end
				-- end
				-- SecurityAIBehaviours.createExertionSoundEffect(self);
				-- self.Stamina = self.Stamina - 6;
			else
				SecurityAIBehaviours.createSoundEffect(self, self.movementSounds.Fall, self.movementSoundVariations.Fall);
				if self.terrainCollided then
					if self.terrainImpactSounds[self.terrainCollidedWith] ~= nil then
						SecurityAIBehaviours.createSoundEffect(self, self.terrainImpactSounds[self.terrainCollidedWith], self.terrainImpactSoundVariations[self.terrainCollidedWith]);
					else
						SecurityAIBehaviours.createSoundEffect(self, self.terrainImpactSounds[12], self.terrainImpactSoundVariations[12]); -- default concrete
					end
					self.terrainCollided = false;
				end
				SecurityAIBehaviours.createExertionSoundEffect(self);
				self.Stamina = self.Stamina - 15;
			end
		end
	end
	
	if self.Vel.Y > 10 then
		self.wasInAir = true;
	else
		self.wasInAir = false;
	end
end

function SecurityAIBehaviours.handleMovement(self)

	local cont = self:GetController()
	
	local crouching = cont:IsState(Controller.BODY_CROUCH)
	local moving = cont:IsState(Controller.MOVE_LEFT) or self:GetController():IsState(Controller.MOVE_RIGHT);
	
	-- Leg Collision Detection system
    --local i = 0
    for i = 1, 2 do
        --local foot = self.feet[i]
		local foot = nil
        --local leg = self.legs[i]
		if i == 1 then
			foot = self.FGFoot 
		else
			foot = self.BGFoot 
		end
        --if foot ~= nil and leg ~= nil and leg.ID ~= rte.NoMOID then
		if foot ~= nil then
            local footPos = foot.Pos				
			local mat = nil
			local offsetY = foot.Radius * 0.7 - math.max(self.Vel.Y * FrameMan.PPM * TimerMan.DeltaTimeSecs, 0) * 4
			-- Walk mode (Precise)
			if cont:IsState(Controller.MOVE_LEFT) == true or cont:IsState(Controller.MOVE_RIGHT) == true then
				local maxi = 2
				for i = 0, maxi do
					local offsetX = 4
					local pixelPos = footPos + Vector(-offsetX + offsetX / maxi * i * 2, offsetY)
					self.footPixel = SceneMan:GetTerrMatter(pixelPos.X, pixelPos.Y)
					
					if self.footPixel ~= 0 then
						mat = SceneMan:GetMaterialFromID(self.footPixel)
					--	PrimitiveMan:DrawLinePrimitive(pixelPos, pixelPos, 162);
					--else
					--	PrimitiveMan:DrawLinePrimitive(pixelPos, pixelPos, 13);
					end
				end
			else
				local offsetX = 4
				local pixelPos = footPos + Vector(0, offsetY)
				self.footPixel = SceneMan:GetTerrMatter(pixelPos.X, pixelPos.Y)
				if self.footPixel ~= 0 then
					mat = SceneMan:GetMaterialFromID(self.footPixel)
				--	PrimitiveMan:DrawLinePrimitive(pixelPos, pixelPos, 162);
				--else
				--	PrimitiveMan:DrawLinePrimitive(pixelPos, pixelPos, 13);
				end
			end
			
			local movement = (cont:IsState(Controller.MOVE_LEFT) == true or cont:IsState(Controller.MOVE_RIGHT) == true or self.Vel.Magnitude > 3)
			if not (crouching) then -- don't do any footstep sounds if we're crawling
				if mat ~= nil then
					--PrimitiveMan:DrawTextPrimitive(footPos, mat.PresetName, true, 0);
					if self.feetContact[i] == false then
						self.feetContact[i] = true
						if self.feetTimers[i]:IsPastSimMS(self.footstepTime) and movement then						
							local terrainStepSoundEntryToUse = self.terrainStepSounds.Walk[self.footPixel] and self.footPixel or 12;
							local sprintOrWalkSoundEffects = {
							[false] = {
							{self.movementSounds.walkPost, self.movementSoundVariations.walkPost},
							{self.terrainStepSounds.Walk[terrainStepSoundEntryToUse], self.terrainStepSoundVariations.Walk[terrainStepSoundEntryToUse]}
							},
							[true] = {
							{self.movementSounds.sprintPost, self.movementSoundVariations.sprintPost},
							{self.terrainStepSounds.Sprint[terrainStepSoundEntryToUse], self.terrainStepSoundVariations.Sprint[terrainStepSoundEntryToUse]}
							}
							};
							for _, soundEffect in pairs(sprintOrWalkSoundEffects [self.isSprinting]) do
							  SecurityAIBehaviours.createSoundEffect(self, soundEffect[1], soundEffect[2]);
							end							
							
							self.feetTimers[i]:Reset()
						end
					end
				else
					if self.feetContact[i] == true then
						self.feetContact[i] = false
						if self.feetTimers[i]:IsPastSimMS(self.footstepTime) and movement then
							if self.isSprinting == true then
								SecurityAIBehaviours.createSoundEffect(self, self.movementSounds.sprintPre, self.movementSoundVariations.sprintPre); -- messy, but we put it here to save on isSprinting check
							else
								SecurityAIBehaviours.createSoundEffect(self, self.movementSounds.walkPre, self.movementSoundVariations.walkPre); -- messy, but we put it here to save on isSprinting check
							end
							self.feetTimers[i]:Reset()
						end
					end
				end
			end
			-- DEBUG CROSS
			--for i = 0, 3 do
			--	local offset = Vector(2,0):RadRotate(math.pi * 0.5 * i)
			--	PrimitiveMan:DrawLinePrimitive(footPos, footPos + offset, 13);
			--end
		end
	end
	
	-- Custom Jump
	if cont:IsState(Controller.BODY_JUMPSTART) == true and cont:IsState(Controller.BODY_CROUCH) == false and self.jumpTimer:IsPastSimMS(self.jumpDelay) and not self.isJumping then
		if self.feetContact[1] == true or self.feetContact[2] == true then
			local jumpVec = Vector(0,-3.5)
			local jumpWalkX = 3
			if cont:IsState(Controller.MOVE_LEFT) == true then
				jumpVec.X = -jumpWalkX
			elseif cont:IsState(Controller.MOVE_RIGHT) == true then
				jumpVec.X = jumpWalkX
			end
			SecurityAIBehaviours.createSoundEffect(self, self.movementSounds.Jump, self.movementSoundVariations.Jump);
			if self.terrainJumpSounds[self.footPixel] ~= nil then
				SecurityAIBehaviours.createSoundEffect(self, self.terrainJumpSounds[self.footPixel], self.terrainJumpSoundVariations[self.footPixel]);
			else
				SecurityAIBehaviours.createSoundEffect(self, self.terrainJumpSounds[12], self.terrainJumpSoundVariations[12]); -- default concrete
			end
			if math.random(0, 100) < 80 then
				SecurityAIBehaviours.createExertionSoundEffect(self);
			end
			self.Stamina = self.Stamina - 10;
			--self.Vel = self.Vel + Vector(0 ,-5)
			if math.abs(self.Vel.X) > jumpWalkX * 2.0 then
				self.Vel = Vector(self.Vel.X, self.Vel.Y + jumpVec.Y)
			else
				self.Vel = Vector(self.Vel.X + jumpVec.X, self.Vel.Y + jumpVec.Y)
			end
			self.isJumping = true
			self.jumpTimer:Reset()
			self.jumpStop:Reset()
			self.jumpBoost:Reset()
		end
	elseif self.isJumping then
		if (self.feetContact[1] == true or self.feetContact[2] == true) and self.jumpStop:IsPastSimMS(100) then
			self.isJumping = false
			if self.Vel.Y > 0 then
				SecurityAIBehaviours.createSoundEffect(self, self.movementSounds.Land, self.movementSoundVariations.Land);
				if self.terrainProneSounds[self.footPixel] ~= nil then
					SecurityAIBehaviours.createSoundEffect(self, self.terrainLandSounds[self.footPixel], self.terrainLandSoundVariations[self.footPixel]);
				else
					SecurityAIBehaviours.createSoundEffect(self, self.terrainLandSounds[12], self.terrainLandSoundVariations[12]); -- default concrete
				end
			end
		else
			if cont:IsState(Controller.BODY_JUMP) == true and not self.jumpBoost:IsPastSimMS(200) then
				self.Vel = self.Vel - SceneMan.GlobalAcc * TimerMan.DeltaTimeSecs * 1.0 -- Stop the gravity
			end
			--cont:SetState(Controller.MOVE_LEFT,false);
			--cont:SetState(Controller.MOVE_RIGHT,false);
			--if cont:IsState(Controller.MOVE_LEFT) == false and cont:IsState(Controller.MOVE_LEFT) == false then
			--	cont:SetState(Controller.BODY_CROUCH,true);
			--end
		end
	end
	-- DEBUG
	--[[
	PrimitiveMan:DrawTextPrimitive(Vector(self.Pos.X,self.Pos.Y), self.isJumping and "jumping" or "not jumping", true, 0);
	--]]
	
	-- Sprint
	local input = ((cont:IsState(Controller.MOVE_LEFT) == true or cont:IsState(Controller.MOVE_RIGHT) == true) and not (cont:IsState(Controller.MOVE_LEFT) == true and cont:IsState(Controller.MOVE_RIGHT) == true))
	
	-- Double Tap
	if self.doubleTapState == 0 then
		if input == true then
			self.doubleTapTimer:Reset()
		else
			self.doubleTapState = 1
		end
	elseif self.doubleTapState == 1 then
		if self.doubleTapTimer:IsPastSimMS(100) then
			self.doubleTapState = 0
		elseif input == true then
			self.isSprinting = true
			self.doubleTapState = 0
		end
	end
	
	--isSprinting
	self.aiSprint = not self:IsPlayerControlled() and (cont:IsState(Controller.MOVE_LEFT) == true or cont:IsState(Controller.MOVE_RIGHT) == true)
	
	--local movementMultiplier = 1
	local movementMultiplier = 1 - (0.2 * (1 - (self.Stamina / 100)))
	local walkMultiplier = 0.65 * movementMultiplier
	--local sprintMultiplier = 0.5 * movementMultiplier
	local sprintMultiplier = 0.65 * movementMultiplier - (0.1 * (1 - (self.Stamina / 100)))
	if self.isSprinting or aiSprint then
		self.footstepTime = self.sprintFootstepTime;
		if input == false then
			self.isSprinting = false
		end
		self:SetLimbPathSpeed(0, self.limbPathDefaultSpeed0 * self.sprintMultiplier * sprintMultiplier);
		self:SetLimbPathSpeed(1, self.limbPathDefaultSpeed1 * self.sprintMultiplier * sprintMultiplier);
		self:SetLimbPathSpeed(2, self.limbPathDefaultSpeed2 * self.sprintMultiplier * sprintMultiplier);
		self.LimbPathPushForce = self.limbPathDefaultPushForce * self.sprintPushForceDenominator * sprintMultiplier
		self.Stamina = math.max(0, self.Stamina - TimerMan.DeltaTimeSecs * 3.5)
	else
		self.footstepTime = self.walkFootstepTime;
		self:SetLimbPathSpeed(0, self.limbPathDefaultSpeed0 * walkMultiplier);
		self:SetLimbPathSpeed(1, self.limbPathDefaultSpeed1 * walkMultiplier);
		self:SetLimbPathSpeed(2, self.limbPathDefaultSpeed2 * walkMultiplier);
		self.LimbPathPushForce = self.limbPathDefaultPushForce * walkMultiplier
	end
	-- DEBUG
	--[[
	for i = 0, 2 do
		PrimitiveMan:DrawTextPrimitive(Vector(self.Pos.X,self.Pos.Y + 10 * i), "speed"..i..": "..self:GetLimbPathSpeed(i), true, 0)
	end
	
	PrimitiveMan:DrawTextPrimitive(Vector(self.Pos.X,self.Pos.Y + 10), self.isSprinting and "sprinting" or "not sprinting", true, 0)
	PrimitiveMan:DrawTextPrimitive(Vector(self.Pos.X,self.Pos.Y + 10), input and "input" or "no input", true, 0)
	PrimitiveMan:DrawTextPrimitive(Vector(self.Pos.X,self.Pos.Y + 20), "state: "..self.doubleTapState, true, 0)
	PrimitiveMan:DrawTextPrimitive(Vector(self.Pos.X,self.Pos.Y + 30), "time: "..self.doubleTapTimer.ElapsedSimTimeMS, true, 0)
	]]
	
	if (crouching) then
		if (moving) then
			if self.terrainCollided == true and self.proneTerrainPlayed == false then
				if self.terrainProneSounds[self.terrainCollidedWith] ~= nil then
					SecurityAIBehaviours.createSoundEffect(self, self.terrainProneSounds[self.terrainCollidedWith], self.terrainProneSoundVariations[self.terrainCollidedWith]);
				else
					SecurityAIBehaviours.createSoundEffect(self, self.terrainProneSounds[12], self.terrainProneSoundVariations[12]); -- default concrete
				end
				self.proneTerrainPlayed = true;
			end
			if (self.moveSoundWalkTimer:IsPastSimMS(700)) then
				SecurityAIBehaviours.createSoundEffect(self, self.movementSounds.Crawl, self.movementSoundVariations.Crawl);
				if self.footPixel ~= 0 then
					if self.terrainCrawlSounds[self.footPixel] ~= nil then
						SecurityAIBehaviours.createSoundEffect(self, self.terrainCrawlSounds[self.footPixel], self.terrainCrawlSoundVariations[self.footPixel]);
					else
						SecurityAIBehaviours.createSoundEffect(self, self.terrainCrawlSounds[12], self.terrainCrawlSoundVariations[12]); -- default concrete
					end
				end
				self.moveSoundWalkTimer:Reset();
			end
		end
		if (not self.wasCrouching and self.moveSoundTimer:IsPastSimMS(800)) then
			if (moving) then
				SecurityAIBehaviours.createSoundEffect(self, self.movementSounds.Sprint, self.movementSoundVariations.Sprint);
				if math.random(0, 100) < 80 then
					SecurityAIBehaviours.createExertionSoundEffect(self);
				end
				self.proneTerrainPlayed = false;
				self.Stamina = self.Stamina - 6;
			else
				SecurityAIBehaviours.createSoundEffect(self, self.movementSounds.Prone, self.movementSoundVariations.Prone);
			end
		end
	else
		if (self.wasCrouching and self.moveSoundTimer:IsPastSimMS(800)) then
			SecurityAIBehaviours.createSoundEffect(self, self.movementSounds.Stand, self.movementSoundVariations.Stand);
			self.moveSoundTimer:Reset();
			if math.random(0, 100) < 40 then
				SecurityAIBehaviours.createExertionSoundEffect(self);
				self.Stamina = self.Stamina - 2;
			end
		end
	end
	
	-- Experimental camera
	--local camDif = SceneMan:ShortestDistance((self.Pos), (self.Head.Pos + self.Head.Vel * rte.PxTravelledPerFrame),SceneMan.SceneWrapsX)
	--camDif = Vector(camDif.X, camDif.Y * 2.0) + Vector(0,5)
	--self.ViewPoint = self.ViewPoint + camDif
	
	self.wasCrouching = crouching;
	self.wasMoving = moving;
end

function SecurityAIBehaviours.handleHealth(self)

	local healthTimerReady = self.healthUpdateTimer:IsPastSimMS(750);
	local wasLightlyInjured = self.Health < (self.oldHealth - 5);
	local wasInjured = self.Health < (self.oldHealth - 25);
	local wasHeavilyInjured = self.Health < (self.oldHealth - 50);
	
	if (healthTimerReady or wasLightlyInjured or wasInjured or wasHeavilyInjured) then
		self.oldHealth = self.Health;
		self.healthUpdateTimer:Reset();	
		
		if wasHeavilyInjured then
			self.Suppression = self.Suppression + 100;
			self.Status = 1
		elseif wasInjured then
			self.Suppression = self.Suppression + 50;
		elseif wasLightlyInjured then
			SecurityAIBehaviours.createEmotion(self, 2, 4, 500);
			self.Suppression = self.Suppression + math.random(9,13);
		end
		
		if (wasInjured or wasHeavilyInjured) and self.Head then
			if self.Health > 0 then
				SecurityAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.Pain, self.voiceSoundVariations.Pain, 5, 2, true)
				self.Stamina = self.Stamina - 25;
			else
				SecurityAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.seriousDeath, self.voiceSoundVariations.seriousDeath, 10, 4)
				self.seriousDeath = true;
				self.deathSoundPlayed = true;
				for actor in MovableMan.Actors do
					if actor.Team == self.Team then
						local d = SceneMan:ShortestDistance(actor.Pos, self.Pos, true).Magnitude;
						if d < 300 then
							local strength = SceneMan:CastStrengthSumRay(self.Pos, actor.Pos, 0, 128);
							if strength < 500 and math.random(1, 100) < 65 then
								actor:SetNumberValue("Sandstorm Friendly Down", 0)
								break;  -- first come first serve
							else
								if IsAHuman(actor) and actor.Head then -- if it is a human check for head
									local strength = SceneMan:CastStrengthSumRay(self.Pos, ToAHuman(actor).Head.Pos, 0, 128);	
									if strength < 500 and math.random(1, 100) < 65 then		
										actor:SetNumberValue("Sandstorm Friendly Down", 0)
										break; -- first come first serve
									end
								end
							end
						end
					end
				end
				self.Dying = true;
				self.headWounds = self.Head.WoundCount
			end
		end
	end
	
	--experimental dying
	
	if (self.allowedToDie == false and self.Health <= 0) or (self.Dying == true) then
		self.Health = 1;
		self.Dying = true;
		if self.Head then
			local wounds = self.Head.WoundCount;
			self.headWounds = wounds; -- to save variable rather than pointer to WoundCount
		end
		
		-- ??? Free performance ???
		for i = 1, self.InventorySize do
			local item = self:Inventory();
			if item then
				item.ToDelete = true
			end
			self:SwapNextInventory(item, true);
		end
		if math.random(1,2) < 2 then
			self:GetController():SetState(Controller.WEAPON_DROP,true);
		end
	end
		
	
	
end

function SecurityAIBehaviours.handleStaminaAndSuppression(self)
	
	local blinkTimerReady = self.blinkTimer:IsPastSimMS(self.blinkDelay);
	local staminaTimerReady = self.staminaUpdateTimer:IsPastSimMS(700);
	local suppressionTimerReady = self.suppressionUpdateTimer:IsPastSimMS(1500);
	
	if (blinkTimerReady) and (not self.Suppressed) and self.Head then
		if self.Head.Frame == self.baseHeadFrame then
			SecurityAIBehaviours.createEmotion(self, 1, 0, 100);
			self.blinkTimer:Reset();
			self.blinkDelay = math.random(5000, 11000);
		end
	end
	
	if (staminaTimerReady) then
	
		if self:IsPlayerControlled() then
			if self.Stamina < 20 then
				if self.Inhale then
					SecurityAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.inhaleHeavy, self.voiceSoundVariations.inhaleHeavy, 0);
					self.Inhale = false;
				else
					SecurityAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.exhaleHeavy, self.voiceSoundVariations.exhaleHeavy, 0);
					self.Inhale = true;
					-- experimental
					SecurityAIBehaviours.createEmotion(self, 1, 0, 300);
				end		
			elseif self.Stamina < 50 then	
				if self.Inhale then
					SecurityAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.inhaleMedium, self.voiceSoundVariations.inhaleMedium, 0);
					self.Inhale = false;
				else
					SecurityAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.exhaleMedium, self.voiceSoundVariations.exhaleMedium, 0);
					self.Inhale = true;
					-- experimental
					SecurityAIBehaviours.createEmotion(self, 1, 0, 200);
				end		
			elseif self.Stamina < 70 then	
				if self.Inhale then
					SecurityAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.inhaleLight, self.voiceSoundVariations.inhaleLight, 0);
					self.Inhale = false;
				else
					SecurityAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.exhaleLight, self.voiceSoundVariations.exhaleLight, 0);
					self.Inhale = true;
				end
			end
		end
	
		self.Stamina = math.max(self.Stamina, 0)
		if (not self.isSprinting) and (not self.aiSprint) then
			if self.Stamina < 20 then
				self.Stamina = self.Stamina + 5;
			elseif self.Stamina < 100 then
				self.Stamina = self.Stamina + 4;
			end
		end
		self.Stamina = math.min(self.Stamina, 100)
		self.staminaUpdateTimer:Reset();
	end
	if (suppressionTimerReady) then
		self.Suppression = math.min(self.Suppression, 100)
		if self.Suppression > 80 then
			self.Suppression = self.Suppression - 15;
		elseif self.Suppression > 0 then
			self.Suppression = self.Suppression - 10;
		end
		self.Suppression = math.max(self.Suppression, 0)
		self.suppressionUpdateTimer:Reset();
		if self.Suppression > 50 then
			self.Suppressed = true;
			if self.suppressedVoicelineTimer:IsPastSimMS(self.suppressedVoicelineDelay) then
				SecurityAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.Suppressed, self.voiceSoundVariations.Suppressed, 4, 2, true);
				self.suppressedVoicelineTimer:Reset();
			end				
		else
			self.Suppressed = false;
		end
	end
end

function SecurityAIBehaviours.handleHeadFrames(self)
	if not self.Head then return end
	if self.Emotion and self.emotionApplied ~= true and self.Head then
		self.Head.Frame = self.baseHeadFrame + self.Emotion;
		self.emotionApplied = true;
	end
		
		
	if self.emotionDuration > 0 and self.emotionTimer:IsPastSimMS(self.emotionDuration) then
		if (self.Suppressed or self.Suppressing) then
			self.Head.Frame = self.baseHeadFrame + 2;
		else
			self.Head.Frame = self.baseHeadFrame;
		end
	elseif (self.emotionDuration == 0) and ((not self.voiceSound or not self.voiceSound:IsBeingPlayed())) then
		-- if suppressed OR suppressing base emotion is angry
		if (self.Suppressed or self.Suppressing) then
			self.Head.Frame = self.baseHeadFrame + 2;
		else
			self.Head.Frame = self.baseHeadFrame;
		end
	end

end


function SecurityAIBehaviours.handleVoicelines(self)

	-- this is the bigun
	
	-- DEVICE RELATED VOICELINES
	
	if self.EquippedItem then
	
		-- RELOADING, SUPPRESSING

		if (IsHDFirearm(self.EquippedItem) and self.EquippedItem:IsInGroup("Weapons")) then
			local gun = ToHDFirearm(self.EquippedItem);
			local reloading = gun:IsReloading();
			
			if gun:IsActivated() then
				if gun.FiredFrame then
					self.gunShotCounter = self.gunShotCounter + 1;
				end
				if self.gunShotCounter > 30 then
					self.Suppressing = true;
				else
					self.Suppressing = false;
				end
				if self.gunShotCounter > 60 and self.suppressingVoicelineTimer:IsPastSimMS(self.suppressingVoicelineDelay) then
					SecurityAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.Suppressing, self.voiceSoundVariations.Suppressing, 6, 3, true);
					self.suppressingVoicelineTimer:Reset();
				end
			else
				self.gunShotCounter = 0;
				self.Suppressing = false;
			end			
			
			if (reloading) then
				if (self.reloadVoicelinePlayed ~= true) then
					if (self.Suppressed) then
						if (math.random(1, 100) < 85) then
							SecurityAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.suppressedReload, self.voiceSoundVariations.suppressedReload, 5, 2, true);
						end
					elseif (math.random(1, 100) < 50) then
						SecurityAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.Reload, self.voiceSoundVariations.Reload, 4);
					end
					self.reloadVoicelinePlayed = true;
				end
			else
				self.reloadVoicelinePlayed = false;
			end
		else
			self.reloadVoicelinePlayed = false;
		end
		
		-- END RELOADING, SUPPRESSING
		
		-- THROWING GRENADES
	
		if (IsTDExplosive(self.EquippedItem)) then
			local activated = self:GetController():IsState(Controller.WEAPON_FIRE)
			if (activated) then
			
			
				-- very messy detection due to string.find being case sensitive
				
				if (self.throwGrenadeVoicelinePlayed ~= true) then
					if (string.find(self.EquippedItem.PresetName, "Stun")) or (string.find(self.EquippedItem.PresetName, "Flash")) or (string.find(self.EquippedItem.PresetName, "stun")) or (string.find(self.EquippedItem.PresetName, "flash")) or
					(ToTDExplosive(self.EquippedItem):NumberValueExists("Sandstorm Flashbang Grenade")) then
						if (self.Suppressed) then
							SecurityAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.suppressedFlashOut, self.voiceSoundVariations.suppressedFlashOut, 5, 3);
						else
							SecurityAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.flashOut, self.voiceSoundVariations.flashOut, 5);
						end
					elseif (string.find(self.EquippedItem.PresetName, "Frag")) or (string.find(self.EquippedItem.PresetName, "HE")) or (string.find(self.EquippedItem.PresetName, "frag")) or 
					(ToTDExplosive(self.EquippedItem):NumberValueExists("Sandstorm Frag Grenade")) then
						if (self.Suppressed) then
							SecurityAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.suppressedFragOut, self.voiceSoundVariations.suppressedFragOut, 5, 3);
						else
							SecurityAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.fragOut, self.voiceSoundVariations.fragOut, 5);
						end
					elseif (string.find(self.EquippedItem.PresetName, "Incendiary")) or (string.find(self.EquippedItem.PresetName, "Flame")) or (string.find(self.EquippedItem.PresetName, "incendiary")) or (string.find(self.EquippedItem.PresetName, "flame")) or (ToTDExplosive(self.EquippedItem):NumberValueExists("Sandstorm Incendiary Grenade")) then
						if (self.Suppressed) then
							SecurityAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.suppressedIncendiaryOut, self.voiceSoundVariations.suppressedIncendiaryOut, 5, 3);
						else
							SecurityAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.incendiaryOut, self.voiceSoundVariations.incendiaryOut, 5);
						end
					elseif (string.find(self.EquippedItem.PresetName, "Mine")) or (string.find(self.EquippedItem.PresetName, "Claymore")) or (string.find(self.EquippedItem.PresetName, "mine")) or (string.find(self.EquippedItem.PresetName, "claymore")) or (ToTDExplosive(self.EquippedItem):NumberValueExists("Sandstorm Mine")) then
						if (self.Suppressed) then
							SecurityAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.suppressedMineOut, self.voiceSoundVariations.suppressedMineOut, 5, 3);
						else
							SecurityAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.mineOut, self.voiceSoundVariations.mineOut, 5);
						end
					elseif (string.find(self.EquippedItem.PresetName, "Molotov")) or (string.find(self.EquippedItem.PresetName, "Bottle Bomb")) or (string.find(self.EquippedItem.PresetName, "molotov")) or (string.find(self.EquippedItem.PresetName, "bottle bomb")) or (ToTDExplosive(self.EquippedItem):NumberValueExists("Sandstorm Molotov")) then
						if (self.Suppressed) then
							SecurityAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.suppressedMolotovOut, self.voiceSoundVariations.suppressedMolotovOut, 5, 3);
						else
							SecurityAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.molotovOut, self.voiceSoundVariations.molotovOut, 5);
						end
					elseif (string.find(self.EquippedItem.PresetName, "Remote")) or (string.find(self.EquippedItem.PresetName, "C4")) or (string.find(self.EquippedItem.PresetName, "Timed")) or (string.find(self.EquippedItem.PresetName, "remote")) or (string.find(self.EquippedItem.PresetName, "c4")) or (string.find(self.EquippedItem.PresetName, "timed")) or (ToTDExplosive(self.EquippedItem):NumberValueExists("Sandstorm Remote Bomb")) then
						if (self.Suppressed) then
							SecurityAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.suppressedRemoteOut, self.voiceSoundVariations.suppressedRemoteOut, 5, 3);
						else
							SecurityAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.remoteOut, self.voiceSoundVariations.remoteOut, 5);
						end
					elseif (string.find(self.EquippedItem.PresetName, "Smoke")) or (string.find(self.EquippedItem.PresetName, "smoke")) or (ToTDExplosive(self.EquippedItem):NumberValueExists("Sandstorm Smoke Grenade")) then
						if (self.Suppressed) then
							SecurityAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.suppressedSmokeOut, self.voiceSoundVariations.suppressedSmokeOut, 5, 3);
						else
							SecurityAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.smokeOut, self.voiceSoundVariations.smokeOut, 5);
						end
					else -- default frag nade
						if (self.Suppressed) then
							SecurityAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.suppressedFragOut, self.voiceSoundVariations.suppressedFragOut, 5, 3);
						else
							SecurityAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.fragOut, self.voiceSoundVariations.fragOut, 5);
						end
					end
					self.throwGrenadeVoicelinePlayed = true;
				end
			else
				self.throwGrenadeVoicelinePlayed = false;
			end
		else
			self.throwGrenadeVoicelinePlayed = false;
		end
	end
	
	-- DEATH REACTIONS
	-- the dying actor actually lets us know whether to play a voiceline through 1-time detection and value-setting.
	-- 0 = normal, 1 = gruesome
	
	if self:NumberValueExists("Sandstorm Friendly Down") then
		self.Suppression = self.Suppression + 25;
		if self.friendlyDownTimer:IsPastSimMS(self.friendlyDownDelay) then
			local Sounds = self:GetNumberValue("Sandstorm Friendly Down") == 0 and self.voiceSounds.witnessDeath or self.voiceSounds.witnessGruesomeDeath
			local Vars = self:GetNumberValue("Sandstorm Friendly Down") == 0 and self.voiceSoundVariations.witnessDeath or self.voiceSoundVariations.witnessGruesomeDeath
			
			SecurityAIBehaviours.createVoiceSoundEffect(self, Sounds, Vars, 5, 4, true);		
			self.friendlyDownTimer:Reset();
		end
		self:RemoveNumberValue("Sandstorm Friendly Down")
	end
		

end

function SecurityAIBehaviours.handleDying(self)

	self:GetController().Disabled = true;
	self.HUDVisible = false
	if self.allowedToDie == false then
		self.Health = 1;
		self.Status = 3;
	else
		if self.Head then
			self.Head.Frame = self.baseHeadFrame + 1; -- (+1: eyes closed. rest in peace grunt)
		end
		self.Health = -1;
		self.Status = 4;
	end


	if self.Head then
		if self.Head.WoundCount > self.headWounds then
			self.deathSoundPlayed = true;
			self.dyingSoundPlayed = true;
			if (self.voiceSound) and (self.voiceSound:IsBeingPlayed()) then
				self.voiceSound:Stop(-1);
			end
			self.allowedToDie = true;
		end
		if self.deathSoundPlayed ~= true then
			-- Addational Velocity
			self.Vel = self.Vel + Vector(RangeRand(-2, 2), RangeRand(-2.0, 0.5))
			self.AngularVel = self.AngularVel + RangeRand(4,12) * (math.random(0,1) * 2.0 - 1.0)
			--self.AngularVel = self.AngularVel + RangeRand(-5,5)
			
			self.deathSoundPlayed = true;
			SecurityAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.Death, self.voiceSoundVariations.Death, 15, 3)
			for actor in MovableMan.Actors do
				if actor.Team == self.Team then
					local d = SceneMan:ShortestDistance(actor.Pos, self.Pos, true).Magnitude;
					if d < 300 then
						local strength = SceneMan:CastStrengthSumRay(self.Pos, actor.Pos, 0, 128);
						if strength < 500 and math.random(1, 100) < 65 then
							actor:SetNumberValue("Sandstorm Friendly Down", 0)
							break;  -- first come first serve
						else
							if IsAHuman(actor) and actor.Head then -- if it is a human check for head
								local strength = SceneMan:CastStrengthSumRay(self.Pos, ToAHuman(actor).Head.Pos, 0, 128);	
								if strength < 500 and math.random(1, 100) < 65 then		
									actor:SetNumberValue("Sandstorm Friendly Down", 0)
									break; -- first come first serve
								end
							end
						end
					end
				end
			end
		end
		if self.dyingSoundPlayed ~= true then
			if not (self.voiceSound) or (not self.voiceSound:IsBeingPlayed()) then
				self:NotResting();
				local attachable
				for attachable in self.Attachables do
					attachable:NotResting();
				end
				self.ToSettle = false;
				self.RestThreshold = -1;
				self.dyingSoundPlayed = true;
				if (math.random(1, 100) < 10) then
					SecurityAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.Incapacitated, self.voiceSoundVariations.Incapacitated, 14)
				end
			end
		end
		if (self.dyingSoundPlayed and self.Vel.Magnitude < 1) then
			self.Vel = self.Vel + Vector(RangeRand(-2, 2), RangeRand(-0.5, 0.5)) * TimerMan.DeltaTimeSecs * 62.5
		end
		
		if self.voiceSound:IsBeingPlayed() then
			self:NotResting();
			local attachable
			for attachable in self.Attachables do
				attachable:NotResting();
			end
			self.ToSettle = false;
			self.RestThreshold = -1;
		elseif self.dyingSoundPlayed == true then
			self.allowedToDie = true;
		end
	end
end

function SecurityAIBehaviours.handleHeadLoss(self)
	if not (self.Head) then
		self.allowedToDie = true;
		self.voiceSounds = {};
		if (self.headGibSoundPlaying ~= true) then
			self.headGibSoundPlaying = true;
			if (self.voiceSound) then
				if (self.voiceSound:IsBeingPlayed()) then
					self.voiceSound:Stop(-1);
					self.voiceSound = nil;
				end
			end
			for actor in MovableMan.Actors do
				if actor.Team == self.Team then
					local d = SceneMan:ShortestDistance(actor.Pos, self.Pos, true).Magnitude;
					if d < 300 then
						local strength = SceneMan:CastStrengthSumRay(self.Pos, actor.Pos, 0, 128);
						if strength < 500 and math.random(1, 100) < 65 then
							actor:SetNumberValue("Sandstorm Friendly Down", 1)
							break;  -- first come first serve
						else
							if IsAHuman(actor) and actor.Head then -- if it is a human check for head
								local strength = SceneMan:CastStrengthSumRay(self.Pos, ToAHuman(actor).Head.Pos, 0, 128);	
								if strength < 500 and math.random(1, 100) < 65 then		
									actor:SetNumberValue("Sandstorm Friendly Down", 1)
									break; -- first come first serve
								end
							end
						end
					end
				end
			end
			self.voiceSound = AudioMan:PlaySound("Sandstorm.rte/Actors/Shared/Sounds/ActorDamage/Death/HeadGib" ..math.random(1, 3) .. ".wav", self.Pos, -1, 0, 130, 1, 400, false);
		end
		if (self.voiceSound) and (self.voiceSound:IsBeingPlayed()) then
			-- all of the below MAY WORK. i dont know
			self:NotResting();
			local attachable
			for attachable in self.Attachables do
				attachable:NotResting();
			end
			self.ToSettle = false;
			self.RestThreshold = -1;
		end
	end
end