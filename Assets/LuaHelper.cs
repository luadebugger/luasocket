using UnityEngine;
using System.Collections;
using YLMobile;

public class LuaHelper
{
    static public void Log(string str)
    {
        LineConsole.WriteToAll(str, LOGLEVEL.INFO);
    }

    static public void LogError(string str)
    {
        LineConsole.WriteToAll(str, LOGLEVEL.ERROR);
    }

    static public void LogWarning(string str)
    {
        LineConsole.WriteToAll(str, LOGLEVEL.WARNING);
    }

    static public string GetLuaPath()
    {
        return AppConst.uLuaPath + "/Lua/";
    }
}
