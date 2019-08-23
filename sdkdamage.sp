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
// ################################################################################

public Action:OnTakeDamage(victim, &attacker, &inflictor, &Float:fDamage, &damagetype, &weapon, Float:damageForce[3], Float:damagePosition[3])
{	
	//Scale the damage
	fDamage *= g_fDamageScale[victim];
	
	//Player on Player damage
	if ((victim > 0 && victim < MaxClients+1))
	{			
		if (attacker > 0 && attacker < MaxClients+1)
		{
			//AXIS v AXIS 
			if (GetClientTeam(attacker) == AXIS && GetClientTeam(victim) == AXIS)
			{
				if (attacker != victim)
				{
					fDamage *= 0.0;
					return Plugin_Changed;
				}
			}
			
			//ALLIES v ALLIES  
			else if (GetClientTeam(attacker) == ALLIES && GetClientTeam(victim) == ALLIES)
			{
				if (victim != attacker)
				{				
					new Handle:pack;			
					CreateDataTimer(0.1, DealDamage, pack, TIMER_FLAG_NO_MAPCHANGE);
					WritePackCell(pack, attacker);
					WritePackCell(pack, 0);
					WritePackCell(pack, 5);
					WritePackCell(pack, DMG_SLASH);
					WritePackString(pack, "weapon_amerknife");
					
					//LogToGame("\"%L\" triggered \"TeamWound\"", attacker);
										
					fDamage *= 0.0;
					return Plugin_Changed;
				}
			}
						
			// AXIS VICTIMS
			else if (GetClientTeam(attacker) == ALLIES && GetClientTeam(victim) == AXIS)
			{		
				//Reduce player damage if teamkilling is above normal.
				if (g_tkAmount[attacker] > 0)
				{
					fDamage /= g_tkAmount[attacker];
				}
						
				decl String:Weapon[32];
				GetClientWeapon(attacker, Weapon, sizeof(Weapon));
				
				new class = GetEntProp(attacker, Prop_Send, "m_iPlayerClass");
				
				if (g_ZombieType[victim] == SKELETON || g_ZombieType[victim] == GASMAN)
				{
					if (IsFakeClient(victim))
					{
						if (!g_PauseMovement[victim] && GetRandomInt(1,10) > 3)
						{
							g_PauseMovement[victim] = true;
							CreateTimer(0.8, Pause, victim, TIMER_FLAG_NO_MAPCHANGE);
							ForceJump(victim, 450.0, 0.0);
							AttachParticle(victim, "rockettrail", 2.0);
						}
					}
				}	
				else if (g_ZombieType[victim] == WITCH)
				{
					if (IsFakeClient(victim))
					{
						if (StrEqual(Weapon, "weapon_mg42") || StrEqual(Weapon, "weapon_30cal"))
						{
							g_canTP[victim] = true;
							RelocateBotBehindPlayer(victim);
						}
						else
						{
							if (!g_PauseMovement[victim] && GetRandomInt(1,10) > 6)
							{
								g_PauseMovement[victim] = true;
								CreateTimer(0.8, Pause, victim, TIMER_FLAG_NO_MAPCHANGE);
								ForceSide(victim, 250.0, 0.0);
							}
						}
					}
				}
				else if (g_ZombieType[victim] == WRAITH || g_ZombieType[victim] == EMO || g_ZombieType[victim] == GREYDUDE || g_ZombieType[victim] == INFECTEDONE || g_ZombieType[victim] == ANARCHIST)
				{
					if (IsFakeClient(victim))
					{
						if (!g_PauseMovement[victim] && GetRandomInt(1,10) > 5)
						{
							g_PauseMovement[victim] = true;
							CreateTimer(0.8, Pause, victim, TIMER_FLAG_NO_MAPCHANGE);
							ForceSide(victim, GetRandomFloat(200.0, 350.0), 0.0);
						}
					}
				}
				
				//If Zombies are in spawn they take no fDamage from nades
				if(StrEqual(Weapon, "weapon_frag_us") || StrEqual(Weapon, "weapon_frag_ger")
				|| StrEqual(Weapon, "weapon_riflegren_us") || StrEqual(Weapon, "weapon_riflegren_ger")
				|| StrEqual(Weapon, "weapon_panzerschreck") || StrEqual(Weapon, "weapon_bazooka"))
				{
					new Float:victimpos[3];
					GetClientAbsOrigin(victim, victimpos);
					if (CheckLocationNearAxisSpawn(victimpos, 600.0))
					{	
						fDamage *= 0.0;
						return Plugin_Changed;
					}	
				}
				
				else if(StrEqual(Weapon, "weapon_mg42") || StrEqual(Weapon, "weapon_30cal"))
				{
					if (class != MG && !g_AllowedMG[attacker])
					{
						fDamage *= 0.0;
						return Plugin_Changed;
					}
				}
				
				else if(StrEqual(Weapon, "weapon_k98_scoped") || StrEqual(Weapon, "weapon_spring"))
				{
					if (class != SNIPER && !g_AllowedSniper[attacker])
					{
						fDamage *= 0.0;
						return Plugin_Changed;
					}
					else
					{
						fDamage *= 2.0;
						return Plugin_Changed;
					}
				}
				
				else if(StrEqual(Weapon, "weapon_bazooka") || StrEqual(Weapon, "weapon_pschreck"))
				{
					if (class != ROCKET && !g_AllowedRocket[attacker])
					{
						fDamage *= 0.0;
						return Plugin_Changed;
					}
					else
					{
						fDamage *= 2.0;
						return Plugin_Changed;
					}
				}
				
				else if(StrEqual(Weapon, "weapon_amerknife") || StrEqual(Weapon, "weapon_spade"))
				{
					if (GetEntProp(attacker, Prop_Send, "m_bProne") == 1 || GetEntProp(attacker, Prop_Send, "m_bDucked") == 1 
						|| GetEntProp(attacker, Prop_Send, "m_bDucking") == 1)
					{
							fDamage *= 0.2;
							return Plugin_Changed;
					}
				}
			}
			
			//ALLIES VICTIMS
			else if (GetClientTeam(attacker) == AXIS && GetClientTeam(victim) == ALLIES)
			{
				decl String:Weapon[64];
				GetClientWeapon(attacker, Weapon, sizeof(Weapon));
				
				if(StrEqual(Weapon, "weapon_amerknife") || StrEqual(Weapon, "weapon_spade"))
				{
					//Backstab?
					new Float:attacker_pos[3];
					new Float:victim_pos[3];          
					new Float:victim_fwd[3];
					new Float:victim_eyes[3];
					new Float:angle_diff;
					new Float:angle_vec[3];
					GetClientAbsOrigin(attacker, attacker_pos);
					GetClientAbsOrigin(victim, victim_pos);
					attacker_pos[2] = victim_pos[2];

					GetClientEyeAngles(victim, victim_eyes);
					GetAngleVectors(victim_eyes, victim_fwd, NULL_VECTOR, NULL_VECTOR);
					MakeVectorFromPoints(victim_pos, attacker_pos, angle_vec);
					NormalizeVector(angle_vec, angle_vec);
					angle_diff = GetVectorDotProduct(victim_fwd, angle_vec);
					
					if (angle_diff < 0.0)
					{
						if (IsFakeClient(attacker))
						{
							fDamage *= 1.0;
							return Plugin_Changed;

						}
						else
						{
							fDamage *= 1.5;
							return Plugin_Changed;
						}
					} 	
					
					if (g_ZombieType[attacker] == UNG)
					{
						fDamage *= 16.0;
						ScaleVector(damageForce, 10.0);
						return Plugin_Changed;
					}
					
					else if (g_ZombieType[attacker] == INFECTEDONE && !g_isInfected[victim])
					{
						fDamage *= 0.8;
						g_isInfected[victim] = true;
						SetEntityModel(victim, "models/player/german_traitor.mdl");
						
						if (g_Hints[victim])
							PrintHelp(victim, "*You have been {green}infected{yellow} - you will slowly {green}lose health {yellow}until you get a {fullred}Health Pack or Zombie Blood", 0);
						return Plugin_Changed;
					}
					
					else
					{
						if (IsFakeClient(attacker))
						{
							fDamage *= 0.4;
							return Plugin_Changed;
						}
						else
						{
							fDamage *= 1.0;
							return Plugin_Changed;
						}
					}
				}
				else if(StrEqual(Weapon, "weapon_mg42") || StrEqual(Weapon, "weapon_30cal") 
				|| StrEqual(Weapon, "weapon_garand") 	|| StrEqual(Weapon, "weapon_k98") 
				|| StrEqual(Weapon, "weapon_thompson") || StrEqual(Weapon, "weapon_mp40") 
				|| StrEqual(Weapon, "weapon_bar") || StrEqual(Weapon, "weapon_mp44") 
				|| StrEqual(Weapon, "weapon_bazooka") || StrEqual(Weapon, "weapon_pschreck")
				|| StrEqual(Weapon, "weapon_k98_scoped") || StrEqual(Weapon, "weapon_spring"))
				{
					fDamage *= 0.0;
					return Plugin_Changed;
				}
				
				else if (StrEqual(Weapon, "env_explosion"))
				{
					new Float:victimpos[3];
					GetClientAbsOrigin(victim, victimpos);
					if (CheckLocationNearAlliedSpawn(victimpos, 300.0))
					{	
						fDamage *= 0.0;
						return Plugin_Changed;
					}	
				}
				
				else if (StrEqual(Weapon, "weapon_gasbomb"))
				{
					new Float:victimpos[3];
					GetClientAbsOrigin(victim, victimpos);
					if (CheckLocationNearAlliedSpawn(victimpos, 300.0))
					{	
						fDamage *= 0.0;
						return Plugin_Changed;
					}	
				}
				
				if (!g_canUseWeapon[attacker])
				{
					fDamage *= 0.0;
					return Plugin_Changed;
				}
			}
			
			//########################### APPLY THE DAMAGE ######################################
			new Float:newHealth = float(g_Health[victim]) - fDamage;
			 // Is the player supposed to die?
			if (newHealth <= 0.0)
			{
					// Set the damage required to kill the player.
					fDamage = float(GetClientHealth(victim));
				   
					return Plugin_Changed;
			}
		   
			// Will the health be rounded down to zero?
			if (GetClientHealth(victim) - RoundFloat(fDamage) <= 0)
			{
					g_Health[victim] = RoundFloat(newHealth);
				   
					return Plugin_Handled;
			}
			
			SetHealth(victim, g_Health[victim]);
			g_Health[victim] = RoundFloat(newHealth);
			return Plugin_Changed;
		}
	
		else if (damagetype & DMG_FALL == DMG_FALL)
		{
			if (GetClientTeam(victim) == AXIS)
				return Plugin_Handled;
		}
	}
	return Plugin_Continue;
}

SetHealth(client, health)
{
	if (client > 0 && IsClientInGame(client) && IsPlayerAlive(client) && health > 0)
	{
		if (health > g_HealthMax[client])
			health = g_HealthMax[client];
			
		SetEntityHealth(client, health * 100 / g_HealthMax[client]);
		g_Health[client] = health;
	}
}


// #################################### DAMAGE ROUTINES ##########################################################################
// SDKHooks_TakeDamage(entity, inflictor, attacker, Float:damage, damageType=DMG_GENERIC, weapon=-1, const Float:damageForce[3]=NULL_VECTOR, const Float:damagePosition[3]=NULL_VECTOR);

//DealDamage(victim, damage, attacker=0, dmg_type=DMG_GENERIC, String:weapon[]="")
public Action:DealDamage(Handle:timer, Handle:pack)
{
	ResetPack(pack);
	new String:weapon[64];
	
	new victim = ReadPackCell(pack);
	new attacker = ReadPackCell(pack);
	new damage = ReadPackCell(pack);
	new dmg_type = ReadPackCell(pack);
	ReadPackString(pack, weapon, sizeof(weapon));
	
	new PointHurt = CreateEntityByName("point_hurt");
	if (PointHurt != -1)
	{
		DispatchKeyValue(PointHurt,"DamageTarget","hurtme");
		DispatchSpawn(PointHurt);
	}
	
	if (victim > 0 && victim < 33 
		&& attacker > 0 && attacker < 33
		&& IsClientInGame(victim) && IsPlayerAlive(victim) 
		&& IsClientInGame(attacker)
		&& damage > 0)
	{
		new String:dmg_str[16];
		IntToString(damage,dmg_str,16);
		new String:dmg_type_str[32];
		IntToString(dmg_type,dmg_type_str,32);
				
		if(IsValidEdict(PointHurt))
		{
			DispatchKeyValue(victim,"targetname","hurtme");
			DispatchKeyValue(PointHurt,"Damage",dmg_str);
			DispatchKeyValue(PointHurt,"DamageType",dmg_type_str);
			
			if(!StrEqual(weapon,""))
				DispatchKeyValue(PointHurt,"classname",weapon);
			else
				DispatchKeyValue(PointHurt,"classname","point_hurt");
				
			AcceptEntityInput(PointHurt,"Hurt",(attacker>0)?attacker:-1);
			
			DispatchKeyValue(victim,"targetname","donthurtme");
			
			AcceptEntityInput(PointHurt, "Kill");
		}
	}
	return Plugin_Handled;
}

public Action:Pause(Handle:timer,any:client)
{
	if (IsClientInGame(client)) 
	{
		g_PauseMovement[client] = false;
	}
	
	return Plugin_Handled;
}