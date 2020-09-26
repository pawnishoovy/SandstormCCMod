
function Create(self)
	
	-- Gear Light Armor
	-- less gibs, more damage, more realistic deaths
	local woundLimitMultiplier = 1.5
	local woundDamageMultiplier = 1.5
	self.DamageMultiplier = self.DamageMultiplier * woundDamageMultiplier
	self.GibWoundLimit = self.GibWoundLimit * woundLimitMultiplier
    for limb in self.Attachables do
        limb.GibWoundLimit = limb.GibWoundLimit * woundLimitMultiplier
	end
	
	-- RANDOM ARMOR AND UNIFORM
	local skin = self:GetNumberValue("SkinTone")
	
	local legsSkin = 0
	local armsSkin = 0
	
	local camo = math.random(1,3) >= 2
	if camo then
		local rn = math.random(0, 4)
		self.Frame = rn
		armsSkin = rn * 3 + (math.random(1,3) < 2 and 2 or skin)
		legsSkin = rn
	else
		local rn = math.random(0, 2)
		
		self.Frame = rn + 6
		armsSkin = 18 + rn * 2 + skin
		legsSkin = math.random(0,7)
	end
	
	for limb in self.Attachables do
		if string.find(limb.PresetName, "Leg") then
			limb:SetNumberValue("Skin", legsSkin)
		elseif string.find(limb.PresetName, "Arm") then
			limb:SetNumberValue("Skin", armsSkin)
		end
	end
	
	--	self.Frame = math.random(0, self.FrameCount - 1);
	
	if math.random(1, 100) < 50 then
		local torsoAttachable = CreateAttachable("Sandstorm Security Light Vest", "SandstormSecurity.rte");
		self:AddAttachable(torsoAttachable);
	else
		local torsoAttachable = CreateAttachable("Sandstorm Security Light Kevlar", "SandstormSecurity.rte");
		self:AddAttachable(torsoAttachable);
		self.DamageMultiplier = self.DamageMultiplier * 0.9
		self.GibWoundLimit = self.GibWoundLimit + math.random(1,2)
	end	
	
	local helmet = math.random(1, 100) < 50;

	
	if self.Head then
		local glasses = math.random(1, 100) < 50;
		local hat = math.random(1, 100) < 50;
		local headBand = math.random(1, 100) < 50;
		if glasses then
			local headAttachable = CreateAttachable("Sandstorm Security Light Glasses", "SandstormSecurity.rte");
			self.Head:AddAttachable(headAttachable);
		end
		if helmet then
			local headAttachable = CreateAttachable("Sandstorm Security Light Helmet", "SandstormSecurity.rte");
			if camo then
				headAttachable.Frame = self.Frame
			else
				headAttachable.Frame = math.random(6, 7)
			end
			self.Head:AddAttachable(headAttachable);
		elseif hat then
			local headAttachable = CreateAttachable("Sandstorm Security Light Hat", "SandstormSecurity.rte");
			self.Head:AddAttachable(headAttachable);
		elseif headBand then
			local headAttachable = CreateAttachable("Sandstorm Security Light Head Band", "SandstormSecurity.rte");
			self.Head:AddAttachable(headAttachable);
		end
	end
	
	if camo and math.random(1, 100) < 40 then
		local backpack = CreateAttachable("Sandstorm Security Backpack", "SandstormSecurity.rte")
		self:AddAttachable(backpack);
		backpack.Frame = 2 + ((rn == 1 or rn == 2) and 3 or 0)
	end
end
