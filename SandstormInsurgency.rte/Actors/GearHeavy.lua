
function Create(self)
	
	-- Gear Heavy Armor
	-- less gibs, more damage, more realistic deaths
	local woundLimitMultiplier = 1.5
	local woundDamageMultiplier = 1.25
	self.DamageMultiplier = self.DamageMultiplier * woundDamageMultiplier
	self.GibWoundLimit = self.GibWoundLimit * woundLimitMultiplier
    for limb in self.Attachables do
        limb.GibWoundLimit = limb.GibWoundLimit * woundLimitMultiplier
	end
	
	self.movementSounds = {
	Land = CreateSoundContainer("Gear Heavy Land", "Sandstorm.rte"),
	Jump = CreateSoundContainer("Gear Heavy Jump", "Sandstorm.rte"),
	Crouch = CreateSoundContainer("Gear Heavy Crouch", "Sandstorm.rte"),
	Stand = CreateSoundContainer("Gear Heavy Stand", "Sandstorm.rte"),
	Step = CreateSoundContainer("Gear Heavy Walk", "Sandstorm.rte"),
	Prone = CreateSoundContainer("Gear Heavy Prone", "Sandstorm.rte"),
	Crawl = CreateSoundContainer("Gear Heavy Crawl", "Sandstorm.rte"),
	Throw = CreateSoundContainer("Gear Heavy Throw", "Sandstorm.rte"),
	throwStart = CreateSoundContainer("Gear Heavy ThrowStart", "Sandstorm.rte"),
	Fall = CreateSoundContainer("Gear Heavy Fall", "Sandstorm.rte")};
	
	self.walkSound = CreateSoundContainer("Gear Heavy Walk", "Sandstorm.rte")
	self.sprintSound = CreateSoundContainer("Gear Heavy Sprint", "Sandstorm.rte")	
	
	self.StrideSound = CreateSoundContainer("Gear Heavy Walk", "Sandstorm.rte")
	self.DeviceSwitchSound = CreateSoundContainer("Gear Heavy DeviceSwitch", "Sandstorm.rte")
	self.BodyHitSound = CreateSoundContainer("Gear Heavy TerrainImpact", "Sandstorm.rte")
	
	self.sprintMultiplier = 1.2;
	
	-- RANDOM ARMOR AND UNIFORM
	local skin = self:GetNumberValue("SkinTone")
	
	local legsSkin = 0
	local armsSkin = 0
	
	local rn = math.random(0, 4)
	self.Frame = rn
	armsSkin = rn * 3 + 2
	legsSkin = rn
	
	for limb in self.Attachables do
		if string.find(limb.PresetName, "Leg") then
			limb:SetNumberValue("Skin", legsSkin)
		elseif string.find(limb.PresetName, "Arm") then
			limb:SetNumberValue("Skin", armsSkin)
		end
	end
	
	--	self.Frame = math.random(0, self.FrameCount - 1);
	
	local torsoAttachable = CreateAttachable("Sandstorm Security Heavy Kevlar", "SandstormSecurity.rte");
	self:AddAttachable(torsoAttachable);
	
	for limb in self.Attachables do
		if string.find(limb.PresetName, "Leg") then
			local limbAttachable = CreateAttachable("Sandstorm Security Leg Pad", "SandstormSecurity.rte");
			limb:AddAttachable(limbAttachable);
		end
	end
	
	if self.Head then
		local mask = math.random(1, 10) < 5;
		if mask then
			local headAttachable = CreateAttachable("Sandstorm Security Heavy Helmet Mask", "SandstormSecurity.rte");
			self.Head:AddAttachable(headAttachable);
		end
		
		local glasses = math.random(1, 10) < 7;
		if glasses then
			local headAttachable = CreateAttachable("Sandstorm Security Heavy Helmet Visor", "SandstormSecurity.rte");
			self.Head:AddAttachable(headAttachable);
		end
		local headAttachable = (math.random(1, 10) < 7 and CreateAttachable("Sandstorm Security Heavy Helmet", "SandstormSecurity.rte") or CreateAttachable("Sandstorm Security Light Helmet", "SandstormSecurity.rte"))
		headAttachable.Frame = self.Frame
		self.Head:AddAttachable(headAttachable);
		
		if headAttachable and math.random(1,3) < 2 then
			local helmetAttachable = CreateAttachable("Sandstorm Security Helmet Detail", "SandstormSecurity.rte");
			headAttachable:AddAttachable(helmetAttachable);
		end
	end
	
	local backpack = CreateAttachable("Sandstorm Security Backpack", "SandstormSecurity.rte")
	self:AddAttachable(backpack);
	backpack.Frame = math.random(0,2) + ((rn == 1 or rn == 2) and 3 or 0)