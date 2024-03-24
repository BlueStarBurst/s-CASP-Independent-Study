

-- A Don't Starve mod that reads the current state of the game and outputs it to a file. This is a mod for the sCASP project.
local require = GLOBAL.require

local socket = require "socket"
local json = require "json"

local host = "localhost"
local port = 12345

local tcp = socket.tcp()

-- local client = socket.connect(host, port)




local Text = require "widgets/text"

require "constants"

print("sCASP reader modmain.lua loaded")

-- print player coordinates to logs

function SendData(data)
    -- print("Sending data to server")
    tcp:send(data)
end

function ReceiveData()
    -- print("Receiving data from server")
    local s, status, partial = tcp:receive()
    -- print("Server:", s or partial)
    return s or partial
end




function GetTimeOfDay()
    local time = GLOBAL.GetClock()
    return time
end

function GetInventoryItems() 
    local items = {}
    local inventory = GLOBAL.GetPlayer().components.inventory
    for k, v in pairs(inventory.itemslots) do
        if v then
            table.insert(items, v.prefab)
        end
    end

    local inv_str = ""
    for k, v in pairs(items) do
        inv_str = inv_str .. v .. " "
    end
    print("Inventory: ", inv_str)

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
    -- get known recipes
    local recipes = GLOBAL.GetAllRecipes()
    local known_recipes = {}
    for k, v in pairs(recipes) do
        table.insert(known_recipes, v.name)
    end

    local known_str = ""
    local count = 0
    for k, v in pairs(known_recipes) do
        if count > 10 then
            break
        end
        known_str = known_str .. v .. " "
        count = count + 1
    end

    print("Known recipes: ", known_str)

    return known_recipes
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

function Wander()
    local player = GLOBAL.GetPlayer()
    local x, y, z = player.Transform:GetWorldPosition()

    local dx = math.random(-10, 10)
    local dz = math.random(-10, 10)
    -- move 10 units forward
    player.components.locomotor:PushAction(GLOBAL.BufferedAction(player, nil, GLOBAL.ACTIONS.WALKTO, nil, GLOBAL.Vector3(x + dx, y, z + dz), nil, 0, true), true)

    print("Player position: ", x, y, z)
end

function GetNearbyEntities()
    local player = GLOBAL.GetPlayer()
    local x, y, z = player.Transform:GetWorldPosition()
    local ents = GLOBAL.TheSim:FindEntities(x, y, z, 10)
    local ent_str = ""
    for k, v in pairs(ents) do
        ent_str = ent_str .. v.prefab .. " "
    end
    print("Nearby entities: ", ent_str)

    return ents
end

function PreparePlayerCharacter(player)
    -- local numbertext = Text(GLOBAL.BUTTONFONT, 24, "Test") --Make some text
    -- numbertext:SetColour(1,1,1,1) --Set the colour to white
    -- The player entity isn't quite ready to equip items yet, so wait one frame
    player:DoTaskInTime(0, function()
        
        print("Attempting connection to host '" ..host.. "' and port " ..port.. "...")
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
        local ents = TheSim:FindEntities(x,y,z, GLOBAL.TUNING.SANITY_EFFECT_RANGE)
        for i,ent in ipairs(ents) do
            for component, _ in pairs(ent.components) do
                print("Component: ", component)
            end
        end

        -- send to position to the server
        -- print("Sending player position to server")
        SendData("Player position:   " .. x .. "   " .. y .. "   " .. z .. "\n")        
        
        -- print("Receiving from server")

        -- print(ReceiveData())

        -- print("\n\n\n")

        -- print("Time of day: ", GetTimeOfDay()) -- returns a string?
        -- print("Inventory: ", GetInventoryItems()) -- returns a table
        -- print("CraftableItems: ", CraftableItems()) -- returns a table
        -- print("CanCraft(axe): ", CanCraft("axe")) -- returns bool
        -- print("NearbyEntities: ", GetNearbyEntities()) -- returns a table

        -- print("\n\n\n")

        Craft("axe")

    end)

    -- debugging help
    -- GLOBAL.require("consolecommands")
    -- GLOBAL.c_select(player)
end
AddSimPostInit(PreparePlayerCharacter)

