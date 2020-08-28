
dofile("Base.rte/Constants.lua")
require("AI/NativeHumanAI")  --dofile("Base.rte/AI/NativeHumanAI.lua")
package.path = package.path .. ";SandstormSecurity.rte/?.lua";
require("Actors/SecurityAIBehaviours")

function Create(self)
	self.AI = NativeHumanAI:Create(self)
	self.RTE = "SandstormSecurity.RTE";
	
	-- Start modded code --
	
	self.Frame = math.random(0, self.FrameCount - 1);
	
	
	-- TERRAIN SOUNDS
	
	self.terrainImpactSounds = {[9] =
	"Sandstorm.rte/Actors/Shared/Sounds/ActorMovement/TerrainDependent/TerrainImpact/Light/Dirt/TerrainImpactDirt",
	[10] =
	"Sandstorm.rte/Actors/Shared/Sounds/ActorMovement/TerrainDependent/TerrainImpact/Light/Dirt/TerrainImpactDirt",
	[11] =
	"Sandstorm.rte/Actors/Shared/Sounds/ActorMovement/TerrainDependent/TerrainImpact/Light/Dirt/TerrainImpactDirt",
	[128] =
	"Sandstorm.rte/Actors/Shared/Sounds/ActorMovement/TerrainDependent/TerrainImpact/Light/Sand/TerrainImpactSand",
	[6] =
	"Sandstorm.rte/Actors/Shared/Sounds/ActorMovement/TerrainDependent/TerrainImpact/Light/Dirt/TerrainImpactDirt",
	[8] =
	"Sandstorm.rte/Actors/Shared/Sounds/ActorMovement/TerrainDependent/TerrainImpact/Light/Dirt/TerrainImpactDirt",
	[12] =	"Sandstorm.rte/Actors/Shared/Sounds/ActorMovement/TerrainDependent/TerrainImpact/Light/Concrete/TerrainImpactConcrete",
	[177] =	"Sandstorm.rte/Actors/Shared/Sounds/ActorMovement/TerrainDependent/TerrainImpact/Light/Concrete/TerrainImpactConcrete",
	[178] =	"Sandstorm.rte/Actors/Shared/Sounds/ActorMovement/TerrainDependent/TerrainImpact/Light/SolidMetal/TerrainImpactSolidMetal",
	[182] =	"Sandstorm.rte/Actors/Shared/Sounds/ActorMovement/TerrainDependent/TerrainImpact/Light/SolidMetal/TerrainImpactSolidMetal"};
	
	self.terrainImpactSoundVariations = {[9] =	5,
	[10] =	5,
	[11] =	5,
	[128] =	5,
	[6] =	5,
	[8] =	5,
	[12] =	5,
	[177] =	5,
	[178] =	5,
	[182] =	5,};
	
	self.terrainLandSounds = {[9] =
	"Sandstorm.rte/Actors/Shared/Sounds/ActorMovement/TerrainDependent/Footsteps/Land/Dirt/LandDirt",
	[10] =
	"Sandstorm.rte/Actors/Shared/Sounds/ActorMovement/TerrainDependent/Footsteps/Land/Dirt/LandDirt",
	[11] =
	"Sandstorm.rte/Actors/Shared/Sounds/ActorMovement/TerrainDependent/Footsteps/Land/Dirt/LandDirt",
	[128] =
	"Sandstorm.rte/Actors/Shared/Sounds/ActorMovement/TerrainDependent/Footsteps/Land/Sand/LandSand",
	[6] =
	"Sandstorm.rte/Actors/Shared/Sounds/ActorMovement/TerrainDependent/Footsteps/Land/Dirt/LandDirt",
	[8] =
	"Sandstorm.rte/Actors/Shared/Sounds/ActorMovement/TerrainDependent/Footsteps/Land/Dirt/LandDirt",
	[12] =	"Sandstorm.rte/Actors/Shared/Sounds/ActorMovement/TerrainDependent/Footsteps/Land/Concrete/LandConcrete",
	[177] =	"Sandstorm.rte/Actors/Shared/Sounds/ActorMovement/TerrainDependent/Footsteps/Land/Concrete/LandConcrete",
	[178] =	"Sandstorm.rte/Actors/Shared/Sounds/ActorMovement/TerrainDependent/Footsteps/Land/SolidMetal/LandSolidMetal",
	[182] =	"Sandstorm.rte/Actors/Shared/Sounds/ActorMovement/TerrainDependent/Footsteps/Land/SolidMetal/LandSolidMetal"};
	
	self.terrainLandSoundVariations = {[9] =	5,
	[10] =	5,
	[11] =	5,
	[128] =	5,
	[6] =	5,
	[8] =	5,
	[12] =	5,
	[177] =	5,
	[178] =	5,
	[182] =	5,};
	
	self.terrainJumpSounds = {[9] =
	"Sandstorm.rte/Actors/Shared/Sounds/ActorMovement/TerrainDependent/Footsteps/Jump/Dirt/JumpDirt",
	[10] =
	"Sandstorm.rte/Actors/Shared/Sounds/ActorMovement/TerrainDependent/Footsteps/Jump/Dirt/JumpDirt",
	[11] =
	"Sandstorm.rte/Actors/Shared/Sounds/ActorMovement/TerrainDependent/Footsteps/Jump/Dirt/JumpDirt",
	[128] =
	"Sandstorm.rte/Actors/Shared/Sounds/ActorMovement/TerrainDependent/Footsteps/Jump/Sand/JumpSand",
	[6] =
	"Sandstorm.rte/Actors/Shared/Sounds/ActorMovement/TerrainDependent/Footsteps/Jump/Dirt/JumpDirt",
	[8] =
	"Sandstorm.rte/Actors/Shared/Sounds/ActorMovement/TerrainDependent/Footsteps/Jump/Dirt/JumpDirt",
	[12] =	"Sandstorm.rte/Actors/Shared/Sounds/ActorMovement/TerrainDependent/Footsteps/Jump/Concrete/JumpConcrete",
	[177] =	"Sandstorm.rte/Actors/Shared/Sounds/ActorMovement/TerrainDependent/Footsteps/Jump/Concrete/JumpConcrete",
	[178] =	"Sandstorm.rte/Actors/Shared/Sounds/ActorMovement/TerrainDependent/Footsteps/Jump/SolidMetal/JumpSolidMetal",
	[182] =	"Sandstorm.rte/Actors/Shared/Sounds/ActorMovement/TerrainDependent/Footsteps/Jump/SolidMetal/JumpSolidMetal"};
	
	self.terrainJumpSoundVariations = {[9] =	5,
	[10] =	5,
	[11] =	5,
	[128] =	5,
	[6] =	5,
	[8] =	5,
	[12] =	5,
	[177] =	5,
	[178] =	5,
	[182] =	5,};
	
	self.terrainProneSounds = {[9] =
	"Sandstorm.rte/Actors/Shared/Sounds/ActorMovement/TerrainDependent/Prone/Dirt/ProneDirt",
	[10] =
	"Sandstorm.rte/Actors/Shared/Sounds/ActorMovement/TerrainDependent/Prone/Dirt/ProneDirt",
	[11] =
	"Sandstorm.rte/Actors/Shared/Sounds/ActorMovement/TerrainDependent/Prone/Dirt/ProneDirt",
	[128] =
	"Sandstorm.rte/Actors/Shared/Sounds/ActorMovement/TerrainDependent/Prone/Sand/ProneSand",
	[6] =
	"Sandstorm.rte/Actors/Shared/Sounds/ActorMovement/TerrainDependent/Prone/Dirt/ProneDirt",
	[8] =
	"Sandstorm.rte/Actors/Shared/Sounds/ActorMovement/TerrainDependent/Prone/Dirt/ProneDirt",
	[12] =
	"Sandstorm.rte/Actors/Shared/Sounds/ActorMovement/TerrainDependent/Prone/Concrete/ProneConcrete",
	[177] =
	"Sandstorm.rte/Actors/Shared/Sounds/ActorMovement/TerrainDependent/Prone/Concrete/ProneConcrete",
	[178] =
	"Sandstorm.rte/Actors/Shared/Sounds/ActorMovement/TerrainDependent/Prone/SolidMetal/ProneSolidMetal",
	[182] =
	"Sandstorm.rte/Actors/Shared/Sounds/ActorMovement/TerrainDependent/Prone/SolidMetal/ProneSolidMetal"};
	
	self.terrainProneSoundVariations = {[9] =	4,
	[10] =	4,
	[11] =	4,
	[128] =	4,
	[6] =	4,
	[8] =	4,
	[12] =	4,
	[177] =	4,
	[178] =	4,
	[182] =	4,};
	
	self.terrainCrawlSounds = {[9] =
	"Sandstorm.rte/Actors/Shared/Sounds/ActorMovement/TerrainDependent/Crawl/Dirt/CrawlDirt",
	[10] =
	"Sandstorm.rte/Actors/Shared/Sounds/ActorMovement/TerrainDependent/Crawl/Dirt/CrawlDirt",
	[11] =
	"Sandstorm.rte/Actors/Shared/Sounds/ActorMovement/TerrainDependent/Crawl/Dirt/CrawlDirt",
	[128] =
	"Sandstorm.rte/Actors/Shared/Sounds/ActorMovement/TerrainDependent/Crawl/Sand/CrawlSand",
	[6] =
	"Sandstorm.rte/Actors/Shared/Sounds/ActorMovement/TerrainDependent/Crawl/Dirt/CrawlDirt",
	[8] =
	"Sandstorm.rte/Actors/Shared/Sounds/ActorMovement/TerrainDependent/Crawl/Dirt/CrawlDirt",
	[12] =
	"Sandstorm.rte/Actors/Shared/Sounds/ActorMovement/TerrainDependent/Crawl/Concrete/CrawlConcrete",
	[177] =
	"Sandstorm.rte/Actors/Shared/Sounds/ActorMovement/TerrainDependent/Crawl/Concrete/CrawlConcrete",
	[178] =
	"Sandstorm.rte/Actors/Shared/Sounds/ActorMovement/TerrainDependent/Crawl/SolidMetal/CrawlSolidMetal",
	[182] =
	"Sandstorm.rte/Actors/Shared/Sounds/ActorMovement/TerrainDependent/Crawl/SolidMetal/CrawlSolidMetal"};
	
	self.terrainCrawlSoundVariations = {[9] =	5,
	[10] =	5,
	[11] =	5,
	[128] =	5,
	[6] =	5,
	[8] =	5,
	[12] =	5,
	[177] =	5,
	[178] =	5,
	[182] =	5,};
	
	
	self.movementSounds = {Land = "Sandstorm.rte/Actors/Shared/Sounds/ActorMovement/Gear/Light/Land/Land",
	Jump = "Sandstorm.rte/Actors/Shared/Sounds/ActorMovement/Gear/Light/Jump/Jump",
	Crawl = "Sandstorm.rte/Actors/Shared/Sounds/ActorMovement/Gear/Light/Crawl/Crawl",
	Sprint = "Sandstorm.rte/Actors/Shared/Sounds/ActorMovement/Gear/Light/Prone/Prone",
	Crouch = "Sandstorm.rte/Actors/Shared/Sounds/ActorMovement/Gear/Light/Crouch/Crouch",
	Stand = "Sandstorm.rte/Actors/Shared/Sounds/ActorMovement/Gear/Light/Stand/Stand",
	Fall = "Sandstorm.rte/Actors/Shared/Sounds/ActorMovement/Gear/Light/Fall/Fall",
	walkPre = "Sandstorm.rte/Actors/Shared/Sounds/ActorMovement/Gear/Light/Walk/Pre",
	walkPost = "Sandstorm.rte/Actors/Shared/Sounds/ActorMovement/Gear/Light/Walk/Post",
	sprintPre = "Sandstorm.rte/Actors/Shared/Sounds/ActorMovement/Gear/Light/Sprint/Pre",
	sprintPost = "Sandstorm.rte/Actors/Shared/Sounds/ActorMovement/Gear/Light/Sprint/Post",
	Impact = 0,};
	
	self.movementSoundVariations = {Land = 5,
	Jump = 5,
	Impact = 5,
	Crawl = 5,
	Sprint = 5,
	Prone = 5,
	Stand = 5,
	Fall = 5,
	walkPre = 5,
	walkPost = 5,
	sprintPre = 5,
	sprintPost = 5};
	
	self.miscSounds = {Impact = "Sandstorm.rte/Actors/Shared/Sounds/ActorDamage/TerrainImpact/BoneBreak"};
	
	self.miscSoundVariations = {Impact = 5,};
	
	-- head and gender and voice management
	
	-- frame 0 idle
	-- frame 1 idle eyes closed
	-- frame 2 angry
	-- frame 3 angry mouth open
	-- frame 4 scared
	
	-- unfortunately hardcoded to our 3 options here with 15 heads total but this may change
	-- TODO unhardcode
	
	local headFrames = 5;
	
	self.Gender = (2 and math.random(1, 100) < 20) or 1;
	
	if self.Gender == 1 then -- Male
		if math.random(1, 2) == 1 then		-- american
		
			self.baseHeadFrame = headFrames * math.random(0, 5);
			if self.Head then
				self.Head.Frame = self.baseHeadFrame;
			end
		
			self.voiceSounds = {Death = 
			"SandstormSecurity.rte/Actors/Shared/Sounds/VO/SecAmericanMale/Death/Death",
			seriousDeath = 
			"SandstormSecurity.rte/Actors/Shared/Sounds/VO/SecAmericanMale/Death/SeriousDeath",
			Incapacitated =
			"SandstormSecurity.rte/Actors/Shared/Sounds/VO/SecAmericanMale/Death/Incapacitated",
			Suppressed =
			"SandstormSecurity.rte/Actors/Shared/Sounds/VO/SecAmericanMale/Suppression/SuppressedByGunfire",
			witnessDeath = 
			"SandstormSecurity.rte/Actors/Shared/Sounds/VO/SecAmericanMale/DeathReactions/FriendlyDown",
			witnessGruesomeDeath = 
			"SandstormSecurity.rte/Actors/Shared/Sounds/VO/SecAmericanMale/DeathReactions/FriendlyGibbed",
			inhaleLight =
			"SandstormSecurity.rte/Actors/Shared/Sounds/VO/SecAmericanMale/Exertion/InhaleLight",
			inhaleMedium =
			"SandstormSecurity.rte/Actors/Shared/Sounds/VO/SecAmericanMale/Exertion/InhaleMedium",
			inhaleHeavy =
			"SandstormSecurity.rte/Actors/Shared/Sounds/VO/SecAmericanMale/Exertion/InhaleHeavy",
			exhaleLight =
			"SandstormSecurity.rte/Actors/Shared/Sounds/VO/SecAmericanMale/Exertion/ExhaleLight",
			exhaleMedium =
			"SandstormSecurity.rte/Actors/Shared/Sounds/VO/SecAmericanMale/Exertion/ExhaleMedium",
			exhaleHeavy =
			"SandstormSecurity.rte/Actors/Shared/Sounds/VO/SecAmericanMale/Exertion/ExhaleHeavy",
			Exertion = 
			"SandstormSecurity.rte/Actors/Shared/Sounds/VO/SecAmericanMale/Exertion/Exertion",
			seriousExertion =
			"SandstormSecurity.rte/Actors/Shared/Sounds/VO/SecAmericanMale/Exertion/SeriousExertion",
			Pain =
			"SandstormSecurity.rte/Actors/Shared/Sounds/VO/SecAmericanMale/Pain/Pain",
			Reload =
			"SandstormSecurity.rte/Actors/Shared/Sounds/VO/SecAmericanMale/Reload/Reload",
			suppressedReload =
			"SandstormSecurity.rte/Actors/Shared/Sounds/VO/SecAmericanMale/Reload/SuppressedReload",
			flashOut =
			"SandstormSecurity.rte/Actors/Shared/Sounds/VO/SecAmericanMale/Throw/FlashOut",		
			suppressedFlashOut =
			"SandstormSecurity.rte/Actors/Shared/Sounds/VO/SecAmericanMale/Throw/SuppressedFlashOut",	
			fragOut =
			"SandstormSecurity.rte/Actors/Shared/Sounds/VO/SecAmericanMale/Throw/FragOut",		
			suppressedFragOut =
			"SandstormSecurity.rte/Actors/Shared/Sounds/VO/SecAmericanMale/Throw/SuppressedFragOut",	
			incendiaryOut =
			"SandstormSecurity.rte/Actors/Shared/Sounds/VO/SecAmericanMale/Throw/IncendiaryOut",		
			suppressedIncendiaryOut =
			"SandstormSecurity.rte/Actors/Shared/Sounds/VO/SecAmericanMale/Throw/SuppressedIncendiaryOut",	
			mineOut =
			"SandstormSecurity.rte/Actors/Shared/Sounds/VO/SecAmericanMale/Throw/MineOut",		
			suppressedMineOut =
			"SandstormSecurity.rte/Actors/Shared/Sounds/VO/SecAmericanMale/Throw/SuppressedMineOut",	
			molotovOut =
			"SandstormSecurity.rte/Actors/Shared/Sounds/VO/SecAmericanMale/Throw/MolotovOut",		
			suppressedMolotovOut =
			"SandstormSecurity.rte/Actors/Shared/Sounds/VO/SecAmericanMale/Throw/SuppressedMolotovOut",	
			remoteOut =
			"SandstormSecurity.rte/Actors/Shared/Sounds/VO/SecAmericanMale/Throw/RemoteOut",		
			suppressedRemoteOut =
			"SandstormSecurity.rte/Actors/Shared/Sounds/VO/SecAmericanMale/Throw/SuppressedRemoteOut",	
			smokeOut =
			"SandstormSecurity.rte/Actors/Shared/Sounds/VO/SecAmericanMale/Throw/SmokeOut",		
			suppressedSmokeOut =
			"SandstormSecurity.rte/Actors/Shared/Sounds/VO/SecAmericanMale/Throw/SuppressedSmokeOut"};			
			
			self.voiceSoundVariations = {Death = 19,
			seriousDeath = 15,
			Incapacitated = 11,
			Suppressed = 37,
			witnessDeath = 8,
			witnessGruesomeDeath = 5,
			inhaleLight = 8,
			inhaleMedium = 10,
			inhaleHeavy = 8,
			exhaleLight = 8,
			exhaleMedium = 10,
			exhaleHeavy = 8,
			Exertion = 7,
			seriousExertion = 7,
			Pain = 17,
			Reload = 29,
			suppressedReload = 35,
			flashOut = 8,
			suppressedFlashOut = 8,
			fragOut = 8,		
			suppressedFragOut = 8,	
			incendiaryOut = 5,		
			suppressedIncendiaryOut = 5,	
			mineOut = 5,		
			suppressedMineOut = 5,	
			molotovOut = 5,		
			suppressedMolotovOut = 5,	
			remoteOut = 5,		
			suppressedRemoteOut = 5,	
			smokeOut = 8,		
			suppressedSmokeOut = 8};				
		else
		
			self.baseHeadFrame = headFrames * math.random(6, 10);
			if self.Head then
				self.Head.Frame = self.baseHeadFrame;
			end
			
			self.voiceSounds = {Death = 
			"SandstormSecurity.rte/Actors/Shared/Sounds/VO/SecArabMale/Death/Death",
			seriousDeath = 
			"SandstormSecurity.rte/Actors/Shared/Sounds/VO/SecArabMale/Death/SeriousDeath",
			Incapacitated =
			"SandstormSecurity.rte/Actors/Shared/Sounds/VO/SecArabMale/Death/Incapacitated",
			Suppressed =
			"SandstormSecurity.rte/Actors/Shared/Sounds/VO/SecArabMale/Suppression/SuppressedByGunfire",
			witnessDeath = 
			"SandstormSecurity.rte/Actors/Shared/Sounds/VO/SecArabMale/DeathReactions/FriendlyDown",
			witnessGruesomeDeath = 
			"SandstormSecurity.rte/Actors/Shared/Sounds/VO/SecArabMale/DeathReactions/FriendlyGibbed",
			inhaleLight =
			"SandstormSecurity.rte/Actors/Shared/Sounds/VO/SecArabMale/Exertion/InhaleLight",
			inhaleMedium =
			"SandstormSecurity.rte/Actors/Shared/Sounds/VO/SecArabMale/Exertion/InhaleMedium",
			inhaleHeavy =
			"SandstormSecurity.rte/Actors/Shared/Sounds/VO/SecArabMale/Exertion/InhaleHeavy",
			exhaleLight =
			"SandstormSecurity.rte/Actors/Shared/Sounds/VO/SecArabMale/Exertion/ExhaleLight",
			exhaleMedium =
			"SandstormSecurity.rte/Actors/Shared/Sounds/VO/SecArabMale/Exertion/ExhaleMedium",
			exhaleHeavy =
			"SandstormSecurity.rte/Actors/Shared/Sounds/VO/SecArabMale/Exertion/ExhaleHeavy",
			Exertion = 
			"SandstormSecurity.rte/Actors/Shared/Sounds/VO/SecArabMale/Exertion/Exertion",
			seriousExertion =
			"SandstormSecurity.rte/Actors/Shared/Sounds/VO/SecArabMale/Exertion/SeriousExertion",
			Pain =
			"SandstormSecurity.rte/Actors/Shared/Sounds/VO/SecArabMale/Pain/Pain",
			Reload =
			"SandstormSecurity.rte/Actors/Shared/Sounds/VO/SecArabMale/Reload/Reload",
			suppressedReload =
			"SandstormSecurity.rte/Actors/Shared/Sounds/VO/SecArabMale/Reload/SuppressedReload",
			flashOut =
			"SandstormSecurity.rte/Actors/Shared/Sounds/VO/SecArabMale/Throw/FlashOut",		
			suppressedFlashOut =
			"SandstormSecurity.rte/Actors/Shared/Sounds/VO/SecArabMale/Throw/SuppressedFlashOut",	
			fragOut =
			"SandstormSecurity.rte/Actors/Shared/Sounds/VO/SecArabMale/Throw/FragOut",		
			suppressedFragOut =
			"SandstormSecurity.rte/Actors/Shared/Sounds/VO/SecArabMale/Throw/SuppressedFragOut",	
			incendiaryOut =
			"SandstormSecurity.rte/Actors/Shared/Sounds/VO/SecArabMale/Throw/IncendiaryOut",		
			suppressedIncendiaryOut =
			"SandstormSecurity.rte/Actors/Shared/Sounds/VO/SecArabMale/Throw/SuppressedIncendiaryOut",	
			mineOut =
			"SandstormSecurity.rte/Actors/Shared/Sounds/VO/SecArabMale/Throw/MineOut",		
			suppressedMineOut =
			"SandstormSecurity.rte/Actors/Shared/Sounds/VO/SecArabMale/Throw/SuppressedMineOut",	
			molotovOut =
			"SandstormSecurity.rte/Actors/Shared/Sounds/VO/SecArabMale/Throw/MolotovOut",		
			suppressedMolotovOut =
			"SandstormSecurity.rte/Actors/Shared/Sounds/VO/SecArabMale/Throw/SuppressedMolotovOut",	
			remoteOut =
			"SandstormSecurity.rte/Actors/Shared/Sounds/VO/SecArabMale/Throw/RemoteOut",		
			suppressedRemoteOut =
			"SandstormSecurity.rte/Actors/Shared/Sounds/VO/SecArabMale/Throw/SuppressedRemoteOut",	
			smokeOut =
			"SandstormSecurity.rte/Actors/Shared/Sounds/VO/SecArabMale/Throw/SmokeOut",		
			suppressedSmokeOut =
			"SandstormSecurity.rte/Actors/Shared/Sounds/VO/SecArabMale/Throw/SuppressedSmokeOut"};
			
			self.voiceSoundVariations = {Death = 20,
			seriousDeath = 18,
			Incapacitated = 13,
			Suppressed = 34,
			witnessDeath = 8,
			witnessGruesomeDeath = 5,
			inhaleLight = 10,
			inhaleMedium = 10,
			inhaleHeavy = 8,
			exhaleLight = 10,
			exhaleMedium = 10,
			exhaleHeavy = 8,
			Exertion = 8,
			seriousExertion = 4,
			Pain = 15,
			Reload = 32,
			suppressedReload = 30,
			flashOut = 8,
			suppressedFlashOut = 8,
			fragOut = 8,		
			suppressedFragOut = 8,	
			incendiaryOut = 5,		
			suppressedIncendiaryOut = 5,	
			mineOut = 5,		
			suppressedMineOut = 5,	
			molotovOut = 5,		
			suppressedMolotovOut = 5,	
			remoteOut = 5,		
			suppressedRemoteOut = 5,	
			smokeOut = 8,		
			suppressedSmokeOut = 8};	
		end
	else	-- Female
	
		self.baseHeadFrame = headFrames * math.random(11, 14);
		if self.Head then
			self.Head.Frame = self.baseHeadFrame;
		end
	
		self.voiceSounds = {Death = 
		"SandstormSecurity.rte/Actors/Shared/Sounds/VO/SecArabFemale/Death/Death",
		seriousDeath = 
		"SandstormSecurity.rte/Actors/Shared/Sounds/VO/SecArabFemale/Death/SeriousDeath",
		Incapacitated =
		"SandstormSecurity.rte/Actors/Shared/Sounds/VO/SecArabFemale/Death/Incapacitated",
		Suppressed =
		"SandstormSecurity.rte/Actors/Shared/Sounds/VO/SecArabFemale/Suppression/SuppressedByGunfire",
		witnessDeath = 
		"SandstormSecurity.rte/Actors/Shared/Sounds/VO/SecArabFemale/DeathReactions/FriendlyDown",
		witnessGruesomeDeath = 
		"SandstormSecurity.rte/Actors/Shared/Sounds/VO/SecArabFemale/DeathReactions/FriendlyGibbed",
		inhaleLight =
		"SandstormSecurity.rte/Actors/Shared/Sounds/VO/SecArabFemale/Exertion/InhaleLight",
		inhaleMedium =
		"SandstormSecurity.rte/Actors/Shared/Sounds/VO/SecArabFemale/Exertion/InhaleMedium",
		inhaleHeavy =
		"SandstormSecurity.rte/Actors/Shared/Sounds/VO/SecArabFemale/Exertion/InhaleHeavy",
		exhaleLight =
		"SandstormSecurity.rte/Actors/Shared/Sounds/VO/SecArabFemale/Exertion/ExhaleLight",
		exhaleMedium =
		"SandstormSecurity.rte/Actors/Shared/Sounds/VO/SecArabFemale/Exertion/ExhaleMedium",
		exhaleHeavy =
		"SandstormSecurity.rte/Actors/Shared/Sounds/VO/SecArabFemale/Exertion/ExhaleHeavy",
		Exertion = 
		"SandstormSecurity.rte/Actors/Shared/Sounds/VO/SecArabFemale/Exertion/Exertion",
		seriousExertion =
		"SandstormSecurity.rte/Actors/Shared/Sounds/VO/SecArabFemale/Exertion/SeriousExertion",
		Pain =
		"SandstormSecurity.rte/Actors/Shared/Sounds/VO/SecArabFemale/Pain/Pain",
		Reload =
		"SandstormSecurity.rte/Actors/Shared/Sounds/VO/SecArabFemale/Reload/Reload",
		suppressedReload =
		"SandstormSecurity.rte/Actors/Shared/Sounds/VO/SecArabFemale/Reload/SuppressedReload",		
		flashOut =
		"SandstormSecurity.rte/Actors/Shared/Sounds/VO/SecArabFemale/Throw/FlashOut",		
		suppressedFlashOut =
		"SandstormSecurity.rte/Actors/Shared/Sounds/VO/SecArabFemale/Throw/SuppressedFlashOut",	
		fragOut =
		"SandstormSecurity.rte/Actors/Shared/Sounds/VO/SecArabFemale/Throw/FragOut",		
		suppressedFragOut =
		"SandstormSecurity.rte/Actors/Shared/Sounds/VO/SecArabFemale/Throw/SuppressedFragOut",	
		incendiaryOut =
		"SandstormSecurity.rte/Actors/Shared/Sounds/VO/SecArabFemale/Throw/IncendiaryOut",		
		suppressedIncendiaryOut =
		"SandstormSecurity.rte/Actors/Shared/Sounds/VO/SecArabFemale/Throw/SuppressedIncendiaryOut",	
		mineOut =
		"SandstormSecurity.rte/Actors/Shared/Sounds/VO/SecArabFemale/Throw/MineOut",		
		suppressedMineOut =
		"SandstormSecurity.rte/Actors/Shared/Sounds/VO/SecArabFemale/Throw/SuppressedMineOut",	
		molotovOut =
		"SandstormSecurity.rte/Actors/Shared/Sounds/VO/SecArabFemale/Throw/MolotovOut",		
		suppressedMolotovOut =
		"SandstormSecurity.rte/Actors/Shared/Sounds/VO/SecArabFemale/Throw/SuppressedMolotovOut",	
		remoteOut =
		"SandstormSecurity.rte/Actors/Shared/Sounds/VO/SecArabFemale/Throw/RemoteOut",		
		suppressedRemoteOut =
		"SandstormSecurity.rte/Actors/Shared/Sounds/VO/SecArabFemale/Throw/SuppressedRemoteOut",	
		smokeOut =
		"SandstormSecurity.rte/Actors/Shared/Sounds/VO/SecArabFemale/Throw/SmokeOut",		
		suppressedSmokeOut =
		"SandstormSecurity.rte/Actors/Shared/Sounds/VO/SecArabFemale/Throw/SuppressedSmokeOut"};
		
		self.voiceSoundVariations = {Death = 20,
		seriousDeath = 15,
		Incapacitated = 12,
		Suppressed = 34,
		witnessDeath = 8,
		witnessGruesomeDeath = 5,
		inhaleLight = 10,
		inhaleMedium = 10,
		inhaleHeavy = 14,
		exhaleLight = 10,
		exhaleMedium = 10,
		exhaleHeavy = 14,
		Exertion = 8,
		seriousExertion = 4,
		Pain = 18,
		Reload = 25,
		suppressedReload = 29,
		flashOut = 8,
		suppressedFlashOut = 8,
		fragOut = 8,		
		suppressedFragOut = 8,	
		incendiaryOut = 5,		
		suppressedIncendiaryOut = 5,	
		mineOut = 5,		
		suppressedMineOut = 5,	
		molotovOut = 5,		
		suppressedMolotovOut = 5,	
		remoteOut = 5,		
		suppressedRemoteOut = 5,	
		smokeOut = 8,		
		suppressedSmokeOut = 8};	
		
	end
	
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
	
	self.staminaUpdateTimer = Timer();
	self.suppressionUpdateTimer = Timer();
	
	self.exertionSoundTimer = Timer();
	
	self.emotionTimer = Timer();
	self.emotionDuration = 0;
	
	self.reloadVoicelineTimer = Timer();
	self.reloadVoicelineDelay = 5000;
	
	self.suppressedVoicelineTimer = Timer();
	self.suppressedVoicelineDelay = 5000;
	
	self.blinkTimer = Timer();
	self.blinkDelay = math.random(5000, 11000);
	
	self.friendlyDownTimer = Timer();
	self.friendlyDownDelay = 5000;
	
	
	-- experimental method for enhanced dying - don't let the actor actually die until we want him to.
	-- reason for this is because when the actor IsDead he will really want to settle and there's not much we can do about it.
	self.allowedToDie = false;
	
	-- Anti Glass cannon script
	-- less gibs, more damage, more realistic deaths
	local woundLimitMultiplier = 1.5
	local woundDamageMultiplier = 1.5
	self.DamageMultiplier = self.DamageMultiplier * woundDamageMultiplier
	self.GibWoundLimit = self.GibWoundLimit * woundLimitMultiplier
    for limb in self.Attachables do
        limb.GibWoundLimit = limb.GibWoundLimit * woundLimitMultiplier
	end
	
	-- fil walk/sprint/jump
	
    -- Leg Collision Detection system
    --self.feet = {nil, nil}
    --self.legs = {nil, nil}
    self.feetContact = {false, false}
    self.feetTimers = {Timer(), Timer()}
	self.footstepTime = 100 -- 2 Timers to avoid noise
	self.sprintFootstepTime = 75
	self.walkFootstepTime = 100
    --[[
    local i = 0
    for limbA in self.Attachables do
        if string.find(limbA.PresetName, "Leg") then
            -- Get Feet
            for limbB in limbA.Attachables do
                i = i + 1
                if string.find(limbB.PresetName, "Foot") then
                    self.feet[i] = limbB
                    self.legs[i] = limbA
                end
            end
        end
    end]]
	
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
	
	self.sprintMultiplier = 1.3 / 0.8
	self.sprintPushForceDenominator = 1.2 / 0.8
	
	self.limbPathDefaultSpeed0 = self:GetLimbPathSpeed(0) * 0.8
	self.limbPathDefaultSpeed1 = self:GetLimbPathSpeed(1) * 0.8
	self.limbPathDefaultSpeed2 = self:GetLimbPathSpeed(2) * 0.8
	self.limbPathDefaultPushForce = self.LimbPathPushForce * 0.8
	
	-- footstep sounds
	
	self.terrainStepSounds = {
	Walk = {
	[9] = "Sandstorm.rte/Actors/Shared/Sounds/ActorMovement/TerrainDependent/Footsteps/Walk/Dirt/WalkDirt",
	[10] = "Sandstorm.rte/Actors/Shared/Sounds/ActorMovement/TerrainDependent/Footsteps/Walk/Dirt/WalkDirt",
	[11] = "Sandstorm.rte/Actors/Shared/Sounds/ActorMovement/TerrainDependent/Footsteps/Walk/Dirt/WalkDirt",
	[128] = "Sandstorm.rte/Actors/Shared/Sounds/ActorMovement/TerrainDependent/Footsteps/Walk/Dirt/WalkDirt",
	[6] = "Sandstorm.rte/Actors/Shared/Sounds/ActorMovement/TerrainDependent/Footsteps/Walk/Sand/WalkSand",
	[8] = "Sandstorm.rte/Actors/Shared/Sounds/ActorMovement/TerrainDependent/Footsteps/Walk/Dirt/WalkDirt",
	[12] = "Sandstorm.rte/Actors/Shared/Sounds/ActorMovement/TerrainDependent/Footsteps/Walk/Concrete/WalkConcrete",
	[177] = "Sandstorm.rte/Actors/Shared/Sounds/ActorMovement/TerrainDependent/Footsteps/Walk/Concrete/WalkConcrete",
	[178] = "Sandstorm.rte/Actors/Shared/Sounds/ActorMovement/TerrainDependent/Footsteps/Walk/SolidMetal/WalkSolidMetal",
	[182] = "Sandstorm.rte/Actors/Shared/Sounds/ActorMovement/TerrainDependent/Footsteps/Walk/SolidMetal/WalkSolidMetal"},
	Sprint = {
	[9] = "Sandstorm.rte/Actors/Shared/Sounds/ActorMovement/TerrainDependent/Footsteps/Sprint/Dirt/SprintDirt",
	[10] = "Sandstorm.rte/Actors/Shared/Sounds/ActorMovement/TerrainDependent/Footsteps/Sprint/Dirt/SprintDirt",
	[11] = "Sandstorm.rte/Actors/Shared/Sounds/ActorMovement/TerrainDependent/Footsteps/Sprint/Dirt/SprintDirt",
	[128] = "Sandstorm.rte/Actors/Shared/Sounds/ActorMovement/TerrainDependent/Footsteps/Sprint/Dirt/SprintDirt",
	[6] = "Sandstorm.rte/Actors/Shared/Sounds/ActorMovement/TerrainDependent/Footsteps/Sprint/Sand/SprintSand",
	[8] = "Sandstorm.rte/Actors/Shared/Sounds/ActorMovement/TerrainDependent/Footsteps/Sprint/Dirt/SprintDirt",
	[12] = "Sandstorm.rte/Actors/Shared/Sounds/ActorMovement/TerrainDependent/Footsteps/Sprint/Concrete/SprintConcrete",
	[177] = "Sandstorm.rte/Actors/Shared/Sounds/ActorMovement/TerrainDependent/Footsteps/Sprint/Concrete/SprintConcrete",
	[178] = "Sandstorm.rte/Actors/Shared/Sounds/ActorMovement/TerrainDependent/Footsteps/Sprint/SolidMetal/SprintSolidMetal",
	[182] = "Sandstorm.rte/Actors/Shared/Sounds/ActorMovement/TerrainDependent/Footsteps/Sprint/SolidMetal/SprintSolidMetal"}	
	};
	
	self.terrainStepSoundVariations = {
	Walk = {
	[9] = 5,
	[10] = 5,
	[11] = 5,
	[128] = 5,
	[6] = 5,
	[8] = 5,
	[12] = 5,
	[177] = 5,
	[178] = 5,
	[182] = 5},
	Sprint = {
	[9] = 5,
	[10] = 5,
	[11] = 5,
	[128] = 5,
	[6] = 5,
	[8] = 5,
	[12] = 5,
	[177] = 5,
	[178] = 5,
	[182] = 5}	
	};
	
	--
	
	-- RANDOM ARMOR
	
	
	if math.random(1, 100) < 50 then
		local torsoAttachable = CreateAttachable("Sandstorm Security Light Vest", "SandstormSecurity.rte");
		self:AddAttachable(torsoAttachable);
	else
		local torsoAttachable = CreateAttachable("Sandstorm Security Light Kevlar", "SandstormSecurity.rte");
		self:AddAttachable(torsoAttachable);
		self.DamageMultiplier = self.DamageMultiplier * 0.9
		self.GibWoundLimit = self.GibWoundLimit + math.random(1,2)
	end		


	if self.Head then
		local glasses = math.random(1, 100) < 50;
		local hat = math.random(1, 100) < 50;
		if glasses then
			local headAttachable = CreateAttachable("Sandstorm Security Light Glasses", "SandstormSecurity.rte");
			self.Head:AddAttachable(headAttachable);
		end
		if hat then
			local headAttachable = CreateAttachable("Sandstorm Security Light Hat", "SandstormSecurity.rte");
			self.Head:AddAttachable(headAttachable);
		end
	end
	
	
	-- End modded code
end

-- Start modded code --

-- End modded code --

function OnCollideWithTerrain(self, terrainID)
	-- let Fall sounds know to play this
	self.terrainCollided = true;
	self.terrainCollidedWith = terrainID;
	

end

-- Start modded code--

function Update(self)

	
	if (UInputMan:KeyPressed(26)) and self:IsPlayerControlled() then
		self.Health = self.Health -26
	end
	
	if UInputMan:KeyPressed(3) and self:IsPlayerControlled() then
		self.Health = self.Health -51
	end
	
	if (UInputMan:KeyPressed(24)) and self:IsPlayerControlled() then
		self.Health = self.Health -6
	end
	
	-- Debug
	local barValue = self.Stamina
	local barValueMax = 100
	local barOffset = Vector(0, 15)
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
	barOffset = Vector(0, 18)
	for i = 0, 1 do
		-- Bar Background
		PrimitiveMan:DrawLinePrimitive(self.Pos + barOffset + Vector(-barLength, i), self.Pos + barOffset + Vector(barLength, i), 26);
		-- Bar Foreground
		local fac = math.max(math.min(barValue / barValueMax, 1), 0)
		PrimitiveMan:DrawLinePrimitive(self.Pos + barOffset + Vector(-barLength, i), self.Pos + barOffset + Vector(-barLength + (barLength * 2 * fac), i), 244);
	end
	
	if self.voiceSound then
		if self.voiceSound:IsBeingPlayed() then
			self.voiceSound:SetPosition(self.Pos);
		end
	end
	
	if (self.Dying ~= true) then
		
		SecurityAIBehaviours.handleLiveAirAndFalling(self);
		
		SecurityAIBehaviours.handleMovement(self);
		
		SecurityAIBehaviours.handleHealth(self);
		
		SecurityAIBehaviours.handleStaminaAndSuppression(self);
		
		SecurityAIBehaviours.handleVoicelines(self);
		
		SecurityAIBehaviours.handleHeadFrames(self);

	else
	
		SecurityAIBehaviours.handleMovement(self);
	
		SecurityAIBehaviours.handleHeadLoss(self);
		
		SecurityAIBehaviours.handleDeadAirAndFalling(self);
		
		SecurityAIBehaviours.handleDying(self);

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
	
		if self.ToSettle then
		else -- we have been gibbed
			if (self.voiceSound) then
				if (self.voiceSound:IsBeingPlayed()) then
					self.voiceSound:Stop(-1);
					self.voiceSound = nil;
				end
			end
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
			end
		end
		if self.headGibSound then
			if self.headGibSound:IsBeingPlayed() then
				self.headGibSound:Stop(-1)
			end
		end
		
	end
	
	-- End modded code --
	
end
