function Create(self)
	self.parentSet = false;
	self.lastAge = self.Age + 0
	
	self.deployment = false;
	self.deploymentStartTimer = Timer();
	self.deploymentStartDelay = 500;
	
	self.deploymentPinPullDelay = 1000;
	self.deploymentPullHarderDelay = 2000;
	
	self.deploymentThrowDelay = 3000;
	
	self.pinPulled = false;
	self.PullHardered = false;
	
	self.triggerVO = true;
	
	-- impact sounds when thrown are done on TM62Set.lua
	
end

function Update(self)

	if self.destroy then
		self.ToDelete = true;
	end

	if self.ID == self.RootID then
		self.parent = nil;
		self.parentSet = false;
		self:RemoveNumberValue("Sandstorm Custom Activation");
		self:RemoveNumberValue("Sandstorm Custom Throw");
		self:RemoveNumberValue("Sandstorm Custom Throwstart");
		
		self.readyToThrow = false;
		self.triggerVO = true;
		
	elseif self.parentSet == false then
		local actor = MovableMan:GetMOFromID(self.RootID);
		if actor and IsAHuman(actor) then
			self.parent = ToAHuman(actor);
			self.parentSet = true;
		end
	end
	
	-- Check if switched weapons/hide in the inventory, etc.
	if self.Age > (self.lastAge + TimerMan.DeltaTimeSecs * 2000) then
		self.deployment = false
		self.deploymentStartTimer:Reset()
	end
	self.lastAge = self.Age + 0
	
	local activated = self:IsActivated()
	self:Deactivate()
	
	if self.parent then
		self.parent:GetController():SetState(Controller.AIM_SHARP,false)
	end
	
	if activated then
		if self.deployment == false then
			self.deployment = true
			self.deploymentStartTimer:Reset()
		end
	end
		
	if self.deployment and self.parent then
		self.Frame = math.floor(math.min(self.deploymentStartTimer.ElapsedSimTimeMS / self.deploymentPullHarderDelay, 1) * 2 + 0.5)
		if self.deploymentStartTimer:IsPastSimMS(self.deploymentStartDelay) then
			self.StanceOffset = Vector(6, 1)
			self.SupportOffset = Vector(1, 1)
			
			if self.deploymentStartTimer:IsPastSimMS(self.deploymentPinPullDelay) then
				self.deploymentPinPullDelay = 200;
				if self.pinPulled == false then
					AudioMan:PlaySound("SandstormInsurgency.rte/Devices/Weapons/Thrown/TM62/Sounds/Pull.ogg", self.Pos, -1, 0, 130, 1, 170, false);
					self.pinPulled = true;
				end
				if self.deploymentStartTimer:IsPastSimMS(self.deploymentPullHarderDelay) then
					self.deploymentStartDelay = 100;
					self.deploymentPullHarderDelay = 1000;
					if self.PullHardered == false then
						AudioMan:PlaySound("SandstormInsurgency.rte/Devices/Weapons/Thrown/TM62/Sounds/PullHarder.ogg", self.Pos, -1, 0, 130, 1, 170, false);
						self.PullHardered = true;
					end
					
					if self.deploymentStartTimer:IsPastSimMS(self.deploymentThrowDelay) then			
						if self.triggerVO then
							self:SetNumberValue("Sandstorm Custom Activation", 1)
							self.triggerVO = false
						end
						self.readyToThrow = true;
										
						if self.throwStartSet ~= true then
							self:SetNumberValue("Sandstorm Custom Throwstart", 1)
							self.throwStartSet = true;
						end
						self.StanceOffset = Vector(-12, 3)
						self.SupportOffset = Vector(90, 90)
						
						self.Frame = 2

						local checkOrigin = self.parent.FGArm.Pos + Vector(7 * self.FlipFactor, 2):RadRotate(self.RotAngle)
						local checkVec = Vector(24 * self.FlipFactor, 0):RadRotate(self.RotAngle)
						local color = 120
						
						local maxi = 3
						for i = 1, maxi do
							PrimitiveMan:DrawLinePrimitive(checkOrigin + checkVec * i / maxi * 0.8, checkOrigin + checkVec * i / maxi, color)
						end
						PrimitiveMan:DrawLinePrimitive(checkOrigin + checkVec, checkOrigin + checkVec + Vector(-5 * self.FlipFactor, 4):RadRotate(self.RotAngle), color)
						PrimitiveMan:DrawLinePrimitive(checkOrigin + checkVec, checkOrigin + checkVec + Vector(-5 * self.FlipFactor, -4):RadRotate(self.RotAngle), color)
					end
				end
			end
		end
		if not activated then
			if not self.readyToThrow then
				self.deployment = false;
				--self.pinPulled = false;
				--self.PullHardered = false;
				self.triggerVO = true;
				if self.PullHardered then
					self.deploymentThrowDelay = 1400;
				end
				self.PullHardered = false;
			elseif not self.thrown then
				self.thrown = true;
				self:SetNumberValue("Sandstorm Custom Throw", 1)
				
				local set = CreateMOSRotating(self.PresetName.." Active");
				set.Pos = self.Pos
				set.RotAngle = 0
				--set.RotAngle = self.RotAngle
				set.Team = self.Team
				set.IgnoresTeamHits = true
				--set.Vel = self.Vel + Vector(15 * self.FlipFactor, 0):RadRotate(self.RotAngle)
				set.Vel = Vector(7 * self.FlipFactor, 0):RadRotate(self.RotAngle)
				
				MovableMan:AddParticle(set)
				self.destroy = true;
			end
		end
	else
		self.JointOffset = Vector(-1, 1)
		self.StanceOffset = Vector(7, 6)
		self.SupportOffset = Vector(1, 1)
		
		self.Frame = 0
		
		self.deploymentStartTimer:Reset()
	end
	
	
	self.SharpStanceOffset = Vector(self.StanceOffset.X * self.FlipFactor, self.StanceOffset.Y)
end