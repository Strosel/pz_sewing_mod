require "luautils";
require "TimedActions/ISBaseTimedAction"

TAPracticeSewing = ISBaseTimedAction:derive("TAPracticeSewing");

function TAPracticeSewing:isValid() -- Check if the action can be done
    -- Check if ammount of material matches expected time
    local inventory = self.character:getInventory();
    local needle = inventory:contains("Needle");
    local thread = inventory:getUsesType("Base.Thread");
    local fabric = inventory:getCountType("Base.RippedSheets");

    return needle and
        thread >= self.patches and
        fabric >= self.patches
end

function TAPracticeSewing:start() -- Trigger when the action start
    self:setActionAnim(CharacterActionAnims.Craft);
end

function TAPracticeSewing:stop() -- Trigger if the action is cancel
    self:Practice(self:getJobDelta());

    -- Remove self from the queue
    ISBaseTimedAction.stop(self);
end

function TAPracticeSewing:perform() -- Trigger when the action is complete
    self:Practice(1.0);

    -- Remove self from the queue
    ISBaseTimedAction.perform(self);
end

function TAPracticeSewing:Practice(progress)
    local patches_used = math.floor(self.patches * progress);
    --NOTE removing a patch always gets 1XP but getting it back gets 4XP, every few patches one is therfore worth 4 times as much
    local got_back = math.floor(patches_used * ISRemovePatch.chanceToGetPatchBack(self.character) / 100.0);
    print(string.format("Finished at %.2f%% %d patches used %d returned", progress, patches_used, got_back));
    local ripped = patches_used - got_back;
    --NOTE adding a patch gives 1 or 2 XP averaged over a large number of patches gives 1.5XP/Patch
    local xp = 1.5 * patches_used + ripped + 4 * got_back;
    self.character:getXp():AddXP(Perks.Tailoring, xp);
    local inventory = self.character:getInventory();

    for n = 1, patches_used do
        if n > got_back then
            inventory:Remove("RippedSheets");
        end
        inventory:FindAndReturn("Thread"):Use();
    end
end

function TAPracticeSewing:new(character, patches) -- What to call in you code
    local o = {};
    setmetatable(o, self);
    self.__index = self;
    o.character = character;
    o.patches = patches;
    o.maxTime = 2 * patches * (150 - (character:getPerkLevel(Perks.Tailoring) * 6));
    if o.character:isTimedActionInstant() then o.maxTime = 1; end
    return o;
end
