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
// MENUS ##############################################################################

public Handler_DoNothing(Handle:menu, MenuAction:action, param1, param2)
{
	/* Do nothing */
}

public Action:DisplayMainMenu(Handle:timer, any:client)
{
	if (IsClientInGame(client))
		DisplayEquipmentMenu(client);
	
	return Plugin_Handled;
}

DisplayEquipmentMenu(client)
{	
	new Handle:hMenu = CreateMenu(MenuHandler_Equip);
	
	decl String:title[100];
	Format(title, sizeof(title), "%s", "Menu:");
	SetMenuTitle(hMenu, title);
	SetMenuExitButton(hMenu, true);
	
	new Float:vecLoc[3];
	GetClientAbsOrigin(client, vecLoc);
	
	//Client is a group officer or admin or supporter
	if (g_IsMember[client] == 2 || g_bIsSupporter[client])
	{
		AddMenuItem(hMenu, "votemenu", "Vote Administration");
	}
	
	if (GetClientTeam(client) == SPECTATOR && GetConVarInt(hL4DGameType) == 2)
	{
		//Check Supporter/Admin status
		new flags = GetUserFlagBits(client);
		
		if (flags & ADMFLAG_ROOT || flags & ADMFLAG_BAN)
		{
			if (g_StoreEnabled)
				AddMenuItem(hMenu, "storeoff", "Turn OFF Store");
			else
				AddMenuItem(hMenu, "storeon", "Turn ON Store");
		}
	}
	
	new class = GetEntProp(client, Prop_Send, "m_iPlayerClass");

	if (class == 3)
	{				
		if (CheckLocationNearAlliedSpawn(vecLoc, STOREDISTANCE) && GetClientTeam(client) == ALLIES)
		{
			if (StrEqual(g_szPlayerWeapon[client], "weapon_k98_scoped"))
				AddMenuItem(hMenu, "weapon_spring", "Allied Springfield");
			else
				AddMenuItem(hMenu, "weapon_k98_scoped", "German Scoped K98");
				
			AddMenuItem(hMenu, "secondary", "Set Secondary Weapon");
		}

	}
	else if (class == 4)
	{				
		if (CheckLocationNearAlliedSpawn(vecLoc, STOREDISTANCE) && GetClientTeam(client) == ALLIES)
		{
			if (StrEqual(g_szPlayerWeapon[client], "weapon_mg42"))
				AddMenuItem(hMenu, "weapon_30cal", "Allied 30-Cal");
			else
				AddMenuItem(hMenu, "weapon_mg42", "German MG42");
				
			AddMenuItem(hMenu, "secondary", "Set Secondary Weapon");
		}

	}
	else if (class == 5)
	{			
		if (CheckLocationNearAlliedSpawn(vecLoc, STOREDISTANCE) && GetClientTeam(client) == ALLIES)
		{
			if (StrEqual(g_szPlayerWeapon[client], "weapon_pschreck"))
				AddMenuItem(hMenu, "weapon_bazooka", "Allied Bazooka");
			else
				AddMenuItem(hMenu, "weapon_pschreck", "German Panzerschreck");
				
			AddMenuItem(hMenu, "secondary", "Set Secondary Weapon");
		}

	}
	else 
	{			
		if (CheckLocationNearAlliedSpawn(vecLoc, STOREDISTANCE) && GetClientTeam(client) == ALLIES)
		{
				AddMenuItem(hMenu, "primary", "Set Primary Weapon");
				AddMenuItem(hMenu, "secondary", "Set Secondary Weapon");
				AddMenuItem(hMenu, "grenade", "Set Grenade Weapon");
		}
	}

	//2
	if (g_IsMember[client] == 0)
		AddMenuItem(hMenu, "join", "Join the Left4DoD Steam Group");
	
	//3	
	
	if (GetClientTeam(client) == ALLIES)
	{
		new String:szWeaponMenuTitle[64];
		
		if (g_hasParachute[client])
			Format(szWeaponMenuTitle, sizeof(szWeaponMenuTitle), "%s", "Forward Advance");
		else
			Format(szWeaponMenuTitle, sizeof(szWeaponMenuTitle), "%s [$%i]", "Forward Advance", GetWeaponCost("parachute"));
			
		if (CheckLocationNearAlliedSpawn(vecLoc, STOREDISTANCE) && CanAffordWeapon(client, "parachute") && g_bSpawnData)
			AddMenuItem(hMenu, "parachute", szWeaponMenuTitle);
		else
			AddMenuItem(hMenu, "parachute", szWeaponMenuTitle, ITEMDRAW_DISABLED);
	}
	else if (GetClientTeam(client) == AXIS)
	{
		if (CheckLocationNearAxisSpawn(vecLoc, STOREDISTANCE) && g_bZSpawnData)
			AddMenuItem(hMenu, "zombieclass", "Choose Zombie");
		else
			AddMenuItem(hMenu, "zombieclass", "Choose Zombie", ITEMDRAW_DISABLED);
			
		if (CheckLocationNearAxisSpawn(vecLoc, STOREDISTANCE) && g_bZSpawnData)
			AddMenuItem(hMenu, "spawn", "Choose Spawn Point");
		else
			AddMenuItem(hMenu, "spawn", "Choose Spawn Point", ITEMDRAW_DISABLED);
	}
	
	//STORE
	if (GetClientTeam(client) == ALLIES)
	{
		if (CheckLocationNearAlliedSpawn(vecLoc, STOREDISTANCE) && g_StoreEnabled)
			AddMenuItem(hMenu, "store", "Store");
		else
			AddMenuItem(hMenu, "store", "Store", ITEMDRAW_DISABLED);
	}
	else if (GetClientTeam(client) == AXIS)
	{	
		if (CheckLocationNearAxisSpawn(vecLoc, STOREDISTANCE) && g_StoreEnabled)
		{
			AddMenuItem(hMenu, "zombiestore", "Store");
		}
		else
		{
			AddMenuItem(hMenu, "zombiestore", "Store", ITEMDRAW_DISABLED);
		}
	}

	
	//
	if (g_IsMember[client] == 0)
	{
		//
		AddMenuItem(hMenu, "faq", "How to Play Left4DoD");
	}
	
	//
	if (g_iMoney[client] > 5 && g_Allies > 1 && g_StoreEnabled)
		AddMenuItem(hMenu, "donate", "Transfer funds");
	else
		AddMenuItem(hMenu, "donate", "Transfer funds", ITEMDRAW_DISABLED);
		
	//
	AddMenuItem(hMenu, "settings", "Settings");
	//
	AddMenuItem(hMenu, "commands", "Display commands");
		

	DisplayMenu(hMenu, client, 20);
	
	
	g_iTimeAFK[client] = 0;	
		
}

public MenuHandler_Equip(Handle:menu, MenuAction:action, param1, param2)
{
	if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
	else if (action == MenuAction_Select)
	{
		decl String:info[32];		
		GetMenuItem(menu, param2, info, sizeof(info));
		
		new Float:vecLoc[3];
		GetClientAbsOrigin(param1, vecLoc);
		
		if (StrEqual(info, "primary"))
		{
			DisplayPrimaryMenu(param1);
		}
		else if (StrEqual(info, "secondary"))
		{
			DisplaySecondaryMenu(param1);
		}
		else if (StrEqual(info, "grenade"))
		{
			DisplayGrenadeMenu(param1);
		}
		else if (StrEqual(info, "parachute"))
		{
			DisplayParachuteMenu(param1);
			
			if (!g_hasParachute[param1])
			{
				g_hasParachute[param1] = true;
				EmitSoundToClient(param1, "weapons/c4_pickup.wav");
		
				PayForEquip(param1, "parachute");
		
				PrintHelp(param1, "*You bought \x04a Parachute\x01. Choose a flag...", 0);	

				if (g_Hints[param1])
					PrintHelp(param1, "*You can advance to forward positions and parachute above captured flags", 0);
			}
		}
		else if (StrEqual(info, "zombieclass"))
		{
			DisplayZombieClassMenu(param1);
			PrintHelp(param1, "*Choose a zombie...", 0);

			if (g_Hints[param1])
			{
				PrintHelp(param1, "*Choose a Zombie to spawn as", 0);
			}
		}
		else if (StrEqual(info, "spawn"))
		{
			DisplaySpawnMenu(param1);
			
			PrintHelp(param1, "*Choose a flag...", 0);

			if (g_Hints[param1])
			{
				PrintHelp(param1, "*You can spawn on any flag as long as there are no enemies nearby", 0);
			}
		}
		else if (StrEqual(info, "faq"))
		{
			ShowMOTDPanel(param1, "Left4DoD Help", "http://www.boff.ca/left4dod/index.html", MOTDPANEL_TYPE_URL );
		}
		else if (StrEqual(info, "ville"))
		{
			ShowMOTDPanel(param1, "Visit TheVille.org", "https://www.theville.org/forums/viewforum.php?f=3", MOTDPANEL_TYPE_URL );
		}
		else if (StrEqual(info, "join"))
		{
			ShowMOTDPanel(param1, "Join the Left4DoD Community", "http://steamcommunity.com/groups/left4dod", MOTDPANEL_TYPE_URL );
		}
		else if (StrEqual(info, "commands"))
		{
			ShowMOTDPanel(param1, "Command list", "http://www.boff.ca/left4dod/commands.html", MOTDPANEL_TYPE_URL );
		}
		else if (StrEqual(info, "store"))
		{
			DisplayStoreMenu(param1);
		}
		else if (StrEqual(info, "donate"))
		{
			DisplayDonateMenu(param1);
		}
		else if (StrEqual(info, "zombiestore"))
		{
			DisplayZombieStoreMenu(param1);
		}
		else if (StrEqual(info, "storeon"))
		{
			g_StoreEnabled = true;
			DisplayEquipmentMenu(param1);
		}
		else if (StrEqual(info, "storeoff"))
		{
			g_StoreEnabled = false;
			DisplayEquipmentMenu(param1);
		}
		else if (StrEqual(info, "settings"))
		{
			DisplaySettingsMenu(param1);
		}
		else if (StrEqual(info, "votemenu"))
		{
			DisplayVotingMenu(param1);
		}
		
		else
		{
			if (GetClientTeam(param1) == ALLIES)
			{
				GivePlayerWeapon(param1, info, 0);
				Format(g_szPlayerWeapon[param1], 32, "%s", info);
			}
		}
		
		g_iTimeAFK[param1] = 0;
	}
}

//############################## ZOMBIE CLASS #############################################################
DisplayZombieClassMenu(client)
{
	new Handle:hMenu = CreateMenu(MenuHandler_ZombieClass);
	
	decl String:title[100];
	Format(title, sizeof(title), "%s", "Choose a Zombie:");
	SetMenuTitle(hMenu, title);
	SetMenuExitButton(hMenu, true);
	
	new Float:vecLoc[3];
	GetClientAbsOrigin(client, vecLoc);
	
	// g_PlayEmo;g_PlayUNG;g_PlaySkeleton;g_PlayGreyDude;g_PlayWitch;g_PlayGasman;g_PlayWraith;g_PlayAnarchist;g_PlayInfectedOne;
	if (CheckLocationNearAxisSpawn(vecLoc, STOREDISTANCE)
		&& g_PlayWitch == 0)
	{
		AddMenuItem(hMenu, "witch", "Play as Witch");
	}
	else
	{
		AddMenuItem(hMenu, "witch", "Play as Witch", ITEMDRAW_DISABLED);
	}
	
	if (CheckLocationNearAxisSpawn(vecLoc, STOREDISTANCE)
		&& g_PlayGreyDude == 0)
	{
		AddMenuItem(hMenu, "greydude", "Play as Grey Dude");
	}
	else
	{
		AddMenuItem(hMenu, "greydude", "Play as Grey Dude", ITEMDRAW_DISABLED);
	}
	
	if (CheckLocationNearAxisSpawn(vecLoc, STOREDISTANCE)
		&& g_PlayInfectedOne == 0)
	{
		AddMenuItem(hMenu, "infectedone", "Play as Infected One");
	}
	else
	{
		AddMenuItem(hMenu, "infectedone", "Play as Infected One", ITEMDRAW_DISABLED);
	}
	
	if (CheckLocationNearAxisSpawn(vecLoc, STOREDISTANCE)
		&& g_PlayGasman == 0)
	{
		AddMenuItem(hMenu, "gasman", "Play as Gasman");
	}
	else
	{
		AddMenuItem(hMenu, "gasman", "Play as Gasman", ITEMDRAW_DISABLED);
	}
	
	if (CheckLocationNearAxisSpawn(vecLoc, STOREDISTANCE)
		&& g_PlayAnarchist == 0)
	{
		AddMenuItem(hMenu, "anarchist", "Play as Anarchist");
	}
	else
	{
		AddMenuItem(hMenu, "anarchist", "Play as Anarchist", ITEMDRAW_DISABLED);
	}
	
	if (CheckLocationNearAxisSpawn(vecLoc, STOREDISTANCE)
		&& g_PlayEmo == 0)
	{
		AddMenuItem(hMenu, "emo", "Play as Emo");
	}
	else
	{
		AddMenuItem(hMenu, "emo", "Play as Emo", ITEMDRAW_DISABLED);
	}
	
	if (CheckLocationNearAxisSpawn(vecLoc, STOREDISTANCE)
		&& g_PlayWraith == 0)
	{
		AddMenuItem(hMenu, "wraith", "Play as Wraith");
	}
	else
	{
		AddMenuItem(hMenu, "wraith", "Play as Wraith", ITEMDRAW_DISABLED);
	}
	
	if (CheckLocationNearAxisSpawn(vecLoc, STOREDISTANCE)
		&& g_PlayUNG == 0)
	{
		AddMenuItem(hMenu, "ung", "Play as UNG");
	}
	else
	{
		AddMenuItem(hMenu, "ung", "Play as UNG", ITEMDRAW_DISABLED);
	}
	
	if (CheckLocationNearAxisSpawn(vecLoc, STOREDISTANCE) 
		&& g_PlaySkeleton == 0)
	{
		AddMenuItem(hMenu, "skeleton", "Play as Skeleton");
	}
	else
	{
		AddMenuItem(hMenu, "skeleton", "Play as Skeleton", ITEMDRAW_DISABLED);
	}
	
	if (CheckLocationNearAxisSpawn(vecLoc, STOREDISTANCE) 
		&& g_PlayHellSpawn == 0)
	{
		AddMenuItem(hMenu, "hellspawn", "Play as Hell Spawn");
	}
	else
	{
		AddMenuItem(hMenu, "hellspawn", "Play as Hell Spawn", ITEMDRAW_DISABLED);
	}
	
	if (CheckLocationNearAxisSpawn(vecLoc, STOREDISTANCE))
	{
		AddMenuItem(hMenu, "zombie", "Play as Zombie");
	}
	else
	{
		AddMenuItem(hMenu, "zombie", "Play as Zombie", ITEMDRAW_DISABLED);
	}
	
	SetMenuExitBackButton(hMenu, true);
	DisplayMenu(hMenu, client, 10);	
}

ResetZombieClassVariable(client)
{
	if (g_PlayEmo == client)
		g_PlayEmo = 0;
	if (g_PlayUNG == client)
		g_PlayUNG = 0;
	if (g_PlaySkeleton == client)
		g_PlaySkeleton = 0;
	if (g_PlayGreyDude == client)
		g_PlayGreyDude = 0;
	if (g_PlayWitch == client)
		g_PlayWitch = 0;
	if (g_PlayGasman == client)
		g_PlayGasman = 0;
	if (g_PlayWraith == client)
		g_PlayWraith = 0;
	if (g_PlayAnarchist == client)
		g_PlayAnarchist = 0;
	if (g_PlayInfectedOne == client)
		g_PlayInfectedOne = 0;
	if (g_PlayHellSpawn == client)
		g_PlayHellSpawn = 0;
}

public MenuHandler_ZombieClass(Handle:menu, MenuAction:action, client, param2)
{
	if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
	else if (action == MenuAction_Cancel)
	{
		if (param2 == MenuCancel_ExitBack && menu != INVALID_HANDLE)
		{
			DisplayEquipmentMenu(client);
		}
	}
	else if (action == MenuAction_Select)
	{
		new Float:vecLoc[3];
		GetClientAbsOrigin(client, vecLoc);
		if (CheckLocationNearAxisSpawn(vecLoc, STOREDISTANCE))
		{
			decl String:info[32];		
			GetMenuItem(menu, param2, info, sizeof(info));
			
			ResetZombieClassVariable(client);
			
			//Set class here
			if (StrEqual(info, "witch"))
			{
				CreateTimer(0.2, SpawnWitch, client, TIMER_FLAG_NO_MAPCHANGE);
				g_ZombieClass[client] = WITCH;
				g_PlayWitch = client;
				SetClientCookie(client, hZombieClassCookie, info);
			}
			else if (StrEqual(info, "greydude"))
			{
				CreateTimer(0.2, SpawnGreyDude, client, TIMER_FLAG_NO_MAPCHANGE);
				g_ZombieClass[client] = GREYDUDE;
				g_PlayGreyDude = client;
				SetClientCookie(client, hZombieClassCookie, info);
			}
			else if (StrEqual(info, "infectedone"))
			{
				CreateTimer(0.2, SpawnInfected, client, TIMER_FLAG_NO_MAPCHANGE);
				g_ZombieClass[client] = INFECTEDONE;
				g_PlayInfectedOne = client;
				SetClientCookie(client, hZombieClassCookie, info);
			}
			else if (StrEqual(info, "gasman"))
			{
				CreateTimer(0.2, SpawnGasman, client, TIMER_FLAG_NO_MAPCHANGE);
				g_ZombieClass[client] = GASMAN;
				g_PlayGasman = client;
				SetClientCookie(client, hZombieClassCookie, info);
			}
			else if (StrEqual(info, "anarchist"))
			{
				CreateTimer(0.2, SpawnAnarchist, client, TIMER_FLAG_NO_MAPCHANGE);
				g_ZombieClass[client] = ANARCHIST;
				g_PlayAnarchist = client;
				SetClientCookie(client, hZombieClassCookie, info);
			}
			else if (StrEqual(info, "emo"))
			{
				CreateTimer(0.2, SpawnEmo, client, TIMER_FLAG_NO_MAPCHANGE);
				g_ZombieClass[client] = EMO;
				g_PlayEmo = client;
				SetClientCookie(client, hZombieClassCookie, info);
			}

			else if (StrEqual(info, "wraith"))
			{
				CreateTimer(0.2, SpawnWraith, client, TIMER_FLAG_NO_MAPCHANGE);
				g_ZombieClass[client] = WRAITH;
				g_PlayWraith = client;
				SetClientCookie(client, hZombieClassCookie, info);
			}
			
			else if (StrEqual(info, "ung"))
			{
				CreateTimer(0.2, SpawnUNG, client, TIMER_FLAG_NO_MAPCHANGE);
				g_ZombieClass[client] = UNG;
				g_PlayUNG = client;
				SetClientCookie(client, hZombieClassCookie, info);
			}
			
			else if (StrEqual(info, "skeleton"))
			{
				CreateTimer(0.2, SpawnSkeleton, client, TIMER_FLAG_NO_MAPCHANGE);
				g_ZombieClass[client] = SKELETON;
				g_PlaySkeleton = client;
				SetClientCookie(client, hZombieClassCookie, info);
			}
			
			else if (StrEqual(info, "hellspawn"))
			{
				CreateTimer(0.2, SpawnHellSpawn, client, TIMER_FLAG_NO_MAPCHANGE);
				g_ZombieClass[client] = HELLSPAWN;
				g_PlayHellSpawn = client;
				SetClientCookie(client, hZombieClassCookie, info);
			}
			
			else if (StrEqual(info, "zombie"))
			{
				CreateTimer(0.2, SpawnZombie, client, TIMER_FLAG_NO_MAPCHANGE);
				g_ZombieClass[client] = ZOMBIE;
				SetClientCookie(client, hZombieClassCookie, info);
			}
			
			DisplayEquipmentMenu(client);

			g_iTimeAFK[client] = 0;
		}
		else
		{
			PrintHelp(client, "*You must be near your spawn to use the menu", 0);
			PrintHelp(client, "*You must be near your spawn to use the menu", 3);
		}
	}
}

//############################## PRIMARY MENU #############################################################
DisplayPrimaryMenu(client)
{	
	new Handle:hMenu = CreateMenu(MenuHandler_Primary);
	
	decl String:title[100];
	Format(title, sizeof(title), "%s", "Choose your primary weapon:");
	SetMenuTitle(hMenu, title);
	SetMenuExitButton(hMenu, true);
	
	AddMenuItem(hMenu, "weapon_garand", "Allied Garand");
	AddMenuItem(hMenu, "weapon_thompson", "Allied Thompson");
	AddMenuItem(hMenu, "weapon_bar", "Allied BAR");
	AddMenuItem(hMenu, "weapon_k98", "German K98");
	AddMenuItem(hMenu, "weapon_mp40", "German MP40");
	AddMenuItem(hMenu, "weapon_mp44", "German MP44");
	
	SetMenuExitBackButton(hMenu, true);
	DisplayMenu(hMenu, client, 10);	
}

public MenuHandler_Primary(Handle:menu, MenuAction:action, client, param2)
{
	if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
	else if (action == MenuAction_Cancel)
	{
		if (param2 == MenuCancel_ExitBack && menu != INVALID_HANDLE)
		{
			DisplayEquipmentMenu(client);
		}
	}
	else if (action == MenuAction_Select)
	{
		new Float:vecLoc[3];
		GetClientAbsOrigin(client, vecLoc);
		if (CheckLocationNearAlliedSpawn(vecLoc, STOREDISTANCE))
		{
			decl String:info[32];		
			GetMenuItem(menu, param2, info, sizeof(info));
			
			GivePlayerWeapon(client, info, 0);
									
			Format(g_szPlayerWeapon[client], 32, "%s", info);
			
			DisplayEquipmentMenu(client);
			
			SetClientCookie(client, hPrimaryCookie, info);
			
			g_iTimeAFK[client] = 0;
		}
		else
		{
			PrintHelp(client, "*You must be near your spawn to use the menu", 0);
			PrintHelp(client, "*You must be near your spawn to use the menu", 3);
		}
	}
}


//############################## SECONDARY MENU #############################################################
DisplaySecondaryMenu(client)
{	
	new Handle:hMenu = CreateMenu(MenuHandler_Secondary);
	
	decl String:title[100];
	Format(title, sizeof(title), "%s", "Choose your secondary weapon:");
	SetMenuTitle(hMenu, title);
	SetMenuExitButton(hMenu, true);
	
	AddMenuItem(hMenu, "weapon_colt", "Allied Colt");
	AddMenuItem(hMenu, "weapon_p38", "German P38");
	AddMenuItem(hMenu, "weapon_m1carbine", "Allied M1 Carbine");
	AddMenuItem(hMenu, "weapon_c96", "German C96");
	
	SetMenuExitBackButton(hMenu, true);
	DisplayMenu(hMenu, client, 10);	
}

public MenuHandler_Secondary(Handle:menu, MenuAction:action, client, param2)
{
	if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
	else if (action == MenuAction_Cancel)
	{
		if (param2 == MenuCancel_ExitBack && menu != INVALID_HANDLE)
		{
			DisplayEquipmentMenu(client);
		}
	}
	else if (action == MenuAction_Select)
	{
		new Float:vecLoc[3];
		GetClientAbsOrigin(client, vecLoc);
		if (CheckLocationNearAlliedSpawn(vecLoc, STOREDISTANCE))
		{
			decl String:info[32];		
			GetMenuItem(menu, param2, info, sizeof(info));
			
			GivePlayerWeapon(client, info, 1);
									
			Format(g_szPlayerSecondaryWeapon[client], 32, "%s", info);
			
			DisplayEquipmentMenu(client);
			
			SetClientCookie(client, hSecondaryCookie, info);
			
			g_iTimeAFK[client] = 0;
		}
		else
		{
			PrintHelp(client, "*You must be near your spawn to use the menu", 0);
			PrintHelp(client, "*You must be near your spawn to use the menu", 3);
		}
	}
}

//############################## GRENADE MENU #############################################################
DisplayGrenadeMenu(client)
{	
	new Handle:hMenu = CreateMenu(MenuHandler_Grenade);
	
	decl String:title[100];
	Format(title, sizeof(title), "%s", "Choose your grenades:");
	SetMenuTitle(hMenu, title);
	SetMenuExitButton(hMenu, true);
	
	AddMenuItem(hMenu, "weapon_frag_us", "Allied Grenade");
	AddMenuItem(hMenu, "weapon_frag_ger", "German Grenade");
	
	if (StrEqual(g_szPlayerWeapon[client], "weapon_k98"))
	{
		AddMenuItem(hMenu, "weapon_riflegren_ger", "German Rifle Grenade");
	}
	else if (StrEqual(g_szPlayerWeapon[client], "weapon_garand"))
	{
		AddMenuItem(hMenu, "weapon_riflegren_us", "Allied Rifle Grenade");
	}
	
	SetMenuExitBackButton(hMenu, true);
	DisplayMenu(hMenu, client, 10);	
	
	g_iTimeAFK[client] = 0;
}

public MenuHandler_Grenade(Handle:menu, MenuAction:action, client, param2)
{
	if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
	else if (action == MenuAction_Cancel)
	{
		if (param2 == MenuCancel_ExitBack && menu != INVALID_HANDLE)
		{
			DisplayEquipmentMenu(client);
		}
	}
	else if (action == MenuAction_Select)
	{
		new Float:vecLoc[3];
		GetClientAbsOrigin(client, vecLoc);
			
		if (CheckLocationNearAlliedSpawn(vecLoc, STOREDISTANCE))
		{			
			decl String:info[32];		
			GetMenuItem(menu, param2, info, sizeof(info));
			
			GivePlayerWeapon(client, info, 3);
									
			Format(g_szPlayerGrenadeWeapon[client], 32, "%s", info);
			
			DisplayEquipmentMenu(client);				
			
			SetClientCookie(client, hGrenadeCookie, info);
			
			g_iTimeAFK[client] = 0;
		}
		else
		{
			PrintHelp(client, "*You must be near your spawn to use the menu", 0);
			PrintHelp(client, "*You must be near your spawn to use the menu", 3);
		}
	}
}

//############################## PRIMARY MENU #############################################################
DisplaySpawnMenu(client)
{	
	new Handle:hMenu = CreateMenu(MenuHandler_Spawn);
	
	decl String:title[100];
	Format(title, sizeof(title), "%s", "Choose your spawn point:");
	SetMenuTitle(hMenu, title);
	SetMenuExitButton(hMenu, true);
	
	//Find flags 
	for (new i = 0; i < g_iFlagNumber; i++)
	{								
		new String:menuitem[16], String:choice[8];
		
		Format(menuitem, sizeof(menuitem), "Flag %i", i);
		Format(choice, sizeof(choice), "%i", i);
		
		if (GetAlliesNearFlag(g_vecZFlagVector[i], 100.0))
		{
			AddMenuItem(hMenu, choice, menuitem, ITEMDRAW_DISABLED);
		}					
		else
		{
			AddMenuItem(hMenu, choice, menuitem);
		}	
	}
	
	
	SetMenuExitBackButton(hMenu, true);
	DisplayMenu(hMenu, client, 10);	
}

public MenuHandler_Spawn(Handle:menu, MenuAction:action, client, param2)
{
	if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
	else if (action == MenuAction_Cancel)
	{
		if (param2 == MenuCancel_ExitBack && menu != INVALID_HANDLE)
		{
			DisplayEquipmentMenu(client);
		}
	}
	else if (action == MenuAction_Select)
	{
		new Float:vecLoc[3];
		GetClientAbsOrigin(client, vecLoc);
		if (CheckLocationNearAxisSpawn(vecLoc, STOREDISTANCE))
		{
			decl String:info[32];		
			GetMenuItem(menu, param2, info, sizeof(info));
			
			new flag = StringToInt(info);
			
			PrintHelp(client, "*Spawning...", 3);
			
			FadeOut(client);
			
			new Handle:pack;
			CreateDataTimer(2.0, SpawnZ, pack, TIMER_FLAG_NO_MAPCHANGE);
			WritePackCell(pack, client);
			WritePackCell(pack, flag);
			
			g_iTimeAFK[client] = 0;
			
			DisplayEquipmentMenu(client);
		}
		else
		{
			PrintHelp(client, "*You must be near your spawn to use the menu", 0);
			PrintHelp(client, "*You must be near your spawn to use the menu", 3);
		}
	}
}

public Action:SpawnZ(Handle:timer, Handle:datapack)
{
	ResetPack(datapack);
	
	new client = ReadPackCell(datapack);
	new flag = ReadPackCell(datapack);
	
	TeleportEntity(client, g_vecZFlagVector[flag], NULL_VECTOR, NULL_VECTOR);
			
	PlaySound(client, false);
	AddParticle(client, "smokegrenade", 2.0, 10.0);
	
	FadeIn(client);
	
	return Plugin_Handled;
}

DisplayParachuteMenu(client)
{	
	new Handle:hMenu = CreateMenu(MenuHandler_Parachute);
	
	decl String:title[100];
	Format(title, sizeof(title), "%s", "Choose your forward advance:");
	SetMenuTitle(hMenu, title);
	SetMenuExitButton(hMenu, true);
	
	//Find flags owned by Allies
	for (new i = 0; i < g_iFlagNumber; i++)
	{								
		new owner = GetEntData(g_iObjectiveResource, g_oOwner + (i * 4));
		new String:menuitem[16], String:choice[8];
		
		Format(menuitem, sizeof(menuitem), "Flag %i", i);
		Format(choice, sizeof(choice), "%i", i);
		
		if (owner == 2)
		{
			AddMenuItem(hMenu, choice, menuitem);
		}					
		else
		{
			AddMenuItem(hMenu, choice, menuitem, ITEMDRAW_DISABLED);
		}	
	}
	
	SetMenuExitBackButton(hMenu, true);
	DisplayMenu(hMenu, client, 10);	
}

public MenuHandler_Parachute(Handle:menu, MenuAction:action, client, param2)
{
	if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
	else if (action == MenuAction_Cancel)
	{
		if (param2 == MenuCancel_ExitBack && menu != INVALID_HANDLE)
		{
			DisplayEquipmentMenu(client);
		}
	}
	else if (action == MenuAction_Select)
	{
		new Float:vecLoc[3];
		GetClientAbsOrigin(client, vecLoc);
		if (CheckLocationNearAlliedSpawn(vecLoc, STOREDISTANCE))
		{
			decl String:info[32];		
			GetMenuItem(menu, param2, info, sizeof(info));
			
			new flag = StringToInt(info);
			
			//Black out screen
			//Aircraft noise
			//Go go go
			FadeOut(client);
			SetEntityMoveType(client, MOVETYPE_NONE);
			EmitSoundToClient(client, "ambient/airplane2.wav");
			PrintHelp(client, "*Dropping you in by parachute", 3);
			
			new Handle:pack;
			CreateDataTimer(3.0, InAircraft, pack, TIMER_FLAG_NO_MAPCHANGE);
			WritePackCell(pack, client);
			WritePackCell(pack, flag);
			
			g_iTimeAFK[client] = 0;
			
			DisplayEquipmentMenu(client);
		}
		else
		{
			PrintHelp(client, "*You must be near your spawn to use the menu", 0);
			PrintHelp(client, "*You must be near your spawn to use the menu", 3);
		}
	}
}

public Action:InAircraft(Handle:timer, Handle:datapack)
{
	ResetPack(datapack);
	
	new client = ReadPackCell(datapack);
	new flag = ReadPackCell(datapack);
	
	//Teleport and set gravity of player
	TeleportEntity(client, g_vecFlagVector[flag], NULL_VECTOR, NULL_VECTOR);
	SetEntityMoveType(client, MOVETYPE_WALK);
	
	//Fade screen back in
	FadeIn(client);
	
	//Get the angles of the player
	new Float:Angles[3] = {0.0, 0.0, 0.0};
	new Float:angle[3];
	GetClientAbsAngles(client, angle);
	
	//Angles[0] = angle[0] + 180.0; 
	Angles[1] = angle[1];
	//Angles[2] = angle[2] + 90.0;
	
	//Teleport parachute and attach to player
	new ent = CreateEntityByName("prop_dynamic_override");
	SetEntityModel(ent, "models/parachute/parachute_carbon.mdl");	
	SetEntProp(ent, Prop_Send, "m_clrRender", -1);
	SetEntityMoveType(ent, MOVETYPE_NOCLIP);
	DispatchSpawn(ent);
	
	// Ident the player
	new String:tName[24];
	Format(tName, sizeof(tName), "target%i", client);
	DispatchKeyValue(client, "targetname", tName);
	
	TeleportEntity(ent, g_vecFlagVector[flag], Angles, NULL_VECTOR);
	SetVariantString(tName);
	AcceptEntityInput(ent, "SetParent", ent, ent, 0);
	
	g_Parachute[client] = ent;
	
	SDKHook(ent, SDKHook_SetTransmit, Hook_SetTransmitParachute);
	
	SetEntityGravity(client, 0.03);
	
	new Handle:pack;				
	CreateDataTimer(0.1, CheckLanding, pack, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
	WritePackCell(pack, client);
	WritePackCell(pack, ent);
	
	EmitSoundToClient(client, "player/american/us_gogogo.wav");
	
	return Plugin_Handled;
}

public Action:Hook_SetTransmitParachute(entity, client) 
{
	//The parachutist should not see the parachute
    if (g_Parachute[client] == entity)
        return Plugin_Handled;
		
    return Plugin_Continue;
} 

public Action:CheckLanding(Handle:timer, Handle:datapack)
{
	ResetPack(datapack);
	
	new client = ReadPackCell(datapack);
	new ent = ReadPackCell(datapack);
	new Float:velocity[3];
	
	if (IsClientInGame(client) && IsPlayerAlive(client))
	{
		GetEntDataVector(client, FindSendPropOffs("CBasePlayer", "m_vecVelocity[0]"), velocity);
	
		new entity_flags = GetEntityFlags(client);
		
		if (velocity[2] >= 0 || (entity_flags & FL_ONGROUND))
		{
			SetEntityGravity(client, 1.0);
			RemoveParachute(ent, client);
			
			g_hasParachute[client] = false;
			return Plugin_Stop;
		}
	}
	else
	{
		return Plugin_Stop;
	}
	
	return Plugin_Handled;
}

RemoveParachute(entity, client)
{
	if (!IsValidEntity(entity) || entity <= MaxClients)
		return;
		
	if (IsValidEntity(entity))
	{	
		new String:classname[256];
		GetEdictClassname(entity, classname, sizeof(classname));
		if (StrEqual(classname, "prop_dynamic", false))
		{
			//SetEntityRenderFx(entity, RENDERFX_FADE_SLOW);
			
			new String:addoutput[64];
			Format(addoutput, sizeof(addoutput), "OnUser1 !self:kill::%f:1", 1.0);
			SetVariantString(addoutput);
			AcceptEntityInput(entity, "AddOutput");
			AcceptEntityInput(entity, "FireUser1");
		}
	}
	
	g_Parachute[client] = 0;
}

//############################## SURVIVOR MENU ############################################################
public Action:DisplayDeathMenu(Handle:timer, any:client)
{
	if (IsClientInGame(client))
		DisplayDeadMenu(client);
	
	return Plugin_Handled;
}

DisplayDeadMenu(client)
{	
	new Handle:hDeathMenu = CreateMenu(MenuHandler_Death);
	
	decl String:title[100];
	Format(title, sizeof(title), "%s", "WOULD YOU LIKE TO:");
	SetMenuTitle(hDeathMenu, title);
	SetMenuExitButton(hDeathMenu, true);
	
	//1
	AddMenuItem(hDeathMenu, "spec", "Spectate (chance of respawn)");
	
	//2
	AddMenuItem(hDeathMenu, "zombie", "Play as Zombie");
	
	SetMenuExitButton(hDeathMenu, false);
	DisplayMenu(hDeathMenu, client, 10);
	
	PrintHelp(client, "*Spectate = the chance to respawn on Allies", 0);
	
}

public MenuHandler_Death(Handle:menu, MenuAction:action, client, param2)
{
	if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
	else if (action == MenuAction_Cancel)
	{
		PrintHelp(client, "*YOU WILL RESPAWN NEXT ROUND", 3);
		PrintHelp(client, "*YOU WILL RESPAWN NEXT ROUND", 0);
	}
	else if (action == MenuAction_Select)
	{
		decl String:info[32];		
		GetMenuItem(menu, param2, info, sizeof(info));
		
		if (StrEqual(info, "spec"))
		{
			g_bCanRespawn[client] = false;
			PrintHelp(client, "*YOU WILL RESPAWN NEXT ROUND", 3);
			PrintHelp(client, "*YOU WILL RESPAWN NEXT ROUND", 0);
		}
		else if (StrEqual(info, "zombie"))
		{
			g_bCanRespawn[client] = true;
			ChangeClientTeam(client, AXIS);
			ShowVGUIPanel(client, "class_ger" , _, true);
		}
	}
}

//############################## SETTINGS MENU #############################################################
DisplaySettingsMenu(client)
{	
	new Handle:hMenu = CreateMenu(MenuHandler_Settings);
	
	decl String:title[100];
	Format(title, sizeof(title), "%s", "Settings");
	SetMenuTitle(hMenu, title);
	SetMenuExitButton(hMenu, true);
	
	//1
	if (g_Hints[client])
		AddMenuItem(hMenu, "nohints", "Do not show Hints");
	else
		AddMenuItem(hMenu, "hints", "Show Hints");
		
	//2
	if (GetClientTeam(client) == ALLIES)
	{
		if (g_ShowOverlays[client])
			AddMenuItem(hMenu, "nooverlay", "Do not show Overlays");
		else 
			AddMenuItem(hMenu, "overlay", "Show Overlays");
	}
	
	//3
	AddMenuItem(hMenu, "closed", "Stop using menus");

	
	SetMenuExitBackButton(hMenu, true);
	DisplayMenu(hMenu, client, 10);	
	
	g_iTimeAFK[client] = 0;
}

public MenuHandler_Settings(Handle:menu, MenuAction:action, client, param2)
{
	if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
	else if (action == MenuAction_Cancel)
	{
		if (param2 == MenuCancel_ExitBack && menu != INVALID_HANDLE)
		{
			DisplayEquipmentMenu(client);
		}
	}
	else if (action == MenuAction_Select)
	{
		decl String:info[32];		
		GetMenuItem(menu, param2, info, sizeof(info));
		
		if (StrEqual(info, "hints"))
		{
			g_Hints[client] = true;
			SetClientCookie(client, hHelpCookie, "1");
		}
		else if (StrEqual(info, "nohints"))
		{
			g_Hints[client] = false;
			SetClientCookie(client, hHelpCookie, "0");
		}
		else if (StrEqual(info, "overlay"))
		{
			g_ShowOverlays[client] = true;
			SetClientCookie(client, hOverlayCookie, "1");
			PrintHelp(client, "*If you find your screen going blank, when you pick up TNT/Radio/Shield, turn this off", 0);
		}
		else if (StrEqual(info, "nooverlay"))
		{
			g_ShowOverlays[client] = false;
			SetClientCookie(client, hOverlayCookie, "0");
		}
		else if (StrEqual(info, "closed"))
		{
			g_useEquip[client] = false;
			SetClientCookie(client, hEquipCookie, "0");
			PrintHelp(client, "*Saying \x04!menu \x01will bring the menu back", 0);
			PrintHelp(client, "*Saying !menu will bring the menu back", 3);
		}
		
		DisplaySettingsMenu(client);
		
		g_iTimeAFK[client] = 0;
	}
}

//############################## VOTE MENU #############################################################
DisplayVotingMenu(client)
{	
	new Handle:hMenu = CreateMenu(MenuHandler_Votes);
	
	decl String:title[100];
	Format(title, sizeof(title), "%s", "Votes Admin");
	SetMenuTitle(hMenu, title);
	SetMenuExitButton(hMenu, true);
	
	AddMenuItem(hMenu, "mute", "Mute Menu");
	AddMenuItem(hMenu, "gag", "Gag Menu");
	AddMenuItem(hMenu, "silence", "Silence Menu");
	AddMenuItem(hMenu, "kick", "Kick Menu");
	AddMenuItem(hMenu, "ban", "Temp Ban Menu");
	AddMenuItem(hMenu, "map", "Map Menu");
	
	SetMenuExitBackButton(hMenu, true);
	DisplayMenu(hMenu, client, 10);	
	
	g_iTimeAFK[client] = 0;
}

public MenuHandler_Votes(Handle:menu, MenuAction:action, client, param2)
{
	if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
	else if (action == MenuAction_Cancel)
	{
		if (param2 == MenuCancel_ExitBack && menu != INVALID_HANDLE)
		{
			DisplayEquipmentMenu(client);
		}
	}
	else if (action == MenuAction_Select)
	{
		decl String:info[32];		
		GetMenuItem(menu, param2, info, sizeof(info));
		
		new Handle:hPlugin = FindPluginByFile("left4dod_player.smx");
		
		if (StrEqual(info, "mute"))
		{
			new Function:func = GetFunctionByName(hPlugin, "Command_Votemute");
			Call_StartFunction(hPlugin, func);
			Call_PushCell(client);
			Call_Finish();
		}
		else if (StrEqual(info, "gag"))
		{
			new Function:func = GetFunctionByName(hPlugin, "Command_Votegag");
			Call_StartFunction(hPlugin, func);
			Call_PushCell(client);
			Call_Finish();
		}
		else if (StrEqual(info, "silence"))
		{
			new Function:func = GetFunctionByName(hPlugin, "Command_Votesilence");
			Call_StartFunction(hPlugin, func);
			Call_PushCell(client);
			Call_Finish();
		}
		else if (StrEqual(info, "kick"))
		{
			new Function:func = GetFunctionByName(hPlugin, "Command_VoteKick");
			Call_StartFunction(hPlugin, func);
			Call_PushCell(client);
			Call_Finish();
		}
		else if (StrEqual(info, "ban"))
		{
			new Function:func = GetFunctionByName(hPlugin, "Command_VoteBan");
			Call_StartFunction(hPlugin, func);
			Call_PushCell(client);
			Call_Finish();
		}
		else if (StrEqual(info, "map"))
		{
			new Function:func = GetFunctionByName(hPlugin, "Command_VoteMap");
			Call_StartFunction(hPlugin, func);
			Call_PushCell(client);
			Call_Finish();
		}
		
		g_iTimeAFK[client] = 0;
	}
}