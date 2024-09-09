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
    local fabric = inventory:FindAndReturn("RippedSheets");

    ISTimedActionQueue.add(TAPickDoorLock:new(player, door, time, primItem, scndItem));
end

-- Creates the context menu entry for "practice sewing"
-- @param player - Current player.
-- @param context - The context menu.
-- @param worldObjects - A list of clicked items.
--
local function createMenuEntries(player, context, items)
    local fabric;
    -- Search through the table of clicked items.
    local items = ISInventoryPane.getActualItems(items)
    for _, object in ipairs(items) do
        -- Look if the clicked item is a valid fabric.
        if object:getFullType() == "Base.RippedSheets" then
            fabric = object;
            break;
        end
    end

    -- Exit early if we have no door.
    if not fabric then return end

    local player = getSpecificPlayer(player);
    local inventory = player:getInventory();

    local needle = inventory:FindAndReturn("Needle");
    local thread = inventory:FindAndReturn("Thread");
    local fabric = inventory:getCountType("Base.RippedSheets");

    thread = thread:getRemainingUses();

    if needle then
        for _, patches in ipairs({ 10, 25, 50 }) do
            if thread >= patches and fabric >= patches then
                context:addOption("Practice sewing: " .. patches .. " patches", worldObjects, practiceSewing, patches,
                    player);
            end
        end
    end
end

-- ------------------------------------------------
-- Game hooks
-- ------------------------------------------------

Events.OnFillInventoryObjectContextMenu.Add(createMenuEntries);
