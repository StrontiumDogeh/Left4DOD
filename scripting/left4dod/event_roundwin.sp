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

public RoundWinEvent(Handle:event, const String:name[], bool:dontBroadcast)
{
	#if DEBUG
		LogToFileEx(g_szLogFileName,"[L4DOD] Round over");
	#endif
		
	g_bRoundActive = false;
	g_bRoundOver = true;
	g_inProgress = false;
	
	new team = GetEventInt(event, "team");
	if (g_Allies >= 1)
	{
		if (team == 2)
		{
			LogToGame("Team \"Allies\" triggered \"round_win_allies\"");
			g_AlliedWins++;
		}
		else if (team == 3)
		{
			LogToGame("Team \"Axis\" triggered \"round_win_axis\"");
			g_AxisWins++;
		}
	}
				
	#if DEBUG
		LogToFileEx(g_szLogFileName,"[L4DOD] Unhooking flags");
	#endif

	if (GetConVarInt(hL4DGameType) == 0 || GetConVarInt(hL4DGameType) == 2)
	{
		for (new i = MaxClients; i < GetMaxEntities(); i++)
		{
			if (IsValidEntity(i))
			{
				new String:classname[128];
				GetEdictClassname(i, classname, sizeof(classname));
				if (StrEqual(classname, "dod_capture_area", false))
				{	
					SDKUnhook(i, SDKHook_StartTouch, OnFlagTouched);
				}
			}
		}
	}
	
	CloseTimers();
	
	DisplayScores();
	
	//Reset who is a bot
	for (new kk=1; kk<=MaxClients; kk++)
	{
		g_ShowSprite[kk] = false;
		g_ZombieType[kk] = -1;
	}
}

public GameOverEvent(Handle:event, const String:name[], bool:dontBroadcast)
{
	#if DEBUG
		LogToFileEx(g_szLogFileName,"[L4DOD] Game over");
	#endif
		
	DisplayScores();
	
	if (GetConVarInt(hL4DGameType) == 0 || GetConVarInt(hL4DGameType) == 2)
	{
		for (new i = MaxClients; i < GetMaxEntities(); i++)
		{
			if (IsValidEntity(i))
			{
				new String:classname[128];
				GetEdictClassname(i, classname, sizeof(classname));
				if (StrEqual(classname, "dod_capture_area", false))
				{	
					SDKUnhook(i, SDKHook_StartTouch, OnFlagTouched);
				}
			}
		}
	}
	
	CloseTimers();
	
	new rum = GetRandomInt(0,2);
	EmitSoundToAll(g_EndSounds[rum]);
		
	for (new i=1; i<=MaxClients; i++)
	{						
		if (hFireTimer[i] != INVALID_HANDLE)
		{
			if (CloseHandle(hFireTimer[i]))
				hFireTimer[i] = INVALID_HANDLE;
		}
		
		if (hShieldTimer[i] != INVALID_HANDLE)
		{
			if (CloseHandle(hShieldTimer[i]))
				hShieldTimer[i] = INVALID_HANDLE;
				
			g_ShieldDeployed[i] = false;
		}
	}
	
	
	// Not at map end since everyone is disconnected by then
	new humans = GetHumansNumber();
	if (humans > 0)
	{
		new total_drops = g_AmmoBoxNumber + g_HealthPackNumber + g_ZombieBloodNumber + g_PillsNumber + g_HoochNumber + g_AdrenalineNumber + g_BoxNadesNumber + g_AntiGasNumber + g_ShieldNumber + g_SpringNumber;
		
		LogToFileEx(g_szLogFileName,"======= Map %s ended ====================", g_szMapName);
		LogToFileEx(g_szLogFileName,"Allied Wins: %i", g_AlliedWins);
		LogToFileEx(g_szLogFileName,"Axis Wins  : %i", g_AxisWins);
		LogToFileEx(g_szLogFileName,"Axis Number: %i", GetAxisTeamNumber());
		LogToFileEx(g_szLogFileName,"Allies Number: %i", GetAlliedTeamNumber());
		LogToFileEx(g_szLogFileName,"Total drops: %i", total_drops);
		LogToFileEx(g_szLogFileName,"===============================================");
		LogToFileEx(g_szLogFileName, " ");
		
		//Get server ID
		new String:address[64], ip, String:port[16], String:ServerIp[16];
		ip = GetConVarInt(FindConVar("hostip"));
		Format(ServerIp, sizeof(ServerIp), "%i.%i.%i.%i", (ip >> 24) & 0x000000FF,(ip >> 16) & 0x000000FF,(ip >> 8) & 0x000000FF, ip & 0x000000FF);
		GetConVarString(FindConVar("hostport"), port, sizeof(port));
		Format(address, sizeof(address), "%s:%s", ServerIp, port);
		
		new String:query[1024];
		Format(query, sizeof(query), "INSERT INTO game (mapname, alliedwins, axiswins, gametype, server, players) VALUES('%s', '%i', '%i', '%i', '%s', '%i');", g_szMapName, g_AlliedWins, g_AxisWins, GetConVarInt(hL4DGameType), address, humans);
			
		//PrintToServer("Query: %s", query);
		SQL_TQuery(hDatabase, AddToDatabase, query, _, DBPrio_High);
	}
}

DisplayScores()
{
	#if DEBUG
		LogToFileEx(g_szLogFileName,"[L4DOD] Displaying scores");
	#endif
	
	new bestWitch = 0, bestEmo = 0, bestTank = 0, bestGasMan = 0, bestZombies = 0, bestTraitor = 0, bestHuman = 0, bestAnarchist = 0, bestUNG = 0, bestWraith=0, bestSkeleton = 0, bestHellSpawn=0;
	new bestWitchValue = 0, bestEmoValue = 0, bestTankValue = 0, bestGasManValue = 0, bestZombiesValue = 0, bestTraitorValue = 0, bestHumanValue = 0, bestAnarchistValue = 0, bestUNGValue = 0, bestWraithValue = 0, bestSkeletonValue = 0, bestHellSpawnValue=0;
	for (new i = 1; i<= MaxClients; i++)
	{
		if (!IsClientInGame(i) || IsFakeClient(i))
			continue;
				
		if (g_ScoreWitch[i] > bestWitchValue)
		{
			bestWitchValue = g_ScoreWitch[i];
			bestWitch = i;
		}
		if (g_ScoreEmo[i] > bestEmoValue)
		{
			bestEmoValue = g_ScoreEmo[i];
			bestEmo = i;
		}
		if (g_ScoreGasMan[i] > bestGasManValue)
		{
			bestGasManValue = g_ScoreGasMan[i];
			bestGasMan = i;
		}
		if (g_ScoreGreyDude[i] > bestTankValue)
		{
			bestTankValue = g_ScoreGreyDude[i];
			bestTank = i;
		}
		if (g_ScoreTraitor[i] > bestTraitorValue)
		{
			bestTraitorValue = g_ScoreTraitor[i];
			bestTraitor = i;
		}
		if (g_ScoreZombies[i] > bestZombiesValue)
		{
			bestZombiesValue = g_ScoreZombies[i];
			bestZombies = i;
		}
		if (g_ScoreHumans[i] > bestHumanValue)
		{
			bestHumanValue = g_ScoreHumans[i];
			bestHuman = i;
		}
		if (g_ScoreAnarchist[i] > bestAnarchistValue)
		{
			bestAnarchistValue = g_ScoreAnarchist[i];
			bestAnarchist = i;
		}
		if (g_ScoreUNG[i] > bestUNGValue)
		{
			bestUNGValue = g_ScoreUNG[i];
			bestUNG = i;
		}
		if (g_ScoreWraith[i] > bestWraithValue)
		{
			bestWraithValue = g_ScoreWraith[i];
			bestWraith = i;
		}
		if (g_ScoreSkeleton[i] > bestSkeletonValue)
		{
			bestSkeletonValue = g_ScoreSkeleton[i];
			bestSkeleton = i;
		}
		if (g_ScoreHellSpawn[i] > bestHellSpawnValue)
		{
			bestHellSpawnValue = g_ScoreHellSpawn[i];
			bestHellSpawn = i;
		}
	}
	
	new String:text[400], String:playername[16];
	Format(text, 400, "");

	Format(playername, 16, "%N", bestWitch);
	if (bestWitchValue > 0)
	{
		Format(text, 400, "%sWitches: %s [%i]\n", text,  playername, bestWitchValue);
		g_iMoney[bestWitch] += 20;
		if (IsClientInGame(bestWitch))
			PrintToChat(bestWitch, "[L4DOD] Cash Bonus for Top Witch Killer");
	}
		
	Format(playername, 16, "%N", bestEmo);
	if (bestEmoValue > 0)
	{
		Format(text, 400, "%sEmos: %s [%i]\n", text,  playername, bestEmoValue);
		g_iMoney[bestEmo] += 20;
		if (IsClientInGame(bestEmo))
			PrintToChat(bestEmo, "[L4DOD] Cash Bonus for Top Emo Killer");
	}
		
	Format(playername, 16, "%N", bestTank);
	if (bestTankValue > 0)
	{
		Format(text, 400, "%sGrey Dudes: %s [%i]\n", text, playername, bestTankValue);
		g_iMoney[bestTank] += 20;
		if (IsClientInGame(bestTank))
			PrintToChat(bestTank, "[L4DOD] Cash Bonus for Top Grey Dude Killer");
	}
		
	Format(playername, 16, "%N", bestGasMan);
	if (bestGasManValue > 0)
	{
		Format(text, 400, "%sGas Men: %s [%i]\n",  text, playername, bestGasManValue);
		g_iMoney[bestGasMan] += 20;
		if (IsClientInGame(bestGasMan))
			PrintToChat(bestGasMan, "[L4DOD] Cash Bonus for Top Gas Man Killer");
	}
		
	Format(playername, 16, "%N", bestTraitor);
	if (bestTraitorValue > 0)
	{
		Format(text, 400, "%sInfected: %s [%i]\n",  text, playername, bestTraitorValue);
		g_iMoney[bestTraitor] += 20;
		if (IsClientInGame(bestTraitor))
			PrintToChat(bestTraitor, "[L4DOD] Cash Bonus for Top Infected One Killer");
	}
		
	Format(playername, 16, "%N", bestAnarchist);
	if (bestAnarchistValue > 0)
	{
		Format(text, 400, "%sAnarchists: %s [%i]\n", text, playername, bestAnarchistValue);
		g_iMoney[bestAnarchist] += 20;
		if (IsClientInGame(bestAnarchist))
			PrintToChat(bestAnarchist, "[L4DOD] Cash Bonus for Top Anarchist Killer");
	}
		
	Format(playername, 16, "%N", bestUNG);
	if (bestUNGValue > 0)
	{
		Format(text, 400, "%sUNGs: %s [%i]\n", text, playername, bestUNGValue);
		g_iMoney[bestUNG] += 40;
		if (IsClientInGame(bestUNG))
			PrintToChat(bestUNG, "[L4DOD] Cash Bonus for Top UNG Killer");
	}
		
	Format(playername, 16, "%N", bestWraith);
	if (bestWraithValue > 0)
	{
		Format(text, 400, "%sWraiths: %s [%i]\n", text, playername, bestWraithValue);
		g_iMoney[bestWraith] += 20;
		if (IsClientInGame(bestWraith))
			PrintToChat(bestWraith, "[L4DOD] Cash Bonus for Top Wraith Killer");
	}
		
	Format(playername, 16, "%N", bestSkeleton);
	if (bestSkeletonValue > 0)
	{
		Format(text, 400, "%sSkeletons: %s [%i]\n", text, playername, bestSkeletonValue);
		g_iMoney[bestSkeleton] += 20;
		if (IsClientInGame(bestSkeleton))
			PrintToChat(bestSkeleton, "[L4DOD] Cash Bonus for Top Skeleton Killer");
	}
	
	Format(playername, 16, "%N", bestHellSpawn);
	if (bestHellSpawnValue > 0)
	{
		Format(text, 400, "%sHell Spawns: %s [%i]\n", text, playername, bestHellSpawnValue);
		g_iMoney[bestHellSpawn] += 20;
		if (IsClientInGame(bestHellSpawn))
			PrintToChat(bestHellSpawn, "[L4DOD] Cash Bonus for Top Hell Spawn Killer");
	}
	
	Format(playername, 16, "%N", bestZombies);
	if (bestZombiesValue > 0)
	{
		Format(text, 400, "%sZombies: %s [%i]\n", text, playername, bestZombiesValue);
		g_iMoney[bestZombies] += 20;
		if (IsClientInGame(bestZombies))
			PrintToChat(bestZombies, "[L4DOD] Cash Bonus for Top Zombie Killer");
	}
		
	Format(playername, 16, "%N", bestHuman);
	if (bestHumanValue > 0)
	{
		Format(text, 400, "%sHumans: %s [%i]", text, playername, bestHumanValue);
		g_iMoney[bestHuman] += 60;
		if (IsClientInGame(bestHuman))
			PrintToChat(bestHuman, "[L4DOD] Cash Bonus for Top Human Killer");
	}
	
	
	Unescape(text);
		
	ReplaceString(text, 400, "\\n", "\n");
	
	new Handle:mSayPanel = CreatePanel();
	SetPanelTitle(mSayPanel, "========== TOP SCORERS =========");
	DrawPanelItem(mSayPanel, "", ITEMDRAW_SPACER);
	DrawPanelText(mSayPanel, text);
	DrawPanelItem(mSayPanel, "", ITEMDRAW_SPACER);

	SetPanelCurrentKey(mSayPanel, 10);
	DrawPanelItem(mSayPanel, "Exit", ITEMDRAW_CONTROL);

	for(new i = 1; i <= MaxClients; i++)
	{
		if(IsClientInGame(i) && !IsFakeClient(i))
		{
			SendPanelToClient(mSayPanel, i, Handler_DoNothing, 10);
		}
	}

	CloseHandle(mSayPanel);
}

CloseTimers()
{
	#if DEBUG
		LogToFileEx(g_szLogFileName,"[L4DOD] Closing Timers");
	#endif
		
	g_bRoundOver = true;
	
	g_bRoundActive = false;
	
	for (new i=1; i<=MaxClients; i++)
	{
		if (g_hSearch_Timer[i] != INVALID_HANDLE)
		{
			KillTimer(g_hSearch_Timer[i]);
			g_hSearch_Timer[i] = INVALID_HANDLE;
		}
		
		if (hFireTimer[i] != INVALID_HANDLE)
		{
			KillTimer(hFireTimer[i]);
			hFireTimer[i] = INVALID_HANDLE;
		}
		
		if (hShieldTimer[i] != INVALID_HANDLE)
		{
			KillTimer(hShieldTimer[i]);
			hShieldTimer[i] = INVALID_HANDLE;
			g_ShieldDeployed[i] = false;
		}
	}
	
	if (hAmbientTimer != INVALID_HANDLE)
	{
		#if DEBUG
				LogToFileEx(g_szLogFileName,"[L4DOD] Ended Ambient Timer");
		#endif
		
		KillTimer(hAmbientTimer);
		hAmbientTimer = INVALID_HANDLE;
	}
	
	if (hSpawnCheckTimer != INVALID_HANDLE)
	{
		#if DEBUG
				LogToFileEx(g_szLogFileName,"[L4DOD] Ended SpawnCheck Timer");
		#endif
		
		KillTimer(hSpawnCheckTimer);
		hSpawnCheckTimer = INVALID_HANDLE;
	}
	
	if (hZombieSoundsTimer != INVALID_HANDLE)
	{
		#if DEBUG
				LogToFileEx(g_szLogFileName,"[L4DOD] Ended Sounds Timer");
		#endif
		
		KillTimer(hZombieSoundsTimer);
		hZombieSoundsTimer = INVALID_HANDLE;
	}
	
	if (hTeamCheck != INVALID_HANDLE)
	{
		#if DEBUG
				LogToFileEx(g_szLogFileName,"[L4DOD] Ended TeamCheck Timer");
		#endif
		
		KillTimer(hTeamCheck);
		hTeamCheck = INVALID_HANDLE;
	}
		
	if (hOneSecond != INVALID_HANDLE)
	{
		#if DEBUG
				LogToFileEx(g_szLogFileName,"[L4DOD] Ended Effects Timer");
		#endif
		
		KillTimer(hOneSecond);
		hOneSecond = INVALID_HANDLE;
	}
	
	if (hTenSecond != INVALID_HANDLE)
	{
		#if DEBUG
				LogToFileEx(g_szLogFileName,"[L4DOD] Ended 10 sec Timer");
		#endif
		
		KillTimer(hTenSecond);
		hTenSecond = INVALID_HANDLE;
	}
	
	if (hTenthSecond != INVALID_HANDLE)
	{
		#if DEBUG
				LogToFileEx(g_szLogFileName,"[L4DOD] Ended TenthSecond Timer");
		#endif
		
		KillTimer(hTenthSecond);
		hTenthSecond = INVALID_HANDLE;
	}
	
	if (hFlagTimer != INVALID_HANDLE)
	{
		#if DEBUG
				LogToFileEx(g_szLogFileName,"[L4DOD] Ended Flag Control Timer");
		#endif
		
		KillTimer(hFlagTimer);
		hFlagTimer = INVALID_HANDLE;
	}
}