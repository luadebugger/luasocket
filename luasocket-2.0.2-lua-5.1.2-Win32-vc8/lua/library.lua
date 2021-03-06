-- 脚本定义的常用基础函数和工具库函数

if Library then		-- 已经载入了
	return
end 

Library = {}

Library.TYPE_COUNT = 6	-- 类型数量

Library.TIME_AREATIME = 3600 * 8
Library.MAX_COPY_LAY = 7

-- LuaClass的MetaTable定义，用来访问基类的成员
Library._tbBaseClassMetatable = 
{
	__index	= function (tb, key)
		return rawget(tb, "_tbBase")[key]
	end
}

--这里并非实例化,而是类类型定义,但会自动调用__Construct方法
function Library:NewClass(tbBase, ...)
	local tbNew	= { _tbBase = tbBase }
	setmetatable(tbNew, self._tbBaseClassMetatable)
	local tbRoot = tbNew
	local tbConstruct = {}
	repeat										-- 寻找最基基类
		tbRoot = rawget(tbRoot, "_tbBase")
		--这里比较难以理解,这里并非实例化时的构造,而是类型定义时,用于数据初始化操作(一般用于有一些判断和计算的初始化)
		local fnConstruct = rawget(tbRoot, "construct")
		if (type(fnConstruct) == "function") then
			table.insert(tbConstruct, fnConstruct)		-- 放入构造函数栈
		end
	until (not rawget(tbRoot, "_tbBase"))
	for i = #tbConstruct, 1, -1 do
		local fnConstruct = tbConstruct[i]
		if fnConstruct and arg ~= nil then
			fnConstruct(tbNew, unpack(arg))			-- 从底向上调用构造函数
		end
	end
	return tbNew
end

-- 调用基类的函数
-- 如果派生类已经覆盖了基类的函数，可以使用此函数继续调用原先的函数
-- 正常情况可以直接使用子类table直接调用
function Library.CallBaseCalssFunction(tbInst, szFunctionName, ...)
	if not tbInst or not tbInst._tbBase then
		return false
	end

	local fn = tbInst._tbBase[szFunctionName]

	if fn then
		fn(tbInst, ...)
	end
	
	return true
end

--对table进行一层的复制
function Library:CopyTB1(tb)
	local tbCopy	= {}
	for k, v in pairs(tb) do
		tbCopy[k]	= v
	end
	return tbCopy
end

function Library:DeepCopyForTable(tbSrc, nMaxLay)
	nMaxLay = nMaxLay or self.MAX_COPY_LAY
	if (nMaxLay <= 0) then
		error("Error: DeepCopy拷贝的层数操作最大层，检查是否有循环引用")
		return
	end
	
	local tbRet = {}
	for k, v in pairs(tbSrc) do
		if (type(v) == "table") then
			tbRet[k] = self:DeepCopyForTable(v, nMaxLay-1)
		else
			tbRet[k] = v
		end
	end
	
	return tbRet
end

-- 最多拷贝N层Table，默认拷贝Library.MAX_COPY_LAY层，层次不可太深，防止递归拷贝
function Library:CopyTBN(tb, n)
	n = n or Library.MAX_COPY_LAY
	if (n == 0) then
		return
	end
	
	local tbRet = {}
	
	for k, v in pairs(tb) do
		if (type(v) == "table") then
			tbRet[k] = self:CopyTBN(v, n-1)
		else
			tbRet[k] = v
		end
	end
	return tbRet
end

function Library:PrintTB1(tbVar, szBlank)
	if (not szBlank) then
		szBlank = ""
	end

	local out = ""
	for k, v in pairs(tbVar) do
		out = out..(szBlank.."["..self:Value2String(k).."]	= "..tostring(v))..", \n"
	end

	LuaHelper.Log(out)--[[arg(s):format, ...]]
end

function Library:PrintTBN(tbVar, nLevel, szBlank, output)
	if (not szBlank) then
		szBlank = ""
	end

	local out = ""

	for k, v in pairs(tbVar) do
		if (type(v) == "table" and nLevel > 1) then
			out = out..(szBlank.."["..self:Value2String(k).."]	:")..", \n"
			out = out..self:PrintTBN(v, nLevel - 1, szBlank .. "  ", true)..", \n"
		else
			out = out..(szBlank.."["..self:Value2String(k).."]	= "..tostring(v))..", \n"
		end
	end

	if output == nil then
		LuaHelper.Log(out)
		return
	end

	return out
end

-- 打印所有数据，不包括function
function Library:PrintTBData(tbVar, szBlank, output)
	if (not szBlank) then
		szBlank = ""
	end

	local out = ""

	if tbVar == nil then
		out = szBlank .. "nil"
		return out
	end

	if type(tbVar) == "string" then
		return tbVar
	elseif type(tbVar) == "userdata" then
		return "*"
	end

	for key, v in pairs(tbVar) do
		local value = tbVar[key]
		local str
		local szType = type(v)
		if (type(key) == "number") then
			str = szBlank.."["..key.."]"
		elseif (type(key) == "userdata") then
			str = szBlank.."."..tostring(key)
		end

		if v == nil then

		--if (szType == "nil") then
			out = string.format("nil!!!key = %s, valueType = %s", tostring(k), type(v))..", \n"
		elseif (szType == "number") then
			out = out..(str.."\t= "..tbVar[key])..", \n"
		elseif (szType == "string") then
			out = out..(str..'\t= "'..tbVar[key]..'"')..", \n"
		elseif (szType == "function") then
		--	out = out..(str.."()")..", \n"
		elseif (szType == "table") then
			if (tbVar[key] == tbVar) then
				out = out..(str.."\t= {...}(self)")..", \n"
			else
				out = out..(str..":")..", \n"
				out = out..self:PrintTBData(tbVar[key], str, true)..", \n"
			end
		elseif (szType == "userdata") then

			-- if v.tostring == nil then
			-- 	out = out ..(str.."\t= "..v:tostring())..", \n"
			-- else
			-- 	out = out..(str.."*")..", \n"
			-- 	out = out..(tostring(v))..", \n"
			-- end

			local _, fi = string.find(key, "ull")

			if fi == 3 or v.tostring ~= nil then
				out = out ..(str.."\t= "..v:tostring())..", \n"
			else
				out = out..(str.."*")..", \n"
				out = out..(tostring(v))..", \n"
			end
		else
			out = out..(str.."\t= "..tostring(tbVar[key]))..", \n"
		end
	end

	if out == "" then
		out = "{}"
	end

	return out
end

-- 打印所有function地址
function Library:PrintTBFunc(tbVar, szBlank, bFull, output)
	if (not szBlank) then
		szBlank = ""
	end

	local out = ""
	
	for key, v in pairs(tbVar) do
		local value = tbVar[key]
		local str
		local szType = type(v)
		if (type(key) == "number") then
			str = szBlank.."["..key.."]"
		else
			str = szBlank.."."..key
		end
		if (szType == "nil") then
			--out = out..(str.."\t= nil")..", \n"
		elseif (szType == "number") then
			--out = out..(str.."\t= "..tbVar[key])..", \n"
		elseif (szType == "string") then
			--out = out..(str..'\t= "'..tbVar[key]..'"')..", \n"
		elseif (szType == "function") then
			out = out..(str.."()"..":"..tostring(v))..", \n"
		elseif (szType == "table") then
			if (tbVar[key] == tbVar) then
				--out = out..(str.."\t= {...}(self)")..", \n"
			elseif bFull == nil or bFull == true then
				out = out..(str..":")..", \n"
				out = out..self:PrintTBFunc(tbVar[key], str, bFull, true)..", \n"
			end
		elseif (szType == "userdata") then
			--out = out..(str.."*")..", \n"
		else
			out = out..(str.."\t= "..tostring(tbVar[key]))..", \n"
		end
	end	

	if output == nil then
		LuaHelper.Log(out)
		return
	end

	return out
end

function Library:PrintTBNilValue(tbVar)
	if not tbVar then
		return
	end

	local out = ""

	for k, v in pairs(tbVar) do
		out = out..tostring(k).."="..tostring(v)
		if not v then
			out = out..string.format("key = %s, valueType = %s", tostring(k), type(v))..", \n"
		end
	end

	LuaHelper.Log(out)
end

function Library:PrintTB(tbVar, szBlank, bRecursion)
	if (not szBlank) then
		szBlank = ""
	end

	if type(tbVar) ~= "table" then
		LuaHelper.Log(" Library:PrintTB Err type. value:"..tostring(tbVar));
		return;
	end

	local out = ""
	
	for key, v in pairs(tbVar) do
		local value = tbVar[key]
		local str
		local szType = type(v)
		if (type(key) == "number") then
			str = szBlank.."["..key.."]"
		else
			str = szBlank.."."..key
		end

		if not v then
		--if (szType == "nil") then
			out = string.format("key = %s, valueType = %s", tostring(k), type(v))..", \n"
		elseif (szType == "number") then
			out = out..(str.."\t= "..tbVar[key])..", \n"
		elseif (szType == "string") then
			out = out..(str..'\t= "'..tbVar[key]..'"')..", \n"
		elseif (szType == "function") then
			out = out..(str.."()=")..tostring(v)..", \n"
		elseif (szType == "table") then
			if (tbVar[key] == tbVar) then
				out = out..(str.."\t= {...}(self)")..", \n"
			else
				out = out..(str..":")..", \n"
				out = out..self:PrintTB(tbVar[key], str, true)..", \n"
			end
		elseif (szType == "userdata") then
			local _, fi = string.find(key, "ull")

			if fi == 3 then
				out = out ..(str.."\t= "..v:tostring())..", \n"
			else
				out = out..(str.."*")..", \n"
				out = out..(tostring(v))..", \n"
			end
		else
			out = out..(str.."\t= "..tostring(tbVar[key]))..", \n"
		end
	end

	if bRecursion == nil then
		LuaHelper.Log("PrintTB:\n"..out)
		return
	end

	return out
end

function Library:CountTB(tbVar)
	local nCount = 0
	for _, _ in pairs(tbVar) do
		nCount	= nCount + 1
	end
	return nCount
end

function Library:StrValue2String(szVal)
	szVal	= string.gsub(szVal, "\\", "\\\\")
	szVal	= string.gsub(szVal, '"', '\\"')
	szVal	= string.gsub(szVal, "\n", "\\n")
	szVal	= string.gsub(szVal, "\r", "\\r")
	--szVal	= string.format("%q", szVal)
	return '"'..szVal..'"'
end

function Library:Value2String(var, szBlank)
	local szType	= type(var)
	if (szType == "nil") then
		return "nil"
	elseif (szType == "number") then
		return tostring(var)
	elseif (szType == "string") then
		return self:StrValue2String(var)
	elseif (szType == "function") then
		local szCode	= string.dump(var)
		local arByte	= {string.byte(szCode, i, #szCode)}
		szCode	= ""
		for i = 1, #arByte do
			szCode	= szCode..'\\'..arByte[i]
		end
		return 'loadstring("' .. szCode .. '")'
	elseif (szType == "table") then
		if not szBlank then
			szBlank	= ""
		end
		local szTbBlank	= szBlank .. "  "
		local szCode	= ""
		for k, v in pairs(var) do
			local szPair	= szTbBlank.."[" .. self:Value2String(k) .. "]	= " .. self:Value2String(v, szTbBlank) .. ",\n"
			szCode	= szCode .. szPair
		end
		if (szCode == "") then
			return "{}"
		else
			return "\n"..szBlank.."{\n"..szCode..szBlank.."}"
		end
	else	--if (szType == "userdata") then
		return '"' .. tostring(var) .. '"'
	end
end

function Library:String2Value(szVal)
	return assert(loadstring("return "..szVal))()
end

function Library:SplitStr(szStrConcat, szSep)
	if (not szSep) then
		szSep = ","
	end
	local tbStrElem = {}
	local nSepLen = #szSep
	local nStart = 1
	local nAt = string.find(szStrConcat, szSep)
	while nAt do
		tbStrElem[#tbStrElem+1] = string.sub(szStrConcat, nStart, nAt - 1)
		nStart = nAt + nSepLen
		nAt = string.find(szStrConcat, szSep, nStart)
	end
	tbStrElem[#tbStrElem+1] = string.sub(szStrConcat, nStart)
	return tbStrElem
end

-- 检查一个Table是否另一个Table的派生Table
function Library:IsDerived(tb, tbBase)
	if (not tb) or (not tbBase) then
		return	0
	end
	repeat
		local pBase = rawget(tb, "_tbBase")
		if (pBase == tbBase) then
			return	1
		end
		tbThis = pBase
	until (not tb)
	return	0
end

function Library:DeepCopy(object)

    local lookup_table = {}

    local function _Copy(_object)

        if type(_object) ~= "table" then
            return _object
        elseif lookup_table[_object] then
            return lookup_table[_object]
        end

        local new_table = {}
        lookup_table[object] = new_table

        for index, value in pairs(_object) do
            new_table[_Copy(index)] = _Copy(_object[index])
        end

        return setmetatable(new_table, getmetatable(_object))
    end

    return _Copy(object)
end


--仅支持 table:func 函数调用，最多支持5个参数(self不计算在内)
function Library.CallTableFunc(_tb, strFuncName, ...)

	--LuaHelper.Log("=====================Library.CallTableFunc()--[[arg(s):_tb, strFuncName, ...]]")
	local argLen = 0
	local arg = {...}

	if arg ~= nil then
		argLen = table.getn(arg)
	end

	local ret = nil

	local func = _tb[strFuncName]

	if func ~= nil then
	    if argLen == 0 then
	    	ret = func(_tb)
	    elseif argLen == 1 then
	    	ret = func(_tb, arg[1])	
	    elseif argLen == 2 then
	    	ret = func(_tb, arg[1], arg[2])	
	    elseif argLen == 3 then
	    	ret = func(_tb, arg[1], arg[2], arg[3])	
	    elseif argLen == 4 then
	    	ret = func(_tb, arg[1], arg[2], arg[3], arg[4])	
	    elseif argLen == 5 then
	    	ret = func(_tb, arg[1], arg[2], arg[3], arg[4], arg[5])
	    else
	    	assert(false)
	    end
	end

    return ret
end

function Library:FindChild(gameobject, strPathName, bThrowErroIfNotFound)
	if bThrowErroIfNotFound == nil then
		bThrowErroIfNotFound = true
	end

	return YLMobile.LuaHelper.FindChild(gameobject, strPathName, bThrowErroIfNotFound)
end

-- --字符串分割函数
-- --传入字符串和分隔符，返回分割后的table
-- function string.split(str, delimiter)
-- 	if str==nil or str=='' or delimiter==nil then
-- 		return nil
-- 	end
	
--     local result = {}
--     for match in (str..delimiter):gmatch("(.-)"..delimiter) do
--         table.insert(result, match)
--     end
--     return result
-- end

-- --字符串按位分割函数
-- --传入字符串，返回分割后的table，必须为字母、数字，否则返回nil
-- function string.gsplit(str)
-- 	local str_tb = {}
-- 	if string.len(str) ~= 0 then
-- 		for i=1,string.len(str) do
-- 			new_str= string.sub(str,i,i)			
-- 			if (string.byte(new_str) >=48 and string.byte(new_str) <=57) or (string.byte(new_str)>=65 and string.byte(new_str)<=90) or (string.byte(new_str)>=97 and string.byte(new_str)<=122) then 				
-- 				table.insert(str_tb,string.sub(str,i,i))				
-- 			else
-- 				return nil
-- 			end
-- 		end
-- 		return str_tb
-- 	else
-- 		return nil
-- 	end
-- end

--=======================================
-- table:  _tbBaseStructMetatableDebug
-- author:    hopli
-- created:   2015/10/16
-- descrip:   类c++的类型检查，访问、修改时会检查table里面的字段拼写.相当于table里面的字段名为常量，字段值为变量
--			 若在子类中有_tbName(字符串类型)变量名，则assert提示会提示具体的table名
--=======================================
Library._tbBaseStructMetatableDebug =
{
	__index	= function (tb, key)

		local bFilterPass = false;
		for _,v in pairs(Library._tbBaseStructMetatableDebug.tbArrVar) do

			if tostring(key) == v then
				bFilterPass = true;
			end
		end

		if not bFilterPass then

			local tbName = rawget(tb,"_tbName");
			if tbName == nil or type(tbName) ~= "string" then
				tbName = "table";
			end

			local err = key..' Not Found In '..tbName;
	    	assert(false, err);

	    	return rawget(tb,key);

		end 	

		return Library._tbBaseStructMetatableDebug[tostring(key)];

	end;

	__newindex = function(tb, key, value)

		local bFilterPass = false;
		for _,v in pairs(Library._tbBaseStructMetatableDebug.tbArrVar) do

			if tostring(key) == v then
				bFilterPass = true;
			end
		end

		if not bFilterPass then

			local tbName = rawget(tb,"_tbName");
			if tbName == nil or type(tbName) ~= "string" then
				tbName = "table";
			end

			local err = key..' Not Found In '..tbName;
			assert(false, err);
		end

	    rawset(tb, key, value);

	end;


	DeepCopy = function (self)
		-- body
		local tbNew = Library:DeepCopyForTable(self, nil);
		setmetatable(tbNew,getmetatable(self));					--由于DeepCopyForTable没有setmetatable，这里仅对表层进行设置
		return tbNew;
	end;

	Copy = function (self)
		-- body
		local tbNew = Library:CopyTB1(self);
		setmetatable(tbNew,getmetatable(self));					--由于CopyTB1没有setmetatable，这里仅对表层进行设置
		return tbNew;
	end;

	New = function (self)
		-- body
		return self:DeepCopy();
	end;


	tbArrVar = {"DeepCopy","Copy","_tbName","New"};	--元表定义的变量、函数,主要用于assert过滤

--	_tbName = "table";

}


--=======================================
-- table:  _tbBaseStructMetatableRelease
-- author:    hopli
-- created:   2015/10/16
-- descrip:   _tbBaseStructMetatableDebug的release版本，不做检查
--=======================================
Library._tbBaseStructMetatableRelease =
{

	__index	= function (tb, key)

		return Library._tbBaseStructMetatableDebug[tostring(key)];

	end;
	
	DeepCopy = function (self)
		-- body
		local tbNew = Library:DeepCopyForTable(self, nil);
		setmetatable(tbNew,getmetatable(self));					--由于DeepCopyForTable没有setmetatable，这里仅对表层进行设置
		return tbNew;
	end;

	Copy = function (self)
		-- body
		local tbNew = Library:CopyTB1(self);
		setmetatable(tbNew,getmetatable(self));					--由于CopyTB1没有setmetatable，这里仅对表层进行设置
		return tbNew;
	end;

	New = function (self)
		-- body
		return self:DeepCopy();
	end;


	tbArrVar = {"DeepCopy","Copy","New"};	--元表定义的变量、函数

--	_tbName = "table";

}
