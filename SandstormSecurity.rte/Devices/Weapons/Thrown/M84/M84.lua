function Create(self)
	
	self.lifeTimer = Timer();
	self.fuseTime = math.random(4000, 5000);
	
	self.impactTimer = Timer();
	self.impactCooldown = 0;
	
	self.lastVel = Vector(0, 0)
	
	self.Rolls = 0;
	
	local dir = "Sandstorm.rte/Devices/Weapons/Shared/Sounds/Grenade/"
	
	self.concreteHit = {["IDs"] = {[12] = "Exists", [177] = "Exists"},
	["Hard"] = nil, ["Medium"] = nil, ["Soft"] = nil};
	self.concreteHit.Hard = {["Variations"] = 9,
	["Path"] = dir.."Flash/Concrete/HitHardConcrete"};
	self.concreteHit.Medium = {["Variations"] = 9,
	["Path"] = dir.."Flash/Concrete/HitMediumConcrete"};
	self.concreteHit.Soft = {["Variations"] = 9,
	["Path"] = dir.."Flash/Concrete/HitSoftConcrete"};
	
	self.concreteRoll = {["Variations"] = 8,
	["Path"] = dir.."Frag/Concrete/RollConcrete"};
	
	--
	
	self.dirtHit = {["IDs"] = {[9] = "Exists", [10] = "Exists", [11] = "Exists", [128] = "Exists"},
	["Hard"] = nil, ["Medium"] = nil, ["Soft"] = nil};
	self.dirtHit.Hard = {["Variations"] = 8,
	["Path"] = dir.."Flash/Dirt/HitHardDirt"};
	self.dirtHit.Medium = {["Variations"] = 8,
	["Path"] = dir.."Flash/Dirt/HitMediumDirt"};
	self.dirtHit.Soft = {["Variations"] = 9,
	["Path"] = dir.."Flash/Dirt/HitSoftDirt"};
	
	self.dirtRoll = {["Variations"] = 9,
	["Path"] = dir.."Frag/Dirt/RollDirt"};
	
	--
	--[[
	self.sandHit = {["IDs"] = {[6] = "Exists", [8] = "Exists"},
	["Hard"] = nil, ["Medium"] = nil, ["Soft"] = nil};
	self.sandHit.Hard = {["Variations"] = 6,
	["Path"] = dir.."Frag/Sand/HitHardSand"};
	self.sandHit.Medium = {["Variations"] = 6,
	["Path"] = dir.."Frag/Sand/HitMediumSand"};
	self.sandHit.Soft = {["Variations"] = 6,
	["Path"] = dir.."Frag/Sand/HitSoftSand"};
	
	self.sandRoll = {["Variations"] = 6,
	["Path"] = dir.."Frag/Sand/RollSand"};]]
	
	self.sandHit = {["IDs"] = {[8] = "Exists"},
	["Hard"] = nil, ["Medium"] = nil, ["Soft"] = nil};
	self.sandHit.Hard = {["Variations"] = 8,
	["Path"] = dir.."Flash/Dirt/HitHardDirt"};
	self.sandHit.Medium = {["Variations"] = 8,
	["Path"] = dir.."Flash/Dirt/HitMediumDirt"};
	self.sandHit.Soft = {["Variations"] = 8,
	["Path"] = dir.."Flash/Dirt/HitSoftDirt"};
	
	self.sandRoll = {["Variations"] = 9,
	["Path"] = dir.."Frag/Dirt/RollDirt"};
	
	--
	
	self.solidMetalHit = {["IDs"] = {[178] = "Exists", [182] = "Exists"},
	["Hard"] = nil, ["Medium"] = nil, ["Soft"] = nil};
	self.solidMetalHit.Hard = {["Variations"] = 5,
	["Path"] = dir.."Flash/SolidMetal/HitHardSolidMetal"};
	self.solidMetalHit.Medium = {["Variations"] = 4,
	["Path"] = dir.."Flash/SolidMetal/HitMediumSolidMetal"};
	self.solidMetalHit.Soft = {["Variations"] = 8,
	["Path"] = dir.."Flash/SolidMetal/HitSoftSolidMetal"};
	
	self.solidMetalRoll = {["Variations"] = 10,
	["Path"] = dir.."Frag/SolidMetal/RollSolidMetal"};
	
	self.frm = 0
end

function OnCollideWithTerrain(self, terrainID)	

	-- LOTS OF DUPE CODE TODO FIX
	
	if self.impactSoundAllowed ~= false then
		self.impactSoundAllowed = false;
		if self.workingTravelImpulse.Magnitude > 40 then
			if self.dirtHit.IDs[terrainID] ~= nil then
				self.hitSound = AudioMan:PlaySound(self.dirtHit.Hard.Path .. math.random(1, self.dirtHit.Hard.Variations) .. ".ogg", self.Pos, -1, 0, 130, 1, 170, false);
			elseif self.sandHit.IDs[terrainID] ~= nil then
				self.hitSound = AudioMan:PlaySound(self.sandHit.Hard.Path .. math.random(1, self.sandHit.Hard.Variations) .. ".ogg", self.Pos, -1, 0, 130, 1, 170, false);
			elseif self.concreteHit.IDs[terrainID] ~= nil then
				self.hitSound = AudioMan:PlaySound(self.concreteHit.Hard.Path .. math.random(1, self.concreteHit.Hard.Variations) .. ".ogg", self.Pos, -1, 0, 130, 1, 170, false);
			elseif self.solidMetalHit.IDs[terrainID] ~= nil then
				self.hitSound = AudioMan:PlaySound(self.solidMetalHit.Hard.Path .. math.random(1, self.solidMetalHit.Hard.Variations) .. ".ogg", self.Pos, -1, 0, 130, 1, 170, false);
			else -- default to concrete
				self.hitSound = AudioMan:PlaySound(self.concreteHit.Hard.Path .. math.random(1, self.concreteHit.Hard.Variations) .. ".ogg", self.Pos, -1, 0, 130, 1, 170, false);
			end
		elseif self.workingTravelImpulse.Magnitude > 20 then
			if self.dirtHit.IDs[terrainID] ~= nil then
				self.hitSound = AudioMan:PlaySound(self.dirtHit.Medium.Path .. math.random(1, self.dirtHit.Medium.Variations) .. ".ogg", self.Pos, -1, 0, 130, 1, 170, false);
			elseif self.sandHit.IDs[terrainID] ~= nil then
				self.hitSound = AudioMan:PlaySound(self.sandHit.Medium.Path .. math.random(1, self.sandHit.Medium.Variations) .. ".ogg", self.Pos, -1, 0, 130, 1, 170, false);
			elseif self.concreteHit.IDs[terrainID] ~= nil then
				self.hitSound = AudioMan:PlaySound(self.concreteHit.Medium.Path .. math.random(1, self.concreteHit.Medium.Variations) .. ".ogg", self.Pos, -1, 0, 130, 1, 170, false);
			elseif self.solidMetalHit.IDs[terrainID] ~= nil then
				self.hitSound = AudioMan:PlaySound(self.solidMetalHit.Medium.Path .. math.random(1, self.solidMetalHit.Medium.Variations) .. ".ogg", self.Pos, -1, 0, 130, 1, 170, false);
			else -- default to concrete
				self.hitSound = AudioMan:PlaySound(self.concreteHit.Medium.Path .. math.random(1, self.concreteHit.Medium.Variations) .. ".ogg", self.Pos, -1, 0, 130, 1, 170, false);
			end
		elseif self.workingTravelImpulse.Magnitude > 5 then
			if self.dirtHit.IDs[terrainID] ~= nil then
				self.hitSound = AudioMan:PlaySound(self.dirtHit.Soft.Path .. math.random(1, self.dirtHit.Soft.Variations) .. ".ogg", self.Pos, -1, 0, 130, 1, 170, false);
			elseif self.sandHit.IDs[terrainID] ~= nil then
				self.hitSound = AudioMan:PlaySound(self.sandHit.Soft.Path .. math.random(1, self.sandHit.Soft.Variations) .. ".ogg", self.Pos, -1, 0, 130, 1, 170, false);
			elseif self.concreteHit.IDs[terrainID] ~= nil then
				self.hitSound = AudioMan:PlaySound(self.concreteHit.Soft.Path .. math.random(1, self.concreteHit.Soft.Variations) .. ".ogg", self.Pos, -1, 0, 130, 1, 170, false);
			elseif self.solidMetalHit.IDs[terrainID] ~= nil then
				self.hitSound = AudioMan:PlaySound(self.solidMetalHit.Soft.Path .. math.random(1, self.solidMetalHit.Soft.Variations) .. ".ogg", self.Pos, -1, 0, 130, 1, 170, false);
			else -- default to concrete
				self.hitSound = AudioMan:PlaySound(self.concreteHit.Soft.Path .. math.random(1, self.concreteHit.Soft.Variations) .. ".ogg", self.Pos, -1, 0, 130, 1, 170, false);
			end
		elseif self.Rolls < 2 then-- roll
			self.Rolls = self.Rolls + 1;
			if self.dirtHit.IDs[terrainID] ~= nil then
				self.rollSound = AudioMan:PlaySound(self.dirtRoll.Path .. math.random(1, self.dirtRoll.Variations) .. ".ogg", self.Pos, -1, 0, 130, 1, 170, false);
			elseif self.sandHit.IDs[terrainID] ~= nil then
				self.rollSound = AudioMan:PlaySound(self.sandRoll.Path .. math.random(1, self.sandRoll.Variations) .. ".ogg", self.Pos, -1, 0, 130, 1, 170, false);
			elseif self.concreteHit.IDs[terrainID] ~= nil then
				self.rollSound = AudioMan:PlaySound(self.concreteRoll.Path .. math.random(1, self.concreteRoll.Variations) .. ".ogg", self.Pos, -1, 0, 130, 1, 170, false);
			elseif self.solidMetalHit.IDs[terrainID] ~= nil then
				self.rollSound = AudioMan:PlaySound(self.solidMetalRoll.Path .. math.random(1, self.solidMetalRoll.Variations) .. ".ogg", self.Pos, -1, 0, 130, 1, 170, false);
			else -- default to concrete
				self.rollSound = AudioMan:PlaySound(self.concreteRoll.Path .. math.random(1, self.concreteRoll.Variations) .. ".ogg", self.Pos, -1, 0, 130, 1, 170, false);
			end
		end
	end
end

function Update(self)

	self.workingTravelImpulse = (self.Vel - self.lastVel) / TimerMan.DeltaTimeSecs * self.Vel.Magnitude * 0.1
	self.lastVel = Vector(self.Vel.X, self.Vel.Y)

	if self.impactTimer:IsPastSimMS(self.impactCooldown) then
		self.impactSoundAllowed = true;
		self.impactTimer:Reset();
		self.impactCooldown = 300; -- increase impact cooldown from first 0
	end

	if not self:IsAttached() then
		if self.Live ~= true and self.pinPulled then
			self.lifeTimer:Reset();
			self.Live = true;
			local spoon = CreateMOSParticle("M84 Grenade Spoon");
			spoon.Pos = self.Pos;
			spoon.Vel = self.Vel+Vector(0,-6)+Vector(3*math.random(),0):RadRotate(math.random()*(math.pi*2));
			MovableMan:AddParticle(spoon);
			
			self.frm = 2
			
			self.pinSound = AudioMan:PlaySound("SandstormSecurity.rte/Devices/Weapons/Thrown/M84/Sounds/SpoonEject" .. math.random(1,4) .. ".ogg", self.Pos, -1, 0, 130, 1, 450, false);			
		end
	end

	if self:IsActivated() and self.pinPulled ~= true then	
		self.lifeTimer:Reset();
		self.pinPulled = true;
		
		local pin = CreateMOSParticle("M84 Grenade Pin");
		pin.Pos = self.Pos;
		pin.Vel = self.Vel+Vector(0,-6)+Vector(3*math.random(),0):RadRotate(math.random()*(math.pi*2));
		MovableMan:AddParticle(pin);
		
		self.frm = 1
		
		self.pinSound = AudioMan:PlaySound("SandstormSecurity.rte/Devices/Weapons/Thrown/M84/Sounds/PullPin" .. math.random(1,3) .. ".ogg", self.Pos, -1, 0, 130, 1, 450, false);
	end	
	
	if self.Live and self.lifeTimer:IsPastSimMS(self.fuseTime) then
		self:GibThis();
	end
	
	self.Frame = self.frm
end
