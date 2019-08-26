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
 // Determines whether a bot needs help in its positioning
 public Action:CheckLocation(Handle:timer, any:iClient)
{
	if (!IsClientInGame(iClient) || !IsPlayerAlive(iClient) || GetConVarInt(hL4DOn) == 0 || g_bRoundOver)
	{
		g_hLocation_Timer[iClient] = INVALID_HANDLE;

		#if DEBUG
			LogToFileEx(g_szLogFileName,"[BOTS] Stopped Location Timer: %i", iClient);
		#endif

		return Plugin_Stop;
	}
	else
	{
		//PerformCheck(iClient);
	}

	return Plugin_Continue;
}

PerformCheck(client)
{
	if (IsClientInGame(client) && IsFakeClient(client) && g_bRoundActive)
	{
		new Float:vecBotPosition[3];

		GetClientAbsOrigin(client, vecBotPosition);
		g_vecLastPosition[client][0] = vecBotPosition[0];
		g_vecLastPosition[client][1] = vecBotPosition[1];
		g_vecLastPosition[client][2] = vecBotPosition[2];
	}
}
