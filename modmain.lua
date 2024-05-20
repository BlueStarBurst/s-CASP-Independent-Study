local DISTANCE = 20

-- Enable Debug Mode (Allow Cltr + R to return to main menu when crashed)
GLOBAL.CHEATS_ENABLED = true
GLOBAL.require( 'debugkeys' )

-- A Don't Starve mod that reads the current state of the game and outputs it to a file. This is a mod for the sCASP project.
local require = GLOBAL.require

local socket = require "socket"
local json = require "json"
local dkjson = require "dkjson"

local host = "localhost"
local port = 12345

local tcp = socket.tcp()

-- local client = socket.connect(host, port)

local Text = require "widgets/text"

require "constants"

print("sCASP reader modmain.lua loaded")

-- SERVER FUNCTIONS --

local currentAction = nil

function SendData(data)
    -- print("Sending data to server")
    tcp:send(data)
end

function ReceiveData()
    -- print("Receiving data from server")
    local s, status, partial = tcp:receive()
    print("Server:", s or partial)
    return s or partial
end

-- END SERVER FUNCTIONS --

-- ACTIONS --

function GetTimeOfDay()
    local time = GLOBAL.GetClock()
    local current_phase = time:GetPhase()
    local current_seg = time:GetSegs()

    return {
        currentPhase = current_phase, -- day, dusk, night
        percentagePhasePassed = time:GetNormEraTime(), -- 0 to 1 where 1 is the end of the phase
        timePeriods = {
            day = time:GetDaySegs(),
            night = time:GetNightSegs(),
            dusk = time:GetDuskSegs()
        }
    }
end

function CanBuild(item)
    local player = GLOBAL.GetPlayer()
    local inventory = player.components.inventory
    local recipes = GLOBAL.GetAllRecipes()
    local recipe = recipes[item]
    if recipe then
        local ingredients = recipe.ingredients
        for k, v in pairs(ingredients) do
            if not inventory:Has(v.type, v.amount) then
                return false
            end
        end
        return true
    end
    return false
end

function BuildableItems()
    -- get known recipes and put them in a table {axe: [(twigs, 2), (flint, 1)], ...}
    local recipes = GLOBAL.GetAllRecipes()
    local known_recipes = {}
    for k, v in pairs(recipes) do
        local ingredients = v.ingredients
        local recipe_name = v.name
        known_recipes[recipe_name] = 0
    end
    -- return known_recipes
end

function Build(item)
    if not CanBuild(item) then
        print("Cannot craft item: ", item)

        -- get each ingredient in the recipe
        local player = GLOBAL.GetPlayer()
        local inventory = player.components.inventory
        local recipes = GLOBAL.GetAllRecipes()
        local recipe = recipes[item]
        if recipe then
            local ingredients = recipe.ingredients
            for k, v in pairs(ingredients) do
                local ingredient = v.type
                local amount = v.amount
                local count = inventory:Count(ingredient, true)
                if count < amount then
                    print("Missing ingredient: ", ingredient, " amount: ", amount - count)
                    -- find entity with the ingredient

                    if ingredient == "twigs" then
                        if PickEntityByName("sapling") then
                            return true
                        else
                            Wander()
                        end
                    elseif ingredient == "cutgrass" then
                        if PickEntityByName("grass") then
                            return true
                        else
                            Wander()
                        end
                    else
                        if PickUpEntityByName(ingredient) then
                            return true
                        else
                            Wander()
                        end
                    end
                    -- else
                    --     print("Ingredient: ", ingredient, " amount: ", amount)
                    --     Wander()
                    -- end
                end
            end
        end

        return false
    end

    local player = GLOBAL.GetPlayer()
    local inventory = player.components.inventory
    local recipes = GLOBAL.GetAllRecipes()
    local recipe = recipes[item]
    -- use builder component to craft item
    local builder = player.components.builder
    if builder then
        builder:MakeRecipe(recipe)
    end
    return true
end

local prev_angle = 0

function WalkToXYZ(x, y, z)
    local player = GLOBAL.GetPlayer()

    local buffered = GLOBAL.BufferedAction(player, nil, GLOBAL.ACTIONS.WALKTO, nil, GLOBAL.Vector3(x, y, z), nil, 0,
        true)

    player.components.locomotor:PushAction(buffered, true)

    -- on success, clear the action
    buffered:AddSuccessAction(function()
        currentAction = nil
    end)

    player:DoTaskInTime(5, function()
        if player.components.locomotor.bufferedaction == buffered then
            player.components.locomotor:Clear()
            prev_angle = prev_angle + math.pi / 2
        end
    end)

end

function WalkInAngle(angle, distance)
    local player = GLOBAL.GetPlayer()
    local x, y, z = player.Transform:GetWorldPosition()
    local dx = math.cos(angle) * distance
    local dz = math.sin(angle) * distance
    WalkToXYZ(x + dx, y, z + dz)
end

function WalkToEntity(guid)
    local entity = GetEntity(guid)
    if entity then
        local x, y, z = entity.Transform:GetWorldPosition()
        WalkToXYZ(x, y, z)
    end
end

function WalkToEntityByName(entity_name)
    local entity = GetEntityByName(entity_name)
    if entity then
        local x, y, z = entity.Transform:GetWorldPosition()
        WalkToXYZ(x, y, z)
    end
end

function Wander()
    local player = GLOBAL.GetPlayer()

    if player.components.locomotor:HasDestination() then
        isBusy = true
        print("Player is busy")
        return
    end

    local angle = prev_angle + math.random(-1, 1) * math.pi / 3
    prev_angle = angle

    WalkInAngle(angle, 10)

    print("WANDERING")
end

local function Entity(inst, v)
    local d = {}

    d.GUID = v.GUID
    d.Prefab = v.prefab
    d.Quantity = v.components.stackable ~= nil and v.components.stackable:StackSize() or 1

    d.Pickable = v.components.pickable and v.components.pickable:CanBePicked()
    d.Cooker = v.components.cooker and true
    d.Cookable = v.components.cookable and true
    d.Edible = inst.components.eater:CanEat(v)
    d.Equippable = v.components.equippable  and true
    d.Fuel = v.components.fuel and true
    d.Fueled = v.components.fueled and not v.components.fueled:IsEmpty()
    d.Grower = v.components.grower and true
    d.Harvestable = v:HasTag("readyforharvest") or (v.components.stewer and v.components.stewer:IsDone())
    d.Collectable = v.components.inventoryitem and v.components.inventoryitem.canbepickedup and not v:HasTag("heavy") -- PICKUP
    d.Stewer = v.components.stewer and true
    d.Hostile = v:HasTag("hostile") or (v.components.combat and v.components.combat.target == GLOBAL.GetPlayer())

    d.Workable = v.components.workable and v.components.workable:CanBeWorked()
    d.Choppable = d.Workable and v.components.workable.action == GLOBAL.ACTIONS.CHOP
    d.Diggable = d.Workable and v.components.workable.action == GLOBAL.ACTIONS.DIG
    d.Hammerable = d.Workable and v.components.workable.action == GLOBAL.ACTIONS.HAMMER
    d.Mineable = d.Workable and v.components.workable.action == GLOBAL.ACTIONS.MINE

    -- remove all keyx with false values
    for k, v in pairs(d) do
        if not v then
            d[k] = nil
        end
    end

    -- d.X, d.Y, d.Z = v.Transform:GetWorldPosition() --Useless for now?
    return d
end

function GetInventoryItems()

    local player = GLOBAL.GetPlayer()
    local inventory = player.components.inventory
    local items = {}

    for k, v in pairs(inventory.itemslots) do
        local entity = Entity(player, v)
        table.insert(items, entity)
    end
    return items
end
    
function GetEquippedItems()
    local player = GLOBAL.GetPlayer()
    local inventory = player.components.inventory
    local items = {}

    for k, v in pairs(inventory.equipslots) do
        if v then
            local entity = Entity(player, v)
            table.insert(items, entity)
        end
    end
    return items
end 

function GetNearbyEntities(distance)
    print("Getting nearby entities")
    local player = GLOBAL.GetPlayer()
    local x, y, z = player.Transform:GetWorldPosition()

    local TAGS = nil
    local EXCLUDE_TAGS = {"INLIMBO", "NOCLICK", "CLASSIFIED", "FX"}
    local ONE_OF_TAGS = nil

    local ents = GLOBAL.TheSim:FindEntities(x, y, z, distance, TAGS, EXCLUDE_TAGS, ONE_OF_TAGS)
    return ents
end

function GetParsedEntities(distance)
    local player = GLOBAL.GetPlayer()
    local entities = GetNearbyEntities(distance)
    local parsed_ents = {}
    for k, v in pairs(entities) do
        if player.GUID ~= v.GUID then
            local entity = Entity(player, v)
            table.insert(parsed_ents, entity)
        end
    end
    print("Parsed entities: ", parsed_ents)
    return parsed_ents
end

function PickEntity(guid)
    local entity = GetEntity(guid)
    if entity then
        -- BufferedAction
        local player = GLOBAL.GetPlayer()
        -- player.components.locomotor:PushAction(GLOBAL.BufferedAction(player, entity, GLOBAL.ACTIONS.PICK, nil, nil, nil, 0, nil, 2), true)
        -- if the entity is pickable, pick it

        local components_string = ""
        for k, v in pairs(entity.components) do
            components_string = components_string .. k .. " "
        end

        if entity.components.pickable and entity.components.pickable:CanBePicked() then
            print("Picking entity: ", entity.prefab, " can be picked: ", entity.components.pickable:CanBePicked(),
                " components: ", components_string)
            player.components.locomotor:PushAction(GLOBAL.BufferedAction(player, entity, GLOBAL.ACTIONS.PICK, nil, nil,
                nil, 0, nil, 2), true)
            return true
        end
    end
    return false
end

-- switch to guid
function PickEntityByName(entity_name)
    local entity = GetEntityByName(entity_name)
    if entity then
        -- BufferedAction
        local player = GLOBAL.GetPlayer()
        -- player.components.locomotor:PushAction(GLOBAL.BufferedAction(player, entity, GLOBAL.ACTIONS.PICK, nil, nil, nil, 0, nil, 2), true)
        -- if the entity is pickable, pick it

        local components_string = ""
        for k, v in pairs(entity.components) do
            components_string = components_string .. k .. " "
        end

        if entity.components.pickable and entity.components.pickable:CanBePicked() then
            print("Picking entity: ", entity_name, " can be picked: ", entity.components.pickable:CanBePicked(),
                " components: ", components_string)
            player.components.locomotor:PushAction(GLOBAL.BufferedAction(player, entity, GLOBAL.ACTIONS.PICK, nil, nil,
                nil, 0, nil, 2), true)
            return true
        end
    end
    return false
end

function PickUpEntity(guid)
    local entity = GetEntity(guid)
    if entity then
        -- BufferedAction
        local player = GLOBAL.GetPlayer()
        -- player.components.locomotor:PushAction(GLOBAL.BufferedAction(player, entity, GLOBAL.ACTIONS.PICK, nil, nil, nil, 0, nil, 2), true)
        -- if the entity is pickable, pick it

        local components_string = ""
        for k, v in pairs(entity.components) do
            components_string = components_string .. k .. " "
        end

        if entity.components.pickable and entity.components.pickable:CanBePicked() then
            print("Picking entity: ", entity.prefab, " can be picked: ", entity.components.pickable:CanBePicked(),
                " components: ", components_string)
            player.components.locomotor:PushAction(GLOBAL.BufferedAction(player, entity, GLOBAL.ACTIONS.PICK, nil, nil,
                nil, 0, nil, 2), true)
            return true
        end
    end
    return false
end

-- switch to guid
function PickUpEntityByName(entity_name) -- pick up entity from the ground
    local entity = GetEntityByName(entity_name)
    if entity then

        print("Picking up entity: ", entity_name)

        -- print all components of the entity
        local components_string = ""
        for k, v in pairs(entity.components) do
            components_string = components_string .. k .. " "
        end
        print("Components: ", components_string)

        -- BufferedAction walk to the entity and pick it up
        local player = GLOBAL.GetPlayer()

        -- walk to the entity
        local x, y, z = entity.Transform:GetWorldPosition()
        -- player.components.locomotor:PushAction(GLOBAL.BufferedAction(player, nil, GLOBAL.ACTIONS.WALKTO, nil,
        -- GLOBAL.Vector3(x, y, z), nil, 0, true), true)

        player.components.locomotor:PushAction(GLOBAL.BufferedAction(player, entity, GLOBAL.ACTIONS.PICKUP, nil, nil,
            nil, 0, nil, 2), true)

        return true

        -- sleep for 2 seconds
        -- GLOBAL.Sleep(2)

    end
    return false
end

-- not working ??
function PlayerSleep()
    local player = GLOBAL.GetPlayer()

    -- find entity with sleepingbag component
    local entities = GetNearbyEntities(DISTNACE)
    local entity = nil
    for k, v in pairs(entities) do
        if v.components.sleepingbag then
            entity = v
            break
        end
    end

    -- buffered action
    if entity and entity.components.sleepingbag then
        player.components.locomotor:PushAction(GLOBAL.BufferedAction(player, entity, GLOBAL.ACTIONS.SLEEPIN, nil, nil,
            nil, 0, nil, 2), true)
    end
end

function Cook()
    local player = GLOBAL.GetPlayer()

    local inv_items = GetInventoryItems()
    local inventory = GLOBAL.GetPlayer().components.inventory

    local slot = 0
    -- find item in inventory
    for k, v in pairs(inventory.itemslots) do
        if v.components.cookable then
            -- buffered action
            print("Cooking item: ", item, k)

            local entities = GetNearbyEntities(DISTANCE)
            local entity = nil
            for k, v in pairs(entities) do
                if v.components.cooker then
                    entity = v
                    break
                end
            end

            -- buffered action
            if entity and entity.components.cooker then
                -- set Active item:
                -- player.components.inventory:SelectActiveItemFromSlot(k)

                player.components.locomotor:PushAction(GLOBAL.BufferedAction(player, entity, GLOBAL.ACTIONS.COOK, v,
                    nil, nil, 0, nil, 2), true)
            end

            break
        end
    end

end

-- switch to guid
function CookByName(item)
    local player = GLOBAL.GetPlayer()

    local inv_items = GetInventoryItems()
    local inventory = GLOBAL.GetPlayer().components.inventory

    local slot = 0
    -- find item in inventory
    for k, v in pairs(inventory.itemslots) do
        if v.prefab == item then
            -- buffered action
            print("Cooking item: ", item, k)

            local entities = GetNearbyEntities(DISTANCE)
            local entity = nil
            for k, v in pairs(entities) do
                if v.components.cooker then
                    entity = v
                    break
                end
            end

            -- buffered action
            if entity and entity.components.cooker then
                -- set Active item:
                -- player.components.inventory:SelectActiveItemFromSlot(k)

                player.components.locomotor:PushAction(GLOBAL.BufferedAction(player, entity, GLOBAL.ACTIONS.COOK, v,
                    nil, nil, 0, nil, 2), true)
            end

            break
        end
    end

end

-- switch to guid
function GetEntity(guid)
    local ents = GetNearbyEntities(DISTANCE)
    for k, v in pairs(ents) do
        if v.GUID == guid and not v:IsInLimbo() then
            return v
        end
    end
    return nil
end

function GetEntityByName(name)
    local ents = GetNearbyEntities(DISTANCE)
    local ent = nil
    local dist = 1000
    local player = GLOBAL.GetPlayer()
    local x, y, z = player.Transform:GetWorldPosition()
    for k, v in pairs(ents) do
        if v.prefab == name then

            -- not in limbo
            if not v:IsInLimbo() then

                local ex, ey, ez = v.Transform:GetWorldPosition()
                local d = math.sqrt((x - ex) ^ 2 + (y - ey) ^ 2 + (z - ez) ^ 2)
                if d < dist then
                    dist = d
                    ent = v
                end
            end
        end
    end

    if ent then
        print("Found entity: ", name, " at distance: ", dist)
        return ent
    end
    return nil
end

function GetDistanceFrom(guid)
    local entity = GetEntity(guid)
    if entity then
        local player = GLOBAL.GetPlayer()
        local x, y, z = player.Transform:GetWorldPosition()
        local ex, ey, ez = entity.Transform:GetWorldPosition()
        local distance = math.sqrt((x - ex) ^ 2 + (y - ey) ^ 2 + (z - ez) ^ 2)
        print("Distance from ", guid, ": ", distance)
        return distance
    end
    return nil
end

-- switch to guid
function GetDistanceFromByName(entity_name)
    local entity = GetEntityByName(entity_name)
    if entity then
        local player = GLOBAL.GetPlayer()
        local x, y, z = player.Transform:GetWorldPosition()
        local ex, ey, ez = entity.Transform:GetWorldPosition()
        local distance = math.sqrt((x - ex) ^ 2 + (y - ey) ^ 2 + (z - ez) ^ 2)
        print("Distance from ", entity_name, ": ", distance)
        return distance
    end
    return nil
end

-- switch to guid
function DropItem(guid)
    local player = GLOBAL.GetPlayer()
    local inventory = player.components.inventory
    local slot = -1
    for k, v in pairs(inventory.itemslots) do
        if v.GUID == guid then
            slot = k
            break
        end
    end

    if slot == -1 then
        return
    end

    local action = GLOBAL.BufferedAction(player, nil, GLOBAL.ACTIONS.DROP, inventory.itemslots[slot], nil, nil, 0, nil,
        2)
    action.options = {
        wholestack = true
    }
    player.components.locomotor:PushAction(action, true)

end

function DropItemByName(item_name)
    local player = GLOBAL.GetPlayer()
    local inventory = player.components.inventory
    local slot = -1
    for k, v in pairs(inventory.itemslots) do
        if v.prefab == item_name then
            slot = k
            break
        end
    end

    if slot == -1 then
        return
    end

    local action = GLOBAL.BufferedAction(player, nil, GLOBAL.ACTIONS.DROP, inventory.itemslots[slot], nil, nil, 0, nil,
        2)
    action.options = {
        wholestack = true
    }
    player.components.locomotor:PushAction(action, true)

end

function IsPlayerInLight()
    local player = GLOBAL.GetPlayer()
    local x, y, z = player.Transform:GetWorldPosition()
    local ents = GetNearbyEntities(10)

    for k, v in pairs(ents) do
        if v.components.burnable and v.components.burnable:GetLargestLightRadius() then
            local ex, ey, ez = v.Transform:GetWorldPosition()
            local d = math.sqrt((x - ex) ^ 2 + (y - ey) ^ 2 + (z - ez) ^ 2)
            if d < v.components.burnable:GetLargestLightRadius() then
                return true
            end
        end
    end
    return false

end

function Equip(guid)
    local player = GLOBAL.GetPlayer()
    local inventory = player.components.inventory
    local slot = -1

    -- if item is in equipslots, return
    for k, v in pairs(inventory.equipslots) do
        if v and v.GUID == guid then
            return true
        end
    end

    for k, v in pairs(inventory.itemslots) do
        if v and v.GUID == guid then
            slot = k
            break
        end
    end

    if slot == -1 then
        return false
    end

    player.components.locomotor:PushAction(GLOBAL.BufferedAction(player, nil, GLOBAL.ACTIONS.EQUIP,
        inventory.itemslots[slot], nil, nil, 0, nil, 2), true)

    return true
end

function EquipByName(item_name)
    local player = GLOBAL.GetPlayer()
    local inventory = player.components.inventory
    local slot = -1

    -- if item is in equipslots, return
    for k, v in pairs(inventory.equipslots) do
        if v and v.prefab == item_name then
            return true
        end
    end

    for k, v in pairs(inventory.itemslots) do
        if v and v.prefab == item_name then
            slot = k
            break
        end
    end

    if slot == -1 then
        Build(item_name)
        return false
    end

    player.components.locomotor:PushAction(GLOBAL.BufferedAction(player, nil, GLOBAL.ACTIONS.EQUIP,
        inventory.itemslots[slot], nil, nil, 0, nil, 2), true)

    return true
end

function CutDownTree()
    local player = GLOBAL.GetPlayer()
    local x, y, z = player.Transform:GetWorldPosition()

    -- if logs or pinecones are on the ground, pick them up
    local ents = GLOBAL.TheSim:FindEntities(x, y, z, 10)
    for k, v in pairs(ents) do
        if v.prefab == "log" or v.prefab == "pinecone" then
            if PickUpEntityByName(v.prefab) == true then
                return
            end
        end
    end

    if not EquipByName("axe") then
        return
    end

    -- -- if player has axe equipped, chop down tree
    -- local inventory = player.components.inventory
    -- local slot = -1
    -- for k, v in pairs(inventory.equipslots) do
    --     if v and v.prefab == "axe" then
    --         slot = k
    --         break
    --     end
    -- end

    -- if slot == -1 then
    --     -- if no axe, craft one
    --     MakeAxe()
    --     return

    -- end

    -- -- if axe is not equipped, equip it
    -- if not inventory.equipslots[slot] then
    --     player.components.locomotor:PushAction(GLOBAL.BufferedAction(player, nil, GLOBAL.ACTIONS.EQUIP, inventory.itemslots[slot], nil, nil, 0, nil, 2), true)
    -- end

    local ents = GLOBAL.TheSim:FindEntities(x, y, z, 10)
    local closest = nil
    local dist = 1000
    for k, v in pairs(ents) do
        -- if no stump, chop tree
        if v.prefab == "evergreen" and not v:HasTag("stump") then
            local ex, ey, ez = v.Transform:GetWorldPosition()
            local d = math.sqrt((x - ex) ^ 2 + (y - ey) ^ 2 + (z - ez) ^ 2)
            if d < dist then
                dist = d
                closest = v
            end

        end
    end

    if closest then
        player.components.locomotor:PushAction(GLOBAL.BufferedAction(player, closest, GLOBAL.ACTIONS.CHOP, nil, nil,
            nil, 0, nil, 2), true)
    else
        Wander()
    end
end

function RunAway() -- run away from nearest entity with hostile tag
    local player = GLOBAL.GetPlayer()
    local x, y, z = player.Transform:GetWorldPosition()

    local ents = GetNearbyEntities(DISTANCE)
    local closest = nil
    local dist = 1000
    for k, v in pairs(ents) do
        if v:HasTag("hostile") then
            local ex, ey, ez = v.Transform:GetWorldPosition()
            local d = math.sqrt((x - ex) ^ 2 + (y - ey) ^ 2 + (z - ez) ^ 2)
            if d < dist then
                dist = d
                closest = v
            end
        end
    end

    if closest then
        local ex, ey, ez = closest.Transform:GetWorldPosition()
        local dx = x - ex
        local dz = z - ez
        local angle = math.atan2(dz, dx)
        WalkInAngle(angle + math.pi, 10)
    end
end

function EatFood(guid)
    local player = GLOBAL.GetPlayer()
    local inventory = player.components.inventory
    local slot = -1
    for k, v in pairs(inventory.itemslots) do
        if v.GUID == guid then
            slot = k
            break
        end
    end

    if slot == -1 then
        return false
    end

    player.components.locomotor:PushAction(GLOBAL.BufferedAction(player, nil, GLOBAL.ACTIONS.EAT,
        inventory.itemslots[slot], nil, nil, 0, nil, 2), true)
    return true
end

function EatFoodByName(item_name)
    local player = GLOBAL.GetPlayer()
    local inventory = player.components.inventory
    local slot = -1
    for k, v in pairs(inventory.itemslots) do
        if v.prefab == item_name then
            slot = k
            break
        end
    end

    if slot == -1 then
        return false
    end

    player.components.locomotor:PushAction(GLOBAL.BufferedAction(player, nil, GLOBAL.ACTIONS.EAT,
        inventory.itemslots[slot], nil, nil, 0, nil, 2), true)
    return true
end

function AddFuel()
    local player = GLOBAL.GetPlayer()
    local inventory = player.components.inventory
    local slot = -1

    for k, v in pairs(inventory.itemslots) do
        if v.components.fuel then
            slot = k
            break
        end
    end

    if slot == -1 then
        return false
    end

    player.components.locomotor:PushAction(GLOBAL.BufferedAction(player, nil, GLOBAL.ACTIONS.ADDFUEL,
        inventory.itemslots[slot], nil, nil, 0, nil, 2), true)
    return true
end

-- END ACTIONS --

-- PLAYER --

function PreparePlayerCharacter(player)
    -- local numbertext = Text(GLOBAL.BUTTONFONT, 24, "Test") --Make some text
    -- numbertext:SetColour(1,1,1,1) --Set the colour to white
    -- The player entity isn't quite ready to equip items yet, so wait one frame
    player:DoTaskInTime(0, function()

        print("Attempting connection to host '" .. host .. "' and port " .. port .. "...")
        tcp:connect(host, port);
        tcp:settimeout(0.1)

        -- Grab a reference to the home campfire
        local x, y, z = player.Transform:GetWorldPosition()

        print("Player position STARTREADER: ", x, y, z)

    end)

    player:DoPeriodicTask(3, function()
        -- Wander()
    end)

    local isBusy = false

    player:DoPeriodicTask(3, function()

        if isBusy then
            return
        end

        -- if locomotor is currently performing an action, don't read from the server

        local playerfacing = player.Transform:GetRotation()
        local x, y, z = player.Transform:GetWorldPosition()

        -- print("Health: ", player.components.health:GetDebugString())

        -- GetDistanceFrom("researchlab") -- You need to be closer than 4 units to use it
        -- PlayerSleep()
        -- Cook("meat")
        -- Build("campfire")
        -- DropStack("cutgrass")
        -- Build("axe")

        -- print(player.components.health:GetDebugString())
        -- print(player.components.hunger:GetDebugString())
        -- print(player.components.sanity:GetDebugString())

        print("Player position: ", x, y, z)
        local tbl = {
            health = player.components.health:GetDebugString(),
            hunger = player.components.hunger:GetDebugString(),
            sanity = player.components.sanity:GetDebugString(),

            -- position = {
            --     x = x,
            --     y = y,
            --     z = z
            -- },

            inventory = GetInventoryItems(),
            equipped = GetEquippedItems(),
            biome = "",
            isInLight = IsPlayerInLight(),
            season = "",
            time = GetTimeOfDay(),
            -- availableRecipes = BuildableItems(),
            entitiesOnScreen = GetParsedEntities(DISTANCE)
        }

        local str = json.encode(tbl, {
            indent = true
        })

        -- print(str)

        SendData(str)
        isBusy = true
        -- local data = ReceiveData()

        -- if currentAction then
        --     print("Current action: ", currentAction)
        --     return
        -- end

        -- if data then
        --     local tbl = dkjson.decode(data)
        --     if tbl then
        --         for k, v in pairs(tbl) do
        --             if k == "action" then

        --                 print("Action: ", v)
        --                 -- loadstring("return " .. v)()

        --                 -- if v == "equip_torch_night_hostile" then
        --                 --     Equip("torch")
        --                 -- elseif v == "run_away_from_enemy" then
        --                 --     RunAway("spider") -- no params
        --                 -- elseif v == "eat_maybe_food" then
        --                 --     EatFood("carrot") -- no params
        --                 -- elseif v == "eat_edible_food" then
        --                 --     EatFood("carrot") -- no params
        --                 -- elseif v == "pick_flower" then
        --                 --     PickEntity("flower")
        --                 -- elseif v == "wander_flower" then
        --                 --     Wander()
        --                 -- elseif v == "run_to_campfire" then
        --                 --     WalkToEntity("campfire")
        --                 -- elseif v == "fuel_campfire" then
        --                 --     AddFuel("log") -- no params
        --                 -- elseif v == "build_campfire" then
        --                 --     Build("campfire")
        --                 -- elseif v == "equip_torch_night" then
        --                 --     Equip("torch")
        --                 -- elseif v == "build_torch_night" then
        --                 --     Build("torch")
        --                 -- elseif v == "cook_food" then
        --                 --     Cook("meat") -- no params
        --                 -- elseif v == "pick_anything" then
        --                 --     PickEntity("flower") -- no params
        --                 -- elseif v == "build_axe" then
        --                 --     Build("axe")
        --                 -- elseif v == "build_torch" then
        --                 --     Build("torch")
        --                 -- elseif v == "equip_axe" then
        --                 --     Equip("axe")
        --                 -- elseif v == "chop_tree" then
        --                 --     CutDownTree()
        --                 -- end
        --             end
        --         end
        --     end
        -- end

    end)

    player:DoPeriodicTask(3, function()

        if not isBusy then
            return
        end

        local data = ReceiveData()

        if currentAction then
            print("Current action: ", currentAction)
            return
        end

        if data then
            local tbl = dkjson.decode(data)
            if tbl then
                for k, v in pairs(tbl) do
                    if k == "action" then


                        print("Action: ", v)
                        -- loadstring("return " .. v)()

                        if v == "equip_torch_night_hostile" then
                            Equip("torch")
                        elseif v == "run_away_from_enemy" then
                            RunAway("spider") -- no params
                        elseif v == "eat_maybe_food" then
                            EatFood("carrot") -- no params
                        elseif v == "eat_edible_food" then
                            EatFood("carrot") -- no params
                        elseif v == "pick_flower" then
                            PickEntity("flower")
                        elseif v == "wander_flower" then
                            Wander()
                        elseif v == "run_to_campfire" then
                            WalkToEntity("campfire")
                        elseif v == "fuel_campfire" then
                            AddFuel("log") -- no params
                        elseif v == "build_campfire" then
                            Build("campfire")
                        elseif v == "equip_torch_night" then
                            Equip("torch")
                        elseif v == "build_torch_night" then
                            Build("torch")
                        elseif v == "cook_food" then
                            Cook("meat") -- no params
                        elseif v == "pick_anything" then
                            PickEntity("flower") -- no params
                        elseif v == "build_axe" then
                            Build("axe")
                        elseif v == "build_torch" then
                            Build("torch")
                        elseif v == "equip_axe" then
                            Equip("axe")
                        elseif v == "chop_tree" then
                            CutDownTree()
                        end
                    end
                end
            end
        end

        isBusy = false

    end)

    -- debugging help
    -- GLOBAL.require("consolecommands")
    -- GLOBAL.c_select(player)
end
AddSimPostInit(PreparePlayerCharacter)

-- END PLAYER --

