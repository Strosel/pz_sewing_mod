require "TimedActions/ISBaseTimedAction"

TAPracticeSewing = ISBaseTimedAction:derive("TAPracticeSewing");

function TAPracticeSewing:isValid() -- Check if the action can be done
    --TODO check if ammount of material matches expected time
    return self.character:getInventory():contains(self.needle) and
        self.character:getInventory():contains(self.fabric) and
        self.character:getInventory():contains(self.thread)
end

function TAPracticeSewing:start() -- Trigger when the action start
    self:setActionAnim(CharacterActionAnims.Craft);
end

function TAPracticeSewing:stop() -- Trigger if the action is cancel
    print("Action stop");
    self:Practice(self:getJobDelta());

    -- Remove self from the queue
    ISBaseTimedAction.stop(self);
end

function TAPracticeSewing:perform() -- Trigger when the action is complete
    print("Action perform");
    self:Practice(1.0);
    
    -- Remove self from the queue
    ISBaseTimedAction.perform(self);
end

function TAPracticeSewing:Practice(progress)
    local patches_used = math.floor(self.patches*progress);
    
    --NOTE removing a patch always gets 1XP but getting it back gets 4XP, every few patches one is therfore worth 4 times as much
    local got_back = math.floor(patches * 100.0/ISRemovePatch.chanceToGetPatchBack(self.character));
    local ripped = patches - got_back;
    --NOTE adding a patch gives 1 or 2 XP averaged over a large number of patches gives 1.5XP/Patch
    local xp = 1.5*patches_used + ripped + 4*got_back;
    self.character:getXp():AddXP(Perks.Tailoring, xp);

    for n=1,patches_used do
        if n > got_back then
            self.character:getInventory():Remove(self.fabric);
        end
        self.thread:Use();
    end
end

function TAPracticeSewing:new(character, patches, fabric, thread, needle) -- What to call in you code
    local o = {};
    setmetatable(o, self);
    self.__index = self;
    o.character = character;
    o.patches = patches;
    o.maxTime = 2*patches*(150 - (character:getPerkLevel(Perks.Tailoring) * 6));
    if o.character:isTimedActionInstant() then o.maxTime = 1; end
    return o;
end
