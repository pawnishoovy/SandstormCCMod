
function Create(self)
	self.lastVel = Vector(self.Vel.X, self.Vel.Y)
	
	self.impulse = Vector()
	
	local type = "Rifle"
	
	self.Sounds = {
	Hit = {[12] = CreateSoundContainer("Casing " .. type .. " Hit Concrete", "Sandstorm.rte"),
			[164] = CreateSoundContainer("Casing " .. type .. " Hit Concrete", "Sandstorm.rte"),
			[177] = CreateSoundContainer("Casing " .. type .. " Hit Concrete", "Sandstorm.rte"),
			[9] = CreateSoundContainer("Casing " .. type .. " Hit Dirt", "Sandstorm.rte"),
			[10] = CreateSoundContainer("Casing " .. type .. " Hit Dirt", "Sandstorm.rte"),
			[11] = CreateSoundContainer("Casing " .. type .. " Hit Dirt", "Sandstorm.rte"),
			[128] = CreateSoundContainer("Casing " .. type .. " Hit Dirt", "Sandstorm.rte"),
			[6] = CreateSoundContainer("Casing " .. type .. " Hit Sand", "Sandstorm.rte"),
			[8] = CreateSoundContainer("Casing " .. type .. " Hit Sand", "Sandstorm.rte"),
			[178] = CreateSoundContainer("Casing " .. type .. " Hit SolidMetal", "Sandstorm.rte"),
			[179] = CreateSoundContainer("Casing " .. type .. " Hit SolidMetal", "Sandstorm.rte"),
			[180] = CreateSoundContainer("Casing " .. type .. " Hit SolidMetal", "Sandstorm.rte"),
			[181] = CreateSoundContainer("Casing " .. type .. " Hit SolidMetal", "Sandstorm.rte"),
			[182] = CreateSoundContainer("Casing " .. type .. " Hit SolidMetal", "Sandstorm.rte")},
	Roll = {[12] = CreateSoundContainer("Casing " .. type .. " Roll Concrete", "Sandstorm.rte"),
			[164] = CreateSoundContainer("Casing " .. type .. " Roll Concrete", "Sandstorm.rte"),
			[177] = CreateSoundContainer("Casing " .. type .. " Roll Concrete", "Sandstorm.rte"),
			[9] = CreateSoundContainer("Casing " .. type .. " Roll Dirt", "Sandstorm.rte"),
			[10] = CreateSoundContainer("Casing " .. type .. " Roll Dirt", "Sandstorm.rte"),
			[11] = CreateSoundContainer("Casing " .. type .. " Roll Dirt", "Sandstorm.rte"),
			[128] = CreateSoundContainer("Casing " .. type .. " Roll Dirt", "Sandstorm.rte"),
			[6] = CreateSoundContainer("Casing " .. type .. " Hit Sand", "Sandstorm.rte"),
			[8] = CreateSoundContainer("Casing " .. type .. " Hit Sand", "Sandstorm.rte"),
			[178] = CreateSoundContainer("Casing " .. type .. " Roll SolidMetal", "Sandstorm.rte"),
			[179] = CreateSoundContainer("Casing " .. type .. " Roll SolidMetal", "Sandstorm.rte"),
			[180] = CreateSoundContainer("Casing " .. type .. " Roll SolidMetal", "Sandstorm.rte"),
			[181] = CreateSoundContainer("Casing " .. type .. " Roll SolidMetal", "Sandstorm.rte"),
			[182] = CreateSoundContainer("Casing " .. type .. " Roll SolidMetal", "Sandstorm.rte")}}
end

function Update(self)
	self.impulse = (self.Vel - self.lastVel) / TimerMan.DeltaTimeSecs * self.Vel.Magnitude * 0.1
	self.lastVel = Vector(self.Vel.X, self.Vel.Y)
end

function OnCollideWithTerrain(self, terrainID)
	--PrimitiveMan:DrawCirclePrimitive(self.Pos, 1, 5);
	--PrimitiveMan:DrawLinePrimitive(self.Pos, self.Pos + self.impulse, 5);
	local playSound = false
	local roll = false
	
	local material = SceneMan:GetMaterialFromID(terrainID)
	
	if self.impulse.Magnitude > 25 then
		playSound = true
		--AudioMan:PlaySound("Sandstorm.rte/Devices/Weapons/Shared/Sounds/Casing/Rifle/Dirt/HitDirt"..math.random(1,10)..".ogg", self.Pos, -1, 0, 130, 1, 250, false);
	elseif self.impulse.Magnitude > 11 then
		playSound = true
		roll = true
		--AudioMan:PlaySound("Sandstorm.rte/Devices/Weapons/Shared/Sounds/Casing/Rifle/Dirt/RollDirt"..math.random(1,10)..".ogg", self.Pos, -1, 0, 130, 1, 250, false);
	end
	
	if playSound then
		if roll then
			if self.Sounds.Roll[terrainID] ~= nil then
				self.Sounds.Roll[terrainID]:Play(self.Pos);
			else
				self.Sounds.Roll[12]:Play(self.Pos); -- default concrete
			end
		else
			if self.Sounds.Hit[terrainID] ~= nil then
				self.Sounds.Hit[terrainID]:Play(self.Pos);
			else
				self.Sounds.Hit[12]:Play(self.Pos); -- default concrete
			end
		end
	end
	--print(self.impulse.Magnitude)
end