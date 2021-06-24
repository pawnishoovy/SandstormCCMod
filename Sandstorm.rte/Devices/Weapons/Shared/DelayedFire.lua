function Create(self)
	
	self.preDelay = 50
	self.preFireTimer = Timer()
	self.preFire = false
	self.preFireFired = false
	self.preFireActive = false
	
	if self:NumberValueExists("DelayedFireTimeMS") then
		self.preDelay = self:GetNumberValue("DelayedFireTimeMS")
		self:RemoveNumberValue("DelayedFireTimeMS")
	end
	
end
function Update(self)
	
	if (self.Magazine and self.Magazine.RoundCount > 0 and not self:IsReloading()) then
		local active = self:IsActivated() and not self.Chamber and not self.Deploy
		--if (active or self.preFire) and (self.fireTimer:IsPastSimMS(60000/self.RateOfFire) or self.preFireTimer:IsPastSimMS(self.preDelay)) then
		if active or self.preFire then
			if not self.preFireActive then
				self.preSound:Play(self.Pos)
				self.preFire = true
				self.preFireActive = true
			end
			
			if self.preFireTimer:IsPastSimMS(self.preDelay) then
				if self.FiredFrame then
					self.preFireFired = false
					self.preFire = false
				elseif not self.preFireFired then
					self:Activate()
				end
				
			else
				self:Deactivate()
			end
		else
			self.preFireActive = active
			self.preFireTimer:Reset()
		end
	else
		self.preFireFired = false
		self.preFire = false
	end
	
end