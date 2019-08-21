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
// KABOOM ###########################################################
#define EMODMG1 450

Detonate(any:client)
{
	if (IsClientInGame(client))
	{ 
		new Float:ClientOrigin[3];
		GetClientAbsOrigin(client, ClientOrigin);
		ClientOrigin[2] +=50;
		
		new String:szMag[16];
		Format(szMag, sizeof(szMag), "%i", EMODMG1);
		
		#if DEBUG
			LogToFileEx(g_szLogFileName,"[L4DOD] Emo detonated:%i", client);
		#endif
				
		new ent = CreateEntityByName("env_explosion");
		DispatchKeyValue(ent, "iMagnitude", szMag);
		DispatchKeyValue(ent, "iRadiusOverride", szMag);
		DispatchSpawn(ent);
		SetEntPropEnt(ent, Prop_Data, "m_hOwnerEntity", client);
		TeleportEntity(ent, ClientOrigin, NULL_VECTOR, NULL_VECTOR);
		AcceptEntityInput(ent, "Explode");
		AcceptEntityInput(ent, "Kill");
		
		new push = CreateEntityByName("env_physexplosion");
		DispatchKeyValue(push, "Magnitude", szMag);
		DispatchKeyValue(push, "Spawnflags", "27");
		DispatchSpawn(push);
		TeleportEntity(push, ClientOrigin, NULL_VECTOR, NULL_VECTOR);
		AcceptEntityInput(push, "Explode");
		AcceptEntityInput(push, "Kill");
		
		AddParticle(client, "smokegrenade", 2.0, 10.0);
		
		new Float:fMag = float(StringToInt(szMag));
		if (fMag <= 200.0) fMag = 200.0;
		
		new shake = CreateEntityByName("env_shake");
		DispatchKeyValueFloat(shake, "amplitude", fMag);
		DispatchKeyValueFloat(shake, "radius", fMag * 2);
		DispatchKeyValueFloat(shake, "duration", 1.0);
		DispatchKeyValueFloat(shake, "frequency", 100.0);
		DispatchKeyValue(shake,"SpawnFlags", "1");
		DispatchSpawn(shake);
		AcceptEntityInput(shake, "StartShake");
		TeleportEntity(shake, ClientOrigin, NULL_VECTOR, NULL_VECTOR);
		CreateTimer(1.1, DestroyShake, shake, TIMER_FLAG_NO_MAPCHANGE);
		
		//Make sure the Emo is dead
		if (IsPlayerAlive(client))
			ForcePlayerSuicide(client);
		
		RemoveRagdoll(client);
	}
}

public Action:DestroyShake(Handle:timer, any:entity)
{		
	if (IsValidEdict(entity))
	{
		new String:classname[256];
		GetEdictClassname(entity, classname, sizeof(classname));
		if (StrEqual(classname, "env_shake", false))
		{
			AcceptEntityInput(entity, "Kill");
		}
	}
	return Plugin_Handled;
}