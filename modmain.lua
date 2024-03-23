

-- A Don't Starve mod that reads the current state of the game and outputs it to a file. This is a mod for the sCASP project.
local require = GLOBAL.require

local socket = require "socket"
local host = "localhost"
local port = 12345

local tcp = socket.tcp()

-- local client = socket.connect(host, port)




local Text = require "widgets/text"

require "constants"

print("sCASP reader modmain.lua loaded")

-- print player coordinates to logs

function SendData(data)
    print("Sending data to server")
    tcp:send(data)
end

function ReceiveData()
    print("Receiving data from server")
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

    player:DoPeriodicTask(1, function()
        local playerfacing = player.Transform:GetRotation()
		local x, y, z = player.Transform:GetWorldPosition()

        -- send to position to the server
        -- print("Sending player position to server")
        SendData("Player position:   " .. x .. "   " .. y .. "   " .. z .. "\n")        
        
        -- print("Receiving from server")

        -- print(ReceiveData())

        -- print("\n\n\n")

        print("Time of day: ", GetTimeOfDay()) -- returns a string?
        print("Inventory: ", GetInventoryItems()) -- returns a table
        print("CraftableItems: ", CraftableItems()) -- returns a table
        print("CanCraft(axe): ", CanCraft("axe")) -- returns bool

        print("\n\n\n")

    end)

    -- debugging help
    -- GLOBAL.require("consolecommands")
    -- GLOBAL.c_select(player)
end
AddSimPostInit(PreparePlayerCharacter)




