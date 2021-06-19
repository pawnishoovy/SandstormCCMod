function Create(self)	
	
	local type = self:GetStringValue("MagazineType");

	self.playSound = true;
	
	if type == "Pistol Metal" then
	
		self.concreteHit = {["IDs"] = {[12] = "Exists", [177] = "Exists"},
		["Container"] = CreateSoundContainer("Physics Magazine Small Metal Concrete", "Sandstorm.rte")};
		
		self.dirtHit = {["IDs"] = {[9] = "Exists", [10] = "Exists", [11] = "Exists", [128] = "Exists"},
		["Container"] = CreateSoundContainer("Physics Magazine " .. type .. " Dirt", "Sandstorm.rte")};
		
		self.sandHit = {["IDs"] = {[6] = "Exists", [8] = "Exists"},
		["Container"] = CreateSoundContainer("Physics Magazine Small Metal Sand", "Sandstorm.rte")};
		
		self.solidMetalHit = {["IDs"] = {[178] = "Exists", [182] = "Exists"},
		["Container"] = CreateSoundContainer("Physics Magazine Small Metal SolidMetal", "Sandstorm.rte")};
		
	elseif type == "Pistol Poly" then
	
		self.concreteHit = {["IDs"] = {[12] = "Exists", [177] = "Exists"},
		["Container"] = CreateSoundContainer("Physics Magazine Small Poly Concrete", "Sandstorm.rte")};
		
		self.dirtHit = {["IDs"] = {[9] = "Exists", [10] = "Exists", [11] = "Exists", [128] = "Exists"},
		["Container"] = CreateSoundContainer("Physics Magazine " .. type .. " Dirt", "Sandstorm.rte")};
		
		self.sandHit = {["IDs"] = {[6] = "Exists", [8] = "Exists"},
		["Container"] = CreateSoundContainer("Physics Magazine Small Poly Sand", "Sandstorm.rte")};
		
		self.solidMetalHit = {["IDs"] = {[178] = "Exists", [182] = "Exists"},
		["Container"] = CreateSoundContainer("Physics Magazine Small Poly SolidMetal", "Sandstorm.rte")};
		
	else
	
		self.concreteHit = {["IDs"] = {[12] = "Exists", [177] = "Exists"},
		["Container"] = CreateSoundContainer("Physics Magazine " .. type .. " Concrete", "Sandstorm.rte")};
		
		self.dirtHit = {["IDs"] = {[9] = "Exists", [10] = "Exists", [11] = "Exists", [128] = "Exists"},
		["Container"] = CreateSoundContainer("Physics Magazine " .. type .. " Dirt", "Sandstorm.rte")};
		
		self.sandHit = {["IDs"] = {[6] = "Exists", [8] = "Exists"},
		["Container"] = CreateSoundContainer("Physics Magazine " .. type .. " Sand", "Sandstorm.rte")};
		
		self.solidMetalHit = {["IDs"] = {[178] = "Exists", [182] = "Exists"},
		["Container"] = CreateSoundContainer("Physics Magazine " .. type .. " SolidMetal", "Sandstorm.rte")};
	end

end

function OnCollideWithTerrain(self, terrainID)
	
	if self.playSound == true then
	
		self.playSound = false;
	
		if self.dirtHit.IDs[terrainID] ~= nil then
			self.dirtHit.Container:Play(self.Pos);
		elseif self.sandHit.IDs[terrainID] ~= nil then
			self.sandHit.Container:Play(self.Pos);
		elseif self.concreteHit.IDs[terrainID] ~= nil then
			self.concreteHit.Container:Play(self.Pos);
		elseif self.solidMetalHit.IDs[terrainID] ~= nil then
			self.solidMetalHit.Container:Play(self.Pos);
		else -- default to concrete
			self.concreteHit.Container:Play(self.Pos);
		end

	end

end