-- local socket = require("socket")
-- host = "localhost"
-- port = 12345

-- print("Attempting connection to host '" ..host.. "' and port " ..port.. "...")
-- conn=socket.tcp()
-- c = assert(conn.connect(host, port))
-- print("Connected! Please type stuff (empty line to stop):")

-- A Don't Starve mod that reads the current state of the game and outputs it to a file. This is a mod for the sCASP project.
local require = GLOBAL.require

local Text = require "widgets/text"

require "constants"

print("sCASP reader modmain.lua loaded")

-- print player coordinates to logs

function PreparePlayerCharacter(player)
    local numbertext = Text(GLOBAL.BUTTONFONT, 24, "Test") --Make some text
    numbertext:SetColour(1,1,1,1) --Set the colour to white
    -- The player entity isn't quite ready to equip items yet, so wait one frame
    player:DoTaskInTime(0, function()

        

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
    end)

    -- debugging help
    -- GLOBAL.require("consolecommands")
    -- GLOBAL.c_select(player)
end
AddSimPostInit(PreparePlayerCharacter)




