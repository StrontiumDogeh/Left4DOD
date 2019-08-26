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

public OnEntityCreated(entity, const String:className[])
{
	if (StrEqual(className, "rocket_bazooka") || StrEqual(className, "rocket_pschreck"))
	{
		SDKHook(entity, SDKHook_Spawn, OnRocketSpawn);
	}
	else if (StrEqual(className, "dod_bomb_target"))
	{
		SDKHook(entity, SDKHook_Spawn, OnBombSpawn);
	}
	else if (StrEqual(className, "grenade_frag_ger"))
	{
		g_iMineData[entity] = 0;

		SDKHook(entity, SDKHook_Spawn, OnGrenadeSpawn);
	}
}
//######## GRENADE
public OnGrenadeSpawn(entity)
{
	CreateTimer(0.3, DelayGrenadeHook, entity, TIMER_FLAG_NO_MAPCHANGE);
}

public Action:DelayGrenadeHook(Handle:timer, any:entity)
{
	if (IsValidEntity(entity))
	{
		new owner = GetEntPropEnt(entity, Prop_Send, "m_hThrower");

		if (owner > 0 && GetClientTeam(owner) == AXIS )
		{
			SDKHook(entity, SDKHook_VPhysicsUpdate, HookGrenadeThink);
		}
	}

	return Plugin_Handled;
}


//######## ROCKET
public OnRocketSpawn(entity)
{
	CreateTimer(0.3, DelayRocketHook, entity, TIMER_FLAG_NO_MAPCHANGE);
}

public Action:DelayRocketHook(Handle:timer, any:entity)
{
	if (IsValidEntity(entity))
	{
		SDKHook(entity, SDKHook_Think, OnRocketThink);
	}
	return Plugin_Handled;
}

public OnRocketThink(entity)
{
	static offsetOwner, offsetOrigin, offsetRotation, offsetVelocity;

	offsetOwner = FindDataMapOffs(entity, "m_hOwnerEntity");
	offsetOrigin = FindDataMapOffs(entity, "m_vecAbsOrigin");
	offsetRotation = FindDataMapOffs(entity, "m_angRotation");
	offsetVelocity = FindDataMapOffs(entity, "m_vecAbsVelocity");

	new owner = GetEntDataEnt2(entity, offsetOwner);

	// If supporter OR member
	if (owner != -1 && (g_bIsSupporter[owner] || g_IsMember[owner] > 0))
	{
		decl Float:vecPosition[3];
		decl Float:vecBuffer[3], Float:vecVelocity[3];

		new iTarget = SeekEnemy(entity);

		if (iTarget != 0)
		{
			GetClientEyePosition(iTarget, vecBuffer);
			GetEntDataVector(entity, offsetOrigin, vecPosition);

			SubtractVectors(vecBuffer, vecPosition, vecBuffer);
			NormalizeVector(vecBuffer, vecVelocity);

			GetVectorAngles(vecVelocity, vecBuffer);
			SetEntDataVector(entity, offsetRotation, vecBuffer);

			ScaleVector(vecVelocity, 1000.0);
			SetEntDataVector(entity, offsetVelocity, vecVelocity);
		}
	}
	else if (owner != -1 )
	{
		decl Float:vecPosition[3], Float:vecAngles[3];

		GetClientEyePosition(owner, vecPosition);
		GetClientEyeAngles(owner, vecAngles);

		TR_TraceRayFilter(vecPosition, vecAngles, MASK_SOLID, RayType_Infinite, TraceRayDontHitSelf, owner);

		if (TR_DidHit())
		{
			decl Float:vecBuffer[3], Float:vecVelocity[3];

			TR_GetEndPosition(vecBuffer);
			GetEntDataVector(entity, offsetOrigin, vecPosition);

			SubtractVectors(vecBuffer, vecPosition, vecBuffer);
			NormalizeVector(vecBuffer, vecVelocity);

			GetVectorAngles(vecVelocity, vecBuffer);
			SetEntDataVector(entity, offsetRotation, vecBuffer);

			ScaleVector(vecVelocity, 1000.0);
			SetEntDataVector(entity, offsetVelocity, vecVelocity);
		}
	}
}

//############ TNT
public OnBombSpawn(entity)
{
	CreateTimer(2.1, DelayModelCheck, entity, TIMER_FLAG_NO_MAPCHANGE);
}

public Action:DelayModelCheck(Handle:timer, any:entity)
{
	if (IsValidEntity(entity))
	{
		new String:modelname[128];
		GetEntPropString(entity, Prop_Data, "m_ModelName", modelname, 128);

		if (StrEqual(modelname, "models/weapons/w_tnt.mdl"))
		{
			for (new client = 1; client <= MaxClients; client++)
			{
				if (g_TNTentity[client] == entity)
					g_primedTNT[client] = true;
			}
		}
	}
	return Plugin_Handled;
}

