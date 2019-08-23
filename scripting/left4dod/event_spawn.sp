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
#define HIDEHUD_ALL         	( 1<<2 )

static const String:name_list[][] = { "Screeching Console", 
"Machete Max", "Zombie Crixsis", "Zombie Pravda", "Vet Zombie", "Rebel Zombie", 
"Maurice Mosher", "Creepy Creeper", "Zombie Tseeneth",  "Zombie MRKI", "Zombie Boki", 
"Zombie Defender", "Zombie Oldboy", "Zombie Blindschleiche", "Ghilliezombie", "Zombie Aleboy", 
"Zombie Papa", "Aardvark Zombie", "Zombie Podunktologist", "Zombie Klaus", "Zombie Store", "Zombie Boots", "Zombie WetSeal",
"Zombie Ion", "Zombie Transit", "Zombie Rugedog", "Masher Carrie", "Donny Osmond", 
"The Carrot of Doom", "Aaaaargh", "Putrid Paul", "Gruesome Gator", "Septic Simon"
 };
 

public SpawnEvent(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (GetConVarInt(hL4DOn))
	{	
		new client   = GetClientOfUserId(GetEventInt(event, "userid"));
		
		//Make sure player is visible
		CreateTimer(0.1, ShowPlayer, client, TIMER_FLAG_NO_MAPCHANGE);
		
		RemoveSprite(client);
		g_showOverlay[client] = false;
		
		GetClientAbsOrigin(client, g_vecSpawn[client]);
				
		SetEntityGravity(client, 1.0);
		SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 1.0);
		
		g_canUseWeapon[client] = true;
		g_iTimeAFK[client] = 0;
		g_iTimeAtSpawn[client] = 0;
		g_iSuspendAFK[client] = false;
		g_PauseMovement[client] = false;
		
		g_iJumps[client] = 0;
		
		for (new flag = 0; flag < g_iFlagNumber; flag++)
		{
			g_atFlag[flag][client] = false;
		}
		
		g_CanRightClick[client] = false;
		
		g_iBotsLostTarget[client] = 0;
		
		g_plantedTNT[client] = false;
		g_TNTentity[client] = 0;
		g_iDroppedTNT[client] = 0;
		g_numDroppedHealth[client] = 0;
		
		//Allied
		g_hasHooch[client] = false;
		g_bZoomed[client] = false;
		g_hasAdrenaline[client] = false;
		g_hasBoxNades[client] = false;
		g_hasAntiGas[client] = false;
		g_hasShotgun[client] = false;
		
		g_preHealth[client] = 0;
				
		g_isIgnored[client] = false;
		g_isInfected[client] = false;
		g_Molotov[client] = 0; 
				
		//Zombie
		g_OnFire[client] = false;		
				
		g_canTP[client] = false;
		g_canVanish[client] = false;
		g_Invisible[client] = false;
		g_canMaster[client] = false;
		g_canSkull[client] = false;
		g_canSmoke[client] = false;
		g_canMine[client] = false;
						
		g_bCanGasBomb[client] = false;
		g_bGasBombExploded[client] = false;
		g_canDet[client] = false;
		g_bCanMakeNoise[client] = true;
		g_canSuck[client] = false;
		g_iSuckCount[client] = 0;
		
		g_invZB[client] = false;
		g_noFire[client] = false;
	
		g_numSkull[client] = 0;
		g_numMaster[client] = 0;
		g_numTP[client] = 0;
		
		g_SpriteEntity[client] = -1;
			
		//Used by bots to prevent runcmd moving bots before round start!
		g_iHasSpawned[client]++;
		g_bIsWaiting[client] = false;

		g_checkWeapons[client] = false;
		
		g_minAlpha[client] = 0;
		SetAlpha(client, 255); 
		g_ShowSprite[client] = false;
		
		//Prevent accidental right clicking from death
		CreateTimer(1.0, AllowRightClick, client, TIMER_FLAG_NO_MAPCHANGE);
				
		// Set up the bot
		if (IsFakeClient(client))
		{				
			#if DEBUG
				LogToFileEx(g_szLogFileName,"[L4DOD] Bot spawned: %i", client);
			#endif
						
			//Reset Bot's targetting
			g_iBotsTarget[client] = 0;
			
			SetEntProp(client, Prop_Data, "m_takedamage", 0, 1); 
			CreateTimer(GetConVarFloat(hL4DSpawnProtection), RestoreHealth, client, TIMER_FLAG_NO_MAPCHANGE);
									
			//Reset Bot's WayPoint variables
			g_WayPoint[client] = 1;
			g_iBotsDirection[client] = 1;
			g_bAtFlag[client] = false;
			g_iBotsStuck[client] = 0;	
			g_bCanTarget[client] = true;
			g_iBotJumped[client] = 0;
			
			SetEntityGravity(client, 0.8);
			
			//Load the waypoints
			GetWaypointsFromSpawn(client);
						
			//Set Bot Health
			g_iBotsTime[client] = 0;
								
			if (g_hSearch_Timer[client] == INVALID_HANDLE)
			{
				g_hSearch_Timer[client] = CreateTimer(1.0, SearchTargets, client, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
				#if DEBUG
					LogToFileEx(g_szLogFileName,"[L4DOD] Search timer started: %i", client);
				#endif
			}
										
			//If they were a boss, reset them
			g_ZombieType[client] = -1;
			SetName(client, "");
			SetAlpha(client, 255);
			
			g_canTP[client] = true;
			g_canGas[client] = false;
			
			#if DEBUG
				LogToFileEx(g_szLogFileName, "[L4DOD] %N spawned with Health %i", client, g_Health[client]);
			#endif
						
			// Spawn Special Infected only when there are less than 4 players on	
			if (GetClientTeam(client) == AXIS)
			{				
				if (GetConVarInt(hL4DSI) == 1)
				{
					// 
					new iWins = g_AlliedWins - g_AxisWins;
					if (iWins <= 0) iWins = 1;
					
					new maxnum = iWins;
					if (maxnum >= 2) maxnum = 2;
				
					if (!CheckSZ(GREYDUDE, 1) && (g_Allies > 3 || g_AlliedWins > g_AxisWins))
					{
						#if DEBUG
							LogToFileEx(g_szLogFileName,"[L4DOD] Bot spawned as Grey Dude:%i", client);
						#endif
													
						g_Health[client] = GREYDUDE_HEALTH;
						g_fDamageScale[client] = 100.0 / GREYDUDE_HEALTH;
						g_HealthMax[client] = GREYDUDE_HEALTH + g_HealthAdded[client];
						
						SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", ZOMBIESPEED);
						
						g_ZombieType[client] = GREYDUDE;
						// Set Bot's model
						SetEntityModel(client, "models/player/german_theone.mdl");
						SetName(client, "The Grey Dude");
						g_canMaster[client] = true;
						g_numMaster[client] = 2500;
						SetAlpha(client, 255);
					}
					
					else if (!CheckSZ(INFECTEDONE, maxnum))
					{
						#if DEBUG
							LogToFileEx(g_szLogFileName,"[L4DOD] Bot spawned as Infected:%i", client);
						#endif
						
						g_Health[client] = INFECTEDONE_HEALTH;
						g_fDamageScale[client] = 100.0 / INFECTEDONE_HEALTH;
						g_HealthMax[client] = INFECTEDONE_HEALTH  + g_HealthAdded[client];
						
						g_ZombieType[client] = INFECTEDONE;
						// Set Bot's model
						SetEntityModel(client, "models/player/german_traitor.mdl");
						SetName(client, "The Infected One");
						g_canVanish[client] = true;
						g_canTP[client] = true;
						SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", INFECTEDSPEED);
						
						new somerandom = GetRandomInt(0,7);
						g_Sprite[client] = g_AxisSpriteModel[somerandom];
						g_ShowSprite[client] = true;
						SetAlpha(client, 255);
						CreateSprite(client);
					}
					
					// 
					else if (!CheckSZ(WITCH, 1) && (g_Allies > 2 || g_AlliedWins > g_AxisWins))
					{
						#if DEBUG
							LogToFileEx(g_szLogFileName,"[L4DOD] Bot spawned as Witch:%i", client);
						#endif
						
						g_Health[client] = WITCH_HEALTH;
						g_fDamageScale[client] = 100.0 / WITCH_HEALTH;
						g_HealthMax[client] = WITCH_HEALTH  + g_HealthAdded[client];
						
						g_ZombieType[client] = WITCH;
						// Set Bot's model
						SetEntityModel(client, "models/player/techknow/left4dead/witch.mdl");
						
						SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", WITCHSPEED);
						
						SetName(client, "The Witch");
						g_numTP[client] = 4;
						SetAlpha(client, 255);
					}
					
					//
					else if (!CheckSZ(EMO, 1) && (g_Allies > 4 || g_AlliedWins > g_AxisWins))
					{
						#if DEBUG
							LogToFileEx(g_szLogFileName,"[L4DOD] Bot spawned as Emo:%i", client);
						#endif
						
						g_Health[client] = EMO_HEALTH;
						g_fDamageScale[client] = 100.0 / EMO_HEALTH;
						g_HealthMax[client] = EMO_HEALTH  + g_HealthAdded[client];
						
						g_ZombieType[client] = EMO;
						
						SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", ZOMBIESPEED);
						
						// Set Bot's model
						SetEntityModel(client, "models/player/german_emo.mdl");
						SetName(client, "The Emo");
						SetAlpha(client, 255);
					}
					
					//
					else if (!CheckSZ(GASMAN, maxnum) && g_Allies > 3)
					{
						#if DEBUG
							LogToFileEx(g_szLogFileName,"[L4DOD] Bot spawned as Gasman:%i", client);
						#endif
						
						g_Health[client] = GASMAN_HEALTH;
						g_fDamageScale[client] = 100.0 / GASMAN_HEALTH;
						g_HealthMax[client] = GASMAN_HEALTH  + g_HealthAdded[client];
						
						g_ZombieType[client] = GASMAN;
						
						SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", ZOMBIESPEED);
						
						g_bCanGasBomb[client] = true;
						g_iNumGasBombs[client] = 2500;
						
						// Set Bot's model
						SetEntityModel(client, "models/player/german_gasman.mdl");
						SetName(client, "The Gas Man");
						SetAlpha(client, 255);
					}
					
					else if (!CheckSZ(ANARCHIST, maxnum))
					{
						#if DEBUG
							LogToFileEx(g_szLogFileName,"[L4DOD] Bot spawned as Anarchist:%i", client);
						#endif
						
						g_Health[client] = ANARCHIST_HEALTH;
						g_fDamageScale[client] = 100.0 / ANARCHIST_HEALTH;
						g_HealthMax[client] = ANARCHIST_HEALTH  + g_HealthAdded[client];
						
						g_ZombieType[client] = ANARCHIST;
						
						SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", ZOMBIESPEED);
						
						g_canSkull[client] = true;
						g_numSkull[client] = 2500;
						
						// Set Bot's model
						SetEntityModel(client, "models/player/techknow/left4dead/hunter.mdl");
						SetName(client, "The Anarchist");
						SetAlpha(client, 255);
					}
					
					//
					else if (!CheckSZ(UNG, 1) && (g_Allies > 7 && g_AlliedWins > g_AxisWins))
					{
						#if DEBUG
							LogToFileEx(g_szLogFileName,"[L4DOD] Bot spawned as Ugly Naked Guy:%i", client);
						#endif
						
						g_Health[client] = UNG_HEALTH;
						g_fDamageScale[client] = 100.0 / UNG_HEALTH;
						g_HealthMax[client] = UNG_HEALTH  + g_HealthAdded[client];
						
						g_ZombieType[client] = UNG;
						
						SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", UNGSPEED);
						
						// Set Bot's model
						SetEntityModel(client, "models/player/german_speedo.mdl");
						SetName(client, "The UNG");
						SetAlpha(client, 255);
					}
					
					//
					else if (!CheckSZ(WRAITH, 1) && (g_Allies > 4 && g_AlliedWins > g_AxisWins))
					{
						#if DEBUG
							LogToFileEx(g_szLogFileName,"[L4DOD] Bot spawned as Wraith:%i", client);
						#endif
						
						g_Health[client] = WRAITH_HEALTH;
						g_fDamageScale[client] = 100.0 / WRAITH_HEALTH;
						g_HealthMax[client] = WRAITH_HEALTH + g_HealthAdded[client];
						
						g_ZombieType[client] = WRAITH;
						
						SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", ZOMBIESPEED);
						
						// Set Bot's model
						SetEntityModel(client, "models/player/wraith/german_wraith.mdl");
						SetName(client, "The Wraith");
						
						g_canSuck[client] = true;
					}
					
					// 
					else if (!CheckSZ(SKELETON, 1) && (g_Allies > 6 || g_AlliedWins > g_AxisWins))
					{
						#if DEBUG
							LogToFileEx(g_szLogFileName,"[L4DOD] Bot spawned as Skeleton:%i", client);
						#endif
						
						g_Health[client] = SKELETON_HEALTH;
						g_fDamageScale[client] = 100.0 / SKELETON_HEALTH;
						g_HealthMax[client] = SKELETON_HEALTH + g_HealthAdded[client];
						
						g_ZombieType[client] = SKELETON;
						
						// Set Bot's model
						SetEntityModel(client, "models/player/russianarmy/zombie/bones.mdl");
						SetName(client, "The Skeleton");
						
						SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", SKELETONSPEED);
						
						SetAlpha(client, 255);
					}
					//
					else if (!CheckSZ(HELLSPAWN, 1)  && (g_Allies > 5 || g_AlliedWins > g_AxisWins))
					{
						#if DEBUG
							LogToFileEx(g_szLogFileName,"[L4DOD] Bot spawned as Hellspawn:%i", client);
						#endif
													
						g_Health[client] = HELLSPAWN_HEALTH;
						g_fDamageScale[client] = 100.0 / HELLSPAWN_HEALTH;
						g_HealthMax[client] = HELLSPAWN_HEALTH + g_HealthAdded[client];
						
						SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", ZOMBIESPEED);
						
						g_ZombieType[client] = HELLSPAWN;
						// Set Bot's model
						SetEntityModel(client, "models/player/russianarmy/zombie/hellknight.mdl");
						SetName(client, "Hell Spawn");
						g_canFireball[client] = true;
						g_numFireball[client] = 2500;
						SetAlpha(client, 255);
					}
					
					else
					{				
						// Set Bot's model
						SetEntityModel(client, "models/player/german_zombie.mdl");
						
						g_Health[client] = ZOMBIE_HEALTH;
						g_fDamageScale[client] = 100.0 / ZOMBIE_HEALTH;
						g_HealthMax[client] = ZOMBIE_HEALTH  + g_HealthAdded[client];
					}
				}
				else
				{				
					// Set Bot's model
					SetEntityModel(client, "models/player/german_zombie.mdl");
					
					g_Health[client] = ZOMBIE_HEALTH;
					g_fDamageScale[client] = 100.0 / ZOMBIE_HEALTH;
					g_HealthMax[client] = ZOMBIE_HEALTH  + g_HealthAdded[client];
				}

				SetEntityMoveType(client, MOVETYPE_WALK);
												
				CreateTimer(0.1, GiveZombieWeapon, client, TIMER_FLAG_NO_MAPCHANGE);
			}
			else
			{
				g_canUseWeapon[client] = false;
				DisableWeapons(client);
			}
		}
		else if (!IsFakeClient(client))
		{	
			if (GetClientTeam(client) == AXIS)
			{
				#if DEBUG
					LogToFileEx(g_szLogFileName,"[L4DOD] Axis Player spawned: %i", client);
				#endif
								
				//Make sure weapons are zeroed on team change
				g_szPlayerWeapon[client] = "";
				g_szPlayerSecondaryWeapon[client] = "";
				g_szPlayerGrenadeWeapon[client] = "";
		
				g_canGas[client] = false;
				g_canSkull[client] = false;
				g_canTP[client] = false;
				g_canVanish[client] = false;
				g_canMaster[client] = false;
				g_canDet[client] = false;
				g_bCanGasBomb[client] = false;
				g_canSuck[client] = false;
				g_canSmoke[client] = true;	
				g_ShowSprite[client] = false;
				
				g_showOverlay[client] = true;
				CreateTimer(5.0, HideOverlay, client, TIMER_FLAG_NO_MAPCHANGE);
				
				if (g_useEquip[client])
					CreateTimer(1.0, DisplayMainMenu, client, TIMER_FLAG_NO_MAPCHANGE);
											
				SetEntProp(client, Prop_Send, "m_fEffects", 0);
				SetEntityMoveType(client, MOVETYPE_WALK);
				
				//Don't take damage
				SetEntProp(client, Prop_Data, "m_takedamage", 0, 1);
				CreateTimer(2.0, RestoreHealth, client, TIMER_FLAG_NO_MAPCHANGE);
				
				//Default values for health
				g_Health[client] = ZOMBIE_HEALTH;
				g_fDamageScale[client] = 100.0 / ZOMBIE_HEALTH;
				g_HealthMax[client] = ZOMBIE_HEALTH;
				
				g_ZombieType[client] = -1;
				
				if (g_ZombieClass[client] == GREYDUDE)
				{						
					CreateTimer(0.2, SpawnGreyDude, client, TIMER_FLAG_NO_MAPCHANGE);
				}	
				else if (g_ZombieClass[client] == WITCH)
				{
					CreateTimer(0.2, SpawnWitch, client, TIMER_FLAG_NO_MAPCHANGE);
				}
				else if (g_ZombieClass[client] == INFECTEDONE)
				{
					CreateTimer(0.2, SpawnInfected, client, TIMER_FLAG_NO_MAPCHANGE);
				}
				else if (g_ZombieClass[client] == GASMAN)
				{
					CreateTimer(0.2, SpawnGasman, client, TIMER_FLAG_NO_MAPCHANGE);
				}					
				else if (g_ZombieClass[client] == ANARCHIST)
				{
					CreateTimer(0.2, SpawnAnarchist, client, TIMER_FLAG_NO_MAPCHANGE);
				}
				else if (g_ZombieClass[client] == WRAITH)
				{
					CreateTimer(0.2, SpawnWraith, client, TIMER_FLAG_NO_MAPCHANGE);
				}
				else if (g_ZombieClass[client] == UNG)
				{
					CreateTimer(0.2, SpawnUNG, client, TIMER_FLAG_NO_MAPCHANGE);
				}
				else if (g_ZombieClass[client] == SKELETON)
				{
					CreateTimer(0.2, SpawnSkeleton, client, TIMER_FLAG_NO_MAPCHANGE);
				}
				else if (g_ZombieClass[client] == EMO)
				{
					CreateTimer(0.2, SpawnEmo, client, TIMER_FLAG_NO_MAPCHANGE);
				}
				else if (g_ZombieClass[client] == HELLSPAWN)
				{
					CreateTimer(0.2, SpawnHellSpawn, client, TIMER_FLAG_NO_MAPCHANGE);
				}
				else
				{
					CreateTimer(0.2, SpawnZombie, client, TIMER_FLAG_NO_MAPCHANGE);
				}
			}
			else if (GetClientTeam(client) == ALLIES)
			{				
				#if DEBUG
					LogToFileEx(g_szLogFileName,"[L4DOD] Allied Player spawned: %i", client);
				#endif
				
				//Make sure Zombie variable is not set
				ResetZombieClassVariable(client);
				
				g_fDamageScale[client] = 100.0 / 500.0;
							
				if (!IsFakeClient(client))
				{												
					g_ZombieType[client] = -1;
					SetAlpha(client, 255);
										
					if (g_useEquip[client])
						CreateTimer(1.0, DisplayMainMenu, client, TIMER_FLAG_NO_MAPCHANGE);
					
					ClientCommand(client, "r_screenoverlay 0");
								
					SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 1.0);
					
					// Weapon menu				
					decl String:Weapon[32];
					GetClientWeapon(client, Weapon, sizeof(Weapon));
										
					//Weapon rules
					new class = GetEntProp(client, Prop_Send, "m_iPlayerClass");
					
					if (StrEqual(g_szPlayerWeapon[client], "") && class == 0)
						g_szPlayerWeapon[client] = "weapon_garand";
					else if (StrEqual(g_szPlayerWeapon[client], "") && class == 1)
						g_szPlayerWeapon[client] = "weapon_thompson";
					else if (StrEqual(g_szPlayerWeapon[client], "") && class == 2)
						g_szPlayerWeapon[client] = "weapon_bar";

					if (!(StrEqual(g_szPlayerWeapon[client], "weapon_30cal") || StrEqual(g_szPlayerWeapon[client], "weapon_mg42")) && class == MG)
						g_szPlayerWeapon[client] = "";
					
					if ((StrEqual(g_szPlayerWeapon[client], "weapon_30cal") || StrEqual(g_szPlayerWeapon[client], "weapon_mg42")) && class != MG)
						g_szPlayerWeapon[client] = "";
						
					if (!(StrEqual(g_szPlayerWeapon[client], "weapon_k98_scoped") || StrEqual(g_szPlayerWeapon[client], "weapon_spring")) && class == SNIPER)
						g_szPlayerWeapon[client] = "";
						
					if ((StrEqual(g_szPlayerWeapon[client], "weapon_k98_scoped") || StrEqual(g_szPlayerWeapon[client], "weapon_spring")) && class != SNIPER)
						g_szPlayerWeapon[client] = "";
						
					if (!(StrEqual(g_szPlayerWeapon[client], "weapon_bazooka") || StrEqual(g_szPlayerWeapon[client], "weapon_pschreck")) && class == ROCKET)
						g_szPlayerWeapon[client] = "";
					
					if ((StrEqual(g_szPlayerWeapon[client], "weapon_bazooka") || StrEqual(g_szPlayerWeapon[client], "weapon_pschreck")) && class != ROCKET)
						g_szPlayerWeapon[client] = "";
										
					CreateTimer(0.2, EquipClient, client, TIMER_FLAG_NO_MAPCHANGE);
					
					g_HealthMax[client] = MAXHEALTH;
					g_Health[client] = MAXHEALTH;
					SetHealth(client, g_Health[client]);
					
					if (g_Hints[client])
					{
						PrintHelp(client,"*Say !menu to open the store", 0);
					}
								
					if (g_useFL[client])
					{
						new effect = GetEntProp(client, Prop_Send, "m_fEffects");
						effect |= 4;
						SetEntProp(client, Prop_Send, "m_fEffects", effect);
					}
					
					// Protect Allies as they leave spawn
					SetEntProp(client, Prop_Data, "m_takedamage", 0, 1);  
					CreateTimer(8.0, RestoreHealth, client, TIMER_FLAG_NO_MAPCHANGE);
				}
			}
		}
	}
}

//Routine only for bots
public bool:CheckSZ(any:type, any:amount)
{
	new total = 0;
	for (new i=1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i) && IsFakeClient(i) && GetClientTeam(i) == AXIS)
		{
			if (g_ZombieType[i] == type)
			{						
				total++;
				if (total >= amount)
					return true;
			}
		}
	}

	return false;
}

public Action:AllowRightClick(Handle:timer, any:client)
{
	g_CanRightClick[client] = true;
	return Plugin_Continue;
}

public Action:HidePlayer(Handle:timer, any:client)
{
	if (IsClientInGame(client))
	{
		SetAlpha(client, 0);
		SDKHook(client, SDKHook_SetTransmit, Hook_SetTransmitInvisible);
	}
	return Plugin_Continue;
}

public Action:ShowPlayer(Handle:timer, any:client)
{
	if (IsClientInGame(client))
	{
		SetAlpha(client, 255);
		SDKUnhook(client, SDKHook_SetTransmit, Hook_SetTransmitInvisible);
	}
	return Plugin_Continue;
}

public Action:Hook_SetTransmitInvisible(entity, client) 
{
	//The AXIS should not see the Spawning player
    if (GetClientTeam(client) == ALLIES)
        return Plugin_Handled;
		
    return Plugin_Continue;
} 

public Action:NameChangeEvent(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	if (IsClientInGame(client) && GetClientTeam(client) == 3)
		return Plugin_Handled;
	
	return Plugin_Continue;
}

//Used to set the names of the bots
public SetName(target, String:nametoset[64])
{ 
	if (strlen(nametoset) == 0)
	{
		new String:name[64];
		Format(name, sizeof(name), "%s", name_list[target]);
			
		SetClientInfo(target, "name", name);
	}
	else
	{
		SetClientInfo(target, "name", nametoset);
	}
}

public Action:SpawnGreyDude(Handle:timer, any:client)
{
	if (IsClientInGame(client) && IsPlayerAlive(client) && GetClientTeam(client) == 3)
	{
		#if DEBUG
			LogToFileEx(g_szLogFileName,"[L4DOD] Player spawned as Grey Dude:%i", client);
		#endif
		
		ResetZombieVariables(client);
		
		g_Health[client] = GREYDUDE_HEALTH;
		g_HealthMax[client] = GREYDUDE_HEALTH;
		g_fDamageScale[client] = 100.0 / GREYDUDE_HEALTH;
		
		g_ZombieType[client] = GREYDUDE;
							
		PrintHelp(client, "*You are \x04The Grey Dude", 0);
		PrintHelp(client, "*You are The Grey Dude", 3);
		PrintHelp(client, "*Point your crosshairs and use \x04+ATTACK2\x01 (or \x04Right Click\x01) to Teleport reinforcements", 0);
		PrintHelp(client, "*Pick up \x04Ammo Boxes\x01 to increase number of Teleports", 0);
		SetEntityModel(client, "models/player/german_theone.mdl");
		
		SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", ZOMBIESPEED);
		
		g_canMaster[client] = true;
		g_numMaster[client] = 10;
		
		CreateTimer(0.1, GiveZombieWeapon, client, TIMER_FLAG_NO_MAPCHANGE);
	}
	return Plugin_Handled;
}

public Action:SpawnInfected(Handle:timer, any:client)
{
	if (IsClientInGame(client) && IsPlayerAlive(client) && GetClientTeam(client) == 3)
	{
		#if DEBUG
			LogToFileEx(g_szLogFileName,"[L4DOD] Player spawned as Infected:%i", client);
		#endif
		
		ResetZombieVariables(client);
		
		g_Health[client] = INFECTEDONE_HEALTH;
		g_HealthMax[client] = INFECTEDONE_HEALTH;
		g_fDamageScale[client] = 100.0 / INFECTEDONE_HEALTH;
		
		g_ZombieType[client] = INFECTEDONE;
		
		SetEntityModel(client, "models/player/german_traitor.mdl");
		PrintHelp(client, "*You are \x04The Infected One", 0);
		PrintHelp(client, "*You are The Infected One", 3);
		PrintHelp(client, "*Use \x04+ATTACK2\x01 (or \x04Right Click\x01) to Disappear", 0);
		
		SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", INFECTEDSPEED);
		
		new somerandom = GetRandomInt(0,7);
		g_Sprite[client] = g_AxisSpriteModel[somerandom];
		g_ShowSprite[client] = true;
		
		g_canVanish[client] = true;
		g_ShowSprite[client] = true;
		
		CreateTimer(0.1, GiveZombieWeapon, client, TIMER_FLAG_NO_MAPCHANGE);
	}
	return Plugin_Handled;
}

public Action:SpawnWitch(Handle:timer, any:client)
{
	if (IsClientInGame(client) && IsPlayerAlive(client) && GetClientTeam(client) == 3)
	{
		#if DEBUG
			LogToFileEx(g_szLogFileName,"[L4DOD] Player spawned as Witch:%i", client);
		#endif
		
		ResetZombieVariables(client);
		
		g_Health[client] = WITCH_HEALTH;
		g_HealthMax[client] = WITCH_HEALTH;
		g_fDamageScale[client] = 100.0 / WITCH_HEALTH;
		
		g_ZombieType[client] = WITCH;
							
		SetEntityModel(client, "models/player/techknow/left4dead/witch.mdl");
		PrintHelp(client, "*You are \x04The Witch", 0);
		PrintHelp(client, "*You are The Witch", 3);
		PrintHelp(client, "*Point your crosshairs and use \x04+ATTACK2 \x01 (or \x04Right Click\x01) to Teleport", 0);
		PrintHelp(client, "*Pick up \x04Ammo Boxes\x01 to increase number of Teleports", 0);
		
		SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", WITCHSPEED);
		
		g_canTP[client] = true;
		g_numTP[client] = 10;
		
		CreateTimer(0.1, GiveZombieWeapon, client, TIMER_FLAG_NO_MAPCHANGE);
	}
	return Plugin_Handled;
}

public Action:SpawnGasman(Handle:timer, any:client)
{
	if (IsClientInGame(client) && IsPlayerAlive(client) && GetClientTeam(client) == 3)
	{
		ResetZombieVariables(client);
		
		#if DEBUG
			LogToFileEx(g_szLogFileName,"[L4DOD] Player spawned as Gasman:%i", client);
		#endif
		g_Health[client] = GASMAN_HEALTH;
		g_HealthMax[client] = GASMAN_HEALTH;
		g_fDamageScale[client] = 100.0 / GASMAN_HEALTH;
		
		g_ZombieType[client] = GASMAN;
							
		SetEntityModel(client, "models/player/german_gasman.mdl");
		PrintHelp(client, "*You are \x04The GasMan", 0);
		PrintHelp(client, "*You are The GasMan", 3);
		PrintHelp(client, "*Use \x04+ATTACK2\x01 (or \x04Right Click\x01) to Gas", 0);
		PrintHelp(client, "*Pick up \x04Ammo Boxes\x01 to increase number of Gas Bombs", 0);
		
		SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", ZOMBIESPEED);
		
		g_bCanGasBomb[client] = true;
		g_iNumGasBombs[client] = 5;
		if (g_bIsSupporter[client])
			g_iNumGasBombs[client] = 10;
		else if (g_IsMember[client] > 0)
			g_iNumGasBombs[client] = 8;
		
		CreateTimer(0.1, GiveZombieWeapon, client, TIMER_FLAG_NO_MAPCHANGE);
	}
	return Plugin_Handled;
}

public Action:SpawnEmo(Handle:timer, any:client)
{
	if (IsClientInGame(client) && IsPlayerAlive(client) && GetClientTeam(client) == AXIS)
	{
		#if DEBUG
			LogToFileEx(g_szLogFileName,"[L4DOD] Player spawned as Emo:%i", client);
		#endif
		
		ResetZombieVariables(client);
		
		g_Health[client] = EMO_HEALTH;
		g_HealthMax[client] = EMO_HEALTH;
		g_fDamageScale[client] = 100.0 / EMO_HEALTH;
			
		g_ZombieType[client] = EMO;
						
		SetEntityModel(client, "models/player/german_emo.mdl");
		PrintHelp(client, "*You are \x04The Emo", 0);
		PrintHelp(client, "*You are The Emo", 3);
		PrintHelp(client, "*Use \x04+ATTACK2\x01 (or \x04Right Click\x01) to Detonate", 0);
		
		SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", ZOMBIESPEED);
		
		g_canDet[client] = true;
		
		CreateTimer(0.1, GiveZombieWeapon, client, TIMER_FLAG_NO_MAPCHANGE);
	}
	return Plugin_Handled;
}

public Action:SpawnAnarchist(Handle:timer, any:client)
{
	if (IsClientInGame(client) && IsPlayerAlive(client) && GetClientTeam(client) == 3)
	{
		#if DEBUG
			LogToFileEx(g_szLogFileName,"[L4DOD] Player spawned as Anarchist:%i", client);
		#endif
		
		ResetZombieVariables(client);
		
		g_Health[client] = ANARCHIST_HEALTH;
		g_HealthMax[client] = ANARCHIST_HEALTH;
		g_fDamageScale[client] = 100.0 / ANARCHIST_HEALTH;
		
		g_ZombieType[client] = ANARCHIST;
							
		SetEntityModel(client, "models/player/techknow/left4dead/hunter.mdl");
		PrintHelp(client, "*You are \x04The Anarchist", 0);
		PrintHelp(client, "*You are The Anarchist", 3);
		PrintHelp(client, "*Use \x04+ATTACK2 \x01 (or \x04Right Click\x01) to launch exploding Skulls", 0);
		PrintHelp(client, "*Pick up \x04Ammo Boxes\x01 to increase number of Skulls", 0);
		
		SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", ZOMBIESPEED);
		
		g_canSkull[client] = true;
		
		g_numSkull[client] = 5;
		if (g_bIsSupporter[client])
			g_numSkull[client] = 10;
		else if (g_IsMember[client] > 0)
			g_numSkull[client] = 7;
		
		CreateTimer(0.1, GiveZombieWeapon, client, TIMER_FLAG_NO_MAPCHANGE);
	}
	return Plugin_Handled;
}

public Action:SpawnHellSpawn(Handle:timer, any:client)
{
	if (IsClientInGame(client) && IsPlayerAlive(client) && GetClientTeam(client) == AXIS)
	{
		#if DEBUG
			LogToFileEx(g_szLogFileName,"[L4DOD] Player spawned as Hell Spawn:%i", client);
		#endif
		
		ResetZombieVariables(client);
		
		g_Health[client] = HELLSPAWN_HEALTH;
		g_HealthMax[client] = HELLSPAWN_HEALTH;
		g_fDamageScale[client] = 100.0 / HELLSPAWN_HEALTH;
		
		g_ZombieType[client] = HELLSPAWN;
							
		SetEntityModel(client, "models/player/russianarmy/zombie/hellknight.mdl");
		PrintHelp(client, "*You are \x04Hell Spawn", 0);
		PrintHelp(client, "*You are Hell Spawn", 3);
		PrintHelp(client, "*Use \x04+ATTACK2 \x01 (or \x04Right Click\x01) to launch exploding Fireballs", 0);
		PrintHelp(client, "*Pick up \x04Ammo Boxes\x01 to increase number of Fireballs", 0);
		
		SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", INFECTEDSPEED);
		
		g_canFireball[client] = true;
		g_numFireball[client] = 5;
		if (g_bIsSupporter[client])
			g_numFireball[client] = 10;
		else if (g_IsMember[client] > 0)
			g_numFireball[client] = 7;
		
		CreateTimer(0.1, GiveZombieWeapon, client, TIMER_FLAG_NO_MAPCHANGE);
	}
	return Plugin_Handled;
}

public Action:SpawnWraith(Handle:timer, any:client)
{
	if (IsClientInGame(client) && IsPlayerAlive(client) && GetClientTeam(client) == AXIS)
	{
		#if DEBUG
			LogToFileEx(g_szLogFileName,"[L4DOD] Player spawned as Wraith:%i", client);
		#endif
	
		ResetZombieVariables(client);
		
		g_Health[client] = WRAITH_HEALTH;
		g_HealthMax[client] = WRAITH_HEALTH;
		g_fDamageScale[client] = 100.0 / WRAITH_HEALTH;
		
		g_ZombieType[client] = WRAITH;
							
		SetEntityModel(client, "models/player/wraith/german_wraith.mdl");
		PrintHelp(client, "*You are \x04The Wraith", 0);
		PrintHelp(client, "*You are The Wraith", 3);
		PrintHelp(client, "*Use \x04+ATTACK2\x01 (or \x04Right Click\x01) to suck health from Allies or give health to Zombies ", 0);
		
		SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", ZOMBIESPEED);
		
		g_canSuck[client] = true;
		
		CreateTimer(0.1, GiveZombieWeapon, client, TIMER_FLAG_NO_MAPCHANGE);
	}
	return Plugin_Handled;
}

public Action:SpawnUNG(Handle:timer, any:client)
{
	if (IsClientInGame(client) && IsPlayerAlive(client) && GetClientTeam(client) == AXIS)
	{
		#if DEBUG
			LogToFileEx(g_szLogFileName,"[L4DOD] Player spawned as UNG:%i", client);
		#endif				
			
		ResetZombieVariables(client);
		
		g_Health[client] = UNG_HEALTH;
		g_HealthMax[client] = UNG_HEALTH;
		g_fDamageScale[client] = 100.0 / UNG_HEALTH;
			
		g_ZombieType[client] = UNG;
						
		SetEntityModel(client, "models/player/german_speedo.mdl");
		PrintHelp(client, "*You are \x04The UNG", 0);
		PrintHelp(client, "*You are The UNG", 3);
		
		SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", UNGSPEED);
		
		CreateTimer(0.1, GiveZombieWeapon, client, TIMER_FLAG_NO_MAPCHANGE);
	}
	return Plugin_Handled;
}

public Action:SpawnSkeleton(Handle:timer, any:client)
{
	if (IsClientInGame(client) && IsPlayerAlive(client) && GetClientTeam(client) == AXIS)
	{
		#if DEBUG
			LogToFileEx(g_szLogFileName,"[L4DOD] Player spawned as Skeleton:%i", client);
		#endif
		
		ResetZombieVariables(client);
		
		g_Health[client] = SKELETON_HEALTH;
		g_HealthMax[client] = SKELETON_HEALTH;
		g_fDamageScale[client] = 100.0 / SKELETON_HEALTH;
			
		g_ZombieType[client] = SKELETON;
		
		SetEntProp(client, Prop_Data, "m_takedamage", 2, 1); 
		
		SetEntityModel(client, "models/player/russianarmy/zombie/bones.mdl");
		PrintHelp(client, "*You are \x04The Skeleton", 0);
		PrintHelp(client, "*You are The Skeleton", 3);
		PrintHelp(client, "*Use your grenades.  Then use \x04+ATTACK2\x01 (or \x04Right Click\x01) to detonate them.", 0);
		
		SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", SKELETONSPEED);
		
		g_canMine[client] = true;
		
		for (new i = 0; i <= 8; i++)
			g_iDroppedMine[client][i] = 0;
			
		g_numMines[client] = 5;
		if (g_bIsSupporter[client])
			g_numMines[client] = 10;
		else if (g_IsMember[client] > 0)
			g_numMines[client] = 8;
		
		CreateTimer(0.1, GiveZombieWeapon, client, TIMER_FLAG_NO_MAPCHANGE);
	}
	return Plugin_Handled;
}

public Action:SpawnZombie(Handle:timer, any:client)
{
	if (IsClientInGame(client) && IsPlayerAlive(client) && GetClientTeam(client) == AXIS)
	{
		#if DEBUG
			LogToFileEx(g_szLogFileName,"[L4DOD] Player spawned as Zombie:%i", client);
		#endif
		
		ResetZombieVariables(client);
		
		g_Health[client] = ZOMBIE_HEALTH;
		g_HealthMax[client] = ZOMBIE_HEALTH;
		g_fDamageScale[client] = 100.0 / ZOMBIE_HEALTH;
			
		g_ZombieType[client] = ZOMBIE;
		
		SetEntityModel(client, "models/player/german_zombie.mdl");
		PrintHelp(client, "*You are \x04A Zombie", 0);
		PrintHelp(client, "*Use the menu to select other Zombies", 3);
		
		SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", ZOMBIESPEED);
		
		CreateTimer(0.1, GiveZombieWeapon, client, TIMER_FLAG_NO_MAPCHANGE);
	}
	return Plugin_Handled;
}

public Action:HideOverlay(Handle:timer, any:client)
{
	g_showOverlay[client] = false;
	return Plugin_Handled;
}

public Action:SpawnCheck(Handle:timer, any:client)
{
	if (g_bRoundOver)
	{
		hSpawnCheckTimer = INVALID_HANDLE;
		return Plugin_Stop;
	}
	
	new Float:loc[3];
	
	if (GetConVarInt(hL4DGameType) == 0 || GetConVarInt(hL4DGameType) == 2)
	{
		for (new i=1; i <= MaxClients; i++)
		{
			if (IsClientInGame(i) && !IsFakeClient(i) && IsPlayerAlive(i) && GetClientTeam(i) == AXIS)
			{
				GetClientAbsOrigin(i, loc);
				
				//Every five secs add...
				if (g_mapType == 0 && CheckLocationNearAlliedSpawn(loc, 400.0))
					g_iTimeAtSpawn[i]++;
				
				if (g_iTimeAtSpawn[i] > 1)
				{
					SetEntProp(i, Prop_Data, "m_takedamage", 2, 1); 
										
					GetClientAbsOrigin(i, loc);
					if (CheckLocationNearAlliedSpawn(loc, GetConVarFloat(hL4DSpawnDistance)))
					{						
						if (g_Invisible[i])
						{
							SetAlpha(i, 255);
							g_ShowSprite[i] = true;
							g_Invisible[i] = false;
														
							PlaySound(i, false);
							
							CreateTimer(5.0, BeginVisibilityHUD, i, TIMER_FLAG_NO_MAPCHANGE);
							CreateTimer(1.0, AllowWeapon, i, TIMER_FLAG_NO_MAPCHANGE);
						}
						
						new Handle:pack;			
						CreateDataTimer(0.3, DealDamage, pack, TIMER_FLAG_NO_MAPCHANGE);
						WritePackCell(pack, i);
						WritePackCell(pack, i);
						WritePackCell(pack, 5);
						WritePackCell(pack, DMG_ACID);
						WritePackString(pack, "weapon_spawndamage");
					}
				}
			}
		}
	}
	return Plugin_Handled;
}

FlashSpawnLocation(any:client)
{
	if (IsClientInGame(client) && IsPlayerAlive(client))
	{			
		//BeamRingPoint(origin, startradius, endradius, texture, halo, startframe, framerate, life, width, spread, amp, color(rgba), speed, fade)
		TE_SetupBeamRingPoint(g_vecSpawn[client], 10.0, 50.0, BeamSprite, HaloSprite, 0, 120, 1.1, 15.0, 0.5, g_WhiteColour, 10, 0);
		TE_SendToClient(client, 0.0);
	}
}

ResetZombieVariables(any:client)
{
	//Zombie
	g_OnFire[client] = false;		
			
	g_canTP[client] = false;
	g_canVanish[client] = false;
	g_Invisible[client] = false;
	g_canMaster[client] = false;
	g_canSkull[client] = false;
	g_canSmoke[client] = false;
	g_canMine[client] = false;
					
	g_bCanGasBomb[client] = false;
	g_bGasBombExploded[client] = false;
	g_canDet[client] = false;
	g_bCanMakeNoise[client] = true;
	g_canSuck[client] = false;
	g_iSuckCount[client] = 0;
	
	g_invZB[client] = false;
	g_noFire[client] = false;

	g_numSkull[client] = 0;
	g_numMaster[client] = 0;
	g_numTP[client] = 0;
	
	g_SpriteEntity[client] = -1;
	g_minAlpha[client] = 0;
	SetAlpha(client, 255); 
	g_ShowSprite[client] = false;
}