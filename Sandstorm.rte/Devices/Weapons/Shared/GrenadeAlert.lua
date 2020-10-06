function Create(self)

	-- this multiscript will ONLY work if there is a property named self.Live
	-- denoting when the grenade is live.
	-- self.Live should be true once the nade has been activated AND thrown.
	
	self.grenadeAlertTimer = Timer();
	self.grenadeAlertDelay = 1500; -- initial
	
	self.attemptAlert = true;
	
	self.parentSet = false;
	

end

function Update(self)
	
	if self.Live then
		self:SetNumberValue("No Throw VO", 1);
		if not self:IsAttached() then
			self.parentSet = false;
			self.parent = nil;
			if self.attemptAlert == true and self.grenadeAlertTimer:IsPastSimMS(self.grenadeAlertDelay) then
				self.grenadeAlertDelay = 600;
				self.grenadeAlertTimer:Reset();
				for actor in MovableMan.Actors do
					if actor.Team ~= self.Team then
						local d = SceneMan:ShortestDistance(actor.Pos, self.Pos, true).Magnitude;
						if d < 400 then
							local strength = SceneMan:CastStrengthSumRay(self.Pos, actor.Pos, 0, 128);
							if strength < 500 then
								actor:SetNumberValue("Spotted Grenade", 1)
								self.attemptAlert = false;
								break;  -- first come first serve
							else
								if IsAHuman(actor) and actor.Head then -- if it is a human check for head
									local strength = SceneMan:CastStrengthSumRay(self.Pos, ToAHuman(actor).Head.Pos, 0, 128);	
									if strength < 500 then		
										actor:SetNumberValue("Spotted Grenade", 1)
										self.attemptAlert = false;
										break; -- first come first serve
									end
								end
							end
						end
					end
				end
			end
		else -- someone picked us up while live... how enticing
			if self.parentSet == false then
				local actor = MovableMan:GetMOFromID(self.RootID);
				if actor and IsAHuman(actor) then
					self.parent = ToAHuman(actor);
					self.parentSet = true;
					self.parent:SetNumberValue("Tossback Grenade", 1);
				end
			end
		end
	end
end