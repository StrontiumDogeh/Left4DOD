/**
 * =============================================================================
 * SourceMod Left4DoD for Day of Defeat Source
 * (C)2009 - 2010 Dog - www.thevilluns.org
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
 
SpawnZombies(client)
{
	if (IsClientInGame(client) && IsPlayerAlive(client) && g_numMaster[client] > 0 && g_canMaster[client])
	{
		g_canMaster[client] = false;
		
		g_numMaster[client]--;
		if (g_numMaster[client] <= 0)
			g_numMaster[client] = 0;
			
		if (!IsFakeClient(client))
			PrintHintText(client, "Spawns left: %i", g_numMaster[client]);
		
		CreateTimer(8.0, AllowMasterTeleport, client, TIMER_FLAG_NO_MAPCHANGE);

		new Float:ClientAngle[3], Float:playerEyes[3], Float:pos[3], Float:AngleVector[3], Float:ClientStart[3];

		GetClientEyePosition(client,playerEyes);
		GetClientEyeAngles(client, ClientAngle);
		
		if (IsFakeClient(client))
		{
			ClientAngle[1] += GetRandomFloat(-45.0, 45.0);
			ClientAngle[2] += 20.0;
		}
		
		#if DEBUG
			LogToFileEx(g_szLogFileName,"[L4DOD] Grey Dude attempting to spawn Zombies:%i", client);
		#endif
							
		new Handle:trace = TR_TraceRayFilterEx(playerEyes, ClientAngle, MASK_SOLID, RayType_Infinite, TraceEntityFilterPlayer);
		new Float:end[3];
		
		if(TR_DidHit(trace))
		{
			TR_GetEndPosition(end, trace);
			
			ClientAngle[0] = 0.0;
								
			GetAngleVectors(ClientAngle, AngleVector, NULL_VECTOR, NULL_VECTOR);
			NormalizeVector(AngleVector, AngleVector);
			ScaleVector(AngleVector, 80.0);
			SubtractVectors(end, AngleVector, pos);
			
			pos[2] +=10;
		}
		CloseHandle(trace);
		
		if (!TR_PointOutsideWorld(end))
		{
			if (CheckLocationNearAlliedSpawn(end, 200.0) && g_mapType != 1)
			{
				if (!IsFakeClient(client))
					PrintHelp(client, "*TOO CLOSE TO ALLIED SPAWN", 3);
			}
			else
			{
				#if DEBUG
					LogToFileEx(g_szLogFileName,"[L4DOD] Grey Dude spawned Zombies:%i", client);
				#endif
				
				new bot;
				new NumberofZombies = g_AlliedWins - g_AxisWins + 2;
				
				if (NumberofZombies < 2)
					NumberofZombies = 2;
				else if (NumberofZombies >= 4)
					NumberofZombies = 4;
											
				for (new i=1; i <= NumberofZombies; i++)
				{
					bot = SelectBot(0);
					
					if (bot > 0 && IsClientInGame(bot) && IsPlayerAlive(bot))
					{
						GetClientAbsOrigin(bot, ClientStart);
												
						new Handle:pack;
						hTeleportData[bot] = CreateDataTimer(2.0, CheckPostTeleport, pack, TIMER_FLAG_NO_MAPCHANGE);
						WritePackFloat(pack, ClientStart[0]);
						WritePackFloat(pack, ClientStart[1]);
						WritePackFloat(pack, ClientStart[2]);
						WritePackFloat(pack, pos[2]);
						WritePackCell(pack, bot);
						
						//Remove spawn protection in case
						SetEntProp(bot, Prop_Data, "m_takedamage", 2, 1);
						
						g_wasTP[bot] = client;
						CreateTimer(6.0, ResetBotTPOwner, bot, TIMER_FLAG_NO_MAPCHANGE);
						
						pos[2] += 10;
						TeleportEntity(bot, pos, NULL_VECTOR, NULL_VECTOR);
						PlaySound(bot, false);
						PlaySound(client, false);
						
						new Float:dir[3] = {0.0, 0.0, 0.0};
												
						TE_SetupSparks(ClientStart, dir, 5000, 1000);
						TE_SendToAll();
						
						TE_SetupSparks(pos, dir, 5000, 1000);
						TE_SendToAll();
												
						//Reset their target
						g_iBotsTarget[bot] = 0;
						GetNearestWaypoint(bot);
					}
				}
				
				new Float:startpos[3];
				startpos[0] = playerEyes[0];
				startpos[1] = playerEyes[1];
				startpos[2] = playerEyes[2] - 30.0;
				
				/* stock TE_SetupBeamPoints(const Float:start[3], const Float:end[3], ModelIndex, HaloIndex, StartFrame, FrameRate, Float:Life,    
          		                         Float:Width, Float:EndWidth, FadeLength, Float:Amplitude, const Color[4], Speed) */
				
				TE_SetupBeamPoints(startpos, pos, GunSmokeSprite, 0, 0, 0, 0.9, Float:10.0, Float:10.0, 5, 5.0, g_AxisColour, 3);
				TE_SendToAll();
								
				EmitSoundToAll("weapons/physcannon/energy_disintegrate4.wav", client);
				
				AddParticle(client, "smokegrenade", 2.0, 10.0);
				
				PlaySound(client, false);
			}
		}
		else
			if (!IsFakeClient(client))
				PrintHelp(client, "*STAY WITHIN THE MAP", 3);
			
		if (!IsFakeClient(client))
		{
			SetEntPropFloat(client, Prop_Send, "m_flProgressBarStartTime", GetGameTime());
			SetEntProp(client, Prop_Send, "m_iProgressBarDuration", 8);
		}
	}
}

public Action:AllowMasterTeleport(Handle:timer, any:client)
{
	g_canMaster[client] = true;
		
	if (IsClientInGame(client) && !IsFakeClient(client) && IsPlayerAlive(client) && GetClientTeam(client) == 3 && g_ZombieType[client] == 1)
	{
		SetEntPropFloat(client, Prop_Send, "m_flProgressBarStartTime", GetGameTime());
		SetEntProp(client, Prop_Send, "m_iProgressBarDuration", 0);
		EmitSoundToClient(client, "buttons/blip1.wav");
	}
		
	return Plugin_Continue;
}

public Action:ResetBotTPOwner(Handle:timer, any:client)
{
	g_wasTP[client] = 0;
				
	return Plugin_Continue;
}