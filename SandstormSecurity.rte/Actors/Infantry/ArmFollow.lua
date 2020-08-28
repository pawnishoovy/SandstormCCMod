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
		local dif = (Vector(ToArm(parent).HandPos.X, ToArm(parent).HandPos.Y) - Vector(self.Pos.X, self.Pos.Y) + Vector(parent.JointOffset.X * self.FlipFactor, parent.JointOffset.Y)) * self.FlipFactor
		local angle = dif.AbsRadAngle
		--PrimitiveMan:DrawCirclePrimitive(Vector(ToArm(parent).HandPos.X, ToArm(parent).HandPos.Y), 1, 13);
		--PrimitiveMan:DrawCirclePrimitive(Vector(ToArm(parent).HandPos.X, ToArm(parent).HandPos.Y) + Vector(parent.JointOffset.X * self.FlipFactor, parent.JointOffset.Y), 1, 5);
		self.RotAngle = angle
		
		--local jointOffset = Vector(self.JointOffset.X * self.FlipFactor, self.JointOffset.Y):RadRotate(self.RotAngle);
		--local offsetTotal = Vector(jointOffset.X, jointOffset.Y):RadRotate(-angle) - jointOffset
		--self.Pos = self.Pos - offsetTotal;
		--self.Pos = parent.Pos + Vector(10,0)
		--self.RotAngle = parent.RotAngle
	else
		self:GibThis()
	end
end