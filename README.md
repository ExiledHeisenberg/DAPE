# DAPE
# Created by TheOneWhoKnocks
#
# 5/11/2019
#
# Credits: This script is based on John's "Dynamic Air Patrol" script.  It has been heavily modified with many added features, but he had the initial idea that inspired this project.

-=> What is this script?
This script runs a server side event that simulates a patrol craft being shot down and a rescue mission to recover the pilots.  It runs on server start, waits 10 - 12  minutes,
then launches a patrol craft chosen at random.  The plan will roam between four random waypoints for a while until an resistance interceptor is launched to deal with the threat.
The script gives the interceptor 10 minutes to shoot down the patrol, and if it doesn't the plan will explode anyway.  If the plane crashes on land, a quick reaction force (QRF)
heli is launched.  Once on scene, the heli will dispatch a QRF force to look for survivors and secure the scene.  Meanwhile, the pilots will secure the heli and await further orders.

If the patrol craft crashes into water, it is deemed lost and no QRF force is launched.  The intercetor will leave the area and the script will try again.  It will repeat until 
a resuce mission is launched.

-=> Features
	(Version 1.4)
	- Added code to reset if rescue heli is shot down
	- Added option to protect rescue heli until it lands
	- Added option to run without Exile
	- Added delay before QRF launches
	- Minor code corrections
	(Version 1.3)
	- Helicopter is now only persistent after someone jumps in
	- Script will now pause until a player joins the server
	- Debug is now on by default to verify its working
    (Version 1.2)
    - Added option to turn off interceptor
    - Added random amounts of cash (poptabs) to AI
    - Added option to make helicopter persistent vehicle with code
    - If not persistent, Vehicle Claim Script should work for most vehicles
    (Version 1.1)
    - Script will now auto clean markers and old mission site once a player jumps in the helicopter    
	- Script now runs continuously
	- Optimized some code
    (Version 1.0)
    - Offers a highly randomized mission and experience
    - Can be easily customized for any custom content or equipment/vehicle mod
    - Should work on any map

-=> Installation

1. Cope the folder "DAPE" to the root of your mission folder (ex. Exile.Altis)
2. Edit your init.sqf in the root of your mission folder and add the following line to the bottom:

[] execVM "DAPE\DAPE.sqf";   // Dynamic Air Patrol Mission

Re-PBO your mission file and you're good to go.

-=> Customizing the script

There are several variables and arrays that you can modify to adjust the script to your liking.  
NOTE: The sript works as is, so if you make any changes be sure you know what you're doing

The code is heavily commented to make it easy to change, but here are some key variables

_APEXDLC = true; //Set to true to enable APEX content
_JetsDLC = true; //Set to true to enable Jets content
These determine if you will add in the content from these two DLCs.  Set to 'false' if you won't have/want these vehicles added.  
This should also give you an idea on how to addyour own content.


_lootWeapons
This array determines the type of loot weapons will be on the rescue chopper as loot.  It also determines what the rescue team is equipped with since they grab their weapons from the heli


_patrolAirplanes
This array contains the types of planes that will spawn in and be shot down


_interceptorPlanes
This array determines the model that will be spawned in to shoot down the patrol craft


_rescueHelis
This array defines the types of heli's that can be used as the rescue chopper.  This is also the main loot for the event so make sure it is somethign you want a player to have.


The rest is pretty complex stuff so only mess around with what you understand. 


