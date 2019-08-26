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

// EVENTS ##################################################################################################
public Action:RoundStartEvent(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (GetConVarInt(hL4DOn))
	{
		g_bRoundOver = false;
		g_inProgress = false;
		g_Checking = 0;
		g_iCurrentRound++;

		g_NumberAlliedTickets = GetConVarInt(hL4DTickets);

		//Disable Store
		if (GetConVarInt(hL4DGameType) == 2)
			g_StoreEnabled = false;
		else
			g_StoreEnabled = true;

		EmitSoundToAll("ambient/left4dod.mp3", SOUND_FROM_PLAYER, _, _, _, 0.5);

		if (hAmbientTimer == INVALID_HANDLE)
		{
			hAmbientTimer = CreateTimer(10.0, Ambient, 0, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
			#if DEBUG
				LogToFileEx(g_szLogFileName,"[L4DOD] Round Began - Started Ambient Timer");
			#endif
		}

		if (hSpawnCheckTimer == INVALID_HANDLE)
		{
			hSpawnCheckTimer = CreateTimer(5.0, SpawnCheck, 0, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
			#if DEBUG
				LogToFileEx(g_szLogFileName,"[L4DOD] Round Began - Started SpawnCheck Timer");
			#endif
		}

		if (hZombieSoundsTimer == INVALID_HANDLE)
		{
			hZombieSoundsTimer = CreateTimer(0.5, ZombieSounds, 0, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
			#if DEBUG
				LogToFileEx(g_szLogFileName,"[L4DOD] Round Began - Started ZombieSounds Timer");
			#endif
		}

		if (hTeamCheck == INVALID_HANDLE)
		{
			hTeamCheck = CreateTimer(1.0, CheckTeam, 0, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
			#if DEBUG
				LogToFileEx(g_szLogFileName,"[L4DOD] Round Began - Started TeamCheck Timer");
			#endif
		}

		if (hOneSecond == INVALID_HANDLE)
		{
			hOneSecond = CreateTimer(1.0, OneSecond, 0, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
			#if DEBUG
				LogToFileEx(g_szLogFileName,"[L4DOD] Round Began - Started 1 sec Timer");
			#endif
		}

		if (hTenSecond == INVALID_HANDLE)
		{
			hTenSecond = CreateTimer(10.0, TenSecond, 0, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
			#if DEBUG
				LogToFileEx(g_szLogFileName,"[L4DOD] Round Began - Started 10 sec Timer");
			#endif
		}

		if (hTenthSecond == INVALID_HANDLE)
		{
			hTenthSecond = CreateTimer(0.1, TenthSecond, 0, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
			#if DEBUG
				LogToFileEx(g_szLogFileName,"[L4DOD] Round Began - Started TenthSecond Timer");
			#endif
		}

		if (hFlagTimer == INVALID_HANDLE)
		{
			hFlagTimer = CreateTimer(1.0, FlagControl, 0, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
			#if DEBUG
				LogToFileEx(g_szLogFileName,"[L4DOD] Round Began - Started Flag Control Timer");
			#endif
		}

		//Reset Player properties
		for (new client=1; client<=MaxClients; client++)
		{
			if (IsClientInGame(client))
			{
				g_bCanRespawn[client] = true;

				g_ScoreWitch[client]=0;
				g_ScoreEmo[client]=0;
				g_ScoreGreyDude[client]=0;
				g_ScoreGasMan[client]=0;
				g_ScoreTraitor[client]=0;
				g_ScoreZombies[client]=0;
				g_ScoreHumans[client]=0;
				g_ScoreAnarchist[client]=0;
				g_ScoreUNG[client]=0;
				g_ScoreWraith[client]=0;
				g_ScoreSkeleton[client]=0;
				g_ScoreHellSpawn[client]=0;

				g_HealthAdded[client] = 0;
			}
		}

		//Extinguish fires/ turn off shields
		for (new i=1; i<=MaxClients; i++)
		{
			if (hFireTimer[i] != INVALID_HANDLE)
			{
				if (CloseHandle(hFireTimer[i]))
					hFireTimer[i] = INVALID_HANDLE;
			}

			g_OnFire[i] = false;

			if (hShieldTimer[i] != INVALID_HANDLE)
			{
				if (CloseHandle(hShieldTimer[i]))
					hShieldTimer[i] = INVALID_HANDLE;
			}

			g_ShieldDeployed[i] = false;
		}

		new x = -1;

		if (g_bFlagData)
		{
			//Dynamically change the time to cap and numbers

			while ((x = FindEntityByClassname(x, "dod_objective_resource")) != -1)
			{
				g_iObjectiveResource = x;

				#if DEBUG
					LogToFileEx(g_szLogFileName,"[L4DOD] Objective Resource %i", g_iObjectiveResource);
				#endif
			}

			#if DEBUG
			for (new i = 0; i < g_iFlagNumber; i++)
			{
				new team = GetEntData(g_iObjectiveResource, g_oOwner + (i * 4));
				PrintToServer("[L4DOD] STORED FLAG: %i TEAM: %i", g_iDoDCaptureArea[i], team);
			}
			#endif

			for (new i = 0; i < g_iFlagNumber; i++)
			{
				if (IsValidEntity(g_iDoDCaptureArea[i]))
				{
					SDKHook(g_iDoDCaptureArea[i], SDKHook_StartTouch, OnFlagTouched);
					SDKHook(g_iDoDCaptureArea[i], SDKHook_EndTouch, OnFlagNotTouched);
					SDKHook(g_iDoDCaptureArea[i], SDKHook_Touch, OnFlagTouched);

					DispatchKeyValue(g_iDoDCaptureArea[i], "area_time_to_cap", "60.0");
					DispatchKeyValue(g_iDoDCaptureArea[i], "area_axis_cancap", "1");

					SetEntDataFloat(g_iObjectiveResource, g_oAlliesTime + (i * 4), 60.0);
					SetEntDataFloat(g_iObjectiveResource, g_oAxisTime + (i * 4), 0.1);
				}

				//Get the default captures for each flag
				new alliesoffset = FindSendPropInfo("CDODObjectiveResource", "m_iAlliesReqCappers");
				new axisoffset = FindSendPropInfo("CDODObjectiveResource", "m_iAxisReqCappers");

				g_flagAlliedDefCaps[i] = GetEntData(g_iObjectiveResource, alliesoffset + (i * 4));
				g_flagAxisDefCaps[i]	= GetEntData(g_iObjectiveResource, axisoffset + (i * 4));

				#if DEBUG
					LogToFileEx(g_szLogFileName,"[L4DOD] Default Caps -> Allies: %i Axis: %i", g_flagAlliedDefCaps[i], g_flagAxisDefCaps[i]);
				#endif
			}
		}

		DisableMapFeatures();

		//Disable first flag
		//SetCPVisible(i, false);
		//AcceptEntityInput(g_iDoDCcontrolPoint[0], "Disable");
		//AcceptEntityInput(g_iDoDCaptureArea[0], "Disable");
		//SetEntityModel(g_iDoDCcontrolPoint[0], "");

	}

	if (GetConVarInt(hL4DSetup))
	{
		new x = -1;
		while ((x = FindEntityByClassname(x, "dod_capture_area")) != -1)
		{
			SDKHook(x, SDKHook_StartTouch, OnFlagTouched);
			SDKHook(x, SDKHook_EndTouch, OnFlagNotTouched);
		}

		CreateTimer(1.0, Timer_Spawn, 0, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
	}

	PrintToServer("ROUND START");


	if (g_iWeather > -1 )
	{
		new precipitation = -1;
		precipitation = FindEntityByClassname(-1, "func_precipitation");
		if (precipitation == -1)
		{
			decl String:precipitation_type[8];
			Format(precipitation_type, sizeof(precipitation_type), "%i", g_iWeather);
			CreatePrecipitation(precipitation_type);
		}
	}

	//############################# MAP ADDITIONS

	//Add ramp to Zombie spawn area
	new Float:EntOrigin[3], Float:EntAngle[3];

	if (StrContains(g_szMapName, "dod_argentan", false) != -1)
	{
		new ent = CreateEntityByName("prop_physics_override");
		if (ent>0)
		{
			EntOrigin[0] = 2220.0;
			EntOrigin[1] = 35.0;
			EntOrigin[2] = 220.0;

			EntAngle[0] = 120.0;
			EntAngle[1] = 90.0;
			EntAngle[2] = 0.0;

			SetEntityModel(ent, "models/props_debris/metal_panel02a.mdl");
			DispatchKeyValue(ent, "StartDisabled", "false");
			DispatchKeyValue(ent, "spawnflags", "8");

			SetEntityMoveType(ent, MOVETYPE_NONE);
			SetEntProp(ent, Prop_Send, "m_CollisionGroup", DROP_COLLISION);
			SetEntProp(ent, Prop_Send, "m_usSolidFlags", 24);
			SetEntProp(ent, Prop_Send, "m_nSolidType", 6);

			DispatchSpawn(ent);
			TeleportEntity(ent, EntOrigin, EntAngle, NULL_VECTOR);
		}

		ent = CreateEntityByName("prop_physics_override");
		if (ent>0)
		{
			EntOrigin[0] = 2270.0;
			EntOrigin[1] = 35.0;
			EntOrigin[2] = 220.0;

			EntAngle[0] = 120.0;
			EntAngle[1] = 90.0;
			EntAngle[2] = 0.0;

			SetEntityModel(ent, "models/props_debris/metal_panel02a.mdl");
			DispatchKeyValue(ent, "StartDisabled", "false");
			DispatchKeyValue(ent, "spawnflags", "8");

			SetEntityMoveType(ent, MOVETYPE_NONE);
			SetEntProp(ent, Prop_Send, "m_CollisionGroup", DROP_COLLISION);
			SetEntProp(ent, Prop_Send, "m_usSolidFlags", 24);
			SetEntProp(ent, Prop_Send, "m_nSolidType", 6);

			DispatchSpawn(ent);
			TeleportEntity(ent, EntOrigin, EntAngle, NULL_VECTOR);
		}

		ent = CreateEntityByName("prop_physics_override");
		if (ent>0)
		{
			EntOrigin[0] = 2320.0;
			EntOrigin[1] = 35.0;
			EntOrigin[2] = 220.0;

			EntAngle[0] = 120.0;
			EntAngle[1] = 90.0;
			EntAngle[2] = 0.0;

			SetEntityModel(ent, "models/props_debris/metal_panel02a.mdl");
			DispatchKeyValue(ent, "StartDisabled", "false");
			DispatchKeyValue(ent, "spawnflags", "8");

			SetEntityMoveType(ent, MOVETYPE_NONE);
			SetEntProp(ent, Prop_Send, "m_CollisionGroup", DROP_COLLISION);
			SetEntProp(ent, Prop_Send, "m_usSolidFlags", 24);
			SetEntProp(ent, Prop_Send, "m_nSolidType", 6);

			DispatchSpawn(ent);
			TeleportEntity(ent, EntOrigin, EntAngle, NULL_VECTOR);
		}
	}
	return Plugin_Continue;
}

public RoundActiveEvent(Handle:event, const String:name[], bool:dontBroadcast)
{
	g_bRoundActive = true;

	PrintToServer("ROUND ACTIVE");

	//Start Bot Aim loop
	for (new i=1; i<=MaxClients; i++)
	{
		g_bPlayerDead[i] = false;

		if (IsClientInGame(i) && IsFakeClient(i))
		{
			if (g_hSearch_Timer[i] == INVALID_HANDLE)
			{
				g_hSearch_Timer[i] = CreateTimer(0.5, SearchTargets, i, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);

				#if DEBUG
				LogToFileEx(g_szLogFileName,"[L4DOD] Search timer started: %i", i);
				#endif
			}
			else
			{
				KillTimer(g_hSearch_Timer[i]);
				g_hSearch_Timer[i] = INVALID_HANDLE;
				g_hSearch_Timer[i] = CreateTimer(0.5, SearchTargets, i, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);

				#if DEBUG
				LogToFileEx(g_szLogFileName,"[L4DOD] Search timer restarted: %i", i);
				#endif
			}

			g_bIsWaiting[i] = true;
			SetEntityMoveType(i, MOVETYPE_NONE);

			CreateTimer(GetRandomFloat(1.0, 3.5), EndSpawnWaiting, i, TIMER_FLAG_NO_MAPCHANGE);
		}
	}


	g_inProgress = true;

}

public Action:EndSpawnWaiting(Handle:timer, any:iClient)
{
	if (IsClientInGame(iClient) && IsPlayerAlive(iClient) && g_bIsWaiting[iClient])
	{
		g_bIsWaiting[iClient] = false;

		SetEntityMoveType(iClient, MOVETYPE_WALK);

		#if DEBUG
		LogToFileEx(g_szLogFileName,"[L4DOD] Ended spawn waiting:%N", iClient);
		#endif
	}

	return Plugin_Continue;
}

stock ChooseHumanZombie()
{
	new index=0;
	new human[MAXPLAYERS+1];

	for (new i=1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i) && !IsFakeClient(i))
		{
			human[index] = i;
			index++;
		}
	}

	new randomnumber = GetRandomInt(0, index-1);

	return human[randomnumber];

}

DisableMapFeatures()
{
	new x = -1;
	while ((x = FindEntityByClassname(x, "func_teamblocker")) != -1)
	{
		AcceptEntityInput(x, "Kill");
		#if DEBUG
			LogToFileEx(g_szLogFileName,"[L4DOD] Disabled Team Blocker:%i", x);
		#endif
	}

	x = -1;
	while ((x = FindEntityByClassname(x, "func_team_wall")) != -1)
	{
		AcceptEntityInput(x, "Kill");
		#if DEBUG
			LogToFileEx(g_szLogFileName,"[L4DOD] Disabled Team Wall:%i", x);
		#endif
	}

	x = -1;
	while ((x = FindEntityByClassname(x, "trigger_hurt")) != -1)
	{
		AcceptEntityInput(x, "Disable");
		#if DEBUG
			LogToFileEx(g_szLogFileName,"[L4DOD] Disabled Trigger Hurt:%i", x);
		#endif
	}

	x = -1;
	while ((x = FindEntityByClassname(x, "prop_physics_multiplayer")) != -1)
	{
		AcceptEntityInput(x, "DisableMotion");
		#if DEBUG
		LogToFileEx(g_szLogFileName,"[L4DOD] Disabled Physics Multiplayer Props:%i", x);
		#endif
	}

	x = -1;
	while ((x = FindEntityByClassname(x, "prop_physics")) != -1)
	{
		AcceptEntityInput(x, "DisableMotion");
		#if DEBUG
		LogToFileEx(g_szLogFileName,"[L4DOD] Disabled Physics Props:%i", x);
		#endif
	}
}

public Action:WaitForPlayers(Handle:timer, any:client)
{
	if (g_iWaitCount <= 0)
	{
		return Plugin_Stop;
	}

	g_iWaitCount--;

	PrintCenterTextAll("Waiting for players: %i", g_iWaitCount);
	return Plugin_Handled;
}

stock CreatePrecipitation(String:type[8])
{
	decl String:MapName[128];
	decl String:buf[128];
	GetCurrentMap(MapName, sizeof(MapName));
	Format(buf, sizeof(buf), "maps/%s.bsp", MapName);
	new ent = CreateEntityByName("func_precipitation");
	DispatchKeyValue(ent, "model", buf);
	DispatchKeyValue(ent, "preciptype", type);
	DispatchKeyValue(ent, "renderamt", "255");
	DispatchKeyValue(ent, "rendercolor", "255 255 255");
	DispatchSpawn(ent);
	ActivateEntity(ent);
	new Float:minbounds[3];
	GetEntPropVector(0, Prop_Data, "m_WorldMins", minbounds);
	new Float:maxbounds[3];
	GetEntPropVector(0, Prop_Data, "m_WorldMaxs", maxbounds);

	SetEntPropVector(ent, Prop_Send, "m_vecMins", minbounds);
	SetEntPropVector(ent, Prop_Send, "m_vecMaxs", maxbounds);
	SetEntProp(ent, Prop_Send, "m_nSolidType", 0);
	new Float:m_vecOrigin[3];
	m_vecOrigin[0] = (minbounds[0] + maxbounds[0])/2;
	m_vecOrigin[1] = (minbounds[1] + maxbounds[1])/2;
	m_vecOrigin[2] = (minbounds[2] + maxbounds[2])/2;
	TeleportEntity(ent, m_vecOrigin, NULL_VECTOR, NULL_VECTOR);
}
