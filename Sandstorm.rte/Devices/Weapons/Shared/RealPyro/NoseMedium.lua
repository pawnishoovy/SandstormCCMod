
function Create(self)
	
	self.noseSounds = CreateSoundContainer("Explosion Nose Medium", "Sandstorm.rte");
	
	self.noseSounds:Play(self.Pos);
	
	self:GibThis();
end