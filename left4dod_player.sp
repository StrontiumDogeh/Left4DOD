//
// SourceMod Script
//
// Developed by Dog
// June 2008
// http://www.theville.org
//


#include <sourcemod>
#include <sdktools>
#include <geoip>
#undef REQUIRE_PLUGIN
#include <adminmenu>

#define PLUGIN_VERSION "2.1.000" 

new Handle:g_Cvar_Limits
new Handle:g_hVoteMenu = INVALID_HANDLE

#define VOTE_CLIENTID	0
#define VOTE_USERID		1
#define VOTE_NAME		0
#define VOTE_NO 		"###no###"
#define VOTE_YES 		"###yes###"

new g_voteClient[2];
new g_votetype = 0;

new String:g_voteInfo[3][65];
new String:classstring[64];
new String:g_kickLog[PLATFORM_MAX_PATH];

new g_Class[MAXPLAYERS+1][10];
new g_isAdmin[MAXPLAYERS+1];

static const String:map_list[][] = 	{ "None", "dod_anzio", "dod_argentan", "dod_avalanche", "dod_donner", "dod_flash", "dod_kalt" };
static const String:classname[][] = { "Rifleman", "Assault", "Support", "Sniper", "MachineGunner", "Rocketman"};

new bool:g_Gagged[65];

public Plugin:myinfo =
{
	name = "Left4DoD Admin",
	author = "Dog",
	description = "Voting",
	version = PLUGIN_VERSION,
	url = "http://www.theville.org"
};

public OnPluginStart()
{
	CreateConVar("left4dod_admin", PLUGIN_VERSION, "Version of votes", FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_REPLICATED)
	g_Cvar_Limits = CreateConVar("left4dod_vote_limit", "0.30", "percent required for successful vote.");
	
	RegConsoleCmd("sm_votemute", Command_Votemute, "sm_votemute  ");
	RegConsoleCmd("sm_votesilence", Command_Votesilence, "sm_votesilence  ");
	RegConsoleCmd("sm_votegag", Command_Votegag, "sm_votegag  ");
	RegConsoleCmd("sm_votemg", Command_VoteMG, "sm_votemg  ");
	RegConsoleCmd("sm_votekick", Command_VoteKick, "sm_votekick  ");
	RegConsoleCmd("sm_votemap", Command_VoteMap, "sm_votemap ");
	RegConsoleCmd("sm_voteban", Command_VoteBan, "sm_voteban ");
	
	RegConsoleCmd("say", Command_Say);
	RegConsoleCmd("say_team", Command_Say);
	RegConsoleCmd("voicemenu", Command_VoiceMenu);
	
	HookEvent("player_changeclass", ChangeClassEvent, EventHookMode_Pre);
	
	LoadTranslations("common.phrases");
}

public OnMapStart()
{
	decl String:logpath[PLATFORM_MAX_PATH];
	FormatTime(logpath, sizeof(logpath), "logs/l4dod_cmds_%Y%m%d.log");
	BuildPath(Path_SM, g_kickLog, PLATFORM_MAX_PATH, logpath);
}

public OnClientAuthorized(client, const String:auth[])
{
	if (IsFakeClient(client) || !IsClientConnected(client))
	{
		return;
	}
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

public OnEventShutdown()
{
	UnhookEvent("player_changeclass", ChangeClassEvent);
}

public OnClientPostAdminCheck(client)
{
	if (!IsFakeClient(client))
	{
		g_isAdmin[client] = 0;
		
		for (new i = 1; i <= 9; i++)
		{
			g_Class[client][i] = 0;
		}
		
		if (GetUserFlagBits(client) & ADMFLAG_VOTE)
		{
			g_isAdmin[client] = 1;
			LogToFileEx(g_kickLog, "\"%L\" is an Admin with Vote Access", client);
		}
		else
		{
			new String:authid[64];
			GetClientAuthString(client, authid, sizeof(authid));
			
			if (GetGroupData(authid) == 2)
			{
				g_isAdmin[client] = 1;
				LogToFileEx(g_kickLog, "\"%L\" is an Admin with Vote Access (via Steam Group)", client);
			}
		}
	}
}

public OnClientDisconnect(client)
{
	g_Class[client][4] = 0;
	g_isAdmin[client] = 0;
}

public Action:ChangeClassEvent(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	new class  = GetEventInt(event, "class");
	
	if (g_Class[client][class] == 1)
	{
		PrintCenterText(client, "%s Class Unavailable", classname[class]);
		Format(classstring, sizeof(classstring), "joinclass %i", 1);
		FakeClientCommand(client, classstring);
		new team   = GetClientTeam(client);
		ShowVGUIPanel(client, team == 2 ? "class_ger" : "class_us");
	}
	return Plugin_Continue
}

public Action:Command_Say(client, args)
{
	if (client)
	{
		if (g_Gagged[client])
		{
			return Plugin_Handled;		
		}
	}
	
	return Plugin_Continue;
}

public Action:Command_VoiceMenu(client, args)
{
	if (client)
	{
		if (g_Gagged[client])
		{
			return Plugin_Handled	
		}
	}
	return Plugin_Continue
}
	
public Action:Command_Votemute(client, args)
{
	if (IsVoteInProgress())
	{
		ReplyToCommand(client, "*Vote in Progress");
		return Plugin_Handled;
	}	
	
	if (!TestVoteDelay(client))
	{
		return Plugin_Handled;
	}
	
	if (g_isAdmin[client] < 1)
	{
		ReplyToCommand(client, "* You need to be a Left4DOD Steam Group admin to use this command");
		return Plugin_Handled;
	}
	
	g_votetype = 0
	DisplayVoteTargetMenu(client);
		
	return Plugin_Handled
}

public Action:Command_Votesilence(client, args)
{
	if (IsVoteInProgress())
	{
		ReplyToCommand(client, "*Vote in Progress")
		return Plugin_Handled;
	}	
	
	if (!TestVoteDelay(client))
	{
		return Plugin_Handled
	}
	
	if (g_isAdmin[client] < 1)
	{
		ReplyToCommand(client, "* You need to be a Left4DOD Steam Group admin to use this command");
		return Plugin_Handled;
	}
	
	g_votetype = 1
	DisplayVoteTargetMenu(client);
		
	return Plugin_Handled
}

public Action:Command_Votegag(client, args)
{
	if (IsVoteInProgress())
	{
		ReplyToCommand(client, "*Vote in Progress")
		return Plugin_Handled;
	}	
	
	if (!TestVoteDelay(client))
	{
		return Plugin_Handled
	}
	
	if (g_isAdmin[client] < 1)
	{
		ReplyToCommand(client, "* You need to be a Left4DOD Steam Group admin to use this command");
		return Plugin_Handled;
	}
			
	g_votetype = 2
	DisplayVoteTargetMenu(client);
		
	return Plugin_Handled
}

public Action:Command_VoteMG(client, args)
{
	if (IsVoteInProgress())
	{
		ReplyToCommand(client, "*Vote in Progress");
		return Plugin_Handled
	}	
	
	if (!TestVoteDelay(client))
	{
		return Plugin_Handled
	}
	
	if (g_isAdmin[client] < 1)
	{
		ReplyToCommand(client, "* You need to be a Left4DOD Steam Group admin to use this command");
		return Plugin_Handled;
	}
	
	g_votetype = 3;
	DisplayVoteTargetMenu(client);
		
	return Plugin_Handled
}

public Action:Command_VoteKick(client, args)
{
	if (IsVoteInProgress())
	{
		ReplyToCommand(client, "*Vote in Progress");
		return Plugin_Handled;
	}	
	
	if (!TestVoteDelay(client))
	{
		return Plugin_Handled;
	}
	
	if (g_isAdmin[client] < 1)
	{
		ReplyToCommand(client, "* You need to be a Left4DOD Steam Group admin to use this command");
		return Plugin_Handled;
	}
	
	g_votetype = 4;
	DisplayVoteTargetMenu(client);
		
	return Plugin_Handled
}

public Action:Command_VoteBan(client, args)
{
	if (IsVoteInProgress())
	{
		ReplyToCommand(client, "*Vote in Progress");
		return Plugin_Handled;
	}	
	
	if (!TestVoteDelay(client))
	{
		return Plugin_Handled;
	}
	
	if (g_isAdmin[client] < 1)
	{
		ReplyToCommand(client, "* You need to be a Left4DOD Steam Group admin to use this command");
		return Plugin_Handled;
	}
	
	g_votetype = 6;
	DisplayVoteTargetMenu(client);
		
	return Plugin_Handled
}

public Action:Command_VoteMap(client, args)
{
	if (IsVoteInProgress())
	{
		ReplyToCommand(client, "*Vote in Progress");
		return Plugin_Handled
	}	
	
	if (!TestVoteDelay(client))
	{
		return Plugin_Handled
	}
	
	if (g_isAdmin[client] < 1)
	{	
		ReplyToCommand(client, "* You need to be a Left4DOD Steam Group admin to use this command");
		return Plugin_Handled;
	}
	
	g_votetype = 7;
	DisplayVoteMapMenu(client);
	
	return Plugin_Handled
}

DisplayVoteMapMenu(client)
{
	new Handle:hMenu = CreateMenu(SelectMap);
	
	decl String:title[100];
	Format(title, sizeof(title), "%s", "Choose map:");
	SetMenuTitle(hMenu, title);
	SetMenuExitBackButton(hMenu, true);
	
	AddMenuItem(hMenu, "1", "Anzio");
	AddMenuItem(hMenu, "2", "Argentan");
	AddMenuItem(hMenu, "3", "Avalanche");
	AddMenuItem(hMenu, "4", "Donner");
	AddMenuItem(hMenu, "5", "Flash");
	AddMenuItem(hMenu, "6", "Kalt");
	
	DisplayMenu(hMenu, client, 10);
}

public SelectMap(Handle:menu, MenuAction:action, param1, param2)
{
	if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
	else if (action == MenuAction_Select)
	{
		decl String:info[32], String:name[32];
		
		GetMenuItem(menu, param2, info, sizeof(info), _, name, sizeof(name));
		new target = StringToInt(info);

		DisplayVoteMenu(param1, target);
	}
}


DisplayVoteTargetMenu(client)
{
	new Handle:menu = CreateMenu(SelectPlayer);
	
	decl String:title[100];
	new String:playername[128]
	new String:identifier[64]
	Format(title, sizeof(title), "%s", "Choose player:");
	SetMenuTitle(menu, title);
	SetMenuExitBackButton(menu, true);
	
	for (new i = 1; i < MaxClients; i++)
	{
		if (IsClientInGame(i))
		{				
			if (IsFakeClient(i))
				continue;
				
			if (g_votetype == 3)
			{
				new class = GetEntProp(client, Prop_Send, "m_iPlayerClass");
				if (class == 4 && GetClientTeam(i) == 2)
				{	
					GetClientName(i, playername, sizeof(playername));
					Format(identifier, sizeof(identifier), "%i", i);
					AddMenuItem(menu, identifier, playername);
				}
			}
			else
			{
				GetClientName(i, playername, sizeof(playername));
				Format(identifier, sizeof(identifier), "%i", i);
				AddMenuItem(menu, identifier, playername);
			}
		}
	}
	
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}


public SelectPlayer(Handle:menu, MenuAction:action, param1, param2)
{
	if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
	else if (action == MenuAction_Select)
	{
		decl String:info[32], String:name[32];
		new target;
		
		GetMenuItem(menu, param2, info, sizeof(info), _, name, sizeof(name));
		target = StringToInt(info);

		if (target == 0)
		{
			PrintToChat(param1, "*%s", "Player no longer available");
		}
		else
		{
			DisplayVoteMenu(param1, target);
		}
	}
}

DisplayVoteMenu(client, target)
{
	g_voteClient[VOTE_CLIENTID] = target;
	
	if (g_votetype != 5 || g_votetype != 7)
	{
		g_voteClient[VOTE_USERID] = GetClientUserId(target);
		GetClientName(target, g_voteInfo[VOTE_NAME], sizeof(g_voteInfo[]));
	}

	if (g_votetype == 0)
	{
		LogToFileEx(g_kickLog, "\"%L\" initiated a mute vote against \"%L\"", client, target);
		PrintToChatAll("*%N initiated a vote mute against %N", client, target);

		g_hVoteMenu = CreateMenu(Handler_VoteCallback, MenuAction:MENU_ACTIONS_ALL);
		SetMenuTitle(g_hVoteMenu, "Mute Player:");
	}
	else if (g_votetype == 1)
	{
		LogToFileEx(g_kickLog, "\"%L\" initiated a silence vote against \"%L\"", client, target);
		PrintToChatAll("*%N initiated a vote silence against %N", client, target);
		
		g_hVoteMenu = CreateMenu(Handler_VoteCallback, MenuAction:MENU_ACTIONS_ALL);
		SetMenuTitle(g_hVoteMenu, "Silence Player:");
	}
	else if (g_votetype == 2)
	{
		LogToFileEx(g_kickLog, "\"%L\" initiated a gag vote against \"%L\"", client, target);
		PrintToChatAll("*%N initiated a vote gag against %N", client, target);
		
		g_hVoteMenu = CreateMenu(Handler_VoteCallback, MenuAction:MENU_ACTIONS_ALL);
		SetMenuTitle(g_hVoteMenu, "Gag Player:");
	}
	else if (g_votetype == 3)
	{
		LogToFileEx(g_kickLog, "\"%L\" initiated a MG vote against \"%L\"", client, target);
		PrintToChatAll("*%N initiated a MG vote against %N", client, target);
		
		g_hVoteMenu = CreateMenu(Handler_VoteCallback, MenuAction:MENU_ACTIONS_ALL);
		SetMenuTitle(g_hVoteMenu, "Remove MG from Player:");
	}
	else if (g_votetype == 4)
	{
		LogToFileEx(g_kickLog, "\"%L\" initiated a vote kick against \"%L\"", client, target);
		PrintToChatAll("*%N initiated a votekick against %N", client, target);
		
		g_hVoteMenu = CreateMenu(Handler_VoteCallback, MenuAction:MENU_ACTIONS_ALL);
		SetMenuTitle(g_hVoteMenu, "Kick Player:");
	}
	else if (g_votetype == 6)
	{
		LogToFileEx(g_kickLog, "\"%L\" initiated a vote ban against \"%L\"", client, target);
		PrintToChatAll("*%N initiated a voteban against %N", client, target);
		
		g_hVoteMenu = CreateMenu(Handler_VoteCallback, MenuAction:MENU_ACTIONS_ALL);
		SetMenuTitle(g_hVoteMenu, "Ban Player:");
	}
	else if (g_votetype == 7)
	{
		LogToFileEx(g_kickLog, "\"%L\" initiated a vote to change the map", client);
		PrintToChatAll("*%N initiated a vote to change the map", client);
		
		g_hVoteMenu = CreateMenu(Handler_VoteCallback, MenuAction:MENU_ACTIONS_ALL);
		SetMenuTitle(g_hVoteMenu, "Change map to:");
	}
	
	AddMenuItem(g_hVoteMenu, VOTE_YES, "Yes");
	AddMenuItem(g_hVoteMenu, VOTE_NO, "No");
	SetMenuExitButton(g_hVoteMenu, false);
	VoteMenuToAll(g_hVoteMenu, 20);
}

public Handler_VoteCallback(Handle:menu, MenuAction:action, param1, param2)
{
	if (action == MenuAction_End)
	{
		VoteMenuClose();
	}
	else if (action == MenuAction_Display)
	{
		decl String:title[64];
		GetMenuTitle(menu, title, sizeof(title));
		
		decl String:buffer[255];
		
		if (g_votetype == 7)
		{
			Format(buffer, sizeof(buffer), "%s %s", title, map_list[g_voteClient[VOTE_CLIENTID]]);
		}
		else
			Format(buffer, sizeof(buffer), "%s %s", title, g_voteInfo[VOTE_NAME]);

		new Handle:panel = Handle:param2;
		SetPanelTitle(panel, buffer);
	}
	else if (action == MenuAction_DisplayItem)
	{
		decl String:display[64];
		GetMenuItem(menu, param2, "", 0, _, display, sizeof(display));
	 
	 	if (strcmp(display, "No") == 0 || strcmp(display, "Yes") == 0)
	 	{
			decl String:buffer[255];
			Format(buffer, sizeof(buffer), "%s", display);

			return RedrawMenuItem(buffer);
		}
	}
	/* else if (action == MenuAction_Select)
	{
		VoteSelect(menu, param1, param2);
	}*/
	else if (action == MenuAction_VoteCancel && param1 == VoteCancel_NoVotes)
	{
		PrintToChatAll("*%s", "No Votes Cast");
	}	
	else if (action == MenuAction_VoteEnd)
	{
		decl String:item[64], String:display[64];
		new Float:percent, Float:limit, votes, totalVotes;

		GetMenuVoteInfo(param2, votes, totalVotes);
		GetMenuItem(menu, param1, item, sizeof(item), _, display, sizeof(display));
		
		if (strcmp(item, VOTE_NO) == 0 && param1 == 1)
		{
			votes = totalVotes - votes; // Reverse the votes to be in relation to the Yes option.
		}
		
		percent = GetVotePercent(votes, totalVotes);
		
		limit = GetConVarFloat(g_Cvar_Limits);
		
		if ((strcmp(item, VOTE_YES) == 0 && FloatCompare(percent,limit) < 0 && param1 == 0) || (strcmp(item, VOTE_NO) == 0 && param1 == 1))
		{
			LogToFileEx(g_kickLog, "Vote failed.");
			PrintToChatAll("*%s", "Vote Failed", RoundToNearest(100.0*limit), RoundToNearest(100.0*percent), totalVotes);
		}
		else
		{
			PrintToChatAll("*%s", "Vote Successful", RoundToNearest(100.0*percent), totalVotes);			
			if (g_votetype == 0)
			{
				PrintToChatAll("*%s", "Muted target", "_s", g_voteInfo[VOTE_NAME]);
				LogToFileEx(g_kickLog, "Vote mute successful, muted \"%L\" ", g_voteClient[VOTE_CLIENTID]);
				SetClientListeningFlags( g_voteClient[VOTE_CLIENTID], VOICE_MUTED);					
			}
			else if (g_votetype == 1)
			{
				PrintToChatAll("*%s", "Silenced target", "_s", g_voteInfo[VOTE_NAME]);	
				LogToFileEx(g_kickLog, "Vote silence successful, silenced \"%L\" ", g_voteClient[VOTE_CLIENTID]);
				SetClientListeningFlags( g_voteClient[VOTE_CLIENTID], VOICE_MUTED);
				g_Gagged[g_voteClient[VOTE_CLIENTID]] = true;
			}		
			else if (g_votetype == 2)
			{
				PrintToChatAll("*%s", "Gagged target", "_s", g_voteInfo[VOTE_NAME]);	
				LogToFileEx(g_kickLog, "Vote gag successful, gagged \"%L\" ", g_voteClient[VOTE_CLIENTID]);
				g_Gagged[g_voteClient[VOTE_CLIENTID]] = true;
			}
			else if (g_votetype == 3)
			{
				PrintToChatAll("*%s", "Removed MG from", "_s", g_voteInfo[VOTE_NAME]);	
				LogToFileEx(g_kickLog, "MG vote successful, removed MG from \"%L\" ", g_voteClient[VOTE_CLIENTID]);
				g_Class[g_voteClient[VOTE_CLIENTID]][4] = 1;
				
				Format(classstring, sizeof(classstring), "joinclass %i", 1);
				FakeClientCommand(g_voteClient[VOTE_CLIENTID], classstring);
				new team   = GetClientTeam(g_voteClient[VOTE_CLIENTID]);
				ShowVGUIPanel(g_voteClient[VOTE_CLIENTID], team == 3 ? "class_ger" : "class_us");
			}
			else if (g_votetype == 4)
			{
				if (IsClientInGame(g_voteClient[VOTE_CLIENTID]))
				{
					PrintToChatAll("*%s", "Kicked target", "_s", g_voteInfo[VOTE_NAME]);	
					LogToFileEx(g_kickLog, "Vote kick successful, kicked \"%L\" ", g_voteClient[VOTE_CLIENTID]);
					KickClient(g_voteClient[VOTE_CLIENTID]);
				}
			}
			else if (g_votetype == 6)
			{
				if (IsClientInGame(g_voteClient[VOTE_CLIENTID]))
				{
					PrintToChatAll("*%s", "Banned target", "_s", g_voteInfo[VOTE_NAME]);	
					LogToFileEx(g_kickLog, "Vote ban successful, banned \"%L\" ", g_voteClient[VOTE_CLIENTID]);
					BanClient(g_voteClient[VOTE_CLIENTID], 30, BANFLAG_AUTO, "Vote banned", "Banned by vote", "sm_voteban");
				}
			}
			else if (g_votetype == 7)
			{
				PrintToChatAll("*Changed the map level to %s", map_list[g_voteClient[VOTE_CLIENTID]]);	
				LogToFileEx(g_kickLog, "Vote map successful, changed to %s", map_list[g_voteClient[VOTE_CLIENTID]]);
				
				PrintToChatAll("*Changing map");
				
				new Handle:dp;
				CreateDataTimer(5.0, Timer_ChangeMap, dp);
				WritePackString(dp, map_list[g_voteClient[VOTE_CLIENTID]]);
			}
		}
	}
	return 0;
}

VoteMenuClose()
{
	CloseHandle(g_hVoteMenu)
	g_hVoteMenu = INVALID_HANDLE
}

Float:GetVotePercent(votes, totalVotes)
{
	return FloatDiv(float(votes),float(totalVotes))
}

bool:TestVoteDelay(client)
{
 	new delay = CheckVoteDelay()
 	
 	if (delay > 0)
 	{
 		if (delay > 60)
 		{
 			ReplyToCommand(client, "*Vote delay: %i mins", delay % 60)
 		}
 		else
 		{
 			ReplyToCommand(client, "*Vote delay: %i secs", delay)
 		}
 		
 		return false
 	}
 	
	return true
}

public Action:Timer_ChangeMap(Handle:timer, Handle:dp)
{
	decl String:mapname[65];
	
	ResetPack(dp);
	ReadPackString(dp, mapname, sizeof(mapname));
	
	ForceChangeLevel(mapname, "sm_votemap Result");
	
	return Plugin_Stop;
}