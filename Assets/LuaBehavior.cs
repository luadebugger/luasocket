using UnityEngine;
using System.Collections;

public class LuaBehavior : MonoBehaviour {

    LuaScriptMgr m_LuaMgr;
	// Use this for initialization
	void Start () {
	    //打开lua state
        m_LuaMgr = new LuaScriptMgr();
        m_LuaMgr.DoFile("System/Wrap.lua");
        m_LuaMgr.DoFile("Common/library.lua");
        m_LuaMgr.DoFile("Common/debugger.lua");
        m_LuaMgr.DoFile("main.lua");
	}
	
	// Update is called once per frame
	void Update () {
	
	}
}
