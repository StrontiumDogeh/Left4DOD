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
 
public Action:TeamEvent(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	g_iTimeAFK[client] = 0;
	
	if (client > 0 && IsClientInGame(client) && !IsFakeClient(client) && GetConVarInt(hL4DOn))
	{
		new mapSkyboxFogColor = 5 | (21 << 8) | (24 << 16);
		new mapSkyboxFrightColor = 2 | (2 << 8) | (2 << 16);
		
		if (GetConVarBool(hL4DFright))
		{
			SetEntProp(client, Prop_Send, "m_skybox3d.fog.enable", 1);
			SetEntProp(client, Prop_Send, "m_skybox3d.fog.colorPrimary", mapSkyboxFrightColor);
			SetEntProp(client, Prop_Send, "m_skybox3d.fog.colorSecondary", mapSkyboxFrightColor);
			SetEntPropFloat(client, Prop_Send, "m_skybox3d.fog.start", 0.0);
			SetEntPropFloat(client, Prop_Send, "m_skybox3d.fog.end", 10.0);
		}
		else
		{
			SetEntProp(client, Prop_Send, "m_skybox3d.fog.enable", 1);
			SetEntProp(client, Prop_Send, "m_skybox3d.fog.colorPrimary", mapSkyboxFogColor);
			SetEntProp(client, Prop_Send, "m_skybox3d.fog.colorSecondary", mapSkyboxFogColor);
			SetEntPropFloat(client, Prop_Send, "m_skybox3d.fog.start", 0.0);
			SetEntPropFloat(client, Prop_Send, "m_skybox3d.fog.end", 80.0);
		}
	}
			
	return Plugin_Handled;
}

public Action:ChangeClassEvent(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
		
	if (GetClientTeam(client) == AXIS && !IsFakeClient(client))
	{
		return Plugin_Handled;
	}
	else
		return Plugin_Continue;
}

public Action:CheckTeam(Handle:timer, any:client)
{
	if (!GetConVarInt(hL4DSetup))
	{
		if (g_bRoundOver)
		{
			hTeamCheck = INVALID_HANDLE;
			return Plugin_Stop;
		}
		
		//Get the Capping Times
		GetFlagCapTimes();
		
		//Turn off team checking for tournament mode
		if (GetConVarInt(hL4DGameType) == 2)
			return Plugin_Handled;
		
		//Get the number of Allies
		g_Allies = GetAlliedTeamNumber();
		
		//Get the total number of humans
		new NumofHumans = GetHumansNumberOnTeams();
			
		if (GetConVarInt(hL4DGameType) == 0)
		{
			new NumofAxis;
			
			switch (NumofHumans)
			{		
				case 7,8,9,10,11,12,13:
					NumofAxis = 1;
				
				case 14,15:
					NumofAxis = 2;
				
				case 16,17:
					NumofAxis = 3;
				
				case 18,19:
					NumofAxis = 4;
				
				case 20,21,22,23:
					NumofAxis = 5;
					
				default: 
					NumofAxis = 0;
			}
			
			//if there are more than 11 humans on the server
			//then add win difference
			if (NumofHumans > 10)
			{
				new diff = g_AxisWins - g_AlliedWins;
					
				NumofAxis = NumofAxis - diff;
				if (NumofAxis <= 0)
					NumofAxis = 0;
			}
					
			if (GetAxisTeamNumber() > NumofAxis)
			{
				//Buffer
				g_Checking++;
				
				if (g_Checking == 20)
					PrintToChatAll("*Teams will autobalance in 30 seconds");
					
				if (g_Checking > 50)
				{
					new playerArray[33];
					new numAxisHumans = 0;
					
					for (new human = 1; human <= MaxClients; human++)
					{					
						if (IsClientInGame(human) && !IsFakeClient(human) && GetClientTeam(human) == AXIS)
						{
							if (GetUserFlagBits(human) & ADMFLAG_ROOT || GetUserFlagBits(human) & ADMFLAG_BAN)
								continue;
								
							playerArray[numAxisHumans] = human;
							numAxisHumans++;
						}
					}
					
					new lowestSwaps = 20, lowestPlayer = 0;
					for (new i = 0; i<= numAxisHumans-1; i++)
					{								
						if (g_iSwapped[playerArray[i]] < lowestSwaps)
						{
							lowestSwaps = g_iSwapped[playerArray[i]];
							lowestPlayer = playerArray[i];
						}
					}
					
					if (lowestPlayer > 0 && IsClientInGame(lowestPlayer))
					{									
						ChangeClientTeam(lowestPlayer, 1);
						g_szPlayerWeapon[lowestPlayer] = "";
						ChangeClientTeam(lowestPlayer, 2);
						ShowVGUIPanel(lowestPlayer, "class_us", INVALID_HANDLE, true);
						ClientCommand(lowestPlayer, "cls_garand");
						PrintHelp(lowestPlayer, "*Moved to Allies to even out the teams", 3);
						PrintHelp(lowestPlayer, "*Moved to Allies to even out the teams", 0);		
						PrintToChatAll("*%N was moved to Allies to balance the teams", lowestPlayer);
						g_iSwapped[lowestPlayer]++;
					}
					
					g_Checking = 0;
				}
			}
		}			
	}
	return Plugin_Handled;
}

public Action:Command_JoinTeam(client, args)
{
	if (GetConVarInt(hL4DOn))
	{
		if (IsFakeClient(client))
		{
			return Plugin_Continue;
		}

		if (GetUserFlagBits(client) & ADMFLAG_ROOT)
		{
			return Plugin_Continue;
		}
		
		new String:teamnumber[2];
		GetCmdArg(1,teamnumber,2);
		
		new team = StringToInt(teamnumber);
		new NumofHumans = GetHumansNumberOnTeams();
		new NumofAxis;
		
		if (GetConVarInt(hL4DGameType) == 0)
		{			
			switch (NumofHumans)
			{		
				case 7,8,9,10,11,12,13:
					NumofAxis = 1;
				
				case 14,15:
					NumofAxis = 2;
				
				case 16,17:
					NumofAxis = 3;
				
				case 18,19:
					NumofAxis = 4;
				
				case 20,21,22,23:
					NumofAxis = 5;
					
				default: 
					NumofAxis = 0;
			}
			
			//if there are more than 11 humans on the server
			//then add win difference
			if (NumofHumans > 10)
			{
				new diff = g_AxisWins - g_AlliedWins;
					
				NumofAxis = NumofAxis - diff;
				if (NumofAxis <= 0)
					NumofAxis = 0;
			}
		}
		
		if (team == AXIS)
		{
			if (GetConVarInt(hL4DGameType) == 0)
			{
				if (!g_switchSpec[client])
				{
					if (GetAxisTeamNumber() >= NumofAxis)
					{
						if (NumofAxis != 5)
						{
							PrintHelp(client, "*Zombie team is full - Try again when there are more Allies", 0);
							PrintHelp(client, "*Zombie team is full - Try again when there are more Allies", 3);
						}
						else
						{
							PrintHelp(client, "*Zombie team is full", 0);
							PrintHelp(client, "*Zombie team is full", 3);
						}
						
						ChangeClientTeam(client, ALLIES);
						ShowVGUIPanel(client, "class_us" , _, true);
							
						return Plugin_Handled;
					}
				}
				else
				{
					PrintHelp(client, "*Do not Spec switch to join Zombies", 0);
					PrintHelp(client, "*Do not Spec switch to join Zombies", 3);
					
					ChangeClientTeam(client, ALLIES);
					ShowVGUIPanel(client, "class_us" , _, true);
						
					return Plugin_Handled;
				}
			}
			else if (GetConVarInt(hL4DGameType) == 1)
			{
				PrintHelp(client, "* You must play as Allies", 0);
				PrintHelp(client, "* You must play as Allies", 3);
				PrintHelp(client, "*Try our other servers for Versus mode", 0);
				ChangeClientTeam(client, ALLIES);
				ShowVGUIPanel(client, "class_us" , _, true);
						
				return Plugin_Handled;
			}
						
			// Passed tests - can join Zombies
			
			//Make sure weapons are zeroed on team change
			g_szPlayerWeapon[client] = "";
			g_szPlayerSecondaryWeapon[client] = "";
			g_szPlayerGrenadeWeapon[client] = "";
			
			return Plugin_Continue;
			
		}
		
		else if (team == ALLIES)
		{
			SDKUnhook(client, SDKHook_SetTransmit, Hook_SetTransmitInvisible);
			
			if (GetConVarInt(hL4DGameType) == 0)
			{
				if (GetAlliedTeamNumber() >= 16)
				{
					ChangeClientTeam(client, AXIS);
					ShowVGUIPanel(client, "class_ger" , _, true);
					
					PrintHelp(client, "*Allied Team is full", 0);
					PrintHelp(client, "*Allied team is full", 3);
					
					return Plugin_Handled;
				}
				
				g_switchSpec[client] = false;
								
				//Passed tests - can join Allies
				g_ZombieType[client] = -1;
				
			}	
			
			return Plugin_Continue;
		}
		
		else if (team == 1)
		{			
			if (IsPlayerAlive(client) && GetConVarInt(hL4DGameType) != 2)
			{
				PrintHelp(client, "*You can only join Spectators when you are dead", 0);
				
				if (GetAlliedTeamNumber() <= MINIMUMALLIES)
					g_switchSpec[client] = true;
					
				return Plugin_Handled;
			}
			else
			{
				g_switchSpec[client] = true;
				g_ZombieType[client] = -1;
				ClientCommand(client, "r_screenoverlay 0");
				
				return Plugin_Continue;
			}
		}		
	}
	return Plugin_Continue;
}

public Action:Command_JoinClass(client, args)
{	
	return Plugin_Continue;
}