function Create(self)
	self.strength = self.Mass * self.Vel.Magnitude;
	self.range = 5 * self.Vel.Magnitude;
	
	local maxi = 1
	
	--[[
	maxi = 240
	for i = 1, maxi do
		local effect = CreateMOPixel("Shockwave Blast", "Sandstorm.rte")
		effect.Pos = self.Pos + Vector(RangeRand(-1,1), RangeRand(-1,1)) * 3
		effect.Vel = Vector(self.Vel.Magnitude * RangeRand(0.95,1.05) * 2,0):RadRotate(math.pi * 2 / maxi * i + RangeRand(-1,1) / maxi)
		effect.Lifetime = effect.Lifetime * math.random(1,4) * 0.5
		MovableMan:AddParticle(effect)
	end]]
	
	--[[
	local maxi = 240
	for i = 1, maxi do
		local effect = CreateMOSParticle("Fire Ball 4 B", "Sandstorm.rte")
		effect.Pos = self.Pos + Vector(RangeRand(-1,1), RangeRand(-1,1))
		effect.Vel = Vector(self.Vel.Magnitude * RangeRand(0.95,1.05) * 0.7,0):RadRotate(math.pi * 2 / maxi * i + RangeRand(-1,1) / maxi)
		effect.Lifetime = effect.Lifetime * math.random(1,8) * 0.15
		MovableMan:AddParticle(effect)
	end]]
	
	maxi = 100
	for i = 1, maxi do
		local pos = self.Pos + Vector(RangeRand(-1,1), RangeRand(-1,1)) * 6
		for i = 1, 3 do
			if SceneMan:GetTerrMatter(pos.X, pos.Y) == 0 then
				break
			else
				pos = self.Pos + Vector(RangeRand(-1,1), RangeRand(-1,1)) * 6
			end
		end
		
		local effect = CreateMOSRotating("Ground Smoke Particle 1", "Sandstorm.rte")
		--effect.Pos = self.Pos + Vector(RangeRand(-1,1), RangeRand(-1,1)) * 6
		effect.Pos = pos
		effect.Vel = Vector(math.random(110,200),0):RadRotate(math.pi * 2 / maxi * i + RangeRand(-2,2) / maxi)
		effect.Lifetime = effect.Lifetime * RangeRand(0.8,2.0)
		effect.AirResistance = effect.AirResistance * RangeRand(0.5,0.8)
		MovableMan:AddParticle(effect)
	end
	
	self.shockwave = true
end
function Update(self)
	--PrimitiveMan:DrawCirclePrimitive(self.Pos, self.range, 5)
	
	-- Run the effect on Update() to give other particles a chance to reach the target
	if self.shockwave then
		for i = 1 , MovableMan:GetMOIDCount() - 1 do
			local mo = MovableMan:GetMOFromID(i);
			if mo and mo.PinStrength == 0 then
				local dist = SceneMan:ShortestDistance(self.Pos, mo.Pos, SceneMan.SceneWrapsX);
				if dist.Magnitude < self.range then
					local strSumCheck = SceneMan:CastStrengthSumRay(self.Pos, self.Pos + dist, 3, 0);
					if strSumCheck < self.strength then
						if IsActor(mo) and dist.Magnitude < (self.range * 0.6) then 
							ToActor(mo):SetNumberValue("Sandstorm Shockwave", 1);
						end
						local massFactor = math.sqrt(1 + math.abs(mo.Mass));
						local distFactor = 1 + dist.Magnitude * 0.1
						local forceVector =	dist:SetMagnitude((self.strength - strSumCheck) /distFactor);
						
						local closeFactor = math.min(dist.Magnitude * 0.02, 1)
						mo.Vel = mo.Vel + forceVector / massFactor * closeFactor;
						mo.AngularVel = mo.AngularVel - forceVector.X /(massFactor + math.abs(mo.AngularVel));
						mo:AddForce(forceVector * massFactor * closeFactor, Vector());
						if IsMOSRotating(mo) then
							mo = ToMOSRotating(mo)
							-- 400 - 200
							local wounding = math.pow((self.strength - strSumCheck) / distFactor / 50, 2.0)
							local woundName = mo:GetEntryWoundPresetName()
							local woundNameExit = mo:GetExitWoundPresetName()
							if woundName and woundName ~= "" and woundNameExit and woundNameExit ~= "" and math.floor(wounding + 0.5) > 0 then
								for i = 1, math.floor(wounding + 0.5) do
									local wound = CreateAEmitter(woundName)
									if wound then
										mo:AddWound(wound, Vector(RangeRand(-1,1),RangeRand(-1,1)) * self.Radius * 0.7, true)
									end
									
								end
								if wounding > 0.7 and IsActor(mo) and IsAHuman(mo) then
									local act = ToActor(mo)
									if act.Status == 0 then
										act.Status = 1
									end
								end
								
							end
							
							if mo.GibImpulseLimit ~= nil and mo.GibImpulseLimit > 0 and (forceVector * massFactor).Magnitude > (mo.GibImpulseLimit * distFactor) * RangeRand(1.3,3) * 1.5 then
								mo:GibThis()
							end
						end
						
					end
				end
			end	
		end
		
		self.shockwave = false
	end
	
	self.ToDelete = true;
end