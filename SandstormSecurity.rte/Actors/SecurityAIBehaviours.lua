SecurityAIBehaviours = {};

-- no longer needed as of pre3!

-- function SecurityAIBehaviours.createSoundEffect(self, effectName, variations)
	-- if effectName ~= nil then
		-- self.soundEffect = AudioMan:PlaySound(effectName .. math.random(1, variations) .. ".ogg", self.Pos, -1, 0, 130, 1, 400, false);	
	-- end
-- end

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

function SecurityAIBehaviours.createVoiceSoundEffect(self, soundContainer, priority, emotion, canOverridePriority)
	if canOverridePriority == nil then
		canOverridePriority = false;
	end
	local usingPriority
	if canOverridePriority == false then
		usingPriority = priority - 1;
	else
		usingPriority = priority;
	end
	if self.Head and soundContainer ~= nil then
		if self.voiceSound then
			if self.voiceSound:IsBeingPlayed() then
				if self.lastPriority <= usingPriority then
					if emotion then
						SecurityAIBehaviours.createEmotion(self, emotion, priority, 0, canOverridePriority);
					end
					self.voiceSound:Stop();
					self.voiceSound = soundContainer;
					soundContainer:Play(self.Pos)
					self.lastPriority = priority;
					return true;
				end
			else
				if emotion then
					SecurityAIBehaviours.createEmotion(self, emotion, priority, 0, canOverridePriority);
				end
				self.voiceSound = soundContainer;
				soundContainer:Play(self.Pos)
				self.lastPriority = priority;
				return true;
			end
		else
			if emotion then
				SecurityAIBehaviours.createEmotion(self, emotion, priority, 0, canOverridePriority);
			end
			self.voiceSound = soundContainer;
			soundContainer:Play(self.Pos)
			self.lastPriority = priority;
			return true;
		end
	end
end

function SecurityAIBehaviours.createExertionSoundEffect(self)
	if self.Stamina < 20 then
		self.exertionSound = self.voiceSounds.seriousExertion
		
		-- experimental
		SecurityAIBehaviours.createEmotion(self, 2, 1, 700);
	elseif self.Stamina < 65 then
		self.exertionSound = self.voiceSounds.Exertion
		
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
		SecurityAIBehaviours.createVoiceSoundEffect(self, self.exertionSound, 2)
	end
end

function SecurityAIBehaviours.handleDeadAirAndFalling(self)
	-- self.altitude = SceneMan:FindAltitude(self.Pos, 100, 3);
	
	-- if (self.TravelImpulse.Magnitude > self.ImpulseDamageThreshold/3) then
		-- self.impactSound = AudioMan:PlaySound("SandstormSecurity.rte/Actors/Sounds/DeathBodyImpact" .. math.random(1, 5) .. ".ogg", self.Pos);
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
	if self.Vel.Y > 14.5 and self.Status == 0 then
		self.Status = 1
		SecurityAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.Suppressed, 5, 2, true)
		SecurityAIBehaviours.createEmotion(self, 4, 4, 1000);
		--HitWhatTerrMaterial
	end

	if (self.TravelImpulse.Magnitude > self.ImpulseDamageThreshold) then
		self.miscSounds.Impact:Play(self.Pos);
		local damage = (self.TravelImpulse.Magnitude - self.ImpulseDamageThreshold) / 50
		--print(damage)
		self.Health = self.Health - damage
		SecurityAIBehaviours.createEmotion(self, 4, 4, 1000);
		if self.terrainCollided then
			if self.terrainSounds.TerrainImpactHeavy[self.terrainCollidedWith] ~= nil then
				self.terrainSounds.TerrainImpactHeavy[self.terrainCollidedWith]:Play(self.Pos);
			else
				self.terrainSounds.TerrainImpactHeavy[12]:Play(self.Pos); -- default concrete
			end
			self.terrainCollided = false;
		end
	end
	
	-- if (self.wasInAir and self.Vel.Y < 10) then
		-- self.altitude = SceneMan:FindAltitude(self.Pos, 100, 3);
		-- if self.altitude < 25 then
			-- --self.wasInAir = false;
			-- if self.Status == 0 then
				-- -- SecurityAIBehaviours.createSoundEffect(self, self.movementSounds.Land, self.movementSoundVariations.Land);
				-- -- if self.footPixel ~= 0 then
					-- -- if self.terrainProneSounds[self.footPixel] ~= nil then
						-- -- SecurityAIBehaviours.createSoundEffect(self, self.terrainLandSounds[self.footPixel], self.terrainLandSoundVariations[self.footPixel]);
					-- -- else
						-- -- SecurityAIBehaviours.createSoundEffect(self, self.terrainLandSounds[12], self.terrainLandSoundVariations[12]); -- default concrete
					-- -- end
				-- -- end
				-- -- SecurityAIBehaviours.createExertionSoundEffect(self);
				-- -- self.Stamina = self.Stamina - 6;
			-- elseif self.moveSoundTimer:IsPastSimMS(600) then
				-- self.moveSoundTimer:Reset();
				-- self.movementSounds.Fall:Play(self.Pos);
				-- if self.terrainCollided then
					-- if self.terrainSounds.TerrainImpactLight[self.terrainCollidedWith] ~= nil then
						-- self.terrainSounds.TerrainImpactLight[self.terrainCollidedWith]:Play(self.Pos);
					-- else
						-- self.terrainSounds.TerrainImpactLight[12]:Play(self.Pos); -- default concrete
					-- end
					-- self.terrainCollided = false;
				-- end
				-- SecurityAIBehaviours.createExertionSoundEffect(self);
				-- self.Stamina = self.Stamina - 15;
			-- end
		-- end
	-- end
	
end

function SecurityAIBehaviours.handleMovement(self)
	
	local crouching = self.controller:IsState(Controller.BODY_CROUCH)
	local moving = self.controller:IsState(Controller.MOVE_LEFT) or self.controller:IsState(Controller.MOVE_RIGHT);
	
	-- Leg Collision Detection system
    --local i = 0
	if self:IsPlayerControlled() then -- AI doesn't update its own foot checking when playercontrolled so we have to do it
		if self.Vel.Y > 10 then
			self.wasInAir = true;
		else
			self.wasInAir = false;
		end
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
				local pixelPos = footPos + Vector(0, 4)
				self.footPixel = SceneMan:GetTerrMatter(pixelPos.X, pixelPos.Y)
				--PrimitiveMan:DrawLinePrimitive(pixelPos, pixelPos, 13)
				if self.footPixel ~= 0 then
					mat = SceneMan:GetMaterialFromID(self.footPixel)
				--	PrimitiveMan:DrawLinePrimitive(pixelPos, pixelPos, 162);
				--else
				--	PrimitiveMan:DrawLinePrimitive(pixelPos, pixelPos, 13);
				end
				
				local movement = (self.controller:IsState(Controller.MOVE_LEFT) == true or self.controller:IsState(Controller.MOVE_RIGHT) == true or self.Vel.Magnitude > 3)
				if mat ~= nil then
					--PrimitiveMan:DrawTextPrimitive(footPos, mat.PresetName, true, 0);
					if self.feetContact[i] == false then
						self.feetContact[i] = true
						if self.feetTimers[i]:IsPastSimMS(self.footstepTime) and movement then																	
							self.feetTimers[i]:Reset()
						end
					end
				else
					if self.feetContact[i] == true then
						self.feetContact[i] = false
						if self.feetTimers[i]:IsPastSimMS(self.footstepTime) and movement then
							self.feetTimers[i]:Reset()
						end
					end
				end
			end
		end
	else
		if self.AI.flying == true and self.wasInAir == false then
			self.wasInAir = true;
		elseif self.AI.flying == false and self.wasInAir == true then
			self.wasInAir = false;
			self.isJumping = false
			if self.moveSoundTimer:IsPastSimMS(500) then
				self.movementSounds.Land:Play(self.Pos);
				self.moveSoundTimer:Reset();
				
				local pos = Vector(0, 0);
				SceneMan:CastObstacleRay(self.Pos, Vector(0, 45), pos, Vector(0, 0), self.ID, self.Team, 0, 10);				
				local terrPixel = SceneMan:GetTerrMatter(pos.X, pos.Y)
				
				if self.terrainSounds.FootstepLand[terrPixel] ~= nil then
					self.terrainSounds.FootstepLand[terrPixel]:Play(self.Pos);
				else -- default to concrete
					self.terrainSounds.FootstepLand[177]:Play(self.Pos);
				end	
			end
		end
	end
	
	-- Custom Jump
	if self.controller:IsState(Controller.BODY_JUMPSTART) == true and self.controller:IsState(Controller.BODY_CROUCH) == false and self.jumpTimer:IsPastSimMS(self.jumpDelay) and not self.isJumping then
		if self.feetContact[1] == true or self.feetContact[2] == true then
			local jumpVec = Vector(0,-3.5)
			local jumpWalkX = 3
			if self.controller:IsState(Controller.MOVE_LEFT) == true then
				jumpVec.X = -jumpWalkX
			elseif self.controller:IsState(Controller.MOVE_RIGHT) == true then
				jumpVec.X = jumpWalkX
			end
			self.movementSounds.Jump:Play(self.Pos);
			local pos = Vector(0, 0);
			SceneMan:CastObstacleRay(self.Pos, Vector(0, 45), pos, Vector(0, 0), self.ID, self.Team, 0, 10);				
			local terrPixel = SceneMan:GetTerrMatter(pos.X, pos.Y)
			
			if self.terrainSounds.FootstepJump[terrPixel] ~= nil then
				self.terrainSounds.FootstepJump[terrPixel]:Play(self.Pos);
			else -- default to concrete
				self.terrainSounds.FootstepJump[177]:Play(self.Pos);
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
	elseif self.isJumping or self.wasInAir then
		if (self.feetContact[1] == true or self.feetContact[2] == true) and self.jumpStop:IsPastSimMS(100) then
			self.isJumping = false
			if self.Vel.Y > 0 and self.moveSoundTimer:IsPastSimMS(500) then
				self.movementSounds.Land:Play(self.Pos);
				self.moveSoundTimer:Reset();
				local pos = Vector(0, 0);
				SceneMan:CastObstacleRay(self.Pos, Vector(0, 45), pos, Vector(0, 0), self.ID, self.Team, 0, 10);				
				local terrPixel = SceneMan:GetTerrMatter(pos.X, pos.Y)
				
				if self.terrainSounds.FootstepLand[terrPixel] ~= nil then
					self.terrainSounds.FootstepLand[terrPixel]:Play(self.Pos);
				else -- default to concrete
					self.terrainSounds.FootstepLand[177]:Play(self.Pos);
				end		
			end
		else
			if self.controller:IsState(Controller.BODY_JUMP) == true and not self.jumpBoost:IsPastSimMS(200) then
				self.Vel = self.Vel - SceneMan.GlobalAcc * TimerMan.DeltaTimeSecs * 1.0 -- Stop the gravity
			end
			--self.controller:SetState(Controller.MOVE_LEFT,false);
			--self.controller:SetState(Controller.MOVE_RIGHT,false);
			--if self.controller:IsState(Controller.MOVE_LEFT) == false and self.controller:IsState(Controller.MOVE_LEFT) == false then
			--	self.controller:SetState(Controller.BODY_CROUCH,true);
			--end
		end
	end
	-- DEBUG
	--[[
	PrimitiveMan:DrawTextPrimitive(Vector(self.Pos.X,self.Pos.Y), self.isJumping and "jumping" or "not jumping", true, 0);
	--]]
	
	-- Sprint
	local input = ((self.controller:IsState(Controller.MOVE_LEFT) == true or self.controller:IsState(Controller.MOVE_RIGHT) == true) and not (self.controller:IsState(Controller.MOVE_LEFT) == true and self.controller:IsState(Controller.MOVE_RIGHT) == true))
	
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
			self.StrideSound = self.sprintSound;
			self.doubleTapState = 0
		end
	end
	
	--isSprinting
	self.aiSprint = not self:IsPlayerControlled() and (self.controller:IsState(Controller.MOVE_LEFT) == true or self.controller:IsState(Controller.MOVE_RIGHT) == true)
	
	--local movementMultiplier = 1
	local movementMultiplier = 1 - (0.2 * (1 - (self.Stamina / 100)))
	local walkMultiplier = 0.65 * movementMultiplier
	--local sprintMultiplier = 0.5 * movementMultiplier
	local sprintMultiplier = 0.65 * movementMultiplier - (0.1 * (1 - (self.Stamina / 100)))
	if self.isSprinting or aiSprint then
		self.footstepTime = self.sprintFootstepTime;
		if input == false or self.controller:IsState(Controller.AIM_SHARP) then
			self.isSprinting = false
			self.StrideSound = self.walkSound;
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
		if (not self.wasCrouching and self.moveSoundTimer:IsPastSimMS(600)) then
			if (moving) then
				self.movementSounds.Prone:Play(self.Pos);
				if math.random(0, 100) < 80 then
					SecurityAIBehaviours.createExertionSoundEffect(self);
				end
				self.proneTerrainPlayed = false;
				self.Stamina = self.Stamina - 6;

			else
				self.movementSounds.Crouch:Play(self.Pos);
			end
		end
		if (moving) then
			if self.terrainCollided == true and self.proneTerrainSoundPlayed ~= true then
				self.proneTerrainSoundPlayed = true;
				
				if self.terrainSounds.Prone[self.terrainCollidedWith] ~= nil then
					self.terrainSounds.Prone[self.terrainCollidedWith]:Play(self.Pos);
				else -- default to concrete
					self.terrainSounds.Prone[177]:Play(self.Pos);
				end
				
			end
				
			if (self.moveSoundWalkTimer:IsPastSimMS(700)) then
				self.movementSounds.Crawl:Play(self.Pos);
				self.moveSoundWalkTimer:Reset();
				
				local pos = Vector(0, 0);
				SceneMan:CastObstacleRay(self.Pos, Vector(0, 20), pos, Vector(0, 0), self.ID, self.Team, 0, 5);				
				local terrPixel = SceneMan:GetTerrMatter(pos.X, pos.Y)
				
				if self.terrainSounds.Crawl[terrPixel] ~= nil then
					self.terrainSounds.Crawl[terrPixel]:Play(self.Pos);
				else -- default to concrete
					self.terrainSounds.Crawl[177]:Play(self.Pos);
				end		
				
			end
		end
	else
		if (self.wasCrouching and self.moveSoundTimer:IsPastSimMS(600)) then
			self.movementSounds.Stand:Play(self.Pos);
			self.moveSoundTimer:Reset();
			if math.random(0, 100) < 40 then
				SecurityAIBehaviours.createExertionSoundEffect(self);
				self.Stamina = self.Stamina - 2;
			end
		end
		self.proneTerrainSoundPlayed = false;
	end
	
	-- Experimental camera
	--local camDif = SceneMan:ShortestDistance((self.Pos), (self.Head.Pos + self.Head.Vel * rte.PxTravelledPerFrame),SceneMan.SceneWrapsX)
	--camDif = Vector(camDif.X, camDif.Y * 2.0) + Vector(0,5)
	--self.ViewPoint = self.ViewPoint + camDif
	
	if not (moving) then
		self.foot = 0
	end
	
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
		
		if self:NumberValueExists("Burn Pain") then
			self:RemoveNumberValue("Burn Pain");
			SecurityAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.burnPain, 5, 2);
		end
		
		if self:NumberValueExists("Death By Fire") then
			SecurityAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.flameDeath, 20, 4);
			self.incapacitated = true
			self.incapacitationChance = 0;
		end
		
		if wasHeavilyInjured then
			self.Suppression = self.Suppression + 100;
			self.Status = 1
		elseif wasInjured then
			self.Suppression = self.Suppression + 60;
		elseif wasLightlyInjured then
			SecurityAIBehaviours.createEmotion(self, 2, 4, 500);
			self.Suppression = self.Suppression + math.random(9,13);
		end
		
		-- blood taint on the head
		if self.Head then
			local headTaint = nil
			if self:NumberValueExists("HeadBloodTaintID") then
				local mo = MovableMan:FindObjectByUniqueID(self:GetNumberValue("HeadBloodTaintID"))
				if mo then
					headTaint = ToAttachable(mo)
				end				
			end
			
			if headTaint ~= nil then
				if self.Health > 80 then
					headTaint.ToDelete = true
				else
					headTaint.Frame = math.floor((1 - ((math.min(self.Health, 100) + 20) / 100)) * 5 + 0.5)
				end
			else
				if self.Health <= 80 then
					local taint = CreateAttachable("Sandstorm Head Blood Taint", "Sandstorm.rte");
					self.Head:AddAttachable(taint);
					taint.Frame = math.floor((1 - ((math.min(self.Health, 100) + 20) / 100)) * 5 + 0.5)
					self:SetNumberValue("HeadBloodTaintID", taint.UniqueID)
				end
			end
		end
		
		if (wasInjured or wasHeavilyInjured) and self.Head then
			
			-- remove the shockwave value, so we don't care about it if we were close enough
			-- to get injured this bad anyway.
			self:RemoveNumberValue("Sandstorm Shockwave");
			
			if self.Health > 0 then
				SecurityAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.Pain, 5, 2, true)
				self.Stamina = self.Stamina - 25;
			else
				SecurityAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.seriousDeath, 10, 4)
				self.seriousDeath = true;
				self.deathSoundPlayed = true;
				for actor in MovableMan.Actors do
					if actor.Team == self.Team then
						local d = SceneMan:ShortestDistance(actor.Pos, self.Pos, true).Magnitude;
						if d < 300 then
							local strength = SceneMan:CastStrengthSumRay(self.Pos, actor.Pos, 0, 128);
							if strength < 500 and math.random(1, 100) < 65 then
								if self:NumberValueExists("Death By Fire") then
									actor:SetNumberValue("Sandstorm Friendly Down", 1)
								else
									actor:SetNumberValue("Sandstorm Friendly Down", 0)
								end
								break;  -- first come first serve
							else
								if IsAHuman(actor) and actor.Head then -- if it is a human check for head
									local strength = SceneMan:CastStrengthSumRay(self.Pos, ToAHuman(actor).Head.Pos, 0, 128);	
									if strength < 500 and math.random(1, 100) < 65 then		
									if self:NumberValueExists("Death By Fire") then
										actor:SetNumberValue("Sandstorm Friendly Down", 1)
									else
										actor:SetNumberValue("Sandstorm Friendly Down", 0)
									end
										break; -- first come first serve
									end
								end
							end
						end
					end
				end
				self.Dying = true;
				if (wasHeavilyInjured) and (self.Head.WoundCount > (self.headWounds + 1)) then
					-- insta death only on big headshots
					self.deathSoundPlayed = true;
					self.dyingSoundPlayed = true;
					if (self.voiceSound) and (self.voiceSound:IsBeingPlayed()) then
						self.voiceSound:Stop(-1);
					end
					self.allowedToDie = true;
					self.voiceSounds = {};
				end
			end
		end
		if self.Head then
			self.headWounds = self.Head.WoundCount
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
			self.controller:SetState(Controller.WEAPON_DROP,true);
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
					SecurityAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.inhaleHeavy, 0);
					self.Inhale = false;
				else
					SecurityAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.exhaleHeavy, 0);
					self.Inhale = true;
					-- experimental
					SecurityAIBehaviours.createEmotion(self, 1, 0, 300);
				end		
			elseif self.Stamina < 50 then	
				if self.Inhale then
					SecurityAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.inhaleMedium, 0);
					self.Inhale = false;
				else
					SecurityAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.exhaleMedium, 0);
					self.Inhale = true;
					-- experimental
					SecurityAIBehaviours.createEmotion(self, 1, 0, 200);
				end		
			elseif self.Stamina < 70 then	
				if self.Inhale then
					SecurityAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.inhaleLight, 0);
					self.Inhale = false;
				else
					SecurityAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.exhaleLight, 0);
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
	
	if self:NumberValueExists("Sandstorm Shockwave") then
		self:RemoveNumberValue("Sandstorm Shockwave");
		self.Suppression = self.Suppression + 60;
		SecurityAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.SuppressedByExplosion, 6, 2, false);
	end
	
	if self:NumberValueExists("Sandstorm Bullet Suppressed") then
		self:RemoveNumberValue("Sandstorm Bullet Suppressed");
		self.Suppression = self.Suppression + 15;
	end
	
	if (suppressionTimerReady) then
		if self.Suppression > 50 then
			if self.Suppression > 99 and self.suppressedVoicelineTimer:IsPastSimMS(self.suppressedVoicelineDelay) then
				-- keep playing voicelines if we keep being suppressed to the max
				SecurityAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.Suppressed, 4, 2, true);
				self.suppressedVoicelineTimer:Reset();
			end
			if self.Suppressed == false then -- initial voiceline
				SecurityAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.Suppressed, 4, 2, true);
			end
			self.Suppressed = true;
		else
			self.Suppressed = false;
		end
		self.Suppression = math.min(self.Suppression, 100)
		if self.Suppression > 80 then
			self.Suppression = self.Suppression - 2.5;
		elseif self.Suppression > 0 then
			self.Suppression = self.Suppression - 10;
		end
		self.Suppression = math.max(self.Suppression, 0)
		self.suppressionUpdateTimer:Reset();
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

function SecurityAIBehaviours.handleAITargetLogic(self)
	-- SPOT ENEMY REACTION
	-- works off of the native AI's target
	
	if not self.LastTargetID then
		self.LastTargetID = -1
	end
	
	--spotEnemy
	--spotEnemyFar
	--spotEnemyClose
	
	if (not self:IsPlayerControlled()) and self.AI.Target and IsAHuman(self.AI.Target) then
	
		self.spotVoiceLineTimer:Reset();
		
		local posDifference = SceneMan:ShortestDistance(self.Pos,self.AI.Target.Pos,SceneMan.SceneWrapsX)
		local distance = posDifference.Magnitude
		
		local isClose = distance < self.spotDistanceClose
		local isMid = distance < self.spotDistanceMid 
		local isFar = distance > self.spotDistanceMid 
		
		--[[
		local maxi = math.floor(distance / 10)
		for i = 1, maxi do
			local vec = posDifference * i / maxi
			local pos = self.Pos + vec
			local color = 162
			if vec.Magnitude < self.spotDistanceClose then
				color = 13
			elseif vec.Magnitude < self.spotDistanceMid then
				color = 122
			end
			PrimitiveMan:DrawLinePrimitive(pos, pos, color);
		end]]
		
		if not isClose and self.EquippedItem and IsHDFirearm(self.EquippedItem) then
			if ToHDFirearm(self.EquippedItem):NumberValueExists("recoilStrengthCurrent") and ToHDFirearm(self.EquippedItem):NumberValueExists("recoilStrengthBase") then
				local strCurrent = ToHDFirearm(self.EquippedItem):GetNumberValue("recoilStrengthCurrent")
				local strBase = ToHDFirearm(self.EquippedItem):GetNumberValue("recoilStrengthBase")
				
				local distanceDif = (self.spotDistanceMid - self.spotDistanceClose)
				local distanceFactor = math.min(math.max((distance / distanceDif + self.spotDistanceClose / distanceDif) - 1, 0), 1)
				
				local burstDelay = not self.burstFireDelayTimer:IsPastSimMS(self.burstFireDelay * strBase / 7 * (distanceFactor + 0.4))
				
				if strCurrent > strBase / (distanceFactor + 0.4) or burstDelay then
					self.controller:SetState(Controller.WEAPON_FIRE, false)
					if not burstDelay then
						self.burstFireDelayTimer:Reset()
						self.burstFireDelay = math.random(self.burstFireDelayMin,self.burstFireDelayMax)
					end
				end
			end
		end
		
		if self.spotAllowed ~= false then
			
			if self.LastTargetID == -1 then
				self.LastTargetID = self.AI.Target.UniqueID
				-- Target spotted
				--local posDifference = SceneMan:ShortestDistance(self.Pos,self.AI.Target.Pos,SceneMan.SceneWrapsX)
				
				if not self.AI.Target:NumberValueExists("Sandstorm Enemy Spotted Age") or -- If no timer exists
				self.AI.Target:GetNumberValue("Sandstorm Enemy Spotted Age") < (self.AI.Target.Age - self.AI.Target:GetNumberValue("Sandstorm Enemy Spotted Delay")) or -- If the timer runs out of time limit
				math.random(0, 100) < self.spotIgnoreDelayChance -- Small chance to ignore timers, to spice things up
				then
					-- Setup the delay timer
					self.AI.Target:SetNumberValue("Sandstorm Enemy Spotted Age", self.AI.Target.Age)
					self.AI.Target:SetNumberValue("Sandstorm Enemy Spotted Delay", math.random(self.spotDelayMin, self.spotDelayMax))
					
					self.spotAllowed = false;
					
					if isClose then
						SecurityAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.spotEnemyClose, 3, 4, false);
					elseif isMid then
						SecurityAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.spotEnemy, 3, 3, false);
					else
						SecurityAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.spotEnemyFar, 3, 2, false);
					end
				end
			else
				-- Refresh the delay timer
				if self.AI.Target:NumberValueExists("Sandstorm Enemy Spotted Age") then
					self.AI.Target:SetNumberValue("Sandstorm Enemy Spotted Age", self.AI.Target.Age)
				end
			end
		end
	else
		if self.spotVoiceLineTimer:IsPastSimMS(self.spotVoiceLineDelay) then
			self.spotAllowed = true;
		end
		if self.LastTargetID ~= -1 then
			self.LastTargetID = -1
			-- Target lost
			--print("TARGET LOST!")
		end
	end
end

function SecurityAIBehaviours.handleVoicelines(self)

	-- this is the bigun
	
	-- DEVICE RELATED VOICELINES
	
	if self.EquippedItem then
	
		-- RELOADING, SUPPRESSING

		if (IsHDFirearm(self.EquippedItem)) then
			-- SPECIAL HANDLING FOR THROWING REMOTE BOMBS
		
			if ToHDFirearm(self.EquippedItem):NumberValueExists("Sandstorm Custom Throw") then
				ToHDFirearm(self.EquippedItem):RemoveNumberValue("Sandstorm Custom Throw");
				self.movementSounds.Throw:Play(self.Pos);
			end
			
			if ToHDFirearm(self.EquippedItem):NumberValueExists("Sandstorm Custom Throwstart") then
				ToHDFirearm(self.EquippedItem):RemoveNumberValue("Sandstorm Custom Throwstart");
				self.movementSounds.throwStart:Play(self.Pos);
			end
			if self.EquippedItem:IsInGroup("Weapons") then
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
						SecurityAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.Suppressing, 6, 3, true);
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
								SecurityAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.suppressedReload, 5, 2, true);
							end
						elseif (math.random(1, 100) < 50) then
							SecurityAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.Reload, 4);
						end
						self.reloadVoicelinePlayed = true;
					end
				else
					self.reloadVoicelinePlayed = false;
				end
			else
				self.reloadVoicelinePlayed = false;
			end
		end
		
		-- END RELOADING, SUPPRESSING
		
		-- THROWING GRENADES
	
		if IsTDExplosive(self.EquippedItem) then
			local activated = self.controller:IsState(Controller.WEAPON_FIRE)
			if (activated) then
				
				if self.activatedExplosive ~= true then
					self.activatedExplosive = true;
					self.movementSounds.throwStart:Play(self.Pos);
				end
			
				-- very messy detection due to string.find being case sensitive
				
				if (self.throwGrenadeVoicelinePlayed ~= true) and 
				(not ToTDExplosive(self.EquippedItem):NumberValueExists("No Throw VO")) then
					if (string.find(self.EquippedItem.PresetName, "Stun")) or (string.find(self.EquippedItem.PresetName, "Flash")) or (string.find(self.EquippedItem.PresetName, "stun")) or (string.find(self.EquippedItem.PresetName, "flash")) or
					(ToTDExplosive(self.EquippedItem):IsInGroup("Sandstorm Flashbang Grenade")) then
						if (self.Suppressed) then
							SecurityAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.suppressedFlashOut, 5, 3);
						else
							SecurityAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.flashOut, 5, 2);
						end
					elseif (string.find(self.EquippedItem.PresetName, "Frag")) or (string.find(self.EquippedItem.PresetName, "HE")) or (string.find(self.EquippedItem.PresetName, "frag")) or 
					(ToTDExplosive(self.EquippedItem):IsInGroup("Sandstorm Frag Grenade")) then
						if (self.Suppressed) then
							SecurityAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.suppressedFragOut, 5, 3);
						else
							SecurityAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.fragOut, 5, 2);
						end
					elseif (string.find(self.EquippedItem.PresetName, "Incendiary")) or (string.find(self.EquippedItem.PresetName, "Flame")) or (string.find(self.EquippedItem.PresetName, "incendiary")) or (string.find(self.EquippedItem.PresetName, "flame")) or (ToTDExplosive(self.EquippedItem):IsInGroup("Sandstorm Incendiary Grenade")) then
						if (self.Suppressed) then
							SecurityAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.suppressedIncendiaryOut, 5, 3);
						else
							SecurityAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.incendiaryOut, 5, 2);
						end
					elseif (string.find(self.EquippedItem.PresetName, "Mine")) or (string.find(self.EquippedItem.PresetName, "Claymore")) or (string.find(self.EquippedItem.PresetName, "mine")) or (string.find(self.EquippedItem.PresetName, "claymore")) or (ToTDExplosive(self.EquippedItem):IsInGroup("Sandstorm Mine")) then
						if (self.Suppressed) then
							SecurityAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.suppressedMineOut, 5, 3);
						else
							SecurityAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.mineOut, 5, 2);
						end
					elseif (string.find(self.EquippedItem.PresetName, "Molotov")) or (string.find(self.EquippedItem.PresetName, "Bottle Bomb")) or (string.find(self.EquippedItem.PresetName, "molotov")) or (string.find(self.EquippedItem.PresetName, "bottle bomb")) or (ToTDExplosive(self.EquippedItem):IsInGroup("Sandstorm Molotov")) then
						if (self.Suppressed) then
							SecurityAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.suppressedMolotovOut, 5, 3);
						else
							SecurityAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.molotovOut, 5, 2);
						end
					elseif (string.find(self.EquippedItem.PresetName, "Remote")) or (string.find(self.EquippedItem.PresetName, "C4")) or (string.find(self.EquippedItem.PresetName, "Timed")) or (string.find(self.EquippedItem.PresetName, "remote")) or (string.find(self.EquippedItem.PresetName, "c4")) or (string.find(self.EquippedItem.PresetName, "timed")) or (ToTDExplosive(self.EquippedItem):IsInGroup("Sandstorm Remote Bomb")) then
						if (self.Suppressed) then
							SecurityAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.suppressedRemoteOut, 5, 3);
						else
							SecurityAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.remoteOut, 5, 2);
						end
					elseif (string.find(self.EquippedItem.PresetName, "Smoke")) or (string.find(self.EquippedItem.PresetName, "smoke")) or (ToTDExplosive(self.EquippedItem):IsInGroup("Sandstorm Smoke Grenade")) then
						if (self.Suppressed) then
							SecurityAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.suppressedSmokeOut, 5, 3);
						else
							SecurityAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.smokeOut, 5, 2);
						end
					else -- default frag nade
						if (self.Suppressed) then
							SecurityAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.suppressedFragOut, 5, 3);
						else
							SecurityAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.fragOut, 5, 2);
						end
					end
					self.throwGrenadeVoicelinePlayed = true;
				end
			else
				self.throwGrenadeVoicelinePlayed = false;
				if self.activatedExplosive then
					self.activatedExplosive = false;
					self.movementSounds.Throw:Play(self.Pos);
				end
			end
		elseif IsHDFirearm(self.EquippedItem) and ToHDFirearm(self.EquippedItem):NumberValueExists("Sandstorm Custom Activation") then
			if (string.find(self.EquippedItem.PresetName, "Remote")) or (string.find(self.EquippedItem.PresetName, "C4")) or (string.find(self.EquippedItem.PresetName, "Timed")) or (string.find(self.EquippedItem.PresetName, "remote")) or (string.find(self.EquippedItem.PresetName, "c4")) or (string.find(self.EquippedItem.PresetName, "timed")) or (ToHDFirearm(self.EquippedItem):IsInGroup("Sandstorm Remote Bomb")) then
				if (self.Suppressed) then
					SecurityAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.suppressedRemoteOut, 5, 3);
				else
					SecurityAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.remoteOut, 5, 2);
				end
			elseif (string.find(self.EquippedItem.PresetName, "Mine")) or (string.find(self.EquippedItem.PresetName, "Claymore")) or (string.find(self.EquippedItem.PresetName, "mine")) or (string.find(self.EquippedItem.PresetName, "claymore")) or (ToTDExplosive(self.EquippedItem):IsInGroup("Sandstorm Mine")) then
				if (self.Suppressed) then
					SecurityAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.suppressedMineOut, 5, 3);
				else
					SecurityAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.mineOut, 5, 2);
				end
			end
			ToHDFirearm(self.EquippedItem):RemoveNumberValue("Sandstorm Custom Activation")
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
			
			SecurityAIBehaviours.createVoiceSoundEffect(self, Sounds, 4, 4, true);		
			self.friendlyDownTimer:Reset();
		end
		self:RemoveNumberValue("Sandstorm Friendly Down")
	end
	
	
	-- FLASH REACTION
	
	if self:NumberValueExists("Flashed") then
		self:RemoveNumberValue("Flashed");
		SecurityAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.Flashed, 5, 4, true);
	end
		
	-- SPOT FRAG GRENADE REACTION
		
	if self:NumberValueExists("Spotted Grenade") then
		self:RemoveNumberValue("Spotted Grenade");
		SecurityAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.spotGrenade, 4, 4, false);
		if self.Suppression < 20 then
			self.Suppression = self.Suppression + 15;
		end
	end
	
	-- SPOT REMOTE BOMB REACTION
	
	if self:NumberValueExists("Spotted Remote") then
		self:RemoveNumberValue("Spotted Remote");
		SecurityAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.spotRemote, 4, 4, false);
		if self.Suppression < 20 then
			self.Suppression = self.Suppression + 25;
		end
	end
	
	-- PICK UP LIVE GRENADE REACTION
	
	if self:NumberValueExists("Tossback Grenade") then
		self:RemoveNumberValue("Tossback Grenade");
		SecurityAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.Tossback, 4, 4, false);
	end

end

function SecurityAIBehaviours.handleDying(self)

	self.controller.Disabled = true;
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
		--self.Head.CollidesWithTerrainWhenAttached = false
		
		if self.headWounds and self.Head.WoundCount > self.headWounds then
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
			SecurityAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.Death, 15, 3)
			for actor in MovableMan.Actors do
				if actor.Team == self.Team then
					local d = SceneMan:ShortestDistance(actor.Pos, self.Pos, true).Magnitude;
					if d < 300 then
						local strength = SceneMan:CastStrengthSumRay(self.Pos, actor.Pos, 0, 128);
						if strength < 500 and math.random(1, 100) < 65 then
							if self:NumberValueExists("Death By Fire") then
								actor:SetNumberValue("Sandstorm Friendly Down", 1)
							else
								actor:SetNumberValue("Sandstorm Friendly Down", 0)
							end
							break;  -- first come first serve
						else
							if IsAHuman(actor) and actor.Head then -- if it is a human check for head
								local strength = SceneMan:CastStrengthSumRay(self.Pos, ToAHuman(actor).Head.Pos, 0, 128);	
								if strength < 500 and math.random(1, 100) < 65 then		
									if self:NumberValueExists("Death By Fire") then
										actor:SetNumberValue("Sandstorm Friendly Down", 1)
									else
										actor:SetNumberValue("Sandstorm Friendly Down", 0)
									end
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
				if (math.random(1, 100) < self.incapacitationChance) then
					SecurityAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.Incapacitated, 14)
					self.incapacitated = true
				end
			end
		end
		if self.incapacitated and (self.dyingSoundPlayed and self.Vel.Magnitude < 1) then
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

function SecurityAIBehaviours.handleRagdoll(self)
	-- EXPERIMENTAL BETTER RAGDOLL
	local radius = self.Radius * 0.9
	
	local min_value = -math.pi;
	local max_value = math.pi;
	local value = self.RotAngle
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
	
	local str = math.max(1 - math.abs(result / math.pi * 2.0), 0)
	--local normal = Vector(0,0)
	--local slide = false
	
	-- Trip on the ground
	for j = 0, 1 do
		local pos = self.Pos + Vector(0, -3):RadRotate(self.RotAngle)
		if self.Head and math.random(1,2) < 2 then
			pos = self.Head.Pos
		end
		
		local maxi = 6
		for i = 0, maxi do
			local checkVec = Vector(radius * (0.7 - 0.2 * j),0):RadRotate(math.pi * 2 / maxi * i + self.RotAngle)
			local checkOrigin = Vector(pos.X, pos.Y) + checkVec + Vector(self.Vel.X, self.Vel.Y) * rte.PxTravelledPerFrame * 0.3
			local checkPix = SceneMan:GetTerrMatter(checkOrigin.X, checkOrigin.Y)
			
			if checkPix > 0 then
				self.Vel = self.Vel - Vector(checkVec.X, checkVec.Y):SetMagnitude(30 * str) * TimerMan.DeltaTimeSecs
				self.AngularVel = self.AngularVel + (self.AngularVel / math.abs(self.AngularVel)) * str * 20 * TimerMan.DeltaTimeSecs
				
				--normal = normal + checkVec
				--slide = true
			end
		end
		
	end
	--[[
	normal = (normal / 12):SetMagnitude(1)
	if slide then
		local slideAngle = normal.AbsRadAngle + math.pi * 0.5
		
		local newVel = Vector(self.Vel.X, self.Vel.Y)
		newVel:RadRotate(slideAngle)
		newVel = Vector(newVel.X, -math.abs(-newVel.Y))
		newVel:RadRotate(-slideAngle)
		self.Vel = self.Vel * str + newVel * (1 - str)
	end]]
	-- SOUNDS
	
	local mat = self.HitWhatTerrMaterial
	--PrimitiveMan:DrawLinePrimitive(self.Pos, self.Pos + self.TravelImpulse * 0.1, 5);
	--PrimitiveMan:DrawLinePrimitive(self.Pos, self.Pos + self.Vel, 13);
	--self.TravelImpulse.Magnitude
	if mat ~= 0 then
		if self.moveSoundTimer:IsPastSimMS(600) then
			self.moveSoundTimer:Reset();
			if self.TravelImpulse.Magnitude > 700 and self.ragdollTerrainImpactTimer:IsPastSimMS(self.ragdollTerrainImpactDelay) then
				self.movementSounds.Fall:Play(self.Pos);
				if self.terrainSounds.TerrainImpactHeavy[self.terrainCollidedWith] ~= nil then
					self.terrainSounds.TerrainImpactHeavy[self.terrainCollidedWith]:Play(self.Pos);
				else
					self.terrainSounds.TerrainImpactHeavy[12]:Play(self.Pos); -- default concrete
				end
				self.ragdollTerrainImpactDelay = math.random(200, 500)
				self.ragdollTerrainImpactTimer:Reset()
			elseif self.TravelImpulse.Magnitude > 400 and self.ragdollTerrainImpactTimer:IsPastSimMS(self.ragdollTerrainImpactDelay) then
				if self.terrainSounds.TerrainImpactLight[self.terrainCollidedWith] ~= nil then
					self.terrainSounds.TerrainImpactLight[self.terrainCollidedWith]:Play(self.Pos);
				else
					self.terrainSounds.TerrainImpactLight[12]:Play(self.Pos); -- default concrete
				end
				self.ragdollTerrainImpactDelay = math.random(200, 500)
				self.ragdollTerrainImpactTimer:Reset()
			elseif self.TravelImpulse.Magnitude > 230 then
				self.movementSounds.Crawl:Play(self.Pos);
			end
		end
	end
end

--MovableObject:
--    Prop HitWhatMOID, r/o
--    Prop HitWhatTerrMaterial, r/o
--    Prop HitWhatParticleUniqueID, r/o

function SecurityAIBehaviours.handleHeadLoss(self)
	if not (self.Head) then
		self.allowedToDie = true;
		self.voiceSounds = {};
		if (self.headGibSoundPlaying ~= true) then
			self.headGibSoundPlaying = true;
			self.voiceSound:Stop(-1);
			
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
			-- self.voiceSound = AudioMan:PlaySound("Sandstorm.rte/Actors/Shared/Sounds/ActorDamage/Death/HeadGib" ..math.random(1, 3) .. ".ogg", self.Pos, -1, 0, 130, 1, 400, false);
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