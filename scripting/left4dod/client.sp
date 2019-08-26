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

public OnClientPutInServer(client)
{
	if (!IsFakeClient(client))
	{
		EmitSoundToClient(client, "left4dod/l4dod_intro.mp3");
	}

	g_switchSpec[client] = false;
}

public OnClientPostAdminCheck(client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);

	if (!IsFakeClient(client))
	{
		if (g_iUserID[client] == GetClientUserId(client))
		{
			//Player was playing the last map
		}
		else
		{
			//New player
			g_iUserID[client] = GetClientUserId(client);

			//Reset important variables for new players
			g_iMoney[client] = 0;

			g_szPlayerWeapon[client] = "";
			g_szPlayerSecondaryWeapon[client] = "";
			g_szPlayerGrenadeWeapon[client] = "";

			g_hasParachute[client] = false;
			g_HasMolotov[client] = false;
			g_hasHooch[client] = false;
			g_hasAdrenaline[client] = false;
			g_airstrike[client] = false;
			g_Shield[client] = false;

			g_AllowedMG[client] = false;
			g_AllowedRocket[client] = false;
			g_AllowedSniper[client] = false;

			ResetZombieClassVariable(client);

			g_iSwapped[client] = 0;
			g_HealthAdded[client] = 0;
		}
		//Check download settings
		CreateTimer(2.0, CheckPlayer, client, TIMER_FLAG_NO_MAPCHANGE);

		//Check Supporter/Admin status
		new flags = GetUserFlagBits(client);

		if (flags & ADMFLAG_ROOT || flags & ADMFLAG_VOTE)
		{
			g_bIsSupporter[client] = true;
		}
		else
		{
			g_bIsSupporter[client] = false;
		}

		new String:authid[64];
		GetClientAuthString(client, authid, sizeof(authid));

		new member_type = 0;
		member_type = GetGroupData(authid);

		if (member_type == 2)
		{
			g_IsMember[client] = 2;
		}
		else if (member_type == 1)
		{
			g_IsMember[client] = 1;
		}
		else if (member_type == 0)
		{
			g_IsMember[client] = 0;
		}

		//Grabs details from the database
		if (hDatabase != INVALID_HANDLE)
		{
			new String:query[1024];
			Format(query, sizeof(query), "SELECT * FROM players WHERE authid REGEXP '^STEAM_[0-9]:%s$' LIMIT 1;", authid[8]);
			//PrintToServer("Query: %s", query);
			SQL_TQuery(hDatabase, GetPlayerStats, query, client, DBPrio_High);
		}
		else
		{
			LogError("L4DOD: Lost Database Connection - Invalid Database");
		}
	}

	if (AreClientCookiesCached(client) && !IsFakeClient(client))
	{
		new String:szBuffer[32];

		#if DEBUG
			LogToFileEx(g_szLogFileName,"[L4DOD] Read equip cookie:%i", client);
		#endif

		GetClientCookie(client, hEquipCookie, szBuffer, sizeof(szBuffer));

		if (strlen(szBuffer) < 1)
			g_useEquip[client] = true;
		else
		{
			switch (StringToInt(szBuffer))
			{
				case 1:
				{
					g_useEquip[client] = true;
					PrintHelp(client, "*Equip menu: ON", 0);
				}
				case 0:
				{
					g_useEquip[client] = false;
					PrintHelp(client, "*Equip menu: OFF", 0);
					PrintHelp(client, "*Say \x04!menu\x01 to get the menu back up", 0);
				}
				default:
				{
					g_useEquip[client] = true;
					PrintHelp(client, "*Equip menu: ON", 0);
				}
			}
		}

		#if DEBUG
			LogToFileEx(g_szLogFileName,"[L4DOD] Read help cookie:%i", client);
		#endif

		GetClientCookie(client, hHelpCookie, szBuffer, sizeof(szBuffer));

		if (strlen(szBuffer) < 1)
		{
			PrintHelp(client, "*Hints: ON", 0);
			g_Hints[client] = true;
		}
		else
		{
			switch (StringToInt(szBuffer))
			{
				case 0:
				{
					g_Hints[client] = false;
					PrintHelp(client, "*Hints: OFF", 0);
				}
				case 1:
				{
					g_Hints[client] = true;
					PrintHelp(client, "*Hints: ON", 0);
				}
				default:
				{
					g_Hints[client] = true;
					PrintHelp(client, "*Hints: ON", 0);
				}
			}
		}

		#if DEBUG
			LogToFileEx(g_szLogFileName,"[L4DOD] Read overlay cookie:%i", client);
		#endif

		GetClientCookie(client, hOverlayCookie, szBuffer, sizeof(szBuffer));

		if (strlen(szBuffer) < 1)
		{
			PrintHelp(client, "*Allied Overlays: OFF", 0);
			g_ShowOverlays[client] = false;
		}
		else
		{
			switch (StringToInt(szBuffer))
			{
				case 0:
				{
					g_ShowOverlays[client] = false;
					PrintHelp(client, "*Allied Overlays: OFF", 0);
				}
				case 1:
				{
					g_ShowOverlays[client] = true;
					PrintHelp(client, "*Allied Overlays: ON", 0);
				}
				default:
				{
					g_ShowOverlays[client] = false;
					PrintHelp(client, "*Allied Overlays: OFF", 0);
				}
			}
		}

		// Load weapons cookies
		g_szPlayerWeapon[client] = "";
		g_szPlayerSecondaryWeapon[client] = "";
		g_szPlayerGrenadeWeapon[client] = "";

		g_getIntro[client] = true;

		#if DEBUG
			LogToFileEx(g_szLogFileName,"[L4DOD] Read weapons cookies:%i", client);
		#endif

		GetClientCookie(client, hPrimaryCookie, szBuffer, sizeof(szBuffer));
		Format(g_szPlayerWeapon[client], 32, "%s", szBuffer);

		GetClientCookie(client, hSecondaryCookie, szBuffer, sizeof(szBuffer));
		Format(g_szPlayerSecondaryWeapon[client], 32, "%s", szBuffer);

		GetClientCookie(client, hGrenadeCookie, szBuffer, sizeof(szBuffer));
		Format(g_szPlayerGrenadeWeapon[client], 32, "%s", szBuffer);

		#if DEBUG
			LogToFileEx(g_szLogFileName,"[L4DOD] Read zombie cookies:%i", client);
		#endif

		GetClientCookie(client, hZombieClassCookie, szBuffer, sizeof(szBuffer));
		if (StrEqual(szBuffer, "emo", false))
		{
			g_ZombieClass[client] = EMO;
		}
		else if (StrEqual(szBuffer, "skeleton", false))
		{
			g_ZombieClass[client] = SKELETON;
		}
		else if (StrEqual(szBuffer, "ung", false))
		{
			g_ZombieClass[client] = UNG;
		}
		else if (StrEqual(szBuffer, "witch", false))
		{
			g_ZombieClass[client] = WITCH;
		}
		else if (StrEqual(szBuffer, "infectedone", false))
		{
			g_ZombieClass[client] = INFECTEDONE;
		}
		else if (StrEqual(szBuffer, "greydude", false))
		{
			g_ZombieClass[client] = GREYDUDE;
		}
		else if (StrEqual(szBuffer, "anarchist", false))
		{
			g_ZombieClass[client] = ANARCHIST;
		}
		else if (StrEqual(szBuffer, "gasman", false))
		{
			g_ZombieClass[client] = GASMAN;
		}
		else if (StrEqual(szBuffer, "wraith", false))
		{
			g_ZombieClass[client] = WRAITH;
		}
	}

	g_plantedTNT[client] = false;
	g_found[client] = false;

	g_FireParticle[client] = 0;
	g_ShieldDeployed[client] = false;

	g_tkClient[client] = -1;
	g_actualtkAmount[client] = 0;
	g_tkDelayedKill[client] = false;
	g_iHasSpawned[client] = 0;

	g_iTimeAFK[client] = 0;

	g_ScoreWitch[client]=0;
	g_ScoreEmo[client]=0;
	g_ScoreGreyDude[client]=0;
	g_ScoreGasMan[client]=0;
	g_ScoreTraitor[client]=0;
	g_ScoreZombies[client]=0;
	g_ScoreHumans[client]=0;
	g_ScoreAnarchist[client]=0;
	g_ScoreUNG[client]=0;
	g_ScoreWraith[client]=0;
	g_ScoreSkeleton[client]=0;
	g_ScoreHellSpawn[client]=0;

	// Display Intro menu
	if (GetConVarInt(hL4DOn) && !IsFakeClient(client))
		DisplayIntro(client);
}

public GetPlayerStats(Handle:owner, Handle:hQuery, const String:error[], any:client)
{
	if(hQuery != INVALID_HANDLE)
	{
		if (client > 0)
		{
			//Found in database
			if (SQL_GetRowCount(hQuery) > 0)
			{
				while(SQL_FetchRow(hQuery))
				{
					g_iMoney[client] = SQL_FetchInt(hQuery, 2);
				}

				//PrintToServer( "[L4DOD] %N [%i] found in Database: ", client, g_iMoney[client]);
			}

			//Not found in database
			else
			{
				g_iMoney[client] = 0;
			}

			CloseHandle(hQuery);
		}
	}
	else
	{
		LogError("L4DOD: Lost Database Connection - Unable to retrieve money");
		LogError("L4DOD: %s", error);

		//Try database again...
	}
}

//Player has fully disconnected
public Action:PlayerDisconnectEvent(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));

	if (client > 0 && !IsFakeClient(client))
		SendToDatabase(client);

	g_iMoney[client] = 0;

	g_szPlayerWeapon[client] = "";
	g_szPlayerSecondaryWeapon[client] = "";
	g_szPlayerGrenadeWeapon[client] = "";

	g_hasParachute[client] = false;
	g_HasMolotov[client] = false;
	g_hasAdrenaline[client] = false;
	g_hasHooch[client] = false;
	g_airstrike[client] = false;
	g_Shield[client] = false;

	g_AllowedMG[client] = false;
	g_AllowedRocket[client] = false;
	g_AllowedSniper[client] = false;

	ResetZombieClassVariable(client);

	g_iSwapped[client] = 0;

	g_tkClient[client] = -1;
	g_tkAmount[client] = 0;
	g_twAmount[client] = 0;
	g_tkfromtw[client] = 0;
	g_actualtkAmount[client] = 0;
	g_tkDelayedKill[client] = false;

	#if DEBUG
		LogToFileEx(g_szLogFileName,"[L4DOD] Unhooked - Player disconnected:%i", client);
	#endif

	return Plugin_Handled;
}


CheckForHumans()
{
	new numberHumans = GetHumansConnected();
	new numberBots = GetAxisBotNumber();

	if (numberHumans == 0 && numberBots == 0)
	{
		LogToFileEx(g_szLogFileName, "[L4DOD] No clients lefts on server.  Changing map....");
		ChangeMap();

	}
	else if (numberBots == 0)
	{
		LogToFileEx(g_szLogFileName, "[L4DOD] No bots lefts on server.  Changing map....");
		ChangeMap();
	}
}

ChangeMap()
{
	SetRandomSeed(RoundFloat(GetEngineTime()));
	new randomNum = GetRandomInt(0,4);

	switch (randomNum)
	{
		case 0:
			ServerCommand("changelevel dod_kalt");

		case 1:
			ServerCommand("changelevel dod_avalanche");

		case 2:
			ServerCommand("changelevel dod_anzio");

		case 3:
			ServerCommand("changelevel dod_donner");

		case 4:
			ServerCommand("changelevel dod_flash");

		default:
			ServerCommand("changelevel dod_kalt");
	}
}


//Player has disconnected due to map change
public OnClientDisconnect(client)
{
	SendToDatabase(client);

	g_szPlayerWeapon[client] = "";
	g_szPlayerSecondaryWeapon[client] = "";
	g_szPlayerGrenadeWeapon[client] = "";

	RemoveMines(client);

	g_ScoreWitch[client]=0;
	g_ScoreEmo[client]=0;
	g_ScoreGreyDude[client]=0;
	g_ScoreGasMan[client]=0;
	g_ScoreTraitor[client]=0;
	g_ScoreZombies[client]=0;
	g_ScoreHumans[client]=0;
	g_ScoreAnarchist[client]=0;
	g_ScoreUNG[client]=0;
	g_ScoreWraith[client]=0;
	g_ScoreSkeleton[client]=0;
	g_ScoreHellSpawn[client]=0;

	g_HealthAdded[client] = 0;

	g_OnFire[client] = false;
	g_bCanMakeNoise[client] = true;

	g_plantedTNT[client] = false;
	g_found[client] = false;
	g_ShieldDeployed[client] = false;

	g_iDroppedTNT[client] = 0;

	g_bCanRespawn[client] = true;

	g_iTimeAFK[client] = 0;

	g_tkClient[client] = -1;
	g_tkAmount[client] = 0;
	g_twAmount[client] = 0;
	g_tkfromtw[client] = 0;
	g_actualtkAmount[client] = 0;
	g_tkDelayedKill[client] = false;

	g_bIsSupporter[client] = false;

	g_hSearch_Timer[client] = INVALID_HANDLE;

	#if DEBUG
		LogToFileEx(g_szLogFileName,"[L4DOD] Unhooked - Map change disconnect:%i", client);
	#endif

	SDKUnhook(client, SDKHook_OnTakeDamage, OnTakeDamage);

	g_ShowSprite[client] = false;
}

public AddToDatabase(Handle:owner, Handle:hQuery, const String:error[], any:client)
{
	if (hQuery == INVALID_HANDLE)
	{
		if (client > 0 && IsClientInGame(client))
			LogToFileEx(g_szLogFileName,"[L4DOD] Error writing to DB [%N]:%s", client, error);
		else
			LogToFileEx(g_szLogFileName,"[L4DOD] Error writing to DB:%s", error);

		return;
	}
	else
	{
		CloseHandle(hQuery);
	}
}

//################################ CHECK PLAYER CVARS #####################################
public Action:CheckPlayer(Handle:timer,any:client)
{
	if (IsClientInGame(client))
	{
		#if DEBUG
			LogToFileEx(g_szLogFileName,"[L4DOD] Checked player:%i", client);
		#endif

		// Check cvars
		QueryClientConVar(client, "cl_allowdownload", ConVarQueryFinished:CheckADFilter, client);
	}

	return Plugin_Handled;
}

public CheckADFilter(QueryCookie:cookie, client, ConVarQueryResult:result, const String:cvarName[], const String:cvarValue[], any:value)
{
	new iValue = StringToInt(cvarValue);

	if (iValue != 1)
	{
		LogToFileEx(g_szLogFileName,"Client '%L' had %s=%s",client, cvarName, cvarValue);
		PrintToConsole(client, "------------------------------");
		PrintToConsole(client, "In order to play Left4DoD, you must download all the additional sounds, models and materials");
		PrintToConsole(client, "Go to http://www.boff.ca/dogblog/files/l4dod.zip");
		PrintToConsole(client, "------------------------------");
		KickClient(client,"Set cl_allowdownload 1");
	}
	else
	{
		if (IsClientInGame(client))
			QueryClientConVar(client, "cl_downloadfilter", ConVarQueryFinished:CheckDFFilter, client);
	}
}

public CheckDFFilter(QueryCookie:cookie, client, ConVarQueryResult:result, const String:cvarName[], const String:cvarValue[], any:value)
{
	if (!StrEqual(cvarValue, "all"))
	{
		LogToFileEx(g_szLogFileName,"Client '%L' had %s=%s",client, cvarName, cvarValue);
		PrintToConsole(client, "------------------------------");
		PrintToConsole(client, "In order to play Left4DoD, you must download all the additional sounds, models and materials");
		PrintToConsole(client, "Go to http://www.boff.ca/dogblog/files/l4dod.zip");
		PrintToConsole(client, "------------------------------");
		KickClient(client,"Set cl_downloadfilter all");
	}
}

public DisplayIntro(any:client)
{
	new String:text1[32], String:text2[32], String:text3[32], String:text7[32], String:text5[32], String:text6[32], String:subtitle[64], String:title[64];
	Format(text1, 32, "");
	Format(text2, 32, "");
	Format(text3, 32, "");
	Format(text5, 32, "");
	Format(text6, 32, "");
	Format(text7, 32, "");
	Format(subtitle, 64, "");

	if (GetConVarInt(hL4DGameType) == 0)
		Format(title,64, "=========== LEFT4DOD v%s =========", PLUGIN_VERSION );
	else if (GetConVarInt(hL4DGameType) == 1)
		Format(title,64, "======= LEFT4DOD COOP v%s ========", PLUGIN_VERSION );
	else if (GetConVarInt(hL4DGameType) == 2)
		Format(title,64, "===== LEFT4DOD TOURNAMENT v%s ====", PLUGIN_VERSION );

	if (g_IsMember[client] > 0)
	{
		subtitle 	= "Welcome back to Left4DoD!";
	}
	else
	{
		subtitle 	= "Left4DoD is an action horror Mod for DoD:S";
	}


	text1 		= "!menu:  Show/Hide menu";
	text2      = "!faq:   How to play Left4DoD";

	if (g_IsMember[client] > 0)
	{
		text3		= "Visit www.theville.org!";
	}
	else
	{
		text3		= "Welcome to TheVille.org!";
	}


	Unescape(subtitle);
	ReplaceString(subtitle, 64, "\\n", "\n");

	new Handle:mSayPanel = CreatePanel();
	SetPanelTitle(mSayPanel, title);
	DrawPanelItem(mSayPanel, "", ITEMDRAW_SPACER);
	DrawPanelText(mSayPanel, subtitle);
	DrawPanelItem(mSayPanel, "", ITEMDRAW_SPACER);
	DrawPanelText(mSayPanel, text1);
	DrawPanelText(mSayPanel, text2);
	DrawPanelItem(mSayPanel, "", ITEMDRAW_SPACER);
	DrawPanelText(mSayPanel, text3);

	DrawPanelItem(mSayPanel, "", ITEMDRAW_SPACER);
	DrawPanelText(mSayPanel, "=============== SETTINGS ==============");
	DrawPanelItem(mSayPanel, "", ITEMDRAW_SPACER);

	if (g_useEquip[client])
		text6 = "MENU: Shows at spawn";
	else
		text6 = "MENU: Hidden";

	DrawPanelText(mSayPanel, text6);

	if (g_Hints[client])
		text7 = "HINTS: Visible";
	else
		text7 = "HINTS: Hidden";

	DrawPanelText(mSayPanel, text7);

	if (g_IsMember[client] > 0)
		text5 = "STEAM GROUP MEMBER: Yes";
	else
		text5 = "STEAM GROUP MEMBER: No";

	DrawPanelText(mSayPanel, text5);

	DrawPanelItem(mSayPanel, "", ITEMDRAW_SPACER);

	SetPanelCurrentKey(mSayPanel, 10);
	DrawPanelItem(mSayPanel, "Exit", ITEMDRAW_CONTROL);

	SendPanelToClient(mSayPanel, client, Handler_DoNothing, 20);

	CloseHandle(mSayPanel);

	if (GetConVarInt(hL4DFright))
	{
		DisplayMessage(client, "HALLOWEEN MODE ENABLED", 20.0);
	}
	else if (GetConVarInt(hL4DGameType) == 1)
	{
		DisplayMessage(client, "COOP MODE ENABLED", 20.0);
	}
	else if (g_IsMember[client] == 0)
	{
		if (!GetConVarInt(hL4DDrops))
			DisplayMessage(client, "DROPS TEMPORARILY DISABLED", 30.0);
		else
			DisplayMessage(client, "JOIN THE LEFT4DOD STEAM GROUP FOR BETTER POWERUPS & AMMO", 30.0);
	}
}

stock DisplayMessage(any:client, String:message[128], Float:fTime)
{
	g_getIntro[client] = true;

	new Handle:pack;
	CreateDataTimer(1.0, DisplayGameInfo, pack, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
	WritePackCell(pack, client);
	WritePackString(pack, message);

	CreateTimer(fTime, TurnOffMessage, client, TIMER_FLAG_NO_MAPCHANGE);
}

public Action:DisplayGameInfo(Handle:timer, Handle:datapack)
{
	ResetPack(datapack);

	new client = ReadPackCell(datapack);

	if (!g_getIntro[client])
	{
		return Plugin_Stop;
	}

	new String:message[128];
	ReadPackString(datapack, message, sizeof(message));

	if (IsClientInGame(client))
	{
		PrintCenterText(client, "[L4DOD]: %s", message);
	}

	return Plugin_Handled;
}

public Action:TurnOffMessage(Handle:timer, any:client)
{
	g_getIntro[client] = false;

	return Plugin_Handled;
}

GetGroupData(const String:auth[])
{
	new Handle:h_KV = CreateKeyValues("1174424");

	new member_type = 0;

	decl String:datapath[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, datapath, PLATFORM_MAX_PATH, "configs/l4dod_group.txt");
	FileToKeyValues(h_KV, datapath);

	KvRewind(h_KV);

	///////////////////////////////////////////////////////////////// Get members
	if (!KvJumpToKey(h_KV, "members"))
	{
		CloseHandle(h_KV);
		PrintToServer("[L4DOD] UNABLE TO LOAD MEMBERS - INCORRECT FILE LAYOUT");
		return false;
	}

	member_type = KvGetNum(h_KV, auth, 0);

	CloseHandle(h_KV);

	return member_type;
}
