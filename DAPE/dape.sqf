/** DYNAMIC AIR PATROL EVENT by TheOneWhoKnocks **/
// Version 1.1
// Originally inspired by johno's Dynamic Air Patrol script
// Modified to include make event run until a chopper event runs, fixed several issues, and enhance overall script
// 4/20/18
// 5/10/2019 - Significant changes and complete overhaul  First release
// 5/18/2019 - Added marker cleanup and ,ade it so script repeats after heli is cleared.  Code optimizations
diag_log "[DAPE] Ambient air patrol engaged";
 
if (!isServer) exitWith{};
 
private ["_cleanupObjects","_rescueChopperRun","_waypoint1","_waypoint2","_waypoint3","_waypoint4","_patrolAirplanes","_crashType","_chosenTarget","_chosenTargetName","_interceptorPlanes","_markerWaypointOne","_markerWaypointTwo","_markerWaypointThree","_markerWayPointFour","_wayPointOne","_wayPointTwo","_wayPointThree","_wayPointFour","_mk","_pos","_interceptor","_interceptorAircraft"];
 
 
/************************************************************************************************/
/** Random location settings ********************************************************************/
/************************************************************************************************/
 
_spawnCenter = [worldSize / 2, worldsize / 2, 1000]; ; //Alternative method

_min = 10; // minimum distance from the center position (Number) in meters
_max = worldSize * 0.4; // maximum distance from the center position (Number) in meters
_mindist = 0; // minimum distance from the nearest object (Number) in meters, ie. create waypoint this distance away from anything within x meters..
_water = 0; // water mode 0: cannot be in water , 1: can either be in water or not , 2: must be in water
_shoremode = 0; // 0: does not have to be at a shore , 1: must be at a shore

/************************************************************************************************/
/** DLC Content  ********************************************************************************/
/************************************************************************************************/
_APEXDLC = true; //Set to true to enable APEX content
_JetsDLC = true; //Set to true to enable Jets content

 
/************************************************************************************************/
/** DEBUG MARKER ********************************************************************************/
/** Turns on markers that show event activity ***************************************************/
/** Also shortens mission for testing ***********************************************************/
/************************************************************************************************/
 
_debug = false; // Will create a marker that will follow the aircraft
 
/************************************************************************************************/
/** GENERATE WAYPOINTS **************************************************************************/
/************************************************************************************************/

_useMarkerWaypoints = false; 
// If true, will use fixed locations instead of random positions.  
// If false, you system will generate four waypoints around the map

_cleanupObjects = [];

if (_debug) then
{
	private _centerPoint = createMarker ["centerpoint", _spawnCenter	];  //Shows map center

	_centerPoint setMarkerType "mil_destroy";
};
 
/************************************************************************************************/
/** If using fixed locations or waypoints *******************************************************/
/************************************************************************************************/
if (_useMarkerWaypoints) then 
{
 
	private _waypoint1 = createMarker ["waypoint1", [8407,10285]	];  //These work for Tanoa and make the craft fly in a large X across the island
	private _waypoint2 = createMarker ["waypoint2", [2970,3416]		];	//The patrol aircraft will fly to waypoint 1, then cycle through 4, then back to 1
	private _waypoint3 = createMarker ["waypoint3", [11652,3123]	];	//The attack aircraft will fly a reverse route
	private _waypoint4 = createMarker ["waypoint4", [3064,11047]	];	//This is the best way to ensure the event works the way you want
	
	if (_debug) then
	{
		_waypoint1 setMarkerType "mil_pickup";
		_waypoint2 setMarkerType "mil_pickup";
		_waypoint3 setMarkerType "mil_pickup";
		_waypoint4 setMarkerType "mil_pickup";
	};
 
    _wayPointOne = getMarkerPos "waypoint1";
    _wayPointTwo = getMarkerPos "waypoint2";
    _wayPointThree = getMarkerPos "waypoint3";
    _wayPointFour = getMarkerPos "waypoint4";
	
}else
/************************************************************************************************/
/** Generate random waypoints *******************************************************************/
/** Note: This makes a very sporadic flight path ************************************************/
/************************************************************************************************/
{
    _wayPointOne = [_spawnCenter,_min,_max,_mindist,_water,5,_shoremode] call BIS_fnc_findSafePos;
    _wayPointTwo = [_spawnCenter,_min,_max,_mindist,_water,5,_shoremode] call BIS_fnc_findSafePos;
    _wayPointThree = [_spawnCenter,_min,_max,_mindist,_water,5,_shoremode] call BIS_fnc_findSafePos;
    _wayPointFour = [_spawnCenter,_min,_max,_mindist,_water,5,_shoremode] call BIS_fnc_findSafePos;
	
	if (_debug) then
	{
		private _waypoint1 = createMarker ["waypoint1", _wayPointOne	];  //These will be randomly placed waypoints
		private _waypoint2 = createMarker ["waypoint2", _wayPointTwo	];	//The patrol aircraft will fly to waypoint 1, then cycle through 4, then back to 1
		private _waypoint3 = createMarker ["waypoint3", _wayPointThree	];	//The attack aircraft will fly a reverse route
		private _waypoint4 = createMarker ["waypoint4", _wayPointFour	];	//This will be a very sporadic flight path

		_waypoint1 setMarkerType "mil_pickup";	
		_waypoint2 setMarkerType "mil_pickup";
		_waypoint3 setMarkerType "mil_pickup";
		_waypoint4 setMarkerType "mil_pickup";
		
		_waypoint1 setMarkerText "WP1";	
		_waypoint2 setMarkerText "WP2";
		_waypoint3 setMarkerText "WP3";
		_waypoint4 setMarkerText "WP4";

	};
};

// Starting position for the interceptor and rescue chopper.
 
_startPos = [_spawnCenter, (worldSize * 0.5), -1, 5, 2] call BIS_fnc_findSafePos ;	// Tries to find a location over the water so they don't just appear out of nowhere

//diag_log format ["[DAPE] Startpos : %1",_startPos];

if (_debug) then
{
	private _startPoint = createMarker ["startpos", _startPos	];  //Shows map center

	_startPoint setMarkerType "mil_start";
	_startPoint setMarkerText "SP-Patrol";

};

_interceptorStartPos = [_spawnCenter, (worldSize * 0.5), -1, 5, 2] call BIS_fnc_findSafePos ;	// Tries to find a location over the water so they don't just appear out of nowhere

if (_debug) then
{
	private _inStartPoint = createMarker ["intstartpos", _interceptorStartPos	];  //Shows map center

	_inStartPoint setMarkerType "hd_start";
	_inStartPoint setMarkerText "SP-Int";

};

//diag_log format ["[DAPE] IntStartpos : %1",_interceptorStartPos];

_interceptorExitPos = [_spawnCenter, (worldSize * 0.75), -1, 5, 2] call BIS_fnc_findSafePos ;	// Tries to find a location over the water so they don't just appear out of nowhere

if (_debug) then
{
	private _inExitPoint = createMarker ["intexitpos", _interceptorExitPos	];  //Shows map center

	_inExitPoint setMarkerType "hd_end";
	_inExitPoint setMarkerText "EP-Int";

};

//diag_log format ["[DAPE] IntExitpos : %1",_interceptorExitPos];


// LOOT
// The loot is the chopper itself, but you can choose to add weapons and items if you want 
 
_amountOfWeapons = 5+floor(random 5);
_amountOfItems = 7+floor(random 5);
 
_lootWeapons =
	[
		"arifle_MXM_Black_F",
		"arifle_MXM_F",
		"srifle_DMR_01_F",
		"srifle_DMR_02_camo_F",
		"srifle_DMR_02_F",
		"srifle_DMR_02_sniper_F",
		"srifle_DMR_03_F",
		"srifle_DMR_03_khaki_F",
		"srifle_DMR_03_multicam_F",
		"srifle_DMR_03_tan_F",
		"srifle_DMR_03_woodland_F",
		"srifle_DMR_04_F",
		"srifle_DMR_04_Tan_F",
		"srifle_DMR_05_blk_F",
		"srifle_DMR_05_hex_F",
		"srifle_DMR_05_tan_f",
		"srifle_DMR_06_camo_F",
		"srifle_DMR_06_olive_F",
		"srifle_EBR_F",
		"srifle_GM6_camo_F",
		"srifle_GM6_F",
		"srifle_LRR_camo_F",
		"srifle_LRR_F",
		 
		"arifle_MX_SW_Black_F",
		"arifle_MX_SW_F",
		"LMG_Mk200_F",
		"MMG_01_hex_F",
		"MMG_01_tan_F",
		"MMG_02_camo_F",
		"MMG_02_black_F",
		"MMG_02_sand_F",
		"LMG_Zafir_F",
		 
		"arifle_Katiba_C_F",
		"arifle_Katiba_F",
		"arifle_Katiba_GL_F",
		"arifle_Mk20_F",
		"arifle_Mk20_GL_F",
		"arifle_Mk20_GL_plain_F",
		"arifle_Mk20_plain_F",
		"arifle_Mk20C_F",
		"arifle_Mk20C_plain_F",
		"arifle_MX_Black_F",
		"arifle_MX_F",
		"arifle_MX_GL_Black_F",
		"arifle_MX_GL_F",
		"arifle_MXC_Black_F",
		"arifle_MXC_F",
		"arifle_SDAR_F",
		"arifle_TRG20_F",
		"arifle_TRG21_F",
		"arifle_TRG21_GL_F"
	];
 
_lootItems =
	[
		"HandGrenade",
		"MiniGrenade",
		"B_IR_Grenade",
		"O_IR_Grenade",
		"I_IR_Grenade",
		"1Rnd_HE_Grenade_shell",
		"3Rnd_HE_Grenade_shell",
		"APERSBoundingMine_Range_Mag",
		"APERSMine_Range_Mag",
		"APERSTripMine_Wire_Mag",
		"ClaymoreDirectionalMine_Remote_Mag",
		"DemoCharge_Remote_Mag",
		"IEDLandBig_Remote_Mag",
		"IEDLandSmall_Remote_Mag",
		"IEDUrbanBig_Remote_Mag",
		"IEDUrbanSmall_Remote_Mag",
		"SatchelCharge_Remote_Mag",
		"SLAMDirectionalMine_Wire_Mag",
		 
		"B_AssaultPack_blk",
		"B_AssaultPack_cbr",
		"B_AssaultPack_dgtl",
		"B_AssaultPack_khk",
		"B_AssaultPack_mcamo",
		"B_AssaultPack_rgr",
		"B_AssaultPack_sgg",
		"B_FieldPack_blk",
		"B_FieldPack_cbr",
		"B_FieldPack_ocamo",
		"B_FieldPack_oucamo",
		"B_TacticalPack_blk",
		"B_TacticalPack_rgr",
		"B_TacticalPack_ocamo",
		"B_TacticalPack_mcamo",
		"B_TacticalPack_oli",
		"B_Kitbag_cbr",
		"B_Kitbag_mcamo",
		"B_Kitbag_sgg",
		"B_Carryall_cbr",
		"B_Carryall_khk",
		"B_Carryall_mcamo",
		"B_Carryall_ocamo",
		"B_Carryall_oli",
		"B_Carryall_oucamo",
		"B_Bergen_blk",
		"B_Bergen_mcamo",
		"B_Bergen_rgr",
		"B_Bergen_sgg",
		"B_HuntingBackpack",
		"B_OutdoorPack_blk",
		"B_OutdoorPack_blu",
		 
		"Rangefinder",
		"NVGoggles",
		"NVGoggles_INDEP",
		"NVGoggles_OPFOR",
		 
		"Exile_Item_InstaDoc",
		"Exile_Item_Vishpirin",
		"Exile_Item_Bandage"
	];
	
// Airplane options
	
_patrolAirplanes = 
	[
		// A-164 Wipeout
		"B_Plane_CAS_01_dynamicLoadout_F",
		// AN-2

		"Exile_Plane_AN2_Green",
		"Exile_Plane_AN2_White",
		"Exile_Plane_AN2_Stripe",
		"An2_tk",
		"An2_af",
		"An2_a2",	
		// Cessna 185 Skymaster (armed)
		"GNT_C185T",
		
		// MQ-4A Greyhawk (UAV)
		"B_UAV_02_dynamicLoadout_F",
		"O_UAV_02_dynamicLoadout_F",
		"I_UAV_02_dynamicLoadout_F"
	];
	
_APEXPatrolAirlanes =
	[
	
		// Ceaser BTT
		"C_Plane_Civil_01_F",
		//"Exile_Plane_Ceasar",
		"C_Plane_Civil_01_racing_F",
		"I_C_Plane_Civil_01_F",	
		
		// KH-3A Fenghuang (UAV)
		"O_T_UAV_04_CAS_F",
		// V-44 X Blackfish
		"B_T_VTOL_01_armed_F",
		"B_T_VTOL_01_infantry_F",
		"B_T_VTOL_01_vehicle_F",
		// Y-32 Xi'an
		"O_T_VTOL_02_infantry_dynamicLoadout_F",
		"O_T_VTOL_02_vehicle_dynamicLoadout_F"
	];
	
_JetsPatrolAirplanes =
	[
		// UCAV Sentinel
		"B_UAV_05_F"
	];

 
 _interceptorPlanes = 
	[
		// A-143 Buzzard
		"I_Plane_Fighter_03_dynamicLoadout_F",
		//To-199 Neophron
		"O_Plane_CAS_02_dynamicLoadout_F"
	];
	
_jetsInterceptorPlanes =
	[
		// A-149 Gryphon
		"I_Plane_Fighter_04_F",
		// F/A 181
		"B_Plane_Fighter_01_F",
		"B_Plane_Fighter_01_Stealth_F",
		// To-201 Shikra
		"O_Plane_Fighter_02_F",
		"O_Plane_Fighter_02_Stealth_F"
	];	
	
_rescueHelis = 
	[
		// UH-80 Ghosthawk
		"B_Heli_Transport_01_F",
		"B_Heli_Transport_01_camo_F",
		
		// CH-67 Huron
		"B_Heli_Transport_03_unarmed_F",
		
		// MH-9 Hummingbird
		"B_Heli_Light_01_F",
		
		// UH1H
		"UH1H_Closed_TK"
		
	];
	
if 	(_APEXDLC) then
{
	_patrolAirplanes append _APEXPatrolAirlanes;
};

if 	(_JetsDLC) then
{
	_patrolAirplanes append _JetsPatrolAirplanes;
	_interceptorPlanes append _jetsInterceptorPlanes;
};
	
// Mission initialization

_side = createCenter EAST;


//Setup Loop logic so it runs this script until the rescue operation can run (Accounts for crashes at sea and runs again if no rescue chopper flies
//while {!_rescueChopperRun} do 
while {true} do 
{
	//diag_log "[DAPE} Loop starting";
	// Randomize the start time of the script
	 
	if (_debug) then
	{
		uiSleep 120;
	}
	else
	{    
		uiSleep 300; // Wait for 5 minutes from beginning of script minutes.
	 
		_randomStartTime = floor (random 600); // Continue the delayed start for a random time between 0 and 10 minutes
		uiSleep _randomStartTime;
	};
	 
	
	_chosenTarget = _patrolAirplanes call BIS_fnc_selectRandom;
	_chosenTargetName = getText (configfile >> "CfgVehicles" >> _chosenTarget >> "displayName");
	
	_patrolGroup = createGroup [EAST,true];
	_spawnedPatrol = [_startPos, 180,_chosenTarget, _patrolGroup] call BIS_fnc_spawnVehicle;
	_airCraftLead = _spawnedPatrol select 0;
		
	[driver _airCraftLead ] joinSilent _patrolGroup;

	//diag_log format ["[DAPE] Patrol Pos: %1", getPosASL _airCraftLead];
	
	_titlePatrol = "ALERT";
	_messagePatrol = format ["A %1 patrol aircraft has been spotted",_chosenTargetName];
	 
	["systemChatRequest", [format ["%1: %2",_titlePatrol,_messagePatrol]]] call ExileServer_system_network_send_broadcast;

	["toastRequest", ["InfoTitleAndText", [_titlePatrol, format ["A %1 patrol aircraft has been spotted",_chosenTargetName]]]] call ExileServer_system_network_send_broadcast;
	 
	if (_debug) then
	{
		[_airCraftLead] spawn
		{
			_planes = _this select 0;
			_pos = position _planes;
			_mk = createMarker ["AirCraftLocation",_pos];
			while {alive _planes} do
			{
				_pos = position _planes;
				"AirCraftLocation" setMarkerType "mil_warning";
				"AirCraftLocation" setMarkerText "Patrol";
				_mk setMarkerPos _pos;
				uiSleep 1;
			};  
		};  
	};
	 
	//diag_log "[DAPE] Patrol aircraft created";
	 
	_patrolGroup setCombatMode "BLUE";
	 
	_airCraftLead disableAI "AUTOTARGET";
	_airCraftLead disableAI "TARGET";
	_airCraftLead disableAI "SUPPRESSION";

	 
	_wp1 = _patrolGroup addWaypoint [_wayPointOne, 500];
	_wp1 setWaypointType "MOVE";
	_wp1 setWaypointBehaviour "CARELESS";
	_wp1 setWaypointspeed "NORMAL";
	 
	_wp2 = _patrolGroup addWaypoint [_wayPointTwo, 500];
	_wp2 setWaypointType "MOVE";
	_wp2 setWaypointBehaviour "CARELESS";
	_wp2 setWaypointspeed "LIMITED";
	 
	_wp3 = _patrolGroup addWaypoint [_wayPointThree, 500];
	_wp3 setWaypointType "MOVE";
	_wp3 setWaypointBehaviour "CARELESS";
	_wp3 setWaypointspeed "NORMAL";
	 
	_wp4 = _patrolGroup addWaypoint [_wayPointFour, 500];
	_wp4 setWaypointType "MOVE";
	_wp4 setWaypointBehaviour "CARELESS";
	_wp4 setWaypointspeed "LIMITED";
	 
	_wp5 = _patrolGroup addWaypoint [_wayPointOne, 500];
	_wp5 setWaypointType "CYCLE";
	_wp5 setWaypointBehaviour "CARELESS";
	_wp5 setWaypointspeed "NORMAL";
	 
	if (_debug) then
	{
		uiSleep 120;
	}
	else
	{    
	 
		uiSleep 600;
	};
	
	diag_log "[DAPE] Intercept aircraft dispatched";
	_interceptor = createGroup [resistance,true];
	_interceptorChoice = _interceptorPlanes call BIS_fnc_selectRandom;
	_interceptorName = getText (configfile >> "CfgVehicles" >> _interceptorChoice >> "displayName");
   
	_spawnedInterceptor = [_interceptorStartPos, 180,_interceptorChoice, _interceptor] call BIS_fnc_spawnVehicle;
	_interceptorAircraft = _spawnedInterceptor select 0;
	
	
	[driver _interceptorAircraft ] joinSilent _interceptor;
	//diag_log format ["[DAPE] Interceptor Pos: %1", getPosASL _interceptorAircraft];

   
	_interceptor setCombatMode "RED";
	_interceptorAircraft allowDamage false;
	_interceptorAircraft setCaptive true;
	_interceptorAircraft forceSpeed 400;
	_interceptorAircraft reveal _airCraftLead;
   
	_waypoints = [_wayPointFour,_wayPointThree,_wayPointTwo,_wayPointOne];
	{
	_intWP = _interceptor addWaypoint [_x, 500];
	_intWP setWaypointType "MOVE";
	_intWP setWaypointBehaviour "SAFE";
	_intWP setWaypointspeed "NORMAL";
	} forEach _waypoints;
	
	_intWP = _interceptor addWaypoint [_wayPointFour, 500];
	_intWP setWaypointType "CYCLE";
	_intWP setWaypointBehaviour "SAFE";
	_intWP setWaypointspeed "NORMAL";
 
	if (_debug) then
	{    
		[_interceptorAircraft] spawn
		{
			_plane2 = _this select 0;
			_pos2 = position _plane2;
			_mk1 = createMarker ["Y",_pos2];
			while {alive _plane2} do
			{    
				_pos2 = position _plane2;
				"Y" setMarkerType "mil_warning";
				"Y" setMarkerText "Intercept";
				_mk1 setMarkerPos _pos2;
				uiSleep 1;
			};
		};  
	};

	_counter = 0;

	// Patrol will fly around for 10 minutes, then blow up by itself unless the interceptor shoots it down first
	// Adjust the counter for number of minutes for interceptor to destroy it
	while {(_counter < 10) && (alive _airCraftLead)} do
	{
		sleep 60;
		_counter = _counter + 1;
	};
	
	_titlePatrol = "MAYDAY";
	_messagePatrol = format ["%1 is going down!",_chosenTargetName];

	for "_i" from 1 to 3 do
	{
		["systemChatRequest", [format ["%1: %2",_titlePatrol,_messagePatrol]]] call ExileServer_system_network_send_broadcast;
	};

	if (alive _airCraftLead) then
	{  
		diag_log "[DAPE] Times up. Blowing lead aircraft";
		_airCraftLead setDamage 1;
	}; 			
 
	//diag_log "[DAPE] Waiting for crash"; 
	while {(getPos _airCraftLead select 2) > 5} do { sleep 5};
	//diag_log "[DAPE] Crash detected"; 
	
	while {(count (waypoints _interceptor)) > 0} do
	{
		deleteWaypoint ((waypoints _interceptor) select 0);
	};

	//diag_log "[DAPE] Interceptor -- Remaining offensive waypoints deleted";

	_intExitWP = _interceptor addWaypoint [_interceptorExitPos, 0];
	_intExitWP setWaypointType "MOVE";
	_intExitWP setWaypointBehaviour "CARELESS";
	_intExitWP setWaypointspeed "NORMAL";
   
	_interceptor setCombatMode "BLUE";
   
	{
	_x disableAI "AUTOTARGET";
	_x disableAI "TARGET";
	_x disableAI "SUPPRESSION";
   
	} forEach units _interceptor;
   
	//diag_log "[DAPE] Interceptor Aircraft dismiss order initiated";
	
	if (_debug) then
	{
		private _crashPoint = createMarker ["crashpos", (position _airCraftLead)	];  

		_crashPoint setMarkerType "hd_join";
		_crashPoint setMarkerText "Crash";

	};
	 
	_isWater = surfaceIsWater position _airCraftLead;
	 
	diag_log format ["[DAPE] Crash in water?: %1",_isWater];
	 
	 
	if (!_isWater) then
	{
		//diag_log "[DAPE] Aircraft Patrol -- Crash recovey sequence initiated";
	 
		_westSide = createCenter west;
		_titleQRF = "WARNING";
		_messageQRF = "A Quick Reaction Force has been dispatched to secure the crash site.  Do not approach or you will be fired on.";
		
		["toastRequest", ["InfoTitleAndText", [_titleQRF, _messageQRF]]] call ExileServer_system_network_send_broadcast;
	 
		["systemChatRequest", [format ["%1: %2",_titleQRF,_messageQRF]]] call ExileServer_system_network_send_broadcast;
			 
		_landPos = _airCraftLead getPos [50, (random 360)];

		{ _x hideObjectGlobal true } foreach (nearestTerrainObjects [_landPos,["TREE", "SMALL TREE", "BUSH"],40]);
	 
		_helipad = "Land_HelipadEmpty_F" createVehicle _landPos;
		sleep 10;
	 
		_crash = createVehicle ["test_EmptyObjectForFireBig",_landPos,[], 0, "can_collide"];
		_crash setPos [position _crash select 0,position _crash select 1, 0.1];
		_crash setVectorUp surfaceNormal position _crash;
		_smoke = createVehicle ["test_EmptyObjectForSmoke",position _crash,[], 0, "can_collide"];
		_smoke attachTo [_crash, [0.5, -2, 1] ];
		
		_cleanupObjects = [_crash,_smoke];
		
	 	_rescueCrew = createGroup [EAST,true];
	 		
		_lootHeli = _rescueHelis call BIS_fnc_selectRandom;

		_spawnRescue = [_startPos, 180, _lootHeli, _rescueCrew] call BIS_fnc_spawnVehicle;
		_chopper = _spawnRescue select 0;
		
		[driver _chopper ] joinSilent _rescueCrew;
		
		_chopper setVariable ["GONE",false];

		
		_chopper addEventHandler ["GetIn",{	params ["_vehicle", "_role", "_unit", "_turret"];if (isPlayer _unit) then {_vehicle setVariable ["GONE",true];};}];
		_chopper addMPEventHandler ["MPKilled",{params ["_vehicle", "_unit"];_vehicle setVariable ["GONE",true];}];
		
		
	 	//diag_log format ["[DAPE] Chopper Pos: %1", getPosASL _chopper];

	 
		if (_debug) then
		{    
			[_chopper] spawn
			{
				_chopper1 = _this select 0;
				_pos3 = position _chopper1;
				_mk2 = createMarker ["E",_pos3];
				while {alive _chopper1} do
				{    
					_pos3 = position _chopper1;
					"E" setMarkerType "mil_warning";
					"E" setMarkerText "Rescue";
					_mk2 setMarkerPos _pos3;
					sleep 1;
				};
			};  
		};
	 
		diag_log "[DAPE] Rescue HELO Dispatched";
	 
		_rescueCrew setCombatMode "BLUE";
	 
		_rescueWP1 = _rescueCrew addWaypoint [_landPos, 0];
		_rescueWP1 setWaypointType "GETOUT";
		_rescueWP1 setWaypointBehaviour "CARELESS";
		_rescueWP1 setWaypointspeed "FULL";
	 
	 // The loot is the chopper itself, but this adds loot from tables above 

		clearMagazineCargoGlobal _chopper;
		clearWeaponCargoGlobal _chopper;
		clearItemCargoGlobal _chopper;
		clearBackpackCargoGlobal _chopper;
	 
		// Add weapons to the chopper
	 
		for "_i" from 1 to _amountOfWeapons do
		{
			_weapon = _lootWeapons call BIS_fnc_selectRandom;
			_chopper addWeaponCargoGlobal [_weapon,1];
		   
			_magazines = getArray (configFile >> "CfgWeapons" >> _weapon >> "magazines");
			_chopper addMagazineCargoGlobal [(_magazines select 0),round random 8];
		};
	 
		for "_i" from 1 to _amountOfItems do
		{
			_items = _lootItems call BIS_fnc_selectRandom;
			_chopper addMagazineCargoGlobal [_items,1];
		   
		};
		
		
		while {(getPos _chopper select 2) >1} do {sleep 10};
		
		{
			removeBackpackGlobal _x;
			removeAllWeapons _x;
			_curWeapon = _lootWeapons call BIS_fnc_selectRandom;
			[_x,_curWeapon, 5] call BIS_fnc_addWeapon;
		} forEach units _rescueCrew;
		
		_rescueCrew setCombatMode "RED";
		_rescueCrew allowFleeing 0;
		_rescueWP2 = _rescueCrew addWaypoint [_landPos, 10];
		_rescueWP2 setWaypointType "GETOUT";
		_rescueWP2 setWaypointBehaviour "SAFE";
		_rescueWP2 setWaypointspeed "NORMAL";
	 
		[_rescueCrew, (getPos _chopper), 50] call bis_fnc_taskPatrol;
	 
		// These units come with gear.  If you want custom loot, see next note
		_aiUnits = ["O_G_Soldier_TL_F", "O_G_medic_F","O_G_Soldier_F","O_G_Soldier_AR_F"];
	 
		_HeliAiUnits = [(getPos _chopper), EAST, _aiUnits,[],[],[0.5,0.9],[],[],(random 360)] call BIS_fnc_spawnGroup;
		_HeliAiUnits deleteGroupWhenEmpty true;
		//Add waypoint for the AI
		_HeliCrashGroupLeader = leader _HeliAiUnits;
		_HeliCrashUnitsGroup = group _HeliCrashGroupLeader;
		
		//_HeliAiUnits joinSilent (group _HeliCrashGroupLeader);

	 
		//  This will remove the gear of the units above and add weapons from the defined loot table above
		{
			removeBackpackGlobal _x;
			removeAllWeapons _x;
			_curWeapon = _lootWeapons call BIS_fnc_selectRandom;
			[_x,_curWeapon, 5] call BIS_fnc_addWeapon;
		} forEach units _HeliAiUnits;
	 
		_HeliAIUnits allowFleeing 0;
	 
		_HeliCrashUnitsGroup addWaypoint [position _crash, 0];
		[_HeliCrashUnitsGroup, 0] setWaypointType "GUARD";
		[_HeliCrashUnitsGroup, 0] setWaypointBehaviour "AWARE";
		
		_heli_marker = createMarker ["DAPE_Marker", _crash];
		_heli_marker setMarkerColor "ColorOrange";
		_heli_marker setMarkerAlpha 1;
		_heli_marker setMarkerText "Rescue Mission";
		_heli_marker setMarkerType "o_air";
		_heli_marker setMarkerBrush "Vertical";
		_heli_marker setMarkerSize [(1.25), (1.25)];
		
		sleep 60;
		
		private _objects = 	[
								["Land_Bodybag_01_black_F",_crash,[0,0,1],[true,false]], 
								["Land_Bodybag_01_black_F",_crash,[0,0,1],[true,false]]
							];
		{
			_object = (_x select 0) createVehicle ((_x select 1) getPos [5, (random 360)]);
			_object enableSimulationGlobal ((_x select 3) select 0);
			_object allowDamage ((_x select 3) select 1);
			_object setDir (random 360);
			_cleanupObjects pushBack _object;
		} forEach _objects;
		
		while {!(_chopper getVariable "GONE")} do {sleep 60};
		
		diag_log ["[DAPE] Heli taken, cleaning up mission"];
		
		deleteMarker "DAPE_Marker";
		
		if (_debug) then
		{
			deleteMarker "E";
			deleteMarker "Y";
			deleteMarker "AirCraftLocation";
			deleteMarker "crashpos";
		};
		
		sleep 300; // Wait 5 minutes and then clean up remnants

		{
			deleteVehicle _x;
		} forEach _cleanupObjects;
		
		{
			deleteVehicle _x;
		} forEach units _rescueCrew;
		
		{
			deleteVehicle _x;
		} forEach units _HeliAiUnits;
		
		deleteVehicle _airCraftLead;
	}
	else
	{
		diag_log "[DAPE] AIRCRAFT crashed in water -- Terminating rescue sequence";
		deleteVehicle _airCraftLead;
	};
	 
	uiSleep 120;
	 
	deleteVehicle _interceptorAircraft;
	if (_debug) then
	{
		deleteMarker "Y";
		deleteMarker "AirCraftLocation";
		deleteMarker "crashpos";
	};
};