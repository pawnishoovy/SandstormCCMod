
function Create(self)
	local dir = "Sandstorm.rte/Devices/Weapons/Shared/Sounds/Explosion"
	
	self.addSounds = {["Outdoors"] = nil,
	["Indoors"] = nil,
	["bigIndoors"] = nil};		
	self.addSounds.Outdoors = {["Variations"] = 5,
	["Path"] = dir.."/Specialty/Rocket/Add"};
	self.addSounds.Indoors = {["Variations"] = 10,
	["Path"] = dir.."/Add/Indoors/AddIndoorsSmall"};
	self.addSounds.bigIndoors = {["Variations"] = 10,
	["Path"] = dir.."/Add/Indoors/AddIndoorsSmall"};
	
	self.ambienceSounds = {["Variations"] = 7,
	["Path"] = dir.."/Ambience/AmbienceMedium"};
	
	self.reflectionSounds = {["Outdoors"] = nil,
	["Indoors"] = nil,
	["bigIndoors"] = nil};
	self.reflectionSounds.Outdoors = {["Variations"] = 3,
	["Path"] = dir.."/Specialty/Rocket/ReflectionOutdoors"};
	self.reflectionSounds.Indoors = {["Variations"] = 5,
	["Path"] = dir.."/Reflection/Indoors/ReflectionIndoorsMedium"};
	self.reflectionSounds.bigIndoors = {["Variations"] = 5,
	["Path"] = dir.."/Reflection/BigIndoors/ReflectionBigIndoorsMedium"};
	
	self.debrisSounds = {["Indoors"] = nil,
	["bigIndoors"] = nil};
	self.debrisSounds.Indoors = {["Variations"] = 5,
	["Path"] = dir.."/Debris/Indoors/DebrisIndoorsMedium"};
	self.debrisSounds.bigIndoors = {["Variations"] = 5,
	["Path"] = dir.."/Debris/BigIndoors/DebrisBigIndoorsMedium"};
	
	local outdoorRays = 0;
	
	local indoorRays = 0;
	
	local bigIndoorRays = 0;

	local Vector2 = Vector(0,-700); -- straight up
	local Vector2Left = Vector(0,-700):RadRotate(45*(math.pi/180));
	local Vector2Right = Vector(0,-700):RadRotate(-45*(math.pi/180));			
	local Vector2SlightLeft = Vector(0,-700):RadRotate(22.5*(math.pi/180));
	local Vector2SlightRight = Vector(0,-700):RadRotate(-22.5*(math.pi/180));		
	local Vector3 = Vector(0,0); -- dont need this but is needed as an arg
	local Vector4 = Vector(0,0); -- dont need this but is needed as an arg

	self.ray = SceneMan:CastObstacleRay(self.Pos, Vector2, Vector3, Vector4, self.RootID, self.Team, 128, 7);
	self.rayRight = SceneMan:CastObstacleRay(self.Pos, Vector2Right, Vector3, Vector4, self.RootID, self.Team, 128, 7);
	self.rayLeft = SceneMan:CastObstacleRay(self.Pos, Vector2Left, Vector3, Vector4, self.RootID, self.Team, 128, 7);			
	self.raySlightRight = SceneMan:CastObstacleRay(self.Pos, Vector2SlightRight, Vector3, Vector4, self.RootID, self.Team, 128, 7);
	self.raySlightLeft = SceneMan:CastObstacleRay(self.Pos, Vector2SlightLeft, Vector3, Vector4, self.RootID, self.Team, 128, 7);
	
	self.rayTable = {self.ray, self.rayRight, self.rayLeft, self.raySlightRight, self.raySlightLeft};
	
	for _, rayLength in ipairs(self.rayTable) do
		if rayLength < 0 then
			outdoorRays = outdoorRays + 1;
		elseif rayLength > 170 then
			bigIndoorRays = bigIndoorRays + 1;
		else
			indoorRays = indoorRays + 1;
		end
	end
	
	-- DEBRIS

	if outdoorRays == 0 and indoorRays >= 3 then
		self.debrisSound = AudioMan:PlaySound(self.debrisSounds.Indoors.Path .. math.random(1, self.debrisSounds.Indoors.Variations) .. ".wav", self.Pos, -1, 0, 130, 1, 450, false);
	end
	
	if outdoorRays >= 2 then
		self.addSound = AudioMan:PlaySound(self.addSounds.Outdoors.Path .. math.random(1, self.addSounds.Outdoors.Variations) .. ".wav", self.Pos, -1, 0, 130, 1, 450, false);
		self.ambienceSound = AudioMan:PlaySound(self.ambienceSounds.Path .. math.random(1, self.ambienceSounds.Variations) .. ".wav", self.Pos, -1, 0, 130, 1, 450, false);
		self.reflectionSound = AudioMan:PlaySound(self.reflectionSounds.Outdoors.Path .. math.random(1, self.reflectionSounds.Outdoors.Variations) .. ".wav", self.Pos, -1, 0, 130, 1, 450, false);
	elseif math.max(outdoorRays, bigIndoorRays, indoorRays) == indoorRays then
		self.addSound = AudioMan:PlaySound(self.addSounds.Indoors.Path .. math.random(1, self.addSounds.Indoors.Variations) .. ".wav", self.Pos, -1, 0, 130, 1, 450, false);
		self.reflectionSound = AudioMan:PlaySound(self.reflectionSounds.Indoors.Path .. math.random(1, self.reflectionSounds.Indoors.Variations) .. ".wav", self.Pos, -1, 0, 130, 1, 450, false);
	else -- bigIndoor
		self.addSound = AudioMan:PlaySound(self.addSounds.bigIndoors.Path .. math.random(1, self.addSounds.bigIndoors.Variations) .. ".wav", self.Pos, -1, 0, 130, 1, 450, false);
		self.reflectionSound = AudioMan:PlaySound(self.reflectionSounds.bigIndoors.Path .. math.random(1, self.reflectionSounds.bigIndoors.Variations) .. ".wav", self.Pos, -1, 0, 130, 1, 450, false);
	end
	
	self:GibThis();
end