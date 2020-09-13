
function Create(self)
	local dir = "Sandstorm.rte/Devices/Weapons/Shared/Sounds/Explosion"
	
	self.noseSounds = {["Variations"] = 4,
	["Path"] = dir.."/Nose/NoseSmall"};
	
	AudioMan:PlaySound(self.noseSounds.Path .. math.random(1, self.noseSounds.Variations) .. ".wav", self.Pos, -1, 0, 130, 1, 450, false);
	
	self:GibThis();
end