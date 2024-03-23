

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
        print("Sending player position to server")
        SendData("Player position:   " .. x .. "   " .. y .. "   " .. z .. "\n")        
        
        print("Receiving from server")

        print(ReceiveData())
        
        print("\n\n\n")
        

    end)

    -- debugging help
    -- GLOBAL.require("consolecommands")
    -- GLOBAL.c_select(player)
end
AddSimPostInit(PreparePlayerCharacter)




