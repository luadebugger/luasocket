using UnityEngine;
using System.Collections;
using com.ootii.Utilities.Debug;

namespace com.ootii.Demos.DL
{
    public class LogDemo : MonoBehaviour
    {
        private float mBtnWidth = 150;
        private float mBtnHeight = 30;

        private bool mScreenWriting1 = false;

        private Rect mConsoleWrite;
        private Rect mScreenWrite;
        private Rect mFileWrite;
        private Rect mAllWrite;

        void Awake()
        {
            mConsoleWrite = new Rect(10, 200 + ((mBtnHeight + 10) * 0), mBtnWidth, mBtnHeight);
            mScreenWrite = new Rect(10, 200 + ((mBtnHeight + 10) * 1), mBtnWidth, mBtnHeight);
            mFileWrite = new Rect(10, 200 + ((mBtnHeight + 10) * 2), mBtnWidth, mBtnHeight);
            mAllWrite = new Rect(10, 200 + ((mBtnHeight + 10) * 3), mBtnWidth, mBtnHeight);
        }

        // Use this for initialization
        void Start()
        {
        }

        // Update is called once per frame
        void Update()
        {
            if (!mScreenWriting1)
            {
                Log.ScreenWrite("1. Writing to line 1", 1);
                Log.ScreenWrite("3. Writing to line 3", 3);
                Log.ScreenWrite("4. Writing to line 4", 4);
                Log.ScreenWrite("6. Writing to line 6", 6);
            }
            else
            {
                Log.ScreenWrite("Do not mind me...");
                Log.ScreenWrite("Just writing to the screen each frame");
            }
        }

        /// <summary>
        /// Place the buttons and send messages when clicked
        /// </summary>
        void OnGUI()
        {
            // Show the buttons
            if (GUI.Button(mConsoleWrite, "Console Write"))
            {
                Log.ConsoleWrite("Whoo hoo! I've written to the console.");
            }

            // Show the buttons
            if (GUI.Button(mScreenWrite, "Toggle Screen Write"))
            {
                mScreenWriting1 = !mScreenWriting1;
            }

            // Show the buttons
            if (GUI.Button(mFileWrite, "File Write"))
            {
                Log.FileWrite("File opened");
                Log.FileWrite("I am here!");

                Log.ConsoleWrite("Written to file: " + Log.FilePath);
            }

            // Show the buttons
            if (GUI.Button(mAllWrite, "All Write"))
            {
                Log.Write("Writing everywhere!");
            }
        }
    }
}
