/////////////////////////////////////////////////////////////////////////////////
//	Dynamic Air Patrol Event 			/////////////////////////////////////////////
// 	Created 1/20/2020					/////////////////////////////////////////////
// 	Developed by TheOneWhoKnocks		/////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////
/*
Version 1.8

*/
DAPE_Version = "1.8";
publicVariableServer "DAPE_Version";

// Set this to true if running with Exile.  Future development will seperate Exile dependencies
DAPE_exileLoaded = true;	

//////////////////////////////////////////////////////////////////////////////////
// Dynamic Air Patrol Event Config	//////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////

// Basic configuration
DAPE_debug = false;				// TRUE - Turns on debug info for DAPE system and shortens timers | FALSE - System runs normal with no markers
DAPE_showMarkers = true;		// TRUE - Will show just the aircraft markers without debug info | FALSE - Doesn't
DAPE_markerPat = "mil_warning";	// Marker for patrol craft
DAPE_markerInt = "mil_warning";	// Marker for intercept craft
DAPE_markerRes = "mil_warning";	// Marker for rescue craft
DAPE_patrolHeight = 150;		// Fly in height for patrol and rescue operations
DAPE_delayIntercept = 600;		//Minimum amount of time after first player connects before patrol launches
DAPE_delayQRF = 30;				// Time before QRF rescue heli launches after the crash
DAPE_interceptorPresent = true;	// TRUE - Interceptor launches and shoots down patrol | FALSE - Only patrol plane flies (Either way, land crash will generate rescue craft)
DAPE_flightTime = 10;			// Maximum time of flight before it self destructs IN MINUTES!
DAPE_AIMoney = 500;				// Max amount of money in AI pockets
DAPE_lootHeliPersist = false;	// TRUE - Vehicle is persistent and uses code defined below | FALSE - vehicle is not persistent
DAPE_lootHeliProtected = true;	// TRUE - Loot heli cannot be shot down in transit     FALSE - Loot heli is vulnerable while it flies in


// Navigation system.  This allows you to define your own waypoints based on your map, or allow the system to select its own
// NOTE: The waypoint finding system is pretty good and should be allowed to work, but if you want to mess with it....
DAPE_useMarkerWaypoints = false;	// FALSE - System generates it's own waypoints.  TRUE - You must define them in x,y
DAPE_wp1 = [8407,10285];			//These work for Tanoa and make the craft fly in a large X across the island
DAPE_wp2 = [2970,3416];				//The patrol aircraft will fly to waypoint 1, then cycle through 4, then back to 1
DAPE_wp3 = [11652,3123];			//The attack aircraft will fly a reverse route
DAPE_wp4 = [3064,11047];			//This will ensure the event plays out the way you want

// This next section defines the models that are used to populate the rescue helicopter. NOTE: You have to use the model of the soldier, as noted
// Some add on packs (ex. Unsung Vietnam) have models that include custom gear.  If you use those and want the custom gear, just plug in their model names
// and change the override variable (DEMS_DAPE_overrideDefaultGear) to false

DAPE_AImodel1 = "O_G_Soldier_TL_F";	// These are the actual models of AI soldiers that will man the rescue mission.  This will 
DAPE_AImodel2 = "O_G_medic_F";		// allow you to incorporate your custom content into the system.  However, remember these
DAPE_AImodel3 = "O_G_Soldier_F";	// are the models, not the clothing, so pay attention to what you put here and look these ones
DAPE_AImodel4 = "O_G_Soldier_AR_F";	// up online first.  They will come with default gear which gets stripped except for clothing
DAPE_overrideDefaultCrewGear = true;// Replaces crew loadout.  If FALSE, leaves default loadout from model
DAPE_overrideDefaultGear = true;	// Replaces rescue AI loadout.  If FALSE, leaves default loadout from model


DAPE_aiItemCount = [3,6]; // The amount [min,max] of items that the AI will carry
DAPE_aiRanks = ["CORPORAL","SERGEANT","LIEUTENANT","CAPTAIN","MAJOR","COLONEL"]; // List of potential AI ranks
DAPE_aiSkill = [0.5,0.6,0.7,0.8,0.9]; // Random skill levels, will apply to overall "skill" 

// Loot amounts (if you want more loot than the heli itself)
DAPE_amountOfWeapons = 5+floor(random 5); 	// Automatically adds 4 magazones per weapon
DAPE_amountOfItems = 7+floor(random 5);		// Backpacks, Items, and explosives

////////////////////////////////////////////////////////////////////////////////////
// AI Vehicles																	////
// Defines what vehicles are used in the mission								////
////////////////////////////////////////////////////////////////////////////////////

DAPE_Air_Patrol = 		[	// Types of vehicles that patrol the map and will be shot down
							// NOTE: These MUST have a default crew assigned to them, otherwise the vehicle will just crash.  Not all content
							// providers crew all vehicles, be sure to test in the editor first toensure they have a deafult crew in the model

							// A-164 Wipeout
							"B_Plane_CAS_01_dynamicLoadout_F",
				
							// MQ-4A Greyhawk (UAV)
							"B_UAV_02_dynamicLoadout_F",
							"O_UAV_02_dynamicLoadout_F",
							"I_UAV_02_dynamicLoadout_F"
						];
						
DAPE_Air_Interceptor = 	[	// Aircraft that will be launched to shoot down the patrol craft
							// NOTE: These MUST have a default crew assigned to them, otherwise the vehicle will just crash.  Not all content
							// providers crew all vehicles, be sure to test in the editor first toensure they have a deafult crew in the model

							// A-143 Buzzard
							"I_Plane_Fighter_03_dynamicLoadout_F",
							//To-199 Neophron
							"O_Plane_CAS_02_dynamicLoadout_F"
						];

DAPE_Air_Rescue_Heli = 	[	// Helicopters that will be dispatched to secure the crash site
							// NOTE: These MUST have a default crew assigned to them, otherwise the vehicle will just crash.  Not all content
							// providers crew all vehicles, be sure to test in the editor first toensure they have a deafult crew in the model
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
						
////////////////////////////////////////////////////////////////////////////////////
// Loot Tables																	////
// Defines what loot can be added to heli										////
////////////////////////////////////////////////////////////////////////////////////

DAPE_lootWeapons = 		[
							"arifle_MXM_Black_F","arifle_MXM_F","srifle_DMR_01_F","srifle_DMR_02_camo_F","srifle_DMR_02_F","srifle_DMR_02_sniper_F",
							"srifle_DMR_03_F","srifle_DMR_03_khaki_F","srifle_DMR_03_multicam_F","srifle_DMR_03_tan_F","srifle_DMR_03_woodland_F",
							"srifle_DMR_04_F","srifle_DMR_04_Tan_F","srifle_DMR_05_blk_F","srifle_DMR_05_hex_F","srifle_DMR_05_tan_f","srifle_DMR_06_camo_F",
							"srifle_DMR_06_olive_F","srifle_EBR_F","srifle_GM6_camo_F","srifle_GM6_F","srifle_LRR_camo_F","srifle_LRR_F",
						 
							"arifle_MX_SW_Black_F","arifle_MX_SW_F","LMG_Mk200_F","MMG_01_hex_F","MMG_01_tan_F","MMG_02_camo_F","MMG_02_black_F",
							"MMG_02_sand_F","LMG_Zafir_F",
						 
							"arifle_Katiba_C_F","arifle_Katiba_F","arifle_Katiba_GL_F","arifle_Mk20_F","arifle_Mk20_GL_F","arifle_Mk20_GL_plain_F",
							"arifle_Mk20_plain_F","arifle_Mk20C_F","arifle_Mk20C_plain_F","arifle_MX_Black_F","arifle_MX_F","arifle_MX_GL_Black_F",
							"arifle_MX_GL_F","arifle_MXC_Black_F","arifle_MXC_F","arifle_SDAR_F","arifle_TRG20_F","arifle_TRG21_F","arifle_TRG21_GL_F"
						];

DAPE_lootMags = 		[
							"HandGrenade","MiniGrenade","B_IR_Grenade","O_IR_Grenade","I_IR_Grenade","1Rnd_HE_Grenade_shell","3Rnd_HE_Grenade_shell",
							"APERSBoundingMine_Range_Mag","APERSMine_Range_Mag","APERSTripMine_Wire_Mag","ClaymoreDirectionalMine_Remote_Mag",
							"DemoCharge_Remote_Mag","IEDLandBig_Remote_Mag","IEDLandSmall_Remote_Mag","IEDUrbanBig_Remote_Mag","IEDUrbanSmall_Remote_Mag",
							"SatchelCharge_Remote_Mag","SLAMDirectionalMine_Wire_Mag"
						];
						
DAPE_lootPacks = 		[
						 
							"B_AssaultPack_blk","B_AssaultPack_cbr","B_AssaultPack_dgtl","B_AssaultPack_khk","B_AssaultPack_mcamo","B_AssaultPack_rgr",
							"B_AssaultPack_sgg","B_FieldPack_blk","B_FieldPack_cbr","B_FieldPack_ocamo","B_FieldPack_oucamo","B_TacticalPack_blk",
							"B_TacticalPack_rgr","B_TacticalPack_ocamo","B_TacticalPack_mcamo","B_TacticalPack_oli","B_Kitbag_cbr","B_Kitbag_mcamo",
							"B_Kitbag_sgg","B_Carryall_cbr","B_Carryall_khk","B_Carryall_mcamo","B_Carryall_ocamo","B_Carryall_oli","B_Carryall_oucamo",
							"B_Bergen_blk","B_Bergen_mcamo","B_Bergen_rgr","B_Bergen_sgg","B_HuntingBackpack","B_OutdoorPack_blk","B_OutdoorPack_blu"
						];
						
DAPE_lootItems = 		[
						 
							"Rangefinder","NVGoggles","NVGoggles_INDEP","NVGoggles_OPFOR"
						];

////////////////////////////////////////////////////////////////////////////////////
// AI Gear																		////
// Defines what gear is applied to the AI										////
////////////////////////////////////////////////////////////////////////////////////
						
DAPE_aiUniform = 		[
							"U_O_Wetsuit","U_O_GhillieSuit","U_O_CombatUniform_oucamo","U_I_OfficerUniform",
							"U_I_CombatUniform_tshirt","U_O_PilotCoveralls","U_OG_Guerilla3_2","U_O_CombatUniform_ocamo"
						];


DAPE_aiBackpack = 		[
							"B_AssaultPack_blk","B_AssaultPack_cbr","B_AssaultPack_dgtl","B_AssaultPack_khk","B_AssaultPack_mcamo","B_AssaultPack_rgr",
							"B_AssaultPack_sgg","B_FieldPack_blk","B_FieldPack_cbr","B_FieldPack_ocamo","B_FieldPack_oucamo","B_TacticalPack_blk",
							"B_TacticalPack_rgr","B_TacticalPack_ocamo","B_TacticalPack_mcamo","B_TacticalPack_oli","B_Kitbag_cbr","B_Kitbag_mcamo",
							"B_Kitbag_sgg","B_Carryall_cbr","B_Carryall_khk","B_Carryall_mcamo","B_Carryall_ocamo","B_Carryall_oli","B_Carryall_oucamo",
							"B_Bergen_blk","B_Bergen_mcamo","B_Bergen_rgr","B_Bergen_sgg","B_HuntingBackpack","B_OutdoorPack_blk","B_OutdoorPack_blu"
						];

DAPE_aiVest = 			[
							"V_PlateCarrier1_rgr","V_PlateCarrier2_blk","V_PlateCarrierL_CTRG","V_PlateCarrierH_CTRG",
							"V_PlateCarrierIA1_dgtl","V_PlateCarrierGL_mtp","V_PlateCarrierGL_blk","V_PlateCarrierGL_rgr",
							"V_PlateCarrier3_rgr"
						];

DAPE_aiHeadgear =		[
							"H_PilotHelmetFighter_I","H_PilotHelmetHeli_I","H_CrewHelmetHeli_I","H_HelmetO_ocamo","H_HelmetSpecO_blk"
						];

DAPE_aiMags = 			[
							"HandGrenade","HandGrenade","HandGrenade","HandGrenade","HandGrenade","HandGrenade",
							"APERSBoundingMine_Range_Mag","APERSMine_Range_Mag","RPG32_HE_F"
						];
						
DAPE_aiItems = 			[
							"Rangefinder","optic_Nightstalker","Rangefinder"
						];