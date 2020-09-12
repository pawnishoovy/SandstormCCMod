
function Create(self)

	self.playSound = true;	

	self.Hit = {["Variations"] = 8,
	["Path"] = "Sandstorm.rte/Devices/Weapons/Shared/Sounds/Casing/LargeShell/Hit"};
	
end

function OnCollideWithTerrain(self, terrainID)
	
	if self.playSound == true then
	
		self.playSound = false;
	
		self.hitSound = AudioMan:PlaySound(self.Hit.Path .. math.random(1, self.Hit.Variations) .. ".wav", self.Pos, -1, 0, 130, 1, 170, false);

	end

end