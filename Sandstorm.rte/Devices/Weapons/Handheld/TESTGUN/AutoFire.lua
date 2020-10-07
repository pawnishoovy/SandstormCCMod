function Create(self)
end
function Update(self)
	self:Activate()
	
	if self.Magazine then
		self.Magazine.RoundCount = -1
	end
end