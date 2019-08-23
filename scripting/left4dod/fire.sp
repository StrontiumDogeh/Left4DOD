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
 
// FIRE NADES #######################################################################
public Action:Fire(Handle:timer, any:ent)
{
	new Float:vLoc[3];
	if (IsValidEntity(ent))
	{
		GetEntDataVector(ent, g_oEntityOrigin, vLoc);
				
		EmitSoundToAll("left4dod/fire.mp3", ent);
		
		new owner;
		
		for (new i = 1; i <= MaxClients; i++)
		{
			if (IsClientInGame(i) && g_Molotov[i] == ent)
			{
				owner = i;
				
				g_Molotov[i] = 0;
				break;
			}
		}
		
		if (CheckLocationNearAxisSpawn(vLoc, 500.0))
			return Plugin_Handled;
		
		if (g_mapType == 0 && CheckLocationNearAlliedSpawn(vLoc, 400.0) && GetConVarInt(hFF) == 1)
			return Plugin_Handled;
			
		if (owner > 0 && hFireTimer[owner] == INVALID_HANDLE)
		{			
			g_HasMolotov[owner] = true;
						
			new Handle:pack;				
			hFireTimer[owner]  = CreateDataTimer(0.5, CheckFire, pack, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
			CreateTimer(12.0, KillFireTimer, owner, TIMER_FLAG_NO_MAPCHANGE);
			WritePackCell(pack, owner);
			WritePackFloat(pack, vLoc[0]);
			WritePackFloat(pack, vLoc[1]);
			WritePackFloat(pack, vLoc[2]);
			
			AttachParticle(ent, "fire_large_01", 12.0);			
		}
	}
	return Plugin_Handled;
}

public Action:CheckFire(Handle:timer, Handle:firestuff)
{	
	new Float:vecLoc[3];
	ResetPack(firestuff);
	new owner = ReadPackCell(firestuff);
	vecLoc[0] = ReadPackFloat(firestuff);
	vecLoc[1] = ReadPackFloat(firestuff);
	vecLoc[2] = ReadPackFloat(firestuff);
	
	if (!g_HasMolotov[owner])
	{
		KillTimer(hFireTimer[owner]);
		hFireTimer[owner] = INVALID_HANDLE;
	}
	
	new Float:victimLoc[3];
		
	if (IsClientInGame(owner) && GetClientTeam(owner) == ALLIES)
	{
		for (new i = 1; i <= MaxClients; i++) 
		{
			if (IsClientInGame(i) && IsPlayerAlive(i) && !IsClientObserver(i))
			{
				if (GetClientTeam(i) == AXIS && g_ZombieType[i] != ANARCHIST && g_ZombieType[i] != SKELETON && g_ZombieType[i] != HELLSPAWN && !g_noFire[i])
				{
					if (!g_OnFire[i])
					{
						GetClientAbsOrigin(i, victimLoc);
						if (GetVectorDistance(vecLoc, victimLoc) < 250.0)
						{
							AttachFireParticle(i, "fire_medium_03_brownsmoke", 10.0);
							
							g_OnFire[i] = true;
							CreateTimer(10.0, RemoveFireStatus, i, TIMER_FLAG_NO_MAPCHANGE);
							
							g_iBotsTarget[i] = 0;
						}
					}
					else
					{
						new fire_damage = 25;
						
						new Handle:pack;			
						CreateDataTimer(0.1, DealDamage, pack, TIMER_FLAG_NO_MAPCHANGE);
						WritePackCell(pack, i);
						WritePackCell(pack, owner);
						WritePackCell(pack, fire_damage);
						WritePackCell(pack, DMG_BURN);
						WritePackString(pack, "weapon_molotov");
					}
				}
				
			}
		}
	}
	else if (IsClientInGame(owner) && GetClientTeam(owner) == AXIS)
	{
		for (new i = 1; i <= MaxClients; i++) 
		{
			if (IsClientInGame(i) && IsPlayerAlive(i) && !IsClientObserver(i))
			{
				if (GetClientTeam(i) == ALLIES)
				{
					if (!g_OnFire[i])
					{
						GetClientAbsOrigin(i, victimLoc);
						if (GetVectorDistance(vecLoc, victimLoc) < 250.0)
						{
							AttachFireParticle(i, "fire_medium_03_brownsmoke", 10.0);
							
							g_OnFire[i] = true;
							
							CreateTimer(9.0, RemoveFireStatus, i, TIMER_FLAG_NO_MAPCHANGE);
							
							g_iBotsTarget[i] = 0;
						}
					}
					else
					{
						new fire_damage = 25;
						
						new Handle:pack;			
						CreateDataTimer(0.1, DealDamage, pack, TIMER_FLAG_NO_MAPCHANGE);
						WritePackCell(pack, i);
						WritePackCell(pack, owner);
						WritePackCell(pack, fire_damage);
						WritePackCell(pack, DMG_BURN);
						WritePackString(pack, "weapon_fireball");
					}
				}
			}
		}
	}
	return Plugin_Handled;
}

public Action:RemoveFireStatus(Handle:timer, any:client)
{
	if (IsClientInGame(client) && IsPlayerAlive(client) && g_OnFire[client])
		g_OnFire[client] = false;
		
	return Plugin_Handled;
}

public Action:KillFireTimer(Handle:timer, any:owner)
{
	g_HasMolotov[owner] = false;
	
	#if DEBUG
		LogToFileEx(g_szLogFileName,"[L4DOD] Removed fire hurt timer:%i", owner);
	#endif
	
	return Plugin_Handled;
}
