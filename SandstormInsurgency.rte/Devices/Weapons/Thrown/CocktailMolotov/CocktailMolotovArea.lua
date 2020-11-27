function Create(self)
	
	self.startSound = AudioMan:PlaySound("Sandstorm.rte/Devices/Weapons/Shared/Sounds/Explosion/Specialty/Molotov/Start1.ogg", self.Pos, -1, 0, 130, 1, 450, false);
	
	self.burnTime = self.Lifetime - 1000
	
	self.GFXDelayMin = 100
	self.GFXDelayMax = 600
	
	self.fuelData = {}
	local maxi = 32
	for i = 1, maxi do
		local data = {}
		data.Pos = Vector(self.Pos.X, self.Pos.Y)
		data.Vel = Vector(25 * ((i-1) / (maxi-1) - 0.5) + math.random(-2,2), math.random(0,-6))
		data.ID = math.random(0,999)
		data.Active = true
		data.Settled = false
		
		data.Bounces = 0
		data.BouncesMax = math.random(6,8)
		
		data.Lifetime = self.burnTime - math.random(0,1000)
		data.LifetimeTimer = Timer()
		
		data.GFXTimer = Timer()
		data.GFXDelay = math.random(self.GFXDelayMin, self.GFXDelayMax)
		
		data.DistanceToOrigin = 0
		
		table.insert(self.fuelData, data)
	end
	
	self.fuelRange = 160
	self.loopTimer = Timer()
end
function Update(self)
	
	PrimitiveMan:DrawCirclePrimitive(self.Pos, self.fuelRange, 5)
	
	if self.Age > self.burnTime then
		self.ToDelete = true
	elseif self.Age > (self.burnTime - 3000) then
		if (not self.loopSound or not self.loopSound:IsBeingPlayed() or self.loopTimer:IsPastSimMS(2480)) and not self.endSound then
			self.endSound = AudioMan:PlaySound("Sandstorm.rte/Devices/Weapons/Shared/Sounds/Explosion/Specialty/Molotov/End1.ogg", self.Pos, -1, 0, 130, 1, 450, false)
		end
	else
		if not self.loopSound or not self.loopSound:IsBeingPlayed() or self.loopTimer:IsPastSimMS(2480) then
		--if self.loopTimer:IsPastSimMS(2500) then
			self.loopSound = AudioMan:PlaySound("Sandstorm.rte/Devices/Weapons/Shared/Sounds/Explosion/Specialty/Molotov/Loop"..math.random(1,6)..".ogg", self.Pos, -1, 0, 130, 1, 450, false)
			self.loopTimer:Reset()
		end
	end
	
	local averagePos = Vector()
	for fuelI, fuel in ipairs(self.fuelData) do
		
		if fuel.Active then
			averagePos = averagePos + SceneMan:ShortestDistance(fuel.Pos, self.Pos, true)
			
			--.ElapsedSimTimeMS
			
			if not fuel.Settled then -- Scatter/Spread
				
				fuel.DistanceToOrigin = SceneMan:ShortestDistance(fuel.Pos, self.Pos, true).Magnitude
			
				local velMagnitude = fuel.Vel.Magnitude
				
				local step = Vector(fuel.Vel.X, fuel.Vel.Y) * GetPPM() * TimerMan.DeltaTimeSecs
				local checkPos = Vector(fuel.Pos.X, fuel.Pos.Y) + step
				if velMagnitude > 1 then -- Collision
					--if SceneMan:GetTerrMatter(checkPos.X, checkPos.Y) == 0 then
					--	fuel.Pos = fuel.Pos + step
					--end
					fuel.Pos = fuel.Pos + step
					
					if (self.Age + fuel.ID) % 4 >= 2 then -- Optimization: update only some fuel points
						local detections = 0
						local lastPos = Vector(fuel.Pos.X, fuel.Pos.Y)
						
						local maxi = 6
						for i = 1, maxi do
							local angle = math.pi * 2 / maxi * i
							local vec = Vector(3,0):RadRotate(angle):RadRotate(((self.Age + fuel.ID) % 12) / 6 * math.pi)
							local pos = fuel.Pos + vec
							if SceneMan:GetTerrMatter(pos.X, pos.Y) ~= 0 then
								fuel.Pos = fuel.Pos - vec:SetMagnitude(1)
								fuel.Vel = fuel.Vel - vec:SetMagnitude(math.min(velMagnitude, 2))
								
								fuel.Vel = fuel.Vel / (1 + TimerMan.DeltaTimeSecs * maxi * 0.3)
								
								detections = detections + 1
							end
						end
						
						if detections > maxi-1 then
							fuel.Active = false
						else
							fuel.Bounces = fuel.Bounces + detections
							if fuel.Bounces > fuel.BouncesMax then -- Settle
								local strength = SceneMan:CastStrengthSumRay(fuel.Pos, lastPos, 0, 98);
								if strength < 80 then
									fuel.Settled = true
								else
									fuel.Active = false
								end
							end
						end
					end
				end
				
				fuel.Vel = fuel.Vel + SceneMan.GlobalAcc * TimerMan.DeltaTimeSecs * 0.65
				fuel.Vel = fuel.Vel / (1 + TimerMan.DeltaTimeSecs * 1.5)
			
				if fuel.DistanceToOrigin > self.fuelRange then -- Delete when out of range
					fuel.Active = false
				end
				
			end
			
			-- Lifetime
			local lifespan = fuel.Lifetime * (2 - (fuel.DistanceToOrigin / self.fuelRange)) / 2
			local strength = 1 - (fuel.LifetimeTimer.ElapsedSimTimeMS / lifespan)
			
			--.ElapsedSimTimeMS
			if fuel.LifetimeTimer:IsPastSimMS(lifespan) then
				fuel.Active = false
			end
			
			-- GFX
			if fuel.GFXTimer:IsPastSimMS(fuel.GFXDelay * (1 + (1 - strength))) then
				
				for i = 1, math.random(1,3) do
					fx = CreateMOSParticle("Sandstorm Cocktail Molotov Flame");
					if fx then
						fx.Pos = fuel.Pos +  Vector(RangeRand(-1, 1), RangeRand(-1, 1)) * 2;
						fx.Vel = Vector(RangeRand(-1, 1), RangeRand(-1, 1)) * 5
						fx.Lifetime = fx.Lifetime * RangeRand(0.7, 1.7) * 0.5 * (0.5 + strength);
						--smoke.GlobalAccScalar = RangeRand(-1, 1) * 0.15; -- Go up and down
						if math.random(1,3) < 2 then
							fx.GlobalAccScalar = RangeRand(0.5, 0.2)
							fx.Lifetime = fx.Lifetime * 2
						end
						MovableMan:AddParticle(fx);
					end
				end
				
				fuel.GFXTimer:Reset()
				fuel.GFXDelay = math.random(self.GFXDelayMin, self.GFXDelayMax)
			end
			
			--PrimitiveMan:DrawCirclePrimitive(fuel.Pos, 13 - 10 * (1 - strength), 13) -- Debug draw
		end
	end
	
	--PrimitiveMan:DrawCirclePrimitive(self.Pos - averagePos / #self.fuelData, 3, 122)
	self.Pos = self.Pos - averagePos / #self.fuelData
end