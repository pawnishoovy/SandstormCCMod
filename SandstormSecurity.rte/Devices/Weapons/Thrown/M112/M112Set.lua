function Create(self)
	
	self.lifeTimer = Timer();
	self.fuseTime = math.random(600, 800);
	
	self.impactTimer = Timer();
	self.impactCooldown = 0;
	
	self.lastVel = Vector(0, 0)
	
	local dir = "Sandstorm.rte/Devices/Weapons/Shared/Sounds/Bomb/"
	
	self.concreteHit = {["IDs"] = {[12] = "Exists", [177] = "Exists"},
	["Hit"] = nil};
	self.concreteHit.Hit = {["Variations"] = 3,
	["Path"] = dir.."M112/ImpactConcrete"};
	
	--
	
	self.dirtHit = {["IDs"] = {[9] = "Exists", [10] = "Exists", [11] = "Exists", [128] = "Exists"},
	["Hit"] = nil};
	self.dirtHit.Hit = {["Variations"] = 3,
	["Path"] = dir.."M112/ImpactDirt"};
	
	--
	
	self.sandHit = {["IDs"] = {[8] = "Exists"},
	["Hit"] = nil};
	self.sandHit.Hit = {["Variations"] = 3,
	["Path"] = dir.."M112/ImpactSand"};
	
	--
	
	self.solidMetalHit = {["IDs"] = {[178] = "Exists", [182] = "Exists"},
	["Hit"] = nil};
	self.solidMetalHit.Hit = {["Variations"] = 3,
	["Path"] = dir.."M112/ImpactSolidMetal"};
	
end

function OnCollideWithTerrain(self, terrainID)	

	if self.PinStrength > 0 then return end
	
	if self.impactSoundAllowed ~= false then
		self.impactSoundAllowed = false;
		if self.workingTravelImpulse.Magnitude > 5 then
			if self.dirtHit.IDs[terrainID] ~= nil then
				self.hitSound = AudioMan:PlaySound(self.dirtHit.Hit.Path .. math.random(1, self.dirtHit.Hit.Variations) .. ".wav", self.Pos, -1, 0, 130, 1, 170, false);
			elseif self.sandHit.IDs[terrainID] ~= nil then
				self.hitSound = AudioMan:PlaySound(self.sandHit.Hit.Path .. math.random(1, self.sandHit.Hit.Variations) .. ".wav", self.Pos, -1, 0, 130, 1, 170, false);
			elseif self.concreteHit.IDs[terrainID] ~= nil then
				self.hitSound = AudioMan:PlaySound(self.concreteHit.Hit.Path .. math.random(1, self.concreteHit.Hit.Variations) .. ".wav", self.Pos, -1, 0, 130, 1, 170, false);
			elseif self.solidMetalHit.IDs[terrainID] ~= nil then
				self.hitSound = AudioMan:PlaySound(self.solidMetalHit.Hit.Path .. math.random(1, self.solidMetalHit.Hit.Variations) .. ".wav", self.Pos, -1, 0, 130, 1, 170, false);
			else -- default to concrete
				self.hitSound = AudioMan:PlaySound(self.concreteHit.Hit.Path .. math.random(1, self.concreteHit.Hit.Variations) .. ".wav", self.Pos, -1, 0, 130, 1, 170, false);
			end
		end
	end
end

function Update(self)
	self.ToSettle = false
	self:NotResting()
	
	if self.Age > 30000 then
		self.ToDelete = true
	end
	
	self.workingTravelImpulse = (self.Vel - self.lastVel) / TimerMan.DeltaTimeSecs * self.Vel.Magnitude * 0.1
	self.lastVel = Vector(self.Vel.X, self.Vel.Y)

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
