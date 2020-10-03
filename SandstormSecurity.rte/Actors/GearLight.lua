
function Create(self)

	self.baseRTE = "Sandstorm.rte";
	
	-- Gear Light Armor
	-- less gibs, more damage, more realistic deaths
	local woundLimitMultiplier = 1.5
	local woundDamageMultiplier = 1.5
	self.DamageMultiplier = self.DamageMultiplier * woundDamageMultiplier
	self.GibWoundLimit = self.GibWoundLimit * woundLimitMultiplier
    for limb in self.Attachables do
        limb.GibWoundLimit = limb.GibWoundLimit * woundLimitMultiplier
	end
	
	self.movementSounds = {
	Land = self.baseRTE.."/Actors/Shared/Sounds/ActorMovement/Gear/Light/Land/Land",
	Jump = self.baseRTE.."/Actors/Shared/Sounds/ActorMovement/Gear/Light/Jump/Jump",
	Crawl = self.baseRTE.."/Actors/Shared/Sounds/ActorMovement/Gear/Light/Crawl/Crawl",
	Sprint = self.baseRTE.."/Actors/Shared/Sounds/ActorMovement/Gear/Light/Prone/Prone",
	Crouch = self.baseRTE.."/Actors/Shared/Sounds/ActorMovement/Gear/Light/Crouch/Crouch",
	Stand = self.baseRTE.."/Actors/Shared/Sounds/ActorMovement/Gear/Light/Stand/Stand",
	Throw = self.baseRTE.."/Actors/Shared/Sounds/ActorMovement/Gear/Light/Throw/Throw",
	throwStart = self.baseRTE.."/Actors/Shared/Sounds/ActorMovement/Gear/Light/ThrowStart/ThrowStart",
	Fall = self.baseRTE.."/Actors/Shared/Sounds/ActorMovement/Gear/Light/Fall/Fall",
	walkPre = self.baseRTE.."/Actors/Shared/Sounds/ActorMovement/Gear/Light/Walk/Pre",
	walkPost = self.baseRTE.."/Actors/Shared/Sounds/ActorMovement/Gear/Light/Walk/Post",
	sprintPre = self.baseRTE.."/Actors/Shared/Sounds/ActorMovement/Gear/Light/Sprint/Pre",
	sprintPost = self.baseRTE.."/Actors/Shared/Sounds/ActorMovement/Gear/Light/Sprint/Post",
	Impact = 0,};
	
	self.movementSoundVariations = {Land = 5,
	Jump = 5,
	Impact = 5,
	Crawl = 5,
	Sprint = 5,
	Crouch = 5,
	Stand = 5,
	Throw = 4,
	throwStart = 4,
	Fall = 5,
	walkPre = 5,
	walkPost = 5,
	sprintPre = 5,
	sprintPost = 5};	
	
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
		backpack.Frame = 0 + ((rn == 1 or rn == 2) and 3 or 0)
	end
end
