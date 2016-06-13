require "server"
require "client"


function Server()
	local socket = require("socket")
	SimpleServer:setupServer(socket)--[[arg(s):sockt]]

	while true do
		SimpleServer:updateServer()
	end
end

function Client()
	local socket = require("socket")
	SimpleClient:setupClient(socket)
	while true do
		SimpleClient:updateClient()
	end
end

function tostringex(v, len)   
    if len == nil then len = 0 end   
    local pre = string.rep('    ', len)   
    local ret = ""   
    if type(v) == "table" then   
        if len > 5 then return"    { ... }" end

        local t = ""   
        for k, v1 in pairs(v) do   
	        t = t .. "\n    " .. pre .. tostring(k) .. ":" 
	        t = t .. tostringex(v1, len + 1)   
	   	end
        if t == "" then   
            ret = ret .. pre .. "{ }    (" .. tostring(v) .. ")" 
        else 
            if len > 0 then   
                ret = ret .. "    (" .. tostring(v) .. ")\n" 
            end   
        ret = ret .. pre .. "{" .. t .. "\n" .. pre .. "}" 
        end   
    else 
        ret = ret .. pre .. tostring(v) .. "    (" .. type(v) .. ")" 
    end   
    return ret   
end

print("main.lua loaded!")
