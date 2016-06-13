require "lua/server"
require "lua/client"
require "lua/Library"


function server()
	local socket = require("socket")
	SimpleServer:setupServer(socket)
	while true do
		SimpleServer:updateServer()
	end
end

function client()
	local socket = require("socket")
	SimpleClient:setupClient(socket)
	while true do
		SimpleClient:updateClient()
	end
end

print("main.lua loaded!")


callFunc = {}

function callFunc:print(str)
    print(str)
end
