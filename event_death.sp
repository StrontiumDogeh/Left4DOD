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

public Action:PlayerDeathEvent(Handle:event, const String:name[], bool:dontBroadcast)   
{
	if (GetConVarInt(hL4DOn))
	{
		new client = GetClientOfUserId(GetEventInt(event, "userid"));
		new attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
		
		new String:weapon_used[64];
		GetEventString(event, "weapon", weapon_used, sizeof(weapon_used));
		
		RemoveSprite(client);
		RemoveMines(client);
		
		SetEntityGravity(client, 1.0);
		
		if (g_Parachute[client] > 0)
			RemoveParachute(g_Parachute[client], client);
						
		//Feuersturms Anti Domination thing
		new domination = GetEventBool(event, "dominated");
		new revenge = GetEventBool(event, "revenge");
		if(domination)
		{
			SetEventBool(event, "dominated", false);
			SetEntData(client, FindSendPropInfo("CDODPlayer", "m_bPlayerDominatingMe") + attacker, 0, 1, true);
			SetEntData(attacker, FindSendPropInfo("CDODPlayer", "m_bPlayerDominated") + client, 0, 1, true);
			return Plugin_Continue;
		}
		if(revenge)
		{
			SetEventBool(event, "revenge", false);
			return Plugin_Continue;
		}
				
		g_airstrike[client] = false;
		g_Shield[client] = false;
		
		g_hasSprings[client] = false;
		
		g_AllowedMG[client] = false;
		g_AllowedRocket[client] = false;
		g_AllowedSniper[client] = false;
		
		g_switchSpec[client] = false;
		g_iBotsStuck[client] = 0;
						
		g_canTP[client] = true;
		
		hSkullData[client] = INVALID_HANDLE;
									
		//Zombie died
		if(GetClientTeam(client) == AXIS)
		{		
			g_HealthAdded[client] = (g_AlliedWins - g_AxisWins) * 1;
			
			//Display reasons for dying
			if (StrEqual(weapon_used, "shield"))
			{							
				if (g_Hints[client])
				{
					PrintHelp(client,"You were killed by a Shield", 3);
					PrintHelp(client,"*You were killed by a Shield", 0);
					PrintHelp(client,"*Weapon: The Shield is a green Allied force field that kills most Zombies", 0);
				}
			}
			else if (StrEqual(weapon_used, "env_fire"))
			{							
				if (g_Hints[client])
				{
					PrintHelp(client,"You were killed by a Molotov", 3);
					PrintHelp(client,"*You were killed by a Molotov", 0);
					PrintHelp(client,"*Weapon: The Molotov is fire that kills most Zombies", 0);
				}
			}
			
			//Create the drop - explosions destroy drop
			if (StrEqual(weapon_used, "molotov") || StrEqual(weapon_used, "env_fire") || StrEqual(weapon_used, "flamethrower") 
				|| StrEqual(weapon_used, "env_explosion") || StrEqual(weapon_used, "shield") 
				|| StrEqual(weapon_used, "panzerschreck") || StrEqual(weapon_used, "bazooka")
				|| StrEqual(weapon_used, "frag_us") || StrEqual(weapon_used, "frag_ger")
				|| StrEqual(weapon_used, "riflegren_us") || StrEqual(weapon_used, "riflegren_ger"))
			{
				RemoveRagdoll(client);
			}
			else
			{
				CreateDrops(client);
			}				
							
			g_ShowSprite[client] = false;
						
			if (!IsFakeClient(client))
				CreateTimer(0.01, DeathOverlay, client, TIMER_FLAG_NO_MAPCHANGE);
			
			//Reset waypoints back to spawn
			g_WayPoint[client] = 1;
						
			if (attacker > 0 && attacker != client)
			{
				if (IsClientInGame(client) && GetClientTeam(attacker) == ALLIES)
				{
					// If player has accidental TW count, subtract 1 for the kill
					if (g_twAmount[attacker] > 0)
					{
						g_twAmount[attacker]--;
					}
					
					if (g_ZombieType[client] == GREYDUDE)
					{
						if (IsFakeClient(client))
							LogToGame("\"%L\" triggered \"KillTheAITank\"", attacker);
						else
							LogToGame("\"%L\" triggered \"KillTheTank\"", attacker);
							
						g_ScoreGreyDude[attacker]++;
					}
					
					else if (g_ZombieType[client] == EMO)
					{
						if (IsFakeClient(client))
							LogToGame("\"%L\" triggered \"KillTheAIEmo\"", attacker);
						else
							LogToGame("\"%L\" triggered \"KillTheEmo\"", attacker);
							
						g_ScoreEmo[attacker]++;
					}
					
					else if (g_ZombieType[client] == GASMAN)
					{				
						if (IsFakeClient(client))
							LogToGame("\"%L\" triggered \"KillTheAIGasMan\"", attacker);
						else
							LogToGame("\"%L\" triggered \"KillTheGasMan\"", attacker);
							
						g_ScoreGasMan[attacker]++;
					}
					
					else if (g_ZombieType[client] == INFECTEDONE)
					{
						if (IsFakeClient(client))
							LogToGame("\"%L\" triggered \"KillTheAITraitor\"", attacker);
						else
							LogToGame("\"%L\" triggered \"KillTheTraitor\"", attacker);
							
						g_ScoreTraitor[attacker]++;
					}
					
					else if (g_ZombieType[client] == WITCH)
					{
						if (IsFakeClient(client))
							LogToGame("\"%L\" triggered \"KillTheAIWitch\"", attacker);
						else
							LogToGame("\"%L\" triggered \"KillTheWitch\"", attacker);
							
						g_ScoreWitch[attacker]++;
					}
					
					else if (g_ZombieType[client] == ANARCHIST)
					{
						if (IsFakeClient(client))
							LogToGame("\"%L\" triggered \"KillTheAIFlame\"", attacker);
						else
							LogToGame("\"%L\" triggered \"KillTheFlame\"", attacker);
							
						g_ScoreAnarchist[attacker]++;
					}
					else if (g_ZombieType[client] == UNG)
					{
						if (IsFakeClient(client))
							LogToGame("\"%L\" triggered \"KillTheAIUNG\"", attacker);
						else
							LogToGame("\"%L\" triggered \"KillTheUNG\"", attacker);
							
						g_ScoreUNG[attacker]++;
					}
					else if (g_ZombieType[client] == WRAITH)
					{
						if (IsFakeClient(client))
							LogToGame("\"%L\" triggered \"KillTheAIWraith\"", attacker);
						else
							LogToGame("\"%L\" triggered \"KillTheWraith\"", attacker);
							
						g_ScoreWraith[attacker]++;
					}
					else if (g_ZombieType[client] == SKELETON)
					{
						if (IsFakeClient(client))
							LogToGame("\"%L\" triggered \"KillTheAISkeleton\"", attacker);
						else
							LogToGame("\"%L\" triggered \"KillTheSkeleton\"", attacker);
							
						g_ScoreSkeleton[attacker]++;
					}
					else if (g_ZombieType[client] == HELLSPAWN)
					{
						if (IsFakeClient(client))
							LogToGame("\"%L\" triggered \"KillTheAIHellSpawn\"", attacker);
						else
							LogToGame("\"%L\" triggered \"KillTheHellSpawn\"", attacker);
							
						g_ScoreHellSpawn[attacker]++;
					}
					else
					{
						LogToGame("\"%L\" triggered \"KillZombie\"", attacker);
						g_ScoreZombies[attacker]++;
					}
				}
			}
			
			//Play Zombie Death sound
			if (g_ZombieType[client] != 0)
			{
				new rnd = GetRandomInt(0, 7);
				if (rnd <= 2)
					EmitSoundToAll(g_ZombieDeathSounds[rnd], client);
			}
			else
			{
				new rnd = GetRandomInt(0, 8);
				if (rnd <= 4)
					EmitSoundToAll(g_WitchSounds[rnd], client);
			}
			
			//Remove any fires
			g_OnFire[client] = false;
			if (g_FireParticle[client] != 0)
			{
				CreateTimer(0.1, DeleteParticle, g_FireParticle[client], TIMER_FLAG_NO_MAPCHANGE);
				g_FireParticle[client] = 0;
			}
			
			// Respawn the Zombie
			if (!IsFakeClient(client))
			{
				CreateTimer(2.5, TimerRespawnPlayer, client, TIMER_FLAG_NO_MAPCHANGE);
			}
			else
				CreateTimer(1.8, TimerRespawnPlayer, client, TIMER_FLAG_NO_MAPCHANGE);
							
			//Reset the Zombie type
			g_ZombieType[client] = -1;
		}
		
		// Allied player died
		else if (IsClientInGame(client) && GetClientTeam(client) == ALLIES)
		{		
			//Ticket system
			if (attacker > 0 && IsClientInGame(attacker) && GetClientTeam(attacker) == AXIS)
				g_NumberAlliedTickets--;
				
			if (g_NumberAlliedTickets <= 0)
			{
				SetWinningTeam(AXIS);
				g_bRoundOver = true;
				g_inProgress = false;
			}
			else
			{	
				new iMaxTickets = GetConVarInt(hL4DTickets);
				
				for (new i=1; i <= MaxClients; i++)
				{
					if (IsClientInGame(i) && !IsFakeClient(i))
					{
						if (GetClientTeam(i) == ALLIES)
						{
							if (g_NumberAlliedTickets > RoundToCeil(iMaxTickets * 0.5))
								CPrintToChat(i, "{lime} Tickets %i/%i", g_NumberAlliedTickets, iMaxTickets);
							else if (g_NumberAlliedTickets > RoundToCeil(iMaxTickets * 0.2) && g_NumberAlliedTickets < RoundToCeil(iMaxTickets * 0.51))
								CPrintToChat(i, "{orange} Tickets %i/%i", g_NumberAlliedTickets, iMaxTickets);
							else if (g_NumberAlliedTickets > RoundToCeil(iMaxTickets * 0.05) && g_NumberAlliedTickets < RoundToCeil(iMaxTickets * 0.21))
								CPrintToChat(i, "{red} Tickets %i/%i", g_NumberAlliedTickets, iMaxTickets);
							else if (g_NumberAlliedTickets <= RoundToCeil(iMaxTickets * 0.05))
								CPrintToChat(i, "{darkred} Tickets %i/%i", g_NumberAlliedTickets, iMaxTickets);
						}
					}
				}
			}
			
			CreateTimer(0.01, DeathOverlay, client, TIMER_FLAG_NO_MAPCHANGE);	
			
			CreateTimer(5.0, RandomHelp, client, TIMER_FLAG_NO_MAPCHANGE);
			
			if (GetConVarInt(hL4DDrops))
			{
				new random = GetRandomInt(0,100);
				if (random < 99)
					CreateTimer(1.0, SpawnAmmoBox, client, TIMER_FLAG_NO_MAPCHANGE);
				else
				{
					if (g_airstrike[client])
					{
						CreateTimer(1.0, SpawnRadio, client, TIMER_FLAG_NO_MAPCHANGE);
					}
					else if (g_Shield[client])
					{
						CreateTimer(1.0, SpawnShield, client, TIMER_FLAG_NO_MAPCHANGE);
					}
					else
					{
						CreateTimer(1.0, SpawnHealthBox, client, TIMER_FLAG_NO_MAPCHANGE);
					}
				}
				
				if (g_numDroppedHealth[client] > 1)
				{
					CreateTimer(1.0, SpawnHealthBox, client, TIMER_FLAG_NO_MAPCHANGE);
					g_numDroppedHealth[client] = 0;
				}
			}
			
			g_bPlayerDead[client] = true;
									
			if (attacker > 0 && attacker < MaxClients+1 && attacker != client && IsClientInGame(attacker))
			{		
				if (GetClientTeam(attacker) == AXIS)
				{						
					EmitSoundToClient(attacker, "npc/fast_zombie/idle1.wav");
					
					// Killer was a Zombie
					if (IsFakeClient(attacker))
					{
						//If human killed by bot zombie, remove a kill
						LogToGame("\"%L\" triggered \"KilledbyBot\"", client);
						
						//Prevents the bot TP away when it makes a kill
						g_canTP[attacker] = false;
						CreateTimer(5.0, AllowBotTeleport, attacker, TIMER_FLAG_NO_MAPCHANGE);
						
						//g_wasTP contains the clientID of the player playing GreyDude
						if (g_wasTP[attacker] > 0 && IsClientInGame(g_wasTP[attacker]))
						{
							LogToGame("\"%L\" triggered \"KillHumanGreyDude\"", g_wasTP[attacker]);
							
							SetEntProp(g_wasTP[attacker], Prop_Data, "m_iFrags", GetClientFrags(g_wasTP[attacker]) + 1);
							
							if (g_Hints[client])
							{
								PrintHelp(client,"You were killed by the Grey Dude", 3);
								PrintHelp(client,"*You were killed by the Grey Dude", 0);
								PrintHelp(client,"*The Grey Dude spawned Zombies near you", 0);
								
								PrintToChat(g_wasTP[attacker],"*One of your minions killed %N", client);
							}
						}
						
						if (g_ZombieType[attacker] == 4 && StrEqual(weapon_used, "env_explosion"))
						{							
							if (g_Hints[client])
							{
								PrintHelp(client,"You were killed by the Emo", 3);
								PrintHelp(client,"*You were killed by the Emo", 0);
								PrintHelp(client,"*Emo Weapon: Suicide bomb", 0);
							}
							
							SetEntProp(attacker, Prop_Data, "m_iFrags", GetClientFrags(attacker) + 1);
							
							RemoveRagdoll(client);
						}
							
						else if (g_ZombieType[attacker] == 5 && StrEqual(weapon_used, "prop_physics"))
						{							
							if (g_Hints[client])
							{
								PrintHelp(client,"You were killed by the Anarchist", 3);
								PrintHelp(client,"*You were killed by the Anarchist", 0);
								PrintHelp(client,"*Anarchist Weapon: Exploding skull", 0);
							}
						}
						
						else if (g_ZombieType[attacker] == 7 && StrEqual(weapon_used, "suck"))
						{							
							if (g_Hints[client])
							{
								PrintHelp(client,"You were killed by the Wraith", 3);
								PrintHelp(client,"*You were killed by the Wraith", 0);
								PrintHelp(client,"*Wraith Weapon: Sucks your health away", 0);
							}
						}
						
						else if (g_ZombieType[attacker] == SKELETON)
						{
							if (g_Hints[client])
							{
								PrintHelp(client,"You were killed by the Skeleton", 3);
								PrintHelp(client,"*You were killed by the Skeleton", 0);
							}
						}
						
						g_wasTP[attacker] = 0;
					}
								
					else if (!IsFakeClient(attacker))
					{
						//Scoring for Zombie humans
						g_ScoreHumans[attacker]++;
						
						SetEntProp(attacker, Prop_Data, "m_iFrags", GetClientFrags(attacker) + 1);
						
						if (g_ZombieType[attacker] == 4 && StrEqual(weapon_used, "env_explosion"))
						{
							LogToGame("\"%L\" triggered \"KillHumanBomb\"", attacker);
							
							if (g_Hints[client])
							{
								PrintHelp(client,"You were killed by the Emo", 3);
								PrintHelp(client,"*You were killed by the Emo", 0);
								PrintHelp(client,"*Emo Weapon: Suicide bomb", 0);
							}
							
							SetEntProp(attacker, Prop_Data, "m_iFrags", GetClientFrags(attacker) + 1);
							
							RemoveRagdoll(client);
						}
							
						else if (g_ZombieType[attacker] == 5 && StrEqual(weapon_used, "prop_physics"))
						{
							LogToGame("\"%L\" triggered \"KillHumanSkull\"", attacker);
							
							if (g_Hints[client])
							{
								PrintHelp(client,"You were killed by the Anarchist", 3);
								PrintHelp(client,"*You were killed by the Anarchist", 0);
								PrintHelp(client,"*Anarchist Weapon: Exploding skull", 0);
							}
						}
						
						else if (g_ZombieType[attacker] == 2 && StrEqual(weapon_used, "gasbomb"))
						{
							LogToGame("\"%L\" triggered \"KillHumanGas\"", attacker);
							
							if (g_Hints[client])
							{
								PrintHelp(client,"You were killed by the Gas Man", 3);
								PrintHelp(client,"*You were killed by the Gas Man", 0);
								PrintHelp(client,"*Gas Man Weapon: Gas", 0);
							}
						}
							
						else if (g_ZombieType[attacker] == 3 && StrEqual(weapon_used, "amerknife"))
							LogToGame("\"%L\" triggered \"KillHumanInfected\"", attacker);
							
						else if (g_ZombieType[attacker] == SKELETON)
						{
							LogToGame("\"%L\" triggered \"KillHumanSkeleton\"", attacker);
							
							if (g_Hints[client])
							{
								PrintHelp(client,"You were killed by the Skeleton", 3);
								PrintHelp(client,"*You were killed by the Skeleton", 0);
								PrintHelp(client,"*Skeletons can only be killed by melee", 0);
							}
						}
						
						else if (g_ZombieType[attacker] == UNG)
							LogToGame("\"%L\" triggered \"KillHumanUNG\"", attacker);
						
						else if (g_ZombieType[attacker] == 7 && StrEqual(weapon_used, "suck"))
						{			
							LogToGame("\"%L\" triggered \"KillHumanWraithSuck\"", attacker);
							if (g_Hints[client])
							{
								PrintHelp(client,"You were killed by the Wraith", 3);
								PrintHelp(client,"*You were killed by the Wraith", 0);
								PrintHelp(client,"*Wraith Weapon: Sucks your health away", 0);
							}
						}
														
						else
							LogToGame("\"%L\" triggered \"KillHuman\"", attacker);

					}
				}
			}
			else if (attacker == client)
			{
				new maxent = GetMaxEntities(), String:weaponname[64];
				for (new i = MaxClients; i < maxent; i++)
				{
					if (IsValidEdict(i) && IsValidEntity(i))
					{
						GetEdictClassname(i, weaponname, sizeof(weaponname));
						if (StrContains(weaponname, "weapon_") != -1 && GetEntDataEnt2(i, g_oWeaponParent) == -1 )
							AcceptEntityInput(i, "Kill");
					}
				}
			}
			
			//Allow bots to retarget
			for (new i = 1; i <= MaxClients; i++)
			{
				if (client == g_iBotsTarget[i])
				{
					g_iBotsTarget[i] = 0;
					GetNearestWaypoint(i);
				}
			}
		}
				
		g_OnFire[client] = false;
	}
	return Plugin_Continue;
}
