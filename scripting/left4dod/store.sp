/**
 * =============================================================================
 * SourceMod CSS for Day of Defeat Source
 * (C)2010 - Dog - www.theville.org
 * (C)2010 - Andersso - www.europeanmarines.eu
 *
 * SourceMod (C)2004-2008 AlliedModders LLC.  All rights reserved.
 * =============================================================================
 *
 * This program is bFree software; you can redistribute it and/or modify it under
 * the terms of the GNU General Public License, version 3.0, as published by the
 * bFree Software Foundation.
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
 
public Action:Command_SetMoney(client, args)
{	
	new String:arg1[32], String:arg2[32];
	new amount;
 
	/* Get the first argument */
	GetCmdArg(1, arg1, sizeof(arg1));
 
	/* If there are 2 or more arguments, and the second argument fetch 
	 * is successful, convert it to an integer.
	 */
	if (args >= 2 && GetCmdArg(2, arg2, sizeof(arg2)))
	{
		amount = StringToInt(arg2);
	}
 
	/* Try and find a matching player */
	new target = FindTarget(client, arg1, true);
	if (target == -1)
	{
		/* FindTarget() automatically replies with the 
		 * failure reason.
		 */
		return Plugin_Handled;
	}
	
	g_iMoney[target] += amount;
			
	PrintToChat(target, "*%N gave you $%i", client, amount);
	PrintCenterText(target, "*%N gave you $%i", client, amount);
	if (client > 0) 
	{
		PrintToChat(client, "*You gave $%i to %N", amount, target);
	}
	LogToFileEx(g_szLogFileName,"[L4DOD] %N set %N's money to $%i", client, target, amount);
	
	
	return Plugin_Handled;
}

public Action:AddSpecial(any:iClient, String:szType[32])
{

	if (StrEqual(szType, "pills"))
	{
		if (GetClientTeam(iClient) == ALLIES)
		{
			SetHealth(iClient, MAXHEALTH);
		}
		
		EmitSoundToClient(iClient, "left4dod/pillsstart.wav");
		PayForEquip(iClient, szType);
	}
	else if (StrEqual(szType, "radio"))
	{
		g_airstrike[iClient] = true;
		EmitSoundToClient(iClient, "weapons/c4_pickup.wav");
		PayForEquip(iClient, szType);
		
		PrintHelp(iClient, "*You bought a \x04Radio", 0);
			
		if (g_Hints[iClient])
		{
			PrintHelp(iClient, "*You can call in an airstrike", 0);
			PrintHelp(iClient, "To use, point your crosshairs, and press E (+USE)", 0);
		}
	}
	else if (StrEqual(szType, "shield"))
	{
		g_Shield[iClient] = true;
		EmitSoundToClient(iClient, "weapons/c4_pickup.wav");
		PayForEquip(iClient, szType);
		
		PrintHelp(iClient, "*You bought a \x04Shield", 0);
			
		if (g_Hints[iClient])
		{
			PrintHelp(iClient, "*You can use it defend yourself", 0);
			PrintHelp(iClient, "To use it, press E (+USE)", 0);
		}
	}
	
	else if (StrEqual(szType, "boxnades"))
	{
		if (g_bIsSupporter[iClient] || g_IsMember[iClient] > 0)
		{
			GivePlayerBoxNades(iClient, 10);
		}
		else
		{
			GivePlayerBoxNades(iClient, 5);
		}
		
		EmitSoundToClient(iClient, "weapons/ammopickup.wav");
		PayForEquip(iClient, szType);
	}
	
	else if (StrEqual(szType, "tnt"))
	{
		new weaponslot;
		weaponslot = GetPlayerWeaponSlot(iClient, 4);
		if(weaponslot == -1) 
		{
			GivePlayerItem(iClient, "weapon_basebomb");
			PrintHelp(iClient, "*You bought \x04TNT", 0);
			
			if (g_Hints[iClient])
			{
				PrintHelp(iClient, "*To plant it, stand near a wall, press and hold E (+USE)", 0);
				PrintHelp(iClient, "*Or press E (+USE) to throw it on the ground and shoot it", 0);
			}
			
			EmitSoundToClient(iClient, "weapons/c4_pickup.wav");
		}	
		
		PayForEquip(iClient, szType);
	}
	
	//Zombie add ons
	else if (StrEqual(szType, "invzb"))
	{
		g_invZB[iClient] = true;
		EmitSoundToClient(iClient, "weapons/bugbait/bugbait_impact1.wav");
		PayForEquip(iClient, szType);
		
		PrintHelp(iClient, "*You bought \x04Invisibility to Zombie Blood", 0);	

		if (g_Hints[iClient])
			PrintHelp(iClient, "*Allies with Zombie blood will not see you", 0);
	}
	else if (StrEqual(szType, "nofire"))
	{
		g_noFire[iClient] = true;
		EmitSoundToClient(iClient, "weapons/bugbait/bugbait_impact1.wav");
		PayForEquip(iClient, szType);
		
		PrintHelp(iClient, "*You bought \x04Fireproofing", 0);	

		if (g_Hints[iClient])
			PrintHelp(iClient, "*Molotovs will not affect you", 0);
	}
	
	g_iTimeAFK[iClient] = 0;
	
	return Plugin_Handled;
}


public Action:PayForEquip(iClient, String:szWeapon[32])
{
	LogToFileEx(g_szLogFileName,"[L4DOD] Transaction - %N ($%i) : %s", iClient, g_iMoney[iClient], szWeapon);
	
	new iWeaponID = -1;
	for (new i = 0; i < MAXWEAPONS; i++)
	{
		if (strcmp(szWeapon, g_Weapon[i]) == 0)
		{
			iWeaponID = i;
		}
	}
		
	if (iWeaponID != -1 && g_iMoney[iClient] > g_szWeaponCost[iWeaponID])
	{
		g_iMoney[iClient] -= g_szWeaponCost[iWeaponID];
		
		if (g_iMoney[iClient] <=0)
			g_iMoney[iClient] = 0;
		
		if (!IsFakeClient(iClient))
			PrintHintText(iClient, "Money: $%i", g_iMoney[iClient]);
	}
	
	PrintHelp(iClient, "*Transaction complete!", 3);
	
	SendToDatabase(iClient);

}

/**
 * Checks to see if a player can afford a weapon for the Menus
 */
public bool:CanAffordWeapon(iClient, String:szWeapon[32])
{
	new iWeaponID = -1;
	for (new i = 0; i < MAXWEAPONS; i++)
	{
		if (strcmp(szWeapon, g_Weapon[i]) == 0)
		{
			iWeaponID = i;
		}
	}
	
	if (g_iMoney[iClient] > g_szWeaponCost[iWeaponID])
	{
		return true;
	}
	
	return false;
}

public SendToDatabase(iClient)
{
	//Add stats to database
	if (iClient > 0 && !IsFakeClient(iClient) && g_iMoney[iClient] > 0)
	{
		new String:query[1024], String:authid[64];
		GetClientAuthString(iClient, authid, sizeof(authid));
		
		new String:clientname[128];
		Format(clientname, sizeof(clientname), "%N", iClient);
		ReplaceString(clientname, sizeof(clientname), "'", "");
		ReplaceString(clientname, sizeof(clientname), " OR ", "");
		ReplaceString(clientname, sizeof(clientname), " IS ", "");
		ReplaceString(clientname, sizeof(clientname), " LIKE ", "");
		ReplaceString(clientname, sizeof(clientname), " DROP ", "");
		ReplaceString(clientname, sizeof(clientname), " INSERT ", "");
		ReplaceString(clientname, sizeof(clientname), " UPDATE ", "");
		
		Format(query, sizeof(query), "INSERT INTO players (authid, playername, money) VALUES('%s','%s', '%i') ON DUPLICATE KEY UPDATE money=%i, playername='%s';", authid, clientname, g_iMoney[iClient], g_iMoney[iClient], clientname);
			
		//PrintToServer("Query: %s", query);
		SQL_TQuery(hDatabase, AddToDatabase, query, iClient, DBPrio_High);
	}
}

/**
 * returns a weapon's cost based on a weapon name
 */
public GetWeaponCost(String:szWeapon[32])
{
	new iWeaponID = -1;
	for (new i = 0; i < MAXWEAPONS; i++)
	{
		if (strcmp(szWeapon, g_Weapon[i]) == 0)
		{
			iWeaponID = i;
		}
	}
	
	if (iWeaponID != -1)
		return g_szWeaponCost[iWeaponID];
	else
		return 0;

}

DisplayStoreMenu(iClient)
{	
	new Float:vecLoc[3];
	GetClientAbsOrigin(iClient, vecLoc);
	
	if (CheckLocationNearAlliedSpawn(vecLoc, STOREDISTANCE))
	{
		new Handle:hMenu = CreateMenu(MenuHandler_Store);
		
		decl String:szTitle[100];
		Format(szTitle, sizeof(szTitle), "Money $%i", g_iMoney[iClient]);
		SetMenuTitle(hMenu, szTitle);
		SetMenuExitBackButton(hMenu, true);
		SetMenuExitButton(hMenu, true);
		
		new class = GetEntProp(iClient, Prop_Send, "m_iPlayerClass");
		if (class < 3)
		{				
			//1
			AddMenuItem(hMenu, "rifles", "Sniper Rifles");
			//2
			AddMenuItem(hMenu, "MG", "Machine Guns");
			//3
			AddMenuItem(hMenu, "rocket", "Rockets");
		}
		//4
		AddMenuItem(hMenu, "equip", "Equipment");
		//5
		AddMenuItem(hMenu, "special", "Special");
				
		DisplayMenu(hMenu, iClient, 10);
		
		if (g_Hints[iClient])
			PrintHelp(iClient, "*Picking up dropped \x04helmets\x01 will give you money", 0);
			
		g_iTimeAFK[iClient] = 0;
	}
	else
	{
		PrintHelp(iClient, "*You must be near your spawn to use the buy menu", 0);
		PrintHelp(iClient, "*You must be near your spawn to use the buy menu", 3);
	}
}

public MenuHandler_Store(Handle:hMenuEquip, MenuAction:menAction, iClient, iParam)
{
	if (menAction == MenuAction_End)
	{
		CloseHandle(hMenuEquip);
	}
	else if (menAction == MenuAction_Cancel)
	{
		if (iParam == MenuCancel_ExitBack && hMenuEquip != INVALID_HANDLE)
		{
			DisplayEquipmentMenu(iClient);
		}
	}
	else if (menAction == MenuAction_Select)
	{
		new Float:vecLoc[3];
		GetClientAbsOrigin(iClient, vecLoc);
		if (CheckLocationNearAlliedSpawn(vecLoc, STOREDISTANCE))
		{
			decl String:szInfo[32], String:szWeaponMenuTitle[64];		
			GetMenuItem(hMenuEquip, iParam, szInfo, sizeof(szInfo));
			
			new weaponslot;
			weaponslot = GetPlayerWeaponSlot(iClient, 4);
						
			new Handle:hMenu = CreateMenu(MenuHandler_Weapons);
			decl String:szTitle[100];
			Format(szTitle, sizeof(szTitle), "Money $%i", g_iMoney[iClient]);
			SetMenuTitle(hMenu, szTitle);
			
			if (StrEqual(szInfo, "rifles"))
			{
				if (g_Hints[iClient])
					PrintHelp(iClient, "*These Rifles are \x04temporary\x01.  You will lose them if you die", 0);
					
				//1
				Format(szWeaponMenuTitle, sizeof(szWeaponMenuTitle), "%s [$%i]", "Springfield", GetWeaponCost("weapon_spring"));
				if (CanAffordWeapon(iClient, "weapon_spring"))
					AddMenuItem(hMenu, "spring", szWeaponMenuTitle);
				else
					AddMenuItem(hMenu, "spring", szWeaponMenuTitle, ITEMDRAW_DISABLED);
				//2
				Format(szWeaponMenuTitle, sizeof(szWeaponMenuTitle), "%s [$%i]", "K98 Scoped", GetWeaponCost("weapon_k98_scoped"));
				if (CanAffordWeapon(iClient, "weapon_k98_scoped"))
					AddMenuItem(hMenu, "k98_scoped", szWeaponMenuTitle);
				else
					AddMenuItem(hMenu, "k98_scoped", szWeaponMenuTitle, ITEMDRAW_DISABLED);
			}
			else if (StrEqual(szInfo, "MG"))
			{
				if (g_Hints[iClient])
					PrintHelp(iClient, "*These MGs are \x04temporary\x01.  You will lose them if you die", 0);
					
				//1
				Format(szWeaponMenuTitle, sizeof(szWeaponMenuTitle), "%s [$%i]", "30Cal", GetWeaponCost("weapon_30cal"));
				if (CanAffordWeapon(iClient, "weapon_30cal"))
					AddMenuItem(hMenu, "30cal", szWeaponMenuTitle);
				else
					AddMenuItem(hMenu, "30cal", szWeaponMenuTitle, ITEMDRAW_DISABLED);
				//2
				Format(szWeaponMenuTitle, sizeof(szWeaponMenuTitle), "%s [$%i]", "MG42", GetWeaponCost("weapon_mg42"));
				if (CanAffordWeapon(iClient, "weapon_mg42"))
					AddMenuItem(hMenu, "mg42", szWeaponMenuTitle);
				else
					AddMenuItem(hMenu, "mg42", szWeaponMenuTitle, ITEMDRAW_DISABLED);
				
			}
			else if (StrEqual(szInfo, "rocket"))
			{
				if (g_Hints[iClient])
					PrintHelp(iClient, "*These Rockets are \x04temporary\x01.  You will lose them if you die", 0);
					
				//1
				Format(szWeaponMenuTitle, sizeof(szWeaponMenuTitle), "%s [$%i]", "Bazooka", GetWeaponCost("weapon_bazooka"));
				if (CanAffordWeapon(iClient, "weapon_bazooka"))
					AddMenuItem(hMenu, "bazooka", szWeaponMenuTitle);
				else
					AddMenuItem(hMenu, "bazooka", szWeaponMenuTitle, ITEMDRAW_DISABLED);
				//2
				Format(szWeaponMenuTitle, sizeof(szWeaponMenuTitle), "%s [$%i]", "Panzerschreck", GetWeaponCost("weapon_pschreck"));
				if (CanAffordWeapon(iClient, "weapon_pschreck"))
					AddMenuItem(hMenu, "pschreck", szWeaponMenuTitle);
				else
					AddMenuItem(hMenu, "pschreck", szWeaponMenuTitle, ITEMDRAW_DISABLED);
									
			}
			else if (StrEqual(szInfo, "equip"))
			{					
				//4 -- All nades are the same price so we just use FragUS
				Format(szWeaponMenuTitle, sizeof(szWeaponMenuTitle), "%s [$%i]", "Grenade", GetWeaponCost("weapon_frag_us"));
				if (CanAffordWeapon(iClient, "weapon_frag_us"))
					AddMenuItem(hMenu, "nade", szWeaponMenuTitle);
				else
					AddMenuItem(hMenu, "nade", szWeaponMenuTitle, ITEMDRAW_DISABLED);
				
				//5
				Format(szWeaponMenuTitle, sizeof(szWeaponMenuTitle), "%s [$%i]", "Box of Nades", GetWeaponCost("boxnades"));
				if (CanAffordWeapon(iClient, "boxnades"))
					AddMenuItem(hMenu, "boxnades", szWeaponMenuTitle);
				else
					AddMenuItem(hMenu, "boxnades", szWeaponMenuTitle, ITEMDRAW_DISABLED);
										
				//6
				Format(szWeaponMenuTitle, sizeof(szWeaponMenuTitle), "%s [$%i]", "TNT", GetWeaponCost("tnt"));
				if (CanAffordWeapon(iClient, "tnt") && (!g_airstrike[iClient] && !g_Shield[iClient] && weaponslot == -1 ))
					AddMenuItem(hMenu, "tnt", szWeaponMenuTitle);
				else
					AddMenuItem(hMenu, "tnt", szWeaponMenuTitle, ITEMDRAW_DISABLED);
				
			}
			else if (StrEqual(szInfo, "special"))
			{
				//1
				Format(szWeaponMenuTitle, sizeof(szWeaponMenuTitle), "%s [$%i]", "Airstrike", GetWeaponCost("radio"));
				if (CanAffordWeapon(iClient, "radio") && (!g_airstrike[iClient] && !g_Shield[iClient] && weaponslot == -1))
					AddMenuItem(hMenu, "radio", szWeaponMenuTitle);
				else
					AddMenuItem(hMenu, "radio", szWeaponMenuTitle, ITEMDRAW_DISABLED);	
					
				//2
				Format(szWeaponMenuTitle, sizeof(szWeaponMenuTitle), "%s [$%i]", "Shield", GetWeaponCost("shield"));
				if (CanAffordWeapon(iClient, "shield") && (!g_airstrike[iClient] && !g_Shield[iClient] && weaponslot == -1))
					AddMenuItem(hMenu, "shield", szWeaponMenuTitle);
				else
					AddMenuItem(hMenu, "shield", szWeaponMenuTitle, ITEMDRAW_DISABLED);
			}
								
			SetMenuExitBackButton(hMenu, true);
			DisplayMenu(hMenu, iClient, 10);
			g_iTimeAFK[iClient] = 0;
		}
		else
		{
			PrintHelp(iClient, "*You must be near your spawn to use the buy menu", 0);
			PrintHelp(iClient, "*You must be near your spawn to use the buy menu", 3);
		}
	}
}

public MenuHandler_Weapons(Handle:hMenuWeapons, MenuAction:menAction, iClient, iParam)
{
	if (menAction == MenuAction_End)
	{
		CloseHandle(hMenuWeapons);
	}
	else if (menAction == MenuAction_Cancel)
	{
		if (iParam == MenuCancel_ExitBack && hMenuWeapons != INVALID_HANDLE)
		{
			DisplayStoreMenu(iClient);
		}
	}
	else if (menAction == MenuAction_Select)
	{
		new Float:vecLoc[3];
		GetClientAbsOrigin(iClient, vecLoc);
		if (CheckLocationNearAlliedSpawn(vecLoc, STOREDISTANCE))
		{
			decl String:szInfo[32];		
			GetMenuItem(hMenuWeapons, iParam, szInfo, sizeof(szInfo));
								
			if (StrEqual(szInfo, "nade"))
			{
				new weaponatslot = GetPlayerWeaponSlot(iClient, 3);
				if (weaponatslot == -1)
				{
					if (GetClientTeam(iClient) == ALLIES)
					{
						GivePlayerWeapon(iClient, "weapon_frag_us", 3);
						PayForEquip(iClient, "weapon_frag_us");
					}
				}
				else
				{
					AddNade(iClient);
					PayForEquip(iClient, "weapon_frag_us");
				}
				
				DisplayStoreMenu(iClient);
			}
			
			else if (StrEqual(szInfo, "radio"))
			{
				AddSpecial(iClient, "radio");
				DisplayStoreMenu(iClient);
			}
			
			else if (StrEqual(szInfo, "shield"))
			{
				AddSpecial(iClient, "shield");
				DisplayStoreMenu(iClient);
			}
			
			else if (StrEqual(szInfo, "boxnades"))
			{
				AddSpecial(iClient, "boxnades");
				DisplayStoreMenu(iClient);
			}
			
			else if (StrEqual(szInfo, "tnt"))
			{
				AddSpecial(iClient, "tnt");
				DisplayStoreMenu(iClient);
			}
				
			else if (StrEqual(szInfo, "parachute"))
			{
				AddSpecial(iClient, "parachute");
				DisplayEquipmentMenu(iClient);
			}
				
			else
			{
				Format(szInfo, sizeof(szInfo), "weapon_%s", szInfo);
				GivePlayerWeapon(iClient, szInfo, 0);
				PayForEquip(iClient, szInfo);
				
				if (StrEqual(szInfo, "weapon_mg42") || StrEqual(szInfo, "weapon_30cal"))
					g_AllowedMG[iClient] = true;
				
				else if (StrEqual(szInfo, "weapon_k98_scoped") || StrEqual(szInfo, "weapon_spring"))
					g_AllowedSniper[iClient] = true;
					
				else if (StrEqual(szInfo, "weapon_pschreck") || StrEqual(szInfo, "weapon_bazooka"))
					g_AllowedRocket[iClient] = true;
					
				DisplayStoreMenu(iClient);
			}
		
			g_iTimeAFK[iClient] = 0;
		}
		else
		{
			PrintHelp(iClient, "*You must be near your spawn to use the buy menu", 0);
			PrintHelp(iClient, "*You must be near your spawn to use the buy menu", 3);
		}
	}
}

//############################ ZOMBIE STORE ###########################
DisplayZombieStoreMenu(iClient)
{	
	new Float:vecLoc[3];
	GetClientAbsOrigin(iClient, vecLoc);	
	
	if (CheckLocationNearAxisSpawn(vecLoc, 100.0))
	{
		new Handle:hMenu = CreateMenu(MenuHandler_ZombieStore);
		
		decl String:szTitle[100];
		Format(szTitle, sizeof(szTitle), "Money $%i", g_iMoney[iClient]);
		SetMenuTitle(hMenu, szTitle);
		SetMenuExitBackButton(hMenu, true);
		SetMenuExitButton(hMenu, true);
		
		//4
		AddMenuItem(hMenu, "special", "Special");
				
		DisplayMenu(hMenu, iClient, 10);
		
		if (g_Hints[iClient])
			PrintHelp(iClient, "*Picking up dropped \x04helmets\x01 will give you money", 0);
			
		g_iTimeAFK[iClient] = 0;
	}
	else
	{
		PrintHelp(iClient, "*You must be near your spawn to use the buy menu", 0);
		PrintHelp(iClient, "*You must be near your spawn to use the buy menu", 3);
	}
}

public MenuHandler_ZombieStore(Handle:hMenuEquip, MenuAction:menAction, iClient, iParam)
{
	if (menAction == MenuAction_End)
	{
		CloseHandle(hMenuEquip);
	}
	else if (menAction == MenuAction_Cancel)
	{
		if (iParam == MenuCancel_ExitBack && hMenuEquip != INVALID_HANDLE)
		{
			DisplayEquipmentMenu(iClient);
		}
	}
	else if (menAction == MenuAction_Select)
	{
		new Float:vecLoc[3];
		GetClientAbsOrigin(iClient, vecLoc);
		
		if (CheckLocationNearAxisSpawn(vecLoc, 100.0))
		{
			decl String:szInfo[32], String:szWeaponMenuTitle[64];		
			GetMenuItem(hMenuEquip, iParam, szInfo, sizeof(szInfo));

			new Handle:hMenu = CreateMenu(MenuHandler_Zombie);
			decl String:szTitle[100];
			Format(szTitle, sizeof(szTitle), "Money $%i", g_iMoney[iClient]);
			SetMenuTitle(hMenu, szTitle);
			
			if (StrEqual(szInfo, "special"))
			{					
				//
				Format(szWeaponMenuTitle, sizeof(szWeaponMenuTitle), "%s [$%i]", "Invisible to Zombie Blood", GetWeaponCost("invzb"));
				if (CanAffordWeapon(iClient, "invzb"))
					AddMenuItem(hMenu, "invzb", szWeaponMenuTitle);
				else
					AddMenuItem(hMenu, "invzb", szWeaponMenuTitle, ITEMDRAW_DISABLED);
					
				//
				Format(szWeaponMenuTitle, sizeof(szWeaponMenuTitle), "%s [$%i]", "Fireproof", GetWeaponCost("nofire"));
				if (CanAffordWeapon(iClient, "nofire"))
					AddMenuItem(hMenu, "nofire", szWeaponMenuTitle);
				else
					AddMenuItem(hMenu, "nofire", szWeaponMenuTitle, ITEMDRAW_DISABLED);							
			}
					
			SetMenuExitBackButton(hMenu, true);
			DisplayMenu(hMenu, iClient, 10);
			
			g_iTimeAFK[iClient] = 0;
		}
		else
		{
			PrintHelp(iClient, "*You must be near your spawn to use the buy menu", 0);
			PrintHelp(iClient, "*You must be near your spawn to use the buy menu", 3);
		}
	}
}

public MenuHandler_Zombie(Handle:hMenuWeapons, MenuAction:menAction, iClient, iParam)
{
	if (menAction == MenuAction_End)
	{
		CloseHandle(hMenuWeapons);
	}
	else if (menAction == MenuAction_Cancel)
	{
		if (iParam == MenuCancel_ExitBack && hMenuWeapons != INVALID_HANDLE)
		{
			DisplayZombieStoreMenu(iClient);
		}
	}
	else if (menAction == MenuAction_Select)
	{
		new Float:vecLoc[3];
		GetClientAbsOrigin(iClient, vecLoc);
		if (CheckLocationNearAxisSpawn(vecLoc, 150.0))
		{
			decl String:szInfo[32];		
			GetMenuItem(hMenuWeapons, iParam, szInfo, sizeof(szInfo));
												
			if (StrEqual(szInfo, "nofire"))
				AddSpecial(iClient, "nofire");
			
			else if (StrEqual(szInfo, "invrocket"))
				AddSpecial(iClient, "invrocket");
			
			else if (StrEqual(szInfo, "invzb"))
				AddSpecial(iClient, "invzb");
				
			DisplayZombieStoreMenu(iClient);
			
			g_iTimeAFK[iClient] = 0;
		}
		else
		{
			PrintHelp(iClient, "*You must be near your spawn to use the buy menu", 0);
			PrintHelp(iClient, "*You must be near your spawn to use the buy menu", 3);
		}
	}
}


//############################ DONATE MENU ############################

DisplayDonateMenu(client)
{
	new Handle:menu = CreateMenu(SelectPlayer_Handler);
	
	decl String:title[100];
	new String:playername[128];
	new String:identifier[64];
	Format(title, sizeof(title), "%s", "Choose player:");
	SetMenuTitle(menu, title);
	SetMenuExitBackButton(menu, true);
	
	for (new i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i) && !IsFakeClient(i) && i != client)
		{	
				GetClientName(i, playername, sizeof(playername));
				Format(identifier, sizeof(identifier), "%i", i);
				AddMenuItem(menu, identifier, playername);
		}
	}
	
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
	
	g_iTimeAFK[client] = 0;
	
	PrintHelp(client, "*Pick up \x04Helmets\x01 to get money", 3);
}

public SelectPlayer_Handler(Handle:hPlayerMenu, MenuAction:action, param1, param2)
{
	if (action == MenuAction_End)
	{
		CloseHandle(hPlayerMenu);
	}
	else if (action == MenuAction_Cancel)
	{
		if (param2 == MenuCancel_ExitBack && hPlayerMenu != INVALID_HANDLE)
		{
			DisplayEquipmentMenu(param1);
		}
	}
	else if (action == MenuAction_Select)
	{
		decl String:info[32], String:name[32];
		new target;
		
		GetMenuItem(hPlayerMenu, param2, info, sizeof(info), _, name, sizeof(name));
		target = StringToInt(info);

		if (target == 0)
		{
			PrintToChat(param1, "*%s", "Player no longer available");
		}
		else
		{
			g_iDonateTarget[param1] = target;
			DisplayAmountMenu(param1);
		}
		
		g_iTimeAFK[param1] = 0;
	}
}

DisplayAmountMenu(client)
{
	new Handle:menu = CreateMenu(Amount_Handler);
	
	decl String:title[100];
	Format(title, sizeof(title), "%s", "Choose amount:");
	SetMenuTitle(menu, title);
	SetMenuExitBackButton(menu, true);
	
	if (g_iMoney[client] > 5)
		AddMenuItem(menu, "5", "$5");
	else
		AddMenuItem(menu, "5", "$5", ITEMDRAW_DISABLED);
	
	if (g_iMoney[client] > 10)
		AddMenuItem(menu, "10", "$10");
	else	
		AddMenuItem(menu, "10", "$10", ITEMDRAW_DISABLED);
		
	if (g_iMoney[client] > 20)
		AddMenuItem(menu, "20", "$20");
	else
		AddMenuItem(menu, "20", "$20", ITEMDRAW_DISABLED);
		
	if (g_iMoney[client] > 50)
		AddMenuItem(menu, "50", "$50");
	else	
		AddMenuItem(menu, "50", "$50", ITEMDRAW_DISABLED);
		
	if (g_iMoney[client] > 100)
		AddMenuItem(menu, "100", "$100");
	else	
		AddMenuItem(menu, "100", "$100", ITEMDRAW_DISABLED);
		
	if (g_iMoney[client] > 200)
		AddMenuItem(menu, "200", "$200");
	else	
		AddMenuItem(menu, "200", "$200", ITEMDRAW_DISABLED);
		
	if (g_iMoney[client] > 500)
		AddMenuItem(menu, "500", "$500");
	else	
		AddMenuItem(menu, "500", "$500", ITEMDRAW_DISABLED);
		
	if (g_iMoney[client] > 1000)
		AddMenuItem(menu, "1000", "$1000");
	else	
		AddMenuItem(menu, "1000", "$1000", ITEMDRAW_DISABLED);
		
	if (g_iMoney[client] > 2000)
		AddMenuItem(menu, "2000", "$2000");
	else	
		AddMenuItem(menu, "2000", "$2000", ITEMDRAW_DISABLED);
		
	if (g_iMoney[client] > 5000)
		AddMenuItem(menu, "5000", "$5000");
	else	
		AddMenuItem(menu, "5000", "$5000", ITEMDRAW_DISABLED);
	
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
	g_iTimeAFK[client] = 0;
}

public Amount_Handler(Handle:menu, MenuAction:action, param1, param2)
{
	if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
	else if (action == MenuAction_Cancel)
	{
		if (param2 == MenuCancel_ExitBack && menu != INVALID_HANDLE)
		{
			DisplayDonateMenu(param1);
		}
	}
	else if (action == MenuAction_Select)
	{
		decl String:info[32];
		
		GetMenuItem(menu, param2, info, sizeof(info));
		new amount = StringToInt(info);
		
		if (g_iMoney[param1] > amount)
		{
			g_iMoney[param1] -= amount;
			g_iMoney[g_iDonateTarget[param1]] += amount;
			
			PrintToChat(g_iDonateTarget[param1], "*%N transferred $%i to you", param1, amount);
			PrintCenterText(g_iDonateTarget[param1], "*%N transferred $%i to you", param1, amount);
			PrintToChat(param1, "*You transferred $%i to %N", amount, g_iDonateTarget[param1]);
			LogToFileEx(g_szLogFileName,"[L4DOD] %N transferred $%i to %N", param1, amount, g_iDonateTarget[param1]);
		}
		else
		{
			PrintHelp(param1, "*You have insufficient funds", 0);
		}
		
		g_iTimeAFK[param1] = 0;
	}
}