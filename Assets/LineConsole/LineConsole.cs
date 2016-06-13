using UnityEngine;
using System.Collections;
using UnityEngine.UI;
using System.Collections.Generic;
#if UNITY_EDITOR
using com.ootii.Utilities.Debug;
#endif

namespace YLMobile
{
    public enum LOGLEVEL
    {
        NONE = -1,
        INFO = 0,
        FLOW,
        NET,
        WARNING,
        ERROR,
    }

    public class LineConsole : MonoBehaviour
    {
        static public LineConsole m_Instance;
        static public YLMobile.LineConsole Instance
        {
            get 
            {
                if (m_Instance == null)
                {
                    GameObject obj = GameObject.Find("LineConsole");

                    if (obj != null)
                    {
                        m_Instance = obj.GetComponent<LineConsole>();
                    }

                    return m_Instance;
                }
                return m_Instance; 
            }

            set 
            { 
                m_Instance = value;
            }
        }
        
        public GameObject m_Panel;

        public Button m_Send;
        public Button m_Min;
        public Button m_Max;
        public Button m_WriteToFile;

        public Button m_OpenFile;
        public Button m_Clear;

        public Button m_AllTraceBack;

        public Text m_out;
        public InputField m_input;

        List<string> m_listConsole;

        public Button ButtonReloadSystem;
        public Button ButtonSwitchShowPanel;
        public Button ButtonDoString;
        public Button ButtonDoFile;

        void Awake()
        {
#if UNITY_EDITOR
            Log.FilePath = "./LuaLog.txt";
#endif
            m_Panel.SetActive(false);
            m_Max.gameObject.SetActive(true);

            m_out.text = "Lua命令行输入, 更多详细内容请看 LineConsole, 如有更好建议请联系phoenixgou@tencent.com\n\n";

            m_input.characterLimit = 1000;

            m_listConsole = new List<string>();
            m_listConsole.Clear();
            m_Send.onClick.AddListener(onClickSend);

            m_Min.onClick.AddListener(onClickMin);
            m_Max.onClick.AddListener(onClickMax);
            m_WriteToFile.onClick.AddListener(onClickWriteToFile);

            ButtonReloadSystem.onClick.AddListener(onClickReloadSys);
            ButtonSwitchShowPanel.onClick.AddListener(onClickSwitchShowPanel);
            ButtonDoString.onClick.AddListener(onClickDoString);
            ButtonDoFile.onClick.AddListener(onClickDoFile);

            m_Clear.onClick.AddListener(onClickClear);
            m_OpenFile.onClick.AddListener(onClickOpenFile);

            m_AllTraceBack.onClick.AddListener(onClickAllTraceBack);

        }

        public void onClickClear()
        {
            m_out.text = "";
        }

        public void onClickOpenFile()
        {
            //OpenFileDialog ofd = new OpenFileDialog();
            //ofd.InitialDirectory = "file://" + UnityEngine.Application.dataPath;
        }

        public void onClickAllTraceBack()
        {
            string cmd = "Logger.printTrace = true";
            LuaScriptMgr.Instance.DoString(cmd);
            m_out.text += "\n" + cmd;
        }

        public void onClickDoFile()
        {
            m_input.text = "f";
        }

        public void onClickDoString()
        {
            m_input.text = "s";
        }

        public void onClickReloadSys()
        {
            m_input.text = "f logic/Module/";
        }

        public void onClickSwitchShowPanel()
        {
            m_input.text = "s GetPanelByUIID(YLMobile_UUID.):CloseSelf()";
        }

        void Start()
        {
            
        }

        void Update()
        {

        }

        public void onClickWriteToFile()
        {

        }

        public void onClickMax()
        {
            m_Panel.SetActive(true);
            m_Max.gameObject.SetActive(false);
        }

        public void onClickMin()
        {
            m_Panel.SetActive(false);
            m_Max.gameObject.SetActive(true);
        }

        public string sendToConsoleAtom(string strContent)
        {
            m_out.text += "\n" + strContent;

            return strContent;
        }

        public void onClickSend()
        {
            string str = m_input.text;
            m_listConsole.Add(str);

            //如果带有lb:前缀,则解析命名
            string strCMD = str;
            string[] arrCMD = strCMD.Split(' ');

            switch (arrCMD[0])
            {
                case "f":
                    {
                        if (arrCMD.Length > 1 && arrCMD[1] != "")
                        {
                            LuaScriptMgr.Instance.DoFile(arrCMD[1]);
                        }
                    }
                    break;
                case "s":
                    {
                        if (arrCMD.Length > 1 && arrCMD[1] != "")
                        {
                            //if (LuaScriptMgr.Instance.GetLuaTable("debugger") != null)
                            //{
                            //    LuaScriptMgr.Instance.DoString("debugger.io = \"" + arrCMD[1] + "\"");
                            //}

                            LuaScriptMgr.Instance.DoString(arrCMD[1]);
                        }
                    }
                    break;

                case "p":
                    {
                        if (arrCMD.Length > 1 && arrCMD[1] != "")
                        {
                            if (arrCMD.Length > 2)
                            {
                                LuaScriptMgr.Instance.DoString("debugger.addlinebreak(\"" + arrCMD[1] + "\", " + arrCMD[2] + ")");
                            }
                            else 
                            {
                                LuaScriptMgr.Instance.DoString("debugger.addfuncbreak(" + arrCMD[1] + ")");
                            }
                            //LuaScriptMgr.Instance.DoString("Library:PrintTBData(" + arrCMD[1] + ")");
                        }
                    }
                    break;
                //case "ldpa":
                //    {
                //        if (arrCMD.Length > 1 && arrCMD[1] != "")
                //        {
                //            LuaScriptMgr.Instance.DoString("Library:PrintTB(" + arrCMD[1] + ", \"" + arrCMD[1] + "\")");
                //        }
                //    }
                //    break;

                //case "ldpf":
                //    {
                //        if (arrCMD.Length > 1 && arrCMD[1] != "")
                //        {
                //            LuaScriptMgr.Instance.DoString("Library:PrintTBFunc(" + arrCMD[1] + ", \"" + arrCMD[1] + "\")");
                //        }
                //    }
                //    break;

                ////下面是调试,用Luahook来实现,目前暂时不处理
                //case "f11":
                //    break;
                //case "f10":
                //    break;
                //case "f5":
                //    break;
                //case "f9":
                //    break;
            }

            str = ">>" + str;
            sendToConsoleAtom(str);

            LineConsole.WriteToUnityDebugConsole(str, LOGLEVEL.NONE);
#if UNITY_EDITOR
            Log.FileWrite(str);
#endif

           // ((IChatSys)YLMobile.Framework.GameKernel.Get(EServiceType.ChatSys)).OnSendSpeak((uint)EnmChatChannelType.eChatChannelType_Near, 0, "", m_input.text);

            m_input.text = "";
        }

        static public void FormatByLevel(ref string input, LOGLEVEL LogLevel)
        {
            switch ((LOGLEVEL)LogLevel)
            {
                case LOGLEVEL.INFO:
                    input = "[INFO]" + input;
                    break;

                case LOGLEVEL.FLOW:
                    input = "[FLOW]" + input;
                    break;

                case LOGLEVEL.NET:
                    input = "[NET]" + input;
                    break;

                case LOGLEVEL.WARNING:
                    input = "[WARNING]" + input;
                    break;

                case LOGLEVEL.ERROR:
                    input = "[ERROR]" + input;
                    break;

                default:
                    break;
            }
        }

        static public void WriteToUnityDebugConsole(string strContent, LOGLEVEL LogLevel)
        {
            //输出到debug命令台
            if (LogLevel == LOGLEVEL.ERROR)
            {
#if UNITY_EDITOR
                Log.ConsoleWriteError(strContent);
#else
                YLMobile.Debug.Error(strContent);
#endif
            }
            else if (LogLevel == LOGLEVEL.WARNING)
            {
#if UNITY_EDITOR
                Log.ConsoleWriteWarning(strContent);
#endif
            }
            else
            {
#if UNITY_EDITOR
                Log.ConsoleWrite(strContent);
#endif
            }
        }

        //Editor下输出到Console和文件中
        //外网输出 error, flow, net. 崩溃时看能否上报(暂不做)
        //外网这里要把error上报(暂不做)
        static public void WriteToAll(string strContent, LOGLEVEL LogLevel)
        {
            FormatByLevel(ref strContent, LogLevel);

            //尝试输出到命令行
            if (LineConsole.Instance != null)
            {
                LineConsole.Instance.sendToConsoleAtom(strContent);
            }

            WriteToUnityDebugConsole(strContent, LogLevel);

            //输出到文件
#if UNITY_EDITOR
            Log.FileWrite(strContent);
#endif
        }
    }
}
