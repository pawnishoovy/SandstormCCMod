function Create(self)

	self.parentSet = false;
	
	self.lastAge = self.Age
	
	self.delayedFire = false
	self.delayedFireTimer = Timer();
	self.delayedFireTimeMS = 50
	
	
	self.originalSharpLength = self.SharpLength
	
	self.originalStanceOffset = Vector(math.abs(self.StanceOffset.X), self.StanceOffset.Y)
	self.originalSharpStanceOffset = Vector(self.SharpStanceOffset.X, self.SharpStanceOffset.Y)
	
	self.rotation = 0
	self.rotationTarget = 0
	self.rotationSpeed = 9
	
	self.horizontalAnim = 0
	self.verticalAnim = 0
	
	self.angVel = 0
	self.lastRotAngle = self.RotAngle
	
	self.smokeTimer = Timer();
	self.smokeDelayTimer = Timer();
	self.canSmoke = false
	
	local ms = 1 / (self.RateOfFire / 60) * 1000
	ms = ms + self.delayedFireTimeMS
	self.RateOfFire = 1 / (ms / 1000) * 60
	self.canShoot = true -- Prevent "automatic" bug, force semi-auto
end

function Update(self)
	self.rotationTarget = 0 -- ZERO IT FIRST AAAA!!!!!
	
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
	
	-- Check if switched weapons/hide in the inventory, etc.
	if self.Age > (self.lastAge + TimerMan.DeltaTimeSecs * 2000) then
		if self.delayedFire then
			self.delayedFire = false
			--if self.Magazine then
			--	self.Magazine.RoundCount = self.Magazine.RoundCount + 1
			--end
		end
	end
	self.lastAge = self.Age + 0
	
	-- Smoothing
	local min_value = -math.pi;
	local max_value = math.pi;
	local value = self.RotAngle - self.lastRotAngle
	local result;
	local ret = 0
	
	local range = max_value - min_value;
	if range <= 0 then
		result = min_value;
	else
		ret = (value - min_value) % range;
		if ret < 0 then ret = ret + range end
		result = ret + min_value;
	end
	
	self.lastRotAngle = self.RotAngle
	self.angVel = (result / TimerMan.DeltaTimeSecs) * self.FlipFactor
	
	self.SharpLength = self.originalSharpLength * (0.9 + math.pow(math.min(self.delayedFireTimer.ElapsedSimTimeMS / (self.delayedFireTimeMS * 5), 1), 2.0) * 0.1)
	
	if not self:IsActivated() then
		self.canShoot = true
	end
	
	if not self.canShoot then
		self:Deactivate()
	end
	
	if self.FiredFrame then
		self.delayedFire = true
		self.delayedFireTimer:Reset()
		if self.Magazine then
			self.Magazine.RoundCount = self.Magazine.RoundCount + 1
		end
	end
	
	if self.delayedFire then
		self:Deactivate()
		self.horizontalAnim = self.horizontalAnim + TimerMan.DeltaTimeSecs / self.delayedFireTimeMS * 1000
		if self.delayedFireTimer:IsPastSimMS(self.delayedFireTimeMS) then
			self.angVel = self.angVel + RangeRand(0.7,1.1) * 30
			
			self.canSmoke = true
			self.smokeTimer:Reset()
			
			local muzzleFlash = CreateAttachable("Muzzle Flash Pistol", "Base.rte");
			muzzleFlash.ParentOffset = self.MuzzleOffset
			muzzleFlash.Lifetime = TimerMan.DeltaTimeSecs * 1300
			muzzleFlash.Frame = math.random(0, muzzleFlash.FrameCount - 1);
			self:AddAttachable(muzzleFlash);
			
			-- PAWNIS COMPLISOUND V2 HERE
			self.addSound = AudioMan:PlaySound("SandstormSecurity.rte/Devices/Weapons/Handheld/M1911/Sounds/Fire.wav", self.Pos, -1, 0, 130, 1, 450, false);
			-- PAWNIS COMPLISOUND V2 HERE
			
			local bullet = CreateMOSRotating("Bullet M1911");
			bullet.Pos = self.Pos + Vector(self.MuzzleOffset.X * self.FlipFactor, self.MuzzleOffset.Y):RadRotate(self.RotAngle + RangeRand(-0.05,0.05));
			bullet.Vel = self.Vel + Vector(1 * self.FlipFactor,0):RadRotate(self.RotAngle) * 180; -- BULLET SPEED
			bullet.RotAngle = self.RotAngle + (math.pi * (-self.FlipFactor + 1) / 2)
			bullet:SetNumberValue("WoundDamageMultiplier", 2.0)
			bullet:SetNumberValue("AlwaysTracer", math.random(0,1))
			bullet:SetNumberValue("NoSmoke", 1)
			
			local casing
			casing = CreateMOSParticle("Casing");
			casing.Pos = self.Pos+Vector(0,-3):RadRotate(self.RotAngle);
			casing.Vel = self.Vel+Vector(-math.random(2,4)*self.FlipFactor,-math.random(3,4)):RadRotate(self.RotAngle);
			MovableMan:AddParticle(casing);
			
			if self.parent then
				bullet.Team = actor.Team;
				bullet.IgnoresTeamHits = true;
			end
			MovableMan:AddParticle(bullet);
			
			self.delayedFire = false
			
			if self.Magazine then
				self.Magazine.RoundCount = self.Magazine.RoundCount - 1
			end
			self.canShoot = false
		end
	end
	
	-- PAWNIS RELOAD ANIMATION HERE
	if self:IsReloading() then
		
	else
		-- SLIDE animation when firing
		-- don't ask, math magic
		local f = math.max(1 - math.min((self.delayedFireTimer.ElapsedSimTimeMS - self.delayedFireTimeMS) / 100, 1), 0)
		self.Frame = self.delayedFire and 0 or math.floor(f * 2 + 0.55)
	end
	-- PAWNIS RELOAD ANIMATION HERE
	
	-- Animation
	if self.parent then
		self.horizontalAnim = math.floor(self.horizontalAnim / (1 + TimerMan.DeltaTimeSecs * 24.0) * 1000) / 1000
		self.verticalAnim = math.floor(self.verticalAnim / (1 + TimerMan.DeltaTimeSecs * 8.0) * 1000) / 1000
		
		local stance = Vector()
		stance = stance + Vector(-5,0) * self.horizontalAnim -- Horizontal animation
		stance = stance + Vector(0,6) * self.verticalAnim -- Vertical animation
		
		self.rotationTarget = self.rotationTarget + (self.angVel * 3)
		self.rotation = (self.rotation + self.rotationTarget * TimerMan.DeltaTimeSecs * self.rotationSpeed) / (1 + TimerMan.DeltaTimeSecs * self.rotationSpeed)
		local total = math.rad(self.rotation) * self.FlipFactor
		
		self.RotAngle = self.RotAngle + total;
		self:SetNumberValue("MagRotation", total);
		
		local jointOffset = Vector(self.JointOffset.X * self.FlipFactor, self.JointOffset.Y):RadRotate(self.RotAngle);
		local offsetTotal = Vector(jointOffset.X, jointOffset.Y):RadRotate(-total) - jointOffset
		self.Pos = self.Pos + offsetTotal;
		self:SetNumberValue("MagOffsetX", offsetTotal.X);
		self:SetNumberValue("MagOffsetY", offsetTotal.Y);
		
		self.StanceOffset = Vector(self.originalStanceOffset.X, self.originalStanceOffset.Y) + stance
		self.SharpStanceOffset = Vector(self.originalSharpStanceOffset.X, self.originalSharpStanceOffset.Y) + stance
	end
	
	if self.canSmoke and not self.smokeTimer:IsPastSimMS(1500) then
		--[[
		local poof = CreateMOPixel("Real Bullet Micro Smoke Ball "..math.random(1,4), "Sandstorm.rte");
		poof.Pos = self.Pos + Vector(self.MuzzleOffset.X * self.FlipFactor, self.MuzzleOffset.Y):RadRotate(self.RotAngle) + Vector(RangeRand(-1,1), RangeRand(-1,1));
		poof.Lifetime = poof.Lifetime * RangeRand(0.2, 1.3) * 0.9;
		poof.Vel = self.Vel * 0.1
		poof.GlobalAccScalar = RangeRand(0.9, 1.0) * -0.4; -- Go up and down
		MovableMan:AddParticle(poof);
		]]
		if self.smokeDelayTimer:IsPastSimMS(120) then
			
			local poof = math.random(1,2) < 2 and CreateMOSParticle("Tiny Smoke Ball 1") or CreateMOPixel("Real Bullet Micro Smoke Ball "..math.random(1,4), "Sandstorm.rte");
			poof.Pos = self.Pos + Vector(self.MuzzleOffset.X * self.FlipFactor, self.MuzzleOffset.Y):RadRotate(self.RotAngle);
			poof.Lifetime = poof.Lifetime * RangeRand(0.3, 1.3) * 0.9;
			poof.Vel = self.Vel * 0.1
			poof.GlobalAccScalar = RangeRand(0.9, 1.0) * -0.4; -- Go up and down
			MovableMan:AddParticle(poof);
			self.smokeDelayTimer:Reset()
			
			--[[
			for i = 0, 2 do
				local poof = i == 0 and CreateMOSParticle("Tiny Smoke Ball 1") or CreateMOPixel("Real Bullet Micro Smoke Ball "..math.random(1,4), "Sandstorm.rte");
				poof.Pos = self.Pos + Vector(self.MuzzleOffset.X * self.FlipFactor, self.MuzzleOffset.Y):RadRotate(self.RotAngle) + Vector(RangeRand(-1,1), RangeRand(-1,1));
				poof.Lifetime = poof.Lifetime * RangeRand(0.7, 1.7) * 0.9;
				--poof.Vel = Vector(RangeRand(-1,1), RangeRand(-1,1)) * 0.5
				poof.GlobalAccScalar = RangeRand(0.9, 1.0) * -0.4; -- Go up and down
				MovableMan:AddParticle(poof);
				self.smokeDelayTimer:Reset()
			end]]
		end
	end
end