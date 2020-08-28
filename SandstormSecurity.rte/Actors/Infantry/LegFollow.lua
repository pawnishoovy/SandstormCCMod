function Create(self)
	--self.Frame = math.random(0, self.FrameCount - 1);
	self.skin = 0
end

function Update(self)
	local parent = self:GetParent();
	if parent then
		parent = ToAttachable(parent)
		if parent:NumberValueExists("Skin") then
			self.skin = parent:GetNumberValue("Skin")
			parent:RemoveNumberValue("Skin")
		end
		
		self:ClearForces();
		self:ClearImpulseForces();
		
		self:RemoveWounds(self.WoundCount);
		self.Frame = parent.Frame + self.skin * 5
	else
		self:GibThis()
	end
end