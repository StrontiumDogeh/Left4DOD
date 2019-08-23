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

public Action:Timer_UpdateView(Handle:Timer)
{
	for(new i = 1; i <= MaxClients; i++)
	{
		if(!IsClientConnected(i) || !IsClientInGame(i) || !IsPlayerAlive(i) )
			continue;
	
		GetPlayerEye(i, g_fPosition[i]);
	}
	return Plugin_Continue;
}

public Action:Timer_CheckPlayers(Handle:Timer)
{
	for(new i = 1; i < MaxClients; i++)
	{
		if(!IsClientConnected(i) || !IsClientInGame(i))
			continue;

		CheckForAFK(i);
		HandleAFKClient(i);
	}
	return Plugin_Continue;
}

CheckForAFK(client)
{
	new Float:vecLoc[3];
	new iTeam = GetClientTeam(client);
	new bool:bSamePlace[3];

	if(iTeam > 1)
	{
		GetPlayerEye(client, vecLoc);

		for(new i = 0; i < 3; i++)
		{
			if(g_fPosition[client][i] == vecLoc[i])
				bSamePlace[i] = true;
			else
				bSamePlace[i] = false;
		}
		
		if(bSamePlace[0] && bSamePlace[1] && bSamePlace[2])
		{
			g_iTimeAFK[client]++;
		}
		else
		{
			g_iTimeAFK[client] = 0;
		}
	}
	else
	{
		if (!g_iSuspendAFK[client])
			g_iTimeAFK[client]++;
	}
}

HandleAFKClient(client)
{
	new iSpecTime;
	new iKickTime;
	new iTeam = GetClientTeam(client);
	
	iKickTime = 36; //6 minutes
	
	if (IsFakeClient(client))
	{
		iSpecTime = 2;
		iKickTime = 2000;
	}
	else if (GetEntProp(client, Prop_Send, "m_iPlayerClass") == 4)
	{
		iSpecTime = 5;
	}
	else if (iTeam == AXIS)
	{
		iSpecTime = 3;
	}
	else
	{
		iSpecTime = 6;
	}
	
	if (g_bIsSupporter[client] || g_IsMember[client] == 2)
	{
		iSpecTime = 6;
		iKickTime = 2000; //30 minutes
	}
	else if (g_IsMember[client] > 0)
	{
		iSpecTime = 6;
		iKickTime = 1800; //30 minutes
	}

	if(g_iTimeAFK[client] >= iSpecTime)
	{
		if (!IsFakeClient(client))
		{
			if(iTeam == ALLIES|| iTeam == AXIS)
			{
				PrintToChatAll("%N was moved to spectate for being AFK.", client);
				LogToFileEx(g_szLogFileName, "\"%L\" was moved to spectate for being AFK too long.", client);
				ChangeClientTeam(client, 1);  
				
				CreateTimer(1.0, DisplaySpecMenu, client, TIMER_FLAG_NO_MAPCHANGE);
			}
		}
	}
	
	if (g_iTimeAFK[client] == (iSpecTime) && iTeam < 2)
	{
		if (!IsFakeClient(client))
		{
			CreateTimer(1.0, DisplaySpecMenu, client, TIMER_FLAG_NO_MAPCHANGE);
		}
	}
	
	if(g_iTimeAFK[client] >= iKickTime)
	{
		if (!IsFakeClient(client) && !g_bIsSupporter[client])
		{
			if(iTeam == SPECTATOR || iTeam == UNASSIGNED)
			{
				PrintToChatAll("%N was kicked for being AFK too long.", client);
				LogToFileEx(g_szLogFileName, "\"%L\" was kicked for being AFK too long.", client);
				KickClient(client, "You were AFK for too long.");
			}
		}
	}
	
	return;
}

// This code was borrowed from Nican's spraytracer
bool:GetPlayerEye(client, Float:pos[3])
{
	new Float:vAngles[3], Float:vOrigin[3];
	GetClientEyePosition(client,vOrigin);
	GetClientEyeAngles(client, vAngles);
	
	new Handle:trace = TR_TraceRayFilterEx(vOrigin, vAngles, MASK_SHOT, RayType_Infinite, TraceEntityFilterPlayer);
	
	if(TR_DidHit(trace))
	{
		TR_GetEndPosition(pos, trace);
		CloseHandle(trace);
		return true;
	}
	CloseHandle(trace);
	return false;
}

public Action:DisplaySpecMenu(Handle:timer, any:client)
{
	if (IsClientInGame(client))
		SpecMenu(client);
	
	return Plugin_Handled;
}

SpecMenu(client)
{	
	new Handle:hSpecMenu = CreateMenu(MenuHandler_Spec);
	
	decl String:title[100];
	Format(title, sizeof(title), "%s", "Are you spectating?");
	SetMenuTitle(hSpecMenu, title);
	SetMenuExitButton(hSpecMenu, true);
	
	//1
	AddMenuItem(hSpecMenu, "yes", "Yes");
	
	//2
	AddMenuItem(hSpecMenu, "no", "No");
	
	SetMenuExitButton(hSpecMenu, false);
	DisplayMenu(hSpecMenu, client, 10);	
}

public MenuHandler_Spec(Handle:menu, MenuAction:action, client, param2)
{
	if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
	else if (action == MenuAction_Select)
	{
		decl String:info[32];		
		GetMenuItem(menu, param2, info, sizeof(info));
		
		if (StrEqual(info, "yes"))
		{
			g_iTimeAFK[client] = 0;
			PrintHelp(client, "*Continuing to spectate...", 0);
		}
	}
}