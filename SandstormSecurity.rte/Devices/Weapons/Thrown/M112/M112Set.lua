function Create(self)
	
	self.lifeTimer = Timer();
	self.fuseTime = math.random(600, 800);
	
	self.impactTimer = Timer();
	self.impactCooldown = 0;
	
	self.lastVel = Vector(0, 0)
	
	self.concreteHit = {["IDs"] = {[12] = "Exists", [177] = "Exists"},
	["Hit"] = nil};
	self.concreteHit.Hit = CreateSoundContainer("DevicesWeaponsSharedSoundsBombM112ImpactConcrete", "Sandstorm.rte");
	
	--
	
	self.dirtHit = {["IDs"] = {[9] = "Exists", [10] = "Exists", [11] = "Exists", [128] = "Exists"},
	["Hit"] = nil};
	self.dirtHit.Hit = CreateSoundContainer("DevicesWeaponsSharedSoundsBombM112ImpactDirt", "Sandstorm.rte");
	
	--
	
	self.sandHit = {["IDs"] = {[8] = "Exists"},
	["Hit"] = nil};
	self.sandHit.Hit = CreateSoundContainer("DevicesWeaponsSharedSoundsBombM112ImpactSand", "Sandstorm.rte");
	
	--
	
	self.solidMetalHit = {["IDs"] = {[178] = "Exists", [182] = "Exists"},
	["Hit"] = nil};
	self.solidMetalHit.Hit = CreateSoundContainer("DevicesWeaponsSharedSoundsBombM112ImpactSolidMetal", "Sandstorm.rte");
	
end

function OnCollideWithTerrain(self, terrainID)	

	if self.PinStrength > 0 then return end
	
	if self.impactSoundAllowed ~= false then
		self.impactSoundAllowed = false;
		if self.workingTravelImpulse.Magnitude > 5 then
			if self.dirtHit.IDs[terrainID] ~= nil then
				self.dirtHit.Hit:Play(self.Pos);
			elseif self.sandHit.IDs[terrainID] ~= nil then
				self.sandHit.Hit:Play(self.Pos);
			elseif self.concreteHit.IDs[terrainID] ~= nil then
				self.concreteHit.Hit:Play(self.Pos);
			elseif self.solidMetalHit.IDs[terrainID] ~= nil then
				self.solidMetalHit.Hit:Play(self.Pos);
			else -- default to concrete
				self.concreteHit.Hit:Play(self.Pos);
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
