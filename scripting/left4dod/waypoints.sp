/**
 * =============================================================================
 * SourceMod Bots for Day of Defeat Source
 * (C)2010 Dog - www.theville.org
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
// #######################################################################

public Action:Command_Location(iClient, args)
{
	if (iClient > 0)
	{
		new Float:vecs[3], Float:angs[3];
		GetClientAbsOrigin(iClient, vecs);
		PrintToChat(iClient, "loc %f %f %f", vecs[0], vecs[1], vecs[2]);

		GetClientAbsAngles(iClient, angs);
		PrintToChat(iClient, "angle %f %f %f", angs[0], angs[1], angs[2]);

		new Float:height;
		height = DistanceToSky(iClient);
		PrintToChat(iClient, "Height above head: %f", height);

		new x = -1, Float:vLoc[3], number = 0;
		while ((x = FindEntityByClassname(x, "dod_control_point")) != -1)
		{
			GetEntDataVector(x, g_oEntityOrigin, vLoc);

			PrintToChat(iClient, "%f %f %f", vLoc[0], vLoc[1], VectorToSky(vLoc));
			number++;
		}
	}
	return Plugin_Handled;
}

public Action:Command_Waypoint(iClient, args)
{
	new String:wp_type[16], String:wp_set[16], String:team[16], Float:location[3];

	if (args < 2)
	{
		ReplyToCommand(iClient, "[SM] Usage: sm_waypoint <add> <#>");
		return Plugin_Handled;
	}

	GetCmdArg(1, wp_type, sizeof(wp_type));
	GetCmdArg(2, wp_set, sizeof(wp_set));
	new setnumber = StringToInt(wp_set);
	new setteam = GetClientTeam(iClient);

	if (iClient > 0 && GetClientTeam(iClient) > 1)
	{
		if (setnumber > 0 && setnumber < 9)
		{
			if (StrEqual(wp_type, "add"))
			{
				GetClientAbsOrigin(iClient, location);

				if (setteam == AXIS)
				{
					Format(team, sizeof(team), "axis%i", setnumber);
					g_iAxisKeys[setnumber] += 1;

					SetMapData(team, g_iAxisKeys[setnumber], location, setnumber, setteam);
					PrintToChat(iClient, "[SM] Waypoint set [%i]: %i", setnumber, g_iAxisKeys[setnumber]);
				}
				else if (setteam == ALLIES)
				{
					Format(team, sizeof(team), "allies%i", setnumber);
					g_iAlliesKeys[setnumber] += 1;

					SetMapData(team, g_iAlliesKeys[setnumber], location, setnumber, setteam);
					PrintToChat(iClient, "[SM] Waypoint set [%i]: %i", setnumber, g_iAlliesKeys[setnumber]);
				}
			}
		}
		else
		{
			ReplyToCommand(iClient, "[SM] Maximum of 8 waypoint sets allowed");
		}
	}
	return Plugin_Handled;
}

bool:SetMapData(String:team[], any:key, Float:vector[3], any:setnumber, any:iTeam)
{
	new Handle:h_KV = CreateKeyValues("WayPoints");

	decl String:datapath[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, datapath, PLATFORM_MAX_PATH, "data/bot_%s.nav", g_szMapName);

	FileToKeyValues(h_KV, datapath);

	if (!KvJumpToKey(h_KV, team, true))
	{
		CloseHandle(h_KV);
		return false;
	}
	new String:temp[8];
	Format(temp, sizeof(temp), "%i", key);
	KvSetVector(h_KV, temp, vector);
	KvRewind(h_KV);
	KeyValuesToFile(h_KV, datapath);


	if (!KvJumpToKey(h_KV, "data", true))
	{
		CloseHandle(h_KV);
		return false;
	}

	new String:setkeys[16];

	if (iTeam == 3)
		Format(setkeys, sizeof(setkeys), "axiskeys%i", setnumber);
	else if (iTeam == 2)
		Format(setkeys, sizeof(setkeys), "allieskeys%i", setnumber);

	KvSetNum(h_KV, setkeys, key);
	KvRewind(h_KV);
	KeyValuesToFile(h_KV, datapath);

	CloseHandle(h_KV);
	return true;
}

bool:GetMapData()
{
	new Handle:h_KV = CreateKeyValues("WayPoints");
	new String:temp[5];
	new String:setgroup[16], String:setkeys[16];

	decl String:datapath[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, datapath, PLATFORM_MAX_PATH, "data/bot_%s.nav", g_szMapName);
	FileToKeyValues(h_KV, datapath);

	for (new iTeam = 2; iTeam <= 3; iTeam++)
	{
		for (new i = 1; i <= 8; i++)
		{
			KvRewind(h_KV);
			///////////////////////////////////////////////////////////////// Get the number of waypoints
			if (!KvJumpToKey(h_KV, "data"))
			{
				CloseHandle(h_KV);
				LogToFileEx(g_szLogFileName,"[L4DOD] UNABLE TO LOAD NAVIGATION - MISSING KEYS");
				return false;
			}
			if (iTeam == ALLIES)
			{
				Format(setkeys, sizeof(setkeys), "allieskeys%i", i);
				g_iAlliesKeys[i] = KvGetNum(h_KV, setkeys, 0);

				#if DEBUG
				LogToFileEx(g_szLogFileName,"[L4DOD] ALLIES SET %i LOADED with %i KEYS", i, g_iAlliesKeys[i]);
				#endif
			}
			else if (iTeam == AXIS)
			{
				Format(setkeys, sizeof(setkeys), "axiskeys%i", i);
				g_iAxisKeys[i] = KvGetNum(h_KV, setkeys, 0);

				#if DEBUG
				LogToFileEx(g_szLogFileName,"[L4DOD] AXIS SET %i LOADED with %i KEYS", i, g_iAxisKeys[i]);
				#endif
			}

			KvRewind(h_KV);

			///////////////////////////////////////////////////////////////// Lookup Axis waypoints
			if (iTeam == ALLIES)
				Format(setgroup, sizeof(setgroup), "allies%i", i);
			else if (iTeam == AXIS)
				Format(setgroup, sizeof(setgroup), "axis%i", i);

			if (!KvJumpToKey(h_KV, setgroup))
			{
				CloseHandle(h_KV);
				LogToFileEx(g_szLogFileName,"[L4DOD] UNABLE TO LOAD NAVIGATION - MISSING WAYPOINTS");
				return false;
			}

			if (iTeam == ALLIES)
			{
				for (new keyvalue=1; keyvalue <= g_iAlliesKeys[i]; keyvalue++)
				{
					Format(temp, sizeof(temp), "%i", keyvalue);
					KvGetVector(h_KV, temp, g_vecAlliesWaypointSet[i][keyvalue]);
				}
			}
			else if (iTeam == AXIS)
			{
				for (new keyvalue=1; keyvalue <= g_iAxisKeys[i]; keyvalue++)
				{
					Format(temp, sizeof(temp), "%i", keyvalue);
					KvGetVector(h_KV, temp, g_vecAxisWaypointSet[i][keyvalue]);
				}
			}
		}
	}

	///////////////////////////////////////////////////////////////// Lookup creator info
	KvRewind(h_KV);

	if (KvJumpToKey(h_KV, "creator"))
	{
		KvGetString(h_KV, "name", g_szWayPointCreator, 32);
		KvGetString(h_KV, "date", g_szWayPointDate, 16);
	}

	CloseHandle(h_KV);

	SetConVarInt(hL4DSetup, 0);
	SetConVarInt(hL4DOn, 1);

	#if DEBUG
		LogToFileEx(g_szLogFileName,"[L4DOD] MAP DATA LOADED SUCCESSFULLY");
	#endif

	return true;
}
