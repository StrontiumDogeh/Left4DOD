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
 
//####################################### FLAG CONTROL ###################################

 bool:GetFlagData()
{
	new Handle:h_KV = CreateKeyValues("WayPoints");
	new String:temp[5];
	
	decl String:datapath[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, datapath, PLATFORM_MAX_PATH, "data/bot_%s.nav", g_szMapName);
	FileToKeyValues(h_KV, datapath);
	
	
	// Get the number of flags
	if (!KvJumpToKey(h_KV, "number"))
	{
		CloseHandle(h_KV);
		g_bFlagData = false;
		
		LogToFileEx(g_szLogFileName,"[L4DOD] UNABLE TO LOAD NAVIGATION - MISSING FLAG DATA - NUMBER OF FLAGS");
		return false;
	}
	g_iFlagNumber = KvGetNum(h_KV, "number", 0);
	
	KvRewind(h_KV);
	
	// Get the flags
	if (!KvJumpToKey(h_KV, "flags"))
	{
		CloseHandle(h_KV);
		g_bFlagData = false;
		
		LogToFileEx(g_szLogFileName,"[L4DOD] UNABLE TO LOAD NAVIGATION - MISSING FLAG DATA");
		return false;
	}
	
	for (new keyvalue=0; keyvalue < g_iFlagNumber; keyvalue++)
	{
		Format(temp, sizeof(temp), "%i", keyvalue);
		g_iDoDCaptureArea[keyvalue] = KvGetNum(h_KV, temp, 0);
		
		#if DEBUG
		LogToFileEx(g_szLogFileName,"[L4DOD] Loaded flag: %i Entity %i", keyvalue, g_iDoDCaptureArea[keyvalue]);
		#endif
	}
	
	KvRewind(h_KV);
	g_bSpawnData = true;
	// Get the CP Vectors
	if (!KvJumpToKey(h_KV, "spawn"))
	{
		CloseHandle(h_KV);
		g_bSpawnData = false;
		
		LogToFileEx(g_szLogFileName,"[L4DOD] UNABLE TO LOAD NAVIGATION - MISSING PARACHUTE SPAWN DATA");
		return false;
	}
	
	for (new keyvalue=0; keyvalue < g_iFlagNumber; keyvalue++)
	{
		Format(temp, sizeof(temp), "%i", keyvalue);
		KvGetVector(h_KV, temp, g_vecFlagVector[keyvalue]);
		
		#if DEBUG
		LogToFileEx(g_szLogFileName,"[L4DOD] Loaded spawn: %i Vector %f %f %f", keyvalue, g_vecFlagVector[keyvalue][0], g_vecFlagVector[keyvalue][1], g_vecFlagVector[keyvalue][2]);
		#endif
	}
	
	//###################################################
	KvRewind(h_KV);
	g_bZSpawnData = true;
	// Get the CP Vectors
	if (!KvJumpToKey(h_KV, "zspawn"))
	{
		CloseHandle(h_KV);
		g_bZSpawnData = false;
		
		LogToFileEx(g_szLogFileName,"[L4DOD] UNABLE TO LOAD NAVIGATION - MISSING ZOMBIE SPAWN DATA");
		return false;
	}
	
	for (new keyvalue=0; keyvalue < g_iFlagNumber; keyvalue++)
	{
		Format(temp, sizeof(temp), "%i", keyvalue);
		KvGetVector(h_KV, temp, g_vecZFlagVector[keyvalue]);
		
		#if DEBUG
		LogToFileEx(g_szLogFileName,"[L4DOD] Loaded zspawn: %i Vector %f %f %f", keyvalue, g_vecZFlagVector[keyvalue][0], g_vecZFlagVector[keyvalue][1], g_vecZFlagVector[keyvalue][2]);
		#endif
	}
		
	g_bFlagData = true;
	CloseHandle(h_KV);
	return true;
}

//5.0 timer
public Action:FlagControl(Handle:timer, any:stuff)
{
	if (g_bRoundOver)
	{
		hFlagTimer = INVALID_HANDLE;
		return Plugin_Stop;
	}
	
	if (GetConVarInt(hL4DGameType) == 0)
	{
		for (new i = 0; i < g_iFlagNumber; i++)
		{					
			// ALLIES FLAGS
			
			if (GetAlliedTeamNumber() <= 1)
			{
				SetEntData(g_iObjectiveResource, g_oAlliesCaps + (i * 4), 1);
				
				if (IsValidEntity(g_iDoDCaptureArea[i]))
					DispatchKeyValue(g_iDoDCaptureArea[i], "area_allies_numcap", "1");
					
				g_AlliedFlagStatus = 0;
			}
			else if (GetAlliedTeamNumber() > 1 && GetAlliedTeamNumber() <= 3)
			{
				if (g_AlliedWins <= 0)
				{
					SetEntData(g_iObjectiveResource, g_oAlliesCaps + (i * 4), 1);
				
					if (IsValidEntity(g_iDoDCaptureArea[i]))
						DispatchKeyValue(g_iDoDCaptureArea[i], "area_allies_numcap", "1");
						
					g_AlliedFlagStatus = 0;
				
				}
				else if (g_AlliedWins > 0 && g_AlliedWins < 4)
				{
					SetEntData(g_iObjectiveResource, g_oAlliesCaps + (i * 4), g_flagAlliedDefCaps[i]);
					new String:szNumber[8];
					Format(szNumber, sizeof(szNumber), "%i", g_flagAlliedDefCaps[i]);
					
					if (IsValidEntity(g_iDoDCaptureArea[i]))
						DispatchKeyValue(g_iDoDCaptureArea[i], "area_allies_numcap", szNumber);
					
					g_AlliedFlagStatus = 1;
					
				}
				else if (g_AlliedWins >= 3)
				{
					SetEntData(g_iObjectiveResource, g_oAlliesCaps + (i * 4), 2);
					
					if (IsValidEntity(g_iDoDCaptureArea[i]))
						DispatchKeyValue(g_iDoDCaptureArea[i], "area_allies_numcap", "2");
					
					g_AlliedFlagStatus = 2;
					
				}
			}
			else if (GetAlliedTeamNumber() > 4)
			{
				if (g_AlliedWins <= 1)
				{
					SetEntData(g_iObjectiveResource, g_oAlliesCaps + (i * 4), g_flagAlliedDefCaps[i]);
					new String:szNumber[8];
					Format(szNumber, sizeof(szNumber), "%i", g_flagAlliedDefCaps[i]);
					
					if (IsValidEntity(g_iDoDCaptureArea[i]))
						DispatchKeyValue(g_iDoDCaptureArea[i], "area_allies_numcap", szNumber);
					
					g_AlliedFlagStatus = 1;
					
				}
				else if (g_AlliedWins > 1 && g_AlliedWins < 4)
				{
					SetEntData(g_iObjectiveResource, g_oAlliesCaps + (i * 4), 2);
					
					if (IsValidEntity(g_iDoDCaptureArea[i]))
						DispatchKeyValue(g_iDoDCaptureArea[i], "area_allies_numcap", "2");
					
					g_AlliedFlagStatus = 2;
					
				}
				else if (g_AlliedWins >= 3)
				{
					SetEntData(g_iObjectiveResource, g_oAlliesCaps + (i * 4), 3);
					
					if (IsValidEntity(g_iDoDCaptureArea[i]))
						DispatchKeyValue(g_iDoDCaptureArea[i], "area_allies_numcap", "3");
						
					g_AlliedFlagStatus = 3;
					
				}
			}
			
			
			// AXIS FLAGS
			
			if (GetAlliedTeamNumber() <= 2)
			{
				if (IsValidEntity(g_iDoDCaptureArea[i]))
				{
					DispatchKeyValue(g_iDoDCaptureArea[i], "area_axis_numcap", "0");
				}
				
				g_AxisFlagStatus = 4;
			}
			else
			{
				if (GetAxisTeamNumber() <= 1)
				{
					SetEntData(g_iObjectiveResource, g_oAxisCaps + (i * 4), 1);
					
					if (IsValidEntity(g_iDoDCaptureArea[i]))
						DispatchKeyValue(g_iDoDCaptureArea[i], "area_axis_numcap", "1");
					
					g_AxisFlagStatus = 0;
					
				}
				else if (GetAxisTeamNumber() > 1 && GetAxisTeamNumber() <= 4)
				{
					if (g_AxisWins < 1)
					{
						SetEntData(g_iObjectiveResource, g_oAxisCaps + (i * 4), 1);
					
						if (IsValidEntity(g_iDoDCaptureArea[i]))
							DispatchKeyValue(g_iDoDCaptureArea[i], "area_axis_numcap", "1");
						
						g_AxisFlagStatus = 0;

					}
					else
					{
						SetEntData(g_iObjectiveResource, g_oAxisCaps + (i * 4), g_flagAxisDefCaps[i]);
						new String:szNumber[8];
						Format(szNumber, sizeof(szNumber), "%i", g_flagAxisDefCaps[i]);
						
						if (IsValidEntity(g_iDoDCaptureArea[i]))
							DispatchKeyValue(g_iDoDCaptureArea[i], "area_axis_numcap", szNumber);
							
						g_AxisFlagStatus = 1;
					}
				}
				else
				{
					if (g_AxisWins < 2)
					{
						SetEntData(g_iObjectiveResource, g_oAxisCaps + (i * 4), g_flagAxisDefCaps[i]);
						new String:szNumber[8];
						Format(szNumber, sizeof(szNumber), "%i", g_flagAxisDefCaps[i]);
						
						if (IsValidEntity(g_iDoDCaptureArea[i]))
							DispatchKeyValue(g_iDoDCaptureArea[i], "area_axis_numcap", szNumber);
							
						g_AxisFlagStatus = 1;
					}
					else
					{
						SetEntData(g_iObjectiveResource, g_oAxisCaps + (i * 4), 2);
						
						if (IsValidEntity(g_iDoDCaptureArea[i]))
							DispatchKeyValue(g_iDoDCaptureArea[i], "area_axis_numcap", "2");
							
						g_AxisFlagStatus = 2;
					}
				}
			}
		}
	}
	
	return Plugin_Handled;
}

public OnFlagTouched(entity, other)
{
	if (other > 0 && other < MaxClients)
	{		
		new current_flag = GetFlagNumber(entity);
			
		if (current_flag > -1)
		{
			g_atFlag[current_flag][other] = true;
		}
		
		//Get the bots to move on if they already own the flag		
		if (g_bFlagData)
		{			
			for (new i = 0; i < g_iFlagNumber; i++)
			{								
				decl String:szTime[16];
				
				if (entity == g_iDoDCaptureArea[i])
				{
					new owner = GetEntData(g_iObjectiveResource, g_oOwner + (i * 4));
					
					if (owner == 0)
					{
						if (GetClientTeam(other) == ALLIES)
						{
							Format(szTime, sizeof(szTime), "%f", g_fAlliedCapTime);
							DispatchKeyValue(entity, "area_time_to_cap", szTime);
						}
						else if (GetClientTeam(other) == AXIS)
						{
							Format(szTime, sizeof(szTime), "%f", g_fAxisCapTime);
							DispatchKeyValue(entity, "area_time_to_cap", szTime);
						}
					}
					else if (owner == 2)
					{
						Format(szTime, sizeof(szTime), "%f", g_fAxisCapTime);
						DispatchKeyValue(entity, "area_time_to_cap", szTime);
					}
					else if (owner == 3)
					{
						Format(szTime, sizeof(szTime), "%f", g_fAlliedCapTime);
						DispatchKeyValue(entity, "area_time_to_cap", szTime);
					}
										
					if (IsFakeClient(other))
					{					
						#if DEBUG
						LogToFileEx(g_szLogFileName,"[L4DOD] %N touched flag %i owned by %i", other, entity, owner);
						#endif

						if (owner == GetClientTeam(other) || (GetAlliedTeamNumber() <= 2 && owner == 0) || g_AxisFlagStatus == 4)
						{
							g_bIsWaiting[other] = false;
							SetEntityMoveType(other, MOVETYPE_WALK);
							g_atFlag[current_flag][other] = false;
						}	
						else
						{
							g_bIsWaiting[other] = true;
							SetEntityMoveType(other, MOVETYPE_NONE);
							CreateTimer((g_fAxisCapTime + 1.0), EndWaiting, other, TIMER_FLAG_NO_MAPCHANGE);
							g_atFlag[current_flag][other] = true;
						}
					}
				}
			}
		}
		else
		{
			#if DEBUG
				LogToFileEx(g_szLogFileName,"[L4DOD] %N touched flag %i", other, entity);
			#endif
		}

		if (GetConVarBool(hL4DSetup))
		{
			PrintToChat(other, "[L4DOD] Flag Entity:%i", entity);
		}
	}
}

public OnFlagNotTouched(entity, other)
{
	if (other > 0 && other < MaxClients)
	{
		if (IsClientInGame(other))
		{
			new current_flag = GetFlagNumber(entity);
			
			if (current_flag > -1)
			{
				g_atFlag[current_flag][other] = false;
			}
		}
	}
}

public Action:EndWaiting(Handle:timer, any:iClient)
{
	if (IsClientInGame(iClient) && IsPlayerAlive(iClient) && g_bIsWaiting[iClient])
	{
		g_bIsWaiting[iClient] = false;
		
		SetEntityMoveType(iClient, MOVETYPE_WALK);
		
		#if DEBUG
		LogToFileEx(g_szLogFileName,"[L4DOD] Ended waiting:%N", iClient);
		#endif
	}
			
	return Plugin_Continue;
}

public Action:FlagCapturedEvent(Handle:hEvent, const String:szName[], bool:bDontBroadcast)
{
	new String:szCappers[1024];
	GetEventString(hEvent, "cappers", szCappers, sizeof(szCappers));
	
	new flag = GetEventInt(hEvent, "cp");
		
	for(new i = 0; i < strlen(szCappers); i++)
	{
		new client = szCappers{i};
		
		if (client > 0 && IsClientInGame(client) && IsPlayerAlive(client))
		{
			if (GetClientTeam(client) == ALLIES)
			{
				decl Float:pos[3];
				GetClientAbsOrigin(client, pos);
				pos[2] += 75.0;
				AddParticle(client, "achieved", 8.0, 75.0);
				
				new health = GetClientHealth(client);
				
				if (health < 100)
					EmitSoundToClient(client, "left4dod/bandage.mp3");
					
				if (health < MAXHEALTH - 25)
				{
					SetEntityHealth(client, health + 25);
					PrintHelp(client, "*For capping, you received \x05Health", 0);	
					EmitSoundToClient(client, "items/smallmedkit1.wav");
					PrintToChat(client, "Health: %i hp", health);
				}
				
				if (g_StoreEnabled)
				{
					new multiplier;
					
					if (GetConVarInt(hL4DFright))
						multiplier = 10;
					else
						multiplier = 1;
						
					new amount = RoundToCeil(Pow(2.0, float(flag))) * multiplier;
					if (amount < 1)
						amount = 1;
					
					g_iMoney[client] = g_iMoney[client] + amount;
					PrintToChat(client, "\x01* +\x04$%i \x01Total: \x04$%i", amount, g_iMoney[client]);
				}
									
				//Additional present!
				new rnd = GetRandomInt(0,100);
				
				switch(rnd)
				{
					case 0:
					{
						CreateTimer(0.2, SpawnAmmoBox, client, TIMER_FLAG_NO_MAPCHANGE);
					}
					
					case 10, 11:
					{
						CreateTimer(0.2, SpawnBoxNades, client, TIMER_FLAG_NO_MAPCHANGE);
					}
						
					case 20:
					{
						CreateTimer(0.2, SpawnZombieBlood, client, TIMER_FLAG_NO_MAPCHANGE);
					}
					
					case 30:
					{
						CreateTimer(0.2, SpawnPills, client, TIMER_FLAG_NO_MAPCHANGE);
					}
					
					case 90:
					{
						CreateTimer(0.2, SpawnRadio, client, TIMER_FLAG_NO_MAPCHANGE);
					}
						
					default:
					{
						//Do Nothing
					}
				}
			}
			else
			{
				
			}
		}
	} 
	return Plugin_Handled;
}

public GetFlagCapTimes()
{
	new Float:fAlliedPlayers = float(GetAlliedTeamNumber());
	if (fAlliedPlayers >= 10.0)
		fAlliedPlayers = 10.0;
		
	new Float:fAxisPlayers = float(GetAxisTeamNumber());
	
	if (GetConVarInt(hL4DGameType) == 0)
	{
		g_fAlliedCapTime =  fAlliedPlayers + 0.1 + float(g_AlliedWins);
		if (g_fAlliedCapTime <= 1.0) g_fAlliedCapTime = 1.0;
		
		g_fAxisCapTime =  fAxisPlayers + 6.0 + float(g_AxisWins);
		if (g_fAxisCapTime <= 2.0) g_fAxisCapTime = 2.0;
	}
	else if (GetConVarInt(hL4DGameType) == 1 || GetConVarInt(hL4DGameType) == 2)
	{
		g_fAlliedCapTime = fAlliedPlayers + 0.1 + (float(g_AlliedWins) * 2.0);
		if (g_fAlliedCapTime <= 1.0) g_fAlliedCapTime = 1.0;
		
		if (g_mapType == 1)
		{
			g_fAxisCapTime = (20.0 - fAlliedPlayers + float(g_AxisWins));
		}
		else
		{
			g_fAxisCapTime = (fAlliedPlayers / 2) + float(g_AxisWins);
		}
		
		if (g_fAxisCapTime <= 2.0) g_fAxisCapTime = 2.0;
	}
	
	for (new i = 0; i < g_iFlagNumber; i++)
	{
		SetEntDataFloat(g_iObjectiveResource, g_oAlliesTime + (i * 4), g_fAlliedCapTime);
		SetEntDataFloat(g_iObjectiveResource, g_oAxisTime + (i * 4), g_fAxisCapTime);
	}
}

GetFlagNumber(entity)
{
	//Find out the flag number
	new current_flag = -1;
	for (new flag = 0; flag < g_iFlagNumber; flag++)
	{
		if (g_iDoDCaptureArea[flag] == entity)
			current_flag = flag;
	}
	
	return current_flag;
}