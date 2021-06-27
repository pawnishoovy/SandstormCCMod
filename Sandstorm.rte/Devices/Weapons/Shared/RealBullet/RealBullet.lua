
function Create(self)

	self.ricochetSound = CreateSoundContainer("Sandstorm Ricochet", "Sandstorm.rte");
	
	self.subsonicFlyBy = CreateSoundContainer("Sandstorm FlyBy Subsonic", "Sandstorm.rte");
	self.supersonicFlyBy = CreateSoundContainer("Sandstorm FlyBy Supersonic", "Sandstorm.rte");
	self.supersonicFlyByAlt = CreateSoundContainer("Sandstorm FlyBy Supersonic Alt", "Sandstorm.rte");
	self.supersonicIndoorsFlyBy = CreateSoundContainer("Sandstorm FlyBy Supersonic Indoors", "Sandstorm.rte");
	self.supersonicIndoorsAltFlyBy = CreateSoundContainer("Sandstorm FlyBy Supersonic Indoors Alt", "Sandstorm.rte");
	
	self.origTeam = self.Team;
	
	for i = 1, math.random(1,3) do
		local poof = CreateMOSParticle(math.random(1,2) < 2 and "Tiny Smoke Ball 1" or "Small Smoke Ball 1");
		poof.Pos = self.Pos
		poof.Vel = Vector(self.Vel.X, self.Vel.Y):RadRotate(math.pi * RangeRand(-1, 1) * 0.05) * RangeRand(0.1, 0.9) * 0.4;
		poof.Lifetime = poof.Lifetime * RangeRand(0.9, 1.6) * 0.2
		MovableMan:AddParticle(poof);
	end
	for i = 1, math.random(1,2) do
		local poof = CreateMOSParticle("Tiny Smoke Ball 1");
		poof.Pos = self.Pos
		poof.Vel = (Vector(self.Vel.X, self.Vel.Y):RadRotate(math.pi * (math.random(0,1) * 2.0 - 1.0) * 0.5 + math.pi * RangeRand(-1, 1) * 0.15) * RangeRand(0.1, 0.9) * 0.3 + Vector(self.Vel.X, self.Vel.Y):RadRotate(math.pi * RangeRand(-1, 1) * 0.15) * RangeRand(0.1, 0.9) * 0.2) * 0.5;
		poof.Lifetime = poof.Lifetime * RangeRand(0.9, 1.6) * 0.2
		MovableMan:AddParticle(poof);
	end
	
	-- epic pawnis armor pen
	self.useArmorSystem = false;
	self.bluntDamage = false;
	self.RHA = self:GetNumberValue("RHA");
	self.MPA = self:GetNumberValue("MPA");
	self.desiredDamage = self:GetNumberValue("Damage");
	self.desiredWounds = self:GetNumberValue("Wounds");
	
	self.Vel = Vector(self.Vel.X, self.Vel.Y) * RangeRand(0.9,1.1)
	self.canTravel = true
	self.ricochetCount = 0
	self.ricochetCountMax = 1
	
	self.flyby = true
	self.flybyTimer = Timer()
	
	self.tracer = 3 * math.random(0,1)
	self.smoke = false
	
	self.alwaysTracer = self:NumberValueExists("AlwaysTracer") and self:GetNumberValue("AlwaysTracer") == 1
	self.noSmoke = self:NumberValueExists("NoSmoke") and self:GetNumberValue("NoSmoke") == 1
	self.noTracer = self:NumberValueExists("NoTracer") and self:GetNumberValue("NoTracer") == 1
	
	--if self.smoke then
	-- FANCY TRAIL BY FILIPEX2000
	self.trailM = 0; -- DONT TOUCH
	self.trailMTarget = RangeRand(-1,1);
	self.trailMProgress = 0; -- DONT TOUCH
	
	self.trailGProgress = 0; -- DONT TOUCH
	self.trailGLoss = -0.5; -- Trail lifetime offset (lower number, stays 100% longer)
	
	-- FINE TUNE!
	self.LifetimeMulti = 0.9; -- How long the particles stay alive
	self.TrailRandomnessMulti = 0.5; -- Wave modulation target speed
	self.TrailWavenessSpeed = 0.5; -- Wave modulation controller speed
	--end
	
	--self.soundLoop = math.random(0,100) < 50 and AudioMan:PlaySound("Sandstorm.rte/Effects/Sounds/Ammunition/Bullet/Flyby/Loop"..math.random(2,4)..".ogg", self.Pos, 0, -1, 100, 1, 500, false) or nil
	local light = "Sandstorm.rte/Effects/Sounds/Ammunition/Bullet/Flyby/Loop3.ogg"
	local deep = "Sandstorm.rte/Effects/Sounds/Ammunition/Bullet/Flyby/Loop4.ogg"
	--self.soundLoop = math.random(0,100) < 70 and AudioMan:PlaySound(math.random(0,100) < 20 and light or deep, self.Pos, 0, -1, 100, 1, 500, false) or nil
	self.soundLoop = nil -- Pawnis didn't like it >:-(
	self.soundPitch = RangeRand(0.8,1.2)
end

function Update(self)
	self.Vel = Vector(self.Vel.X, self.Vel.Y) + SceneMan.GlobalAcc * TimerMan.DeltaTimeSecs
	
	if self.soundLoop then
		AudioMan:SetSoundPosition(self.soundLoop, self.Pos)
		AudioMan:SetSoundPitch(self.soundLoop, (self.soundPitch + 0.5) * 2.5)
		self.soundPitch = self.soundPitch / (1 + TimerMan.DeltaTimeSecs * 6.0) -- Pitch Shift
	end
	
	if self.canTravel then
		local travelVel = (Vector(self.Vel.X, self.Vel.Y) * GetPPM() * TimerMan.DeltaTimeSecs)--:RadRotate(RangeRand(-1,1) * 0.05) -- Weird effect
		local travel = travelVel
		
		local endPos = Vector(self.Pos.X, self.Pos.Y); -- This value is going to be overriden by function below, this is the end of the ray
		self.ray = SceneMan:CastObstacleRay(self.Pos, travelVel, Vector(0, 0), endPos, 0 , self.Team, 0, 2)
		
		travel = SceneMan:ShortestDistance(self.Pos,endPos,SceneMan.SceneWrapsX)
		
		-- Flyby sound (epic haxx)
		-- if self.flyby and self.flybyTimer:IsPastSimMS(80) and self.Vel.Magnitude > 40 then
			-- --local cameraPos = Vector(SceneMan:GetScrollTarget(0).X, SceneMan:GetScrollTarget(0).Y)
			
			-- local controlledActor = ActivityMan:GetActivity():GetControlledActor(0);
			
			-- if controlledActor then
	
			
				-- local distA = SceneMan:ShortestDistance(self.Pos,controlledActor.Pos,SceneMan.SceneWrapsX).Magnitude
				-- local vectorA = SceneMan:ShortestDistance(self.Pos,controlledActor.Pos,SceneMan.SceneWrapsX)
				-- local distAMin = math.random(50,100)		
				
				-- if distA < distAMin and SceneMan:CastObstacleRay(self.Pos, vectorA, Vector(0, 0), Vector(0, 0), controlledActor.ID, -1, 128, 8) < 0 then
					-- self.flyby = false
					
					-- self.supersonicIndoorsFlyBy:Play(controlledActor.Pos);
					
					-- if ToActor(controlledActor).Team ~= self.Team then
						-- ToActor(controlledActor):SetNumberValue("Sandstorm Bullet Suppressed", 1);
					-- end
				-- else
					-- local offset = Vector(travelVel.X, travelVel.Y) * RangeRand(0.2,1.0)
					-- local distB = SceneMan:ShortestDistance(self.Pos + offset,controlledActor.Pos,SceneMan.SceneWrapsX).Magnitude
					-- local distBMin = math.random(30,50)
					-- if distB < distBMin and SceneMan:CastObstacleRay(self.Pos, vectorA, Vector(0, 0), Vector(0, 0), controlledActor.ID, -1, 128, 8) < 0 then
						-- self.flyby = false
						
						-- self.supersonicIndoorsAltFlyBy:Play(controlledActor.Pos);
						
						-- if ToActor(controlledActor).Team ~= self.Team then
							-- ToActor(controlledActor):SetNumberValue("Sandstorm Bullet Suppressed", 1);
						-- end
					-- end
				-- end
			-- end
			
			-- --local s = self.UniqueID % 7 + 1
			-- --PrimitiveMan:DrawCirclePrimitive(cameraPos, s, 5)
		-- end
		
		-- Tracer Trail
		
		if not self.noTracer and ((math.random(1,5) < 2 and self.tracer > 0 and self.ricochetCount < 1) or (self.alwaysTracer and math.random(1,5) <= 2)) then
			local maxi = travel.Magnitude/ GetPPM() * 1.5
			for i = 0, maxi do
				--PrimitiveMan:DrawCirclePrimitive(self.Pos + travel / maxi * i, 2 + i / maxi * 3, 166);
				local particle = CreateMOPixel("Real Bullet Glow");
				particle.Pos = self.Pos + travel / maxi * i * RangeRand(1.1,0.9);
				--particle.Vel = travel:SetMagnitude(30)
				--particle.EffectRotAngle = self.RotAngle;
				particle.EffectRotAngle = self.Vel.AbsRadAngle;
				MovableMan:AddParticle(particle);
			end
			self.tracer = self.tracer - 1
			if not self.smoke then
				self.smoke = math.random(1,8) < 2
			end
		end
		
		--PrimitiveMan:DrawLinePrimitive(self.Pos, self.Pos + travel, 5);
		if self.ray > -1 then
			local canDamage = false
			local hitGFXType = 0-- 0 Default, 1 Flesh, 2 Concrete, 3 Dirt, 4 Sand, 5 Metal
			local hitGFX = {"Real Bullet Hit Effect Flesh", "Real Bullet Hit Effect Concrete", "Real Bullet Hit Effect Dirt", "Real Bullet Hit Effect Sand", "Real Bullet Hit Effect Metal"}
			self.Pos = endPos
			
			if self.soundLoop ~= nil then
				self.soundLoop:Stop()
				self.soundLoop = nil
			end
			
			self.Vel = self.Vel * 0.85
			local hitMO = false
			for i = -1, 1 do
				local checkOrigin = Vector(self.Pos.X, self.Pos.Y) + Vector(self.Vel.X,self.Vel.Y):SetMagnitude(i)
				local checkPix = SceneMan:GetMOIDPixel(checkOrigin.X, checkOrigin.Y)
				if checkPix and checkPix ~= rte.NoMOID and MovableMan:GetMOFromID(checkPix).Team ~= self.Team then
					local MO = ToMOSRotating(MovableMan:GetMOFromID(checkPix))
					self.MOHit = MO;
					local woundName = MO:GetEntryWoundPresetName()
					local woundNameExit = MO:GetExitWoundPresetName()
					hitMO = true
					self.woundOffset = (SceneMan:ShortestDistance(MO.Pos, checkOrigin + Vector(self.Vel.X, self.Vel.Y):SetMagnitude(1), SceneMan.SceneWrapsX)):RadRotate(MO.RotAngle * -1.0)
					
					
					-- epic pawnis armorpen
					if MO:NumberValueExists("ArmorRHA") then -- if we have hit an MO that has this value, it has our armor system
						self.useArmorSystem = true; -- tell the code to spawn proper damage pixel
						local MORHA = MO:GetNumberValue("ArmorRHA");
						local MOMPA = MO:GetNumberValue("ArmorMPA");
						
						-- ROUND ONE: RHA VS RHA
						
						local modifiedRHA = self.RHA - MORHA;
						self.modifiedDamage = self.desiredDamage * (modifiedRHA / self.RHA)
						self.modifiedWounds = math.floor((self.desiredWounds * (modifiedRHA / self.RHA)) + 0.5) -- ghetto round
						if self.modifiedWounds < 1 then
							self.modifiedWounds = 1;
						end
						if self.modifiedDamage < 1 then -- bad armor pen, we're going blunt
							-- ROUND TWO: MPA VS MPA
							self.bluntDamage = true; -- tell code later not to spawn any pixel
							local modifiedMPA = self.MPA - MOMPA;
							self.modifiedDamage = (self.desiredDamage * 0.7) * (modifiedMPA / self.MPA)
							if self.modifiedDamage < 1 then
								self.modifiedDamage = 0.3; -- morale damage
							end
						end
					end
						
					
					if string.find(MO.Material.PresetName,"Flesh") or (woundName and string.find(woundName,"Flesh")) or (woundNameExit and string.find(woundNameExit,"Flesh")) then
						hitGFXType = 1
						local maxi = 1
						if self:NumberValueExists("Wounds") then
							maxi = self:GetNumberValue("Wounds");
						end
						if self.modifiedWounds then
							maxi = self.modifiedWounds;
						end
						if math.random(1,4) <= maxi then
							MO:AddWound(CreateAEmitter("Sandstorm Blood Taint"), self.woundOffset, true)
						end
					elseif string.find(MO.Material.PresetName,"Metal") or (woundName and string.find(woundName,"Dent")) or (woundNameExit and string.find(woundNameExit,"Dent")) then
						hitGFXType = 5
					end
					break
				end
			end
			local hitVel = Vector(self.Vel.X, self.Vel.Y)
			if hitMO then-- check MOs first
				canDamage = true
				self.ToDelete = true
			else -- ricochet
				if self.ricochetCount < self.ricochetCountMax then
					-- Normal approximation by filipex2000
					-- Does magic stuff
					-- haxx
					--self.canTravel = false
					local detections = 0
					local maxi = 7
					local normal = Vector(0,0)
					local materialStrength = 0
					local materialID = 0
					for i = 0, maxi do
						local checkVec = Vector(3,0):RadRotate(math.pi * 2 / maxi * i)
						local checkOrigin = Vector(self.Pos.X, self.Pos.Y) + checkVec
						local checkPix = SceneMan:GetTerrMatter(checkOrigin.X, checkOrigin.Y)
						--[[
						if checkPix > 0 then
							PrimitiveMan:DrawLinePrimitive(self.Pos + checkVec, self.Pos + checkVec, 13);
						else
							PrimitiveMan:DrawLinePrimitive(self.Pos + checkVec, self.Pos + checkVec, 5);
							normal = (Vector(normal.X, normal.Y) + Vector(checkVec.X, checkVec.Y)) * 0.5
						end]]
						if checkPix == 0 then
							normal = (Vector(normal.X, normal.Y) + Vector(checkVec.X, checkVec.Y)) * 0.5
						else
							materialStrength = materialStrength + SceneMan:GetMaterialFromID(checkPix).StructuralIntegrity
							detections = detections + 1
							materialID = checkPix
						end
					end
					-- Compare Materials
					local material = SceneMan:GetMaterialFromID(materialID)
					if string.find(material.PresetName,"Flesh") then -- Lord have mercy
						hitGFXType = 1
					elseif string.find(material.PresetName,"Concrete") or string.find(material.PresetName,"Rock") then
						hitGFXType = 2
					elseif string.find(material.PresetName,"Dirt") or string.find(material.PresetName,"Soil") then
						hitGFXType = 3
					elseif string.find(material.PresetName,"Sand") then
						hitGFXType = 4
					elseif string.find(material.PresetName,"Metal") then
						hitGFXType = 5
					end
					
					if detections > 0 then
						materialStrength = math.min(materialStrength / maxi / 132, 1)
						normal = normal:SetMagnitude(1.0)
						normal = normal:RadRotate(RangeRand(-1,1) * 0.2) --Randomize normal to spice things up
						--PrimitiveMan:DrawLinePrimitive(self.Pos, self.Pos + normal * 5.0, 122); -- Debug
						local diff = normal - Vector(self.Vel.X, self.Vel.Y):SetMagnitude(1.0)
						self.Vel = (Vector(self.Vel.X, self.Vel.Y) * RangeRand(0.4,0.8) + normal:SetMagnitude(self.Vel.Magnitude) * RangeRand(0.1,0.4)) * RangeRand(0.5,1.0) * materialStrength
						
						self.ricochetCount = self.ricochetCount + 1
						self.smoke = math.random(1,2) < 2
						if self.Vel.Magnitude < 10 then
							self.ToDelete = true
							canDamage = true
						else
							canDamage = true
							if diff.Magnitude < 1.7 and ((self.smoke and math.random(1,4) <= 2) or self.alwaysTracer) then
								self.ricochetSound:Play(self.Pos);
							end
						end
					else
						canDamage = true
						self.ToDelete = true
					end
				else
					self.ToDelete = true
				end
			end
			
			if canDamage then
				local maxi = 1
				if self:NumberValueExists("Wounds") then
					maxi = self:GetNumberValue("Wounds");
				end
				if self.modifiedWounds then
					maxi = self.modifiedWounds;
				end
				if self.bluntDamage then
					local woundName = self.MOHit:GetEntryWoundPresetName()
					self.MOHit:AddWound(CreateAEmitter(woundName), self.woundOffset, false);
					local actor = IsActor(self.MOHit:GetRootParent()) and ToActor(self.MOHit:GetRootParent()) or nil;
					local friendlyFireModifier = actor.Team == self.origTeam and 0.3 or 1;
					if actor and self.modifiedDamage > 0 then
						actor.Health = actor.Health - (self.modifiedDamage * friendlyFireModifier);
						actor:SetNumberValue("Sandstorm Bullet Suppressed", 1);
						if friendlyFireModifier ~= 1 then
							actor:SetNumberValue("Sandstorm Friendly Fire", 1);
						end
					end
				else
					local friendlyFireModifier = 1;
					if self.MOHit then
						local actor = IsActor(self.MOHit:GetRootParent()) and ToActor(self.MOHit:GetRootParent()) or nil;
						friendlyFireModifier = actor.Team == self.origTeam and 0.3 or 1;
						if friendlyFireModifier ~= 1 then
							actor:SetNumberValue("Sandstorm Friendly Fire", 1);
						end
					end
					for i = 1, maxi do
						local pixel = CreateMOPixel("Real Bullet Damage");
						pixel.Vel = Vector(hitVel.X, hitVel.Y) * 0.6;--Vector(self.Vel.X, self.Vel.Y) * 0.6;
						pixel.Sharpness = self.Sharpness
						pixel.Mass = self.Mass
						pixel.Pos = self.Pos - Vector(self.Vel.X,self.Vel.Y):SetMagnitude(2)--self.Pos - Vector(2, 0):RadRotate(self.RotAngle);
						pixel.Team = self.Team
						--pixel.IgnoresTeamHits = true;
						
						-- we assume in the following code that the wound's burstdamage is 5.
						if self.useArmorSystem then
							local woundName = self.MOHit:GetEntryWoundPresetName()
							local woundNameExit = self.MOHit:GetExitWoundPresetName()
							self.MOHit:AddWound(CreateAEmitter(woundName), self.woundOffset, false);
							pixel.WoundDamageMultiplier = ((self.modifiedDamage/5) / maxi) * friendlyFireModifier;
							pixel:SetWhichMOToNotHit(self.MOHit, -1)
							-- print(self.MOHit.PresetName)
							
						else
							pixel.WoundDamageMultiplier = ((self.desiredDamage/5) / maxi) * friendlyFireModifier;
						end
						MovableMan:AddParticle(pixel);
					end
				end
				
				-- if self.MOHit then
					-- print("hitmo: " .. tostring(self.MOHit))
				-- end
				-- print("armorsystem: " .. tostring(self.useArmorSystem))
				-- print("blunt: " .. tostring(self.bluntDamage))
				-- print("modified damage: " .. tostring(self.modifiedDamage))
				-- print("modified wounds: " .. tostring(self.modifiedWounds))
				
				local effect = CreateMOSRotating(hitGFXType == 0 and "Real Bullet Hit Effect Default" or hitGFX[hitGFXType]);
				if effect then
					effect.Pos = self.Pos - Vector(self.Vel.X,self.Vel.Y):SetMagnitude(1)
					MovableMan:AddParticle(effect);
					effect:GibThis();
				end
			end
			
			if self.Vel.Magnitude < 10 then
				self.ToDelete = true
			end
		else
			self.Pos = endPos
		end
		
		-- Epic Trail
		
		if ((self.smoke) or self.alwaysTracer) and not self.noSmoke then
			local smoke
			local offset = travel
			local trailLength = math.floor((offset.Magnitude+0.5) / 5)
			for i = 1, trailLength do
				if RangeRand(0,1) < (1 - self.trailGLoss) then
					--smoke = CreateMOPixel("Real Bullet Micro Smoke Ball "..math.random(1,4));
					smoke = CreateMOPixel("Real Bullet Micro Smoke Ball "..math.random(1,4));
					if smoke then
						
						local a = 10 * self.TrailWavenessSpeed;
						local b = 5 * self.TrailRandomnessMulti;
						self.trailM = (self.trailM + self.trailMTarget * TimerMan.DeltaTimeSecs * a) / (1 + TimerMan.DeltaTimeSecs * a)
						self.trailMProgress = self.trailMProgress + TimerMan.DeltaTimeSecs * b;
						if self.trailMProgress > 1 then
							self.trailMTarget = RangeRand(-1,1);
							self.trailMProgress = self.trailMProgress - 1;
						end
						
						smoke.Pos = self.Pos - offset * (1 - (i/trailLength)) * RangeRand(0.9, 1.1);
						smoke.Vel = self.Vel * self.trailGProgress * 0.25 + Vector(0, self.trailM * 12  * RangeRand(0.9, 1.1) * self.trailGProgress):RadRotate(Vector(self.Vel.X, self.Vel.Y).AbsRadAngle);-- * RangeRand(0.5, 1.2) * 0.5;
						smoke.Lifetime = smoke.Lifetime * RangeRand(0.1, 1.9) * (1.0 + self.trailGProgress) * 0.3 * self.LifetimeMulti;
						smoke.GlobalAccScalar = RangeRand(-1, 1) * 0.15; -- Go up and down
						MovableMan:AddParticle(smoke);
						
						local c = 1;
						self.trailGProgress = math.min(self.trailGProgress + TimerMan.DeltaTimeSecs * c, 1.0)
						self.trailGLoss = math.min(self.trailGLoss + TimerMan.DeltaTimeSecs * 0.65, 1.0);
					end
				end
			end
		end
		
	end
end



function Destroy(self)
	if self.soundLoop ~= nil then
		self.soundLoop:Stop()
		self.soundLoop = nil
	end
end