

function Create(self)
	self.beltStartPoint = Vector(-7,3)
	self.beltEndPoint = Vector(10,2)
	self.beltLengthMax = 15
	
	self.beltPointPosX = self.Pos.X
	self.beltPointPosY = self.Pos.Y
	
	self.beltPointVelX = 0
	self.beltPointVelY = 0
	
	self.color = 55
end

function Update(self)
	local posA = Vector(self.Pos.X, self.Pos.Y) + Vector(self.beltStartPoint.X * self.FlipFactor, self.beltStartPoint.Y):RadRotate(self.RotAngle)
	local posB = Vector(self.Pos.X, self.Pos.Y) + Vector(self.beltEndPoint.X * self.FlipFactor, self.beltEndPoint.Y):RadRotate(self.RotAngle)
	--PrimitiveMan:DrawLinePrimitive(self.Pos, self.Pos + self.beltPointA, 5);
	--PrimitiveMan:DrawLinePrimitive(posA, posB, 5);
	-- Physics
	local v = Vector(self.beltPointVelX, self.beltPointVelY) + SceneMan.GlobalAcc * TimerMan.DeltaTimeSecs -- Gravity
	
	-- Pull the point to belt Stat and End points
	for i, point in ipairs({self.beltStartPoint, self.beltEndPoint}) do
		point = Vector(self.Pos.X, self.Pos.Y) + Vector(point.X * self.FlipFactor, point.Y):RadRotate(self.RotAngle)
		local dif = SceneMan:ShortestDistance(Vector(self.beltPointPosX, self.beltPointPosY), point,SceneMan.SceneWrapsX)
		v = v + dif * math.min(math.max((dif.Magnitude / 5) - 1, 0), 6) * TimerMan.DeltaTimeSecs
	end
	
	v = v / (1 + TimerMan.DeltaTimeSecs * 6.0) -- Air Friction
	
	self.beltPointVelX = v.X
	self.beltPointVelY = v.Y
	
	self.beltPointPosX = self.beltPointPosX + self.beltPointVelX * rte.PxTravelledPerFrame
	self.beltPointPosY = self.beltPointPosY + self.beltPointVelY * rte.PxTravelledPerFrame
	
	-- Limit Position
	local posCenter = (posA + posB) * 0.5
	local newPos = SceneMan:ShortestDistance(posCenter, Vector(self.beltPointPosX, self.beltPointPosY), SceneMan.SceneWrapsX)
	newPos = posCenter + newPos:SetMagnitude(math.min(newPos.Magnitude, self.beltLengthMax))
	self.beltPointPosX = newPos.X
	self.beltPointPosY = newPos.Y
	
	-- DEBUG
	--PrimitiveMan:DrawLinePrimitive(posA, posA, 13);
	--PrimitiveMan:DrawLinePrimitive(posB, posB, 13);
	local pos = Vector(self.beltPointPosX, self.beltPointPosY)
	--PrimitiveMan:DrawLinePrimitive(pos, pos + SceneMan:ShortestDistance(pos,posA,SceneMan.SceneWrapsX), 5);
	--PrimitiveMan:DrawLinePrimitive(pos, pos + SceneMan:ShortestDistance(pos,posB,SceneMan.SceneWrapsX), 5);
	
	local maxi = 5
	local pointLast = Vector(0,0)
	for i = 0, maxi do
		local fac = i / maxi
		local p1 =  posA - self.Pos
		local p2 =  pos - self.Pos
		local p3 =  posB - self.Pos
		
		local point = p1 * math.pow(1 - fac, 2) + p2 * 2 * (1 - fac) * fac + p3 * math.pow(fac, 2)
		
		--PrimitiveMan:DrawLinePrimitive(self.Pos + p1, self.Pos + p2, 13)
		--PrimitiveMan:DrawLinePrimitive(self.Pos + p3, self.Pos + p2, 13)
		if i > 0 then
			PrimitiveMan:DrawLinePrimitive(self.Pos + point, self.Pos + pointLast, self.color)
		end
		pointLast = point
		
		--PrimitiveMan:DrawCirclePrimitive(self.Pos + p1, 1, 13);
		--PrimitiveMan:DrawCirclePrimitive(self.Pos + p2, 1, 13);
		--PrimitiveMan:DrawCirclePrimitive(self.Pos + p3, 1, 13);
	end
	
	-- Simple fix for scene wrapping
	
	if SceneMan.SceneWrapsX then
		if self.beltPointPosX > SceneMan.SceneWidth then
			self.beltPointPosX = self.beltPointPosX - SceneMan.SceneWidth
		elseif self.beltPointPosX < 0 then
			self.beltPointPosX = self.beltPointPosX + SceneMan.SceneWidth
		end
	end
end 