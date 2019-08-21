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
 
 Teleport(client)
 {
	if (IsClientInGame(client) && IsPlayerAlive(client) && g_numTP[client] > 0 && g_canTP[client])
	{
		g_canTP[client] = false;
		
		g_numTP[client]--;
		if (g_numTP[client] <= 0)
			g_numTP[client] = 0;
		
		if (!IsFakeClient(client))
			PrintHintText(client, "Teleports left: %i", g_numTP[client]);
								
		new Float:ClientAngle[3], Float:playerEyes[3], Float:pos[3], Float:AngleVector[3], Float:ClientStart[3];

		GetClientEyePosition(client,playerEyes);
		GetClientEyeAngles(client, ClientAngle);
		GetClientAbsOrigin(client, ClientStart);
		
		if (IsFakeClient(client))
		{
			ClientAngle[1] += GetRandomFloat(-45.0, 45.0);
			ClientAngle[2] += 10.0;
		}
							
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
		}
		CloseHandle(trace);
		
		if (!TR_PointOutsideWorld(end))
		{
			if (CheckLocationNearAlliedSpawn(end, 400.0) && g_mapType != 1)
			{
				if (!IsFakeClient(client))
					PrintHelp(client, "*TOO CLOSE TO ALLIED SPAWN", 3);
			}
			else
			{
				#if DEBUG
					LogToFileEx(g_szLogFileName,"[L4DOD] Witch teleported:%i", client);
				#endif
		
				new Handle:pack;
				hTeleportData[client] = CreateDataTimer(2.0, CheckPostTeleport, pack, TIMER_FLAG_NO_MAPCHANGE);
				WritePackFloat(pack, ClientStart[0]);
				WritePackFloat(pack, ClientStart[1]);
				WritePackFloat(pack, ClientStart[2]);
				WritePackFloat(pack, pos[2]);
				WritePackCell(pack, client);
				
				AddParticle(client, "smokegrenade_jet", 2.0, 10.0);
				AttachParticle(client, "rockettrail", 2.0);
				pos[2] += 10;
				TeleportEntity(client, pos, NULL_VECTOR, NULL_VECTOR);
				AddParticle(client, "smokegrenade", 2.0, 10.0);
				
				ClientStart[2] += 30.0;
				pos[2] += 30.0;
				
				/* stock TE_SetupBeamPoints(const Float:start[3], const Float:end[3], ModelIndex, HaloIndex, StartFrame, FrameRate, Float:Life,    
          		                         Float:Width, Float:EndWidth, FadeLength, Float:Amplitude, const Color[4], Speed) */
			
				TE_SetupBeamPoints(ClientStart, pos, GunSmokeSprite, 0, 0, 30, 2.0, Float:10.0, Float:10.0, 5, 0.0, g_AxisColour, 1);
				TE_SendToAll();
				
				for (new i = 0; i < 4; i++)
					PlaySound(client, false);
			}
		}
		else
		{
			if (!IsFakeClient(client))
				PrintHelp(client, "*STAY WITHIN THE MAP", 3);
		}
			
		if (!IsFakeClient(client))
		{
			CreateTimer(10.0, AllowBotTeleport, client, TIMER_FLAG_NO_MAPCHANGE);
			SetEntPropFloat(client, Prop_Send, "m_flProgressBarStartTime", GetGameTime());
			SetEntProp(client, Prop_Send, "m_iProgressBarDuration", 10);
		}
		else
		{
			CreateTimer(8.0, AllowBotTeleport, client, TIMER_FLAG_NO_MAPCHANGE);
		}
	}
 }
 
RelocateBotBehindPlayer(any:bot)
{
	if (bot > 0 && IsClientInGame(bot) && IsPlayerAlive(bot) &&  g_iBotsTarget[bot] > 0 && IsClientInGame(g_iBotsTarget[bot]) && IsPlayerAlive(g_iBotsTarget[bot]) && g_canTP[bot])
	{
		#if DEBUG
			LogToFileEx(g_szLogFileName,"[L4DOD] Relocate behind player function executed");
		#endif
		
		// Don't let bot relocate again for a while
		g_canTP[bot] = false;
		CreateTimer(10.0, AllowBotTeleport, bot, TIMER_FLAG_NO_MAPCHANGE);
		
		new Float:ClientVector[3], Float:ClientAngle[3], Float:AngleVector[3], Float:TeleportTo[3];
		GetClientAbsOrigin(g_iBotsTarget[bot], ClientVector);
		GetClientEyeAngles(g_iBotsTarget[bot], ClientAngle);
		
		PlaySound(bot, false);
		
		new rnd = GetRandomInt(0, 5);
		
		if (rnd <= 3)
		{
			//Get the angle behind the player
			ClientAngle[0] = 0.0;
			//ClientAngle[1] += 180.0;
			
			GetAngleVectors(ClientAngle, AngleVector, NULL_VECTOR, NULL_VECTOR);
			NormalizeVector(AngleVector, AngleVector);
			ScaleVector(AngleVector, 60.0);
			SubtractVectors(ClientVector, AngleVector, TeleportTo);
			
			new Handle:pack;
			hTeleportData[bot] = CreateDataTimer(2.0, CheckPostTeleport, pack, TIMER_FLAG_NO_MAPCHANGE);
			WritePackFloat(pack, ClientVector[0]);
			WritePackFloat(pack, ClientVector[1]);
			WritePackFloat(pack, ClientVector[2]);
			WritePackFloat(pack, TeleportTo[2]);
			WritePackCell(pack, bot);
			
			AddParticle(bot, "smokegrenade_jet", 2.0, 10.0);
			
			TeleportTo[2] += 10;
			TeleportEntity(bot, TeleportTo, NULL_VECTOR, NULL_VECTOR);
			PlaySound(bot, false);	
						
			AddParticle(bot, "smokegrenade", 2.0, 10.0);
			
			PlaySound(bot, false);
						
			CreateTimer(1.2, AllowWeapon, bot, TIMER_FLAG_NO_MAPCHANGE);
		}
	}
}

public Action:AllowBotTeleport(Handle:timer, any:client)
{
	g_canTP[client] = true;
		
	if (IsClientInGame(client) && !IsFakeClient(client) && IsPlayerAlive(client) && GetClientTeam(client) == 3 && g_ZombieType[client] == WITCH)
	{
		SetEntPropFloat(client, Prop_Send, "m_flProgressBarStartTime", GetGameTime());
		SetEntProp(client, Prop_Send, "m_iProgressBarDuration", 0);
		EmitSoundToClient(client, "buttons/blip1.wav");
	}
		
	return Plugin_Continue;
}
