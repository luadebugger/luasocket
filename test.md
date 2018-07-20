# V2-SpatialOS Setup Guide
```
Authors: Zhou, Wayne, Jonas, Alex
Last Updated: 01 June 2018
```

This document will guide you to through the necessary steps to setup and run the V2-SpatialOS game. Note that there are two possible flows in later sections of this document:
1. Running (pre-built) Windows executables for **Phy-Worker.exe** and **V2.exe** client directly.
2. Running `project_physics` and `project_unity` in Unity Editor.

## Contents:
 - [Prerequisites](#prerequisites)
 - [SVN Branching](#svn-branching)
 - [SVN Permissions](#svn-permissions)
 - [Checkout (this) SpatialOS branch](#checkout-this-spatialos-branch)
 - [Setting up the repository](#setting-up-the-repository)
 - [Building the project](#building-the-project)
 - [Running the game](#running-the-game)
 - [Troubleshooting the setup](#troubleshooting-the-setup)
 - [SyncServer Repository](#syncserver-repository)
 - [Building the executables](#building-the-executables)
 - [Merging trunk changes](#merging-trunk-changes)

## Prerequisites
To view this document in proper markdown view in Google Chrome, you should [use this Markdown Viewer extension](https://chrome.google.com/webstore/detail/markdown-viewer/ckkdlimhmcjmikdlpkmbgfkaikojcbjk). Extension Options -> Disable Content Security Policy + Allow All.

Make sure to [register for SpatialOS](https://improbable.io/get-spatialos) on your traveler account.

## SVN Branching
The V2 team is actively developing on `trunk`. To prevent disrupting their workflow, we (Improbable engineers) should develop and commit our spatialos-related
changes to `branches/spatialos`.  Please only keep one branch for SpatialOS-related development to prevent merge conflicts and manual diffs.

## SVN Permissions

Using TortoiseSVN, open the repo browser and point it to:
```
https://svn-v2.gz.netease.com/svn/program/workspace_all/branches/spatialos
```
If you see a prompt, accept the certificate permanently. Then, enter the username from the **IT Setup Guide for V2** (e.g. wb.nealer) and the **Default Password** for authentication.

## Checkout (this) SpatialOS branch

You may checkout the `spatialos` branch via TortoiseSVN (right click windows folder -> SVN Checkout -> Fully recursive -> OK). Or you can perform this in a command prompt:

```bash
svn checkout https://svn-v2.gz.netease.com/svn/program/workspace_all/branches/spatialos
cd spatialos
```

<p>
	<details>
	  <summary>(Optional) Additionally, also checkout the development `trunk` used by the V2 team.</summary>
	  <blockquote>
		<p>Keep in mind that it takes a few hours due to large art assets (>58 GB):
		<p>
		```
		svn://svn-v2.gz.netease.com/svn/program/workspace_all/trunk
		```
		</blockquote>
	</details>
</p>

### Generate Artworks Library folder
You may skip the collapsed section below if you are running the Windows executables directly.

<p>
	<details>
	  <summary>Expand this section otherwise.</summary>
	  <blockquote>
		<p>The `ArtWorks` repo is about 10GB, it takes about 25mins to download.
		After all the repository pulling, you need to generate a library folder.

		<p>Make sure you have set up access to the Unity Asset cache:

		<li>Open Unity, select a new project</li>
		<li>Within Edit &gt; Preferences &gt; Cached Server, make sure the IP is set to **192.168.46.10** and **Remote** mode.</li>
		<li>Within Edit > Project Settings > Player, set Api Compatibility Level to **.NET 2.0** and not **.NET 2.0 subset**. If these versions don't exist or don't work, please use **.NET 4.6 Equivalent**.</li>

		<p>Make sure that you have checked out all of the above external repos. Relaunch Unity, navigate to and open the folder `project_unity/`. Unity will (hopefully) pull in all the stuff needed from the cache server - or rebuild a tonne of stuff.

		<p>Once Unity has finished loading and generated the `project_unity/Library` folder, you should run `project_physics/init_after_checkout.bat` to generating the symlink for `project_physics`.
		</blockquote>
	</details>
</p>

### Symlink SpatialOS workers to `project_physics` and `project_unity`

Run the script  `workers/init_spatialos_workers.bat` This creates the following symlinks / directory junctions:
```
workers/ClientWorker <=> `project_unity`
workers/PhyWorker <=> `project_physics`
```

## Building the project
Manually run `run/0build_schema.bat`. You should see the following output if its successful:
```bash
Info: parse lua schema ok!
Info: write c# schema
Info: write c# schema ok!
```

### Building the Spatial Stack

If you want to run the spatial workers parallel to the V2 game, make sure you satisfy the system requirements for C# spatial worker. Refer to [workers/LifecycleWorker/README.md](workers\LifecycleWorker\README.md).

Run this in the command prompt:
```bash
spatial codegen
spatial worker build
```

You should see the following output:
```bash
PS C: spatial codegen
'spatial codegen' succeeded (2.0s)
PS C: spatial build build-config
Generating bridge settings for ClientWorker.
Generating bridge settings for PhyWorker.
'spatial build build-config' succeeded (0.0s)
```

Note: The purpose of running `spatial worker build` at the moment is to generate bridge configurations for all workers and to build the LifeCycleWorker. The build section for all other workers is in fact a no-op. This is because:
- the logic worker doesn't need to be built
- the unity workers shall be either run in the editor or from built out executables.

You may skip the collapsed section below if you are running the Windows executables directly.

<p>
	<details>
		<summary>Expand this section otherwise.</summary>
		<blockquote>
			<p>Load via Unity once (and close) for each of the following folders:

			<li>project_unity</li>
			<li>project_physics</li>
			<br>
			Make sure to clear and resolve any errors (it's ok if you make some local changes to fix the errors), and rebuild the projects by pressing Ctrl+r ... Once all the errors are resolved, you should eventually see extra tabs at the top of Unity.
		</blockquote>
	</details>
</p>



## Running the game

### Running the servers locally

#### Option 1: Start servers using the BootMaster GUI tool
- Open the BootMaster located in `/run/Boot Master.exe`.
- Click the button `SpatialOS Master Boot`.
- The BootMaster will perform the steps listed in Option 2 under the hood.

#### Option 2: Start servers manually (the old way)
In a command prompt, execute the batch file `run/boot_spatial.bat`. This performs the following:

 - builds V2 LUA schema `0build_schema.bat`.
   - Currently disabled unless you modify the V2 LUA schema.
 - starts V2 SyncServer `1boot_syncserver.bat`
 - performs `spatial local launch`.
   - This waits for **SpatialOS ready. Access the inspector at http://localhost:21000/inspector**
 - starts V2 LogicServer `2boot_logic.bat`

### Running the PhyWorker (project_physics)

You can two options: (1) either run the PhyWorker directly via a Windows executable, or (2) play `project_physics` in Unity.

<p>
	<details>
	  <summary>(Option 1) Running `Phy-Worker.exe` directly.</summary>
		  <blockquote>
		  	Execute `build_package\Package\v2-11232-1651\PhyWorker\Phy-Worker.exe`. You should see things moving around and some large Gizmos.
		  </blockquote>
	</details>
</p>

<p>
	<details>
	  <summary>(Option 2) Running `project_physics` in Unity.</summary>
	  <blockquote>
		<p>Open the `project_physics` project with Unity, and then open the `PhyWorker.unity` scene under `Assets\PhyWorker\Scenes`, then click Play.

		<p>The first time you run the **PhyWorld**, you might be
		asked to choose the lua library, choose `../project_lua`.
		In the `scene` view mode of the PhyWorker `project_physics`, you should see things moving around and some large Gizmos.
		</blockquote>
	</details>
</p>

![Scene of PhyWorker](./project_physics.png)

- At this point, the PhyWorker sends an RPC to V2 logic worker, which loads the scene.
- PhyWorker will get a bunch of **AddEntity** ops from the V2 runtime - which it then uses to spawns SpatialOS entities.
- At this point, the Inspector can validate that the stack is working.

### Running the Game client in Unity (project_unity)

You can two options: (1) either run the V2 game client directly via a Windows executable, or (2) play `project_unity` in Unity.

<p>
	<details>
	  <summary>(Option 1) Running `V2.exe` directly.</summary>
	  <blockquote>
	  	Execute `build_package\Package\v2-11232-1651\Client\v2.exe`.
	  </blockquote>
	</details>
</p>

<p>
	<details>
		<summary>(Option 2) Running `project_unity` in Unity.</summary>
		<blockquote>
		  	<p>Open `project_unity` with Unity, and then open the `start.unity` scene under `Assets\Scenes`, then click Play. The first time you run the **start** scene, you might be asked to choose the lua library, choose `../project_lua`.

		  	<p>In the `game` view mode of the Unity client `project_unity`, you should see yourself fall to the ground.
		</blockquote>
	</details>
</p>

Once the client connects, the SyncServer console window should show the following:
```bash
0 16:41:15.107159 [M][INFO] Schema Loaded 35ee447aa062261f6696362a18efbb36d448a5
1 16:41:15.126216 [T0][INFO] Start
2 16:41:15.126216 [T1][INFO] Start
3 16:41:15.132727 [M][INFO] Listen to tcp://*:19027
4 16:41:16.482029 [M][INFO] Worker connected 3273129984
5 16:41:16.676014 [M][INFO] World create 0
7 16:41:16.677015 [M][INFO] World create 100
10 16:41:45.134356 [M][INFO] Worker 3273129984 delay 1ms
11 16:42:15.133668 [M][INFO] Worker 3273129984 delay 0ms
12 16:42:15.145198 [M][INFO] Worker connected 3289907200   /* PhyWorker (project_physics) */
1166 16:42:44.626608 [M][INFO] Worker connected 3306684416 /* UnityClient (project_unity) */
...
```

### Moving in the game world

In the game client, you should see yourself fall to the ground. You can use the following keys:
 - `V` key to toggle your camera (floating => first person => third person mode)
 - `WASD` to move around
 - `E` to equip weapons
 - `C` to show the HUD: inventory, build, village
 - `M` to show the debug menu
 - `Esc` to unfocus the Unity window
 - `Ctrl + Shift + P` to pause Unity

![Game of Unity](./project_unity.png)

### Understand what's happening
In the SpatialOS inspector - you should see entites runnings around and moving after you've launched the **PhyWorker**.

There should be 5 applications running for the game to work. `boot_spatial.bat` starts three of them - two V2 servers and a SpatialOS local launch (Note: The terminal output is shown in the BootMaster window instead of three separate terminals if you started the serverstackusingthe BootMaster). You manually **play** the two Unity clients. The recommended order is:
```
boot_spatial.bat (Syncserver + Logic + spatial local launch)
	=> Unity PhyWorker (project_physics/Phy-Worker.exe)
	=> Unity Client (project_unity/V2.exe)
```

Whenever you change something in SpatialOS, you should:
 - Unplay the two Unity windows (Close Phy-Worker.exe + V2.exe)
 - Stop all server processes in the BootMaster by pressing `Kill zombie processes`. Alternatively: Kill the three windows spawned by `boot_spatial.bat`
 - Restart the server stack in BooMaster or by running `boot_spatial.bat`
 - Play the two Unity windows (Run Phy-Worker.exe + V2.exe)

In general, the mapping of the above components to `SpatialOS` terms:

```
SyncServer == Spatial local launch
LogicWorker == Lua logic worker using C API + LUA integration
project_physics == Phy-Worker.exe == UnityWorker
project_unity == V2.exe == ClientWorker
```

## Troubleshooting the setup
Kill all Unity processes, restart your machine if in doubt, or ask Wei / Shuige if needed.
- If there is no output from running `1boot_syncserver.bat`, try to run `run/0build_schema.bat` again.
- If TortoiseSVN asks you for a username and password then the **Kerberos Ticket
  Manager** step probably didn’t work, try re-running this.
- You can also access the svn repo through the browser using the **https://**
  prefix instead of **svn://** using your username without any suffix and
  default password.
- Test your access to the repo by pinging the host: `svn-v2.gz.netease.com`
    - If this fails : Run the program that has blue search icon on the
      desktop (当IP权限出问题时，执行一次后重试.exe) as ADMIN - if you have ping failures to the svn repos, this script fixes up IP permissions issues.
    - If this still fails - ask Steve :)
- If you get this console error `LuaException: luadir path not exists` in project_unity, you will need to reconfigure the path in `project_unity/Config/player_settings.json`.

## SyncServer repository
You can access the syncserver code and the readme for it within the separate repo
 that can be checked out from `https://svn-v2.gz.netease.com/svn/program/distributed_entity/trunk/native/`.

## Building the executables
The QA lead in the V2 team owns this process for nightly builds. Unless you make game changes, you can build the executables by running one of the following. Make sure that all zombie Unity.exe processes are terminated for full CPU before running. This should take <30 mins and generate the output in the folder `build_package\Package\v2-<SVN revision>\`.
```
build_package\Package\不更新只打包客户端.bat           //package client
build_package\Package\不更新打包（客户端+服务器）.bat  //package client + PhyW
build_package\Package\更新后打包（客户端+服务器）.bat  //svn update and package client + PhyW
```

## Merging trunk changes
You can follow this guide [V2: Merging SVN trunk > SpatialOS branch](https://drive.google.com/open?id=1SfCCFWWSr10GK36XFLKsBndOT1YzZYOtMVm95GnuAIg) to update this `spatialos` branch and merge changes from V2 development `trunk`.
