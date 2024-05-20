local require = GLOBAL.require
local dofile = GLOBAL.dofile

local socket = require "socket"
dofile("scriptlibs/socket.lua")
dofile("scriptlibs/socket/http.lua")
local http = require "socket.http" 

local mime = require "mime"
local ltn12 = require "ltn12" 

-- Define the URL for the POST request
local url = "http://httpbin.org/post"

-- Perform the POST request
local res, code, response_headers, status = http.request("http://httpbin.org/post", "")

-- Print the response
print("Response Status: " .. (status or "unknown"))
print("Response Code: " .. (code or "unknown"))
print("Response Headers:")
if response_headers then
    for k, v in pairs(response_headers) do
        print(k .. ": " .. v)
    end
end

-- Print the response body in do periodic action
function PreparePlayerCharacter(player)
    player:DoPeriodicTask(1, function()
        print(res)
    end)
end

AddSimPostInit(PreparePlayerCharacter)