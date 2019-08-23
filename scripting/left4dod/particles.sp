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
// ################################################################################
AttachParticle(ent, String:particleType[], Float:time=1.0)
{
	new particle = CreateEntityByName("info_particle_system");
	
	#if DEBUG
		LogToFileEx(g_szLogFileName,"[L4DOD] Created Particle:%i", particle);
	#endif
	
	new String:tName[128];
	if (IsValidEdict(particle))
	{
		new Float:pos[3];
		GetEntPropVector(ent, Prop_Send, "m_vecOrigin", pos);
		pos[2] += 10;
		#if DEBUG
			LogToFileEx(g_szLogFileName,"[L4DOD] Got vectors for Particle:%i", particle);
		#endif
		
		TeleportEntity(particle, pos, NULL_VECTOR, NULL_VECTOR);
		
		#if DEBUG
			LogToFileEx(g_szLogFileName,"[L4DOD] Teleported Particle:%i", particle);
		#endif
		
		Format(tName, sizeof(tName), "target%i", ent);
		DispatchKeyValue(ent, "targetname", tName);
		
		DispatchKeyValue(particle, "targetname", "dodparticle");
		DispatchKeyValue(particle, "effect_name", particleType);
		DispatchSpawn(particle);
		
		#if DEBUG
			LogToFileEx(g_szLogFileName,"[L4DOD] Spawned Particle:%i", particle);
		#endif
		
		SetVariantString(tName);
		AcceptEntityInput(particle, "SetParent", particle, particle, 0);
		ActivateEntity(particle);
		AcceptEntityInput(particle, "start");
		
		CreateTimer(time, DeleteParticle, particle, TIMER_FLAG_NO_MAPCHANGE);
	}
}

AddParticle(ent, String:type[], Float:time, Float:offset)
{
	new particle = CreateEntityByName("info_particle_system");
	
	new String:tName[128];
	if (IsValidEdict(particle) && IsValidEntity(ent))
	{
		new Float:pos[3];
		GetEntPropVector(ent, Prop_Send, "m_vecOrigin", pos);
		pos[2] += offset;
		TeleportEntity(particle, pos, NULL_VECTOR, NULL_VECTOR);
		
		Format(tName, sizeof(tName), "target%i", ent);
		DispatchKeyValue(ent, "targetname", tName);
		
		DispatchKeyValue(particle, "targetname", "dodparticle");
		DispatchKeyValue(particle, "effect_name", type);
		DispatchSpawn(particle);
		ActivateEntity(particle);
		AcceptEntityInput(particle, "start");
		
		if (time != -1.0)
			CreateTimer(time, DeleteParticle, particle, TIMER_FLAG_NO_MAPCHANGE);
	}
}

PositionParticle(Float:pos[3], String:type[], Float:time)
{
	new particle = CreateEntityByName("info_particle_system");

	if (IsValidEdict(particle))
	{
		pos[2] += 10;
		TeleportEntity(particle, pos, NULL_VECTOR, NULL_VECTOR);
				
		DispatchKeyValue(particle, "effect_name", type);
		DispatchSpawn(particle);
		ActivateEntity(particle);
		AcceptEntityInput(particle, "start");
		
		CreateTimer(time, DeleteParticle, particle, TIMER_FLAG_NO_MAPCHANGE);
	}
}

public Action:DeleteParticle(Handle:timer, any:particle)
{
    if (IsValidEntity(particle))
    {
        new String:classname[256];
        GetEdictClassname(particle, classname, sizeof(classname));
        if (StrEqual(classname, "info_particle_system", false))
        {
            AcceptEntityInput(particle, "Kill");
        }
    }
    return Plugin_Handled;
}

AttachFireParticle(ent, String:particleType[], Float:time=1.0)
{
	new particle = CreateEntityByName("info_particle_system");
	
	new String:tName[128];
	if (IsValidEdict(particle))
	{
		new Float:pos[3];
		GetEntPropVector(ent, Prop_Send, "m_vecOrigin", pos);
		pos[2] += 10;
		TeleportEntity(particle, pos, NULL_VECTOR, NULL_VECTOR);
		
		Format(tName, sizeof(tName), "target%i", ent);
		DispatchKeyValue(ent, "targetname", tName);
		
		DispatchKeyValue(particle, "targetname", "dodparticle");
		DispatchKeyValue(particle, "effect_name", particleType);
		DispatchSpawn(particle);
		SetVariantString(tName);
		AcceptEntityInput(particle, "SetParent", particle, particle, 0);
		ActivateEntity(particle);
		AcceptEntityInput(particle, "start");
		
		g_FireParticle[ent] = particle;
		
		CreateTimer(time, DeleteFireParticle, particle, TIMER_FLAG_NO_MAPCHANGE);
	}
}

public Action:DeleteFireParticle(Handle:timer, any:particle)
{
	if (IsValidEntity(particle))
	{
		new String:classname[256];
		GetEdictClassname(particle, classname, sizeof(classname));
		if (StrEqual(classname, "info_particle_system", false))
		{
			AcceptEntityInput(particle, "Kill");
		}
		
		for (new i=1; i <= MaxClients; i++)
		{
			if (g_FireParticle[i] == particle)
			{
				g_FireParticle[i] = 0;
				
				return Plugin_Handled;
			}
		}
	}
	return Plugin_Handled;
}
