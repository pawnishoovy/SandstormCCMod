function Create(self)
	self.effectOn = math.random(1,4) < 2
	self.effectLoss = math.random(-10,10)
	
	self.baseSharpness = self.Sharpness
	
	--self.effectNames = {"Tiny Smoke Ball 1", "Tiny Smoke Ball 1", "Tiny Smoke Ball 1",  "Tiny Smoke Ball 1", "Tracer Smoke Ball 1", "Blast Ball Small 1", "Tracer Smoke Ball 1"}
	self.effectNames = {"Tiny Smoke Ball 1", "Tiny Smoke Ball 1", "Tiny Smoke Ball 1",  "Tiny Smoke Ball 1", "Tracer Smoke Ball 1"}
end

function Update(self)
	self.Sharpness = self.baseSharpness / (1 + self.Age * 0.002)
	
	if self.effectOn then
		local effect
		local offset = self.Vel * rte.PxTravelledPerFrame

		local maxi = math.max(math.floor((offset.Magnitude * 0.1) + 0.5), 1)
		for i = 1, maxi do
			if math.random(0,100) >= self.effectLoss then
				effect = CreateMOSParticle(self.effectNames[math.random(1, #self.effectNames)])
				if effect then
					effect.Pos = self.Pos - offset * (i/maxi) * RangeRand(0.95,1.05) + Vector(RangeRand(-1, 1), RangeRand(-1, 1))
					effect.Vel = self.Vel * RangeRand(0.6, 0.8) + Vector(RangeRand(-1, 1), RangeRand(-1, 1)) * 5
					effect.Lifetime = effect.Lifetime * RangeRand(0.8,1.2);
					MovableMan:AddParticle(effect)
				end
				
				self.effectLoss = self.effectLoss + TimerMan.DeltaTimeSecs * 150 / maxi
			end
			
		end
	end
end