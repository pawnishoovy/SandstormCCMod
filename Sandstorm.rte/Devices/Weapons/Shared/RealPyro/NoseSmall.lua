
function Create(self)
	
	self.noseSounds = CreateSoundContainer("Explosion Nose Small", "Sandstorm.rte");
	
	self.noseSounds:Play(self.Pos);
	
	self:GibThis();
end