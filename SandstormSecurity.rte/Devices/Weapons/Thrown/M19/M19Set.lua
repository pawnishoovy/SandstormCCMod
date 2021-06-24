function Create(self)
	
	self.lifeTimer = Timer();
	self.fuseTime = math.random(600, 800);
	
	self.impactTimer = Timer();
	self.impactCooldown = 0;
	
	self.lastVel = Vector(0, 0)
	
	self.checkTimer = Timer();
	self.checkDelay = 1000;
	self.checkI = 0
	
	self.terrainSounds = {
	Impact = {[12] = CreateSoundContainer("M19 Impact Concrete", "Sandstorm.rte"),
			[164] = CreateSoundContainer("M19 Impact Concrete", "Sandstorm.rte"),
			[177] = CreateSoundContainer("M19 Impact Concrete", "Sandstorm.rte"),
			[9] = CreateSoundContainer("M19 Impact Dirt", "Sandstorm.rte"),
			[10] = CreateSoundContainer("M19 Impact Dirt", "Sandstorm.rte"),
			[11] = CreateSoundContainer("M19 Impact Dirt", "Sandstorm.rte"),
			[128] = CreateSoundContainer("M19 Impact Dirt", "Sandstorm.rte"),
			[6] = CreateSoundContainer("M19 Impact Sand", "Sandstorm.rte"),
			[8] = CreateSoundContainer("M19 Impact Sand", "Sandstorm.rte"),
			[178] = CreateSoundContainer("M19 Impact SolidMetal", "Sandstorm.rte"),
			[179] = CreateSoundContainer("M19 Impact SolidMetal", "Sandstorm.rte"),
			[180] = CreateSoundContainer("M19 Impact SolidMetal", "Sandstorm.rte"),
			[181] = CreateSoundContainer("M19 Impact SolidMetal", "Sandstorm.rte"),
			[182] = CreateSoundContainer("M19 Impact SolidMetal", "Sandstorm.rte")}}
	
end

function OnCollideWithTerrain(self, terrainID)	

	if self.PinStrength > 0 then return end
	
	if self.impactSoundAllowed ~= false then
		self.impactSoundAllowed = false;
		if self.workingTravelImpulse.Magnitude > 5 then
			if self.terrainSounds.Impact[terrainID] ~= nil then
				self.terrainSounds.Impact[terrainID]:Play(self.Pos);
			else -- default to concrete
				self.terrainSounds.Impact[177]:Play(self.Pos);
			end
		end
	end
end

function Update(self)
	self.ToSettle = false
	self:NotResting()
	
	if self.Age > 360000 then
		self.ToDelete = true
	end
	
	self.workingTravelImpulse = (self.Vel - self.lastVel) / TimerMan.DeltaTimeSecs * self.Vel.Magnitude * 0.1
	self.lastVel = Vector(self.Vel.X, self.Vel.Y)

	if self.impactTimer:IsPastSimMS(self.impactCooldown) then
		self.impactSoundAllowed = true;
		self.impactTimer:Reset();
		self.impactCooldown = 300; -- increase impact cooldown from first 0
	end

	if self.checkTimer:IsPastSimMS(self.checkDelay) and self.Vel.Magnitude < 5 then
		self.checkDelay = 100;
		self.checkTimer:Reset();
		
		self.checkI = self.checkI % 2 + 1
		
		local checkOrigin = Vector(self.Pos.X, self.Pos.Y) + Vector((self.checkI - 1) * 3, - 5)--:RadRotate(self.RotAngle)
		local checkPix = SceneMan:GetMOIDPixel(checkOrigin.X, checkOrigin.Y)
		PrimitiveMan:DrawLinePrimitive(checkOrigin, checkOrigin, 5)
		
		local stepper = nil
		if checkPix ~= 255 then
			stepper = MovableMan:GetMOFromID(checkPix);
		end
		
		--
		--[[
		local rayVector = Vector(0, -5):RadRotate(self.RotAngle);
		local ray1 = SceneMan:CastMORay(self.Pos + Vector(-3, -1):RadRotate(self.RotAngle), rayVector, self.ID, -2, 0, true, 1); -- -2 = no team ignored, self.ID = ignore self
		PrimitiveMan:DrawLinePrimitive(self.Pos + Vector(-3, -1):RadRotate(self.RotAngle), self.Pos + Vector(-3, 0):RadRotate(self.RotAngle) + rayVector, 5)
		local ray2 = SceneMan:CastMORay(self.Pos + Vector(3, -1):RadRotate(self.RotAngle), rayVector, self.ID, -2, 0, true, 1);
		PrimitiveMan:DrawLinePrimitive(self.Pos + Vector(3, -1):RadRotate(self.RotAngle), self.Pos + Vector(3, 0):RadRotate(self.RotAngle) + rayVector, 5)
		local ray3 = SceneMan:CastMORay(self.Pos, rayVector, self.ID, -2, 0, true, 1);
		PrimitiveMan:DrawLinePrimitive(self.Pos, self.Pos + rayVector, 5)
		if ray1 ~= nil then
			self.object = MovableMan:GetMOFromID(ray1);
		end
		if ray2 ~= nil then
			self.object = MovableMan:GetMOFromID(ray2);
		end
		if ray3 ~= nil then
			self.object = MovableMan:GetMOFromID(ray3);
		end]]
		
		if stepper then
			stepperParent = MovableMan:GetMOFromID(stepper.RootID); -- get the torso/base part
			if (stepperParent and stepperParent.Mass > 10) or stepper.Mass > 10 then -- if its heavy enough
				self:EraseFromTerrain()
				self:GibThis();
			end
		end
	end
	
end
