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

public Action:BroadcastAudioEvent(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (GetConVarInt(hL4DOn))
	{
		new String:sound[128];
		GetEventString(event, "sound", sound, sizeof(sound));

		if(strcmp(sound,"Game.USWin", true) == 0)
		{
			for (new client = 1; client <= MaxClients; client++)
			{
				if(IsClientInGame(client) && !IsFakeClient(client))
					EmitSoundToClient(client, "left4dod/allied_win.mp3");
			}
			return Plugin_Handled;
		}

		if(strcmp(sound,"Game.GermanWin", true) == 0)
		{
			new rum = GetRandomInt(0,3);

			for (new client = 1; client <= MaxClients; client++)
			{
				if(IsClientInGame(client) && !IsFakeClient(client))
				{
					EmitSoundToClient(client, g_EndSounds[rum]);
				}
			}
			return Plugin_Handled;
		}

		if(strcmp(sound,"Voice.German_StartRound", true) ==0)
		{
			new randint = GetRandomInt(0,13);
			for (new client = 1; client <= MaxClients; client++)
			{
				if(IsClientInGame(client) && !IsFakeClient(client) && GetClientTeam(client) == 3)
					EmitSoundToClient(client, g_ZombieIdleSounds[randint]);
			}
			return Plugin_Handled;
		}

		if(strcmp(sound,"Voice.German_FlagCapture", true) ==0)
		{
			new randint = GetRandomInt(0,13);
			for (new client = 1; client <= MaxClients; client++)
			{
				if(IsClientInGame(client) && !IsFakeClient(client) && GetClientTeam(client) == 3)
					EmitSoundToClient(client, g_ZombieIdleSounds[randint]);
			}
			return Plugin_Handled;
		}
	}
	return Plugin_Continue;
}

// ################################### SOUNDS ######################################################################################

public Action:Ambient(Handle:timer, any:data)
{
	if (g_bRoundOver)
	{
		hAmbientTimer = INVALID_HANDLE;
		return Plugin_Stop;
	}

	EmitSoundToAll("ambient/left4dod.mp3", SOUND_FROM_PLAYER, _, _, _, 0.5);

	return Plugin_Handled;
}

public Action:ZombieSounds(Handle:timer, any:client)
{
	if (g_bRoundOver)
	{
		hZombieSoundsTimer = INVALID_HANDLE;
		return Plugin_Stop;
	}

	new bot = SelectBot(1);

	if (bot > 0 && IsClientInGame(bot) && GetClientTeam(bot) == AXIS)
	{
		if (IsPlayerAlive(bot))
		{
			if (g_ZombieType[bot] != 0)
			{
				new rnd = GetRandomInt(0, 26);
				EmitSoundToAll(g_ZombieSounds[rnd], bot);
			}
			else
			{
				new rnd = GetRandomInt(0, 4);
				EmitSoundToAll(g_WitchSounds[rnd], bot);
			}
		}
	}

	return Plugin_Handled;
}

PlaySound(any:bot, bool:isEntity)
{
	if (!isEntity)
	{
		if (bot > 0 && IsClientInGame(bot) && IsPlayerAlive(bot))
		{
			if (GetClientTeam(bot) == 3)
			{
				if (g_ZombieType[bot] == 0)
				{
					// It's a witch
					new rnd = GetRandomInt(0, 5);
					EmitSoundToAll(g_WitchSounds[rnd], bot);
				}
				else
				{
					new rnd = GetRandomInt(0, 26);
					EmitSoundToAll(g_ZombieSounds[rnd], bot);
				}
			}
		}
	}
	else
	{
		new rnd = GetRandomInt(0, 26);
		EmitSoundToAll(g_ZombieSounds[rnd], bot);
	}
}

public Action:NormalSoundHook(clients[64], &client_count, String:sample[PLATFORM_MAX_PATH], &entity, &channel, &Float:volume, &level, &pitch, &flags)
{
	if(strcmp(FIRE_SMALL_LOOP2, sample, false) == 0)
		return Plugin_Stop;

	return Plugin_Continue;
}

public Action:AllowMakeNoise(Handle:timer, any:client)
{
	g_bCanMakeNoise[client] = true;
	return Plugin_Handled;
}
