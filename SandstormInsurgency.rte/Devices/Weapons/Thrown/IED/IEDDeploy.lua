function Create(self)

	self.detonateSound = CreateSoundContainer("IED Detonate", "SandstormInsurgency.rte");

	self.parentSet = false;
	self.lastAge = self.Age + 0
	
	self.displayChargeTimer = Timer()
	self.displayCharge = false
	
	self.detonatorName = "IED Detonator"
	
	if self.PresetName == self.detonatorName then
		self.state = 1
		
		self.destroyTimer = Timer()
		self.destroy = false
	else
		self.deploymentStartTimer = Timer()
		self.deploymentStartDelay = 500
		self.deployment = false
		
		self.triggerVO = true
		
		self.state = 0
	end
	
	-- for planting sounds
	-- impact sounds when thrown are done on IEDSet.lua

	self.terrainSounds = {
	Impact = {[12] = CreateSoundContainer("IED Impact Concrete", "Sandstorm.rte"),
			[164] = CreateSoundContainer("IED Impact Concrete", "Sandstorm.rte"),
			[177] = CreateSoundContainer("IED Impact Concrete", "Sandstorm.rte"),
			[9] = CreateSoundContainer("IED Impact Dirt", "Sandstorm.rte"),
			[10] = CreateSoundContainer("IED Impact Dirt", "Sandstorm.rte"),
			[11] = CreateSoundContainer("IED Impact Dirt", "Sandstorm.rte"),
			[128] = CreateSoundContainer("IED Impact Dirt", "Sandstorm.rte"),
			[6] = CreateSoundContainer("IED Impact Sand", "Sandstorm.rte"),
			[8] = CreateSoundContainer("IED Impact Sand", "Sandstorm.rte"),
			[178] = CreateSoundContainer("IED Impact SolidMetal", "Sandstorm.rte"),
			[179] = CreateSoundContainer("IED Impact SolidMetal", "Sandstorm.rte"),
			[180] = CreateSoundContainer("IED Impact SolidMetal", "Sandstorm.rte"),
			[181] = CreateSoundContainer("IED Impact SolidMetal", "Sandstorm.rte"),
			[182] = CreateSoundContainer("IED Impact SolidMetal", "Sandstorm.rte")}}
	
end

function Update(self)

	if self.ID == self.RootID then
		self.parent = nil;
		self.parentSet = false;
		self:RemoveNumberValue("Sandstorm Custom Activation");
		self:RemoveNumberValue("Sandstorm Custom Throw");
		self:RemoveNumberValue("Sandstorm Custom Throwstart");
	elseif self.parentSet == false then
		local actor = MovableMan:GetMOFromID(self.RootID);
		if actor and IsAHuman(actor) then
			self.parent = ToAHuman(actor);
			self.parentSet = true;
		end
	end
	
	-- Check if switched weapons/hide in the inventory, etc.
	if self.Age > (self.lastAge + TimerMan.DeltaTimeSecs * 2000) then
		if self.PresetName ~= self.detonatorName then
			self.deployment = false
			self.deploymentStartTimer:Reset()
		else
			self.displayChargeTimer:Reset()
			self.displayCharge = true
		end
	end
	self.lastAge = self.Age + 0
	
	local activated = self:IsActivated()
	self:Deactivate()
	
	if self.parent then
		self.parent:GetController():SetState(Controller.AIM_SHARP,false)
	end
	
	if self.state == 0 then -- Deployment
		if activated then
			if not self.deployment then
				self.deployment = true
				self.deploymentStartTimer:Reset()
			end
			
		end
		
		if self.deployment and self.parent then
			if self.deploymentStartTimer:IsPastSimMS(self.deploymentStartDelay) then
				if self.triggerVO then
					self:SetNumberValue("Sandstorm Custom Activation", 1)
					self.triggerVO = false
				end
				
				local hitLocation = Vector()
				--local checkOrigin = self.parent.FGArm.Pos + Vector(self.StanceOffset.X, self.StanceOffset.Y - 2):RadRotate(self.RotAngle)
				local checkOrigin = self.parent.FGArm.Pos + Vector(7 * self.FlipFactor, 2):RadRotate(self.RotAngle)
				local checkVec = Vector(24 * self.FlipFactor, 0):RadRotate(self.RotAngle)
				--local terrCheck = SceneMan:CastStrengthSumRay(checkOrigin, checkOrigin + checkVec, 2, 0);
				local terrCheck = SceneMan:CastStrengthRay(checkOrigin, checkVec, 30, hitLocation, 2, 0, SceneMan.SceneWrapsX)
				
				local direction = self.RotAngle
				
				local rayEndPos = checkOrigin + checkVec
				if terrCheck then 
					local rayHitPos = SceneMan:GetLastRayHitPos()
					rayEndPos = Vector(rayHitPos.X, rayHitPos.Y)
					
					local normal = Vector()
					local maxi = 8
					for i = 1, maxi do
						local vec =Vector(3,0):RadRotate(math.pi * 2 * (i / maxi))
						local checkPos = rayEndPos + vec
						local checkPix = SceneMan:GetTerrMatter(checkPos.X, checkPos.Y)
						if checkPix == 0 then
							normal = normal + vec
						end
					end
					direction = normal.AbsRadAngle
					
					-- cool VISUALIZATIONZZZZ
					local color = 120
					local position = rayEndPos + Vector(2,0):RadRotate(direction)
					local width = 12 * 0.5
					local height = 4 * 0.5
					
					PrimitiveMan:DrawLinePrimitive(position + Vector(width, height):RadRotate(direction + math.pi/2), position + Vector(-width, height):RadRotate(direction + math.pi/2), color)
					
					PrimitiveMan:DrawLinePrimitive(position + Vector(-width, height):RadRotate(direction + math.pi/2), position + Vector(-width, -height):RadRotate(direction + math.pi/2), color)
					PrimitiveMan:DrawLinePrimitive(position + Vector(width, -height):RadRotate(direction + math.pi/2), position + Vector(width, height):RadRotate(direction + math.pi/2), color)
					
					PrimitiveMan:DrawLinePrimitive(position + Vector(width, -height):RadRotate(direction + math.pi/2), position + Vector(-width, -height):RadRotate(direction + math.pi/2), color)
				
				else
					local color = 120
					
					local maxi = 3
					for i = 1, maxi do
						PrimitiveMan:DrawLinePrimitive(checkOrigin + checkVec * i / maxi * 0.8, checkOrigin + checkVec * i / maxi, color)
					end
					PrimitiveMan:DrawLinePrimitive(checkOrigin + checkVec, checkOrigin + checkVec + Vector(-5 * self.FlipFactor, 4):RadRotate(self.RotAngle), color)
					PrimitiveMan:DrawLinePrimitive(checkOrigin + checkVec, checkOrigin + checkVec + Vector(-5 * self.FlipFactor, -4):RadRotate(self.RotAngle), color)
				end
				
				-- Stick
				if terrCheck then
					self.throwStartSet = false;
					self.StanceOffset = Vector(6, 1)
					self.SupportOffset = Vector(1, 1)
					
					
					
					--PrimitiveMan:DrawLinePrimitive(checkOrigin, rayEndPos, 5)
					
					if not activated then
						self.state = 1

						local terrainID = SceneMan:GetTerrMatter(hitLocation.X, hitLocation.Y);
						--AudioMan:PlaySound("SandstormInsurgency.rte/Devices/Weapons/Thrown/IED/Sounds/Attach.ogg", self.Pos, -1, 0, 130, 1, 170, false)
						if self.terrainSounds.Impact[terrainID] ~= nil then
							self.terrainSounds.Impact[terrainID]:Play(self.Pos);
						else -- default to concrete
							self.terrainSounds.Impact[177]:Play(self.Pos);
						end
						
						local set = CreateMOSRotating(self.PresetName.." Active");
						set.Pos = rayEndPos + Vector(2,0):RadRotate(direction);
						set.PinStrength = 100
						set:SetNumberValue("Set", 1);
						set.RotAngle = direction + math.pi
						set.Team = self.Team
						set.IgnoresTeamHits = true
						set.Vel = self.Vel;
						
						MovableMan:AddParticle(set)
						self:SetNumberValue("ChargeID", set.UniqueID)
					end
				else
				-- Throw
					if self.throwStartSet ~= true then
						self:SetNumberValue("Sandstorm Custom Throwstart", 1)
						self.throwStartSet = true;
					end
					self.StanceOffset = Vector(-12, 3)
					self.SupportOffset = Vector(90, 90)
					
					if not activated then
						self:SetNumberValue("Sandstorm Custom Throw", 1)
						self.state = 1
						
						local set = CreateMOSRotating(self.PresetName.." Active");
						set.Pos = self.Pos;
						set.RotAngle = self.RotAngle
						set.Team = self.Team
						set.IgnoresTeamHits = true
						--set.Vel = self.Vel + Vector(15 * self.FlipFactor, 0):RadRotate(self.RotAngle)
						set.Vel = Vector(15 * self.FlipFactor, 0):RadRotate(self.RotAngle)
						
						MovableMan:AddParticle(set)
						self:SetNumberValue("ChargeID", set.UniqueID)
					end
				end
				
			elseif not activated then
				self.deployment = false
			end
			self.Frame = math.floor(math.min(self.deploymentStartTimer.ElapsedSimTimeMS / self.deploymentStartDelay, 1) * 2 + 0.5)
		else
			self.JointOffset = Vector(-1, 1)
			self.StanceOffset = Vector(7, 6)
			self.SupportOffset = Vector(1, 1)
			
			self.Frame = 0
			self.deploymentStartTimer:Reset()
		end
		
	elseif self.state == 1 then -- Detonator
		self.JointOffset = Vector(1, 1)
		self.StanceOffset = Vector(7, 6)
		self.SupportOffset = Vector(0, 1)
		
		if self.PresetName ~= self.detonatorName then
			self.PresetName = self.detonatorName
		end
		
		if not self.displayChargeTimer:IsPastSimMS(2000) then
			if self.displayCharge then
				local charge = MovableMan:FindObjectByUniqueID(self:GetNumberValue("ChargeID"))
				if charge then
					local pos = ToMOSRotating(charge).Pos
					local angle = ToMOSRotating(charge).RotAngle
					
					local color = 5
					local width = 12 * 0.5
					local height = 4 * 0.5
					
					PrimitiveMan:DrawLinePrimitive(pos + Vector(width, height):RadRotate(angle + math.pi/2), pos + Vector(-width, height):RadRotate(angle + math.pi/2), color)
					
					PrimitiveMan:DrawLinePrimitive(pos + Vector(-width, height):RadRotate(angle + math.pi/2), pos + Vector(-width, -height):RadRotate(angle + math.pi/2), color)
					PrimitiveMan:DrawLinePrimitive(pos + Vector(width, -height):RadRotate(angle + math.pi/2), pos + Vector(width, height):RadRotate(angle + math.pi/2), color)
					
					PrimitiveMan:DrawLinePrimitive(pos + Vector(width, -height):RadRotate(angle + math.pi/2), pos + Vector(-width, -height):RadRotate(angle + math.pi/2), color)
				end
			end
		else
			self.displayCharge = false
		end
		
		if activated and self:NumberValueExists("ChargeID") then
			local charge = MovableMan:FindObjectByUniqueID(self:GetNumberValue("ChargeID"))
			if charge then
				ToMOSRotating(charge):SetNumberValue("Fuse", 1)
			end
			self.detonateSound:Play(self.Pos);
			self.destroy = true
			self.destroyTimer:Reset()
			
			self:RemoveNumberValue("ChargeID")
		end
		
		if self.destroy and self.destroyTimer:IsPastSimMS(1000) then
			self.JointStrength = -5
			self.HUDVisible = false
			self.RestThreshold = 500
			self.GetsHitByMOs = false
			self.GibImpulseLimit = 1
			
			--if self.parent then -- It kinda broken
				--self.parent:GetController():SetState(Controller.WEAPON_CHANGE_PREV, true)
			--end
		end
		
		self.Frame = 3
	end
	
	self.SharpStanceOffset = Vector(self.StanceOffset.X * self.FlipFactor, self.StanceOffset.Y)
end