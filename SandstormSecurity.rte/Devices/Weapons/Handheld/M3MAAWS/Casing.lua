
function Create(self)

	self.playSound = true;	

	self.Hit = CreateSoundContainer("Casing Large Shell Hit", "Sandstorm.rte");
	
end

function OnCollideWithTerrain(self, terrainID)
	
	if self.playSound == true then
	
		self.playSound = false;
	
		self.Hit:Play(self.Pos);

	end

end