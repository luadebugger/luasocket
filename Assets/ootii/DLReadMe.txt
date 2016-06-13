Debug Logger
by ootii


Complete documentation is found here:
http://www.ootii.com/UnityDebugLogger.cshtml


For feedback or support, contact:
Tim Tryzbiak
support@ootii.com


While the online documentation more fully describes how to use the Debug Logger, the following will help get you started:


When debugging scripts, being able to write out to a log is critical. The Unity Console is great, but sometimes you want to write to the screen or a file. The Debug Logger lets you do this in the simplest way possible.

With the Debug Logger, you can write to the console, write to the screen, write to a text file, or write to them all at once. 


Note: The logger also uses a super fast object caching pool that you can use with with other objects!


** Set Up **

The package you download from the Unity Asset Store contains all of the scripts you need to use the Debug Logger. Feel free to use the code as-is or modify it. 

To setup the Debug Logger, follow these simple steps: 

1. Create a new unity project or open an existing one. 
The scripts you've just downloaded will work with any Unity project. 

2. Add this package to your project
You can use the scripts where they are or copy the 3 script files to your own folders.

3. If you want to write to the screen, add the "Log" as a component to your camera.

Note: The options for the 'Log' inspector can only be set while in editor.


** Usage **

Using the logger can't be simplier. 

1. Include these scripts in your scripts 
As with any classes you want to use, you have to tell your scripts they exist. To do this, you'll need to add the "using" directive to the top of your script files that call the Debug Logger. 

	using com.ootii.Utilities;

2. Call the logger's functions

	Log.ScreenWrite("I am writing to the screen");
	
	Log.ConsoleWrite("I am writing to the Unity console");
	
	Log.FileWrite("I am writing to a file");
	
	Log.Write("I am writing to the screen, console, and file");
	
Yep, that's it.


** Bonus **

I've included an object caching class that you can use with other objects. It's great for performance as it keeps Unity from having to allocate objects over and over. Check out the "ObjectPool.cs" file for more info.


** Wrap Up **

Check out the online documentation for more functionality.
