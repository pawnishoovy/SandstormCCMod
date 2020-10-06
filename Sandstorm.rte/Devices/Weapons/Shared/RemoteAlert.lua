function Create(self)

	-- this multiscript will ONLY work if there is a property named self.Live
	-- denoting when the grenade is live.
	-- self.Live should be true once the nade has been activated AND thrown.
	
	-- this particular version is for the remote bombs (IED, M112/C4)
	
	self.remoteAlertTimer = Timer();
	self.remoteAlertDelay = 1000; -- initial
	
	self.attemptAlert = true;

end

function Update(self)
	
	if self.Live then
		if self.attemptAlert == true and self.remoteAlertTimer:IsPastSimMS(self.remoteAlertDelay) then
			self.remoteAlertDelay = 500;
			self.remoteAlertTimer:Reset();
			for actor in MovableMan.Actors do
				if actor.Team ~= self.Team then
					local d = SceneMan:ShortestDistance(actor.Pos, self.Pos, true).Magnitude;
					if d < 400 then
						local strength = SceneMan:CastStrengthSumRay(self.Pos, actor.Pos, 0, 128);
						if strength < 500 then
							actor:SetNumberValue("Spotted Remote", 1)
							self.attemptAlert = false;
							break;  -- first come first serve
						else
							if IsAHuman(actor) and actor.Head then -- if it is a human check for head
								local strength = SceneMan:CastStrengthSumRay(self.Pos, ToAHuman(actor).Head.Pos, 0, 128);	
								if strength < 500 then		
									actor:SetNumberValue("Spotted Remote", 1)
									self.attemptAlert = false;
									break; -- first come first serve
								end
							end
						end
					end
				end
			end
		end
	end
end