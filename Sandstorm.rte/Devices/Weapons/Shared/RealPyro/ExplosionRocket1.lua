
function Create(self)
	
	self.addSounds = {["Outdoors"] = nil,
	["Indoors"] = nil,
	["bigIndoors"] = nil};		
	self.addSounds.Outdoors = CreateSoundContainer("Explosion Specialty Rocket Add", "Sandstorm.rte");
	self.addSounds.Indoors = CreateSoundContainer("Explosion Add Indoors Small", "Sandstorm.rte");
	self.addSounds.bigIndoors = CreateSoundContainer("Explosion Add Indoors Small", "Sandstorm.rte");
	
	self.ambienceSounds = CreateSoundContainer("Explosion Ambience Medium", "Sandstorm.rte");
	
	self.reflectionSounds = {["Outdoors"] = nil,
	["Indoors"] = nil,
	["bigIndoors"] = nil};
	self.reflectionSounds.Outdoors = CreateSoundContainer("Explosion Specialty Rocket Reflection Outdoors", "Sandstorm.rte");
	self.reflectionSounds.Indoors = CreateSoundContainer("Explosion Reflection Indoors Medium", "Sandstorm.rte");
	self.reflectionSounds.bigIndoors = CreateSoundContainer("Explosion Reflection Big Indoors Medium", "Sandstorm.rte");
	
	self.debrisSounds = {["Indoors"] = nil,
	["bigIndoors"] = nil};
	self.debrisSounds.Indoors = CreateSoundContainer("Explosion Debris Indoors Medium", "Sandstorm.rte");
	
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
		self.debrisSounds.Indoors:Play(self.Pos);
	end
	
	if outdoorRays >= 2 then
		self.addSounds.Outdoors:Play(self.Pos);
		self.ambienceSounds:Play(self.Pos);
		self.reflectionSounds.Outdoors:Play(self.Pos);
	elseif math.max(outdoorRays, bigIndoorRays, indoorRays) == indoorRays then
		self.addSounds.Indoors:Play(self.Pos);
		self.reflectionSounds.Indoors:Play(self.Pos);
	else -- bigIndoor
		self.addSounds.bigIndoors:Play(self.Pos);
		self.reflectionSounds.bigIndoors:Play(self.Pos);
	end
	
	self:GibThis();
end