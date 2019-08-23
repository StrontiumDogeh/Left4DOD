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
 
// COMMANDS #######################################################################
public Action:Command_VoiceMenu(client, const String:command[], argc)
{
	if (client)
	{
		if (GetClientTeam(client) == AXIS)
		{
			if (g_ZombieType[client] != 0)
			{
				new randomnumber = GetRandomInt(0,13);
				EmitSoundToAll(g_ZombieIdleSounds[randomnumber], client);
			}
			else
			{
				new rnd = GetRandomInt(0, 5);
				EmitSoundToAll(g_WitchSounds[rnd], client);
			}
			return Plugin_Handled;
		}
	}
	return Plugin_Continue;
}

public Action:Command_Drop(client, args)
{
	if (client)
	{
		if (GetClientTeam(client) == ALLIES)
			return Plugin_Handled;

	}
	return Plugin_Continue;
}

public Action:Command_RecordingDemo(client, args)
{
	if (client > 0)
	{
		g_iSuspendAFK[client] = true;
	}
	return Plugin_Handled;
}

public Action:Command_StopRecordingDemo(client, args)
{
	if (client > 0)
	{
		g_iSuspendAFK[client] = false;
	}
	return Plugin_Handled;
}

public Action:Command_Kill(client, args)
{
	if (client)
	{
		if (GetClientTeam(client) == ALLIES)
			return Plugin_Handled;

	}
	return Plugin_Continue;
}

public Action:Command_DropHealth(client, args) 
{
	if (client > 0 && IsClientInGame(client) && GetClientTeam(client) == ALLIES)
	{
		
		if (g_numDroppedHealth[client] > 0)
		{
			CreateTimer(0.1, SpawnHealthBoxInFront, client, TIMER_FLAG_NO_MAPCHANGE);

			g_numDroppedHealth[client]--;
		}
		else
			PrintHelp(client, "*You do not have enough health kits", 0);

	}
		
	return Plugin_Handled;
}

public Action:Command_Medic(client, args) 
{
	if (client > 0 && IsClientInGame(client) && GetClientTeam(client) == ALLIES)
		PrintHelp(client, "*Pick up the \x04RED boxes\x01 when a Zombie dies", 0);	
	return Plugin_Handled;
}

public Action:Command_Ammo(client, args) 
{
	if (client > 0 && IsClientInGame(client) && GetClientTeam(client) == ALLIES)
		PrintHelp(client, "*Pick up the \x05GREEN boxes\x01 when a Zombie dies", 0);	
	return Plugin_Handled;
}

public Action:Command_Help(client, args)
{
	if (client > 0)
		ShowMOTDPanel(client, "Left4DoD Help", "http://www.boff.ca/left4dod/index.html", MOTDPANEL_TYPE_URL );
		
	return Plugin_Handled;
}

public Action:Command_Status(client, args)
{
	new total_drops = g_AmmoBoxNumber + g_HealthPackNumber + g_ZombieBloodNumber + g_PillsNumber + g_HoochNumber + g_AdrenalineNumber + g_BoxNadesNumber + g_AntiGasNumber +g_RadioNumber + g_ShieldNumber + g_SpringNumber;
	
	PrintToConsole(client, "");
	PrintToConsole(client, "======= LEFT4DOD STATUS V%s ======", PLUGIN_VERSION);
	PrintToConsole(client, "Allied Wins: %i", g_AlliedWins);
	PrintToConsole(client, "Axis Wins: %i", g_AxisWins);
	PrintToConsole(client, "Axis Number: %i", GetAxisTeamNumber());
	PrintToConsole(client, "Allies Number: %i", GetAlliedTeamNumber());
	PrintToConsole(client, "GameType: %i", GetConVarInt(hL4DGameType));
	PrintToConsole(client, "");
	PrintToConsole(client, "Entities: %i/%i", GetEntityCount(), GetMaxEntities());
	PrintToConsole(client, "Total drops: %i", total_drops);
	PrintToConsole(client, "");
	PrintToConsole(client, "Allied Flag Status: %s", g_FlagStates[g_AlliedFlagStatus]);
	PrintToConsole(client, "Axis Flag Status: %s", g_FlagStates[g_AxisFlagStatus]);
		
	if (GetConVarInt(hL4DGameType) == 0)
	{
		PrintToConsole(client, "");
		PrintToConsole(client, "======= LEFT4DOD TEAM SWAP STATUS ======");
		for (new i = 1; i <= MaxClients; i++)
		{
			if (!IsClientInGame(i))
				continue;
			
			if (IsFakeClient(i))
				continue;
				
			if (g_iSwapped[i] == 0)
				continue;
			
			PrintToConsole(client, "%N - Swapped: %i", i, g_iSwapped[i]);
		}
	}
	
	PrintToConsole(client, "");
	PrintToConsole(client, "======= LEFT4DOD BANK ======");
	for (new i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i))
			continue;
		
		if (IsFakeClient(i))
			continue;
		
		if (g_iMoney[i] > 0)
			PrintToConsole(client, "%N - $%i", i, g_iMoney[i]);
	}
	
	PrintToConsole(client, "");
	PrintToConsole(client, "======= LEFT4DOD GROUP STATUS ======");
	for (new i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i))
			continue;
		
		if (IsFakeClient(i))
			continue;
				
		if (g_bIsSupporter[i])
			PrintToConsole(client, "%N - is a Left4DoD Ville Supporter", i);
		
		if (g_IsMember[i] == 1)
			PrintToConsole(client, "%N - is a Left4DoD Ville Steam Group Member", i);
			
		else if (g_IsMember[i] == 2)
			PrintToConsole(client, "%N - is a Left4DoD Ville Steam Group Admin", i);
	}

	
	return Plugin_Handled;
}


public Action:Command_BotStatus(client, args)
{
	for (new i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i))
			continue;
		
		if (!IsFakeClient(i))
			continue;
		
		PrintToConsole(client, "%N - Health: %i MaxHealth: %i)", i, g_Health[i], g_HealthMax[i]);
	}
	return Plugin_Handled;
}

public Action:Command_Radio(client, args)
{
	if (IsClientInGame(client))
	{
		if (client > 0)
		ShowMOTDPanel(client, "Game Radio", "http://boff.clanservers.com", MOTDPANEL_TYPE_URL );

	}
	return Plugin_Continue;
}

public Action:Command_RadioOff(client, args)
{
	if (IsClientInGame(client))
	{
		if (client > 0)
		{
			PrintToChat(client, "Say !off to turn off the radio");
			ShowMOTDPanel(client, "Game Radio", "http://boff.clanservers.com/blank.html", MOTDPANEL_TYPE_URL );
		}
	}
	return Plugin_Continue;
}