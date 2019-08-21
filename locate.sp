/**
 * =============================================================================
 * SourceMod Bots for Day of Defeat Source
 * (C)2010 Dog - www.thevilluns.org
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
 
 stock bool:IsPointVisible(const Float:start[3], const Float:end[3])
{
	TR_TraceRayFilter(start, end, MASK_PLAYERSOLID, RayType_EndPoint, TraceEntityFilterStuff);

	return TR_GetFraction() == 1.0;
}

stock bool:IsPointVisibleToNPC(const Float:start[3], const Float:end[3])
{
	TR_TraceRayFilter(start, end, MASK_OPAQUE, RayType_EndPoint, TraceEntityFilterStuff);

	return TR_GetFraction() >= 0.75;
}

 stock bool:IsHullVisible(const Float:start[3], const Float:end[3], const Float:mins[3], const Float:maxs[3])
{
	TR_TraceHullFilter(start, end, mins, maxs, MASK_PLAYERSOLID, TraceEntityFilterStuff);

	return TR_GetFraction() == 1.0;
}

public bool:TraceEntityFilterStuff(entity, mask)
{
	return entity > MaxClients;
} 

 GetWaypointsFromSpawn(iClient)
{
	new Float:vecClientOrigin[3];
	GetClientAbsOrigin(iClient, vecClientOrigin);
	
	new iTeam = GetClientTeam(iClient);
	new iClosestSet = 0;
	new Float:fClosestDist = 1000.0;
	
	for (new i = 1; i <= 8; i++)
	{
		new Float:distance;
		if (iTeam == ALLIES)
			distance = GetVectorDistance(g_vecAlliesWaypointSet[i][1], vecClientOrigin);
		else if (iTeam == AXIS)
			distance = GetVectorDistance(g_vecAxisWaypointSet[i][1], vecClientOrigin);
			
		if (distance < fClosestDist)
		{
			fClosestDist = distance;
			iClosestSet = i;
		}
	}
	
	if (iClosestSet > 0)
		g_WayPointSet[iClient] = iClosestSet;
	else
		g_WayPointSet[iClient] = GetRandomInt(1,8);
	
	#if DEBUG
		LogToFileEx(g_szLogFileName,"[L4DOD] LOADING SPAWN WAYPOINT SET %i for %N", g_WayPointSet[iClient], iClient);
	#endif
	
	// Transfer waypoints
	if (iTeam == ALLIES)
	{
		for (new i=1; i <= g_iAlliesKeys[g_WayPointSet[iClient]]; i++)
		{
			g_vecWayPoint[iClient][i] = g_vecAlliesWaypointSet[g_WayPointSet[iClient]][i];		
		}
		
		#if DEBUG
			LogToFileEx(g_szLogFileName,"[L4DOD] Loaded %i Allied waypoints for %N", g_iAlliesKeys[g_WayPointSet[iClient]], iClient);
		#endif
	}
	else if (iTeam == AXIS)
	{
		for (new i=1; i <= g_iAxisKeys[g_WayPointSet[iClient]]; i++)
		{
			g_vecWayPoint[iClient][i] = g_vecAxisWaypointSet[g_WayPointSet[iClient]][i];		
		}
		
		#if DEBUG
			LogToFileEx(g_szLogFileName,"[L4DOD] Loaded %i Axis waypoints for %N", g_iAxisKeys[g_WayPointSet[iClient]], iClient);
		#endif
	}
}

GetNearestWaypoint(iClient)
{
	if (IsClientInGame(iClient) && IsPlayerAlive(iClient) )
	{
		new Float:loc[3];
		GetClientAbsOrigin(iClient, loc);
						
		//There is no point is getting a new set if the same one is returned
		//So find out which set the player currently is on
		new iCurrentSet = g_WayPointSet[iClient];
		
		new Float:nearest = 4000.0;
		new bestset = g_WayPointSet[iClient];
		new bestwp = g_WayPoint[iClient];
		
		if (GetClientTeam(iClient) == AXIS)
		{
			for (new set = 1; set <= 8; set++)
			{	
				if (set != iCurrentSet)
				{
					for (new i = g_iAxisKeys[set]; i >= 1;  i--)
					{			
						if (IsPointVisible(loc, g_vecAxisWaypointSet[set][i]))
						{
							new Float:shortest = GetVectorDistance(loc, g_vecAxisWaypointSet[set][i]);
							if (shortest < nearest 
								&& (loc[2] - g_vecAxisWaypointSet[set][i][2] < 15.0 || g_vecAxisWaypointSet[set][i][2] - loc[2] < 15.0))
							{
								nearest = shortest;
								bestset = set;
								bestwp = i;	
							}
						}
					}
				}
			}
			
			if (bestset != g_WayPointSet[iClient])
			{
				g_WayPointSet[iClient] = bestset;
				g_WayPoint[iClient] = bestwp;
				
				for (new k=1; k <= g_iAxisKeys[g_WayPointSet[iClient]]; k++)
				{
					g_vecWayPoint[iClient][k] = g_vecAxisWaypointSet[g_WayPointSet[iClient]][k];		
				}
			}
		}
		else if (GetClientTeam(iClient) == ALLIES)
		{
			for (new set = 1; set <= 8; set++)
			{				
				if (set != iCurrentSet)
				{
					for (new i = g_iAlliesKeys[set]; i >= 1;  i--)
					{			
						if (IsPointVisible(loc, g_vecAlliesWaypointSet[set][i]))
						{
							new Float:shortest = GetVectorDistance(loc, g_vecAlliesWaypointSet[set][i]);
							if (shortest < nearest 
								&& (loc[2] - g_vecAlliesWaypointSet[set][i][2] < 15.0 || g_vecAlliesWaypointSet[set][i][2] - loc[2] < 15.0))
							{
								nearest = shortest;
								bestset = set;
								bestwp = i;	
							}
						}
					}
				}
			}
			
			if (bestset != g_WayPointSet[iClient])
			{
				g_WayPointSet[iClient] = bestset;
				g_WayPoint[iClient] = bestwp;
				
				for (new k=1; k <= g_iAlliesKeys[g_WayPointSet[iClient]]; k++)
				{
					g_vecWayPoint[iClient][k] = g_vecAlliesWaypointSet[g_WayPointSet[iClient]][k];		
				}
			}
		}
	}
	
	#if DEBUG
	LogToFileEx(g_szLogFileName,"NEW WAYPOINT SET Client:%N Set:%i Pos:%i", iClient, g_WayPointSet[iClient], g_WayPoint[iClient]);
	#endif
}

public Float:DistanceToSky(iClient)
{
	new Float:location[3];
	GetClientAbsOrigin(iClient, location);
	
	location[2] += 75.0;
	
	new Float:angle[3], Float:endpos[3];
	angle[0] = -90.0;
	angle[1] = 0.0;
	angle[2] = 0.0;
			
	new Handle:trace = TR_TraceRayEx(location, angle, MASK_SOLID, RayType_Infinite);
	
	if(TR_DidHit(trace))
		TR_GetEndPosition(endpos, trace);
	
	CloseHandle(trace);
	
	return endpos[2] - location[2];
}

public Float:VectorToSky(Float:location[3])
{	
	location[2] += 75.0;
	
	new Float:angle[3], Float:endpos[3];
	angle[0] = -90.0;
	angle[1] = 0.0;
	angle[2] = 0.0;
			
	new Handle:trace = TR_TraceRayEx(location, angle, MASK_SOLID, RayType_Infinite);
	
	if(TR_DidHit(trace))
		TR_GetEndPosition(endpos, trace);
	
	CloseHandle(trace);
	
	return endpos[2] - 80.0;
}

//HUMAN LOCATORS ////////////////////////////////////////////////////////////////////////////////////
GetNearestWaypointToTarget(iClient, iTarget)
{
	if (IsClientInGame(iClient) && IsPlayerAlive(iClient))
	{	
		new Float:loc[3], Float:target_loc[3];
		GetClientEyePosition(iClient, loc);
		GetClientEyePosition(iTarget, target_loc);
		
		new best_set;
		new target_wp;
		
		new Float:nearest = 4000.0;
		
		if (GetClientTeam(iClient) == AXIS)
		{
			for (new set = 1; set <= 8; set++)
			{
				//Is the target near bot waypoint set?
				for (new i = g_iAxisKeys[set]; i >= 1;  i--)
				{			
					if (IsPointVisible(target_loc, g_vecAxisWaypointSet[set][i]))
					{
						new Float:shortest = GetVectorDistance(target_loc, g_vecAxisWaypointSet[set][i]);
						if (shortest < nearest)
						{
							nearest = shortest;
							best_set = set;
							target_wp = i;
						}
					}
				}
			}
			
			if (best_set != g_WayPointSet[iClient])
			{
				g_WayPointSet[iClient] = best_set;
				
				// Load the bots waypoint set
				for (new i=1; i <= g_iAxisKeys[g_WayPointSet[iClient]]; i++)
				{
					g_vecWayPoint[iClient][i] = g_vecAxisWaypointSet[g_WayPointSet[iClient]][i];		
				}
			
				//Find the nearest point on the waypoint set to the bot
				nearest = 4000.0;
				for (new i = g_iAxisKeys[g_WayPointSet[iClient]]; i >= 1;  i--)
				{			
					if (IsPointVisible(loc, g_vecWayPoint[iClient][i]))
					{
						new Float:shortest = GetVectorDistance(loc, g_vecWayPoint[iClient][i]);
						if (shortest < nearest)
						{
							nearest = shortest;
							g_WayPoint[iClient] = i;			
						}
					}
				}
				
				if (target_wp > g_WayPoint[iClient])
					g_iBotsDirection[iClient] = 1;
				else
					g_iBotsDirection[iClient] = -1;
			}
		}
		
		#if DEBUG
		LogToFileEx(g_szLogFileName,"NEW TARGET WAYPOINT SET Client:%N Set:%i Pos:%i", iClient, g_WayPointSet[iClient], g_WayPoint[iClient]);
		#endif
	}
}

GetNearestEnemy(any:iClient)
{
	if (GetConVarInt(hL4DOn) && g_bCanTarget[iClient])
	{
		new index=0;
		new iPlayer[MAXPLAYERS+1];
		new Float:botVision = 2000.0;
					
		new iEnemyTeam;
		new iTeam = GetClientTeam(iClient);
		if (iTeam == AXIS) iEnemyTeam = ALLIES;
		else iEnemyTeam = AXIS;
					
		for (new i=1; i <= MaxClients; i++)
		{
			if (IsClientInGame(i) && IsPlayerAlive(i) && GetClientTeam(i) == iEnemyTeam)
			{
				new Float:vecBotEyes[3], Float:vecTargetEyes[3], Float:vecTargetPosition[3], Float:vecBotPosition[3];
				
				GetClientEyePosition(iClient, vecBotEyes);
				GetClientAbsOrigin(iClient, vecBotPosition);
				
				GetClientEyePosition(i, vecTargetEyes);
				GetClientAbsOrigin(i, vecTargetPosition);
													
				if (GetVectorDistance(vecBotEyes, vecTargetEyes) < botVision)
				{				
					if (IsPointVisible(vecBotEyes, vecTargetEyes))
					{		
						//Some bots can target regardless
						if (g_ZombieType[iClient] == ANARCHIST || g_ZombieType[iClient] == GASMAN 
							|| g_ZombieType[iClient] == GREYDUDE || g_ZombieType[iClient] == WITCH || g_ZombieType[iClient] == HELLSPAWN)
						{
							//Target Machine gunners
							decl String:Weapon[32];
							GetClientWeapon(i, Weapon, sizeof(Weapon));
							
							if (StrEqual(Weapon, "weapon_mg42") || StrEqual(Weapon, "weapon_30cal"))
							{
								return i;
							}
							else
							{
								iPlayer[index] = i;
								index++;	
							}
						}
						//UNG targets snipers
						else if (g_ZombieType[iClient] == UNG)
						{
							decl String:Weapon[32];
							GetClientWeapon(i, Weapon, sizeof(Weapon));
							
							if (StrEqual(Weapon, "weapon_mg42") || StrEqual(Weapon, "weapon_30cal") || StrEqual(Weapon, "weapon_k98_scoped") || StrEqual(Weapon, "weapon_spring"))
							{
								return i;
							}
							else
							{
								iPlayer[index] = i;
								index++;	
							}
						}
						else
						{
							//Don't target enemies out of reach
							//2 models high
							//Depending on map type
							if (g_mapType == 1)
							{
								iPlayer[index] = i;
								index++;
							}
							else
							{
								if (vecTargetPosition[2] < (vecBotPosition[2] + 144.0)) 
								{
									iPlayer[index] = i;
									index++;
								}
							}
						}
					}
				}
			}
		}
		
		if (index >= 1)
		{
			new iRnd = GetRandomInt(0, index-1);
			return iPlayer[iRnd];
		}
		else
			return 0;
	}
	return 0;
}

SeekEnemy(any:entity)
{
	new Float:MinHull[3] = {-16.071752, -2.363513, -2.363512};
	new Float:MaxHull[3] = {15.930954, 2.363512, 2.363512};
	
	decl Float:vecRocket[3];
	GetEntPropVector(entity, Prop_Send, "m_vecOrigin", vecRocket);

	new iClosestEnemy = 0;
	new Float:fClosestDistance = 8000.0;
	new Float:fDistance;
	
	for (new i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i) && IsPlayerAlive(i) && GetClientTeam(i) == AXIS)
		{
			if (g_Invisible[i])
				continue;
				
			if (g_bIsSupporter[i] && GetConVarInt(hL4DGameType) != 2)
				continue;
				
			if (g_iJumps[i] > 0)
				continue;
			
			//Maybe target people with lotsa money
			if (!IsFakeClient(i) && GetRandomInt(0,1000) > 500)
				continue;
							
			if (g_ZombieType[i] == INFECTEDONE)
				continue;
				
			decl Float:vecEnemy[3];
			GetClientEyePosition(i, vecEnemy);
			TR_TraceHullFilter(vecRocket, vecEnemy, MinHull, MaxHull, MASK_ALL, RayDontHitOwnerOrSelf, entity);
			if (TR_GetEntityIndex() == i)
			{
				fDistance = GetVectorDistance(vecRocket, vecEnemy);
				if (fDistance < fClosestDistance)
				{
					iClosestEnemy = i;
					fClosestDistance = fDistance;
				}
			}
		
		}
	}
	
	return iClosestEnemy;
}

public bool:RayDontHitOwnerOrSelf(entity, contentsMask, any:data)
{
	new iOwner = GetEntPropEnt(data, Prop_Send, "m_hOwnerEntity");
	return ((entity != data) && (entity != iOwner));
}

public bool:AreHumansNearby(any:iClient, Float:distance)
{
	if (GetConVarInt(hL4DOn))
	{
		new index=0;
		new iPlayer[MAXPLAYERS+1];

		new Float:mins[3] = {-16.000000, -16.000000, 0.000000};
		new Float:maxs[3] = {16.000000, 16.000000, 72.000000};
							
		for (new i=1; i <= MaxClients; i++)
		{
			if (IsClientInGame(i) && IsPlayerAlive(i) && !IsFakeClient(i))
			{
				new Float:vecBotEyes[3], Float:vecTargetEyes[3];
				
				GetClientEyePosition(iClient, vecBotEyes);
				GetClientEyePosition(i, vecTargetEyes);
									
				if (GetVectorDistance(vecBotEyes, vecTargetEyes) < distance)
				{
					//Are there humans near bot and are there humans near teleport destination
					if (IsHullVisible(vecBotEyes, vecTargetEyes, mins, maxs) 
						&& GetVectorDistance(g_vecWayPoint[iClient][g_WayPoint[iClient]], vecTargetEyes) < 900.0)
					{
						iPlayer[index] = i;
						index++;
					}
				}
			}
		}
		
		if (index >= 1)
			return true;
		
		else
			return false;
	}
	return false;
}
