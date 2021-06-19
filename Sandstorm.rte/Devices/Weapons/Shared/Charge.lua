function Create(self)

	self.chargeSound = CreateSoundContainer("YourSoundContainer", "Your.rte"); -- prepare a soundcontainer to play later, you need to define this in .ini
	
	self.parentSet = false; -- we need to find our parent in Update so we just set a variable saying we haven't yet to keep track of it
	
	self.charge = false; -- not charging on startup
	self.chargeTimer = Timer(); -- save a timer to use
	self.chargeTimeMS = 100; -- milliseconds between frames. there's more ways to do this but this way is least math-intensive
	
	self.lastAge = self.Age + 0; -- failsafe for when you put away the gun while charging. guns in inventories are in some weird void state and can't really do anything then
	
	self.fireDelayTimer = Timer();
	self.fireDelayMS = 200; -- timer and minor delay for after reloading just to be tidy
	
	self.activated = false; -- not charging on startup

end
function Update(self)
	
	if self.ID == self.RootID then -- ID is our ID, RootID is the ID of the final thing we're attached to. if they're the same, we're not attached to anything
		self.parent = nil;
		self.parentSet = false;
	elseif self.parentSet == false then -- if it is different we're probably being held, so set parent
		local actor = MovableMan:GetMOFromID(self.RootID); -- MovableMan is MovableManager which manages all movables (wow), MO is Movable Object. self explanatory
		if actor and IsAHuman(actor) then
			self.parent = ToAHuman(actor); -- for some reason you need to do ToClass sometimes, i'm not smart enough in c++ to know exactly why
			self.parentSet = true;
		end
	end
	
	-- Check if switched weapons/hide in the inventory, etc.
	if self.Age > (self.lastAge + TimerMan.DeltaTimeSecs * 2000) then
		if self.charge then
			self.charge = false;
		end
		self.fireDelayTimer:Reset();
	end
	self.lastAge = self.Age + 0; -- + 0 to save the value rather than a reference
	
	if self:DoneReloading() or self:IsReloading() then -- self explanatory
		self.fireDelayTimer:Reset();
	end

	if self.parent then -- if we have a parent, do all the chargey stuff. if we don't, and for example some magic mod is trying to 
						-- forcibly activate without holding us, the charge just wont happen and the gun will fire normally.
						
		local fire = self:IsActivated(); -- self:IsActivated is a helddevice function that returns true or false depending on whether it's activated or not, i.e. primary mouse button clicked or held
		
		self:Deactivate(); -- after saving whether we're truly activated or not, always keep ourselves deactivated so we can't fire without wanting to
		
		if fire and not self:IsReloading() then
			if not self.Magazine or self.Magazine.RoundCount < 1 then
				--self:Reload();
				self:Activate(); -- if we're on an empty mag or no mag at all, just activate, this will trigger a reload
			elseif not self.activated and not self.charge and self.fireDelayTimer:IsPastSimMS(self.fireDelayMS) then
				self.activated = true;
				
				self.chargeSound:Play(self.Pos); -- play the charging sound at our position
				
				self.fireDelayTimer:Reset();
				
				self.charge = true;
				self.chargeTimer:Reset(); -- reset the timer back to 0
			end
		else
			if self.activated then
				self.activated = false;
			end
		end
	end
	
	if self.charge then
		self.chargeSound.Pos = self.Pos; -- set the position of the sound to us all the time so it follows
		
		if self.chargeTimer:IsPastSimMS(self.chargeTimeMS) then
			if self.Frame == self.FrameCount then -- if we're at final frame
				self:Activate(); -- fire!!!
				self.charge = false;
				self.Frame = 0;
			else
				self.Frame = self.Frame + 1; -- increment frame by 1
			end
		end
	end
	
end