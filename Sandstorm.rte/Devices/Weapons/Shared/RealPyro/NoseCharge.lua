
function Create(self)
	
	self.noseSounds = CreateSoundContainer("Explosion Specialty Remote Nose", "Sandstorm.rte");
	
	self.noseSounds:Play(self.Pos);
	
	self:GibThis();
end