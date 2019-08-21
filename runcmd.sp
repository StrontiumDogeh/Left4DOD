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

// Used to process commands
public Action:OnPlayerRunCmd(client, &buttons, &impulse, Float:vel[3], Float:angles[3], &weapon) 
{		
	if (IsClientInGame(client) && !IsFakeClient(client) && IsPlayerAlive(client) && GetClientTeam(client) == AXIS && g_CanRightClick[client])
	{						
		//Check for double jump
		DoubleJump(client);
		
		//Block Witch Sprint
		//if ((g_ZombieType[client] == WITCH) && !g_inLimbo[client])
			//buttons &= ~(IN_SPEED); 
								
		if ((buttons & IN_ATTACK2) == IN_ATTACK2 && g_inProgress)
		{			
			if ((g_ZombieType[client] == WITCH)  && g_canTP[client] )
			{
				Teleport(client);
				g_canTP[client] = false;
			}
			else if (g_ZombieType[client] == GREYDUDE && g_canMaster[client])
			{
				SpawnZombies(client);
				g_canMaster[client] = false;
			}
			else if (g_ZombieType[client] == GASMAN && g_bCanGasBomb[client])
			{
				GasBomb(client);	
				g_bCanGasBomb[client] = false;
			}
			else if (g_ZombieType[client] == INFECTEDONE && g_canVanish[client])
			{
				AddParticle(client, "smokegrenade_jet", 3.0, 10.0);
				
				Disappear(client);
				g_canVanish[client] = false;
			}
			else if (g_ZombieType[client] == INFECTEDONE && g_canAppear[client])
			{
				AddParticle(client, "smokegrenade_jet", 3.0, 10.0);
				
				CreateTimer(0.1, RestoreVisibility, client, TIMER_FLAG_NO_MAPCHANGE);
				g_canAppear[client] = false;
			}
			else if (g_ZombieType[client] == EMO && g_canDet[client])
			{
				AttachParticle(client, "smokegrenade", 1.0);
				
				Detonate(client);
				g_canDet[client] = false;
			}		
			else if (g_ZombieType[client] == ANARCHIST && g_canSkull[client])
			{
				FireSkulls(client);	
				g_canSkull[client] = false;
			}
			else if (g_ZombieType[client] == HELLSPAWN && g_canFireball[client])
			{
				FireBalls(client);	
				g_canFireball[client] = false;
			}
			else if (g_ZombieType[client] == SKELETON )
			{
				DetonateMines(client);
			}
			else if (g_ZombieType[client] == WRAITH && g_canSuck[client] && (GetEntityFlags(client) & FL_ONGROUND))
			{
				new target = GetClientAimTarget(client, true);
				if ( target > 0 && GetClientTeam(target) == ALLIES )
				{
					new Float:vecWraithLoc[3], Float:vecTargetLoc[3], Float:vecWraithEyes[3], Float:vecTargetEyes[3];					
					GetClientAbsOrigin(target, vecTargetLoc);
					GetClientAbsOrigin(client, vecWraithLoc);
					
					GetClientEyePosition(client, vecWraithEyes);
					GetClientEyePosition(target, vecTargetEyes);
					
					new Float:distancecheck;
					distancecheck = GetVectorDistance(vecWraithLoc, vecTargetLoc);
					
					if (distancecheck < 700.0)
					{
						if (IsPointVisible(vecWraithEyes, vecTargetEyes))
						{
							//damage between 2 and 11
							new Float:dmg = ((801.0 - distancecheck) / 700.0 * SUCK);
							Suck(client, target, RoundToCeil(dmg));
							
							vecWraithLoc[2] += 30.0;
							vecTargetLoc[2] += 30.0;
														
							/* stock TE_SetupBeamPoints(const Float:start[3], const Float:end[3], ModelIndex, HaloIndex, StartFrame, FrameRate, Float:Life,    
															 Float:Width, Float:EndWidth, FadeLength, Float:Amplitude, const Color[4], Speed) */
							TE_SetupBeamPoints(vecTargetLoc, vecWraithLoc, BallSprite, HaloSprite, 0, 10, 0.5, 
															20.0, 10.0, 0, 15.0, g_AxisColour, 30);
							TE_SendToAll();
						}
					}
				}
			
				else
				{
					if ( target > 0 && GetClientTeam(target) == AXIS && g_Health[client] >= 80)
					{
						new Float:vecWraithLoc[3], Float:vecTargetLoc[3], Float:vecWraithEyes[3], Float:vecTargetEyes[3];					
						GetClientAbsOrigin(target, vecTargetLoc);
						GetClientAbsOrigin(client, vecWraithLoc);
						
						GetClientEyePosition(client, vecWraithEyes);
						GetClientEyePosition(target, vecTargetEyes);
						
						new Float:distancecheck;
						distancecheck = GetVectorDistance(vecWraithLoc, vecTargetLoc);
						
						if (distancecheck < 800.0)
						{
							if (IsPointVisible(vecWraithEyes, vecTargetEyes))
							{
								//damage between 2 and 11
								new Float:heal = ((801.0 - distancecheck) / 500.0 * HEAL);
								
								Heal(client, target, RoundToCeil(heal));
								
								vecWraithLoc[2] += 30.0;
								vecTargetLoc[2] += 30.0;
															
								/* stock TE_SetupBeamPoints(const Float:start[3], const Float:end[3], ModelIndex, HaloIndex, StartFrame, FrameRate, Float:Life,    
																 Float:Width, Float:EndWidth, FadeLength, Float:Amplitude, const Color[4], Speed) */
								TE_SetupBeamPoints(vecTargetLoc, vecWraithLoc, BallSprite, HaloSprite, 0, 10, 0.5, 
																20.0, 10.0, 0, 15.0, g_AxisColourFeed, 30);
								TE_SendToAll();
							}
						}
					}
				}
			}
		}
		
		//Block Attack
		if (!g_canUseWeapon[client])
			buttons &= ~(IN_ATTACK); 
			
		if ((buttons & IN_USE) == IN_USE)
		{	
			if (g_canSmoke[client] && !g_bRoundOver)
			{
				Smoke(client);
			}
		}
					
	}
	
	//ALL BOTS
	else if (g_bRoundActive && IsClientInGame(client) && IsFakeClient(client) && IsPlayerAlive(client))
	{										
		new Float:vecResult[3], Float:vecAngle[3], Float:vecTargetEyes[3], Float:vecTargetPosition[3], Float:vecBotEyes[3], Float:vecBotPosition[3];
			
		GetClientAbsOrigin(client, vecBotPosition);
		
		if (client > 0 && g_iBotsTarget[client] == 0)
		{
			buttons &= ~(IN_ATTACK);
								
			if (!g_bIsWaiting[client])
			{
				CheckWayPoints(client);
				//Turn the bot to nearest waypoint
				MakeVectorFromPoints(vecBotPosition, g_vecWayPoint[client][g_WayPoint[client]], vecResult);
				GetVectorAngles(vecResult, vecAngle);
				
				new Float:vecVel[3];
				GetAngleVectors(vecAngle, vecVel, NULL_VECTOR, NULL_VECTOR);
				
				if (g_ZombieType[client] != UNG)
					ScaleVector(vecVel, MOVE_FORWARD);
				else
					ScaleVector(vecVel, UNG_FORWARD);
					
				vecVel[2] = GRAVITY;
				
				TeleportEntity(client, NULL_VECTOR, vecAngle, vecVel);
				
				//Set the angles on PlayerRunCmd
				angles[0] = vecAngle[0];
				angles[1] = vecAngle[1];
				angles[2] = vecAngle[2];
								
				vel[0] = vecVel[0];
				vel[1] = vecVel[1];
				vel[2] = vecVel[2];
			
				//Are we there yet?
				if (GetVectorDistance(vecBotPosition, g_vecWayPoint[client][g_WayPoint[client]]) < WAYPOINTREACHED)
				{
					g_WayPoint[client] += g_iBotsDirection[client];
						
					g_WayPointCheck[client] = 0;
									
					//At the end of waypoints so make way back to previous waypoints
					CheckWayPoints(client);		

					g_iBotsStuck[client] = 0;
				}
				else
				{	
					if (GetVectorDistance(g_vecLastPosition[client], vecBotPosition) < 2.0)
					{
						g_iBotsStuck[client]++;
						
						if (g_iBotsStuck[client] == 20 || g_iBotsStuck[client] == 80 || g_iBotsStuck[client] == 120)
						{
							//Try a jump
							new Float:height = DistanceToSky(client);
							if (height > 50.0)
							{
								decl Float:vVel[3];
								GetEntPropVector(client, Prop_Data, "m_vecVelocity", vVel);
								vel[2] = vVel[2];
								
								decl Float:clientEyeAngles[3];
								GetClientEyeAngles(client, clientEyeAngles);
								
								decl Float:forwardVector[3];
								GetAngleVectors(clientEyeAngles, forwardVector, NULL_VECTOR, NULL_VECTOR);
								NormalizeVector(forwardVector, forwardVector);
								ScaleVector(forwardVector, 100.0);
								
								vVel[0] += forwardVector[0];
								vVel[1] += forwardVector[1];
								
								if (vVel[2] <= 0.0)
									vVel[2] = 4000.0;
								else
									vVel[2] += 450.0;
								
								TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, vVel);		// boost player

								buttons |= (IN_JUMP);
								SetEntProp(client, Prop_Data, "m_nButtons", buttons);
							}
						}
						else if (g_iBotsStuck[client] == 450)
						{
							if (g_WayPoint[client] < 7)
							{
								AddParticle(client, "smokegrenade_jet", 3.0, 10.0);
								TeleportEntity(client, g_vecWayPoint[client][7], NULL_VECTOR, NULL_VECTOR);
								g_WayPoint[client] = 8;
								g_iBotsStuck[client] = 0;
							}	
							else
							{
								if (g_iBotsDirection[client] == 1)
									g_iBotsDirection[client] = -1;
								else
									g_iBotsDirection[client] = 1;
									
								g_WayPoint[client] += g_iBotsDirection[client];
							}
						}
						else if (g_iBotsStuck[client] > 600)
						{
							g_iBotsStuck[client] = 0;
							AddParticle(client, "smokegrenade_jet", 3.0, 10.0);
							CreateTimer(0.1, TimerRespawnPlayer, client, TIMER_FLAG_NO_MAPCHANGE);
						}
					}
				}			
			}
		}
		// BOT HAS A TARGET
		else
		{			
			if (g_iBotsTarget[client] > 0 && IsClientInGame(g_iBotsTarget[client]) && IsPlayerAlive(g_iBotsTarget[client]))
			{	
				if (g_isIgnored[g_iBotsTarget[client]])
				{
					g_iBotsTarget[client] = 0;
				}
				else if (g_isInfected[g_iBotsTarget[client]] && g_ZombieType[client] == INFECTEDONE)
				{
					g_iBotsTarget[client] = 0;
				}
				else
				{
					//If the bot is waiting, move them now they have a target
					if (g_bIsWaiting[client] && g_ZombieType[client] != GASMAN && g_ZombieType[client] != HELLSPAWN
					&& g_ZombieType[client] != GREYDUDE && g_ZombieType[client] != ANARCHIST && g_ZombieType[client] != WRAITH)
					{
						new randomNum = GetRandomInt(1, 100);
						
						//Some bots will stay while others move on
						if (randomNum > 20)
						{
							SetEntityMoveType(client, MOVETYPE_WALK);
							g_bIsWaiting[client] = false;
						}
					}
									
					//Can the target be seen?
					//If yes run to it, if not use WP
					
					GetClientEyePosition(g_iBotsTarget[client], vecTargetEyes);				
					GetClientEyePosition(client, vecBotEyes);
					
					GetClientAbsOrigin(g_iBotsTarget[client], vecTargetPosition);
					GetClientAbsOrigin(client, vecBotPosition);
					
					//Jump max height
					vecTargetPosition[2] += 50.0;
					vecBotPosition[2] += 50.0;
					
					vecTargetEyes[2] -= GetRandomFloat(0.0, 20.0);
					
					new Float:distancecheck;
					distancecheck = GetVectorDistance(vecBotEyes, vecTargetEyes);
					
//////////////////////Bot can see all of player so sprint full speed
					if ((IsPointVisible(vecTargetEyes, vecBotEyes) && IsPointVisible(vecTargetPosition, vecBotPosition)) 
						|| GetVectorDistance(vecBotEyes, vecTargetEyes) < 80.0)
					{					
						new Float:speed = 1.0;
												
						MakeVectorFromPoints(vecBotEyes, vecTargetEyes, vecResult);
						GetVectorAngles(vecResult, vecAngle);
						vecAngle[1] -= GetRandomFloat(0.0,5.0);
						
						new Float:vecVel[3];
						GetAngleVectors(vecAngle, vecVel, NULL_VECTOR, NULL_VECTOR);
						
						if (distancecheck >= 700.0)
						{
							if (g_ZombieType[client] != UNG)
								speed = MOVE_SEEK;
							else
								speed = UNG_FORWARD;
						}
						else if (distancecheck < 700.0 && distancecheck > MINIMUM_RUN_DISTANCE)
						{
							if (g_ZombieType[client] == UNG || g_ZombieType[client] == WRAITH)
								speed = UNG_FORWARD;
							else
								speed = MOVE_ATTACK;
						}
							
						ScaleVector(vecVel, speed);
						vecVel[2] = GRAVITY;
						
						vecVel[0] += g_vecBotVel[client][0];
						vecVel[1] += g_vecBotVel[client][1];
						vecVel[2] += g_vecBotVel[client][2];
						
						vel[0] = vecVel[0];
						vel[1] = vecVel[1];
						vel[2] = vecVel[2];
						
						if (!g_PauseMovement[client])
							TeleportEntity(client, NULL_VECTOR, vecAngle, vecVel);
						
						//Set the angles on PlayerRunCmd
						angles[0] = vecAngle[0];
						angles[1] = vecAngle[1];
						angles[2] = vecAngle[2];
																														
						if (distancecheck < MINIMUM_ATTACK_DISTANCE)
						{
							if (g_ZombieType[client] == INFECTEDONE)
							{
								if (g_Invisible[client] && !g_bRoundOver)
								{
									AddParticle(client, "smokegrenade_jet", 3.0, 10.0);
									CreateTimer(0.1, RestoreVisibility, client, TIMER_FLAG_NO_MAPCHANGE);
								}
								buttons |= IN_ATTACK;
							}
							else
							{
								buttons |= IN_ATTACK;
							}
							
							g_iBotsStuck[client] = 0;
						}
						else
						{
							buttons &= ~(IN_ATTACK);
						}
						
						if (distancecheck > 700.0 && distancecheck < 1300.0)
						{
							if (g_ZombieType[client] == EMO && IsFakeClient(client))
							{
								if (g_bCanMakeNoise[client])
								{
									EmitSoundToAll("npc/fast_zombie/fz_alert_far1.wav", client);
									g_bCanMakeNoise[client] = false;
									CreateTimer(3.0, AllowMakeNoise, client, TIMER_FLAG_NO_MAPCHANGE);
								}
							}
						}
						
						if (distancecheck < 900.0 && distancecheck > MINIMUM_ATTACK_DISTANCE)
						{
							if (g_ZombieType[client] == ANARCHIST && g_canSkull[client] && !g_bRoundOver)
							{					
								FireSkulls(client);
							}
							else if (g_ZombieType[client] == HELLSPAWN && g_canFireball[client] && !g_bRoundOver)
							{					
								FireBalls(client);
							}
							else if (g_ZombieType[client] == GASMAN && g_bCanGasBomb[client]  && !g_bRoundOver)
							{
								GasBomb(client);								
							}
							else if (g_ZombieType[client] == EMO && GetRandomInt(0, 9) <= 5 && IsFakeClient(client))
							{
								if (g_bCanMakeNoise[client])
								{
									EmitSoundToAll("npc/fast_zombie/fz_frenzy1.wav", client);
									g_bCanMakeNoise[client] = false;
									CreateTimer(3.0, AllowMakeNoise, client, TIMER_FLAG_NO_MAPCHANGE);
								}
							}
							else if (g_ZombieType[client] == INFECTEDONE && g_canVanish[client] && !g_bRoundOver)
							{
								AddParticle(client, "smokegrenade_jet", 3.0, 10.0);
								Disappear(client);
							}
							else if (g_ZombieType[client] == GREYDUDE && g_canMaster[client] && !g_bRoundOver)
							{					
								AddParticle(client, "smokegrenade_jet", 3.0, 10.0);
								SpawnZombies(client);
							}
						}
						
						if (distancecheck < 700.0 && distancecheck > (MINIMUM_ATTACK_DISTANCE + 50.0) && !g_bRoundOver)
						{
							if (g_ZombieType[client] == WRAITH)
							{
								//damage between 2 and 11
								new Float:dmg = ((801.0 - distancecheck) / 700.0 * SUCK);
								Suck(client, g_iBotsTarget[client], RoundToCeil(dmg));
								new Float:playerOrigin[3], Float:botOrigin[3];
								
								GetClientAbsOrigin(g_iBotsTarget[client],playerOrigin);
								GetClientAbsOrigin(client,botOrigin);
								
								playerOrigin[2] += 30.0;
								botOrigin[2] += 30.0;
								
								/* stock TE_SetupBeamPoints(const Float:start[3], const Float:end[3], ModelIndex, HaloIndex, StartFrame, FrameRate, Float:Life,    
																 Float:Width, Float:EndWidth, FadeLength, Float:Amplitude, const Color[4], Speed) */
								TE_SetupBeamPoints(botOrigin, playerOrigin, GunSmokeSprite, HaloSprite, 0, 0, 0.5, 
																20.0, 10.0, 0, 1.0, g_AxisColour, 3);
								TE_SendToAll();
							}
							else if (g_ZombieType[client] == WITCH && g_Allies > 6 && g_canTP[client])
							{
								Teleport(client);
								g_canTP[client] = false;
							}
						}
												
						if (distancecheck < 160.0 && g_ZombieType[client] == EMO && !g_bRoundOver)
						{				
							AttachParticle(client, "smokegrenade", 1.0);
							Detonate(client);
						}
						
						if (distancecheck < 200.0)
						{
							if (g_bCanMakeNoise[client])
							{
								PlaySound(client, false);
								g_bCanMakeNoise[client] = false;
								CreateTimer(3.0, AllowMakeNoise, client, TIMER_FLAG_NO_MAPCHANGE);
							}
						}
						
						//If the player is prone, hack him...
						if (distancecheck < 80.0 && g_iBotsTarget[client] > 0)
						{							
							//Slash the player
							if (GetEntProp(g_iBotsTarget[client], Prop_Send, "m_bProne") == 1)
							{
								new Handle:pack;			
								CreateDataTimer(0.1, DealDamage, pack, TIMER_FLAG_NO_MAPCHANGE);
								WritePackCell(pack, g_iBotsTarget[client]);
								WritePackCell(pack, client);
								WritePackCell(pack, 1);
								WritePackCell(pack, DMG_SLASH);

								if (g_ZombieType[client] != INFECTEDONE)
								{
									WritePackString(pack, "weapon_spade");
								}
								else
								{
									WritePackString(pack, "weapon_amerknife");
								}
							}
						}	
						
						//Bot is blocked while trying to get to target
						if (GetVectorDistance(g_vecLastPosition[client], vecBotPosition) < 2.0 && !g_bIsWaiting[client])
						{						
							g_iBotsStuck[client]++;
																				
							if ((g_iBotsStuck[client] == 20 || g_iBotsStuck[client] == 60 || g_iBotsStuck[client] == 100) && distancecheck > 80.0)
							{
								//Try a jump
								new Float:height = DistanceToSky(client);
								if (height > 50.0)
								{
									decl Float:vVel[3];
									GetEntPropVector(client, Prop_Data, "m_vecVelocity", vVel);
									vel[2] = vVel[2];
									
									decl Float:clientEyeAngles[3];
									GetClientEyeAngles(client, clientEyeAngles);
									
									decl Float:forwardVector[3];
									GetAngleVectors(clientEyeAngles, forwardVector, NULL_VECTOR, NULL_VECTOR);
									NormalizeVector(forwardVector, forwardVector);
									ScaleVector(forwardVector, 100.0);
									
									vVel[0] += forwardVector[0];
									vVel[1] += forwardVector[1];
									
									if (vVel[2] <= 0.0)
										vVel[2] = 4000.0;
									else
										vVel[2] += 450.0;
									
									if (!g_PauseMovement[client])
										TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, vVel);		// boost player
									
									buttons |= (IN_JUMP);
									SetEntProp(client, Prop_Data, "m_nButtons", buttons);
								}
							}
						}
					}
					
/////////////////////SI can be stuck
					else if (g_ZombieType[client] == WITCH || g_ZombieType[client] == GREYDUDE 
					|| g_ZombieType[client] == ANARCHIST || g_ZombieType[client] == GASMAN || g_ZombieType[client] == HELLSPAWN)
					{					
						new Float:vecNewAngle[3], Float:vecBotLocation[3];
												
						if (!IsPointVisible(vecTargetEyes, vecBotEyes))
						{					
							g_iBotsLostTarget[client]++;
						}

						if (distancecheck < 900.0 && distancecheck > MINIMUM_ATTACK_DISTANCE)
						{
							if (g_ZombieType[client] == ANARCHIST && g_canSkull[client] && !g_bRoundOver)
							{					
								FireSkulls(client);
							}
							else if (g_ZombieType[client] == HELLSPAWN && g_canFireball[client] && !g_bRoundOver)
							{					
								FireBalls(client);
							}
							else if (g_ZombieType[client] == GASMAN && g_bCanGasBomb[client]  && !g_bRoundOver)
							{
								GasBomb(client);		
							}
							else if ((g_ZombieType[client] == WITCH) && g_Allies > 6 && g_canTP[client])
							{
								RelocateBotBehindPlayer(client);
							}
							else if (g_ZombieType[client] == GREYDUDE && g_canMaster[client] && !g_bRoundOver)
							{					
								AddParticle(client, "smokegrenade_jet", 3.0, 10.0);
								SpawnZombies(client);
							}
						}
																		
						GetClientAbsOrigin(client, vecBotLocation);

						//Point the bot in the direction of the target
						MakeVectorFromPoints(vecBotEyes, vecTargetEyes, vecResult);
						GetVectorAngles(vecResult, vecAngle);
						vecAngle[1] -= GetRandomFloat(0.0,5.0);
						
						//Get the velocity to run and move them in the direction of a waypoint
						new Float:vecVel[3];
						MakeVectorFromPoints(vecBotLocation, g_vecWayPoint[client][g_WayPoint[client]], vecResult);
						GetVectorAngles(vecResult, vecNewAngle);
						GetAngleVectors(vecNewAngle, vecVel, NULL_VECTOR, NULL_VECTOR);
											
						if (g_ZombieType[client] != UNG)
							ScaleVector(vecVel, MOVE_SEEK);
						else
							ScaleVector(vecVel, UNG_FORWARD);
							
						vecVel[2] = GRAVITY;
						
						if (!g_PauseMovement[client])
							TeleportEntity(client, NULL_VECTOR, vecAngle, vecVel);
						
						vecVel[0] += g_vecBotVel[client][0];
						vecVel[1] += g_vecBotVel[client][1];
						vecVel[2] += g_vecBotVel[client][2];
						
						vel[0] = vecVel[0];
						vel[1] = vecVel[1];
						vel[2] = vecVel[2];
						
						//Set the angles on PlayerRunCmd
						angles[0] = vecAngle[0];
						angles[1] = vecAngle[1];
						angles[2] = vecAngle[2];
																		
						if (GetVectorDistance(vecBotLocation, g_vecWayPoint[client][g_WayPoint[client]]) < WAYPOINTREACHED)
						{
							g_WayPoint[client] += g_iBotsDirection[client];
								
							g_WayPointCheck[client] = 0;
											
							//At the end of waypoints so make way back to previous waypoints
							CheckWayPoints(client);		

							g_iBotsStuck[client] = 0;
						}		
												
						//Bot has totally lost target so reset and look for another
						if (g_iBotsLostTarget[client] > 300)
						{
							g_iBotsStuck[client] = 0;
							g_iBotsTarget[client] = 0;
							g_iBotsLostTarget[client] = 0;
							
							GetNearestWaypoint(client);
						}
					}
					
					//OTHER BOTS WHO CANNOT SEE THE WHOLE TARGET
					else
					{					
						new Float:vecNewAngle[3], Float:vecBotLocation[3];
						
						//Is there a nearer enemy? If so retarget and pass on this cycle
						new NewTarget = GetNearestEnemy(client);
						if (NewTarget != g_iBotsTarget[client])
						{
							g_iBotsTarget[client] = NewTarget;
							g_iBotsStuck[client] = 0;
							g_iBotsLostTarget[client] = 0;
						}
						//No other target so keep in view
						else
						{
							g_iBotsLostTarget[client]++;
							
							GetClientAbsOrigin(client, vecBotLocation);

							//Point the bot in the direction of the target
							MakeVectorFromPoints(vecBotEyes, vecTargetEyes, vecResult);
							GetVectorAngles(vecResult, vecAngle);
							vecAngle[1] -= GetRandomFloat(0.0,5.0);
							
							//Get the velocity to run
							new Float:vecVel[3];
							MakeVectorFromPoints(vecBotLocation, g_vecWayPoint[client][g_WayPoint[client]], vecResult);
							GetVectorAngles(vecResult, vecNewAngle);
							GetAngleVectors(vecNewAngle, vecVel, NULL_VECTOR, NULL_VECTOR);
																										
							ScaleVector(vecVel, MOVE_SEEK);
							vecVel[2] = GRAVITY;
							
							TeleportEntity(client, NULL_VECTOR, vecAngle, vecVel);
							
							vecVel[0] += g_vecBotVel[client][0];
							vecVel[1] += g_vecBotVel[client][1];
							vecVel[2] += g_vecBotVel[client][2];
							
							vel[0] = vecVel[0];
							vel[1] = vecVel[1];
							vel[2] = vecVel[2];
							
							//Set the angles on PlayerRunCmd
							angles[0] = vecAngle[0];
							angles[1] = vecAngle[1];
							angles[2] = vecAngle[2];
																			
							if (GetVectorDistance(vecBotLocation, g_vecWayPoint[client][g_WayPoint[client]]) < WAYPOINTREACHED)
							{
								g_WayPoint[client] += g_iBotsDirection[client];
									
								g_WayPointCheck[client] = 0;
												
								//At the end of waypoints so make way back to previous waypoints
								CheckWayPoints(client);		

								g_iBotsStuck[client] = 0;
							}		
													
							//Bot has totally lost target so reset and look for another
							if (g_iBotsLostTarget[client] > 300)
							{
								g_iBotsStuck[client] = 0;
								g_iBotsTarget[client] = 0;
								g_iBotsLostTarget[client] = 0;
								
								GetNearestWaypoint(client);
							}
						}
					}
				}
			}
			else
			{
				g_iBotsTarget[client] = GetNearestEnemy(client);
			}
		}
		
		g_vecLastPosition[client][0] = vecBotPosition[0];
		g_vecLastPosition[client][1] = vecBotPosition[1];
		g_vecLastPosition[client][2] = vecBotPosition[2];
		
	}
	
	else if (IsClientInGame(client) && !IsFakeClient(client) && IsPlayerAlive(client) && GetClientTeam(client) == ALLIES)
	{			
		//Check for double jump
		if (g_hasSprings[client])
		{
			DoubleJump(client);
		}
		
		if ((buttons & IN_USE) == IN_USE)
		{
			if (g_airstrike[client] && !g_bRoundOver)
			{
				AirStrike(client);
			}
				
			else if(g_Shield[client] && !g_bRoundOver)
			{
				Shield(client);
			}
						
			else
			{
				new weaponslot;
				weaponslot = GetPlayerWeaponSlot(client, 4);
				
				//Have TNT
				if(weaponslot != -1)
				{
					if (!g_plantedTNT[client]) 
					{
						g_primedTNT[client] = false;
						
						decl Float:start[3], Float:angle[3], Float:end[3], Float:normal[3], Float:pos[3], Float:buffer[3], Float:distance;
						distance = -3.0;
						GetClientEyePosition( client, start);
						GetClientEyeAngles( client, angle);
						GetAngleVectors(angle, end, NULL_VECTOR, NULL_VECTOR);
						NormalizeVector(end, end);

						start[0]=start[0]+end[0]*24.0;
						start[1]=start[1]+end[1]*24.0;
						start[2]=start[2]+end[2]*24.0;

						end[0]=start[0]+end[0]*64.0;
						end[1]=start[1]+end[1]*64.0;
						end[2]=start[2]+end[2]*64.0;

						TR_TraceRayFilter(start, end, CONTENTS_SOLID, RayType_EndPoint, TraceEntityFilterAll, 0);

						if (TR_DidHit(INVALID_HANDLE))
						{
							// Get the angles to place it
							TR_GetEndPosition(end, INVALID_HANDLE);
							TR_GetPlaneNormal(INVALID_HANDLE, normal);
							GetVectorAngles(normal, normal);
							
							//Back up along the trace ray
							GetVectorDistance(start, end, false);
							GetAngleVectors(angle, buffer, NULL_VECTOR, NULL_VECTOR);
							pos[0] = end[0] + (buffer[0]*distance);
							pos[1] = end[1] + (buffer[1]*distance);
							pos[2] = end[2] + (buffer[2]*distance);
							
							//Correct model angle
							normal[0] = -90.0;
							
							new bomb = CreateEntityByName("dod_bomb_target");
							DispatchKeyValue(bomb, "StartDisabled", "false");
							DispatchKeyValue(bomb, "bombing_team", "2");
							DispatchSpawn(bomb);
							
							g_plantedTNT[client] = true;
							g_TNTentity[client] = bomb;
							
							SetEntityMoveType(bomb, MOVETYPE_VPHYSICS);
							SetEntProp(bomb, Prop_Send, "m_CollisionGroup", DROP_COLLISION);
							SetEntProp(bomb, Prop_Send, "m_usSolidFlags", 28);
							SetEntProp(bomb, Prop_Send, "m_nSolidType", 6); 
												
							TeleportEntity(bomb, pos, normal, NULL_VECTOR);
							
							CreateTimer(3.0, RemoveTNT, bomb, TIMER_FLAG_NO_MAPCHANGE);
							
							new Handle:pack;
							CreateDataTimer(3.0, ReplaceTNT, pack, TIMER_FLAG_NO_MAPCHANGE);
							WritePackFloat(pack, pos[0]);
							WritePackFloat(pack, pos[1]);
							WritePackFloat(pack, pos[2]);
							WritePackFloat(pack, normal[0]);
							WritePackFloat(pack, normal[1]);
							WritePackFloat(pack, normal[2]);
							WritePackCell(pack, client);
						}
						else
						{
							// Strip the tnt
							new tnt;
							tnt = GetPlayerWeaponSlot(client, 4);
							if(tnt != -1) 
							{
								if (RemovePlayerItem(client, tnt))
									AcceptEntityInput(tnt, "kill");
							}
							CreateTimer(0.1, SpawnTNTInFrontPrimed, client, TIMER_FLAG_NO_MAPCHANGE);
							
						}
					}
				}
				
				//No TNT so any Healthpacks?
				else if (g_numDroppedHealth[client] > 0)
				{
					CreateTimer(0.1, SpawnHealthBoxInFront, client, TIMER_FLAG_NO_MAPCHANGE);

					g_numDroppedHealth[client]--;
				}
			}
		}

	}
			
	return Plugin_Continue;
}

public Action:CheckPostTeleport(Handle:timer, Handle:datapack)
{
	ResetPack(datapack);
	new Float:lastPosition[3], Float:pos;
	lastPosition[0] = ReadPackFloat(datapack);
	lastPosition[1] = ReadPackFloat(datapack);
	lastPosition[2] = ReadPackFloat(datapack);
	pos	 = ReadPackFloat(datapack);
	new client = ReadPackCell(datapack);

	hTeleportData[client] = INVALID_HANDLE;
		
	if (IsClientInGame(client) && IsPlayerAlive(client) && GetClientTeam(client) == 3)
	{
		new Float: loc[3];
		GetClientAbsOrigin(client, loc);
		if (loc[2] == (pos + 10.0))
		{
			TeleportEntity(client, lastPosition, NULL_VECTOR, NULL_VECTOR);
			
			g_iBotsTarget[client] = 0;
			GetNearestWaypoint(client);
			
			if (!IsFakeClient(client))
				PrintHelp(client, "*TELEPORT CAREFULLY...", 3);
				
			#if DEBUG
				LogToFileEx(g_szLogFileName,"[L4DOD] CheckPostTeleport executed:%i", client);
			#endif
			
		}
	}

	return Plugin_Continue;
}

public Action:ResetClientTNT(Handle:timer, any:client)
{
	g_plantedTNT[client] = false;
	return Plugin_Handled;
}

public Action:RemoveTNT(Handle:timer, any:entity)
{
	if (IsValidEntity(entity) && IsValidEdict(entity))
	{		
		new String:classname[256];
		GetEdictClassname(entity, classname, sizeof(classname));
		if (StrEqual(classname, "dod_bomb_target", false))
		{
			AcceptEntityInput(entity, "kill");
		}
	}
	return Plugin_Handled;
}

public Action:ReplaceTNT(Handle:timer, Handle:datapack)
{
	ResetPack(datapack);
	new Float:normal[3], Float:pos[3];
	pos[0] = ReadPackFloat(datapack);
	pos[1] = ReadPackFloat(datapack);
	pos[2] = ReadPackFloat(datapack);
	normal[0] = ReadPackFloat(datapack);
	normal[1] = ReadPackFloat(datapack);
	normal[2] = ReadPackFloat(datapack);
	new client = ReadPackCell(datapack);
	
	g_plantedTNT[client] = false;
	
	g_TNTNumber++;

	new ent = CreateEntityByName("prop_physics_override");
	if (ent>0 && g_primedTNT[client])
	{
		SetEntityModel(ent, "models/weapons/w_tnt.mdl");		
		new String:tntname2[16];
		Format(tntname2, sizeof(tntname2), "TNT%i", g_TNTNumber);
		DispatchKeyValue(ent, "StartDisabled", "false");
		DispatchKeyValue(ent, "targetname", tntname2);
		SetEntityMoveType(ent, MOVETYPE_NONE);
		SetEntProp(ent, Prop_Send, "m_CollisionGroup", DROP_COLLISION);
				
		DispatchSpawn(ent);
		AcceptEntityInput(ent, "DisableMotion");
				
		TeleportEntity(ent, pos, normal, NULL_VECTOR);
		
		#if DEBUG
			LogToFileEx(g_szLogFileName,"[L4DOD] Created tnt drop:%i", ent);
		#endif
		
		DispatchKeyValue(ent, "physdamagescale", "1.0");
		DispatchKeyValue(ent, "spawnflags", "527");
		SetEntProp(ent, Prop_Data, "m_takedamage", 2);
		DispatchKeyValue(ent, "MinHealthDmg", "20.0");
		SDKHook(ent, SDKHook_OnTakeDamage, EntityTakeDamage);
		SetEntityRenderColor(ent, 255, 0, 128, 255);
		
		if (g_Hints[client])
			PrintHelp(client, "\x05*Shoot the Red TNT and it will explode", 0);
			
		new String:addoutput[64];
		Format(addoutput, sizeof(addoutput), "OnUser1 !self:kill::%f:1", 21.0);
		SetVariantString(addoutput);
		AcceptEntityInput(ent, "AddOutput");
		AcceptEntityInput(ent, "FireUser1");
		
		PrintHelp(client, "*TNT is primed.  Shoot to detonate", 0);
		PrintHelp(client, "*TNT is primed.  Shoot to detonate", 3);
		
		g_primedTNT[client] = false;
		g_TNTentity[client] = 0;
	}		
	return Plugin_Handled;
}

public Action:AllowTargeting(Handle:timer, any:iClient)
{
	g_bCanTarget[iClient] = true;
	return Plugin_Handled;
}
 
 CheckWayPoints(any:bot)
{
	if (GetClientTeam(bot) == AXIS)
	{
		if (g_WayPoint[bot] >= g_iAxisKeys[g_WayPointSet[bot]] && g_iBotsDirection[bot] == 1)
		{
			g_WayPoint[bot] = g_iAxisKeys[g_WayPointSet[bot]];
			g_iBotsDirection[bot] = -1;
		}
	}
	else if (GetClientTeam(bot) == ALLIES)
	{
		if (g_WayPoint[bot] >= g_iAlliesKeys[g_WayPointSet[bot]] && g_iBotsDirection[bot] == 1)
		{
			g_WayPoint[bot] = g_iAlliesKeys[g_WayPointSet[bot]];
			g_iBotsDirection[bot] = -1;
		}
	}
		
	//Bots do not need to go back to spawn
	if (g_iBotsDirection[bot] == -1 && g_WayPoint[bot] < 7)
	{
		g_WayPoint[bot] = 7;
		g_iBotsDirection[bot] = 1;
	}
}

stock DoubleJump(const any:client) 
{
	new	fCurFlags	= GetEntityFlags(client);
	new fCurButtons = GetClientButtons(client);
		
	if (g_iLastFlags[client] & FL_ONGROUND) 
	{					
		if (!(fCurFlags & FL_ONGROUND) &&	!(g_iLastButtons[client] & IN_JUMP) && fCurButtons & IN_JUMP) 
		{
			OriginalJump(client);				
		}
	} 
	else if (fCurFlags & FL_ONGROUND) 
	{
		Landed(client);
	} 
	else if (!(g_iLastButtons[client] & IN_JUMP) && fCurButtons & IN_JUMP) 
	{
		ReJump(client);				
	}
	
	g_iLastFlags[client]	= fCurFlags;			
	g_iLastButtons[client]	= fCurButtons;		
}

stock OriginalJump(const any:client) 
{
	g_iJumps[client]++;	
	AttachParticle(client, "rockettrail", 2.0);
}

stock Landed(const any:client) 
{
	g_iJumps[client] = 0;	
}

stock ReJump(const any:client)
{
	if (GetClientTeam(client) == AXIS)
	{
		if (g_ZombieType[client] >= 0)
		{
			if ( 1 <= g_iJumps[client] <= g_iJumpMax[g_ZombieType[client]]) 
			{						
			// has jumped at least once but hasn't exceeded max re-jumps
				g_iJumps[client]++;										// increment jump count
				decl Float:vVel[3];
				GetEntPropVector(client, Prop_Data, "m_vecVelocity", vVel);	// get current speeds
				
				decl Float:clientEyeAngles[3];
				GetClientEyeAngles(client, clientEyeAngles);
				
				decl Float:forwardVector[3];
				GetAngleVectors(clientEyeAngles, forwardVector, NULL_VECTOR, NULL_VECTOR);
				NormalizeVector(forwardVector, forwardVector);
				ScaleVector(forwardVector, 100.0);
				
				vVel[0] += forwardVector[0];
				vVel[1] += forwardVector[1];
				
				vVel[2] = g_fJumpAmount[g_ZombieType[client]];
				TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, vVel);		// boost player
				
				PlaySound(client, false);
			
				AttachParticle(client, "rockettrail", 1.0);
			}
		}
	}
}

stock ForceJump(const any:client, Float:fJump, Float:fAngle)
{
	if (GetClientTeam(client) == AXIS)
	{
		new	fCurFlags	= GetEntityFlags(client);
		
		if (g_ZombieType[client] >= 0 && fCurFlags & FL_ONGROUND)
		{					
			decl Float:vVel[3];
			GetEntPropVector(client, Prop_Data, "m_vecVelocity", vVel);	// get current speeds
			
			decl Float:clientEyeAngles[3];
			GetClientEyeAngles(client, clientEyeAngles);
			clientEyeAngles[1] += fAngle * (GetRandomFloat(-1.0, 1.0));
			
			decl Float:forwardVector[3];
			GetAngleVectors(clientEyeAngles, forwardVector, NULL_VECTOR, NULL_VECTOR);
			NormalizeVector(forwardVector, forwardVector);
			ScaleVector(forwardVector, 150.0);
			
			vVel[0] += forwardVector[0];
			vVel[1] += forwardVector[1];
			
			vVel[2] = forwardVector[2] + fJump;
			TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, vVel);		// boost player
				
			PlaySound(client, false);
		}
	}
}

stock ForceSide(const any:client, Float:fJump, Float:fAngle)
{
	if (GetClientTeam(client) == AXIS)
	{
		new	fCurFlags	= GetEntityFlags(client);
		
		if (g_ZombieType[client] >= 0 && fCurFlags & FL_ONGROUND)
		{					
			decl Float:vVel[3];
			GetEntPropVector(client, Prop_Data, "m_vecVelocity", vVel);	// get current speeds
			
			decl Float:clientEyeAngles[3];
			GetClientEyeAngles(client, clientEyeAngles);
			clientEyeAngles[1] += fAngle * (GetRandomFloat(-1.0, 1.0));
			
			decl Float:forwardVector[3];
			GetAngleVectors(clientEyeAngles, forwardVector, NULL_VECTOR, NULL_VECTOR);
			NormalizeVector(forwardVector, forwardVector);
			ScaleVector(forwardVector, 150.0);
			
			vVel[0] += forwardVector[0] + (fJump * GetRandomFloat(-1.0, 1.0)); //jump to side
			vVel[1] += forwardVector[1] + (fJump * GetRandomFloat(-0.5, 0.5)); //jump back
			
			vVel[2] = forwardVector[2] + (fJump * GetRandomFloat(0.5, 1.0));
			TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, vVel);		// boost player
				
			PlaySound(client, false);
		}
	}
}

