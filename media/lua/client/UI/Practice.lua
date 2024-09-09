require('luautils');

---
-- @param worldObjects
-- @param door
-- @param player
--
local function practiceSewing(worldObjects, patches, player)
    local inventory = player:getInventory();

    local needle = inventory:FindAndReturn("Needle");
    local thread = inventory:FindAndReturn("Thread");
    local fabric = inventory:FindAndReturn("RippedSheets"); --TODO use dirty sheets?

    ISTimedActionQueue.add(TAPickDoorLock:new(player, door, time, primItem, scndItem));
end

-- Creates the context menu entry for "practice sewing"
-- @param player - Current player.
-- @param context - The context menu.
-- @param worldObjects - A list of clicked items.
--
local function createMenuEntries(player, context, worldObjects)
    local fabric;
    -- Search through the table of clicked items.
    for _, object in ipairs(worldObjects) do
        -- Look if the clicked item is a valid fabric.
        if instanceof(object, "RippedSheets") then --TODO use dirty sheets?
            fabric = object;
            break;
        end
    end

    -- Exit early if we have no door.
    if not fabric then return end
    
    local needle = inventory:FindAndReturn("Needle");
    local thread = inventory:FindAndReturn("Thread"):getCount();
    local fabric = inventory:FindAndReturn("RippedSheets"):getCount(); --TODO use dirty sheets?

    if needle then
        for _,patches in ipairs({10,25,50}) do
            if thread >= patches and fabric >= patches then
                context:addOption("Practice sewing: "..patches.." patches", worldObjects, practiceSewing, patches, player);
            end
        end
    end
end

-- ------------------------------------------------
-- Game hooks
-- ------------------------------------------------

Events.OnFillWorldObjectContextMenu.Add(createMenuEntries);
