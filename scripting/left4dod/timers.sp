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
 


//####################################### TIMED STUFF ###################################
//10.0 timer
public Action:TenSecond(Handle:timer, any:stuff)
{
	if (g_bRoundOver)
	{
		hTenSecond = INVALID_HANDLE;
		return Plugin_Stop;
	}
	
	CheckForHumans();
	
	for (new i=1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i))
			continue;
						
		if (IsClientObserver(i))
			continue;	
			
		if (!IsPlayerAlive(i))
		{				
			continue;
		}
				
		if (!IsFakeClient(i))
		{
			if (GetClientTeam(i) == ALLIES)
			{
				if (g_isInfected[i])
				{
					new Handle:pack;			
					CreateDataTimer(0.1, DealDamage, pack, TIMER_FLAG_NO_MAPCHANGE);
					WritePackCell(pack, i);
					WritePackCell(pack, i);
					WritePackCell(pack, 40);
					WritePackCell(pack, DMG_POISON);
					WritePackString(pack, "weapon_infected");
				}
			}
		}
	}
	/*
	if (GetAxisTeamNumber() > 2 && GetConVarInt(hAT) == 1)
	{
		ServerCommand("sv_alltalk 0");
		PrintCenterTextAll("All Talk is now off");
	}
	else if (GetAxisTeamNumber() <= 2 && GetConVarInt(hAT) == 0)
	{
		ServerCommand("sv_alltalk 1");
		PrintCenterTextAll("All Talk is now on");
	}
	*/
	
	return Plugin_Handled;
}

//1.0 timer
public Action:OneSecond(Handle:timer, any:stuff)
{
	if (g_bRoundOver)
	{
		hOneSecond = INVALID_HANDLE;
		return Plugin_Stop;
	}
		
	//Check if Zombies have primary weapons
	for (new i=1; i <= MaxClients; i++)
	{
		//Check Axis have no weapons
		if (g_checkWeapons[i] && IsClientInGame(i) && IsPlayerAlive(i) && GetClientTeam(i) == AXIS)
		{
			new weaponslot = GetPlayerWeaponSlot(i, 0);

			if (weaponslot != -1)
			{	
				decl String:Weapon[64];
				GetClientWeapon(i, Weapon, sizeof(Weapon));
				
				if(StrEqual(Weapon, "weapon_mg42") || StrEqual(Weapon, "weapon_30cal") || StrEqual(Weapon, "weapon_garand") 
				|| StrEqual(Weapon, "weapon_k98") || StrEqual(Weapon, "weapon_thompson") 
				|| StrEqual(Weapon, "weapon_mp40") || StrEqual(Weapon, "weapon_bar") || StrEqual(Weapon, "weapon_mp44") 
				|| StrEqual(Weapon, "weapon_bazooka") || StrEqual(Weapon, "weapon_k98_scoped") || StrEqual(Weapon, "weapon_spring"))
				{
					if (RemovePlayerItem(i, weaponslot))
						RemoveEdict(weaponslot);
					
					if (g_ZombieType[i] == INFECTEDONE)	
						FakeClientCommand(i, "use weapon_amerknife");
					else
						FakeClientCommand(i, "use weapon_spade");
				}
			}
		}
	}
		
	for (new i=1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i))
			continue;
						
		if (IsClientObserver(i))
			continue;	
			
		if (!IsPlayerAlive(i))
		{				
			continue;
		}
				
		if (!IsFakeClient(i))
		{
			//Blink where the player spawned
			FlashSpawnLocation(i);
			
			if (GetClientTeam(i) == ALLIES)
			{			
				//Keep the flashlight on 			
				new effect = GetEntProp(i, Prop_Send, "m_fEffects");
				if (effect & 4)
					g_useFL[i] = true;
				else
					g_useFL[i] = false;
					
				//Hooch effect
				if (g_hasHooch[i] || g_hasAdrenaline[i])
					SetEntPropFloat(i, Prop_Send, "m_flStamina", 100.0);
					
				new weaponslot;
				weaponslot = GetPlayerWeaponSlot(i, 4);
									
				if (g_airstrike[i] && g_ShowOverlays[i])
				{
					if (g_isIgnored[i])
						ClientCommand(i, "r_screenoverlay left4dod/overlay_radio_zb"); 
					else
						ClientCommand(i, "r_screenoverlay left4dod/overlay_radio");
				}
				else if (g_Shield[i] && g_ShowOverlays[i])
				{
					if (g_isIgnored[i])
						ClientCommand(i, "r_screenoverlay left4dod/overlay_shield_zb"); 
					else
						ClientCommand(i, "r_screenoverlay left4dod/overlay_shield");
				}
				else if (weaponslot != -1 && g_ShowOverlays[i])
				{
					if (g_isIgnored[i])
						ClientCommand(i, "r_screenoverlay left4dod/overlay_tnt_zb"); 
					else
						ClientCommand(i, "r_screenoverlay left4dod/overlay_tnt");
				}
				else
				{
					if (g_isIgnored[i])
						ClientCommand(i, "r_screenoverlay left4dod/zvision002"); 
					else
						ClientCommand(i, "r_screenoverlay 0");
				}
			}
			else if (GetClientTeam(i) == AXIS)
			{					
				if (g_showOverlay[i])
				{				
					switch (g_ZombieType[i])
					{
						case 0:
							ClientCommand(i, "r_screenoverlay left4dod/overlay_witch_01a");
						
						case 1:
							ClientCommand(i, "r_screenoverlay left4dod/overlay_grey_01a"); 
						
						case 2:
							ClientCommand(i, "r_screenoverlay left4dod/overlay_gas_01a"); 
	
						case 3:
							ClientCommand(i, "r_screenoverlay left4dod/overlay_io_01a"); 
						
						case 4:
							ClientCommand(i, "r_screenoverlay left4dod/overlay_emo_01a"); 
						
						case 5:
							ClientCommand(i, "r_screenoverlay left4dod/overlay_anarchist_01a"); 
						
						case 7:
							ClientCommand(i, "r_screenoverlay left4dod/overlay_wraith_01a");

						default:
							ClientCommand(i, "r_screenoverlay debug/yuv");
					}
				}
				else if (g_Invisible[i])
				{
					ClientCommand(i, "r_screenoverlay debug/yuv");
				}
				else
				{
					switch (g_ZombieType[i])
					{
						case 0:
							ClientCommand(i, "r_screenoverlay left4dod/zvision002");
						
						case 1:
							ClientCommand(i, "r_screenoverlay left4dod/zvision002"); 
						
						case 2:
							ClientCommand(i, "r_screenoverlay left4dod/zvision002"); 
	
						case 3:
							ClientCommand(i, "r_screenoverlay left4dod/zvision"); 
						
						case 4:
							ClientCommand(i, "r_screenoverlay left4dod/zvision"); 
						
						case 5:
							ClientCommand(i, "r_screenoverlay left4dod/zvision002"); 
						
						case 6:
							ClientCommand(i, "r_screenoverlay left4dod/zvision"); 
						
						case 7:
							ClientCommand(i, "r_screenoverlay left4dod/zvision002");
						
						case 8:
							ClientCommand(i, "r_screenoverlay left4dod/zvision002");
						
						case 9:
							ClientCommand(i, "r_screenoverlay left4dod/zvision002");

						default:
							ClientCommand(i, "r_screenoverlay left4dod/zvision"); 
					}
				}
				
				if (g_Health[i] < g_HealthMax[i])
				{
					g_Health[i] += 3;
					SetHealth(i, g_Health[i]);
				}
			}
		}
		else
		{
			SetEntPropFloat(i, Prop_Send, "m_flStamina", 100.0);
			
			if (g_Health[i] < g_HealthMax[i] && g_ZombieType[i] > 0)
			{
				g_Health[i] += 2;
				SetHealth(i, g_Health[i]);
			}
		}
	}
	return Plugin_Handled;
}

// 0.1 timer
public Action:TenthSecond(Handle:timer, any:client)
{
	if (g_bRoundOver)
	{
		hTenthSecond = INVALID_HANDLE;
		return Plugin_Stop;
	}
		
	for (new i=1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i) && !IsFakeClient(i) && IsPlayerAlive(i))
		{
			if (GetClientTeam(i) == AXIS)
			{
				//Stamina
				if (g_ZombieType[i] == INFECTEDONE || g_ZombieType[i] == WITCH 
				     || g_ZombieType[i] == EMO || g_ZombieType[i] == ANARCHIST 
					 || g_ZombieType[i] == GREYDUDE || g_ZombieType[i] == GASMAN 
					 || g_ZombieType[i] == WRAITH || g_ZombieType[i] == SKELETON
					 || g_ZombieType[i] == HELLSPAWN)
				{
					if (IsValidEntity(i))
					{
						SetEntPropFloat(i, Prop_Send, "m_flStamina", 100.0);
						SetEntPropFloat(i, Prop_Send, "m_flSlowedUntilTime", 0.0);
					}
				}
				
				//Distance Check
				if (g_bCanMakeNoise[i])
				{
					if (g_ZombieType[i] == EMO && GetAlliesNearby(i, 1000.0) && GetClientTeam(i) == AXIS)
					{
						new reallyrandom = GetRandomInt(1,3);
						
						switch (reallyrandom)
						{
							case 1:
								EmitSoundToAll("npc/fast_zombie/fz_alert_far1.wav", i);
							
							case 2:
								EmitSoundToAll("npc/zombie_poison/pz_call1.wav", i);
								
							case 3:
								EmitSoundToAll("npc/fast_zombie/fz_frenzy1.wav", i);
						}
						
						g_bCanMakeNoise[i] = false;
						CreateTimer(3.0, AllowMakeNoise, i, TIMER_FLAG_NO_MAPCHANGE);
					}
				}
			}
			else if (GetClientTeam(i) == ALLIES)
			{
				//Hooch effect
				if (g_hasHooch[i] || g_hasAdrenaline[i])
				{
					SetEntPropFloat(i, Prop_Send, "m_flStamina", 100.0);
				}
				
				if (GetEntProp(i, Prop_Send, "m_iPlayerClass") == 3 || g_AllowedSniper[i])
				{
					if (GetEntProp(i, Prop_Send, "m_iFOV") == 20)
					{
						g_bZoomed[i] = true;
					}
					else
					{
						g_bZoomed[i] = false;
					}
				}
			}
		}
	}
	
	for (new flag = 0; flag < g_iFlagNumber; flag++)
	{
		g_fNumberAlliesAtFlag[flag] = 0.0;
		for (new i= 1; i <= MaxClients; i++)
		{
			if (IsClientInGame(i) && GetClientTeam(i) == ALLIES && g_atFlag[flag][i])
				g_fNumberAlliesAtFlag[flag] += 1.5;
		}
		
		g_NumberAxisAtFlag[flag] = 0;
		for (new i= 1; i <= MaxClients; i++)
		{
			if (IsClientInGame(i) && GetClientTeam(i) == AXIS && g_atFlag[flag][i])
				g_NumberAxisAtFlag[flag] += 1;
		}
	}
	
	// Zombie Blood effect
	// Allied Sprite

	new Float:SpriteVector[3], Float:ViewerVector[3];
		
	for (new i=1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i) && IsPlayerAlive(i) && !IsClientObserver(i))
		{	
			//Allied team with ESP?
			if (GetClientTeam(i) == ALLIES && (g_isIgnored[i] || g_bZoomed[i]))
			{
				GetClientEyePosition(i, ViewerVector);
				
				for (new k=1; k <= MaxClients; k++)
				{
					if (IsClientInGame(k) && IsPlayerAlive(k) && GetClientTeam(k) == AXIS && !g_Invisible[k] && !g_invZB[k])
					{
						new Float:ClientOrigin[3];
						GetClientAbsOrigin(k, ClientOrigin);
						ClientOrigin[2] += 36;
						
						GetClientEyePosition(k, SpriteVector);
						
						new bool:eyes = IsPointVisible(SpriteVector, ViewerVector);
						new bool:feet = IsPointVisible(ClientOrigin, ViewerVector);
																				
						if (!eyes && !feet)
						{								
							TE_SetupGlowSprite(ClientOrigin, g_AlliedSpriteModel75, 0.1, 1.0, 255) ;
							TE_SendToClient(i, 0.0);
						}
						else if (!eyes || !feet)
						{								
							TE_SetupGlowSprite(ClientOrigin, g_AlliedSpriteModel50, 0.1, 1.0, 255) ;
							TE_SendToClient(i, 0.0);
						}
						else if (GetVectorDistance(SpriteVector, ViewerVector) > 400.0)
						{
							TE_SetupGlowSprite(ClientOrigin, g_AlliedSpriteModel, 0.1, 1.0, 255) ;
							TE_SendToClient(i, 0.0);
						}
					}
				}
			}
			else if (GetClientTeam(i) == AXIS && !IsFakeClient(i) && (GetConVarInt(hL4DGameType) == 0 || GetConVarInt(hL4DGameType) == 2))
			{
				GetClientEyePosition(i, ViewerVector);
														
				for (new k=1; k <= MaxClients; k++)
				{
					if (IsClientInGame(k) && IsPlayerAlive(k))
					{
						if (GetClientTeam(k) == ALLIES && !g_isIgnored[k])
						{
							new Float:ClientOrigin[3];
							GetClientAbsOrigin(k, ClientOrigin);
							GetClientEyePosition(k, SpriteVector);
							ClientOrigin[2] += 36;
							
							//Find all Allied players and place a TE on them
							if (!IsPointVisible(SpriteVector, ViewerVector) || GetVectorDistance(SpriteVector, ViewerVector) > 400.0)
							{
								new ClientHealth = g_Health[k];
								new Sprite;
								
								if (ClientHealth >= 250)
									Sprite = g_AlliedSpriteModel400;
								else if (ClientHealth > 149 && ClientHealth < 250)
									Sprite = g_AlliedSpriteModel200;
								else if (ClientHealth > 49 && ClientHealth < 150)
									Sprite = g_AlliedSpriteModel;
								else if (ClientHealth < 50 && ClientHealth > 25)
									Sprite = g_AlliedSpriteModel50;
								else if (ClientHealth <= 25)
									Sprite = g_AlliedSpriteModel75;
									
								TE_SetupGlowSprite(ClientOrigin, Sprite, 0.1, 1.0, 255) ;
								TE_SendToClient(i, 0.0);
							}
						}
						else if (GetClientTeam(k) == AXIS && !IsFakeClient(k))
						{
							new Float:ClientOrigin[3];
							GetClientAbsOrigin(k, ClientOrigin);
							GetClientEyePosition(k, SpriteVector);
							ClientOrigin[2] += 36;
							
							if (!IsPointVisible(SpriteVector, ViewerVector) || GetVectorDistance(SpriteVector, ViewerVector) > 400.0)
							{									
								TE_SetupGlowSprite(ClientOrigin, g_AxisHumanSpriteModel, 0.1, 1.0, 255) ;
								TE_SendToClient(i, 0.0);
							}
						}
					}
				}
			}
		}
	}
		
	return Plugin_Handled;
}

public Action:ResetFound(Handle:timer, any:client)
{
	g_found[client] = false;
	return Plugin_Handled;
}