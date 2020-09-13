function Create(self)
	self.strength = self.Mass * self.Vel.Magnitude;
	self.range = 5 * self.Vel.Magnitude;
	
	self.shockwave = true
end
function Update(self)
	PrimitiveMan:DrawCirclePrimitive(self.Pos, self.range, 5)
	
	-- Run the effect on Update() to give other particles a chance to reach the target
	if self.shockwave then
		for i = 1 , MovableMan:GetMOIDCount() - 1 do
			local mo = MovableMan:GetMOFromID(i);
			if mo and mo.PinStrength == 0 then
				local dist = SceneMan:ShortestDistance(self.Pos, mo.Pos, SceneMan.SceneWrapsX);
				if dist.Magnitude < self.range then
					local strSumCheck = SceneMan:CastStrengthSumRay(self.Pos, self.Pos + dist, 3, 0);
					if strSumCheck < self.strength then
						local massFactor = math.sqrt(1 + math.abs(mo.Mass));
						local distFactor = 1 + dist.Magnitude * 0.1;
						local forceVector =	dist:SetMagnitude((self.strength - strSumCheck) /distFactor);
						mo.Vel = mo.Vel + forceVector /massFactor;
						mo.AngularVel = mo.AngularVel - forceVector.X /(massFactor + math.abs(mo.AngularVel));
						mo:AddForce(forceVector * massFactor, Vector());
						
						if IsMOSRotating(mo) then
							mo = ToMOSRotating(mo)
							-- 400 - 200
							local wounding = math.pow((self.strength - strSumCheck) / distFactor / 85, 3.0)
							local woundName = mo:GetEntryWoundPresetName()
							local woundNameExit = mo:GetExitWoundPresetName()
							if woundName and woundNameExit and math.floor(wounding + 0.5) > 0 then
								for i = 1, math.floor(wounding + 0.5) do
									local wound = CreateAEmitter(woundName)
									if wound then
										mo:AddWound(wound, Vector(RangeRand(-1,1),RangeRand(-1,1)) * self.Radius * 0.7, true)
									end
								end
								
							end
							
							if mo.GibImpulseLimit ~= nil and mo.GibImpulseLimit > 0 and (forceVector * massFactor).Magnitude > (mo.GibImpulseLimit * distFactor) * RangeRand(1.3,3) then
								mo:GibThis()
							end
						end
						
					end
				end
			end	
		end
		
		self.shockwave = false
	end
	
	--self.ToDelete = true;
end