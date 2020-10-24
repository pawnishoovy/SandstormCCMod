
function Create(self)
	local dir = "Sandstorm.rte/Devices/Weapons/Shared/Sounds/Explosion"
	
	self.noseSounds = {["Variations"] = 5,
	["Path"] = dir.."/Specialty/Remote/Nose"};
	
	AudioMan:PlaySound(self.noseSounds.Path .. math.random(1, self.noseSounds.Variations) .. ".ogg", self.Pos, -1, 0, 130, 1, 450, false);
	
	self:GibThis();
end