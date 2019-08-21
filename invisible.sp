/**
 * =============================================================================
 * SourceMod Left4DoD for Day of Defeat Source
 * (C)2009 - 2010 Dog - www.thevilluns.org
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
 
Disappear(any:client)
{
	if (g_ZombieType[client] == INFECTEDONE)
	{
		CreateTimer(0.1, HidePlayer, client, TIMER_FLAG_NO_MAPCHANGE);
		
		g_ShowSprite[client] = false;
		g_canVanish[client] = false;
		g_Invisible[client] = true;
		g_canAppear[client] = false;
		
		PlaySound(client, false);
		
		CreateTimer(0.1, BlockWeapon, client, TIMER_FLAG_NO_MAPCHANGE);
		CreateTimer(2.0, CanAppear, client, TIMER_FLAG_NO_MAPCHANGE);
		CreateTimer(10.0, RestoreVisibility, client, TIMER_FLAG_NO_MAPCHANGE);
	}
}

public Action:CanAppear(Handle:timer, any:client)
{
	if (IsClientInGame(client) && IsPlayerAlive(client) && GetClientTeam(client) == AXIS && g_ZombieType[client] == INFECTEDONE && g_Invisible[client])
	{
		g_canAppear[client] = true;
	}
	
	return Plugin_Continue;
}

public Action:RestoreVisibility(Handle:timer, any:client)
{
	if (IsClientInGame(client) && IsPlayerAlive(client) && GetClientTeam(client) == AXIS && g_ZombieType[client] == INFECTEDONE && g_Invisible[client])
	{
		g_ShowSprite[client] = true;
		g_Invisible[client] = false;
		
		CreateTimer(0.1, ShowPlayer, client, TIMER_FLAG_NO_MAPCHANGE);
		
		AddParticle(client, "smokegrenade_jet", 2.0, 10.0);
		
		PlaySound(client, false);
		
		CreateTimer(2.0, BeginVisibilityHUD, client, TIMER_FLAG_NO_MAPCHANGE);
		CreateTimer(1.5, AllowWeapon, client, TIMER_FLAG_NO_MAPCHANGE);
	}
	
	return Plugin_Continue;
}

public SetAlpha(any:client, any:alpha)
{
	if (client > 0 && IsClientInGame(client) && IsPlayerAlive(client))
	{
		SetEntityRenderMode(client, RENDER_TRANSCOLOR);
		SetEntityRenderColor(client, 255, 255, 255, alpha);
		
		for (new i = 0; i < 5; i++)
		{
			new entity = GetPlayerWeaponSlot(client, i);
			if (entity != -1)
			{
				SetEntityRenderMode(entity, RENDER_TRANSCOLOR);
				SetEntityRenderColor(entity, 255, 255, 255, alpha);
			}
		} 
	}
}

public Action:BeginVisibilityHUD(Handle:timer, any:client)
{
	if (IsClientInGame(client) && IsPlayerAlive(client) && GetClientTeam(client) == 3 && g_ZombieType[client] == 3)
	{
		if (!IsFakeClient(client))
		{
			SetEntPropFloat(client, Prop_Send, "m_flProgressBarStartTime", GetGameTime());
			SetEntProp(client, Prop_Send, "m_iProgressBarDuration", 10);
		}
		
		CreateTimer(10.0, CloseVisibilityHUD, client, TIMER_FLAG_NO_MAPCHANGE);
	}
	
	return Plugin_Continue;
}

public Action:CloseVisibilityHUD(Handle:timer, any:client)
{
	if (IsClientInGame(client) && !IsFakeClient(client) && GetClientTeam(client) == 3 && g_ZombieType[client] == 3)
	{
		SetEntPropFloat(client, Prop_Send, "m_flProgressBarStartTime", GetGameTime());
		SetEntProp(client, Prop_Send, "m_iProgressBarDuration", 0);
		EmitSoundToClient(client, "buttons/blip1.wav");
	}
	
	g_canVanish[client] = true;
	g_minAlpha[client] = 0;
		
	return Plugin_Handled;
}