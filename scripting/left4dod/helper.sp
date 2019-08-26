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
// HELPER ROUTINES ############################################################################################

public GetLivePlayers(any:iTeam)
{
	new iCount = 0;
	for (new i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i) && IsPlayerAlive(i) && GetClientTeam(i) == iTeam)
			iCount++;
	}

	return iCount;
}

GetAlliedTeamNumber()
{
	return GetTeamClientCount(2);
}

GetAxisTeamNumber()
{
	new humanstotal = 0;

	for (new i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i) && GetClientTeam(i) == AXIS)
		{
			if (GetUserFlagBits(i) & ADMFLAG_ROOT || GetUserFlagBits(i) & ADMFLAG_BAN)
				continue;

			if (!IsFakeClient(i))
				humanstotal++;
		}
	}
	return humanstotal;
}

stock GetAxisBotNumber()
{
	new botstotal = 0;

	for (new i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i) && GetClientTeam(i) == 3)
		{
			if (IsFakeClient(i))
				botstotal++;
		}
	}
	return botstotal;
}

GetHumansNumber()
{
	new humanstotal = 0;

	for (new i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i))
		{
			if (!IsFakeClient(i))
				humanstotal++;
		}
	}
	return humanstotal + GetConVarInt(hL4DAI);
}

GetHumansNumberOnTeams()
{
	new humanstotal = 0;

	for (new i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i))
		{
			if (!IsFakeClient(i) && GetClientTeam(i) > 1)
				humanstotal++;
		}
	}
	return humanstotal + GetConVarInt(hL4DAI);
}

GetHumansConnected()
{
	new humanstotal = 0;

	for (new i = 1; i <= MaxClients; i++)
	{
		if (IsClientConnected(i))
		{
			if (!IsFakeClient(i))
				humanstotal++;
		}
	}
	return humanstotal;
}

CheckLocationNearAlliedSpawn(Float:Loc[3], Float:distance)
{
	for (new i = 0; i < g_NumberofAlliedSpawnPoints; i++)
	{
		if (GetVectorDistance(Loc, g_fAlliedSpawnVectors[i]) < distance)
			return true;
	}

	return false;
}

CheckLocationNearAxisSpawn(Float:Loc[3], Float:distance)
{
	for (new i = 0; i < g_NumberofAxisSpawnPoints; i++)
	{
		if (GetVectorDistance(Loc, g_fAxisSpawnVectors[i]) < distance)
			return true;
	}

	return false;
}

public Float:GetDistanceToAxisSpawn(Float:Loc[3])
{
	new Float:distance;
	new Float:bestDistance = 4000.0;
	for (new i = 0; i < g_NumberofAxisSpawnPoints; i++)
	{
		distance = GetVectorDistance(Loc, g_fAxisSpawnVectors[i]);
		if (distance < bestDistance)
			bestDistance = distance;
	}

	return bestDistance;
}

public bool:GetAlliesNearby(any:client, Float:distance)
{
	new bool:isVisible = false;
	new Float:ClientVector[3], Float:PlayerVector[3];

	if (GetConVarInt(hL4DOn))
	{
		for (new i=1; i <= MaxClients; i++)
		{
			if (IsClientInGame(i) && GetClientTeam(i) == 2 && IsPlayerAlive(i))
			{
				if (i == client)
					continue;

				GetClientEyePosition(client, ClientVector);
				GetClientEyePosition(i, PlayerVector);

				if (GetVectorDistance(ClientVector, PlayerVector) < distance)
				{
					if (IsPointVisible(ClientVector, PlayerVector))
						isVisible = true;
				}
			}
		}
	}
	return isVisible;
}

public bool:GetAlliesNearFlag(Float:vecFlag[3], Float:distance)
{
	new Float:PlayerVector[3];

	for (new i=1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i) && GetClientTeam(i) == ALLIES && IsPlayerAlive(i))
		{
			GetClientAbsOrigin(i, PlayerVector);

			if (GetVectorDistance(vecFlag, PlayerVector) < distance)
			{
				return true;
			}
		}
	}

	return false;
}

// 0 both
// 1 ignore BOTS
// 2 ignore ALLIES
// 3 ignore AXIS
public GetClosestClient(Float:pos[3], ignore)
{
	new Float:ClientVector[3], Float:fDistance, Float:fNearest = DROP_RANGE;
	new closest = 0;

	for (new i=1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i) && IsPlayerAlive(i))
		{
			if (ignore == 3 && GetClientTeam(i) == AXIS)
				continue;

			if (ignore == 1 && IsFakeClient(i))
				continue;

			GetClientAbsOrigin(i, ClientVector);

			fDistance = GetVectorDistance(ClientVector, pos);
			if (fDistance < fNearest)
			{
				fNearest = fDistance;
				closest = i;
			}
		}
	}
	return closest;
}

//When false: select_humans dooes not include human Zombies
SelectBot(any:method)
{
	new index=0;
	new client[MAXPLAYERS+1];

	for (new i=1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i) && IsPlayerAlive(i) && GetClientTeam(i) == 3)
		{
			// Selects ALL Axis players including bots
			if (method == 1 && g_bCanMakeNoise[i])
			{
				client[index] = i;
				index++;
				g_bCanMakeNoise[i] = false;
				CreateTimer(3.0, AllowMakeNoise, i, TIMER_FLAG_NO_MAPCHANGE);
			}

			// Selects ALL bots except SI
			else if (method == 0)
			{
				if (IsFakeClient(i))
				{
					if (g_ZombieType[i] == 0 || g_ZombieType[i] == 1
					|| g_ZombieType[i] == 2 || g_ZombieType[i] == 3
					|| g_ZombieType[i] == 5 || g_ZombieType[i] == 6 || g_ZombieType[i] == 8 || g_ZombieType[i] == 9)
						continue;

					if (g_ZombieType[i] == EMO && g_AlliedWins <= g_AxisWins)
						continue;

					else
					{
						if (g_iBotsStuck[i] > 400)
						{
							g_iBotsStuck[i] = 0;
							return i;
						}

						client[index] = i;
						index++;
					}
				}
			}
			// Selects ALL bots
			else if (method == 2)
			{
				if (IsFakeClient(i))
				{
					client[index] = i;
					index++;
				}
			}
		}
	}

	if (index >=1)
	{
		new randomnumber = GetRandomInt(0, index-1);
		return client[randomnumber];
	}
	else
		return 0;
}

public bool:TraceEntityFilterAll (entity, contentsMask)
{
  return false;
}

public bool:TraceRayDontHitSelf(entity, mask, any:client)
{
	return (entity != client);
}

public bool:TraceEntityFilterPlayer(entity, contentsMask)
{
	return entity > MaxClients || !entity;
}

public bool:TraceRayFilterWorld(entity, mask, any:client)
{
	return entity < MaxClients || entity != client;
}

public bool:TraceRayFilterNonPlayers(entity, mask)
{
	return entity > 0 && entity < MaxClients+1;
}

//Blind the player
FadeOut(any:client)
{
	if(IsClientInGame(client))
	{
		new Handle:hFadeClient = StartMessageOne("Fade", client);
		BfWriteShort(hFadeClient, 800);	// FIXED 16 bit, with SCREENFADE_FRACBITS fractional, seconds duration
		BfWriteShort(hFadeClient, 800);		// FIXED 16 bit, with SCREENFADE_FRACBITS fractional, seconds duration until reset (fade & hold)
		BfWriteShort(hFadeClient, (FFADE_PURGE|FFADE_OUT|FFADE_STAYOUT)); // fade type (in / out)
		BfWriteByte(hFadeClient, 0);	// fade red
		BfWriteByte(hFadeClient, 0);	// fade green
		BfWriteByte(hFadeClient, 0);	// fade blue
		BfWriteByte(hFadeClient, 255);	// fade alpha
		EndMessage();
	}
}

//Restore vision
FadeIn(any:client)
{
	if(IsClientInGame(client))
	{
		new Handle:hFadeClient = StartMessageOne("Fade", client);
		BfWriteShort(hFadeClient, 800);	// FIXED 16 bit, with SCREENFADE_FRACBITS fractional, seconds duration
		BfWriteShort(hFadeClient, 800);		// FIXED 16 bit, with SCREENFADE_FRACBITS fractional, seconds duration until reset (fade & hold)
		BfWriteShort(hFadeClient, (FFADE_PURGE|FFADE_IN|FFADE_STAYOUT)); // fade type (in / out)
		BfWriteByte(hFadeClient, 0);	// fade red
		BfWriteByte(hFadeClient, 0);	// fade green
		BfWriteByte(hFadeClient, 0);	// fade blue
		BfWriteByte(hFadeClient, 255);	// fade alpha
		EndMessage();
	}
}

