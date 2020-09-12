
function Create(self)
	self.lastVel = Vector(self.Vel.X, self.Vel.Y)
	
	self.impulse = Vector()
	
	local dir = "Sandstorm.rte/Devices/Weapons/Shared/Sounds/Casing/"
	local name = "LargeCaliber"
	
	self.ConcreteHit = {["Variations"] = 10,
	["Path"] = dir..name.."/Concrete/HitConcrete"};
	
	self.ConcreteRoll = {["Variations"] = 10,
	["Path"] = dir..name.."/Concrete/RollConcrete"};
	
	--
	
	self.DirtHit = {["Variations"] = 10,
	["Path"] = dir..name.."/Dirt/HitDirt"};
	
	self.DirtRoll = {["Variations"] = 10,
	["Path"] = dir..name.."/Dirt/RollDirt"};
	
	--
	
	self.SolidMetalHit = {["Variations"] = 10,
	["Path"] = dir..name.."/SolidMetal/HitSolidMetal"};
	
	self.SolidMetalRoll = {["Variations"] = 10,
	["Path"] = dir..name.."/SolidMetal/RollSolidMetal"};
	
	--
	
	self.SandHit = {["Variations"] = 10,
	["Path"] = dir..name.."/Sand/HitSand"};
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
		--AudioMan:PlaySound("Sandstorm.rte/Devices/Weapons/Shared/Sounds/Casing/Rifle/Dirt/HitDirt"..math.random(1,10)..".wav", self.Pos, -1, 0, 130, 1, 250, false);
	elseif self.impulse.Magnitude > 11 then
		playSound = true
		roll = true
		--AudioMan:PlaySound("Sandstorm.rte/Devices/Weapons/Shared/Sounds/Casing/Rifle/Dirt/RollDirt"..math.random(1,10)..".wav", self.Pos, -1, 0, 130, 1, 250, false);
	end
	
	if playSound then
		local sound = self.ConcreteHit
		if string.find(material.PresetName,"Concrete") or string.find(material.PresetName,"Rock") or string.find(material.PresetName,"Glass") then
			sound = (roll and self.ConcreteRoll or self.ConcreteHit)
		elseif string.find(material.PresetName,"Dirt") or string.find(material.PresetName,"Soil") or string.find(material.PresetName,"Flesh") or string.find(material.PresetName,"Bone") or string.find(material.PresetName,"Grass") then
			sound = (roll and self.DirtRoll or self.DirtHit)
		elseif string.find(material.PresetName,"Sand") then
			sound = self.SandHit
		elseif string.find(material.PresetName,"Metal") or string.find(material.PresetName,"Stuff") then
			sound = (roll and self.SolidMetalRoll or self.SolidMetalHit)
		end
		
		AudioMan:PlaySound(sound.Path .. math.random(1, sound.Variations) .. ".wav", self.Pos, -1, 0, 15, 1, 200, false);
	end
	--print(self.impulse.Magnitude)
end