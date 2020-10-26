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
		self.sharpAimSounds.In = {["Variations"] = 6,
		["Path"] = "Sandstorm.rte/Devices/Weapons/Shared/Sounds/SharpAim/SharpAimIn"};
		self.sharpAimSounds.Out = {["Variations"] = 6,
		["Path"] = "Sandstorm.rte/Devices/Weapons/Shared/Sounds/SharpAim/SharpAimOut"};
	elseif self:IsInGroup("Weapons - Secondary") then
		self.sharpAimSounds = {["In"] = nil, ["Out"] = nil};
		self.sharpAimSounds.In = {["Variations"] = 6,
		["Path"] = "Sandstorm.rte/Devices/Weapons/Shared/Sounds/SharpAim/SharpAimPistolIn"};
		self.sharpAimSounds.Out = {["Variations"] = 6,
		["Path"] = "Sandstorm.rte/Devices/Weapons/Shared/Sounds/SharpAim/SharpAimPistolOut"};	
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
	
	if self.sharpAimTimer:IsPastSimMS(self.sharpAimDelay) then
		if self.parent and self.parent:IsPlayerControlled() then
			local controller = self.parent:GetController();
			if controller:IsState(Controller.AIM_SHARP) and self.sharpAiming == false then
				self.sharpAiming = true;
				self.sharpAimTimer:Reset();
				self.sharpAimSound = AudioMan:PlaySound(self.sharpAimSounds.In.Path .. math.random(1, self.sharpAimSounds.In.Variations) .. ".ogg", self.Pos, -1, 0, 130, 1, 250, false);
			elseif (not controller:IsState(Controller.AIM_SHARP)) and self.sharpAiming == true then
				self.sharpAiming = false;
				self.sharpAimTimer:Reset();
				self.sharpAimSound = AudioMan:PlaySound(self.sharpAimSounds.Out.Path .. math.random(1, self.sharpAimSounds.Out.Variations) .. ".ogg", self.Pos, -1, 0, 130, 1, 250, false);
			end
		end		
	end
	
end