
function Create(self)

	self.lighterOpenSound = CreateSoundContainer("Sandstorm Cocktail Molotov LighterOpen", "SandstormInsurgency.rte");
	self.throwSound = CreateSoundContainer("Sandstorm Cocktail Molotov Throw", "SandstormInsurgency.rte");

	self.explodeSound = CreateSoundContainer("Explosion Specialty Molotov Start", "Sandstorm.rte");

	self.origMass = self.Mass;
	self.lastVel = 0;
	
	self.Frame = math.random(0, self.FrameCount - 1);
end
function OnAttach(self)
	self.lighterOpenSound:Play(self.Pos);
end
function Update(self)
	if not self:IsAttached() and self.Live then
		if not self.Thrown then
			self.Thrown = true;
			self.throwSound:Play(self.Pos);
		end
		self.Mass = self.origMass + math.sqrt(self.lastVel);
	else
		self.Mass = self.origMass;
	end
	if self.WoundCount > 1 then
		self:Activate();
	end
	if not self.explosion and self:IsActivated() then
		self.Live = true;
		self.explosion = CreateMOSRotating("Sandstorm Cocktail Molotov Explosion")
		self.flameArea = CreateMOSRotating("Sandstorm Cocktail Molotov Area")
	end
	self.lastVel = self.Vel.Magnitude;
end
function Destroy(self)
	-- Explode into flames only if lit
	if self.explosion then
		self.explodeSound:Play(self.Pos);
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