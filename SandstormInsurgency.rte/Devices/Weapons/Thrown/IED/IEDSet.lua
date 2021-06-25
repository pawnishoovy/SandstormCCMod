function Create(self)
	
	self.lifeTimer = Timer();
	self.fuseTime = math.random(600, 800);
	
	self.impactTimer = Timer();
	self.impactCooldown = 0;
	
	self.lastVel = Vector(0, 0)
	
	self.terrainSounds = {
	Impact = {[12] = CreateSoundContainer("IED Impact Concrete", "Sandstorm.rte"),
			[164] = CreateSoundContainer("IED Impact Concrete", "Sandstorm.rte"),
			[177] = CreateSoundContainer("IED Impact Concrete", "Sandstorm.rte"),
			[9] = CreateSoundContainer("IED Impact Dirt", "Sandstorm.rte"),
			[10] = CreateSoundContainer("IED Impact Dirt", "Sandstorm.rte"),
			[11] = CreateSoundContainer("IED Impact Dirt", "Sandstorm.rte"),
			[128] = CreateSoundContainer("IED Impact Dirt", "Sandstorm.rte"),
			[6] = CreateSoundContainer("IED Impact Sand", "Sandstorm.rte"),
			[8] = CreateSoundContainer("IED Impact Sand", "Sandstorm.rte"),
			[178] = CreateSoundContainer("IED Impact SolidMetal", "Sandstorm.rte"),
			[179] = CreateSoundContainer("IED Impact SolidMetal", "Sandstorm.rte"),
			[180] = CreateSoundContainer("IED Impact SolidMetal", "Sandstorm.rte"),
			[181] = CreateSoundContainer("IED Impact SolidMetal", "Sandstorm.rte"),
			[182] = CreateSoundContainer("IED Impact SolidMetal", "Sandstorm.rte")}}
	
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
	
	if self.Age > 90000 then
		self.ToDelete = true
	end
	
	self.workingTravelImpulse = (self.Vel - self.lastVel) / TimerMan.DeltaTimeSecs * self.Vel.Magnitude * 0.1
	self.lastVel = Vector(self.Vel.X, self.Vel.Y)
	
	if not self:NumberValueExists("Set") then
		if self.lastVel.Magnitude > 3 then
			self.Live = true;
		else
			self.Live = false;
		end
	end

	if self.impactTimer:IsPastSimMS(self.impactCooldown) then
		self.impactSoundAllowed = true;
		self.impactTimer:Reset();
		self.impactCooldown = 300; -- increase impact cooldown from first 0
	end
	
	--if self:NumberValueExists("Fuse") then
	--	PrimitiveMan:DrawLinePrimitive(self.Pos, self.Pos + self.Vel, 5)
	--end
	
	if self:NumberValueExists("Fuse") then
		if self.lifeTimer:IsPastSimMS(self.fuseTime) then
			self:GibThis();
		end
	else
		self.lifeTimer:Reset()
	end
end
