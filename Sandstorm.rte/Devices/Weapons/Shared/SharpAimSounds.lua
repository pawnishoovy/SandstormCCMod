function Create(self)
	
	if self.parent or self.parentSet == false then
		-- we already have parentsystem, dont use another, save on performance
	else
		self.parentSet = false;
		self.useSharpAimParentSystem = true;
	end
	
	if self.sharpAimSounds then
		-- we have custom sounds for this gun (awesome), dont use defaults
	elseif self:IsInGroup("Weapons - Primary") then
		self.sharpAimSounds = {["In"] = nil, ["Out"] = nil};
		self.sharpAimSounds.In = CreateSoundContainer("DevicesWeaponsSharedSoundsSharpAimSharpAimIn", "Sandstorm.rte");
		self.sharpAimSounds.Out = CreateSoundContainer("DevicesWeaponsSharedSoundsSharpAimSharpAimOut", "Sandstorm.rte");
	elseif self:IsInGroup("Weapons - Secondary") then
		self.sharpAimSounds = {["In"] = nil, ["Out"] = nil};
		self.sharpAimSounds.In = CreateSoundContainer("DevicesWeaponsSharedSoundsSharpAimSharpAimPistolIn", "Sandstorm.rte");
		self.sharpAimSounds.Out = CreateSoundContainer("DevicesWeaponsSharedSoundsSharpAimSharpAimPistolOut", "Sandstorm.rte");
	end
	
	self.sharpAiming = false;
	
	self.sharpAimTimer = Timer();
	self.sharpAimDelay = 500;
		
	
end
function Update(self)
	
	if self.useSharpAimParentSystem then
		if self.ID == self.RootID then
			self.parent = nil;
			self.parentSet = false;
		elseif self.parentSet == false then
			local actor = MovableMan:GetMOFromID(self.RootID);
			if actor and IsAHuman(actor) then
				self.parent = ToAHuman(actor);
				self.parentSet = true;
			end
		end
	end
	
	if self.sharpAimSounds and self.sharpAimTimer:IsPastSimMS(self.sharpAimDelay) then
		if self.parent and self.parent:IsPlayerControlled() then
			local controller = self.parent:GetController();
			local sharpAim = controller:IsState(Controller.AIM_SHARP) and not controller:IsState(Controller.MOVE_LEFT) and not controller:IsState(Controller.MOVE_RIGHT)
			
			if sharpAim and self.sharpAiming == false then
				self.sharpAiming = true;
				self.sharpAimTimer:Reset();
				self.sharpAimSounds.In:Play(self.Pos);
			elseif (not sharpAim) and self.sharpAiming == true then
				self.sharpAiming = false;
				self.sharpAimTimer:Reset();
				self.sharpAimSounds.Out:Play(self.Pos);
			end
		end		
	end
	
end