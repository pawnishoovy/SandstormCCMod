
function Create(self)

	-- Gear Light Armor
	-- less gibs, more damage, more realistic deaths
	local woundLimitMultiplier = 1.5
	local woundDamageMultiplier = 1.25
	self.DamageMultiplier = self.DamageMultiplier * woundDamageMultiplier
	self.GibWoundLimit = self.GibWoundLimit * woundLimitMultiplier
    for limb in self.Attachables do
        limb.GibWoundLimit = limb.GibWoundLimit * woundLimitMultiplier
	end
	
	self.movementSounds = {
	Land = CreateSoundContainer("Gear Light Land", "Sandstorm.rte"),
	Jump = CreateSoundContainer("Gear Light Jump", "Sandstorm.rte"),
	Crouch = CreateSoundContainer("Gear Light Crouch", "Sandstorm.rte"),
	Stand = CreateSoundContainer("Gear Light Stand", "Sandstorm.rte"),
	Step = CreateSoundContainer("Gear Light Walk", "Sandstorm.rte"),
	Prone = CreateSoundContainer("Gear Light Prone", "Sandstorm.rte"),
	Crawl = CreateSoundContainer("Gear Light Crawl", "Sandstorm.rte"),
	Throw = CreateSoundContainer("Gear Light Throw", "Sandstorm.rte"),
	throwStart = CreateSoundContainer("Gear Light ThrowStart", "Sandstorm.rte"),
	Fall = CreateSoundContainer("Gear Light Fall", "Sandstorm.rte")};
	
	self.walkSound = CreateSoundContainer("Gear Light Walk", "Sandstorm.rte")
	self.sprintSound = CreateSoundContainer("Gear Light Sprint", "Sandstorm.rte")
	
	self.StrideSound = CreateSoundContainer("Gear Light Walk", "Sandstorm.rte")
	self.DeviceSwitchSound = CreateSoundContainer("Gear Light DeviceSwitch", "Sandstorm.rte")
	self.BodyHitSound = CreateSoundContainer("Gear Light TerrainImpact", "Sandstorm.rte")
	
	self.sprintMultiplier = 1.625;
	
	-- RANDOM ARMOR AND UNIFORM
	local skin = self:GetNumberValue("SkinTone")
	
	local legsSkin = 0
	local armsSkin = 0
	

	local rn = math.random(0, 2)
	
	self.Frame = rn + 6
	armsSkin = 18 + rn * 2 + skin
	legsSkin = math.random(0,12)
	
	for limb in self.Attachables do
		if string.find(limb.PresetName, "Leg") then
			limb:SetNumberValue("Skin", legsSkin)
		elseif string.find(limb.PresetName, "Arm") then
			limb:SetNumberValue("Skin", armsSkin)
		end
	end
	
	--	self.Frame = math.random(0, self.FrameCount - 1);
	
	if math.random(1, 10) < 5 then
		local torsoAttachable = CreateAttachable("Sandstorm Insurgency Light Vest", "SandstormInsurgency.rte");
		self:AddAttachable(torsoAttachable);
	elseif math.random(1, 10) < 7 then
		local torsoAttachable = CreateAttachable("Sandstorm Insurgency Light Kevlar", "SandstormInsurgency.rte");
		self:AddAttachable(torsoAttachable);
		self.DamageMultiplier = self.DamageMultiplier * 0.9
		self.GibWoundLimit = self.GibWoundLimit + math.random(1,2)
	end	
	
	if self.Head then
		local balaclava = self.baseHeadFrame >= 25
		local beard = self.baseHeadFrame <= 5
		
		local shemagh = math.random(1, 100) < 60 and not beard and not balaclava;
		
		local glasses = math.random(1, 10) < 5;
		local hat = math.random(1, 10) < 5 and not balaclava;
		local headBand = math.random(1, 10) < 5;
		
		local bandana = not balaclava and not shemagh and math.random(1, 10) < 7
		
		if glasses then
			local headAttachable = CreateAttachable("Sandstorm Insurgency Light Glasses", "SandstormInsurgency.rte");
			self.Head:AddAttachable(headAttachable);
		end
		if shemagh then
			local headAttachable = CreateAttachable("Sandstorm Insurgency Light Shemagh", "SandstormInsurgency.rte");
			self.Head:AddAttachable(headAttachable);
		elseif hat then
			local headAttachable = CreateAttachable("Sandstorm Insurgency Light Hat", "SandstormInsurgency.rte");
			self.Head:AddAttachable(headAttachable);
		elseif headBand then
			local headAttachable = CreateAttachable("Sandstorm Insurgency Light Head Band", "SandstormInsurgency.rte");
			self.Head:AddAttachable(headAttachable);
		end
		if bandana then
			local headAttachable = CreateAttachable("Sandstorm Insurgency Light Bandana", "SandstormInsurgency.rte");
			self.Head:AddAttachable(headAttachable);
		end
	end
	
	--[[
	if camo and math.random(1, 10) < 4 then
		local backpack = CreateAttachable("Sandstorm Insurgency Backpack", "SandstormInsurgency.rte")
		self:AddAttachable(backpack);
		backpack.Frame = 0 + ((rn == 1 or rn == 2) and 3 or 0)
	end]]
end
