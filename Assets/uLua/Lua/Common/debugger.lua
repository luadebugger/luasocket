debugger = {}
debugger.funcbreakpoints = {}
debugger.linebreakpoints = {}
debugger.luacode = {}
debugger.command = {}
debugger.idgenerator = 0

function debugger.generatebreakpointid()
    debugger.idgenerator = debugger.idgenerator + 1
    return debugger.idgenerator
end

function debugger.addfuncbreak(fun)
    assert(type(fun) == "function", "must be a function")

    local id = debugger.generatebreakpointid()
    debugger.funcbreakpoints[fun] = id

    print(string.format("id: %d, function break point added: ", id), fun)

    debugger.setnormalmode()
end

function debugger.delfuncbreak(fun)
    assert(type(fun) == "function", "must be a function")

    if debugger.funcbreakpoints[fun] then
        local id = debugger.funcbreakpoints[fun]
        debugger.funcbreakpoints[fun] = nil
        print(string.format("id: %d, function break point deleted", id), fun)
    else
        print("no break point:", fun)
    end
end

function debugger.printfuncbreak()
    for fun, id in pairs(debugger.funcbreakpoints) do
        print(string.format("id: %d ", id), fun)
    end
end

function debugger.addlinebreak(file, line)
    if not debugger.linebreakpoints[file] then
        debugger.linebreakpoints[file] = {}
    end

    local id = debugger.generatebreakpointid()
    debugger.linebreakpoints[file][line] = id

    print(string.format("id: %d, line break point [%s]:%d added", id, string.sub(file, 2), line))

    debugger.setnormalmode()
end

function debugger.dellinebreak(file, line)
    if debugger.linebreakpoints[file] and debugger.linebreakpoints[file][line] then
        local id = debugger.linebreakpoints[file][line]
        debugger.linebreakpoints[file][line] = nil
        print(string.format("id: %d, line break point [%s]:%d deleted", id, file, line))
        return
    end

    print(string.format("no break point: [%s]:%d", file, line))
end

function debugger.printlinebreak()
    for file, lines in pairs(debugger.linebreakpoints) do
        for line, id in pairs(lines) do
            print(string.format("id: %d [%s]:%d", id, file, line))
        end
    end
end

function debugger.clearbreakpoint()
    debugger.funcbreakpoints = {}
    debugger.linebreakpoints = {}
end

function debugger.loadluacode(filename)
    local file, errormsg = io.open(LuaHelper.GetLuaPath() .. '/' .. filename)
    if not file then
        print(errormsg .. ", filename:" .. filename)
        return
    end

    local code = {}
    for line in file:lines() do
        table.insert(code, line)
    end

    debugger.luacode[filename] = code
    file:close()
end

function debugger.printluacode(file, line, ll)
    --print("debugger.printluacode>>>>>>>>>>>>>>>>>>>>>>>>")
    local fileContent = "breakpoint>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>\nCode Source:\n\n"
    if not debugger.luacode[file] then
        debugger.loadluacode(file)
    end

    local code = debugger.luacode[file]
    if not code then
        return fileContent
    end

    local beginline = (line - ll) < 1 and 1 or (line - ll)
    local endline = (line + ll) > #code and #code or (line + ll)

    for i = beginline, endline do
        local tips = ""
        if line == i then
            tips = "\t<<<<<<<<<<<<<<<<<< breakpoint here!"
        end
        fileContent = fileContent .. string.format("line:%d\t %s%s\n", i, code[i], tips)
    end

    return fileContent
end

debugger.crthookfunc = nil

function debugger.setnormalmode()
    debugger.crthookfunc = debugger.setnormalmode
    debug.sethook(debugger.normalmodehook, "cl")
end

function debugger.setstepinmode()
    debugger.crthookfunc = debugger.setstepinmode
    debug.sethook(debugger.stepinmodehook, "l")
end

function debugger.setstepovermode()
    debugger.crthookfunc = debugger.setstepovermode
    debug.sethook(debugger.stepovermodehook, "crl")
end

function debugger.setnextlinemode()
    debugger.crthookfunc = debugger.setnextlinemode
    debug.sethook(debugger.nextlinemodehook, "crl")
end

function debugger.checkbreakline(stacklevel, onbreak)
    --print("debugger.checkbreakline>>>>>>>>>>>>>>>>>>>>>")
    local info = debug.getinfo(stacklevel, "Sl")

    -- print(info.source..", "..info.short_src..", "..", "..info.linedefined..", "..info.lastlinedefined..", "..info.what)
    -- print(info.currentline)

    local _source = string.gsub(info.source, "\\", "/")
    local arrSource = Library:SplitStr(_source, "/")

    for file, lines in pairs(debugger.linebreakpoints) do
        local fileSource = string.gsub(file, "\\", "/")
        fileSource = Library:SplitStr(fileSource, "/")

        if fileSource[#fileSource] == #arrSource[#arrSource] then
            for line, _ in pairs(lines) do
                if line == info.currentline then
                    if onbreak then onbreak() end
                    debugger.breakthepoint(stacklevel + 1)
                    -- LuaHelper.Log(debugger.printline({[2]= 3}, stacklevel+1) .. "\n" .. tracebackex(stacklevel+1) .. '\n')
                    -- debug.sethook()
                end
            end
        end
    end
end

function debugger.checkbreakfunc(stacklevel, onbreak)
    local info = debug.getinfo(stacklevel, "Slf")

    -- print(info.source..", "..info.short_src..", "..", "..info.linedefined..", "..info.lastlinedefined..", "..info.what)
    -- print(info.currentline)
    -- print(tostring(info.func))

    for fun, _ in pairs(debugger.funcbreakpoints) do
        if fun == info.func then
            if onbreak then onbreak() end
            -- enter step in mode
            --debugger.setstepinmode()
            print(tracebackex(stacklevel+1))
            debug.sethook()
        end
    end
end

function debugger.normalmodehook(event, line)
    --LuaHelper.LogWarning("debugger.normalmodehook>>>>>>>>>>>>>>>>>")
    -- print(debug.traceback())
    -- Library:PrintTB(debug.getinfo(2))
    -- --LuaHelper.LogWarning(event)
    -- --LuaHelper.LogWarning(tostring(line))

    if event == "line" then
        debugger.checkbreakline(3)
    elseif event == "call" then
        debugger.checkbreakfunc(3)
    end
end

function debugger.stepinmodehook(event, line)
    --YLMobile.LuaHelper.StopLuaSysMgr()
    -- print("debugger.stepinmodehook>>>>>>>>>>>>>>>>>")
    -- print(event)
    -- print(tostring(line))

    debugger.breakthepoint(3)
end

function debugger.stepovermodehook(event, line)
    --YLMobile.LuaHelper.StopLuaSysMgr()

    -- print("debugger.stepovermodehook>>>>>>>>>>>>>>>>>")
    -- print(event)
    -- print(tostring(line))

    local onbreak = function()
        debugger.stepoverbreak = nil
        debugger.callfunctimes = nil
    end

    if event == "line" then
        debugger.checkbreakline(3, onbreak)

        if debugger.stepoverbreak and debugger.callfunctimes == 0 then
            onbreak()
            debugger.breakthepoint(3)
        end
    elseif event == "call" then
        debugger.checkbreakfunc(3, onbreak)

        if debugger.stepoverbreak then
            debugger.callfunctimes = debugger.callfunctimes + 1
        end
    elseif event == "return" then
        if debugger.stepoverbreak then
            debugger.callfunctimes = debugger.callfunctimes - 1
        end
    end
end

function debugger.nextlinemodehook(event, line)
    --YLMobile.LuaHelper.StopLuaSysMgr()

    -- print("debugger.nextlinemodehook>>>>>>>>>>>>>>>>>")
    -- print(event)
    -- print(tostring(line))

    local onbreak = function()
        debugger.nextlinebreak = nil
        debugger.callfunctimes = nil
    end

    if event == "line" then
        debugger.checkbreakline(3, onbreak)

        if debugger.nextlinebreak and debugger.callfunctimes <= 1 then
            onbreak()
            debugger.breakthepoint(3)
        end
    elseif event == "call" then
        debugger.checkbreakfunc(3, onbreak)

        if debugger.nextlinebreak then
            debugger.callfunctimes = debugger.callfunctimes + 1
        end
    elseif event == "return" then
        if debugger.nextlinebreak then
            debugger.callfunctimes = debugger.callfunctimes - 1
        end
    end
end

function debugger.breakthepoint(stacklevel, notprintcode)
    if not notprintcode then
        -- print currentline code
        local info = debug.getinfo(stacklevel, "Sl")
        print(debugger.printluacode(string.sub(info.source, 1), info.currentline, 0))
    end

    -- get command input
    print("debugger >")
    --local l = io.read("*l")
    --进入协程, 每隔1S读取一次iostream.如果有内容,则返回
    debug.sethook()
    local l = getIOInput()
    debugger.crthookfunc()

    print(tostring(l))
    
    if l == nil then
        return;
    end

    --local l = debugger.io
    local command = debugger.parsecommand(l)
    debugger.execute(command, stacklevel + 1)
end

function debugger.parsecommand(commandline)
    local t = {}
    for w in string.gmatch(commandline, "[^ ]+") do
        table.insert(t, w)
    end

    return t
end

function debugger.execute(command, stacklevel)
    local executor = debugger.command[command[1]]
    if not executor then
        debugger.errorcmd()
        debugger.breakthepoint(stacklevel + 1)
    else
        executor(command, stacklevel + 1)
    end
end

function debugger.breakline(command, stacklevel)
    local iscurrentfile = tonumber(command[2]) and true or false
    for i = 2, #command do
        local errorcmd = false
        if iscurrentfile and not tonumber(command[i]) then
            errorcmd = true
        end

        if not iscurrentfile and math.fmod(i, 2) == 1 and not tonumber(command[i]) then
            errorcmd = true
        end

        if errorcmd then
            return debugger.errorcmd()
        end
    end

    if iscurrentfile then
        local info = debug.getinfo(stacklevel, "S")
        for i = 2, #command do
            local line = tonumber(command[i])
            debugger.addlinebreak(info.source, line)
        end
    else
        for i = 2, #command, 2 do
            local file = "@" .. command[i]
            local line = tonumber(command[i + 1])
            debugger.addlinebreak(file, line)
        end
    end
end

function debugger.breakfunc(command, stacklevel)
    for i = 2, #command do
        local chunk = loadstring(string.format("return %s", command[i]))
        local func = chunk and chunk() or nil

        if type(func) == "function" then
            debugger.addfuncbreak(func)
            print(string.format("break function: %s", command[i]))
        else
            print(string.format("no function %s, can't break it", command[i]))
        end
    end
end

function debugger.breakpoint(command, stacklevel)
    if #command < 2 then
        debugger.errorcmd()
        return debugger.breakthepoint(stacklevel + 1)
    end

    local isbreakfunc = tonumber(command[2]) and 0 or 1
    isbreakfunc = (command[3] and tonumber(command[3])) and 0 or isbreakfunc

    if isbreakfunc == 1 then
        debugger.breakfunc(command, stacklevel + 1)
    else
        debugger.breakline(command, stacklevel + 1)
    end

    debugger.breakthepoint(stacklevel + 1, true)
end

function debugger.continue(command, stacklevel)
    debugger.setnormalmode()
    --YLMobile.LuaHelper.RunLuaSysMgr()
end

function debugger.nextline(command, stacklevel)
    debugger.nextlinebreak = true
    debugger.callfunctimes = 1
    debugger.setnextlinemode()
end

function debugger.stepin(command, stacklevel)
    debugger.setstepinmode()
end

function debugger.stepover(command, stacklevel)
    debugger.stepoverbreak = true
    debugger.callfunctimes = 1
    debugger.setstepovermode()
end

function debugger.printline(command, stacklevel)
    local info = debug.getinfo(stacklevel, "Sl")
    local lines = tonumber(command[2]) or 2
    return debugger.printluacode(string.sub(info.source, 1), info.currentline, lines)

    --debugger.breakthepoint(stacklevel + 1, true)
end

function debugger.getlocalvaluetable(stacklevel)
    local j = 1
    local t = {}
    while true do
        local n, v = debug.getlocal(stacklevel, j)
        if not n then break end

        t[n] = v
        j = j + 1
    end

    return t
end

function debugger.setlocalvaluetable(stacklevel, newlocals)
    local j = 1
    while true do
        local n, v = debug.getlocal(stacklevel, j)
        if not n then break end

        v = newlocals[n]
        assert(debug.setlocal(stacklevel, j, v) == n)
        j = j + 1
    end
end

function debugger.getupvaluetable(stacklevel)
    local f = debug.getinfo(stacklevel, "f").func
    local j = 1
    local t = {}
    while true do
        local n, v = debug.getupvalue(f, j)
        if not n then break end

        t[n] = v
        j = j + 1
    end

    return t
end

function debugger.setupvaluetable(stacklevel, newupvalues)
    local f = debug.getinfo(stacklevel, "f").func
    local j = 1
    while true do
        local n, v = debug.getupvalue(f, j)
        if not n then break end

        v = newupvalues[n]
        assert(debug.setupvalue(f, j, v) == n)
        j = j + 1
    end
end

function debugger.getfuncenvtable(stacklevel)
    local fenv = getfenv(stacklevel)
    local upvaluetable = debugger.getupvaluetable(stacklevel + 1)
    setmetatable(upvaluetable, { __index = function(t, k) return fenv[k] end })

    local localvaluetable = debugger.getlocalvaluetable(stacklevel + 1)
    setmetatable(localvaluetable, { __index = function(t, k) return upvaluetable[k] end,
                                    __newindex = function() assert(false) end })
    return localvaluetable, upvaluetable, fenv
end

function debugger.printvar(command, stacklevel)
    local getvalue = function(name, stacklevel)
        local chunk = loadstring(string.format("return %s", name))
        if chunk then
            setfenv(chunk, debugger.getfuncenvtable(stacklevel + 1))
            local value = { pcall(chunk) }
            if value[1] then
                table.remove(value, 1)
                if #value ~= 0 then
                    return name, value
                end
            end
        end

        return name, nil
    end

    for i = 2, #command do
        local n, v = getvalue(command[i], stacklevel + 1)
        if type(v) == "table" then
            print(n, unpack(v))
        else
            print(n, v)
        end
    end

    debugger.breakthepoint(stacklevel + 1, true)
end

function debugger.traceback(command, stacklevel)
    local level = stacklevel
    while true do
        local info = debug.getinfo(level, "Sl")
        if not info then break end

        print(string.format("[%s]:%d", info.short_src, info.currentline))
        level = level + 1
    end

    debugger.breakthepoint(stacklevel + 1, true)
end

function debugger.printbreakpoint(command, stacklevel)
    debugger.printfuncbreak()
    debugger.printlinebreak()
    debugger.breakthepoint(stacklevel + 1, true)
end

function debugger.clearbreak(command, stacklevel)
    debugger.clearbreakpoint()
    print("clear all break points ok")
    debugger.breakthepoint(stacklevel + 1, true)
end

function debugger.deletebreak(command, stacklevel)
    local getfuncbreakpoint = function(breakpointid)
        for func, id in pairs(debugger.funcbreakpoints) do
            if id == breakpointid then
                return func
            end
        end
    end

    local getlinebreakpoint = function(breakpointid)
        for file, lines in pairs(debugger.linebreakpoints) do
            for line, id in pairs(lines) do
                if id == breakpointid then
                    return file, line
                end
            end
        end
    end

    for i = 2, #command do
        local id = tonumber(command[i])
        if id then
            local func = getfuncbreakpoint(id)
            if func then
                debugger.delfuncbreak(func)
            else
                local file, line = getlinebreakpoint(id)
                if file and line then
                    debugger.dellinebreak(file, line)
                end
            end
        end
    end

    debugger.breakthepoint(stacklevel + 1, true)
end

function debugger.dosetvalue(command, stacklevel)
    local setcommand = string.format("%s = %s", command[2], command[3])
    local chunk = loadstring(setcommand)

    if chunk then
        local localvaluetable, upvaluetable = debugger.getfuncenvtable(stacklevel + 1)
        setfenv(chunk, localvaluetable)
        if pcall(chunk) then
            debugger.setlocalvaluetable(stacklevel + 1, localvaluetable)
            debugger.setupvaluetable(stacklevel + 1, upvaluetable)
            return setcommand .. " ok"
        end
    end

    return setcommand .. " failed"
end

function debugger.setvalue(command, stacklevel)
    if #command < 3 then
        debugger.errorcmd()
        return debugger.breakthepoint(stacklevel + 1)
    end

    local msg = debugger.dosetvalue(command, stacklevel + 1)
    print(msg)
    debugger.breakthepoint(stacklevel + 1, true)
end

function debugger.help(command, stacklevel)
    local str = [[
        b   --   break line. eg. b file line ...
                 current file: eg. b line line ...
                 function: eg. b func func ...
        c   --   continue
        n   --   next line
        s   --   step in
        o   --   step over
        l   --   print context lua code. eg. l [lines]
        p   --   print var value. eg. p var1 var2 ...
        t   --   traceback
        pb  --   print all break points
        cb  --   clear all break points
        db  --   delete break point. eg. db id1 id2 ...
        set --   set value. eg. set var value
        h   --   for help
    ]]

    print(str)
    debugger.breakthepoint(stacklevel + 1, true)
end

function debugger.errorcmd()
    print("error command, h for help")
end

debugger.command["b"] = debugger.breakpoint
debugger.command["c"] = debugger.continue
debugger.command["n"] = debugger.nextline
debugger.command["s"] = debugger.stepin
debugger.command["o"] = debugger.stepover
debugger.command["l"] = debugger.printline
debugger.command["p"] = debugger.printvar
debugger.command["t"] = debugger.traceback
debugger.command["pb"] = debugger.printbreakpoint
debugger.command["cb"] = debugger.clearbreak
debugger.command["db"] = debugger.deletebreak
debugger.command["set"] = debugger.setvalue
debugger.command["h"] = debugger.help

debugger.io = ""

function tracebackex(tracelevel)   
    local ret = ""   
    local level = tracelevel
    ret = ret .. "Stack Traceback And Local Value:\n\n" 
    while true do   
        --get stack info   
        local info = debug.getinfo(level, "Sln")   
        if not info then break end   
        if info.what == "C" then                -- C function   
            ret = ret .. tostring(level) .. "    C function\n" 
        else           -- Lua function   
            ret = ret .. string.format("    [%s]:%d in function `%s`\n", info.source, info.currentline, info.name or "")
        end   

        --默认输出第一层的局部变量
        if level == tracelevel then
            --get local vars   
            local i = 1 
            while true do   
                local name, value = debug.getlocal(level, i)   
                if not name then break end

                if name == "self" then
                    ret = ret .. "    " .. name .. " =\t\t" .. tostring(value) .. "\n" 
                else
                    ret = ret .. "    " .. name .. " =\t\t" .. tostringex(value, 3) .. "\n" 
                end
                
                i = i + 1 
            end
        end

        level = level + 1 
    end   
    return ret   
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

--_tb
g_strIoInput = nil

function coTryGetIOInput()
    while true do
        if g_strIoInput ~= nil then
            return g_strIoInput
        end
    end
end

function getIOInput()
    local thread = coroutine.create(coTryGetIOInput)
    local _ret, str = coroutine.resume(thread)
    return str
end

