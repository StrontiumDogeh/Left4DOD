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

public Action:WeaponEvent(Handle:event, const String:name[], bool:dontBroadcast)
 /* WEAPON NUMBERS
 1 "weapon_amerknife"  2 "weapon_spade"  3 "weapon_colt"  4 "weapon_p38"  5 "weapon_c96" 6 "weapon_garand"
 8 "weapon_k98"  9 "weapon_spring"  10 "weapon_k98_scoped"  11 "weapon_thompson"  12 "weapon_mp40"  13 "weapon_mp44"  14 "weapon_bar"
 17 "weapon_bazooka"  18 "weapon_pschreck" 19 "weapon_frag_us" 20 "weapon_frag_ger"  37 "bar single shot" 38 "mp44 single shot" 35 "weapon_30cal" 36 "weapon_mg42"
 25 "weapon_riflegren_us"  26 "weapon_riflegren_ger"
 29 "weapon_punch_us"
30 "weapon_punch_ger"
 */

 /* SLOTS
[0] garand-1 k98-1 spring-1 k98_scoped-1 thompson-1 mp40-1 mp44-1 bar-1 30cal-1 mg42-1 bazooka-1 pschreck-1
[1] colt-2 p38-2 c96-2 m1carbine-2
[2] amerknife-3 spade-3 smoke_us-3 smoke_ger-3
[3] frag_us-4 frag_ger-4 riflegren_us-4 riflegren_ger-4
*/
{
	if (GetConVarInt(hL4DOn))
	{
		new attacker = GetClientOfUserId(GetEventInt(event, "attacker"));

		if (!IsFakeClient(attacker))
		{
			// Was a grenade thrown?
			new weapon = GetEventInt(event, "weapon");
			new ent = -1;

			//American smoke nade
			if (weapon == 23)
			{
				while ((ent = FindEntityByClassname(ent, "grenade_smoke_us")) != -1)
				{
					if (IsValidEntity(ent))
					{
						TE_SetupBeamFollow(ent, BeamSprite, 0, Float:6.0, Float:10.0, Float:10.0, 5, g_AlliesColour);
						TE_SendToAll();

						if (GetEntPropEnt(ent, Prop_Send, "m_hThrower") == attacker)
						{
							g_Molotov[attacker] = ent;
							CreateTimer(3.0, Fire, ent, TIMER_FLAG_NO_MAPCHANGE);
						}
					}
				}
			}

			else if (weapon == 17)
			{
				ent = -1;
				while ((ent = FindEntityByClassname(ent, "rocket_bazooka")) != -1)
				{
					if (IsValidEntity(ent))
					{
						TE_SetupBeamFollow(ent, BeamSprite, 0, Float:5.0, Float:10.0, Float:10.0, 5, g_AlliesColour);
						TE_SendToAll();

						if (GetConVarBool(hL4DFright))
						{
							SetEntityModel(ent, "models/models_kit/hallo_pumpkin_s.mdl");
							SetEntProp(ent, Prop_Send, "m_clrRender", -1);
						}
					}
				}
			}

			else if (weapon == 18)
			{
				ent = -1;
				while ((ent = FindEntityByClassname(ent, "rocket_pschreck")) != -1)
				{
					if (IsValidEntity(ent))
					{
						TE_SetupBeamFollow(ent, BeamSprite, 0, Float:5.0, Float:10.0, Float:10.0, 5, g_AlliesColour);
						TE_SendToAll();

						if (GetConVarBool(hL4DFright))
						{
							SetEntityModel(ent, "models/models_kit/hallo_pumpkin_s.mdl");
							SetEntProp(ent, Prop_Send, "m_clrRender", -1);
						}
					}
				}
			}

			else if (weapon == 19)
			{
				ent = -1;
				while ((ent = FindEntityByClassname(ent, "grenade_frag_us")) != -1)
				{
					if (IsValidEntity(ent))
					{
						//stock TE_SetupBeamFollow(EntIndex, ModelIndex, HaloIndex, Float:Life, Float:Width, Float:EndWidth, FadeLength, const Color[4])

						TE_SetupBeamFollow(ent, BeamSprite, 0, Float:5.0, Float:10.0, Float:10.0, 5, g_AlliesColour);
						TE_SendToAll();

						if (GetConVarBool(hL4DFright))
						{
								SetEntityModel(ent, "models/gibs/hgibs.mdl");
								SetEntProp(ent, Prop_Send, "m_clrRender", -1);
						}
						else
						{
							if (GetEntPropEnt(ent, Prop_Send, "m_hThrower") == attacker && g_bIsSupporter[attacker])
							{
								SetEntityModel(ent, "models/gibs/hgibs.mdl");
								SetEntProp(ent, Prop_Send, "m_clrRender", -1);
							}
						}
					}
				}
			}

			else if (weapon == 20)
			{
				ent = -1;
				while ((ent = FindEntityByClassname(ent, "grenade_frag_ger")) != -1)
				{
					if (IsValidEntity(ent))
					{
						//stock TE_SetupBeamFollow(EntIndex, ModelIndex, HaloIndex, Float:Life, Float:Width, Float:EndWidth, FadeLength, const Color[4])
						new owner = GetEntPropEnt(ent, Prop_Send, "m_hThrower");
						if (GetClientTeam(owner) == ALLIES)
						{
							TE_SetupBeamFollow(ent, BeamSprite, 0, Float:5.0, Float:10.0, Float:10.0, 5, g_AlliesColour);
							TE_SendToAll();

							if (GetConVarBool(hL4DFright))
							{
								SetEntityModel(ent, "models/gibs/hgibs.mdl");
								SetEntProp(ent, Prop_Send, "m_clrRender", -1);
							}
							else
							{
								if (owner == attacker && g_bIsSupporter[attacker])
								{
									SetEntityModel(ent, "models/gibs/hgibs.mdl");
									SetEntProp(ent, Prop_Send, "m_clrRender", -1);
								}
							}
						}
						else if (GetClientTeam(owner) == AXIS)
						{

							if (owner == attacker && g_ZombieType[attacker] == SKELETON)
							{
								TE_SetupBeamFollow(ent, BeamSprite, 0, Float:5.0, Float:10.0, Float:10.0, 5, g_AxisColour);
								TE_SendToAll();

								SetEntityModel(ent, "models/weapons/w_bugbait.mdl");
								SetEntProp(ent, Prop_Send, "m_clrRender", -1);

								new Handle:pack;
								CreateDataTimer(2.5, ReplaceNade, pack, TIMER_FLAG_NO_MAPCHANGE);
								WritePackCell(pack, attacker);
								WritePackCell(pack, ent);

							}
						}
					}
				}
			}

			else if (weapon == 25)
			{
				ent = -1;
				while ((ent = FindEntityByClassname(ent, "grenade_riflegren_us")) != -1)
				{
					if (IsValidEntity(ent))
					{
						TE_SetupBeamFollow(ent, BeamSprite, 0, Float:5.0, Float:10.0, Float:10.0, 5, g_AlliesColour);
						TE_SendToAll();

						if (GetConVarBool(hL4DFright))
						{
							SetEntityModel(ent, "models/gibs/hgibs.mdl");
							SetEntProp(ent, Prop_Send, "m_clrRender", -1);
						}
						else
						{
							if (GetEntPropEnt(ent, Prop_Send, "m_hThrower") == attacker && g_bIsSupporter[attacker])
							{
								SetEntityModel(ent, "models/gibs/hgibs.mdl");
								SetEntProp(ent, Prop_Send, "m_clrRender", -1);
							}
						}

						if (GetEntPropEnt(ent, Prop_Send, "m_hThrower") == attacker && g_IsMember[attacker] > 0)
						{
							g_Bomblet[attacker] = ent;
							CreateTimer(2.0, Carpet, ent, TIMER_FLAG_NO_MAPCHANGE);
						}
					}
				}
			}

			else if (weapon == 26)
			{
				ent = -1;
				while ((ent = FindEntityByClassname(ent, "grenade_riflegren_ger")) != -1)
				{
					if (IsValidEntity(ent))
					{
						TE_SetupBeamFollow(ent, BeamSprite, 0, Float:5.0, Float:10.0, Float:10.0, 5, g_AlliesColour);
						TE_SendToAll();

						if (GetConVarBool(hL4DFright))
						{
							SetEntityModel(ent, "models/gibs/hgibs.mdl");
							SetEntProp(ent, Prop_Send, "m_clrRender", -1);
						}
						else
						{
							if (GetEntPropEnt(ent, Prop_Send, "m_hThrower") == attacker && g_bIsSupporter[attacker])
							{
								SetEntityModel(ent, "models/gibs/hgibs.mdl");
								SetEntProp(ent, Prop_Send, "m_clrRender", -1);
							}
						}
					}
				}
			}

			//restock pistols and carbine
			else if (weapon == 3)
			{
				SetEntData(attacker, g_oAmmo+4, 14, 4, true);
			}
			else if (weapon == 4)
			{
				SetEntData(attacker, g_oAmmo+8, 14, 4, true);
			}
			else if (weapon == 5)
			{
				SetEntData(attacker, g_oAmmo+12, 20, 4, true);
			}
			else if (weapon == 7)
			{
				SetEntData(attacker, g_oAmmo+24, 14, 4, true);
			}


			if((weapon == 9 || weapon == 8) && g_hasShotgun[attacker])
			{
				StartedShooting(attacker);
				hAngleTimer[attacker] = CreateTimer(0.2, StoppedShooting, attacker, TIMER_FLAG_NO_MAPCHANGE);
				EmitSoundToAll("left4dod/oneshot.mp3", attacker);
			}

			//Player fired so reset AFK timer
			g_iTimeAFK[attacker] = 0;

		}
	}
	return Plugin_Handled;
}

public Action:Command_Equip(client, args)
{
	if (client > 0 && IsClientInGame(client))
	{
		new Float:vecLoc[3];
		GetClientAbsOrigin(client, vecLoc);

		if (CheckLocationNearAlliedSpawn(vecLoc, STOREDISTANCE))
		{
			DisplayEquipmentMenu(client);
			g_useEquip[client] = true;
			SetClientCookie(client, hEquipCookie, "1");
		}
		else
		{
			DisplayEquipmentMenu(client);
			g_useEquip[client] = true;
			SetClientCookie(client, hEquipCookie, "1");
			PrintHelp(client, "*Weapons only available within \x04spawn", 0);
		}
	}

	return Plugin_Handled;
}

// WEAPONS #########################################################################

public Action:GiveZombieWeapon(Handle:timer, any:client)
{
	if (IsClientInGame(client) && IsPlayerAlive(client) && GetClientTeam(client) == AXIS)
	{
		#if DEBUG
			LogToFileEx(g_szLogFileName,"[L4DOD] Weapon given:%i", client);
		#endif

		g_canUseWeapon[client] = true;

		// Strip the weapons
		new weaponslot;
		for (new slot = 0; slot < 5; slot++)
		{
			weaponslot = GetPlayerWeaponSlot(client, slot);
			if(weaponslot != -1)
			{
				if (RemovePlayerItem(client, weaponslot))
					RemoveEdict(weaponslot);
			}
		}

		// Give the bot a weapon
		if (g_ZombieType[client] == INFECTEDONE)
		{
			GivePlayerItem(client, "weapon_amerknife");
			FakeClientCommand(client, "use weapon_amerknife");
		}
		else if (g_ZombieType[client] == SKELETON)
		{
			GivePlayerItem(client, "weapon_amerknife");
			FakeClientCommand(client, "use weapon_amerknife");

			GivePlayerItem(client, "weapon_frag_ger");
			new WeaponID = -1;
			for (new i = 0; i < MAXWEAPONS; i++)
			{
				if (strcmp("weapon_frag_ger", g_Weapon[i]) == 0)
				{
					WeaponID = i;
				}
			}
			if (WeaponID != -1)
			{
				if (WeaponID == 0 || WeaponID == 1)
					return Plugin_Handled;

				else
				{
					new WeaponAmmo = g_oAmmo + g_AmmoOffs[WeaponID];

					SetEntData(client, WeaponAmmo, 6, 4, true);
				}
			}
		}
		else
		{
			GivePlayerItem(client, "weapon_spade");
			FakeClientCommand(client, "use weapon_spade");
		}

		if (g_Invisible[client])
			SetAlpha(client, 0);

		g_checkWeapons[client] = true;
	}
	return Plugin_Handled;
}

public Action:BlockWeapon(Handle:timer, any:client)
{
	#if DEBUG
		LogToFileEx(g_szLogFileName,"[L4DOD] Weapon blocked:%i", client);
	#endif

	g_canUseWeapon[client] = false;
	DisableWeapons(client);
	return Plugin_Handled;
}

public Action:AllowWeapon(Handle:timer, any:client)
{
	#if DEBUG
		LogToFileEx(g_szLogFileName,"[L4DOD] Weapon allowed:%i", client);
	#endif

	g_canUseWeapon[client] = true;
	EnableWeapons(client);
	return Plugin_Handled;
}

public Action:AddAmmo(any:client)
{
	if (IsClientInGame(client) && IsPlayerAlive(client))
	{
		#if DEBUG
			LogToFileEx(g_szLogFileName,"[L4DOD] Ammo added:%i", client);
		#endif

		new WeaponID = -1;

		new weaponatslot = GetPlayerWeaponSlot(client, 0);
		if (weaponatslot != -1)
		{
			decl String:Weapon[32];
			GetEdictClassname(weaponatslot, Weapon, sizeof(Weapon));

			for (new i = 0; i < MAXWEAPONS; i++)
			{
				if (strcmp(Weapon, g_Weapon[i]) == 0)
				{
					WeaponID = i;
					break;
				}
			}

			if (WeaponID != -1)
			{
				if (WeaponID == 0 || WeaponID == 1 || WeaponID > 24)
					return Plugin_Handled;

				else
				{
					new WeaponAmmo = g_oAmmo + g_AmmoOffs[WeaponID];
					new currammo = GetEntData(client, WeaponAmmo);
					new AmmoMx;

					AmmoMx = g_AmmoMax[WeaponID];
					//Ammo is less than max amount
					//Player may still have half empty clips
					if (currammo < AmmoMx)
					{
						new bonus;
						if (g_bIsSupporter[client])
						{
							bonus = 3;
						}
						else if (g_iMoney[client] > 500  || g_IsMember[client] > 0)
						{
							bonus = 2;
						}
						else
						{
							bonus = 1;
						}

						new totalAmmo = currammo + (g_AmmoRefill[WeaponID] * bonus);

						if (totalAmmo >= AmmoMx)
							totalAmmo = AmmoMx;

						SetEntData(client, WeaponAmmo, totalAmmo, 4, true);

						PrintHelp(client, "*You picked up \x04Ammo", 0);
						EmitSoundToClient(client, "weapons/ammopickup.wav");
					}
					//Check the clip size
					else
					{
						//Only work on weapons that actually have clips
						if (g_ClipSize[WeaponID] > 0)
						{
							new ClipAmmo = GetEntData(weaponatslot, g_offsetClip1);
							if (ClipAmmo < g_ClipSize[WeaponID])
							{
								new bonus;
								if (g_bIsSupporter[client])
								{
									bonus = 3;
								}
								else if (g_IsMember[client] > 0)
								{
									bonus = 2;
								}
								else
								{
									bonus = 1;
								}

								new totalAmmo = ClipAmmo + (g_AmmoRefill[WeaponID] * bonus);

								if (totalAmmo >= g_ClipSize[WeaponID])
									totalAmmo = g_ClipSize[WeaponID];

								SetEntData(weaponatslot, g_offsetClip1, totalAmmo);
								PrintHelp(client, "*You picked up \x04Ammo", 0);
								EmitSoundToClient(client, "weapons/ammopickup.wav");
							}
						}
					}
				}
			}
		}
	}
	return Plugin_Handled;
}

public Action:AddNade(any:client)
{
	if (IsClientInGame(client) && IsPlayerAlive(client) && !IsClientObserver(client) && GetClientTeam(client) == ALLIES)
	{
		new String:Grenade[32], String:PrimaryWeapon[32];
		new weaponatslot = GetPlayerWeaponSlot(client, 0);

		if (weaponatslot != -1)
			GetEdictClassname(weaponatslot, PrimaryWeapon, sizeof(PrimaryWeapon));

		new class = GetEntProp(client, Prop_Send, "m_iPlayerClass");
		if (class == 0)
		{
			if (StrEqual(PrimaryWeapon, "weapon_k98"))
				Grenade = "weapon_riflegren_ger";

			else if (StrEqual(PrimaryWeapon, "weapon_garand"))
				Grenade = "weapon_riflegren_us";
		}
		else
			Grenade = "weapon_frag_us";

		//Look for the weapon in db
		new WeaponID = -1;
		for (new i = 0; i < MAXWEAPONS; i++)
		{
			if (strcmp(Grenade, g_Weapon[i]) == 0)
			{
				WeaponID = i;
			}
		}

		if (WeaponID != -1)
		{
			if (WeaponID == 0 || WeaponID == 1)
				return Plugin_Handled;

			else
			{
				new WeaponAmmo = g_oAmmo + g_AmmoOffs[WeaponID];

				new currentnum = GetEntData(client, WeaponAmmo);
				currentnum++;

				SetEntData(client, WeaponAmmo, currentnum, 4, true);
			}
		}
	}
	else if (IsClientInGame(client) && IsPlayerAlive(client) && !IsClientObserver(client) && GetClientTeam(client) == AXIS)
	{
		//Look for the weapon in db
		new WeaponID = -1;
		for (new i = 0; i < MAXWEAPONS; i++)
		{
			if (strcmp("weapon_frag_ger", g_Weapon[i]) == 0)
			{
				WeaponID = i;
			}
		}

		if (WeaponID != -1)
		{
			if (WeaponID == 0 || WeaponID == 1)
				return Plugin_Handled;

			else
			{
				new WeaponAmmo = g_oAmmo + g_AmmoOffs[WeaponID];

				new currentnum = GetEntData(client, WeaponAmmo);

				if (currentnum <= 0)
				{
					GivePlayerItem(client, "weapon_frag_ger");
				}
				else
				{
					currentnum++;

					if (currentnum >= 6)
						currentnum = 6;

					SetEntData(client, WeaponAmmo, currentnum, 4, true);
				}
			}
		}
	}
	return Plugin_Handled;
}

public Action:SetAmmo(any:client, String:Weapon[])
{
	if (IsClientInGame(client) && IsPlayerAlive(client) && GetClientTeam(client) == ALLIES)
	{
		#if DEBUG
			LogToFileEx(g_szLogFileName,"[L4DOD] Ammo set:%i", client);
		#endif

		new WeaponID = -1;
		for (new i = 0; i < MAXWEAPONS; i++)
		{
			if (strcmp(Weapon, g_Weapon[i]) == 0)
			{
				WeaponID = i;
			}
		}

		if (WeaponID != -1)
		{
			if (WeaponID == 0 || WeaponID == 1)
				return Plugin_Handled;

			else
			{
				new WeaponAmmo = g_oAmmo + g_AmmoOffs[WeaponID];

				SetEntData(client, WeaponAmmo, g_AmmoMax[WeaponID], 4, true);
			}
		}
	}
	return Plugin_Handled;
}

public Action:EquipClient(Handle:timer, any:client)
{
	if (IsClientInGame(client) && IsPlayerAlive(client) && !IsClientObserver(client) && GetClientTeam(client) == ALLIES)
	{
		new class = GetEntProp(client, Prop_Send, "m_iPlayerClass");

		if (!StrEqual(g_szPlayerWeapon[client], ""))
		{
			GivePlayerWeapon(client, g_szPlayerWeapon[client], 0);
		}
		else
		{
			if (class == 3)
				GivePlayerWeapon(client, "weapon_spring", 0);

			if (class == 4)
				GivePlayerWeapon(client, "weapon_30cal", 0);
		}

		if (!StrEqual(g_szPlayerSecondaryWeapon[client], ""))
		{
			GivePlayerWeapon(client, g_szPlayerSecondaryWeapon[client], 1);
		}

		if (!StrEqual(g_szPlayerGrenadeWeapon[client], "") && class < 3)
		{
			GivePlayerWeapon(client, g_szPlayerGrenadeWeapon[client], 3);
		}
	}
	return Plugin_Handled;
}


public Action:GivePlayerWeapon(any:client, String:Weapon[32], any:slot)
{
	if (IsClientInGame(client) && IsPlayerAlive(client) && !IsClientObserver(client) && GetClientTeam(client) == ALLIES)
	{
		#if DEBUG
			LogToFileEx(g_szLogFileName,"[L4DOD] Allies - Weapon given:%i", client);
		#endif

		// Strip the weapons
		new weaponslot;
		weaponslot = GetPlayerWeaponSlot(client, slot);
		if(weaponslot != -1)
		{
			if (RemovePlayerItem(client, weaponslot))
				AcceptEntityInput(weaponslot, "kill");
		}

		// Give the player a weapon
		GivePlayerItem(client, Weapon);
		SetAmmo(client, Weapon);
	}
	return Plugin_Handled;
}

public Action:GivePlayerBoxNades(any:client, any:amount)
{
	if (IsClientInGame(client) && IsPlayerAlive(client) && !IsClientObserver(client) && GetClientTeam(client) == ALLIES)
	{
		#if DEBUG
			LogToFileEx(g_szLogFileName,"[L4DOD] Box nades given:%i", client);
		#endif

		// Strip the weapons
		new weaponslot;
		weaponslot = GetPlayerWeaponSlot(client, 3);
		if(weaponslot != -1)
		{
			if (RemovePlayerItem(client, weaponslot))
				AcceptEntityInput(weaponslot, "kill");
		}

		new String:Grenade[32], String:PrimaryWeapon[32];
		new weaponatslot = GetPlayerWeaponSlot(client, 0);

		if (weaponatslot != -1)
			GetEdictClassname(weaponatslot, PrimaryWeapon, sizeof(PrimaryWeapon));

		new class = GetEntProp(client, Prop_Send, "m_iPlayerClass");
		if (class == 0)
		{
			if (StrEqual(PrimaryWeapon, "weapon_k98"))
				Grenade = "weapon_riflegren_ger";

			else if (StrEqual(PrimaryWeapon, "weapon_garand"))
				Grenade = "weapon_riflegren_us";
		}
		else
			Grenade = "weapon_frag_us";


		// Give the player a weapon
		GivePlayerItem(client, Grenade);

		new WeaponID = -1;
		for (new i = 0; i < MAXWEAPONS; i++)
		{
			if (strcmp(Grenade, g_Weapon[i]) == 0)
			{
				WeaponID = i;
			}
		}

		if (WeaponID != -1)
		{
			if (WeaponID == 0 || WeaponID == 1)
				return Plugin_Handled;

			else
			{
				new WeaponAmmo = g_oAmmo + g_AmmoOffs[WeaponID];

				SetEntData(client, WeaponAmmo, amount, 4, true);
			}
		}

		if (StrEqual(g_szPlayerWeapon[client], "weapon_thompson") || StrEqual(g_szPlayerWeapon[client], "weapon_mp40") || class == 1)
		{
			weaponslot = GetPlayerWeaponSlot(client, 2);
			if (weaponslot == -1)
			{
				GivePlayerItem(client, "weapon_smoke_us");
			}
		}
	}
	return Plugin_Handled;
}

//############ WEAPONS CONTROL
DisableWeapons(any:client)
{
	if (IsClientInGame(client))
	{
		new weaponslot;
		for (new slot = 0; slot < 5; slot++)
		{
			weaponslot = GetPlayerWeaponSlot(client, slot);
			if(weaponslot != -1)
			{
				SetEntPropFloat(weaponslot, Prop_Send, "m_flNextPrimaryAttack", GetGameTime() + 999999.0);
				SetEntPropFloat(weaponslot, Prop_Send, "m_flNextSecondaryAttack", GetGameTime() + 999999.0);
			}
		}
	}
}

EnableWeapons(any:client)
{
	if (IsClientInGame(client))
	{
		new weaponslot;
		for (new slot = 0; slot < 5; slot++)
		{
			weaponslot = GetPlayerWeaponSlot(client, slot);
			if(weaponslot != -1)
			{
				SetEntPropFloat(weaponslot, Prop_Send, "m_flNextPrimaryAttack", GetGameTime());
				SetEntPropFloat(weaponslot, Prop_Send, "m_flNextSecondaryAttack", GetGameTime());
			}
		}
	}
}

public Action:StartedShooting(client)
{
	if(hAngleTimer[client] != INVALID_HANDLE)
	{
		if(CloseHandle(hAngleTimer[client]))
		{
			hAngleTimer[client] = INVALID_HANDLE;
		}
	}
	new Float:Origin[3];
	GetClientAbsOrigin(client, Origin);
	new Float:Angles[3];
	GetClientEyeAngles(client, Angles);
	Angles[0] += GetRandomFloat(-10.0,-30.0);
	TeleportEntity(client, Origin, Angles, NULL_VECTOR);
	return Plugin_Handled;
}

public Action:StoppedShooting(Handle:timer, any:client)
{
	hAngleTimer[client] = INVALID_HANDLE;
	new Float:Origin[3];
	GetClientAbsOrigin(client, Origin);
	new Float:Angles[3];
	GetClientEyeAngles(client, Angles);
	Angles[0] += GetRandomFloat(1.0,10.0);
	TeleportEntity(client, Origin, Angles, NULL_VECTOR);

	new weaponslot = GetPlayerWeaponSlot(client, 0);
	SetEntPropFloat(weaponslot, Prop_Send, "m_flNextPrimaryAttack", GetGameTime()+1.0);
	return Plugin_Handled;
}
