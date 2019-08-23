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

public Action:HurtEvent(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (GetConVarInt(hL4DOn))
	{
		new client = GetClientOfUserId(GetEventInt(event, "userid"));
		new attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
		new damage = GetEventInt(event, "damage");
				
		if (GetClientHealth(client) <= 0)
		{
			new iPrimaryWeapon = GetPlayerWeaponSlot(client, 0);

			if (iPrimaryWeapon != -1)
			{	
				#if DEBUG
					LogToFileEx(g_szLogFileName,"[L4DOD] Removed weapon from map");
				#endif
				
				AcceptEntityInput(iPrimaryWeapon, "Kill");
			}
		}
		
		//If hurt event make sure the client is a bot and not a headshot
		if (GetClientTeam(client) == AXIS)
		{
			AddParticle(client, "blood_impact_green_01_droplets", 4.0, 50.0);
			AddParticle(client, "blood_impact_green_02_glow", 4.0, 40.0);
			AddParticle(client, "blood_impact_green_02_chunk", 4.0, 30.0);
			AddParticle(client, "blood_zombie_split_spray", 2.0, 40.0);		
						
			//Play Zombie Pain sound
			if (g_ZombieType[client] != 0)
			{
				new rnd = GetRandomInt(0, 15);
				if (rnd <= 5)
					EmitSoundToAll(g_ZombiePainSounds[rnd], client);
			}
			else
			{
				new rnd = GetRandomInt(0, 15);
				if (rnd <= 4)
					EmitSoundToAll(g_WitchSounds[rnd], client);
			}
			
			if (g_ZombieType[client] == GREYDUDE  
			    || g_ZombieType[client] == GASMAN	 || g_ZombieType[client] == ANARCHIST 
				|| g_ZombieType[client] == WRAITH  || g_ZombieType[client] == EMO)
			{
				SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", ZOMBIESPEED);
				
				if (!IsFakeClient(client))
					SetEntPropFloat(client, Prop_Send, "m_flStunDuration", 0.0);
			}
			else if (g_ZombieType[client] == INFECTEDONE || g_ZombieType[client] == HELLSPAWN)
			{
				SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", INFECTEDSPEED);
				
				if (!IsFakeClient(client))
					SetEntPropFloat(client, Prop_Send, "m_flStunDuration", 0.0);
					
				if (g_Invisible[client])
				{
					g_minAlpha[client] +=20;
					if (g_minAlpha[client] >= 255)
						g_minAlpha[client] = 255;
						
					SetAlpha(client, g_minAlpha[client]);
				}
			}
			else if (g_ZombieType[client] == UNG)
			{
				SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", UNGSPEED);
				
				if (!IsFakeClient(client))
					SetEntPropFloat(client, Prop_Send, "m_flStunDuration", 0.0);
			}
			else if (g_ZombieType[client] == SKELETON)
			{
				SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", SKELETONSPEED);
				
				if (!IsFakeClient(client))
					SetEntPropFloat(client, Prop_Send, "m_flStunDuration", 0.0);
			}
			else if (g_ZombieType[client] == WITCH)
			{
				SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", WITCHSPEED);
				
				if (!IsFakeClient(client))
					SetEntPropFloat(client, Prop_Send, "m_flStunDuration", 0.0);
			}
			else
			{
				if (g_Health[client] < g_HealthMax[client])
				{
					new Float:speed = g_Health[client] / g_HealthMax[client] * 0.4;
					if (speed > 0.4)
						speed = 0.4;
					SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 0.6 + speed);
				}
			}
				
			//If the bot was hurt by a player, then use that to hunt player
			if (attacker > 0 && client > 0 
				&& !g_isIgnored[attacker] && IsFakeClient(client) 
				&& GetClientTeam(attacker) != GetClientTeam(client) && g_ZombieType[client] != UNG && g_ZombieType[client] != EMO)
			{	
				g_iBotsTarget[client] = attacker;
			}
		}

		else if (GetClientTeam(client) == ALLIES)
		{
			
			if (client > 0 && IsClientInGame(client))
			{				
				AddParticle(client, "blood_impact_red_01", 2.0, 50.0);
				AddParticle(client, "blood_impact_red_01_mist", 3.0, 60.0);
				
				if (g_ZombieType[attacker] == WRAITH)
				{
					//Fill up regular health first
					if (IsClientInGame(attacker))
					{
						new attacker_health = g_Health[attacker];
						attacker_health += damage;
						
						if (attacker_health > WRAITH_HEALTH)
							attacker_health = WRAITH_HEALTH;
							
						g_Health[attacker] = attacker_health;
						SetHealth(attacker, attacker_health);
					}
					
				}
					
				if ((g_Health[client] < 50) && !g_isIgnored[client] && GetClientTeam(client) == ALLIES)
				{
					HurtOverlay(client);
					CreateTimer(5.0, RemoveOverlay, client, TIMER_FLAG_NO_MAPCHANGE);
				}
			}
		}
	}
	return Plugin_Continue;
}
