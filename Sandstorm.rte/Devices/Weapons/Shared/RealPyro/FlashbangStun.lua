function Create(self)
	self.strength = self.Mass * self.Vel.Magnitude;
	self.range = 5 * self.Vel.Magnitude;
	
	local maxi = 1
	
	
	maxi = 240
	for i = 1, maxi do
		local effect = CreateMOPixel("Shockwave Blast", "Sandstorm.rte")
		effect.Pos = self.Pos + Vector(RangeRand(-1,1), RangeRand(-1,1)) * 3
		effect.Vel = Vector(self.Vel.Magnitude * RangeRand(0.95,1.05) * 2,0):RadRotate(math.pi * 2 / maxi * i + RangeRand(-1,1) / maxi)
		effect.Lifetime = effect.Lifetime * math.random(1,4) * 0.5
		MovableMan:AddParticle(effect)
	end
	
	self.flash = true
	self.flashedActors = {}
end
function Update(self)
	--PrimitiveMan:DrawCirclePrimitive(self.Pos, self.range, 5)
	
	-- Run the effect on Update() to give other particles a chance to reach the target
	if self.flash then
		for actor in MovableMan.Actors do
			local dist = SceneMan:ShortestDistance(self.Pos, actor.Pos, SceneMan.SceneWrapsX);
			
			local distHead = nil
			if actor.Head then
				distHead = SceneMan:ShortestDistance(self.Pos, actor.Pos, SceneMan.SceneWrapsX);
			end
			if dist.Magnitude < self.range then
				
				local canFlash = false
				if SceneMan:CastStrengthSumRay(self.Pos, self.Pos + dist, 3, 0) < self.strength then
					canFlash = true
				elseif distHead and SceneMan:CastStrengthSumRay(self.Pos, self.Pos + distHead, 3, 0) < self.strength then
					canFlash = true
				end
				
				if canFlash and actor.ClassName ~= "ADoor" and actor.ClassName ~= "ACraft" then
					if actor.Status == 0 and IsAHuman(actor) then
						actor.Status = 1
					end
					if math.random(1,3) < 2 and actor:GetController() then
						actor:GetController():SetState(Controller.WEAPON_DROP,true)
					end
					actor:SetNumberValue("Flashed", 1)
					
					table.insert(self.flashedActors, actor.UniqueID)
				end
			end
		end
		
		self.flash = false
	end
	for i, ID in ipairs(self.flashedActors) do
		local actor = ToActor(MovableMan:FindObjectByUniqueID(ID))
		if actor then
			actor = ToActor(actor)
			if actor.Status == 0 and IsAHuman(actor) then
				actor.Status = 1
			end
			local ctrl = actor:GetController()
			if ctrl then
				ctrl:SetState(Controller.WEAPON_FIRE,false)
				ctrl:SetState(Controller.AIM_SHARP,false)
				ctrl:SetState(Controller.MOVE_LEFT,false);
				ctrl:SetState(Controller.MOVE_RIGHT,false);
			end
		end
	end
	--self.ToDelete = true;
end