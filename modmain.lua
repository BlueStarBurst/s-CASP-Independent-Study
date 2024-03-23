

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

function PreparePlayerCharacter(player)
    local numbertext = Text(GLOBAL.BUTTONFONT, 24, "Test") --Make some text
    numbertext:SetColour(1,1,1,1) --Set the colour to white
    -- The player entity isn't quite ready to equip items yet, so wait one frame
    player:DoTaskInTime(0, function()

        
        print("Attempting connection to host '" ..host.. "' and port " ..port.. "...")
        tcp:connect(host, port);
        tcp:settimeout(0.1)

        tcp:send("Player position:   " .. 0 .. "   " .. 0 .. "   " .. 0 .. "\n")

        numbertext:SetPosition(300,100) --Put text somewhere (starts at bottom left)

        

        -- Grab a reference to the home campfire
        local x, y, z = player.Transform:GetWorldPosition()

		print("Player position STARTREADER: ", x, y, z)

        

        -- local ents = TheSim:FindEntities(x, y, z, 20, {"campfire"})
        -- player.homefirepit = ents[1]

        -- -- Make sure the player is facing it
        -- player.Transform:SetRotation(player:GetAngleToPoint(Point(player.homefirepit.Transform:GetWorldPosition())))
    end)

    player:DoPeriodicTask(1, function()
        local playerfacing = player.Transform:GetRotation()
		local x, y, z = player.Transform:GetWorldPosition()
		print("Player position: ", x, y, z, "\nPlayer facing: ", playerfacing)
        numbertext:SetString( "Player position:   " .. x .. "   " .. y .. "   " .. z ) --Change the text on the fly
        -- GLOBAL.TheCamera:SetHeadingTarget(-playerfacing + 180)

        -- send to position to the server
        print("Sending player position to server")
        tcp:send("Player position:   " .. x .. "   " .. y .. "   " .. z .. "\n")
        
        
        print("Receiving from server")
        local s, status, partial = tcp:receive()
        print("Server:", s or partial)
        print("\n\n\n")
        

    end)

    -- debugging help
    -- GLOBAL.require("consolecommands")
    -- GLOBAL.c_select(player)
end
AddSimPostInit(PreparePlayerCharacter)




