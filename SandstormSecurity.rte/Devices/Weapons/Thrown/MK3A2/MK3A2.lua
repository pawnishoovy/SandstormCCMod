function Create(self)
	
	self.lifeTimer = Timer();
	self.fuseTime = math.random(4000, 5000);
	
	self.impactTimer = Timer();
	self.impactCooldown = 0;
	
	self.lastVel = Vector(0, 0)
	
	self.Rolls = 0;
	
	self.concreteHit = {["IDs"] = {[12] = "Exists", [177] = "Exists"},
	["Hard"] = nil, ["Medium"] = nil, ["Soft"] = nil};
	self.concreteHit.Hard = CreateSoundContainer("DevicesWeaponsSharedSoundsGrenadeFragConcreteHitHardConcrete", "Sandstorm.rte");
	self.concreteHit.Medium = CreateSoundContainer("DevicesWeaponsSharedSoundsGrenadeFragConcreteHitMediumConcrete", "Sandstorm.rte");
	self.concreteHit.Soft = CreateSoundContainer("DevicesWeaponsSharedSoundsGrenadeFragConcreteHitSoftConcrete", "Sandstorm.rte");
	
	self.concreteRoll = CreateSoundContainer("DevicesWeaponsSharedSoundsGrenadeFragConcreteRollConcrete", "Sandstorm.rte");
	
	--
	
	self.dirtHit = {["IDs"] = {[9] = "Exists", [10] = "Exists", [11] = "Exists", [128] = "Exists"},
	["Hard"] = nil, ["Medium"] = nil, ["Soft"] = nil};
	self.dirtHit.Hard = CreateSoundContainer("DevicesWeaponsSharedSoundsGrenadeFragDirtHitHardDirt", "Sandstorm.rte");
	self.dirtHit.Medium = CreateSoundContainer("DevicesWeaponsSharedSoundsGrenadeFragDirtHitMediumDirt", "Sandstorm.rte");
	self.dirtHit.Soft = CreateSoundContainer("DevicesWeaponsSharedSoundsGrenadeFragDirtHitSoftDirt", "Sandstorm.rte");
	
	self.dirtRoll = CreateSoundContainer("DevicesWeaponsSharedSoundsGrenadeFragDirtRollDirt", "Sandstorm.rte");
	
	--
	
	self.sandHit = {["IDs"] = {[6] = "Exists", [8] = "Exists"},
	["Hard"] = nil, ["Medium"] = nil, ["Soft"] = nil};
	self.sandHit.Hard = CreateSoundContainer("DevicesWeaponsSharedSoundsGrenadeFragSandHitHardSand", "Sandstorm.rte");
	self.sandHit.Medium = CreateSoundContainer("DevicesWeaponsSharedSoundsGrenadeFragSandHitMediumSand", "Sandstorm.rte");
	self.sandHit.Soft = CreateSoundContainer("DevicesWeaponsSharedSoundsGrenadeFragSandHitSoftSand", "Sandstorm.rte");
	
	self.sandRoll = CreateSoundContainer("DevicesWeaponsSharedSoundsGrenadeFragSandRollSand", "Sandstorm.rte");
	
	--
	
	self.solidMetalHit = {["IDs"] = {[178] = "Exists", [182] = "Exists"},
	["Hard"] = nil, ["Medium"] = nil, ["Soft"] = nil};
	self.solidMetalHit.Hard = CreateSoundContainer("DevicesWeaponsSharedSoundsGrenadeFragSolidMetalHitHardSolidMetal", "SolidMetalstorm.rte");
	self.solidMetalHit.Medium = CreateSoundContainer("DevicesWeaponsSharedSoundsGrenadeFragSolidMetalHitMediumSolidMetal", "SolidMetalstorm.rte");
	self.solidMetalHit.Soft = CreateSoundContainer("DevicesWeaponsSharedSoundsGrenadeFragSolidMetalHitSoftSolidMetal", "SolidMetalstorm.rte");
	
	self.solidMetalRoll = CreateSoundContainer("DevicesWeaponsSharedSoundsGrenadeFragSolidMetalRollSolidMetal", "SolidMetalstorm.rte");
	
	self.frm = 0
end

function OnCollideWithTerrain(self, terrainID)	

	-- LOTS OF DUPE CODE TODO FIX
	
	if self.impactSoundAllowed ~= false then
		self.impactSoundAllowed = false;
		if self.workingTravelImpulse.Magnitude > 40 then
			if self.dirtHit.IDs[terrainID] ~= nil then
				self.dirtHit.Soft:Play(self.Pos);
			elseif self.sandHit.IDs[terrainID] ~= nil then
				self.sandHit.Soft:Play(self.Pos);
			elseif self.concreteHit.IDs[terrainID] ~= nil then
				self.concreteHit.Soft:Play(self.Pos);
			elseif self.solidMetalHit.IDs[terrainID] ~= nil then
				self.solidMetalHit.Soft:Play(self.Pos);
			else -- default to concrete
				self.concreteHit.Soft:Play(self.Pos);
			end
		elseif self.workingTravelImpulse.Magnitude > 20 then
			if self.dirtHit.IDs[terrainID] ~= nil then
				self.dirtHit.Medium:Play(self.Pos);
			elseif self.sandHit.IDs[terrainID] ~= nil then
				self.sandHit.Medium:Play(self.Pos);
			elseif self.concreteHit.IDs[terrainID] ~= nil then
				self.concreteHit.Medium:Play(self.Pos);
			elseif self.solidMetalHit.IDs[terrainID] ~= nil then
				self.solidMetalHit.Medium:Play(self.Pos);
			else -- default to concrete
				self.concreteHit.Medium:Play(self.Pos);
			end
		elseif self.workingTravelImpulse.Magnitude > 5 then
			if self.dirtHit.IDs[terrainID] ~= nil then
				self.dirtHit.Soft:Play(self.Pos);
			elseif self.sandHit.IDs[terrainID] ~= nil then
				self.sandHit.Soft:Play(self.Pos);
			elseif self.concreteHit.IDs[terrainID] ~= nil then
				self.concreteHit.Soft:Play(self.Pos);
			elseif self.solidMetalHit.IDs[terrainID] ~= nil then
				self.solidMetalHit.Soft:Play(self.Pos);
			else -- default to concrete
				self.concreteHit.Soft:Play(self.Pos);
			end
		elseif self.Rolls < 2 then-- roll
			self.Rolls = self.Rolls + 1;
			if self.dirtHit.IDs[terrainID] ~= nil then
				self.dirtRoll:Play(self.Pos);
			elseif self.sandHit.IDs[terrainID] ~= nil then
				self.sandRoll:Play(self.Pos);
			elseif self.concreteHit.IDs[terrainID] ~= nil then
				self.concreteRoll:Play(self.Pos);
			elseif self.solidMetalHit.IDs[terrainID] ~= nil then
				self.solidMetalRoll:Play(self.Pos);
			else -- default to concrete
				self.concreteRoll:Play(self.Pos);
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
			local spoon = CreateMOSParticle("M67 Grenade Spoon");
			spoon.Pos = self.Pos;
			spoon.Vel = self.Vel+Vector(0,-6)+Vector(3*math.random(),0):RadRotate(math.random()*(math.pi*2));
			MovableMan:AddParticle(spoon);
			
			self.frm = 2
			
			self.pinSound = AudioMan:PlaySound("SandstormSecurity.rte/Devices/Weapons/Thrown/M67/Sounds/SpoonEject" .. math.random(1,4) .. ".ogg", self.Pos, -1, 0, 130, 1, 450, false);			
		end
	end

	if self:IsActivated() and self.pinPulled ~= true then	
		self.lifeTimer:Reset();
		self.pinPulled = true;
		
		local pin = CreateMOSParticle("M67 Grenade Pin");
		pin.Pos = self.Pos;
		pin.Vel = self.Vel+Vector(0,-6)+Vector(3*math.random(),0):RadRotate(math.random()*(math.pi*2));
		MovableMan:AddParticle(pin);
		
		self.frm = 1
		
		self.pinSound = AudioMan:PlaySound("SandstormSecurity.rte/Devices/Weapons/Thrown/M67/Sounds/PullPin" .. math.random(1,4) .. ".ogg", self.Pos, -1, 0, 130, 1, 450, false);
	end	
	
	if self.Live and self.lifeTimer:IsPastSimMS(self.fuseTime) then
		self:GibThis();
	end
	
	self.Frame = self.frm
end
