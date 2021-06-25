function Create(self)
	
	self.idleBurnSound = CreateSoundContainer("Sandstorm Cocktail Molotov IdleBurn", "SandstormInsurgency.rte");
	
	self.Scale = 0;
end
function Update(self)
	local parent = self:GetParent();
	self.idleBurnSound.Pos = self.Pos;
	if parent then
		if self.lit then
			if not self.burnLoop then
				self.burnLoop = true;
				self.idleBurnSound:Play(self.Pos);
			end
			self.Scale = 1;
			if math.random() < 0.3 then
				local part = CreateMOSParticle("Flame Smoke 2");
				if math.random() < 0.3 then
					part = CreateMOSParticle("Fire Puff Small");
				end
				part.Pos = self.Pos;
				part.Vel = self.Vel + Vector(math.random(), 0):RadRotate(math.random() * 6.28);
				part.Lifetime = part.Lifetime * RangeRand(0.5, 1.0);
				MovableMan:AddParticle(part);
			end
		elseif ToTDExplosive(parent):IsActivated() then
			self.lit = true;
		end
	else
		self.ToDelete = true;
	end
end
function Destroy(self)
	self.idleBurnSound:Stop(-1);
end