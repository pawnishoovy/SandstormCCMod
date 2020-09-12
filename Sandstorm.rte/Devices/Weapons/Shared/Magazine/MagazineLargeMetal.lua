
function Create(self)

	self.playSound = true;
	
	local dir = "Sandstorm.rte/Devices/Weapons/Shared/Sounds/Magazine/"
	local name = "LargeMetal"
	
	self.dirtHit = {["IDs"] = {[9] = "Exists", [10] = "Exists", [11] = "Exists", [128] = "Exists"},
	["Variations"] = 6,
	["Path"] = dir..name.."/Dirt/HitDirt"};
	
	
	self.sandHit = {["IDs"] = {[6] = "Exists", [8] = "Exists"},
	["Variations"] = 5,
	["Path"] = dir..name.."/Sand/HitSand"};
	

	self.solidMetalHit = {["IDs"] = {[178] = "Exists", [182] = "Exists"},
	["Variations"] = 4,
	["Path"] = dir..name.."/SolidMetal/HitSolidMetal"};
	

	self.concreteHit = {["IDs"] = {[12] = "Exists", [177] = "Exists"},
	["Variations"] = 6,
	["Path"] = dir..name.."/Concrete/HitConcrete"};
	
end

function OnCollideWithTerrain(self, terrainID)
	
	if self.playSound == true then
	
		self.playSound = false;
	
		if self.dirtHit.IDs[terrainID] ~= nil then
			self.hitSound = AudioMan:PlaySound(self.dirtHit.Path .. math.random(1, self.dirtHit.Variations) .. ".wav", self.Pos, -1, 0, 130, 1, 170, false);
		elseif self.sandHit.IDs[terrainID] ~= nil then
			self.hitSound = AudioMan:PlaySound(self.sandHit.Path .. math.random(1, self.sandHit.Variations) .. ".wav", self.Pos, -1, 0, 130, 1, 170, false);
		elseif self.concreteHit.IDs[terrainID] ~= nil then
			self.hitSound = AudioMan:PlaySound(self.concreteHit.Path .. math.random(1, self.concreteHit.Variations) .. ".wav", self.Pos, -1, 0, 130, 1, 170, false);
		elseif self.solidMetalHit.IDs[terrainID] ~= nil then
			self.hitSound = AudioMan:PlaySound(self.solidMetalHit.Path .. math.random(1, self.solidMetalHit.Variations) .. ".wav", self.Pos, -1, 0, 130, 1, 170, false);
		else -- default to concrete
			self.hitSound = AudioMan:PlaySound(self.concreteHit.Path .. math.random(1, self.concreteHit.Variations) .. ".wav", self.Pos, -1, 0, 130, 1, 170, false);
		end

	end

end