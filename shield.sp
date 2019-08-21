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
// SHIELD ###########################################################

Shield(any:client)
{
	if (client > 0 && IsClientInGame(client) && IsPlayerAlive(client))
	{
		if (g_Shield[client])
		{
			new Float:vOrigin[3];
			GetClientAbsOrigin(client,vOrigin);
				
			if (CheckLocationNearAxisSpawn(vOrigin, 500.0))
			return;
			
			if (GetClientTeam(client) == ALLIES && hShieldTimer[client] == INVALID_HANDLE && !g_ShieldDeployed[client])
			{
				g_Shield[client] = false;
				
				EmitAmbientSound("items/suitchargeok1.wav", vOrigin, client, SNDLEVEL_RAIDSIREN);
							
				Circle(vOrigin, 160.0);
				
				new duration;
				if (g_bIsSupporter[client])
				{
					duration = 15;
				}
				else if (g_IsMember[client] > 0)
				{
					duration = 9;
				}
				else
				{
					duration = 6;
				}
				
				SetEntPropFloat(client, Prop_Send, "m_flProgressBarStartTime", GetGameTime());
				SetEntProp(client, Prop_Send, "m_iProgressBarDuration", duration);
				
				new Handle:off;
				CreateDataTimer(float(duration), TurnOffShield, off, TIMER_FLAG_NO_MAPCHANGE);
				WritePackCell(off, client);
				WritePackFloat(off, vOrigin[0]);
				WritePackFloat(off, vOrigin[1]);
				WritePackFloat(off, vOrigin[2]);
							
				g_ShieldDeployed[client] = true;
							
				new Handle:pack;				
				hShieldTimer[client]  = CreateDataTimer(0.1, CheckShield, pack, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
				WritePackCell(pack, client);
				WritePackFloat(pack, vOrigin[0]);
				WritePackFloat(pack, vOrigin[1]);
				WritePackFloat(pack, vOrigin[2]);		
			}
		}
		else
		{
			PrintHelp(client, "[L4DOD] Cannot deploy shield at this time", 0);
		}
	}
}

public Action:TurnOffShield(Handle:timer, any:shieldstuff)
{	
	new Float:vecLoc[3];
	ResetPack(shieldstuff);
	new client = ReadPackCell(shieldstuff);
	vecLoc[0] = ReadPackFloat(shieldstuff);
	vecLoc[1] = ReadPackFloat(shieldstuff);
	vecLoc[2] = ReadPackFloat(shieldstuff);
	
	g_ShieldDeployed[client] = false;
	
	if (IsClientInGame(client) && !IsFakeClient(client) && IsPlayerAlive(client))
	{
		SetEntPropFloat(client, Prop_Send, "m_flProgressBarStartTime", GetGameTime());
		SetEntProp(client, Prop_Send, "m_iProgressBarDuration", 0);
		EmitAmbientSound("items/suitchargeno1.wav", vecLoc, client, SNDLEVEL_RAIDSIREN);
	}
			
	return Plugin_Continue;
}

public Action:CheckShield(Handle:timer, Handle:shieldstuff)
{	
	new Float:vecLoc[3];
	ResetPack(shieldstuff);
	new owner = ReadPackCell(shieldstuff);
	vecLoc[0] = ReadPackFloat(shieldstuff);
	vecLoc[1] = ReadPackFloat(shieldstuff);
	vecLoc[2] = ReadPackFloat(shieldstuff);
	
	if (!g_ShieldDeployed[owner] || g_bRoundOver)
	{
		hShieldTimer[owner] = INVALID_HANDLE;
		return Plugin_Stop;
	}
	
	new Float:victimLoc[3];
		
	if (IsClientInGame(owner) && GetClientTeam(owner) == ALLIES)
	{
		for (new i = 1; i <= MaxClients; i++) 
		{
			if (IsClientInGame(i) && IsPlayerAlive(i))
			{
				if (GetClientTeam(i) == AXIS)
				{
					GetClientAbsOrigin(i, victimLoc);
					if (GetVectorDistance(vecLoc, victimLoc) < 200.0)
					{						
						SetEntProp(i, Prop_Data, "m_takedamage", 2, 1); 
						
						g_CanRightClick[i] = false;
						
						new Handle:pack;			
						CreateDataTimer(0.1, DealDamage, pack, TIMER_FLAG_NO_MAPCHANGE);
						WritePackCell(pack, i);
						WritePackCell(pack, owner);
						WritePackCell(pack, 1000);
						WritePackCell(pack, DMG_ENERGYBEAM);
						WritePackString(pack, "weapon_shield");
						
						new rnd = GetRandomInt(0,5);
						EmitAmbientSound(g_Zaps[rnd], victimLoc, i, SNDLEVEL_RAIDSIREN);
						PlaySound(i, false);
					}		
				}
			}
		}
	}
	return Plugin_Handled;
}

Circle(Float:vecLocation[3], Float:radius)
{
	new Float:angle=0.0, Float:x, Float:y;
	
	new Float:pos1[3];
	new Float:pos2[3];
		
	//Create the start position for the first part of the beam
	pos2[0] = vecLocation[0] + radius;
	pos2[1] = vecLocation[1];
	pos2[2] = vecLocation[2];
	
	while (angle <= 2 * PI)
	{			
		x = radius * Cosine(angle);
		y = radius * Sine(angle);
		
		pos1[0] = vecLocation[0] + x;
		pos1[1] = vecLocation[1] + y;
		pos1[2] = vecLocation[2];
		
		pos2[0] = vecLocation[0] + x;
		pos2[1] = vecLocation[1] + y;
		pos2[2] = vecLocation[2] + 100.0;
		
		/* stock TE_SetupBeamPoints(const Float:start[3], const Float:end[3], ModelIndex, HaloIndex, StartFrame, FrameRate, Float:Life,    
          		                         Float:Width, Float:EndWidth, FadeLength, Float:Amplitude, const Color[4], Speed) */

		TE_SetupBeamPoints(pos1, pos2, BallSprite, HaloSprite, 0, 0, 10.0, 
								Float:10.0, Float:10.0, 0, 0.0, g_AlliesColour, 3);
		TE_SendToAll();
				
		angle += 0.3;
	}
}