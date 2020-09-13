
function Create(self)
	local dir = "Sandstorm.rte/Devices/Weapons/Shared/Sounds/Explosion"
	
	self.addSounds = {["Variations"] = 5,
	["Path"] = dir.."/Specialty/Rocket/Add"};
	
	AudioMan:PlaySound(self.addSounds.Path .. math.random(1, self.addSounds.Variations) .. ".wav", self.Pos, -1, 0, 130, 1, 450, false);
	
	self:GibThis();
end