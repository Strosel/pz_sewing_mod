require "luautils";

---
-- @param worldObjects
-- @param door
-- @param player
--
local function practiceSewing(worldObjects, patches, player)
    local inventory = player:getInventory();

    local needle = inventory:getSomeTypeRecurse("Base.Needle", 1);
    ISInventoryPaneContextMenu.transferIfNeeded(player, needle);

    --HACK cant find and transfer thread by total number of uses
    local thread_needed = patches-inventory:getUsesType("Base.Thread");
    if thread_needed > 0 then
        local thread = inventory:getSomeTypeRecurse("Base.Thread", patches);
        if instanceof(thread, "InventoryItem") then
            ISInventoryPaneContextMenu.transferIfNeeded(player, thread);
        elseif instanceof(thread, "ArrayList") then
            for i=1,thread:size() do
                local spool = thread:get(i-1);
                thread_needed  = thread_needed - spool:getRemainingUses();
                ISInventoryPaneContextMenu.transferIfNeeded(player, spool);
                if thread_needed <= 0 then break end
            end
        end
    end

    local fabric = inventory:getSomeTypeRecurse("Base.RippedSheets", patches);
    ISInventoryPaneContextMenu.transferIfNeeded(player, fabric);

    ISTimedActionQueue.add(TAPracticeSewing:new(player, patches));
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

    local needle = inventory:containsTypeRecurse("Base.Needle");
    local thread = inventory:getUsesTypeRecurse("Base.Thread");
    local fabric = inventory:getCountTypeRecurse("Base.RippedSheets");

    if needle then
        for _, patches in ipairs({ 10, 25, 50 }) do
            if thread >= patches and fabric >= patches then
                context:addOption("Practice sewing: " .. patches .. " patches", worldObjects, practiceSewing, patches, player);
            end
        end
    end
end

-- ------------------------------------------------
-- Game hooks
-- ------------------------------------------------

Events.OnFillInventoryObjectContextMenu.Add(createMenuEntries);
