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

    local current_phase_segs = 16
    if current_phase == "day" then
        print("Daytime: ", current_phase_segs)
    elseif current_phase == "night" then
        print("Nighttime: ", current_phase_segs)
    elseif current_phase == "dusk" then
        print("Dusktime: ", current_phase_segs)
    end

    local current_seg = time:GetNormEraTime() * current_phase_segs
    if current_phase == "dusk" then
        current_seg = current_seg + time:GetDaySegs()
    elseif current_phase == "night" then
        current_seg = current_seg + time:GetDaySegs() + time:GetDuskSegs()
    end

    print("Time of day: ", time:GetNormEraTime(), "current seg:", current_seg, "day segs: ", time:GetDaySegs(),
        "night segs: ", time:GetNightSegs(), "dusk segs: ", time:GetDuskSegs())
    return {
        hoursInDay = 16,
        currentHour = current_seg,
        timePeriods = {
            day = time:GetDaySegs(),
            night = time:GetNightSegs(),
            dusk = time:GetDuskSegs()
        }
    }
end

function GetInventoryItems()

    -- return {"item" : "amount"}
    local player = GLOBAL.GetPlayer()
    local inventory = player.components.inventory
    local items = {}
    for k, v in pairs(inventory.itemslots) do
        if v then
            items[v.prefab] = inventory:Count(v.prefab, true)
        end
    end
    return items
end

function CanCraft(item)
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

function CraftableItems()
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

function Craft(item)
    if not CanCraft(item) then
        print("Cannot craft item: ", item)
        return
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

end

function WalkToXYZ(x, y, z)
    local player = GLOBAL.GetPlayer()
    player.components.locomotor:PushAction(GLOBAL.BufferedAction(player, nil, GLOBAL.ACTIONS.WALKTO, nil,
        GLOBAL.Vector3(x, y, z), nil, 0, true), true)
end

function WalkToEntity(entity_name)
    local entity = GetEntity(entity_name)
    if entity then
        local x, y, z = entity.Transform:GetWorldPosition()
        WalkToXYZ(x, y, z)
    end
end

function Wander()
    local player = GLOBAL.GetPlayer()
    local x, y, z = player.Transform:GetWorldPosition()

    local dx = math.random(-10, 10)
    local dz = math.random(-10, 10)
    -- move 10 units forward
    WalkToXYZ(x + dx, y, z + dz)

    print("Player position: ", x, y, z)
end

function GetNearbyEntities(distance)
    local player = GLOBAL.GetPlayer()
    local x, y, z = player.Transform:GetWorldPosition()
    local ents = GLOBAL.TheSim:FindEntities(x, y, z, distance or 10)
    local ent_str = ""
    for k, v in pairs(ents) do
        ent_str = ent_str .. v.prefab .. " "
    end
    -- print("Nearby entities: ", ent_str)

    return ents
end

function GetParsedEntities(distance)
    local entities = GetNearbyEntities(distance)
    local parsed_entities = {}
    -- parse entities into {"Rabbit": {"position": {"x": 0, "y": 0, "z": 0}, "components": ["Cookable", "Edible", "Dead"]}}
    for k, v in pairs(entities) do
        -- local components = {}
        -- for k, v in pairs(v.components) do
        --     table.insert(components, k)
        -- end

        -- local str = json.encode(components, {
        --     indent = true
        -- })
        local X, Y, Z = v.Transform:GetWorldPosition()
        parsed_entities[v.prefab] = {
            position = {
                x = X,
                y = Y,
                z = Z
            },
            -- components = str
        }
    end
    return parsed_entities
end

function PickEntity(entity_name)
    local entity = GetEntity(entity_name)
    if entity then
        -- BufferedAction
        local player = GLOBAL.GetPlayer()
        -- player.components.locomotor:PushAction(GLOBAL.BufferedAction(player, entity, GLOBAL.ACTIONS.PICK, nil, nil, nil, 0, nil, 2), true)
        -- if the entity is pickable, pick it

        local components_string = ""
        for k, v in pairs(entity.components) do
            components_string = components_string .. k .. " "
        end

        print("Picking entity: ", entity_name, " can be picked: ", entity.components.pickable:CanBePicked(),
            " components: ", components_string)

        if entity.components.pickable and entity.components.pickable:CanBePicked() then
            player.components.locomotor:PushAction(GLOBAL.BufferedAction(player, entity, GLOBAL.ACTIONS.PICK, nil, nil,
                nil, 0, nil, 2), true)
        end
    end
end

function PlayerSleep()
    local player = GLOBAL.GetPlayer()

    -- find entity with sleepingbag component
    local entities = GetNearbyEntities()
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

function Cook(item)
    local player = GLOBAL.GetPlayer()

    local inv_items = GetInventoryItems()
    local inventory = GLOBAL.GetPlayer().components.inventory

    local slot = 0
    -- find item in inventory
    for k, v in pairs(inventory.itemslots) do
        if v.prefab == item then
            -- buffered action
            print("Cooking item: ", item, k)

            local entities = GetNearbyEntities()
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

function GetEntity(name)
    local ents = GetNearbyEntities()
    for k, v in pairs(ents) do
        if v.prefab == name then
            return v
        end
    end
    return nil
end

function GetDistanceFrom(entity_name)
    local entity = GetEntity(entity_name)
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

function DropItem(item_name)
    local player = GLOBAL.GetPlayer()
    local inventory = player.components.inventory
    local slot = 0
    for k, v in pairs(inventory.itemslots) do
        if v.prefab == item_name then
            slot = k
            break
        end
    end
    player.components.locomotor:PushAction(GLOBAL.BufferedAction(player, nil, GLOBAL.ACTIONS.DROP,
        inventory.itemslots[slot], nil, nil, 0, nil, 2), true)
end

function DropStack(item_name, amount)
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

    player:DoPeriodicTask(1, function()
        local playerfacing = player.Transform:GetRotation()
        local x, y, z = player.Transform:GetWorldPosition()

        print("Health: ", player.components.health:GetDebugString())

        -- local ents = TheSim:FindEntities(x,y,z, GLOBAL.TUNING.SANITY_EFFECT_RANGE)
        -- for i,ent in ipairs(ents) do
        --     for component, _ in pairs(ent.components) do
        --         print("Component: ", component)
        --     end
        -- end

        -- WalkToEntity("flower")
        -- PickEntity("grass")

        -- send to position to the server
        -- print("Sending player position to server")

        -- SendData("Player position:   " .. x .. "   " .. y .. "   " .. z .. "\n")

        -- print("Receiving from server")

        -- print(ReceiveData())

        -- print("\n\n\n")

        -- print("Time of day: ", GetTimeOfDay()) -- returns a string?
        -- print("Inventory: ", GetInventoryItems()) -- returns a table
        -- print("CraftableItems: ", CraftableItems()) -- returns a table
        -- print out craftable items

        -- for k, v in pairs(CraftableItems()) do
        --     local ingredients = ""
        --     for i, j in pairs(v) do
        --         ingredients = ingredients .. j.type .. " " .. j.amount .. " "
        --     end
        --     print(k, ingredients)
        -- end

        -- print("CanCraft(axe): ", CanCraft("axe")) -- returns bool
        -- print("NearbyEntities: ", GetNearbyEntities()) -- returns a table
        -- print out nearby entities
        -- for k, v in pairs(GetNearbyEntities()) do
        --     print(v.prefab)
        -- end
        -- print("\n\n\n")

        -- GetDistanceFrom("researchlab") -- You need to be closer than 4 units to use it
        -- PlayerSleep()
        -- Cook("meat")
        -- Craft("campfire")
        -- DropStack("cutgrass")
        -- Craft("axe")

        print(player.components.health:GetDebugString())
        print(player.components.hunger:GetDebugString())
        print(player.components.sanity:GetDebugString())
        

        local tbl = {
            health = player.components.health:GetDebugString(),
            hunger = player.components.hunger:GetDebugString(),
            sanity = player.components.sanity:GetDebugString(),
        
            position = {
                x = x,
                y = y,
                z = z
            },
        
            inventory = GetInventoryItems(),
            equipped = {},
            biome = "",
            season = "",
            timeOfDay = GetTimeOfDay(),
            -- availableRecipes = CraftableItems(),
            entitiesOnScreen = GetParsedEntities(10),
            -- entitiesOnMap = GetParsedEntities(100),
        }

        local str = json.encode(tbl, {
            indent = true
        })

        -- print(str)

        SendData(str)

    end)

    -- debugging help
    -- GLOBAL.require("consolecommands")
    -- GLOBAL.c_select(player)
end
AddSimPostInit(PreparePlayerCharacter)

-- END PLAYER --

