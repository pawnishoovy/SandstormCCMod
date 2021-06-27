
dofile("Base.rte/Constants.lua")
require("AI/NativeHumanAI")  --dofile("Base.rte/AI/NativeHumanAI.lua")
package.path = package.path .. ";SandstormSecurity.rte/?.lua";
require("Actors/SecurityAIBehaviours")

function Create(self)
	self.AI = NativeHumanAI:Create(self)
	--You can turn features on and off here
	self.armSway = true;
	self.automaticEquip = true;
	self.alternativeGib = true;
	self.visibleInventory = true;
	
	-- Start modded code --
	
	self.RTE = "SandstormSecurity.rte";
	self.baseRTE = "Sandstorm.rte";
	
	self.miscSounds = {Impact = CreateSoundContainer("ActorsSharedSoundsActorDamageTerrainImpactBoneBreak", "Sandstorm.rte"),
	burnIgnite = CreateSoundContainer("ActorsSharedSoundsActorDamageBurnIgnite", "Sandstorm.rte"),
	burnLoop = CreateSoundContainer("ActorsSharedSoundsActorDamageBurnLoop", "Sandstorm.rte"),
	burnEnd = CreateSoundContainer("ActorsSharedSoundsActorDamageBurnEnd", "Sandstorm.rte")};
	
	-- head and gender and voice management
	
	-- frame 0 idle
	-- frame 1 idle eyes closed
	-- frame 2 angry
	-- frame 3 angry mouth open
	-- frame 4 scared
	
	-- unfortunately hardcoded to our 3 options here with 15 heads total but this may change
	-- TODO unhardcode
	local skin = 0
	
	local headFrames = 5;
	
	self.Gender = (2 and math.random(1, 100) < 20) or 1;
	
	if self.Gender == 1 then -- Male
		if math.random(1, 2) == 1 then		-- american
			skin = 1
			self.baseHeadFrame = headFrames * math.random(0, 5);
			if self.Head then
				self.Head.Frame = self.baseHeadFrame;
			end
		
			self.Identity = "SecAmericanMale";			
				
		else
			skin = 0
			self.baseHeadFrame = headFrames * math.random(6, 10);
			if self.Head then
				self.Head.Frame = self.baseHeadFrame;
			end
			
			self.Identity = "SecArabMale";
			
		end
	else	-- Female
	
		self.baseHeadFrame = headFrames * math.random(11, 14);
		if self.Head then
			self.Head.Frame = self.baseHeadFrame;
		end
		if self.baseHeadFrame == 70 then -- EXCEPTION, LIGHTER SKIN TONE HEAD SKIN
			skin = 1
		else -- REGULAR
			skin = 0
		end
	
		self.Identity = "SecArabFemale";
		
	end
	
	
	self:SetNumberValue("SkinTone", skin)
	
	self.voiceSounds = {Death = 
	CreateSoundContainer("Death " .. self.Identity, "SandstormSecurity.rte"),
	seriousDeath = 
	CreateSoundContainer("SeriousDeath " .. self.Identity, "SandstormSecurity.rte"),
	flameDeath = 
	CreateSoundContainer("FlameDeath " .. self.Identity, "SandstormSecurity.rte"),
	Incapacitated =
	CreateSoundContainer("Incapacitated " .. self.Identity, "SandstormSecurity.rte"),
	Suppressed =
	CreateSoundContainer("SuppressedByGunfire " .. self.Identity, "SandstormSecurity.rte"),
	SuppressedByExplosion =
	CreateSoundContainer("SuppressedByExplosion " .. self.Identity, "SandstormSecurity.rte"),
	Suppressing =
	CreateSoundContainer("Suppressing " .. self.Identity, "SandstormSecurity.rte"),
	witnessDeath = 
	CreateSoundContainer("FriendlyDown " .. self.Identity, "SandstormSecurity.rte"),
	witnessGruesomeDeath = 
	CreateSoundContainer("FriendlyGibbed " .. self.Identity, "SandstormSecurity.rte"),
	lastOneStanding = 
	CreateSoundContainer("LastOneStanding " .. self.Identity, "SandstormSecurity.rte"),
	inhaleLight =
	CreateSoundContainer("InhaleLight " .. self.Identity, "SandstormSecurity.rte"),
	inhaleMedium =
	CreateSoundContainer("InhaleMedium " .. self.Identity, "SandstormSecurity.rte"),
	inhaleHeavy =
	CreateSoundContainer("InhaleHeavy " .. self.Identity, "SandstormSecurity.rte"),
	exhaleLight =
	CreateSoundContainer("ExhaleLight " .. self.Identity, "SandstormSecurity.rte"),
	exhaleMedium =
	CreateSoundContainer("ExhaleMedium " .. self.Identity, "SandstormSecurity.rte"),
	exhaleHeavy =
	CreateSoundContainer("ExhaleHeavy " .. self.Identity, "SandstormSecurity.rte"),
	Exertion = 
	CreateSoundContainer("Exertion " .. self.Identity, "SandstormSecurity.rte"),
	seriousExertion =
	CreateSoundContainer("SeriousExertion " .. self.Identity, "SandstormSecurity.rte"),
	Pain =
	CreateSoundContainer("Pain " .. self.Identity, "SandstormSecurity.rte"),
	burnPain =
	CreateSoundContainer("BurnPain " .. self.Identity, "SandstormSecurity.rte"),
	Flashed =
	CreateSoundContainer("Flashed " .. self.Identity, "SandstormSecurity.rte"),
	friendlyFire =
	CreateSoundContainer("FriendlyFire " .. self.Identity, "SandstormSecurity.rte"),
	Sorry =
	CreateSoundContainer("Sorry " .. self.Identity, "SandstormSecurity.rte"),
	Intimidate =
	CreateSoundContainer("Intimidate " .. self.Identity, "SandstormSecurity.rte"),
	intimidateSuppressed =
	CreateSoundContainer("IntimidateSuppressed " .. self.Identity, "SandstormSecurity.rte"),
	intimidateResponse =
	CreateSoundContainer("IntimidateResponse " .. self.Identity, "SandstormSecurity.rte"),
	intimidateResponseSuppressed =
	CreateSoundContainer("IntimidateResponseSuppressed " .. self.Identity, "SandstormSecurity.rte"),
	Reload =
	CreateSoundContainer("Reload " .. self.Identity, "SandstormSecurity.rte"),
	suppressedReload =
	CreateSoundContainer("SuppressedReload " .. self.Identity, "SandstormSecurity.rte"),
	flashOut =
	CreateSoundContainer("FlashOut " .. self.Identity, "SandstormSecurity.rte"),		
	suppressedFlashOut =
	CreateSoundContainer("SuppressedFlashOut " .. self.Identity, "SandstormSecurity.rte"),	
	fragOut =
	CreateSoundContainer("FragOut " .. self.Identity, "SandstormSecurity.rte"),		
	suppressedFragOut =
	CreateSoundContainer("SuppressedFragOut " .. self.Identity, "SandstormSecurity.rte"),	
	incendiaryOut =
	CreateSoundContainer("IncendiaryOut " .. self.Identity, "SandstormSecurity.rte"),		
	suppressedIncendiaryOut =
	CreateSoundContainer("SuppressedIncendiaryOut " .. self.Identity, "SandstormSecurity.rte"),	
	mineOut =
	CreateSoundContainer("MineOut " .. self.Identity, "SandstormSecurity.rte"),		
	suppressedMineOut =
	CreateSoundContainer("SuppressedMineOut " .. self.Identity, "SandstormSecurity.rte"),	
	molotovOut =
	CreateSoundContainer("MolotovOut " .. self.Identity, "SandstormSecurity.rte"),		
	suppressedMolotovOut =
	CreateSoundContainer("SuppressedMolotovOut " .. self.Identity, "SandstormSecurity.rte"),	
	remoteOut =
	CreateSoundContainer("RemoteOut " .. self.Identity, "SandstormSecurity.rte"),		
	suppressedRemoteOut =
	CreateSoundContainer("SuppressedRemoteOut " .. self.Identity, "SandstormSecurity.rte"),	
	smokeOut =
	CreateSoundContainer("SmokeOut " .. self.Identity, "SandstormSecurity.rte"),		
	suppressedSmokeOut =
	CreateSoundContainer("SuppressedSmokeOut " .. self.Identity, "SandstormSecurity.rte"),
	Tossback = 
	CreateSoundContainer("Tossback " .. self.Identity, "SandstormSecurity.rte"),
	spotGrenade =
	CreateSoundContainer("SpotFrag " .. self.Identity, "SandstormSecurity.rte"),
	spotRemote =
	CreateSoundContainer("SpotRemote " .. self.Identity, "SandstormSecurity.rte"),
	spotRocket =
	CreateSoundContainer("SpotRocket " .. self.Identity, "SandstormSecurity.rte"),
	enemyDown =
	CreateSoundContainer("EnemyDown " .. self.Identity, "SandstormSecurity.rte"),
	enemyDownClose =
	CreateSoundContainer("EnemyDownClose " .. self.Identity, "SandstormSecurity.rte"),
	enemyDownSuppressed =
	CreateSoundContainer("EnemyDownSuppressed " .. self.Identity, "SandstormSecurity.rte"),
	enemyDownCloseSuppressed =
	CreateSoundContainer("EnemyDownCloseSuppressed " .. self.Identity, "SandstormSecurity.rte"),
	spotEnemy =
	CreateSoundContainer("SpotEnemy " .. self.Identity, "SandstormSecurity.rte"),
	spotEnemyFar =
	CreateSoundContainer("SpotEnemyFar " .. self.Identity, "SandstormSecurity.rte"),
	spotEnemyClose =
	CreateSoundContainer("SpotEnemyClose " .. self.Identity, "SandstormSecurity.rte")};
	
	-- MEANINGLESS! purely here so we don't need a check later and can just set its pos all the time
	self.voiceSound = CreateSoundContainer("Crawl Concrete", "Sandstorm.rte");
	
	self.altitude = 0;
	self.wasInAir = false;
	
	self.moveSoundTimer = Timer();
	self.moveSoundWalkTimer = Timer();
	self.wasCrouching = false;
	self.wasMoving = false;
	
	self.Stamina = 100;
	self.Inhale = true;
	self.Suppression = 0;
	self.Suppressed = false;
	
	self.healthUpdateTimer = Timer();
	self.oldHealth = self.Health;
	
	
	self.headWounds = 0;
	
	-- chance upon any non-headshot death to be incapacitated for a while before really dying
	self.incapacitationChance = 10;
	
	self.Burning = false;
	
	self.staminaUpdateTimer = Timer();
	self.suppressionUpdateTimer = Timer();
	
	self.exertionSoundTimer = Timer();
	
	self.emotionTimer = Timer();
	self.emotionDuration = 0;
	
	self.reloadVoicelineTimer = Timer();
	self.reloadVoicelineDelay = 5000;
	
	self.suppressedVoicelineTimer = Timer();
	self.suppressedVoicelineDelay = 5000;
	
	self.gunShotCounter = 0;
	self.suppressingVoicelineTimer = Timer();
	self.suppressingVoicelineDelay = 15000;
	
	self.blinkTimer = Timer();
	self.blinkDelay = math.random(5000, 11000);
	
	self.ragdollTerrainImpactTimer = Timer();
	self.ragdollTerrainImpactDelay = math.random(200, 500);
	
	self.friendlyDownTimer = Timer();
	self.friendlyDownDelay = 5000;
	
	self.spotVoiceLineTimer = Timer();
	self.spotVoiceLineDelay = 15000;
	
	 -- in pixels
	self.spotDistanceClose = 175;
	self.spotDistanceMid = 520;
	--spotDistanceFar -- anything further than distanceMid
	
	 -- in MS
	self.spotDelayMin = 4000;
	self.spotDelayMax = 8000;
	
	 -- in percent
	self.spotIgnoreDelayChance = 10;
	self.spotNoVoicelineChance = 15;
	
	 -- intimidation
	self.intimidateCooldown = 5000;
	self.intimidateCooldownTimer = Timer();
	
	self.intimidateResponseTimer = Timer();
	self.intimidateResponseDelay = math.random(2000, 4000);
	
	self.AIPostCombatIntimidationTimer = Timer();
	self.AIPostCombatIntimidationDelay = math.random(1500, 9000);
	
	-- extremely epic, 2000-tier combat/idle mode system
	self.inCombat = false;
	self.combatExitTimer = Timer();
	self.combatExitDelay = 10000;
	
	 -- burst fire
	self.burstFireDelayTimer = Timer()
	self.burstFireDelayMin = 150
	self.burstFireDelayMax = 300
	self.burstFireDelay = math.random(self.burstFireDelayMin,self.burstFireDelayMax)
	
	-- experimental method for enhanced dying - don't let the actor actually die until we want him to.
	-- reason for this is because when the actor IsDead he will really want to settle and there's not much we can do about it.
	self.allowedToDie = false;
	
	-- fil walk/sprint/jump
	
    -- Leg Collision Detection system
    self.feetContact = {false, false}
    self.feetTimers = {Timer(), Timer()}
	self.footstepTime = 100 -- 2 Timers to avoid noise
	self.sprintFootstepTime = 75
	self.walkFootstepTime = 100
	self.foot = 0;
	
	-- Custom Jumping
	self.isJumping = false
	self.jumpTimer = Timer();
	self.jumpDelay = 500;
	self.jumpStop = Timer();
	self.jumpBoost = Timer();
	
	-- Spring
	self.isSprinting = false
	self.doubleTapTimer = Timer();
	self.doubleTapState = 0

	self.sprintPushForceDenominator = 1.2 / 0.8
	
	self.limbPathDefaultSpeed0 = self:GetLimbPathSpeed(0) * 0.8
	self.limbPathDefaultSpeed1 = self:GetLimbPathSpeed(1) * 0.8
	self.limbPathDefaultSpeed2 = self:GetLimbPathSpeed(2) * 0.8
	self.limbPathDefaultPushForce = self.LimbPathPushForce * 0.8
	
	-- terrain sounds
	
	self.terrainSounds = {
	Crawl = {[12] = CreateSoundContainer("Crawl Concrete", "Sandstorm.rte"),
			[164] = CreateSoundContainer("Crawl Concrete", "Sandstorm.rte"),
			[177] = CreateSoundContainer("Crawl Concrete", "Sandstorm.rte"),
			[9] = CreateSoundContainer("Crawl Dirt", "Sandstorm.rte"),
			[10] = CreateSoundContainer("Crawl Dirt", "Sandstorm.rte"),
			[11] = CreateSoundContainer("Crawl Dirt", "Sandstorm.rte"),
			[128] = CreateSoundContainer("Crawl Dirt", "Sandstorm.rte"),
			[6] = CreateSoundContainer("Crawl Sand", "Sandstorm.rte"),
			[8] = CreateSoundContainer("Crawl Sand", "Sandstorm.rte"),
			[178] = CreateSoundContainer("Crawl SolidMetal", "Sandstorm.rte"),
			[179] = CreateSoundContainer("Crawl SolidMetal", "Sandstorm.rte"),
			[180] = CreateSoundContainer("Crawl SolidMetal", "Sandstorm.rte"),
			[181] = CreateSoundContainer("Crawl SolidMetal", "Sandstorm.rte"),
			[182] = CreateSoundContainer("Crawl SolidMetal", "Sandstorm.rte")},
	Prone = {[12] = CreateSoundContainer("Prone Concrete", "Sandstorm.rte"),
			[164] = CreateSoundContainer("Prone Concrete", "Sandstorm.rte"),
			[177] = CreateSoundContainer("Prone Concrete", "Sandstorm.rte"),
			[9] = CreateSoundContainer("Prone Dirt", "Sandstorm.rte"),
			[10] = CreateSoundContainer("Prone Dirt", "Sandstorm.rte"),
			[11] = CreateSoundContainer("Prone Dirt", "Sandstorm.rte"),
			[128] = CreateSoundContainer("Prone Dirt", "Sandstorm.rte"),
			[6] = CreateSoundContainer("Prone Sand", "Sandstorm.rte"),
			[8] = CreateSoundContainer("Prone Sand", "Sandstorm.rte"),
			[178] = CreateSoundContainer("Prone SolidMetal", "Sandstorm.rte"),
			[179] = CreateSoundContainer("Prone SolidMetal", "Sandstorm.rte"),
			[180] = CreateSoundContainer("Prone SolidMetal", "Sandstorm.rte"),
			[181] = CreateSoundContainer("Prone SolidMetal", "Sandstorm.rte"),
			[182] = CreateSoundContainer("Prone SolidMetal", "Sandstorm.rte")},
	TerrainImpactLight = {[12] = CreateSoundContainer("TerrainImpact Light Concrete", "Sandstorm.rte"),
			[164] = CreateSoundContainer("TerrainImpact Light Concrete", "Sandstorm.rte"),
			[177] = CreateSoundContainer("TerrainImpact Light Concrete", "Sandstorm.rte"),
			[9] = CreateSoundContainer("TerrainImpact Light Dirt", "Sandstorm.rte"),
			[10] = CreateSoundContainer("TerrainImpact Light Dirt", "Sandstorm.rte"),
			[11] = CreateSoundContainer("TerrainImpact Light Dirt", "Sandstorm.rte"),
			[128] = CreateSoundContainer("TerrainImpact Light Dirt", "Sandstorm.rte"),
			[6] = CreateSoundContainer("TerrainImpact Light Sand", "Sandstorm.rte"),
			[8] = CreateSoundContainer("TerrainImpact Light Sand", "Sandstorm.rte"),
			[178] = CreateSoundContainer("TerrainImpact Light SolidMetal", "Sandstorm.rte"),
			[179] = CreateSoundContainer("TerrainImpact Light SolidMetal", "Sandstorm.rte"),
			[180] = CreateSoundContainer("TerrainImpact Light SolidMetal", "Sandstorm.rte"),
			[181] = CreateSoundContainer("TerrainImpact Light SolidMetal", "Sandstorm.rte"),
			[182] = CreateSoundContainer("TerrainImpact Light SolidMetal", "Sandstorm.rte")},
	TerrainImpactHeavy = {[12] = CreateSoundContainer("TerrainImpact Heavy Concrete", "Sandstorm.rte"),
			[164] = CreateSoundContainer("TerrainImpact Heavy Concrete", "Sandstorm.rte"),
			[177] = CreateSoundContainer("TerrainImpact Heavy Concrete", "Sandstorm.rte"),
			[9] = CreateSoundContainer("TerrainImpact Heavy Dirt", "Sandstorm.rte"),
			[10] = CreateSoundContainer("TerrainImpact Heavy Dirt", "Sandstorm.rte"),
			[11] = CreateSoundContainer("TerrainImpact Heavy Dirt", "Sandstorm.rte"),
			[128] = CreateSoundContainer("TerrainImpact Heavy Dirt", "Sandstorm.rte"),
			[6] = CreateSoundContainer("TerrainImpact Heavy Sand", "Sandstorm.rte"),
			[8] = CreateSoundContainer("TerrainImpact Heavy Sand", "Sandstorm.rte"),
			[178] = CreateSoundContainer("TerrainImpact Heavy SolidMetal", "Sandstorm.rte"),
			[179] = CreateSoundContainer("TerrainImpact Heavy SolidMetal", "Sandstorm.rte"),
			[180] = CreateSoundContainer("TerrainImpact Heavy SolidMetal", "Sandstorm.rte"),
			[181] = CreateSoundContainer("TerrainImpact Heavy SolidMetal", "Sandstorm.rte"),
			[182] = CreateSoundContainer("TerrainImpact Heavy SolidMetal", "Sandstorm.rte")},
	FootstepJump = {[12] = CreateSoundContainer("Footstep Jump Concrete", "Sandstorm.rte"),
			[164] = CreateSoundContainer("Footstep Jump Concrete", "Sandstorm.rte"),
			[177] = CreateSoundContainer("Footstep Jump Concrete", "Sandstorm.rte"),
			[9] = CreateSoundContainer("Footstep Jump Dirt", "Sandstorm.rte"),
			[10] = CreateSoundContainer("Footstep Jump Dirt", "Sandstorm.rte"),
			[11] = CreateSoundContainer("Footstep Jump Dirt", "Sandstorm.rte"),
			[128] = CreateSoundContainer("Footstep Jump Dirt", "Sandstorm.rte"),
			[6] = CreateSoundContainer("Footstep Jump Sand", "Sandstorm.rte"),
			[8] = CreateSoundContainer("Footstep Jump Sand", "Sandstorm.rte"),
			[178] = CreateSoundContainer("Footstep Jump SolidMetal", "Sandstorm.rte"),
			[179] = CreateSoundContainer("Footstep Jump SolidMetal", "Sandstorm.rte"),
			[180] = CreateSoundContainer("Footstep Jump SolidMetal", "Sandstorm.rte"),
			[181] = CreateSoundContainer("Footstep Jump SolidMetal", "Sandstorm.rte"),
			[182] = CreateSoundContainer("Footstep Jump SolidMetal", "Sandstorm.rte")},
	FootstepLand = {[12] = CreateSoundContainer("Footstep Land Concrete", "Sandstorm.rte"),
			[164] = CreateSoundContainer("Footstep Land Concrete", "Sandstorm.rte"),
			[177] = CreateSoundContainer("Footstep Land Concrete", "Sandstorm.rte"),
			[9] = CreateSoundContainer("Footstep Land Dirt", "Sandstorm.rte"),
			[10] = CreateSoundContainer("Footstep Land Dirt", "Sandstorm.rte"),
			[11] = CreateSoundContainer("Footstep Land Dirt", "Sandstorm.rte"),
			[128] = CreateSoundContainer("Footstep Land Dirt", "Sandstorm.rte"),
			[6] = CreateSoundContainer("Footstep Land Sand", "Sandstorm.rte"),
			[8] = CreateSoundContainer("Footstep Land Sand", "Sandstorm.rte"),
			[178] = CreateSoundContainer("Footstep Land SolidMetal", "Sandstorm.rte"),
			[179] = CreateSoundContainer("Footstep Land SolidMetal", "Sandstorm.rte"),
			[180] = CreateSoundContainer("Footstep Land SolidMetal", "Sandstorm.rte"),
			[181] = CreateSoundContainer("Footstep Land SolidMetal", "Sandstorm.rte"),
			[182] = CreateSoundContainer("Footstep Land SolidMetal", "Sandstorm.rte")},
	FootstepWalk = {[12] = CreateSoundContainer("Footstep Walk Concrete", "Sandstorm.rte"),
			[164] = CreateSoundContainer("Footstep Walk Concrete", "Sandstorm.rte"),
			[177] = CreateSoundContainer("Footstep Walk Concrete", "Sandstorm.rte"),
			[9] = CreateSoundContainer("Footstep Walk Dirt", "Sandstorm.rte"),
			[10] = CreateSoundContainer("Footstep Walk Dirt", "Sandstorm.rte"),
			[11] = CreateSoundContainer("Footstep Walk Dirt", "Sandstorm.rte"),
			[128] = CreateSoundContainer("Footstep Walk Dirt", "Sandstorm.rte"),
			[6] = CreateSoundContainer("Footstep Walk Sand", "Sandstorm.rte"),
			[8] = CreateSoundContainer("Footstep Walk Sand", "Sandstorm.rte"),
			[178] = CreateSoundContainer("Footstep Walk SolidMetal", "Sandstorm.rte"),
			[179] = CreateSoundContainer("Footstep Walk SolidMetal", "Sandstorm.rte"),
			[180] = CreateSoundContainer("Footstep Walk SolidMetal", "Sandstorm.rte"),
			[181] = CreateSoundContainer("Footstep Walk SolidMetal", "Sandstorm.rte"),
			[182] = CreateSoundContainer("Footstep Walk SolidMetal", "Sandstorm.rte")},
	FootstepSprint = {[12] = CreateSoundContainer("Footstep Sprint Concrete", "Sandstorm.rte"),
			[164] = CreateSoundContainer("Footstep Sprint Concrete", "Sandstorm.rte"),
			[177] = CreateSoundContainer("Footstep Sprint Concrete", "Sandstorm.rte"),
			[9] = CreateSoundContainer("Footstep Sprint Dirt", "Sandstorm.rte"),
			[10] = CreateSoundContainer("Footstep Sprint Dirt", "Sandstorm.rte"),
			[11] = CreateSoundContainer("Footstep Sprint Dirt", "Sandstorm.rte"),
			[128] = CreateSoundContainer("Footstep Sprint Dirt", "Sandstorm.rte"),
			[6] = CreateSoundContainer("Footstep Sprint Sand", "Sandstorm.rte"),
			[8] = CreateSoundContainer("Footstep Sprint Sand", "Sandstorm.rte"),
			[178] = CreateSoundContainer("Footstep Sprint SolidMetal", "Sandstorm.rte"),
			[179] = CreateSoundContainer("Footstep Sprint SolidMetal", "Sandstorm.rte"),
			[180] = CreateSoundContainer("Footstep Sprint SolidMetal", "Sandstorm.rte"),
			[181] = CreateSoundContainer("Footstep Sprint SolidMetal", "Sandstorm.rte"),
			[182] = CreateSoundContainer("Footstep Sprint SolidMetal", "Sandstorm.rte")}
	};
	
	-- End modded code
	
end

-- Start modded code --

function OnStride(self)

	if self.BGFoot and self.FGFoot then
	
		-- if math.random(0, 100) < 30 then
			-- if self.EquippedItem and IsHDFirearm(self.EquippedItem) then
				-- local gun = ToHDFirearm(self.EquippedItem)
				-- if gun:NumberValueExists("Gun Rattle Type") then
					-- if self.gunRattles[gun:GetNumberValue("Gun Rattle Type")] then
						-- self.gunRattles[gun:GetNumberValue("Gun Rattle Type")]:Play(gun.Pos);
					-- end
				-- end
			-- end	
		-- end

		local startPos = self.foot == 0 and self.BGFoot.Pos or self.FGFoot.Pos
		self.foot = (self.foot + 1) % 2
		
		local pos = Vector(0, 0);
		SceneMan:CastObstacleRay(startPos, Vector(0, 9), pos, Vector(0, 0), self.ID, self.Team, 0, 3);				
		local terrPixel = SceneMan:GetTerrMatter(pos.X, pos.Y)
		
		if terrPixel ~= 0 then -- 0 = air
			if self.isSprinting == true then
				if self.terrainSounds.FootstepSprint[terrPixel] ~= nil then
					self.terrainSounds.FootstepSprint[terrPixel]:Play(self.Pos);
				else -- default to concrete
					self.terrainSounds.FootstepSprint[177]:Play(self.Pos);
				end
			else
				if self.terrainSounds.FootstepWalk[terrPixel] ~= nil then
					self.terrainSounds.FootstepWalk[terrPixel]:Play(self.Pos);
				else -- default to concrete
					self.terrainSounds.FootstepWalk[177]:Play(self.Pos);
				end			
			end
		end
		
	elseif self.BGFoot then
	
		-- if math.random(0, 100) < 30 then
			-- if self.EquippedItem and IsHDFirearm(self.EquippedItem) then
				-- local gun = ToHDFirearm(self.EquippedItem)
				-- if gun:NumberValueExists("Gun Rattle Type") then
					-- if self.gunRattles[gun:GetNumberValue("Gun Rattle Type")] then
						-- self.gunRattles[gun:GetNumberValue("Gun Rattle Type")]:Play(gun.Pos);
					-- end
				-- end
			-- end	
		-- end
	
		local startPos = self.BGFoot.Pos
		
		local pos = Vector(0, 0);
		SceneMan:CastObstacleRay(startPos, Vector(0, 9), pos, Vector(0, 0), self.ID, self.Team, 0, 3);				
		local terrPixel = SceneMan:GetTerrMatter(pos.X, pos.Y)
		
		if terrPixel ~= 0 then -- 0 = air
			if self.isSprinting == true then
				if self.terrainSounds.FootstepSprint[terrPixel] ~= nil then
					self.terrainSounds.FootstepSprint[terrPixel]:Play(self.Pos);
				else -- default to concrete
					self.terrainSounds.FootstepSprint[177]:Play(self.Pos);
				end
			else
				if self.terrainSounds.FootstepWalk[terrPixel] ~= nil then
					self.terrainSounds.FootstepWalk[terrPixel]:Play(self.Pos);
				else -- default to concrete
					self.terrainSounds.FootstepWalk[177]:Play(self.Pos);
				end			
			end
		end
		
	elseif self.FGFoot then
	
		-- if math.random(0, 100) < 30 then
			-- if self.EquippedItem and IsHDFirearm(self.EquippedItem) then
				-- local gun = ToHDFirearm(self.EquippedItem)
				-- if gun:NumberValueExists("Gun Rattle Type") then
					-- if self.gunRattles[gun:GetNumberValue("Gun Rattle Type")] then
						-- self.gunRattles[gun:GetNumberValue("Gun Rattle Type")]:Play(gun.Pos);
					-- end
				-- end
			-- end	
		-- end
	
		local startPos = self.FGFoot.Pos
		
		local pos = Vector(0, 0);
		SceneMan:CastObstacleRay(startPos, Vector(0, 9), pos, Vector(0, 0), self.ID, self.Team, 0, 3);				
		local terrPixel = SceneMan:GetTerrMatter(pos.X, pos.Y)
		
		if terrPixel ~= 0 then -- 0 = air
			if self.isSprinting == true then
				if self.terrainSounds.FootstepSprint[terrPixel] ~= nil then
					self.terrainSounds.FootstepSprint[terrPixel]:Play(self.Pos);
				else -- default to concrete
					self.terrainSounds.FootstepSprint[177]:Play(self.Pos);
				end
			else
				if self.terrainSounds.FootstepWalk[terrPixel] ~= nil then
					self.terrainSounds.FootstepWalk[terrPixel]:Play(self.Pos);
				else -- default to concrete
					self.terrainSounds.FootstepWalk[177]:Play(self.Pos);
				end			
			end
		end
		
	end
	
end

function OnCollideWithTerrain(self, terrainID)
	-- let Fall sounds know to play this
	self.terrainCollided = true;
	self.terrainCollidedWith = terrainID;
	--if self.Dying or self.Status == Actor.DEAD or self.Status == Actor.DYING then
	--	SecurityAIBehaviours.handleRagdoll(self)
	--end
end

-- End modded code --

function Update(self)

	self.controller = self:GetController();
	
	if self.alternativeGib then
		HumanFunctions.DoAlternativeGib(self);
	end
	if self.automaticEquip then
		HumanFunctions.DoAutomaticEquip(self);
	end
	if self.armSway then
		HumanFunctions.DoArmSway(self, (self.Health/self.MaxHealth));	--Argument: shove strength
	end
	if self.visibleInventory then
		HumanFunctions.DoVisibleInventory(self, false);	--Argument: whether to show all items
	end
	
	-- Start modded code--
	
	if (UInputMan:KeyPressed(26)) and self:IsPlayerControlled() then
		self.Health = self.Health -26
	end
	
	if UInputMan:KeyPressed(3) and self:IsPlayerControlled() then
		self.Health = self.Health -51
	end
	
	if (UInputMan:KeyPressed(24)) and self:IsPlayerControlled() then
		self.Health = self.Health -6
	end
	
	if self:IsPlayerControlled() then
		-- Debug
		local barValue = self.Stamina
		local barValueMax = 100
		local barOffset = Vector(0, 17)
		local barLength = 10
		-- Stamina
		for i = 0, 1 do
			-- Bar Background
			PrimitiveMan:DrawLinePrimitive(self.Pos + barOffset + Vector(-barLength, i), self.Pos + barOffset + Vector(barLength, i), 26);
			-- Bar Foreground
			local fac = math.max(math.min(barValue / barValueMax, 1), 0)
			PrimitiveMan:DrawLinePrimitive(self.Pos + barOffset + Vector(-barLength, i), self.Pos + barOffset + Vector(-barLength + (barLength * 2 * fac), i), 116);
		end
		-- Suppression
		barValue = self.Suppression
		barOffset = Vector(0, 20)
		for i = 0, 1 do
			-- Bar Background
			PrimitiveMan:DrawLinePrimitive(self.Pos + barOffset + Vector(-barLength, i), self.Pos + barOffset + Vector(barLength, i), 26);
			-- Bar Foreground
			local fac = math.max(math.min(barValue / barValueMax, 1), 0)
			PrimitiveMan:DrawLinePrimitive(self.Pos + barOffset + Vector(-barLength, i), self.Pos + barOffset + Vector(-barLength + (barLength * 2 * fac), i), 244);
		end
	end
	
	self.voiceSound.Pos = self.Pos;
	
	if (self.Dying ~= true) then
		
		SecurityAIBehaviours.handleLiveAirAndFalling(self);
		
		SecurityAIBehaviours.handleMovement(self);
		
		SecurityAIBehaviours.handleHealth(self);
		
		SecurityAIBehaviours.handleStaminaAndSuppression(self);
		
		SecurityAIBehaviours.handleAITargetLogic(self);
		
		SecurityAIBehaviours.handleVoicelines(self);
		
		SecurityAIBehaviours.handleHeadFrames(self);

	else
	
		SecurityAIBehaviours.handleMovement(self);
	
		SecurityAIBehaviours.handleHeadLoss(self);
		
		--SecurityAIBehaviours.handleDeadAirAndFalling(self);
		
		SecurityAIBehaviours.handleDying(self);
		
	end
	
	if self.Status == 1 or self.Dying then
		SecurityAIBehaviours.handleRagdoll(self)
	end
	
	-- clear terrain stuff after we did everything that used em
	
	self.terrainCollided = false;
	self.terrainCollidedWith = nil;
end
-- End modded code --

function UpdateAI(self)
	self.AI:Update(self)

end

function Destroy(self)
	self.AI:Destroy(self)
	
	-- Start modded code --
	
	if ActivityMan:ActivityRunning() then -- for some reason the game crashes if you switch activities (i.e. start a new one) while this actor is active
										  -- presumably it attempts to destroy this, which then tells it to do a buncha stuff and it just goes mad
										  -- this check is to see if the activity is running, since you have to be paused to switch activities. hopefully.
										  -- it is possible Void Wanderers switches activities without pausing. thus this may not work and induce a crash	
	
		if not self.ToSettle then -- we have been gibbed
			

			self.voiceSound:Stop(-1);


			--[[
			for actor in MovableMan.Actors do
				if actor.Team == self.Team then
					local d = SceneMan:ShortestDistance(actor.Pos, self.Pos, true).Magnitude;
					if d < 300 then
						local strength = SceneMan:CastStrengthSumRay(self.Pos, actor.Pos, 0, 128);
						if strength < 500 then
							actor:SetNumberValue("Sandstorm Friendly Down", 1)
							break;  -- first come first serve
						else
							if IsAHuman(actor) and actor.Head then -- if it is a human check for head
								local strength = SceneMan:CastStrengthSumRay(self.Pos, ToAHuman(actor).Head.Pos, 0, 128);	
								if strength < 500 then		
									actor:SetNumberValue("Sandstorm Friendly Down", 1)
									break; -- first come first serve
								end
							end
						end
					end
				end
			end]]
		end
		if self.headGibSound then
			self.headGibSound:Stop(-1)
		end
		
	end
	
	-- End modded code --
	
end
