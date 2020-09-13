
function Create(self)
	self.PinStrength = 99000
	self.PreMO = self:GetStringValue("PreMOSRotatingToGib")
	self.PostMO = self:GetStringValue("PostMOSRotatingToGib")
	self.DelayMS = self:GetNumberValue("DelayMS")
	
	self.Timer = Timer();
end

function Update(self)
	if self.PreMO then
		local effect = CreateMOSRotating(self.PreMO)
		if effect then
			effect.Pos = self.Pos
			MovableMan:AddParticle(effect);
			--effect:GibThis();
		end
		
		self.PreMO = nil
	end
	
	if self.Timer:IsPastSimMS(self.DelayMS) then
		local effect = CreateMOSRotating(self.PostMO)
		if effect then
			effect.Pos = self.Pos
			MovableMan:AddParticle(effect);
			--effect:GibThis();
		end
		self.PostMO = nil
		
		self.ToDelete = true
	end
end