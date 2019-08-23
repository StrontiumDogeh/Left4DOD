/**
 * =============================================================================
 * SourceMod Left4DoD for Day of Defeat Source
 * (C)2009 - 2010 Dog - www.theville.org
 *
 * SourceMod (C)2004-2008 AlliedModders LLC.  All rights reserved.
 * =============================================================================
 *
 * This program is free software; you can redistribute it and/or modify it under
 * the terms of the GNU General Public License, version 3.0, as published by the
 * Free Software Foundation.
 * 
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
 * details.
 *
 * You should have received a copy of the GNU General Public License along with
 * this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * As a special exception, AlliedModders LLC gives you permission to link the
 * code of this program (as well as its derivative works) to "Half-Life 2," the
 * "Source Engine," the "SourcePawn JIT," and any Game MODs that run on software
 * by the Valve Corporation.  You must obey the GNU General Public License in
 * all respects for all other code used.  Additionally, AlliedModders LLC grants
 * this exception to all derivative works.  AlliedModders LLC defines further
 * exceptions, found in LICENSE.txt (as of this writing, version JULY-31-2007),
 * or <http://www.sourcemod.net/license.php>.
 *
 */
 
public OnMapStart()
{
	SetLightStyle(0,"bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbabbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbba");
	SetRandomSeed(GetTime());
	new rndSky = GetRandomInt(0,6);
	
	switch (rndSky)
	{
		case 0:
		{
			ServerCommand("sv_skyname sky_day01_09");
			g_iWeather = 3;
			PrintToServer("[L4DOD] Weather type: Snow");
		}
		
		case 1:
		{
			ServerCommand("sv_skyname sky_borealis01");
			g_iWeather = 3;
			PrintToServer("[L4DOD] Weather type: Snow");
		}
			
		case 2:
		{
			ServerCommand("sv_skyname sky_dod_09_hdr");
			g_iWeather = 0;
			PrintToServer("[L4DOD] Weather type: Rain");
		}
			
		case 3:
		{
			ServerCommand("sv_skyname sky_dod_10_hdr");
			g_iWeather = 0;
			PrintToServer("[L4DOD] Weather type: Rain");
		}
			
		case 4:
		{
			ServerCommand("sv_skyname sky_day01_08");
			g_iWeather = -1;
			PrintToServer("[L4DOD] Weather type: Clear");
		}
		
		case 5:
		{
			ServerCommand("sv_skyname sky_day03_06");
			g_iWeather = -1;
			PrintToServer("[L4DOD] Weather type: Clear");
		}
		
		case 6:
		{
			ServerCommand("sv_skyname sky_day02_09");
			g_iWeather = 0;
			PrintToServer("[L4DOD] Weather type: Rain");
		}
		
		default:
		{
			ServerCommand("sv_skyname sky_borealis01");
			g_iWeather = 3;
			PrintToServer("[L4DOD] Weather type: Snow");
		}
	}
			
	// Get the name of the map 
	GetCurrentMap(g_szMapName, sizeof(g_szMapName));
	
	decl String:logpath[PLATFORM_MAX_PATH];
	FormatTime(logpath, sizeof(logpath), "logs/l4dod%Y%m%d.log");
	BuildPath(Path_SM, g_szLogFileName, PLATFORM_MAX_PATH, logpath);

	LogToFileEx(g_szLogFileName, "-----------------------------------------------------");
	LogToFileEx(g_szLogFileName, "[L4DOD] Map: %s", g_szMapName);
	
	if (StrContains(g_szMapName, "dod_carrion", false) != -1)
		g_mapType = 1;
	else 
		g_mapType = 0;
		
	//Load the flag and waypoint data
	for (new i=1; i <=8; i++)
	{
		g_iAxisKeys[i] = 0;
		g_iAlliesKeys[i] = 0;
	}
	
	//Add extra spawn points if any
	g_bSpawnData = false;
	GetSpawnPointsData();
	
	//Reset Rounds
	g_iCurrentRound = 0;
	
	//Reset Waiting For Players timer
	g_iWaitCount = 40;
	
	if (!GetFlagData())
	{
		//LogError("[L4DOD] NO FLAG DATA FOUND");
		g_bFlagData = false;
	}
	else
		g_bFlagData = true;
		
	decl String:datapath[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, datapath, PLATFORM_MAX_PATH, "data/bot_%s.nav", g_szMapName);
		
	if (!FileExists(datapath))
	{
		LogError("[L4DOD] %s not found", datapath);
		LogError("[L4DOD] Disabling Mod");
		LogError("[L4DOD] When you have added waypoints, reload the map");
		LogError("[L4DOD] Switching on Setup Mode");

		SetConVarInt(hL4DSetup, 1);
		SetConVarInt(hL4DOn, 0);
		CreateTimer(2.0, RemoveAllBots, 0, TIMER_FLAG_NO_MAPCHANGE);
	}
	else
	{
		SetConVarInt(hL4DSetup, 0);
		SetConVarInt(hL4DOn, 1);
		
		//Load the waypoints for bots
		if (!GetMapData())
		{
			LogToFileEx(g_szLogFileName,"[L4DOD] ** W A R N I N G **");
			LogToFileEx(g_szLogFileName,"[L4DOD] Unable to load waypoints");
			SetConVarInt(hL4DSetup, 1);
			SetConVarInt(hL4DOn, 0);
		}
	}
	
	CreateTimer(1.1, SetUp, 0, TIMER_FLAG_NO_MAPCHANGE);
			
	//Particle Files
	AddFileToDownloadsTable("particles/blood_impact.pcf");
	AddFileToDownloadsTable("particles/water_impact.pcf");
	AddFileToDownloadsTable("particles/fire_01.pcf");
	
	PrecacheParticleSystem("blood_impact_green_01_droplets");
	PrecacheParticleSystem("fire_jet_01_flame");
	
	new String:filen[64];
	Format(filen, sizeof(filen),"maps/%s_particles.txt", g_szMapName);
	AddFileToDownloadsTable(filen);
	
	//Models files
	AddFileToDownloadsTable("models/player/german_zombie.dx80.vtx");
	AddFileToDownloadsTable("models/player/german_zombie.dx90.vtx");
	AddFileToDownloadsTable("models/player/german_zombie.mdl");
	AddFileToDownloadsTable("models/player/german_zombie.phy");
	AddFileToDownloadsTable("models/player/german_zombie.sw.vtx");
	AddFileToDownloadsTable("models/player/german_zombie.vvd");
	AddFileToDownloadsTable("models/player/german_theone.dx80.vtx");
	AddFileToDownloadsTable("models/player/german_theone.dx90.vtx");
	AddFileToDownloadsTable("models/player/german_theone.mdl");
	AddFileToDownloadsTable("models/player/german_theone.phy");
	AddFileToDownloadsTable("models/player/german_theone.sw.vtx");
	AddFileToDownloadsTable("models/player/german_theone.vvd");
	AddFileToDownloadsTable("models/player/german_emo.dx80.vtx");
	AddFileToDownloadsTable("models/player/german_emo.dx90.vtx");
	AddFileToDownloadsTable("models/player/german_emo.mdl");
	AddFileToDownloadsTable("models/player/german_emo.phy");
	AddFileToDownloadsTable("models/player/german_emo.sw.vtx");
	AddFileToDownloadsTable("models/player/german_emo.vvd");
	AddFileToDownloadsTable("models/player/german_gasman.dx80.vtx");
	AddFileToDownloadsTable("models/player/german_gasman.dx90.vtx");
	AddFileToDownloadsTable("models/player/german_gasman.mdl");
	AddFileToDownloadsTable("models/player/german_gasman.phy");
	AddFileToDownloadsTable("models/player/german_gasman.sw.vtx");
	AddFileToDownloadsTable("models/player/german_gasman.vvd");
	AddFileToDownloadsTable("models/player/techknow/left4dead/witch.dx80.vtx");
	AddFileToDownloadsTable("models/player/techknow/left4dead/witch.dx90.vtx");
	AddFileToDownloadsTable("models/player/techknow/left4dead/witch.mdl");
	AddFileToDownloadsTable("models/player/techknow/left4dead/witch.phy");
	AddFileToDownloadsTable("models/player/techknow/left4dead/witch.sw.vtx");
	AddFileToDownloadsTable("models/player/techknow/left4dead/witch.vvd");
	AddFileToDownloadsTable("models/player/techknow/left4dead/witch.xbox.vtx");
	AddFileToDownloadsTable("models/player/german_traitor.dx80.vtx");
	AddFileToDownloadsTable("models/player/german_traitor.dx90.vtx");
	AddFileToDownloadsTable("models/player/german_traitor.mdl");
	AddFileToDownloadsTable("models/player/german_traitor.phy");
	AddFileToDownloadsTable("models/player/german_traitor.sw.vtx");
	AddFileToDownloadsTable("models/player/german_traitor.vvd");
	AddFileToDownloadsTable("models/player/german_speedo.dx80.vtx");
	AddFileToDownloadsTable("models/player/german_speedo.dx90.vtx");
	AddFileToDownloadsTable("models/player/german_speedo.mdl");
	AddFileToDownloadsTable("models/player/german_speedo.phy");
	AddFileToDownloadsTable("models/player/german_speedo.sw.vtx");
	AddFileToDownloadsTable("models/player/german_speedo.vvd");
	AddFileToDownloadsTable("models/player/german_speedo.xbox.vtx");
	AddFileToDownloadsTable("models/player/techknow/left4dead/hunter.dx80.vtx");
	AddFileToDownloadsTable("models/player/techknow/left4dead/hunter.dx90.vtx");
	AddFileToDownloadsTable("models/player/techknow/left4dead/hunter.mdl");
	AddFileToDownloadsTable("models/player/techknow/left4dead/hunter.phy");
	AddFileToDownloadsTable("models/player/techknow/left4dead/hunter.sw.vtx");
	AddFileToDownloadsTable("models/player/techknow/left4dead/hunter.vvd");
	AddFileToDownloadsTable("models/player/techknow/left4dead/hunter.xbox.vtx");
	AddFileToDownloadsTable("models/player/wraith/german_wraith.dx80.vtx");
	AddFileToDownloadsTable("models/player/wraith/german_wraith.dx90.vtx");
	AddFileToDownloadsTable("models/player/wraith/german_wraith.mdl");
	AddFileToDownloadsTable("models/player/wraith/german_wraith.phy");
	AddFileToDownloadsTable("models/player/wraith/german_wraith.sw.vtx");
	AddFileToDownloadsTable("models/player/wraith/german_wraith.vvd");
	AddFileToDownloadsTable("models/player/wraith/german_wraith.xbox.vtx");
	AddFileToDownloadsTable("models/player/russianarmy/zombie/bones.dx80.vtx");
	AddFileToDownloadsTable("models/player/russianarmy/zombie/bones.dx90.vtx");
	AddFileToDownloadsTable("models/player/russianarmy/zombie/bones.mdl");
	AddFileToDownloadsTable("models/player/russianarmy/zombie/bones.phy");
	AddFileToDownloadsTable("models/player/russianarmy/zombie/bones.sw.vtx");
	AddFileToDownloadsTable("models/player/russianarmy/zombie/bones.vvd");
	AddFileToDownloadsTable("models/player/russianarmy/zombie/bones.xbox.vtx");
	AddFileToDownloadsTable("models/player/russianarmy/zombie/hellknight.dx80.vtx");
	AddFileToDownloadsTable("models/player/russianarmy/zombie/hellknight.dx90.vtx");
	AddFileToDownloadsTable("models/player/russianarmy/zombie/hellknight.mdl");
	AddFileToDownloadsTable("models/player/russianarmy/zombie/hellknight.phy");
	AddFileToDownloadsTable("models/player/russianarmy/zombie/hellknight.sw.vtx");
	AddFileToDownloadsTable("models/player/russianarmy/zombie/hellknight.vvd");
	AddFileToDownloadsTable("models/player/russianarmy/zombie/hellknight.xbox.vtx");
	
	AddFileToDownloadsTable("models/left4dod/medic_pack.dx80.vtx");
	AddFileToDownloadsTable("models/left4dod/medic_pack.dx90.vtx");
	AddFileToDownloadsTable("models/left4dod/medic_pack.mdl");
	AddFileToDownloadsTable("models/left4dod/medic_pack.phy");
	AddFileToDownloadsTable("models/left4dod/medic_pack.sw.vtx");
	AddFileToDownloadsTable("models/left4dod/medic_pack.vvd");
	AddFileToDownloadsTable("models/left4dod/oneshot.dx80.vtx");
	AddFileToDownloadsTable("models/left4dod/oneshot.dx90.vtx");
	AddFileToDownloadsTable("models/left4dod/oneshot.mdl");
	AddFileToDownloadsTable("models/left4dod/oneshot.phy");
	AddFileToDownloadsTable("models/left4dod/oneshot.sw.vtx");
	AddFileToDownloadsTable("models/left4dod/oneshot.vvd");		
	
	AddFileToDownloadsTable("models/models_kit/hallo_pumpkin_s.dx90.vtx");
	AddFileToDownloadsTable("models/models_kit/hallo_pumpkin_s.dx80.vtx");
	AddFileToDownloadsTable("models/models_kit/hallo_pumpkin_s.xbox.vtx");
	AddFileToDownloadsTable("models/models_kit/hallo_pumpkin_s.mdl");
	AddFileToDownloadsTable("models/models_kit/hallo_pumpkin_s.phy");
	AddFileToDownloadsTable("models/models_kit/hallo_pumpkin_s.sw.vtx");
	AddFileToDownloadsTable("models/models_kit/hallo_pumpkin_s.vvd");	
	
	AddFileToDownloadsTable("models/parachute/parachute_carbon.dx90.vtx");
	AddFileToDownloadsTable("models/parachute/parachute_carbon.dx80.vtx");
	AddFileToDownloadsTable("models/parachute/parachute_carbon.xbox.vtx");
	AddFileToDownloadsTable("models/parachute/parachute_carbon.mdl");
	AddFileToDownloadsTable("models/parachute/parachute_carbon.sw.vtx");
	AddFileToDownloadsTable("models/parachute/parachute_carbon.vvd");	
	
	//Materials files
	AddFileToDownloadsTable("materials/models/player/zombie/german_body.vmt");
	AddFileToDownloadsTable("materials/models/player/zombie/german_body.vtf");
	AddFileToDownloadsTable("materials/models/player/zombie/german_gear.vmt");
	AddFileToDownloadsTable("materials/models/player/zombie/german_gear.vtf");
	AddFileToDownloadsTable("materials/models/player/theone/german_body.vmt");
	AddFileToDownloadsTable("materials/models/player/theone/german_body.vtf");
	AddFileToDownloadsTable("materials/models/player/theone/german_gear.vmt");
	AddFileToDownloadsTable("materials/models/player/theone/german_gear.vtf");
	AddFileToDownloadsTable("materials/models/player/emo/german_body.vmt");
	AddFileToDownloadsTable("materials/models/player/emo/german_body.vtf");
	AddFileToDownloadsTable("materials/models/player/emo/german_gear.vmt");
	AddFileToDownloadsTable("materials/models/player/emo/german_gear.vtf");
	AddFileToDownloadsTable("materials/models/player/gasman/german_body.vmt");
	AddFileToDownloadsTable("materials/models/player/gasman/german_body.vtf");
	AddFileToDownloadsTable("materials/models/player/gasman/german_gear.vmt");
	AddFileToDownloadsTable("materials/models/player/gasman/german_gear.vtf");
	AddFileToDownloadsTable("materials/models/player/techknow/l4d/witch.vmt");
	AddFileToDownloadsTable("materials/models/player/techknow/l4d/witch.vtf");
	AddFileToDownloadsTable("materials/models/player/techknow/l4d/witch_hair.vmt");
	AddFileToDownloadsTable("materials/models/player/techknow/l4d/witch_hair.vtf");
	AddFileToDownloadsTable("materials/models/player/techknow/l4d/witch_n.vtf");
	AddFileToDownloadsTable("materials/models/player/traitor/american_gear.vmt");
	AddFileToDownloadsTable("materials/models/player/traitor/american_gear.vtf");
	AddFileToDownloadsTable("materials/models/player/traitor/american_body.vmt");
	AddFileToDownloadsTable("materials/models/player/traitor/american_body.vtf");
	AddFileToDownloadsTable("materials/models/player/speedo/german_body.vmt");
	AddFileToDownloadsTable("materials/models/player/speedo/german_body.vtf");
	AddFileToDownloadsTable("materials/models/player/techknow/l4d/hunter.vmt");
	AddFileToDownloadsTable("materials/models/player/techknow/l4d/hunter.vtf");
	AddFileToDownloadsTable("materials/models/player/techknow/l4d/hunter.vtf");
	AddFileToDownloadsTable("materials/models/player/wraith/german_body.vmt");
	AddFileToDownloadsTable("materials/models/player/wraith/german_body.vtf");
	AddFileToDownloadsTable("materials/models/player/rac/bones/slow_bones.vtf");
	AddFileToDownloadsTable("materials/models/player/rac/bones/slow_bones.vmt");
	AddFileToDownloadsTable("materials/models/player/rac/bones/slow_bones_bump.vtf");
	AddFileToDownloadsTable("materials/models/player/rac/hellknight/estuche.vtf");
	AddFileToDownloadsTable("materials/models/player/rac/hellknight/estuche.vmt");
	AddFileToDownloadsTable("materials/models/player/rac/hellknight/hellknight.vtf");
	AddFileToDownloadsTable("materials/models/player/rac/hellknight/hellknight.vmt");
	AddFileToDownloadsTable("materials/models/player/rac/hellknight/hellknight_normal.vtf");
			
	AddFileToDownloadsTable("materials/models/left4dod/medic_pack.vmt");
	AddFileToDownloadsTable("materials/models/left4dod/medic_pack.vtf");	
	AddFileToDownloadsTable("materials/models/left4dod/oneshot.vmt");
	AddFileToDownloadsTable("materials/models/left4dod/oneshot.vtf");
	
	AddFileToDownloadsTable("materials/sprites/player_icons/american01.vmt");
	AddFileToDownloadsTable("materials/sprites/player_icons/american01.vtf");
	AddFileToDownloadsTable("materials/sprites/player_icons/american02.vmt");
	AddFileToDownloadsTable("materials/sprites/player_icons/american02.vtf");
	AddFileToDownloadsTable("materials/sprites/player_icons/american03.vmt");
	AddFileToDownloadsTable("materials/sprites/player_icons/american03.vtf");
	AddFileToDownloadsTable("materials/sprites/player_icons/american04.vmt");
	AddFileToDownloadsTable("materials/sprites/player_icons/american04.vtf");
	AddFileToDownloadsTable("materials/sprites/player_icons/american05.vmt");
	AddFileToDownloadsTable("materials/sprites/player_icons/american05.vtf");
	AddFileToDownloadsTable("materials/sprites/player_icons/american06.vmt");
	AddFileToDownloadsTable("materials/sprites/player_icons/american06.vtf");
	AddFileToDownloadsTable("materials/sprites/player_icons/american07.vmt");
	AddFileToDownloadsTable("materials/sprites/player_icons/american07.vtf");
	AddFileToDownloadsTable("materials/sprites/player_icons/american08.vmt");
	AddFileToDownloadsTable("materials/sprites/player_icons/american08.vtf");
	
	AddFileToDownloadsTable("materials/left4dod/overlay_io_01a.vmt");
	AddFileToDownloadsTable("materials/left4dod/overlay_io_01a.vtf");
	AddFileToDownloadsTable("materials/left4dod/overlay_emo_01a.vmt");
	AddFileToDownloadsTable("materials/left4dod/overlay_emo_01a.vtf");
	AddFileToDownloadsTable("materials/left4dod/overlay_grey_01a.vmt");
	AddFileToDownloadsTable("materials/left4dod/overlay_grey_01a.vtf");
	AddFileToDownloadsTable("materials/left4dod/overlay_witch_01a.vmt");
	AddFileToDownloadsTable("materials/left4dod/overlay_witch_01a.vtf");
	AddFileToDownloadsTable("materials/left4dod/overlay_gas_01a.vmt");
	AddFileToDownloadsTable("materials/left4dod/overlay_gas_01a.vtf");
	AddFileToDownloadsTable("materials/left4dod/overlay_anarchist_01a.vmt");
	AddFileToDownloadsTable("materials/left4dod/overlay_anarchist_01a.vtf");
	AddFileToDownloadsTable("materials/left4dod/overlay_wraith_01a.vmt");
	AddFileToDownloadsTable("materials/left4dod/overlay_wraith_01a.vtf");
	
	AddFileToDownloadsTable("materials/left4dod/overlay_tnt.vtf");
	AddFileToDownloadsTable("materials/left4dod/overlay_tnt.vmt");
	AddFileToDownloadsTable("materials/left4dod/overlay_shield.vtf");
	AddFileToDownloadsTable("materials/left4dod/overlay_shield.vmt");
	AddFileToDownloadsTable("materials/left4dod/overlay_radio.vtf");
	AddFileToDownloadsTable("materials/left4dod/overlay_radio.vmt");
	AddFileToDownloadsTable("materials/left4dod/overlay_tnt_zb.vtf");
	AddFileToDownloadsTable("materials/left4dod/overlay_tnt_zb.vmt");
	AddFileToDownloadsTable("materials/left4dod/overlay_shield_zb.vtf");
	AddFileToDownloadsTable("materials/left4dod/overlay_shield_zb.vmt");
	AddFileToDownloadsTable("materials/left4dod/overlay_radio_zb.vtf");
	AddFileToDownloadsTable("materials/left4dod/overlay_radio_zb.vmt");
	
	AddFileToDownloadsTable("materials/left4dod/overlay_io_02a.vmt");
	AddFileToDownloadsTable("materials/left4dod/overlay_io_02a.vtf");
	AddFileToDownloadsTable("materials/left4dod/overlay_emo_02a.vmt");
	AddFileToDownloadsTable("materials/left4dod/overlay_emo_02a.vtf");
	AddFileToDownloadsTable("materials/left4dod/overlay_grey_02a.vmt");
	AddFileToDownloadsTable("materials/left4dod/overlay_grey_02a.vtf");
	AddFileToDownloadsTable("materials/left4dod/overlay_witch_02a.vmt");
	AddFileToDownloadsTable("materials/left4dod/overlay_witch_02a.vtf");
	AddFileToDownloadsTable("materials/left4dod/overlay_gas_02a.vmt");
	AddFileToDownloadsTable("materials/left4dod/overlay_gas_02a.vtf");
	AddFileToDownloadsTable("materials/left4dod/overlay_anarchist_02a.vmt");
	AddFileToDownloadsTable("materials/left4dod/overlay_anarchist_02a.vtf");
	AddFileToDownloadsTable("materials/left4dod/overlay_wraith_02a.vmt");
	AddFileToDownloadsTable("materials/left4dod/overlay_wraith_02a.vtf");
	
	AddFileToDownloadsTable("models/stickynades/stickynades_red.mdl");
	AddFileToDownloadsTable("models/stickynades/stickynades_blue.mdl");
	
	AddFileToDownloadsTable("materials/left4dod/zvision.vmt");
	AddFileToDownloadsTable("materials/left4dod/zvision.vtf");
	AddFileToDownloadsTable("materials/left4dod/zvision002.vmt");
	AddFileToDownloadsTable("materials/left4dod/zvision002.vtf");
	AddFileToDownloadsTable("materials/particle/particledefault.vmt");
			
	AddFileToDownloadsTable("materials/sprites/player_icons/human.vmt");
	AddFileToDownloadsTable("materials/sprites/player_icons/human.vtf");
	AddFileToDownloadsTable("materials/sprites/player_icons/human50.vmt");
	AddFileToDownloadsTable("materials/sprites/player_icons/human50.vtf");
	AddFileToDownloadsTable("materials/sprites/player_icons/human75.vmt");
	AddFileToDownloadsTable("materials/sprites/player_icons/human75.vtf");
	AddFileToDownloadsTable("materials/sprites/player_icons/human200.vmt");
	AddFileToDownloadsTable("materials/sprites/player_icons/human200.vtf");
	AddFileToDownloadsTable("materials/sprites/player_icons/human400.vmt");
	AddFileToDownloadsTable("materials/sprites/player_icons/human400.vtf");
	AddFileToDownloadsTable("materials/sprites/player_icons/zombie001.vmt");
	AddFileToDownloadsTable("materials/sprites/player_icons/zombie001.vtf");
	
	AddFileToDownloadsTable("materials/models/models_kit/hallo_pumpkin.vmt");
	AddFileToDownloadsTable("materials/models/models_kit/hallo_pumpkin.vtf");
	AddFileToDownloadsTable("materials/models/models_kit/hallo_pumpkin_skin2.vmt");
	AddFileToDownloadsTable("materials/models/models_kit/hallo_pumpkin_skin2.vtf");
	
	AddFileToDownloadsTable("materials/models/parachute/pack_carbon.vtf");
	AddFileToDownloadsTable("materials/models/parachute/pack_carbon.vmt");
	AddFileToDownloadsTable("materials/models/parachute/parachute_carbon.vtf");
	AddFileToDownloadsTable("materials/models/parachute/parachute_carbon.vmt");
	
	AddFileToDownloadsTable("materials/effects/fleck_ash1.vtf");
	AddFileToDownloadsTable("materials/effects/fleck_ash1.vmt");
	AddFileToDownloadsTable("materials/effects/fleck_ash2.vtf");
	AddFileToDownloadsTable("materials/effects/fleck_ash2.vmt");
	AddFileToDownloadsTable("materials/effects/fleck_ash3.vtf");
	AddFileToDownloadsTable("materials/effects/fleck_ash3.vmt");
					
	PrecacheModel("models/player/german_zombie.mdl", true);
	PrecacheModel("models/player/german_theone.mdl", true);
	PrecacheModel("models/player/german_emo.mdl", true);
	PrecacheModel("models/player/german_gasman.mdl", true);
	PrecacheModel("models/player/german_speedo.mdl", true);
	PrecacheModel("models/zombie/classic.mdl", true);
	PrecacheModel("models/player/techknow/left4dead/witch.mdl", true);
	PrecacheModel("models/player/techknow/left4dead/hunter.mdl", true);
	PrecacheModel("models/player/german_traitor.mdl", true);
	PrecacheModel("models/player/wraith/german_wraith.mdl", true);
	PrecacheModel("models/player/russianarmy/zombie/bones.mdl", true);
	PrecacheModel("models/player/russianarmy/zombie/hellknight.mdl", true);
	
	PrecacheModel("models/ammo/ammo_axis.mdl", true);
	PrecacheModel("models/ammo/ammo_us.mdl", true);
	
	PrecacheModel("models/left4dod/medic_pack.mdl", true);
	PrecacheModel("models/props_junk/propane_tank001a.mdl", true);
	PrecacheModel("models/items/battery.mdl", true);
	PrecacheModel("models/items/HealthKit.mdl", true);
	PrecacheModel("models/props_lab/jar01a.mdl", true);
	PrecacheModel("models/props_lab/jar01b.mdl", true);
	PrecacheModel("models/props_junk/glassjug01.mdl", true);
	PrecacheModel("models/props_junk/glassjug01_chunk01.mdl", true);
	PrecacheModel("models/props_junk/glassjug01_chunk02.mdl", true);
	PrecacheModel("models/props_junk/glassjug01_chunk03.mdl", true);
	PrecacheModel("models/props_junk/PopCan01a.mdl", true);
	PrecacheModel("models/healthvial.mdl", true);
	PrecacheModel("models/gibs/hgibs.mdl", true);
	PrecacheModel("models/gibs/hgibs_scapula.mdl", true);
	PrecacheModel("models/gibs/hgibs_spine.mdl", true);
	PrecacheModel("models/helmets/helmet_german.mdl", true);
	PrecacheModel("models/helmets/helmet_american.mdl", true);
	PrecacheModel("models/weapons/w_tnt.mdl", true);
	PrecacheModel("models/weapons/w_tnt_red.mdl", true);
	PrecacheModel("models/weapons/w_tnt_grey.mdl", true);
	PrecacheModel("models/props_misc/german_radio.mdl", true);
	PrecacheModel("models/shells/shell_large.mdl", true);
	
	PrecacheModel("models/props_debris/metal_panel02a.mdl", true);
	PrecacheModel("models/props_debris/metal_panelchunk02d.mdl", true);
	PrecacheModel("models/props_debris/metal_panelchunk01a.mdl", true);
	PrecacheModel("models/props_debris/metal_panelchunk01b.mdl", true);
	PrecacheModel("models/props_debris/metal_panelchunk01c.mdl", true);
	PrecacheModel("models/props_debris/metal_panelchunk01d.mdl", true);
	PrecacheModel("models/props_debris/metal_panelchunk01e.mdl", true);
	PrecacheModel("models/props_debris/metal_panelchunk02e.mdl", true);
	PrecacheModel("models/props_debris/metal_panelshard01a.mdl", true);
	PrecacheModel("models/props_debris/metal_panelshard01b.mdl", true);
	PrecacheModel("models/props_debris/metal_panelshard01c.mdl", true);
	PrecacheModel("models/props_debris/metal_panelshard01d.mdl", true);
	PrecacheModel("models/props_debris/metal_panelshard01e.mdl", true);
	
	PrecacheModel("models/models_kit/hallo_pumpkin_s.mdl", true);
	PrecacheModel("models/parachute/parachute_carbon.mdl", true);
	
	PrecacheModel("models/weapons/w_bugbait.mdl", true);
	
	PrecacheModel("materials/particle/particle_smokegrenade.vtf", true);
	PrecacheModel("materials/particle/particle_smokegrenade1.vmt", true);
	
	PrecacheModel("materials/effects/fleck_ash1.vmt", true);
	PrecacheModel("materials/effects/fleck_ash2.vmt", true);
	PrecacheModel("materials/effects/fleck_ash3.vmt", true);
					
	g_AxisSpriteModel[0] = PrecacheModel("materials/sprites/player_icons/american01.vmt", true);
	g_AxisSpriteModel[1] = PrecacheModel("materials/sprites/player_icons/american02.vmt", true);
	g_AxisSpriteModel[2] = PrecacheModel("materials/sprites/player_icons/american03.vmt", true);
	g_AxisSpriteModel[3] = PrecacheModel("materials/sprites/player_icons/american04.vmt", true);
	g_AxisSpriteModel[4] = PrecacheModel("materials/sprites/player_icons/american05.vmt", true);
	g_AxisSpriteModel[5] = PrecacheModel("materials/sprites/player_icons/american06.vmt", true);
	g_AxisSpriteModel[6] = PrecacheModel("materials/sprites/player_icons/american07.vmt", true);
	g_AxisSpriteModel[7] = PrecacheModel("materials/sprites/player_icons/american08.vmt", true);
	
	g_AlliedSpriteModel   = PrecacheModel("materials/sprites/player_icons/human.vmt", true);
	g_AlliedSpriteModel50 = PrecacheModel("materials/sprites/player_icons/human50.vmt", true);
	g_AlliedSpriteModel75 = PrecacheModel("materials/sprites/player_icons/human75.vmt", true);
	g_AlliedSpriteModel200 = PrecacheModel("materials/sprites/player_icons/human200.vmt", true);
	g_AlliedSpriteModel400 = PrecacheModel("materials/sprites/player_icons/human400.vmt", true);
	
	g_AxisHumanSpriteModel = PrecacheModel("materials/sprites/player_icons/zombie001.vmt", true);
	
	PrecacheModel("materials/left4dod/overlay_anarchist_01a.vmt", true);
	PrecacheModel("materials/left4dod/overlay_io_01a.vmt", true);
	PrecacheModel("materials/left4dod/overlay_emo_01a.vmt", true);
	PrecacheModel("materials/left4dod/overlay_witch_01a.vmt", true);
	PrecacheModel("materials/left4dod/overlay_grey_01a.vmt", true);
	PrecacheModel("materials/left4dod/overlay_gas_01a.vmt", true);
	PrecacheModel("materials/left4dod/overlay_wraith_01a.vmt", true);
	
	PrecacheModel("materials/left4dod/overlay_anarchist_02a.vmt", true);
	PrecacheModel("materials/left4dod/overlay_io_02a.vmt", true);
	PrecacheModel("materials/left4dod/overlay_emo_02a.vmt", true);
	PrecacheModel("materials/left4dod/overlay_witch_02a.vmt", true);
	PrecacheModel("materials/left4dod/overlay_grey_02a.vmt", true);
	PrecacheModel("materials/left4dod/overlay_gas_02a.vmt", true);
	PrecacheModel("materials/left4dod/overlay_wraith_02a.vmt", true);
	
	PrecacheModel("materials/left4dod/overlay_tnt_zb.vmt", true);
	PrecacheModel("materials/left4dod/overlay_shield_zb.vmt", true);
	PrecacheModel("materials/left4dod/overlay_radio_zb.vmt", true);
	PrecacheModel("materials/left4dod/overlay_tnt_zb.vmt", true);
	PrecacheModel("materials/left4dod/overlay_shield_zb.vmt", true);
	PrecacheModel("materials/left4dod/overlay_radio_zb.vmt", true);
	
	PrecacheModel("materials/left4dod/zvision.vmt", true);
	PrecacheModel("materials/left4dod/zvision002.vmt", true);
	
	// Ambient sounds and sound effects
	AddFileToDownloadsTable("sound/ambient/left4dod.mp3");
	AddFileToDownloadsTable("sound/left4dod/allied_win.mp3");
	AddFileToDownloadsTable("sound/left4dod/zombie_win.mp3");
	AddFileToDownloadsTable("sound/left4dod/l4dod_intro.mp3");
	AddFileToDownloadsTable("sound/left4dod/end001.mp3");
	AddFileToDownloadsTable("sound/left4dod/end002.mp3");
	AddFileToDownloadsTable("sound/left4dod/end003.mp3");
	AddFileToDownloadsTable("sound/left4dod/gasbomb.wav");
	AddFileToDownloadsTable("sound/left4dod/hooch_groan.mp3");
	AddFileToDownloadsTable("sound/left4dod/hooch_drink.mp3");
	AddFileToDownloadsTable("sound/left4dod/fireball.mp3");
	AddFileToDownloadsTable("sound/left4dod/fire.mp3");
	AddFileToDownloadsTable("sound/left4dod/fire_5.mp3");
	AddFileToDownloadsTable("sound/left4dod/steam2.mp3");
	AddFileToDownloadsTable("sound/left4dod/prop.mp3");
	AddFileToDownloadsTable("sound/left4dod/squelch.mp3");
	AddFileToDownloadsTable("sound/left4dod/oneshot.mp3");
	AddFileToDownloadsTable("sound/left4dod/cough01.mp3");
	
	AddFileToDownloadsTable("sound/left4dod/witch/witch001.mp3");
	AddFileToDownloadsTable("sound/left4dod/witch/witch002.mp3");
	AddFileToDownloadsTable("sound/left4dod/witch/witch003.mp3");
	AddFileToDownloadsTable("sound/left4dod/witch/witch004.mp3");
	AddFileToDownloadsTable("sound/left4dod/witch/witch005.mp3");
	AddFileToDownloadsTable("sound/left4dod/witch/witch006.mp3");
	
	AddFileToDownloadsTable("sound/left4dod/zombie/zombie001.mp3");
	AddFileToDownloadsTable("sound/left4dod/zombie/zombie002.mp3");
	AddFileToDownloadsTable("sound/left4dod/zombie/zombie003.mp3");
	AddFileToDownloadsTable("sound/left4dod/zombie/zombie004.mp3");
	AddFileToDownloadsTable("sound/left4dod/zombie/zombie005.mp3");
	AddFileToDownloadsTable("sound/left4dod/zombie/zombie006.mp3");
	AddFileToDownloadsTable("sound/left4dod/zombie/zombie007.mp3");
	AddFileToDownloadsTable("sound/left4dod/zombie/zombie008.mp3");
	AddFileToDownloadsTable("sound/left4dod/zombie/zombie009.mp3");
	AddFileToDownloadsTable("sound/left4dod/zombie/zombie010.mp3");
	AddFileToDownloadsTable("sound/left4dod/zombie/zombie011.mp3");
	AddFileToDownloadsTable("sound/left4dod/zombie/zombie012.mp3");
	AddFileToDownloadsTable("sound/left4dod/zombie/zombie013.mp3");
	AddFileToDownloadsTable("sound/left4dod/zombie/zombie014.mp3");
	AddFileToDownloadsTable("sound/left4dod/zombie/zombie015.mp3");
	AddFileToDownloadsTable("sound/left4dod/zombie/zombie016.mp3");
	AddFileToDownloadsTable("sound/left4dod/zombie/zombie017.mp3");
	AddFileToDownloadsTable("sound/left4dod/zombie/zombie018.mp3");
	AddFileToDownloadsTable("sound/left4dod/zombie/zombie019.mp3");
	AddFileToDownloadsTable("sound/left4dod/zombie/zombie020.mp3");
	AddFileToDownloadsTable("sound/left4dod/zombie/zombie021.mp3");
	AddFileToDownloadsTable("sound/left4dod/zombie/zombie022.mp3");
	AddFileToDownloadsTable("sound/left4dod/zombie/zombie023.mp3");
	AddFileToDownloadsTable("sound/left4dod/zombie/zombie024.mp3");
	
	AddFileToDownloadsTable("sound/left4dod/pillsstart.wav");
	AddFileToDownloadsTable("sound/left4dod/bandage.mp3");
	
	PrecacheSound("ambient/left4dod.mp3", true);
	PrecacheSound("left4dod/allied_win.mp3", true);
	PrecacheSound("left4dod/zombie_win.mp3", true);
	PrecacheSound("left4dod/l4dod_intro.mp3", true);
	PrecacheSound("left4dod/end001.mp3", true);
	PrecacheSound("left4dod/end002.mp3", true);
	PrecacheSound("left4dod/end003.mp3", true);
	PrecacheSound("left4dod/hooch_groan.mp3", true);
	PrecacheSound("left4dod/hooch_drink.mp3", true);
	PrecacheSound("left4dod/fireball.mp3", true);
	PrecacheSound("left4dod/fire.mp3", true);
	PrecacheSound("left4dod/fire_5.mp3", true);
	PrecacheSound("left4dod/steam2.mp3", true);
	PrecacheSound("left4dod/prop.mp3", true);
	PrecacheSound("left4dod/squelch.mp3", true);
	PrecacheSound("left4dod/oneshot.mp3", true);
	PrecacheSound("left4dod/cough01.mp3", true);
	PrecacheSound("left4dod/gasbomb.wav", true);
	PrecacheSound("weapons/grenade/tick1.wav", true);
	
	PrecacheSound("weapons/c4_plant.wav", true);
	PrecacheSound("ambient/levels/labs/coinslot1.wav", true);
	
	PrecacheSound("left4dod/witch/witch001.mp3", true);
	PrecacheSound("left4dod/witch/witch002.mp3", true);
	PrecacheSound("left4dod/witch/witch003.mp3", true);
	PrecacheSound("left4dod/witch/witch004.mp3", true);
	PrecacheSound("left4dod/witch/witch005.mp3", true);
	PrecacheSound("left4dod/witch/witch006.mp3", true);
	
	PrecacheSound("left4dod/zombie/zombie001.mp3", true);
	PrecacheSound("left4dod/zombie/zombie002.mp3", true);
	PrecacheSound("left4dod/zombie/zombie003.mp3", true);
	PrecacheSound("left4dod/zombie/zombie004.mp3", true);
	PrecacheSound("left4dod/zombie/zombie005.mp3", true);
	PrecacheSound("left4dod/zombie/zombie006.mp3", true);
	PrecacheSound("left4dod/zombie/zombie007.mp3", true);
	PrecacheSound("left4dod/zombie/zombie008.mp3", true);
	PrecacheSound("left4dod/zombie/zombie009.mp3", true);
	PrecacheSound("left4dod/zombie/zombie010.mp3", true);
	PrecacheSound("left4dod/zombie/zombie011.mp3", true);
	PrecacheSound("left4dod/zombie/zombie012.mp3", true);
	PrecacheSound("left4dod/zombie/zombie013.mp3", true);
	PrecacheSound("left4dod/zombie/zombie014.mp3", true);
	PrecacheSound("left4dod/zombie/zombie015.mp3", true);
	PrecacheSound("left4dod/zombie/zombie016.mp3", true);
	PrecacheSound("left4dod/zombie/zombie017.mp3", true);
	PrecacheSound("left4dod/zombie/zombie018.mp3", true);
	PrecacheSound("left4dod/zombie/zombie019.mp3", true);
	PrecacheSound("left4dod/zombie/zombie020.mp3", true);
	PrecacheSound("left4dod/zombie/zombie021.mp3", true);
	PrecacheSound("left4dod/zombie/zombie022.mp3", true);
	PrecacheSound("left4dod/zombie/zombie023.mp3", true);
	PrecacheSound("left4dod/zombie/zombie024.mp3", true);
	
	PrecacheSound("ambient/atmosphere/ambience_base.wav", true);
	PrecacheSound("ambient/airplane2.wav", true);
	PrecacheSound("player/american/us_gogogo.wav", true);
	
	PrecacheSound("left4dod/pillsstart.wav", true);
	PrecacheSound("left4dod/bandage.mp3", true);
	PrecacheSound("weapons/ammopickup.wav", true);
	PrecacheSound("weapons/mortar.wav", true);
	PrecacheSound("weapons/c4_pickup.wav", true);
	PrecacheSound("items/smallmedkit1.wav", true);
	PrecacheSound("weapons/explode_smoke.wav", true);
	PrecacheSound("player/suit_sprint.wav", true);
	PrecacheSound("weapons/bugbait/bugbait_impact1.wav", true);
	PrecacheSound("weapons/bugbait/bugbait_squeeze3.wav", true);
	PrecacheSound("buttons/blip1.wav", true);
	PrecacheSound("npc/zombie_poison/pz_warn2.wav", true);
	PrecacheSound("npc/antlion_grub/squashed.wav", true);
	PrecacheSound("items/suitchargeok1.wav", true);
	PrecacheSound("items/suitchargeno1.wav", true);
	PrecacheSound("ambient/energy/spark1.wav", true);
	PrecacheSound("ambient/energy/spark2.wav", true);
	PrecacheSound("ambient/energy/spark3.wav", true);
	PrecacheSound("ambient/energy/spark4.wav", true);
	PrecacheSound("ambient/energy/spark5.wav", true);
	PrecacheSound("ambient/energy/spark6.wav", true);
	
	PrecacheSound("npc/zombie/zombie_pain1.wav", true);
	PrecacheSound("npc/zombie/zombie_pain2.wav", true);
	PrecacheSound("npc/zombie/zombie_pain3.wav", true);
	PrecacheSound("npc/zombie/zombie_pain4.wav", true);
	PrecacheSound("npc/zombie/zombie_pain5.wav", true);
	PrecacheSound("npc/zombie/zombie_pain6.wav", true);
	PrecacheSound("npc/zombie/zombie_die1.wav", true);
	PrecacheSound("npc/zombie/zombie_die2.wav", true);
	PrecacheSound("npc/zombie/zombie_die3.wav", true);
	PrecacheSound("npc/zombie/zombie_alert1.wav", true);
	PrecacheSound("npc/zombie/zombie_alert2.wav", true);
	PrecacheSound("npc/zombie/zombie_alert3.wav", true);
	
	PrecacheSound("npc/zombie/claw_strike2.wav", true);
	
	PrecacheSound("npc/zombie/zombie_voice_idle1.wav", true);
	PrecacheSound("npc/zombie/zombie_voice_idle2.wav", true);
	PrecacheSound("npc/zombie/zombie_voice_idle3.wav", true);
	PrecacheSound("npc/zombie/zombie_voice_idle4.wav", true);
	PrecacheSound("npc/zombie/zombie_voice_idle5.wav", true);
	PrecacheSound("npc/zombie/zombie_voice_idle6.wav", true);
	PrecacheSound("npc/zombie/zombie_voice_idle7.wav", true);
	PrecacheSound("npc/zombie/zombie_voice_idle8.wav", true);
	PrecacheSound("npc/zombie/zombie_voice_idle9.wav", true);
	PrecacheSound("npc/zombie/zombie_voice_idle10.wav", true);
	PrecacheSound("npc/zombie/zombie_voice_idle11.wav", true);
	PrecacheSound("npc/zombie/zombie_voice_idle12.wav", true);
	PrecacheSound("npc/zombie/zombie_voice_idle13.wav", true);
	PrecacheSound("npc/zombie/zombie_voice_idle14.wav", true);

	PrecacheSound("npc/zombie_poison/pz_call1.wav", true);
	PrecacheSound("npc/fast_zombie/fz_alert_far1.wav", true);
	PrecacheSound("npc/fast_zombie/fz_frenzy1.wav", true);
	PrecacheSound("npc/fast_zombie/idle1.wav", true);
	
	PrecacheSound("ambient/explosions/explode_8.wav", true);
	PrecacheSound("weapons/physcannon/energy_disintegrate4.wav", true);
	
	if (GetConVarInt(hL4DOn))
	{
		//Maps
		//AddFileToDownloadsTable("maps/dod_carrion_a1.bsp");
		
		//Start AFK Timers but turn off for Tournament Mode
		if (GetConVarInt(hL4DGameType) != 2)
			CreateTimer(60.0, Timer_StartTimers, 0, TIMER_FLAG_NO_MAPCHANGE);
		
		//ResetAmmoBox numbers
		g_AmmoBoxNumber = 0;
		g_HealthPackNumber = 0;
		g_ZombieBloodNumber = 0;
		g_PillsNumber = 0;
		g_HoochNumber = 0;
		g_AdrenalineNumber = 0;
		g_SkullNumber = 0;
		g_BoxNadesNumber = 0;
		g_AntiGasNumber = 0;
		g_TNTNumber = 0;
		g_RadioNumber = 0;
		g_SpringNumber = 0;
						
		//Reset difference of winning
		g_AlliedWins = 0;
		g_AxisWins = 0;
		
		//Reset team balance
		//g_Checking = 0;
		
		//Reset all Scores and cvars
		for (new i = 1; i <= MaxClients; i++)
		{
			g_ScoreWitch[i]=0;
			g_ScoreEmo[i]=0;
			g_ScoreGreyDude[i]=0;
			g_ScoreGasMan[i]=0;
			g_ScoreTraitor[i]=0;
			g_ScoreZombies[i]=0;
			g_ScoreHumans[i]=0;
			g_ScoreAnarchist[i]=0;
			g_ScoreUNG[i]=0;
			g_ScoreWraith[i]=0;
			g_ScoreSkeleton[i]=0;
			g_ScoreHellSpawn[i]=0;
			
			g_HealthMax[i] = 100;
			g_ZombieType[i]=-1;
			
			g_bCanMakeNoise[i] = true;
			g_iTimeAFK[i] = 0;
		}
				
		// Apply SpawnFactor
		new spawntime = -1;
		spawntime = FindEntityByClassname(-1, "info_doddetect");
		if (spawntime != -1) 
		{
			DispatchKeyValue(spawntime, "detect_axis_respawnfactor", "0.1");
		}
	}
	
	BeamSprite = PrecacheModel("materials/sprites/laser.vmt", true);
	HaloSprite = PrecacheModel("materials/sprites/halo01.vmt", true);
	GunSmokeSprite = PrecacheModel("materials/sprites/lgtning.vmt", true);	
	//GunSmokeSprite = PrecacheModel("materials/sprites/gunsmoke.vmt", true);
	BallSprite = PrecacheModel("materials/sprites/combineball_glow_blue_1.vmt", true);
	
	new edict_index;
	new x = -1;
	g_NumberofAlliedSpawnPoints = 0;
	g_NumberofAxisSpawnPoints = 0;
	
	for (new i = 0; i < 20; i++)
	{
		edict_index = FindEntityByClassname(x, "info_player_allies");
		if (IsValidEntity(edict_index))
		{
			GetEntDataVector(edict_index, g_oEntityOrigin, g_fAlliedSpawnVectors[i]); 
			g_NumberofAlliedSpawnPoints++;
			x = edict_index;
		}
	}
	
	x = -1;
	for (new i = 0; i < 20; i++)
	{
		edict_index = FindEntityByClassname(x, "info_player_axis");
		if (IsValidEntity(edict_index))
		{
			GetEntDataVector(edict_index, g_oEntityOrigin, g_fAxisSpawnVectors[i]); 
			g_NumberofAxisSpawnPoints++;
			x = edict_index;
		}
	}		
	
	#if DEBUG
		LogToFileEx(g_szLogFileName,"[L4DOD] Allied Spawn Points: %i", g_NumberofAlliedSpawnPoints);
		LogToFileEx(g_szLogFileName,"[L4DOD] Axis Spawn Points: %i", g_NumberofAxisSpawnPoints);
	#endif
}

public Action:Timer_StartTimers(Handle:Timer)
{
	hAFKUpdateViewTimer = CreateTimer(7.0, Timer_UpdateView, 0, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
	hAFKCheckPlayersTimer = CreateTimer(10.0, Timer_CheckPlayers, 0, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
	
	return Plugin_Handled;
}

public OnMapEnd()
{
	if (GetConVarInt(hL4DOn))
	{			
		CloseTimers();
				
		for (new i=1; i<=MaxClients; i++)
		{		
			//Switch off all timers
			if (hFireTimer[i] != INVALID_HANDLE)
			{
				if (CloseHandle(hFireTimer[i]))
					hFireTimer[i] = INVALID_HANDLE;
			}
			
			if (hShieldTimer[i] != INVALID_HANDLE)
			{
				if (CloseHandle(hShieldTimer[i]))
					hShieldTimer[i] = INVALID_HANDLE;
					
				g_ShieldDeployed[i] = false;
			}
			
			if (g_hSearch_Timer[i] != INVALID_HANDLE)
			{
				KillTimer(g_hSearch_Timer[i]);
				g_hSearch_Timer[i] = INVALID_HANDLE;
			}
						
			g_ShowSprite[i] = false;
		}
		
		if (hAFKCheckPlayersTimer != INVALID_HANDLE)
		{
			#if DEBUG
					LogToFileEx(g_szLogFileName,"[L4DOD] Ended AFK Player Check Timer");
			#endif
			
			KillTimer(hAFKCheckPlayersTimer);
			hAFKCheckPlayersTimer = INVALID_HANDLE;
		}
		
		if (hAFKUpdateViewTimer != INVALID_HANDLE)
		{
			#if DEBUG
					LogToFileEx(g_szLogFileName,"[L4DOD] Ended AFK Update View Timer");
			#endif
			
			KillTimer(hAFKUpdateViewTimer);
			hAFKUpdateViewTimer = INVALID_HANDLE;
		}
	}
}

public Action:SetUp(Handle:timer, any:client)
{	
	#if DEBUG
		LogToFileEx(g_szLogFileName,"[L4DOD] Setting up map and bots");
	#endif
		
	// Turn off balance so that axis team can have six+ bots
	//CVARs
	ServerCommand("dod_freezecam 0");
	ServerCommand("mp_limitteams 32");
	ServerCommand("mp_tickpointinterval 1800");
	ServerCommand("dod_friendlyfiresafezone 0");
	ServerCommand("npc_vphysics 1");
		
	if (GetConVarInt(hL4DOn))
	{
		//Fill the Axis team with bots
		new String:addbot[64];
		
		switch (GetConVarInt(hL4DGameType))
		{
			case 0:
				g_botnumber = 16;
			
			case 1:
			{
				g_botnumber = 16;
				ServerCommand("sv_visiblemaxplayers 26");
			}
				
			case 2:
			{
				g_botnumber = 14;
			}
			
			case 3:
				g_botnumber = 14;
				
			default:
				g_botnumber = 14;
		
		}
		
		ServerCommand("sv_cheats 1");
		ServerCommand("bot_zombie 1");
		ServerCommand("dod_flagrespawnbonus 0");
		ServerCommand("mp_show_voice_icons 0");
		ServerCommand("sv_turbophysics 1");
		
		for (new i = 1; i <= g_botnumber; i++)
		{
			if (GetAxisBotNumber() < g_botnumber)
			{
				Format(addbot, sizeof(addbot), "bot -team 3");
				ServerCommand(addbot);
			}
		}
		ServerCommand("sv_cheats 0");
		
		if (GetConVarInt(hL4DGameType) == 0)
		{
			ServerCommand("dod_bonusroundtime 15");
			ServerCommand("dod_bonusround 1");
			ServerCommand("mp_friendlyfire 1");
			
			ServerCommand("mp_limit_allies_rifleman -1");
			ServerCommand("mp_limit_allies_assault 5");
			ServerCommand("mp_limit_allies_support -1");
			ServerCommand("mp_limit_allies_sniper 2");
			ServerCommand("mp_limit_allies_mg 1");
			ServerCommand("mp_limit_allies_rocket 4");
			
			ServerCommand("mp_limit_axis_rifleman -1");
			ServerCommand("mp_limit_axis_assault 0");
			ServerCommand("mp_limit_axis_support 0");
			ServerCommand("mp_limit_axis_sniper 0");
			ServerCommand("mp_limit_axis_mg 0");
			ServerCommand("mp_limit_axis_rocket 0");
		}
	}
	
	// Apply Weather effects
	// Apply Fog Color
	new fog = -1;
	fog = FindEntityByClassname(-1, "env_fog_controller"); 
	if (fog != -1) 
	{
		DispatchKeyValue(fog, "fogenable", "1");
		
		if (GetConVarInt(hL4DFright))
		{				
			DispatchKeyValue(fog, "fogcolor", "5 21 24");	
			DispatchKeyValue(fog, "fogcolor2", "6 6 6");
			DispatchKeyValue(fog, "fogblend", "1");					
			DispatchKeyValueFloat(fog, "fogstart", 000.0);
			DispatchKeyValueFloat(fog, "fogend", 500.0);
			DispatchKeyValueFloat(fog, "fogmaxdensity", 1.0);
		}
		else
		{				
			DispatchKeyValue(fog, "fogcolor", "10 42 48");	
			DispatchKeyValue(fog, "fogcolor2", "5 21 24");
			DispatchKeyValue(fog, "fogblend", "1");		
			DispatchKeyValueFloat(fog, "fogstart", -80.0);
			DispatchKeyValueFloat(fog, "fogend", 700.0);
			DispatchKeyValueFloat(fog, "fogmaxdensity", 1.0);
		}
		
		AcceptEntityInput(fog, "TurnOn");
	}
	
	new sun = -1;
	sun = FindEntityByClassname(-1, "env_sun"); 
	if (sun != -1) 
	{
		AcceptEntityInput(sun, "TurnOff");
	}
	
	//Change light settings
			
	new light = -1;
	while ((light = FindEntityByClassname(light, "light_spot")) != -1)
	{
		if (IsValidEntity(light))
		{
			AcceptEntityInput(light, "TurnOff");
		}
	}
	
	light = -1; 
	while ((light = FindEntityByClassname(light, "light")) != -1)
	{
		if (IsValidEntity(light))
		{
			AcceptEntityInput(light, "TurnOff");
		}
	}
	
				
	new lightenv = -1;
	lightenv = FindEntityByClassname(-1, "light_environment"); 
	if (lightenv != -1) 
	{
		DispatchKeyValue(lightenv, "brightness", "46 255 46 140");
		DispatchKeyValue(lightenv, "ambient", "46 255 46 140");
	}
	
	lightenv = FindEntityByClassname(-1, "point_spotlight"); 
	if (lightenv != -1) 
	{
		DispatchKeyValue(lightenv, "brightness", "46 255 46 140");
		DispatchKeyValue(lightenv, "ambient", "46 255 46 140");
	}
	
	new world = -1;
	world = FindEntityByClassname(-1, "worldspawn"); 
	if (world != -1) 
	{
		DispatchKeyValue(world, "coldworld", "1");
	}
	return Plugin_Handled;
}

public Action:RemoveAllBots(Handle:timer, any:client)
{
	for (new k=1; k<=MaxClients; k++)
	{
		if (IsClientInGame(k) && IsFakeClient(k))
			KickClient(k);
	}
	
	for (new k=1; k<=8; k++)
	{
		g_iAxisKeys[k] = 0;
	}
	
	return Plugin_Handled;
}

public Action:Timer_Spawn(Handle:timer, any:value)
{
	new colour[4], Float:start[3];
	colour[0] = 255;
	colour[1] = 255;
	colour[2] = 255;
	colour[3] = 255;
		
	for (new i = 0; i < g_NumberofAlliedSpawnPoints; i++)
	{							
		start[0] = g_fAlliedSpawnVectors[i][0];
		start[1] = g_fAlliedSpawnVectors[i][1];
		start[2] = g_fAlliedSpawnVectors[i][2] + 10.0;
	
		//BeamRingPoint(origin, startradius, endradius, texture, halo, startframe, framerate, life, width, spread, amp, color(rgba), speed, fade)
		TE_SetupBeamRingPoint(start, 10.0, 50.0, BeamSprite, HaloSprite, 0, 12, 1.1, 15.0, 0.5, colour, 10, 0);
		TE_SendToAll();
	}

	for (new i = 0; i < g_NumberofAxisSpawnPoints; i++)
	{
		start[0] = g_fAxisSpawnVectors[i][0];
		start[1] = g_fAxisSpawnVectors[i][1];
		start[2] = g_fAxisSpawnVectors[i][2] + 10.0;
	
		//BeamRingPoint(origin, startradius, endradius, texture, halo, startframe, framerate, life, width, spread, amp, color(rgba), speed, fade)
		TE_SetupBeamRingPoint(start, 10.0, 50.0, BeamSprite, HaloSprite, 0, 12, 1.1, 15.0, 0.5, colour, 10, 0);
		TE_SendToAll();
	}
		
	return Plugin_Handled;
}

 bool:GetSpawnPointsData()
{
	new Handle:h_KV = CreateKeyValues("WayPoints");
	new String:temp[5];
	
	decl String:datapath[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, datapath, PLATFORM_MAX_PATH, "data/bot_%s.nav", g_szMapName);
	FileToKeyValues(h_KV, datapath);
	KvRewind(h_KV);
	
	// Get the number of spawns per team
	if (!KvJumpToKey(h_KV, "spawns"))
	{
		CloseHandle(h_KV);
		return false;
	}
	new iAxisSpawnsNumber = KvGetNum(h_KV, "axis_sp", 0);
	new iAlliesSpawnsNumber = KvGetNum(h_KV, "allies_sp", 0);
	
	//Got the quantity of spawn points so now load them	
	if (iAxisSpawnsNumber > 0)
	{
		KvRewind(h_KV);
	
		// Get the spawn points
		if (!KvJumpToKey(h_KV, "axisspawns"))
		{
			CloseHandle(h_KV);
			
			PrintToServer("[L4DOD] NO AXIS SPAWN POINTS - MISSING DATA");
			return false;
		}
		for (new keyvalue=0; keyvalue < iAxisSpawnsNumber; keyvalue++)
		{
			Format(temp, sizeof(temp), "loc%i", keyvalue);
			KvGetVector(h_KV, temp, g_vecAxisSpawn[keyvalue]);
			
			Format(temp, sizeof(temp), "angle%i", keyvalue);
			KvGetVector(h_KV, temp, g_vecAxisSpawnAngle[keyvalue]);
			
			#if DEBUG
			LogToFileEx(g_szLogFileName,"[L4DOD] Loaded spawn: %i Vector %i", keyvalue, g_vecAxisSpawn[keyvalue]);
			#endif
			
			new entity = CreateEntityByName("info_player_axis");
			if (DispatchSpawn(entity))
			{
				TeleportEntity(entity, g_vecAxisSpawn[keyvalue], NULL_VECTOR, NULL_VECTOR);
			}
		}
	}
	else
	{
		PrintToServer("[L4DOD] NO AXIS SPAWN POINTS");
	}
	
	if (iAlliesSpawnsNumber > 0)
	{
		KvRewind(h_KV);
	
		// Get the spawn points
		if (!KvJumpToKey(h_KV, "alliesspawns"))
		{
			CloseHandle(h_KV);
			
			PrintToServer("[L4DOD] NO ALLIES SPAWN POINTS - MISSING DATA");
			return false;
		}
		for (new keyvalue=0; keyvalue < iAlliesSpawnsNumber; keyvalue++)
		{
			Format(temp, sizeof(temp), "loc%i", keyvalue);
			KvGetVector(h_KV, temp, g_vecAlliesSpawn[keyvalue]);
			
			Format(temp, sizeof(temp), "angle%i", keyvalue);
			KvGetVector(h_KV, temp, g_vecAlliesSpawnAngle[keyvalue]);
			
			#if DEBUG
			LogToFileEx(g_szLogFileName,"[L4DOD] Loaded spawn: %i Vector %i", keyvalue, g_vecAlliesSpawn[keyvalue]);
			#endif
			
			new entity = CreateEntityByName("info_player_allies");
			if (DispatchSpawn(entity))
			{
				TeleportEntity(entity, g_vecAxisSpawn[keyvalue], NULL_VECTOR, NULL_VECTOR);
			}
		}
	}
	else
	{
		PrintToServer("[L4DOD] NO ALLIES SPAWN POINTS");
	}
	
	CloseHandle(h_KV);
	return true;
}

stock PrecacheParticleSystem( const String:p_strEffectName[] )
{
	static s_numStringTable = INVALID_STRING_TABLE;

	if ( s_numStringTable == INVALID_STRING_TABLE  )
		s_numStringTable = FindStringTable( "ParticleEffectNames" );

	AddToStringTable( s_numStringTable, p_strEffectName );
}