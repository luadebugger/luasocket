-- require "System/Wrap"
-- require "common/library"
-- require "common/debugger"
require "Logic/test"

-- function trace (event, line)
-- 	print(tracebackex())
-- 	-- Library:PrintTB(debug.getinfo(2))
-- 	-- local s = debug.getinfo(2).source
-- 	-- print(s .. ":" .. line)
-- 	--print(debug.traceback())
-- 	--Library:PrintTB(debug.getinfo(2))
-- 	--Library:PrintTB(debug.getlocal(2, 1))
-- 	-- debug.sethook()
-- 	-- local ret = ""
-- 	-- local i = 1  
-- 	-- while true do  
-- 	-- 	local name, value = debug.getlocal(2, i)  
-- 	-- 	if not name then
-- 	-- 		print(ret)
-- 	-- 		break 
-- 	-- 	end
-- 	-- 	ret = ret .. "        " .. name .. " =    " .. tostring(value) .. "\n"
-- 	-- 	i = i + 1  
-- 	-- end
-- end

-- -- Library:PrintTB(Launcher)

-- -- print(tostring(trace))

-- debug.sethook(trace, "l")

-- debugger.addfuncbreak(Launcher.test)

function startTest()
	Launcher:test(123, "test")
end

function startOn()
	startTest()
end

function main()
	startOn()
end

-- debugger.addlinebreak("Logic/test.lua", 8)
-- main()