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

// TARGETTING AND DIRECTION ####################################################################################
//Begin the Timer that will keep the bot moving towards targets and waypoints
public Action:SearchTargets(Handle:timer, any:iClient)
{
	if (!IsClientInGame(iClient) || !IsPlayerAlive(iClient) || GetConVarInt(hL4DOn) == 0 || g_bRoundOver)
	{
		g_hSearch_Timer[iClient] = INVALID_HANDLE;

		#if DEBUG
			LogToFileEx(g_szLogFileName,"[BOTS] Stopped Search Timer: %i", iClient);
		#endif

		return Plugin_Stop;
	}
	else
	{
		PerformSearch(iClient);

		#if DEBUG>2
			LogToFileEx(g_szLogFileName,"[BOTS] %N SET:%i Waypoint:%i Dir: %i",
					1, g_WayPointSet[1], g_WayPoint[1], g_iBotsDirection[1]);
		#endif
	}

	return Plugin_Continue;
}

PerformSearch(iBot)
{
	if (IsClientInGame(iBot) && IsFakeClient(iBot))
	{
		//Find a player on the other team
		if (g_iBotsTarget[iBot] == 0)
		{
			g_iBotsTarget[iBot] = GetNearestEnemy(iBot);
		}
		else
		{
			// Ignore the target
			if (g_isIgnored[g_iBotsTarget[iBot]])
				g_iBotsTarget[iBot] = 0;

			if (g_isInfected[g_iBotsTarget[iBot]] && g_ZombieType[iBot] == INFECTEDONE)
				g_iBotsTarget[iBot] = 0;

			if (g_iBotsTarget[iBot] > 0 && IsClientInGame(g_iBotsTarget[iBot]) && IsPlayerAlive(g_iBotsTarget[iBot]))
				GetNearestWaypointToTarget(iBot, g_iBotsTarget[iBot]);
		}
	}
}
