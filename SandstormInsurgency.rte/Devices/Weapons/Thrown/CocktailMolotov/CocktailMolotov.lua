function Create(self)
	self.origMass = self.Mass;
	self.lastVel = 0;
	
	self.Frame = math.random(0, self.FrameCount - 1);
end
function Update(self)
	if self.ID == self.RootID then
		if self.thrown == false then
			self.AngularVel = self.AngularVel - self.Vel.Magnitude * self.FlipFactor * math.random();
			self.thrown = true;
		end
		self.Mass = self.origMass + math.sqrt(self.lastVel);
	else
		self.thrown = false;
		self.Mass = self.origMass;
	end
	if self.WoundCount > 1 then
		self:Activate();
	end
	if not self.explosion and self:IsActivated() then
		self.explosion = CreateMOSRotating("Sandstorm Cocktail Molotov Explosion")
		self.flameArea = CreateMOSRotating("Sandstorm Cocktail Molotov Area")
	end
	self.lastVel = self.Vel.Magnitude;
end
function Destroy(self)
	-- Explode into flames only if lit
	if self.explosion then
		self.explosion.Pos = Vector(self.Pos.X, self.Pos.Y);
		self.explosion.Vel = Vector(self.Vel.X, self.Vel.Y);
		MovableMan:AddParticle(self.explosion);
		self.explosion:GibThis();
	end
	
	if self.flameArea then
		self.flameArea.Pos = Vector(self.Pos.X, self.Pos.Y);
		self.flameArea.Vel = Vector(self.Vel.X, self.Vel.Y);
		MovableMan:AddParticle(self.flameArea);
	end
end