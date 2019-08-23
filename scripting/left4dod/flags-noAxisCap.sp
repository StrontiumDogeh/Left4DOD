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
	//##########################################################
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
	//###################################################
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
	
	//##########################################################
	KvRewind(h_KV);
	
	// Get the flags
	if (!KvJumpToKey(h_KV, "cp"))
	{
		CloseHandle(h_KV);
		g_bFlagData = false;
		
		LogToFileEx(g_szLogFileName,"[L4DOD] UNABLE TO LOAD NAVIGATION - MISSING CP DATA");
		return false;
	}
	for (new keyvalue=0; keyvalue < g_iFlagNumber; keyvalue++)
	{
		Format(temp, sizeof(temp), "%i", keyvalue);
		g_iDoDCcontrolPoint[keyvalue] = KvGetNum(h_KV, temp, 0);
		
		#if DEBUG
		LogToFileEx(g_szLogFileName,"[L4DOD] Loaded flag: %i Entity %i", keyvalue, g_iDoDCcontrolPoint[keyvalue]);
		#endif
	}
		
	g_bFlagData = true;
	CloseHandle(h_KV);
	return true;
}

//1.0 timer
public Action:FlagControl(Handle:timer, any:stuff)
{
	if (g_bRoundOver)
	{
		hFlagTimer = INVALID_HANDLE;
		return Plugin_Stop;
	}
	
	g_AxisFlagStatus = 4;
	
	for (new i = 0; i < g_iFlagNumber; i++)
	{							
		if (g_mapType == 0)
		{
			new Float:test = SetCapTime(i);
			PrintToServer("Number at flag %i: %f", i, test);
		}
		// Defend map
		else
		{				
			if (IsValidEntity(g_iDoDCaptureArea[i]))
				DispatchKeyValue(g_iDoDCaptureArea[i], "area_allies_numcap", "0");
					
			g_AlliedFlagStatus = 4;
		}
	}
	
	return Plugin_Handled;
}

//i is the flag number
Float:SetCapTime(i)
{
	if (g_fNumberAlliesAtFlag[i] < 1.0)
		g_fNumberAlliesAtFlag[i] = 1.0;
		
	new iWins = g_AlliedWins - g_AxisWins;
	if (iWins <= 0) iWins = 0;
		
	new Float:fAlliedWins = (float(iWins) * 0.20) + 1.0;
	new Float:fCapTime = 60.0;
	fCapTime = 20.0 * fAlliedWins / g_fNumberAlliesAtFlag[i];

	SetEntDataFloat(g_iObjectiveResource, g_oAlliesTime + (i * 4), fCapTime);
	SetEntData(g_iObjectiveResource, g_oAlliesCaps + (i * 4), 1);

	if (IsValidEntity(g_iDoDCaptureArea[i]))
	{	
		if (g_NumberAxisAtFlag[i] > 0 && g_fNumberAlliesAtFlag[i] > 1.0)
		{
			PrintToServer("Block");
			fCapTime = 400.0;
			DispatchKeyValue(g_iDoDCaptureArea[i], "area_allies_numcap", "1");
			DispatchKeyValue(g_iDoDCaptureArea[i], "area_axis_cancap", "1");
			DispatchKeyValueFloat(g_iDoDCaptureArea[i], "area_time_to_cap", fCapTime);
			SetEntDataFloat(g_iObjectiveResource, g_oAlliesTime + (i * 4), fCapTime);
		}
		else
		{
			DispatchKeyValue(g_iDoDCaptureArea[i], "area_allies_numcap", "1");
			DispatchKeyValue(g_iDoDCaptureArea[i], "area_axis_cancap", "1");
			DispatchKeyValueFloat(g_iDoDCaptureArea[i], "area_time_to_cap", fCapTime);
		}
	}
	return fCapTime;
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

public Action:OnFlagTouched(entity, other)
{
	if (other > 0 && other < MaxClients)
	{
		if (IsClientInGame(other) && GetClientTeam(other) == AXIS)
		{				
			new current_flag = GetFlagNumber(entity);
			
			if (current_flag > -1)
			{
				g_atFlag[current_flag][other] = true;
			}
			return Plugin_Handled;
		}
		
		//Find out the flag number
		new current_flag = GetFlagNumber(entity);

		//Not on Axis so must be at flag
		if (IsClientInGame(other) && current_flag != -1)
			g_atFlag[current_flag][other] = true;
		
		if (GetConVarBool(hL4DSetup))
		{
			PrintToChat(other, "[L4DOD] Flag Entity:%i", entity);
		}
	}
	
	return Plugin_Continue;
}

public Action:OnFlagNotTouched(entity, other)
{
	if (other > 0 && other < MaxClients)
	{
		if (IsClientInGame(other) && GetClientTeam(other) == AXIS)
		{	
			//Find out the flag number
			new current_flag = GetFlagNumber(entity);
			
			if (current_flag != -1)
			{
				g_atFlag[current_flag][other] = false;
			}
			
			return Plugin_Handled;
		}
		
		//Find out the flag number
		new current_flag = GetFlagNumber(entity);
		
		if (IsClientInGame(other) && current_flag != -1)
			g_atFlag[current_flag][other] = false;
	}
	
	return Plugin_Continue;
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
				
				if (GetConVarInt(hL4DGameType) == 1)
				{
					for (new bot=1; bot<=MaxClients; bot++)
					{
						g_HealthAdded[bot] = 0;
					}
				}
				
				new health = g_Health[client];
			
				if (health < g_HealthMax[client])	
				{
					health += 25;
					SetHealth(client, health);
					PrintHelp(client, "{red}*For capping, you received \x05Health", 0);	
					EmitSoundToClient(client, "left4dod/bandage.mp3");
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
				new rnd = GetRandomInt(0,1000);
				
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
					
					case 40, 41:
					{
						CreateTimer(0.2, SpawnHealthBox, client, TIMER_FLAG_NO_MAPCHANGE);
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
		else
		{
			for (new bot=1; bot<=MaxClients; bot++)
			{
				if (IsClientInGame(bot) && IsFakeClient(bot))
					g_HealthAdded[bot] += 20;
			}
		}
	} 
	return Plugin_Handled;
}

