function Create(self)
	
	self.pullPinSound = CreateSoundContainer("F1 PullPin", "SandstormInsurgency.rte");
	self.spoonEjectSound = CreateSoundContainer("F1 SpoonEject", "SandstormInsurgency.rte");	
	
	self.lifeTimer = Timer();
	self.fuseTime = math.random(4000, 5000);
	
	self.impactTimer = Timer();
	self.impactCooldown = 0;
	
	self.lastVel = Vector(0, 0)
	
	self.Rolls = 0;
	
	self.terrainSounds = {
	Hard = {[12] = CreateSoundContainer("Frag Impact Hard Concrete", "Sandstorm.rte"),
			[164] = CreateSoundContainer("Frag Impact Hard Concrete", "Sandstorm.rte"),
			[177] = CreateSoundContainer("Frag Impact Hard Concrete", "Sandstorm.rte"),
			[9] = CreateSoundContainer("Frag Impact Hard Dirt", "Sandstorm.rte"),
			[10] = CreateSoundContainer("Frag Impact Hard Dirt", "Sandstorm.rte"),
			[11] = CreateSoundContainer("Frag Impact Hard Dirt", "Sandstorm.rte"),
			[128] = CreateSoundContainer("Frag Impact Hard Dirt", "Sandstorm.rte"),
			[6] = CreateSoundContainer("Frag Impact Hard Sand", "Sandstorm.rte"),
			[8] = CreateSoundContainer("Frag Impact Hard Sand", "Sandstorm.rte"),
			[178] = CreateSoundContainer("Frag Impact Hard SolidMetal", "Sandstorm.rte"),
			[179] = CreateSoundContainer("Frag Impact Hard SolidMetal", "Sandstorm.rte"),
			[180] = CreateSoundContainer("Frag Impact Hard SolidMetal", "Sandstorm.rte"),
			[181] = CreateSoundContainer("Frag Impact Hard SolidMetal", "Sandstorm.rte"),
			[182] = CreateSoundContainer("Frag Impact Hard SolidMetal", "Sandstorm.rte")},
	Medium = {[12] = CreateSoundContainer("Frag Impact Medium Concrete", "Sandstorm.rte"),
			[164] = CreateSoundContainer("Frag Impact Medium Concrete", "Sandstorm.rte"),
			[177] = CreateSoundContainer("Frag Impact Medium Concrete", "Sandstorm.rte"),
			[9] = CreateSoundContainer("Frag Impact Medium Dirt", "Sandstorm.rte"),
			[10] = CreateSoundContainer("Frag Impact Medium Dirt", "Sandstorm.rte"),
			[11] = CreateSoundContainer("Frag Impact Medium Dirt", "Sandstorm.rte"),
			[128] = CreateSoundContainer("Frag Impact Medium Dirt", "Sandstorm.rte"),
			[6] = CreateSoundContainer("Frag Impact Medium Sand", "Sandstorm.rte"),
			[8] = CreateSoundContainer("Frag Impact Medium Sand", "Sandstorm.rte"),
			[178] = CreateSoundContainer("Frag Impact Medium SolidMetal", "Sandstorm.rte"),
			[179] = CreateSoundContainer("Frag Impact Medium SolidMetal", "Sandstorm.rte"),
			[180] = CreateSoundContainer("Frag Impact Medium SolidMetal", "Sandstorm.rte"),
			[181] = CreateSoundContainer("Frag Impact Medium SolidMetal", "Sandstorm.rte"),
			[182] = CreateSoundContainer("Frag Impact Medium SolidMetal", "Sandstorm.rte")},
	Soft = {[12] = CreateSoundContainer("Frag Impact Soft Concrete", "Sandstorm.rte"),
			[164] = CreateSoundContainer("Frag Impact Soft Concrete", "Sandstorm.rte"),
			[177] = CreateSoundContainer("Frag Impact Soft Concrete", "Sandstorm.rte"),
			[9] = CreateSoundContainer("Frag Impact Soft Dirt", "Sandstorm.rte"),
			[10] = CreateSoundContainer("Frag Impact Soft Dirt", "Sandstorm.rte"),
			[11] = CreateSoundContainer("Frag Impact Soft Dirt", "Sandstorm.rte"),
			[128] = CreateSoundContainer("Frag Impact Soft Dirt", "Sandstorm.rte"),
			[6] = CreateSoundContainer("Frag Impact Soft Sand", "Sandstorm.rte"),
			[8] = CreateSoundContainer("Frag Impact Soft Sand", "Sandstorm.rte"),
			[178] = CreateSoundContainer("Frag Impact Soft SolidMetal", "Sandstorm.rte"),
			[179] = CreateSoundContainer("Frag Impact Soft SolidMetal", "Sandstorm.rte"),
			[180] = CreateSoundContainer("Frag Impact Soft SolidMetal", "Sandstorm.rte"),
			[181] = CreateSoundContainer("Frag Impact Soft SolidMetal", "Sandstorm.rte"),
			[182] = CreateSoundContainer("Frag Impact Soft SolidMetal", "Sandstorm.rte")},
	Roll = {[12] = CreateSoundContainer("Frag Impact Roll Concrete", "Sandstorm.rte"),
			[164] = CreateSoundContainer("Frag Impact Roll Concrete", "Sandstorm.rte"),
			[177] = CreateSoundContainer("Frag Impact Roll Concrete", "Sandstorm.rte"),
			[9] = CreateSoundContainer("Frag Impact Roll Dirt", "Sandstorm.rte"),
			[10] = CreateSoundContainer("Frag Impact Roll Dirt", "Sandstorm.rte"),
			[11] = CreateSoundContainer("Frag Impact Roll Dirt", "Sandstorm.rte"),
			[128] = CreateSoundContainer("Frag Impact Roll Dirt", "Sandstorm.rte"),
			[6] = CreateSoundContainer("Frag Impact Roll Sand", "Sandstorm.rte"),
			[8] = CreateSoundContainer("Frag Impact Roll Sand", "Sandstorm.rte"),
			[178] = CreateSoundContainer("Frag Impact Roll SolidMetal", "Sandstorm.rte"),
			[179] = CreateSoundContainer("Frag Impact Roll SolidMetal", "Sandstorm.rte"),
			[180] = CreateSoundContainer("Frag Impact Roll SolidMetal", "Sandstorm.rte"),
			[181] = CreateSoundContainer("Frag Impact Roll SolidMetal", "Sandstorm.rte"),
			[182] = CreateSoundContainer("Frag Impact Roll SolidMetal", "Sandstorm.rte")}
			}
	
	self.frm = 0
end

function OnCollideWithTerrain(self, terrainID)	

	-- LOTS OF DUPE CODE TODO FIX
	-- THE ABOVE TODO HAS BEEN TODONE... YEARS LATER!!!
	
	if self.impactSoundAllowed ~= false then
		self.impactSoundAllowed = false;
		if self.workingTravelImpulse.Magnitude > 40 then
			if self.terrainSounds.Hard[terrainID] ~= nil then
				self.terrainSounds.Hard[terrainID]:Play(self.Pos);
			else -- default to concrete
				self.terrainSounds.Hard[177]:Play(self.Pos);
			end
		elseif self.workingTravelImpulse.Magnitude > 20 then
			if self.terrainSounds.Medium[terrainID] ~= nil then
				self.terrainSounds.Medium[terrainID]:Play(self.Pos);
			else -- default to concrete
				self.terrainSounds.Medium[177]:Play(self.Pos);
			end
		elseif self.workingTravelImpulse.Magnitude > 5 then
			if self.terrainSounds.Soft[terrainID] ~= nil then
				self.terrainSounds.Soft[terrainID]:Play(self.Pos);
			else -- default to concrete
				self.terrainSounds.Soft[177]:Play(self.Pos);
			end
		elseif self.Rolls < 2 then-- roll
			self.Rolls = self.Rolls + 1;
			if self.terrainSounds.Roll[terrainID] ~= nil then
				self.terrainSounds.Roll[terrainID]:Play(self.Pos);
			else -- default to concrete
				self.terrainSounds.Roll[177]:Play(self.Pos);
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
			local spoon = CreateMOSParticle("F1 Grenade Spoon");
			spoon.Pos = self.Pos;
			spoon.Vel = self.Vel+Vector(0,-6)+Vector(3*math.random(),0):RadRotate(math.random()*(math.pi*2));
			MovableMan:AddParticle(spoon);
			
			self.frm = 2
			
			self.spoonEjectSound:Play(self.Pos);			
		end
	end

	if self:IsActivated() and self.pinPulled ~= true then	
		self.lifeTimer:Reset();
		self.pinPulled = true;
		
		local pin = CreateMOSParticle("F1 Grenade Pin");
		pin.Pos = self.Pos;
		pin.Vel = self.Vel+Vector(0,-6)+Vector(3*math.random(),0):RadRotate(math.random()*(math.pi*2));
		MovableMan:AddParticle(pin);
		
		self.frm = 1
		
		sself.pullPinSound:Play(self.Pos);
	end	
	
	if self.Live and self.lifeTimer:IsPastSimMS(self.fuseTime) then
		self:GibThis();
	end
	
	self.Frame = self.frm
end
