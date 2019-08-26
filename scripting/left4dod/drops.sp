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

COLLISION_GROUP_NONE  = 0,
COLLISION_GROUP_DEBRIS,            // Collides with nothing but world and static stuff
COLLISION_GROUP_DEBRIS_TRIGGER, // Same as debris, but hits triggers
COLLISION_GROUP_INTERACTIVE_DEBRIS,    // Collides with everything except other interactive debris or debris
COLLISION_GROUP_INTERACTIVE,    // Collides with everything except interactive debris or debris
COLLISION_GROUP_PLAYER,
COLLISION_GROUP_BREAKABLE_GLASS,
COLLISION_GROUP_VEHICLE,
COLLISION_GROUP_PLAYER_MOVEMENT,  // For HL2, same as Collision_Group_Player

COLLISION_GROUP_NPC,            // Generic NPC group
COLLISION_GROUP_IN_VEHICLE,        // for any entity inside a vehicle
COLLISION_GROUP_WEAPON,            // for any weapons that need collision detection
COLLISION_GROUP_VEHICLE_CLIP,    // vehicle clip brush to restrict vehicle movement
COLLISION_GROUP_PROJECTILE,        // Projectiles!
COLLISION_GROUP_DOOR_BLOCKER,    // Blocks entities not permitted to get near moving doors
COLLISION_GROUP_PASSABLE_DOOR,    // Doors that the player shouldn't collide with
COLLISION_GROUP_DISSOLVING,        // Things that are dissolving are in this group
COLLISION_GROUP_PUSHAWAY,        // Nonsolid on client and server, pushaway in player code

COLLISION_GROUP_NPC_ACTOR,        // Used so NPCs in scripts ignore the player.


FSOLID_CUSTOMRAYTEST        = 0x0001,    // Ignore solid type + always call into the entity for ray tests
FSOLID_CUSTOMBOXTEST        = 0x0002,    // Ignore solid type + always call into the entity for swept box tests
FSOLID_NOT_SOLID            = 0x0004,    // Are we currently not solid?
FSOLID_TRIGGER                = 0x0008,    // This is something may be collideable but fires touch functions
										// even when it's not collideable (when the FSOLID_NOT_SOLID flag is set)
FSOLID_NOT_STANDABLE        = 0x0010,    // You can't stand on this
FSOLID_VOLUME_CONTENTS        = 0x0020,    // Contains volumetric contents (like water)
FSOLID_FORCE_WORLD_ALIGNED    = 0x0040,    // Forces the collision rep to be world-aligned even if it's SOLID_BSP or SOLID_VPHYSICS
FSOLID_USE_TRIGGER_BOUNDS    = 0x0080,    // Uses a special trigger bounds separate from the normal OBB
FSOLID_ROOT_PARENT_ALIGNED    = 0x0100,    // Collisions are defined in root

 */

 // HEALTH/AMMO DROPS ##################################################
// SLOTS
// [0] garand-1 k98-1 spring-1 k98_scoped-1 thompson-1 mp40-1 mp44-1 bar-1 30cal-1 mg42-1 bazooka-1 pschreck-1
// [1] colt-2 p38-2 c96-2 m1carbine-2
// [2] amerknife-3 spade-3 smoke_us-3 smoke_ger-3
// [3] frag_us-4 frag_ger-4 riflegren_us-4 riflegren_ger-4

CreateDrops(any:client)
{

	new Float:droptime = 1.1;

	CreateTimer((droptime - 0.3), DeleteRagdoll, client, TIMER_FLAG_NO_MAPCHANGE);

	if (GetConVarInt(hL4DDrops))
	{
		if (g_ZombieType[client] == GREYDUDE)
			CreateTimer(droptime, SpawnZombieBlood, client, TIMER_FLAG_NO_MAPCHANGE);

		else if (g_ZombieType[client] == WITCH)
			CreateTimer(droptime, SpawnHooch, client, TIMER_FLAG_NO_MAPCHANGE);

		else if (g_ZombieType[client] == INFECTEDONE)
			CreateTimer(droptime, SpawnAmmoBox, client, TIMER_FLAG_NO_MAPCHANGE);

		else if (g_ZombieType[client] == ANARCHIST)
			CreateTimer(droptime, SpawnBoxNades, client, TIMER_FLAG_NO_MAPCHANGE);

		else if (g_ZombieType[client] == GASMAN)
			CreateTimer(droptime, SpawnAntiGas, client, TIMER_FLAG_NO_MAPCHANGE);

		else if (g_ZombieType[client] == EMO)
			CreateTimer(droptime, SpawnTNT, client, TIMER_FLAG_NO_MAPCHANGE);

		else if (g_ZombieType[client] == UNG)
			CreateTimer(droptime, SpawnShield, client, TIMER_FLAG_NO_MAPCHANGE);

		else if (g_ZombieType[client] == WRAITH)
			CreateTimer(droptime, SpawnHealthBox, client, TIMER_FLAG_NO_MAPCHANGE);

		else if (g_ZombieType[client] == SKELETON)
			CreateTimer(droptime, SpawnAdrenaline, client, TIMER_FLAG_NO_MAPCHANGE);

		else if (g_ZombieType[client] == HELLSPAWN)
			CreateTimer(droptime, SpawnHealthBox, client, TIMER_FLAG_NO_MAPCHANGE);

		else if (g_Allies > 3 && g_Allies < 11)
		{
			SetRandomSeed(RoundFloat(GetEngineTime()));
			new randomNum = GetRandomInt(1, 100);

			switch (randomNum)
			{
				case 1, 2, 3, 4, 5, 6, 7:
					CreateTimer(droptime, SpawnAmmoBox, client, TIMER_FLAG_NO_MAPCHANGE);
				case 10, 11, 12, 13:
					CreateTimer(droptime, SpawnTNT, client, TIMER_FLAG_NO_MAPCHANGE);
				case 21, 22:
					CreateTimer(droptime, SpawnAdrenaline, client, TIMER_FLAG_NO_MAPCHANGE);
				case 30:
					CreateTimer(droptime, SpawnRadio, client, TIMER_FLAG_NO_MAPCHANGE);
				case 40, 41:
					CreateTimer(droptime, SpawnAntiGas, client, TIMER_FLAG_NO_MAPCHANGE);
				case 60, 61:
					CreateTimer(droptime, SpawnBoxNades, client, TIMER_FLAG_NO_MAPCHANGE);
				case 70, 71, 72:
					CreateTimer(droptime, SpawnHooch, client, TIMER_FLAG_NO_MAPCHANGE);
				case 80, 81, 82, 84, 85:
					CreateTimer(droptime, SpawnHealthBox, client, TIMER_FLAG_NO_MAPCHANGE);
				case 94:
					CreateTimer(droptime, SpawnShield, client, TIMER_FLAG_NO_MAPCHANGE);
				case 98, 99:
					CreateTimer(droptime, SpawnZombieBlood, client, TIMER_FLAG_NO_MAPCHANGE);

				default:
					CreateTimer(droptime, SpawnGuts, client, TIMER_FLAG_NO_MAPCHANGE);
			}
		}
		else if (g_Allies > 10)
		{
			SetRandomSeed(RoundFloat(GetEngineTime()));
			new randomNum = GetRandomInt(1, 100);
			switch (randomNum)
			{
				case 1, 2, 3, 4, 5:
					CreateTimer(droptime, SpawnAmmoBox, client, TIMER_FLAG_NO_MAPCHANGE);
				case 10, 11, 12, 13:
					CreateTimer(droptime, SpawnTNT, client, TIMER_FLAG_NO_MAPCHANGE);
				case 21, 22, 23, 24:
					CreateTimer(droptime, SpawnAdrenaline, client, TIMER_FLAG_NO_MAPCHANGE);
				case 30:
					CreateTimer(droptime, SpawnRadio, client, TIMER_FLAG_NO_MAPCHANGE);
				case 40, 41:
					CreateTimer(droptime, SpawnAntiGas, client, TIMER_FLAG_NO_MAPCHANGE);
				case 60:
					CreateTimer(droptime, SpawnBoxNades, client, TIMER_FLAG_NO_MAPCHANGE);
				case 70, 71:
					CreateTimer(droptime, SpawnHooch, client, TIMER_FLAG_NO_MAPCHANGE);
				case 80, 81, 82, 83:
					CreateTimer(droptime, SpawnHealthBox, client, TIMER_FLAG_NO_MAPCHANGE);
				case 95:
					CreateTimer(droptime, SpawnShield, client, TIMER_FLAG_NO_MAPCHANGE);
				case 98:
					CreateTimer(droptime, SpawnZombieBlood, client, TIMER_FLAG_NO_MAPCHANGE);

				default:
					CreateTimer(droptime, SpawnGuts, client, TIMER_FLAG_NO_MAPCHANGE);
			}
		}
		else
		{
			SetRandomSeed(RoundFloat(GetEngineTime()));
			new randomNum = GetRandomInt(1, 100);
			switch (randomNum)
			{
				case 1, 2, 3, 4, 5, 6, 7, 8, 9:
					CreateTimer(droptime, SpawnAmmoBox, client, TIMER_FLAG_NO_MAPCHANGE);
				case 10, 11, 12, 13, 14:
					CreateTimer(droptime, SpawnTNT, client, TIMER_FLAG_NO_MAPCHANGE);
				case 21, 22, 23, 24:
					CreateTimer(droptime, SpawnAdrenaline, client, TIMER_FLAG_NO_MAPCHANGE);
				case 30, 31:
					CreateTimer(droptime, SpawnRadio, client, TIMER_FLAG_NO_MAPCHANGE);
				case 40, 41, 42, 43, 44:
					CreateTimer(droptime, SpawnAntiGas, client, TIMER_FLAG_NO_MAPCHANGE);
				case 60, 61, 62, 63, 64, 65:
					CreateTimer(droptime, SpawnBoxNades, client, TIMER_FLAG_NO_MAPCHANGE);
				case 71, 72, 73, 74, 75:
					CreateTimer(droptime, SpawnHooch, client, TIMER_FLAG_NO_MAPCHANGE);
				case 80, 81, 82, 83, 84, 85, 86, 87, 88, 89:
					CreateTimer(droptime, SpawnHealthBox, client, TIMER_FLAG_NO_MAPCHANGE);
				case 94:
					CreateTimer(droptime, SpawnShield, client, TIMER_FLAG_NO_MAPCHANGE);
				case 97, 98:
					CreateTimer(droptime, SpawnZombieBlood, client, TIMER_FLAG_NO_MAPCHANGE);

				default:
					CreateTimer(droptime, SpawnGuts, client, TIMER_FLAG_NO_MAPCHANGE);
			}
		}
	}
}

public Action:DeleteRagdoll(Handle:timer, any:client)
{
	if (!IsValidEntity(client) || IsPlayerAlive(client))
		return;

	if (IsClientInGame(client))
	{
		new ragdoll = GetEntPropEnt(client, Prop_Send, "m_hRagdoll");

		if (IsValidEdict(ragdoll))
	    {
			new String:dname[32];
			Format(dname, sizeof(dname), "dis_%d", client);

			new ent = CreateEntityByName("env_entity_dissolver");
			if (ent>0)
			{
				DispatchKeyValue(ragdoll, "targetname", dname);
				DispatchKeyValue(ent, "dissolvetype", "1");
				DispatchKeyValue(ent, "target", dname);
				AcceptEntityInput(ent, "Dissolve");
				AcceptEntityInput(ent, "kill");

				#if DEBUG
					LogToFileEx(g_szLogFileName,"[L4DOD] Deleted Ragdoll:%i", ent);
				#endif
			}
		}
	}

	return;
}

RemoveRagdoll(victim)
{
	new Ragdoll = GetEntPropEnt(victim, Prop_Send, "m_hRagdoll");
	if(IsValidEdict(Ragdoll))
	{
		AcceptEntityInput(Ragdoll, "kill");

		#if DEBUG
			LogToFileEx(g_szLogFileName,"[L4DOD] Removed Ragdoll:%i", Ragdoll);
		#endif
	}
}


public Action:SpawnAmmoBox(Handle:timer, any:client)
{
	new Float: ClientOrigin[3];

	if (IsClientInGame(client))
	{
		GetClientAbsOrigin(client, ClientOrigin);

		if (IsAreaClear(ClientOrigin))
		{
			g_AmmoBoxNumber++;

			new ent = CreateEntityByName("prop_physics_override");
			if (ent>0)
			{
				SetEntityModel(ent, "models/ammo/ammo_axis.mdl");
				new String:ammoname[16];
				Format(ammoname, sizeof(ammoname), "Ammo%i", g_AmmoBoxNumber);
				DispatchKeyValue(ent, "StartDisabled", "false");
				DispatchKeyValue(ent, "targetname", ammoname);
				SetEntityMoveType(ent, MOVETYPE_VPHYSICS);
				SetEntProp(ent, Prop_Send, "m_CollisionGroup", DROP_COLLISION);
				SetEntProp(ent, Prop_Send, "m_usSolidFlags", DROP_SOLID_FLAGS);
				SetEntProp(ent, Prop_Send, "m_nSolidType", DROP_SOLID);
				//SetEntityRenderFx(ent, RENDERFX_PULSE_FAST_WIDE);

				DispatchSpawn(ent);
				TeleportEntity(ent, ClientOrigin, NULL_VECTOR, NULL_VECTOR);

				SDKHook(ent, SDKHook_StartTouch, TouchHookAmmo);
				SDKHook(ent, SDKHook_Touch, TouchHookAmmo);
				SDKHook(ent, SDKHook_EndTouch, TouchHookAmmo);

				#if DEBUG
					LogToFileEx(g_szLogFileName,"[L4DOD] Created ammo drop:%i", ent);
				#endif

				new String:addoutput[64];
				Format(addoutput, sizeof(addoutput), "OnUser1 !self:kill::%f:1", 10.0);
				SetVariantString(addoutput);
				AcceptEntityInput(ent, "AddOutput");
				AcceptEntityInput(ent, "FireUser1");

				AttachParticle(ent, "fire_small_base", 10.0);
			}
		}
		else
		{
			new player = GetClosestClient(ClientOrigin, 0);

			if (player > 0)
				AddAmmo(player);
		}
	}

	return Plugin_Handled;
}

public Action:TouchHookAmmo(entity, client)
{
	if (client > 0 && client <= MaxClients)
	{
		if (GetClientTeam(client) == ALLIES)
		{
			AddAmmo(client);

			DestroyEntity(entity);
		}
	}
	return Plugin_Handled;
}

public Action:SpawnHealthBox(Handle:timer, any:client)
{
	new Float: ClientOrigin[3];

	if (IsClientInGame(client))
	{
		GetClientAbsOrigin(client, ClientOrigin);

		if (IsAreaClear(ClientOrigin))
		{
			g_HealthPackNumber++;

			new ent = CreateEntityByName("prop_physics_override");
			if (ent>0)
			{
				SetEntityModel(ent, "models/left4dod/medic_pack.mdl");
				new String:healthname[16];
				Format(healthname, sizeof(healthname), "Health%i", g_HealthPackNumber);
				DispatchKeyValue(ent, "StartDisabled", "false");
				DispatchKeyValue(ent, "targetname", healthname);
				SetEntityMoveType(ent, MOVETYPE_VPHYSICS);
				SetEntProp(ent, Prop_Send, "m_CollisionGroup", DROP_COLLISION);
				SetEntProp(ent, Prop_Send, "m_usSolidFlags", DROP_SOLID_FLAGS);
				SetEntProp(ent, Prop_Send, "m_nSolidType", DROP_SOLID);
				//SetEntityRenderFx(ent, RENDERFX_PULSE_FAST_WIDE);

				DispatchSpawn(ent);
				TeleportEntity(ent, ClientOrigin, NULL_VECTOR, NULL_VECTOR);

				SDKHook(ent, SDKHook_StartTouch, TouchHookHealthFromBot);
				SDKHook(ent, SDKHook_Touch, TouchHookHealthFromBot);
				SDKHook(ent, SDKHook_EndTouch, TouchHookHealthFromBot);

				#if DEBUG
					LogToFileEx(g_szLogFileName,"[L4DOD] Created healthfrombot drop:%i", ent);
				#endif

				new String:addoutput[64];
				Format(addoutput, sizeof(addoutput), "OnUser1 !self:kill::%f:1", 10.0);
				SetVariantString(addoutput);
				AcceptEntityInput(ent, "AddOutput");
				AcceptEntityInput(ent, "FireUser1");

				AttachParticle(ent, "fire_small_base", 10.0);
			}
		}
		else
		{
			new player = GetClosestClient(ClientOrigin, 0);

			if (player > 0)
				AddHealth(player);
		}
	}

	return Plugin_Handled;
}

public Action:TouchHookHealthFromBot(entity, client)
{
	if (client > 0 && client <= MaxClients && !g_hasAdrenaline[client])
	{
		new health = g_Health[client];

		if (health < g_HealthMax[client])
		{
			AddHealth(client);
		}
		else
		{
			if (GetClientHealth(client) < 100 || g_isInfected[client])
			{
				AddHealth(client);
			}
			else
			{
				g_numDroppedHealth[client]++;
				PrintHelp(client, "{red}*You picked up \x04Health Kit", 0);
				EmitSoundToClient(client, "weapons/c4_pickup.wav");
			}
		}

		DestroyEntity(entity);

	}
	return Plugin_Handled;
}

public Action:SpawnHealthBoxInFront(Handle:timer, any:iClient)
{
	if (IsClientInGame(iClient))
	{
		new Float:vecClient[3], Float:vecAngle[3], Float:vecAngleVector[3], Float:vecVelocity[3], Float:fDistance;
		GetClientEyePosition(iClient, vecClient);
		GetClientEyeAngles(iClient, vecAngle);
		vecAngle[0] = -5.0;

		//How far away from the player to spawn the MedicBox before throwing it
		fDistance = 2.0;

		//Determine the direction the Medic Box has to go
		//and where it has to spawn from
		GetAngleVectors(vecAngle, vecAngleVector, NULL_VECTOR, NULL_VECTOR);

		vecClient[0]+=vecAngleVector[0]*fDistance;
		vecClient[1]+=vecAngleVector[1]*fDistance;
		vecClient[2]+=vecAngleVector[2]*fDistance;

		vecClient[2] -= 20.0;

		//Determine how hard to throw it
		GetAngleVectors(vecAngle, vecVelocity, NULL_VECTOR, NULL_VECTOR);
		NormalizeVector(vecVelocity, vecVelocity);
		ScaleVector(vecVelocity, 250.0);

		g_HealthPackNumber++;

		new ent = CreateEntityByName("prop_physics_override");
		if (ent>0)
		{
			SetEntityModel(ent, "models/left4dod/medic_pack.mdl");
			new String:healthname2[16];
			Format(healthname2, sizeof(healthname2), "Health%i", g_HealthPackNumber);
			DispatchKeyValue(ent, "StartDisabled", "false");
			DispatchKeyValue(ent, "targetname", healthname2);
			SetEntityMoveType(ent, MOVETYPE_VPHYSICS);
			SetEntProp(ent, Prop_Send, "m_CollisionGroup", DROP_COLLISION);
			SetEntProp(ent, Prop_Send, "m_usSolidFlags", DROP_SOLID_FLAGS);
			SetEntProp(ent, Prop_Send, "m_nSolidType", DROP_SOLID);

			//SetEntityRenderFx(ent, RENDERFX_PULSE_FAST_WIDE);

			DispatchSpawn(ent);
			TeleportEntity(ent, vecClient, NULL_VECTOR, vecVelocity);

			SDKHook(ent, SDKHook_StartTouch, TouchHookHealthFromPlayer);
			SDKHook(ent, SDKHook_Touch, TouchHookHealthFromPlayer);
			SDKHook(ent, SDKHook_EndTouch, TouchHookHealthFromPlayer);

			#if DEBUG
				LogToFileEx(g_szLogFileName,"[L4DOD] Created healthfromplayer drop:%i", ent);
			#endif

			new String:addoutput[64];
			Format(addoutput, sizeof(addoutput), "OnUser1 !self:kill::%f:1", 10.0);
			SetVariantString(addoutput);
			AcceptEntityInput(ent, "AddOutput");
			AcceptEntityInput(ent, "FireUser1");
		}
	}

	return Plugin_Handled;
}

public Action:TouchHookHealthFromPlayer(entity, client)
{
	if (client > 0 && client <= MaxClients && !g_hasAdrenaline[client])
	{
		new health = g_Health[client];

		if (health < g_HealthMax[client])
		{
			AddHealth(client);
		}
		else
		{
			if (GetClientHealth(client) < 100 || g_isInfected[client])
			{
				AddHealth(client);
			}
			else
			{
				g_numDroppedHealth[client]++;
				PrintHelp(client, "{red}*You picked up \x04Health Kit", 0);
				EmitSoundToClient(client, "weapons/c4_pickup.wav");
			}
		}

		DestroyEntity(entity);
	}
	return Plugin_Handled;
}

AddHealth(client)
{
	if (IsClientInGame(client) && IsPlayerAlive(client))
	{
		if (GetClientTeam(client) == ALLIES)
		{
			new low = 5;

			if (g_bIsSupporter[client])
			{
				low = 60;
			}
			else if (g_IsMember[client] > 0)
			{
				low = 40;
			}

			new randomnumber = GetRandomInt(low,70);
			g_Health[client] += randomnumber;
			SetHealth(client, g_Health[client]);

			if (!g_isIgnored[client])
				ClientCommand(client, "r_screenoverlay 0");

			PrintHelp(client, "{red}*You picked up \x04Health", 0);
			EmitSoundToClient(client, "items/smallmedkit1.wav");
			EmitSoundToClient(client, "left4dod/bandage.mp3");

			if (g_isInfected[client])
			{
				g_isInfected[client] = false;
				PrintHelp(client, "{red}*Your infection was {green}cured", 0);

				SetEntityModel(client, "models/player/american_assault.mdl");
			}

			g_OnFire[client] = false;
		}
		else if (GetClientTeam(client) == AXIS)
		{
			g_Health[client] += 100;
			SetHealth(client, g_Health[client]);

			g_OnFire[client] = false;

			if (!IsFakeClient(client))
			{
				EmitSoundToClient(client, "weapons/bugbait/bugbait_impact1.wav");
				PrintHelp(client, "{red}*You picked up \x04Health", 0);

				if (g_Hints[client])
					PrintHelp(client, "{red}\x05*Your health has been increased", 0);
			}
		}
	}
}

public Action:SpawnZombieBlood(Handle:timer, any:client)
{
	new Float: ClientOrigin[3];

	if (IsClientInGame(client))
	{
		GetClientAbsOrigin(client, ClientOrigin);

		if (IsAreaClear(ClientOrigin))
		{
			g_ZombieBloodNumber++;

			new ent = CreateEntityByName("prop_physics_override");
			if (ent>0)
			{
				SetEntityModel(ent, "models/healthvial.mdl");
				new String:bloodname[16];
				Format(bloodname, sizeof(bloodname), "Ammo%i", g_ZombieBloodNumber);
				DispatchKeyValue(ent, "StartDisabled", "false");
				DispatchKeyValue(ent, "targetname", bloodname);
				SetEntityMoveType(ent, MOVETYPE_VPHYSICS);
				SetEntProp(ent, Prop_Send, "m_CollisionGroup", DROP_COLLISION);
				SetEntProp(ent, Prop_Send, "m_usSolidFlags", DROP_SOLID_FLAGS);
				SetEntProp(ent, Prop_Send, "m_nSolidType", DROP_SOLID);

				//SetEntityRenderFx(ent, RENDERFX_PULSE_FAST_WIDE);

				DispatchSpawn(ent);
				TeleportEntity(ent, ClientOrigin, NULL_VECTOR, NULL_VECTOR);

				SDKHook(ent, SDKHook_StartTouch, TouchHookZombieBlood);
				SDKHook(ent, SDKHook_Touch, TouchHookZombieBlood);
				SDKHook(ent, SDKHook_EndTouch, TouchHookZombieBlood);

				#if DEBUG
					LogToFileEx(g_szLogFileName,"[L4DOD] Created zombieblood drop:%i", ent);
				#endif

				new String:addoutput[64];
				Format(addoutput, sizeof(addoutput), "OnUser1 !self:kill::%f:1", 10.0);
				SetVariantString(addoutput);
				AcceptEntityInput(ent, "AddOutput");
				AcceptEntityInput(ent, "FireUser1");

				AttachParticle(ent, "fire_small_base", 10.0);
			}
		}
		else
		{
			new player = GetClosestClient(ClientOrigin, 0);

			if (player > 0)
				AddZombieBlood(player);
		}
	}

	return Plugin_Handled;
}

public Action:TouchHookZombieBlood(entity, client)
{
	if (client > 0 && client <= MaxClients && !g_isIgnored[client])
	{
		AddZombieBlood(client);

		if (g_isInfected[client])
		{
			g_isInfected[client] = false;
			PrintHelp(client, "*Your infection was {green}cured", 0);

			SetEntityModel(client, "models/player/american_assault.mdl");
		}

		DestroyEntity(entity);
	}
	return Plugin_Handled;
}

AddZombieBlood(client)
{
	if (IsClientInGame(client) && IsPlayerAlive(client))
	{
		if (GetClientTeam(client) == ALLIES && !g_isIgnored[client])
		{
			g_isIgnored[client] = true;

			EmitSoundToClient(client, "weapons/bugbait/bugbait_impact1.wav");
			AddParticle(client, "smokegrenade", 2.0, 10.0);
			PrintHelp(client, "*You picked up \x04Zombie Blood", 0);

			if (g_Hints[client])
				PrintHelp(client, "\x05*The Zombies cannot see you", 0);

			new duration;
			if (g_bIsSupporter[client])
			{
				duration = 15;
			}
			else if (g_IsMember[client] > 0)
			{
				duration = 13;
			}
			else
			{
				duration = 7;
			}

			SetEntProp(client, Prop_Data, "m_takedamage", 0, 1);
			SetAlpha(client, 20);
			SetEntPropFloat(client, Prop_Send, "m_flProgressBarStartTime", GetGameTime());
			SetEntProp(client, Prop_Send, "m_iProgressBarDuration", duration);
			CreateTimer(float(duration), RestoreHealthFromZombieBlood, client, TIMER_FLAG_NO_MAPCHANGE);
			CreateTimer(float(duration), StopIgnoring, client, TIMER_FLAG_NO_MAPCHANGE);
			g_ShowSprite[client] = false;
		}
		else if (GetClientTeam(client) == AXIS && g_ZombieType[client] > -1)
		{
			g_Health[client] = g_HealthMax[client];

			if (!IsFakeClient(client))
			{
				EmitSoundToClient(client, "weapons/bugbait/bugbait_impact1.wav");
				PrintHelp(client, "*You picked up \x04Zombie Blood", 0);

				if (g_Hints[client])
					PrintHelp(client, "\x05*Your health has been restored", 0);
			}
		}
	}
}

public Action:StopIgnoring(Handle:timer, any:client)
{
	if (IsClientInGame(client) && IsPlayerAlive(client) && g_isIgnored[client])
	{
		g_isIgnored[client] = false;
		SetAlpha(client, 255);
		ClientCommand(client, "r_screenoverlay 0");
		EmitSoundToClient(client, "weapons/bugbait/bugbait_squeeze3.wav");
		SetEntPropFloat(client, Prop_Send, "m_flProgressBarStartTime", GetGameTime());
		SetEntProp(client, Prop_Send, "m_iProgressBarDuration", 0);

		g_ShowSprite[client] = true;
	}

	return Plugin_Handled;
}

public Action:SpawnPills(Handle:timer, any:client)
{
	new Float: ClientOrigin[3];

	if (IsClientInGame(client))
	{
		GetClientAbsOrigin(client, ClientOrigin);

		if (IsAreaClear(ClientOrigin))
		{
			g_PillsNumber++;

			new ent = CreateEntityByName("prop_physics_override");
			if (ent>0)
			{
				SetEntityModel(ent, "models/props_lab/jar01a.mdl");
				new String:pillsname[16];
				Format(pillsname, sizeof(pillsname), "Ammo%i", g_PillsNumber);
				DispatchKeyValue(ent, "StartDisabled", "false");
				DispatchKeyValue(ent, "targetname", pillsname);
				SetEntityMoveType(ent, MOVETYPE_VPHYSICS);
				SetEntProp(ent, Prop_Send, "m_CollisionGroup", DROP_COLLISION);
				SetEntProp(ent, Prop_Send, "m_usSolidFlags", DROP_SOLID_FLAGS);
				SetEntProp(ent, Prop_Send, "m_nSolidType", DROP_SOLID);

				//SetEntityRenderFx(ent, RENDERFX_PULSE_FAST_WIDE);

				DispatchSpawn(ent);
				TeleportEntity(ent, ClientOrigin, NULL_VECTOR, NULL_VECTOR);

				SDKHook(ent, SDKHook_StartTouch, TouchHookPills);
				SDKHook(ent, SDKHook_Touch, TouchHookPills);
				SDKHook(ent, SDKHook_EndTouch, TouchHookPills);

				#if DEBUG
					LogToFileEx(g_szLogFileName,"[L4DOD] Created pills drop:%i", ent);
				#endif

				new String:addoutput[64];
				Format(addoutput, sizeof(addoutput), "OnUser1 !self:kill::%f:1", 10.0);
				SetVariantString(addoutput);
				AcceptEntityInput(ent, "AddOutput");
				AcceptEntityInput(ent, "FireUser1");

				AttachParticle(ent, "fire_small_base", 10.0);
			}
		}
		else
		{
			new player = GetClosestClient(ClientOrigin, BOTS);

			if (player > 0)
				AddPills(player);
		}
	}

	return Plugin_Handled;
}

public Action:TouchHookPills(entity, client)
{
	if (client > 0 && client <= MaxClients)
	{
		new health = g_Health[client];

		if (!IsFakeClient(client) && health < g_HealthMax[client])
		{
			AddPills(client);
			DestroyEntity(entity);
		}
	}
	return Plugin_Handled;
}

AddPills(client)
{
	if (GetClientTeam(client) == ALLIES)
	{
		if (IsClientInGame(client) && IsPlayerAlive(client))
		{
			//Pills stuff
			EmitSoundToClient(client, "left4dod/pillsstart.wav");

			SetHealth(client, MAXHEALTH);

			PrintHelp(client, "*You picked up \x04Pills", 0);

			if (g_Hints[client])
				PrintHelp(client, "*You have maximum health", 0);
		}
	}
	else if (IsClientInGame(client) && IsPlayerAlive(client) && GetClientTeam(client) == AXIS)
	{
		SetHealth(client, MAXHEALTH);

		if (!IsFakeClient(client))
		{
			EmitSoundToClient(client, "weapons/bugbait/bugbait_impact1.wav");
			PrintHelp(client, "*You picked up \x04Pills", 0);

			if (g_Hints[client])
				PrintHelp(client, "\x05*Your health is at max", 0);
		}
	}
}

public Action:SpawnHooch(Handle:timer, any:client)
{
	new Float: ClientOrigin[3];

	if (IsClientInGame(client))
	{
		GetClientAbsOrigin(client, ClientOrigin);

		if (IsAreaClear(ClientOrigin))
		{
			g_HoochNumber++;

			new ent = CreateEntityByName("prop_physics_override");
			if (ent>0)
			{
				SetEntityModel(ent, "models/props_junk/glassjug01.mdl");
				new String:hoochname[16];
				Format(hoochname, sizeof(hoochname), "Hooch%i", g_HoochNumber);
				DispatchKeyValue(ent, "StartDisabled", "false");
				DispatchKeyValue(ent, "targetname", hoochname);
				SetEntityMoveType(ent, MOVETYPE_VPHYSICS);
				SetEntProp(ent, Prop_Send, "m_CollisionGroup", DROP_COLLISION);
				SetEntProp(ent, Prop_Send, "m_usSolidFlags", 152);
				SetEntProp(ent, Prop_Send, "m_nSolidType", DROP_SOLID);

				//SetEntityRenderFx(ent, RENDERFX_PULSE_FAST_WIDE);

				DispatchSpawn(ent);
				TeleportEntity(ent, ClientOrigin, NULL_VECTOR, NULL_VECTOR);

				SDKHook(ent, SDKHook_StartTouch, TouchHookHooch);
				SDKHook(ent, SDKHook_Touch, TouchHookHooch);
				SDKHook(ent, SDKHook_EndTouch, TouchHookHooch);

				#if DEBUG
					LogToFileEx(g_szLogFileName,"[L4DOD] Created hooch drop:%i", ent);
				#endif

				new String:addoutput[64];
				Format(addoutput, sizeof(addoutput), "OnUser1 !self:kill::%f:1", 10.0);
				SetVariantString(addoutput);
				AcceptEntityInput(ent, "AddOutput");
				AcceptEntityInput(ent, "FireUser1");

				AttachParticle(ent, "fire_small_base", 10.0);
			}
		}
		else
		{
			new player = GetClosestClient(ClientOrigin, AXIS);

			if (player > 0)
				AddHooch(player);
		}
	}

	return Plugin_Handled;
}

public Action:TouchHookHooch(entity, client)
{
	if (client > 0 && client <= MaxClients)
	{
		if (GetClientTeam(client) == ALLIES && !g_hasHooch[client])
		{
			AddHooch(client);
			DestroyEntity(entity);
		}
	}
	return Plugin_Handled;
}

AddHooch(client)
{
	if (GetClientTeam(client) == ALLIES && !g_hasHooch[client])
	{
		EmitSoundToClient(client, "left4dod/hooch_drink.mp3");

		PrintHelp(client, "*You picked up a \x04Bottle of Hooch", 0);

		if (g_Hints[client])
			PrintHelp(client, "*You can sprint without tiring!", 0);

		new duration;
		if (g_bIsSupporter[client])
		{
			duration = 15;
		}
		else if (g_IsMember[client] > 0)
		{
			duration = 13;
		}
		else
		{
			duration = 5;
		}

		SetEntPropFloat(client, Prop_Send, "m_flProgressBarStartTime", GetGameTime());
		SetEntProp(client, Prop_Send, "m_iProgressBarDuration", duration);

		g_hasHooch[client] = true;

		SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", HOOCH_SPEED);

		CreateTimer(float(duration), StopHoochEffect, client, TIMER_FLAG_NO_MAPCHANGE);
	}
}

public Action:StopHoochEffect(Handle:timer, any:client)
{
	if (IsClientInGame(client) && IsPlayerAlive(client) && g_hasHooch[client])
	{
		g_hasHooch[client] = false;

		EmitSoundToClient(client, "left4dod/hooch_groan.mp3");

		SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 1.0);

		SetEntPropFloat(client, Prop_Send, "m_flProgressBarStartTime", GetGameTime());
		SetEntProp(client, Prop_Send, "m_iProgressBarDuration", 0);
	}

	return Plugin_Handled;
}

public Action:SpawnBoxNades(Handle:timer, any:client)
{
	new Float: ClientOrigin[3];

	if (IsClientInGame(client))
	{
		GetClientAbsOrigin(client, ClientOrigin);
		if (IsAreaClear(ClientOrigin))
		{
			g_BoxNadesNumber++;

			new ent = CreateEntityByName("prop_physics_override");

			if (ent>0)
			{
				SetEntityModel(ent, "models/ammo/ammo_us.mdl");
				new String:nadesname[16];
				Format(nadesname, sizeof(nadesname), "BoxNades%i", g_BoxNadesNumber);
				DispatchKeyValue(ent, "StartDisabled", "false");
				DispatchKeyValue(ent, "targetname", nadesname);
				SetEntityMoveType(ent, MOVETYPE_VPHYSICS);
				SetEntProp(ent, Prop_Send, "m_CollisionGroup", DROP_COLLISION);
				SetEntProp(ent, Prop_Send, "m_usSolidFlags", DROP_SOLID_FLAGS);
				SetEntProp(ent, Prop_Send, "m_nSolidType", DROP_SOLID);

				//SetEntityRenderFx(ent, RENDERFX_PULSE_FAST_WIDE);

				DispatchSpawn(ent);
				SetEntityRenderColor(ent, 200, 124, 0, 255);
				TeleportEntity(ent, ClientOrigin, NULL_VECTOR, NULL_VECTOR);

				SDKHook(ent, SDKHook_StartTouch, TouchHookBoxNades);
				SDKHook(ent, SDKHook_Touch, TouchHookBoxNades);
				SDKHook(ent, SDKHook_EndTouch, TouchHookBoxNades);

				#if DEBUG
					LogToFileEx(g_szLogFileName,"[L4DOD] Created nades drop:%i", ent);
				#endif

				new String:addoutput[64];
				Format(addoutput, sizeof(addoutput), "OnUser1 !self:kill::%f:1", 10.0);
				SetVariantString(addoutput);
				AcceptEntityInput(ent, "AddOutput");
				AcceptEntityInput(ent, "FireUser1");

				AttachParticle(ent, "fire_small_base", 10.0);
			}
		}
		else
		{
			new player = GetClosestClient(ClientOrigin, BOTS);

			if (player > 0)
				AddBoxNades(player);
		}
	}

	return Plugin_Handled;
}

public Action:TouchHookBoxNades(entity, client)
{
	if (client > 0 && client <= MaxClients)
	{
		if (!IsFakeClient(client))
		{
			AddBoxNades(client);
			DestroyEntity(entity);
		}
	}
	return Plugin_Handled;
}

AddBoxNades(client)
{
	if (GetClientTeam(client) == ALLIES && !g_hasBoxNades[client])
	{
		EmitSoundToClient(client, "weapons/ammopickup.wav");

		PrintHelp(client, "*You picked up a \x04Box of Nades", 0);

		if (g_Hints[client])
			PrintHelp(client, "*You have six more nades", 0);

		if (g_bIsSupporter[client])
		{
			GivePlayerBoxNades(client, 12);
		}
		else if (g_IsMember[client] > 0)
		{
			GivePlayerBoxNades(client, 8);
		}
		else
		{
			GivePlayerBoxNades(client, 4);
		}

		g_hasBoxNades[client] = true;

		CreateTimer(5.0, AllowNadesPickup, client, TIMER_FLAG_NO_MAPCHANGE);
	}
	else if (g_ZombieType[client] == ANARCHIST)
	{
		g_numSkull[client] += 5;
		if (g_numSkull[client] >= 20)
			g_numSkull[client] = 20;

		EmitSoundToClient(client, "weapons/bugbait/bugbait_impact1.wav");
		PrintHelp(client, "*You picked up \x04Skull ammo", 0);

		if (g_Hints[client])
			PrintHelp(client, "\x05*You have more skulls to throw", 0);
	}
}

public Action:AllowNadesPickup(Handle:timer, any:client)
{
	if (!IsClientInGame(client))
		return Plugin_Handled;

	g_hasBoxNades[client] = false;

	return Plugin_Handled;
}

public Action:SpawnAntiGas(Handle:timer, any:client)
{
	new Float: ClientOrigin[3];

	if (IsClientInGame(client))
	{
		GetClientAbsOrigin(client, ClientOrigin);

		if (IsAreaClear(ClientOrigin))
		{
			g_AntiGasNumber++;

			new ent = CreateEntityByName("prop_physics_override");
			if (ent>0)
			{
				SetEntityModel(ent, "models/props_lab/jar01b.mdl");
				new String:antigasname[16];
				Format(antigasname, sizeof(antigasname), "AntiGas%i", g_AntiGasNumber);
				DispatchKeyValue(ent, "StartDisabled", "false");
				DispatchKeyValue(ent, "targetname", antigasname);
				SetEntityMoveType(ent, MOVETYPE_VPHYSICS);
				SetEntProp(ent, Prop_Send, "m_CollisionGroup", DROP_COLLISION);
				SetEntProp(ent, Prop_Send, "m_usSolidFlags", DROP_SOLID_FLAGS);
				SetEntProp(ent, Prop_Send, "m_nSolidType", DROP_SOLID);
				//SetEntityRenderFx(ent, RENDERFX_PULSE_FAST_WIDE);

				DispatchSpawn(ent);
				SetEntityRenderColor(ent, 200, 124, 0, 255);
				TeleportEntity(ent, ClientOrigin, NULL_VECTOR, NULL_VECTOR);

				SDKHook(ent, SDKHook_StartTouch, TouchHookAntiGas);
				SDKHook(ent, SDKHook_Touch, TouchHookAntiGas);
				SDKHook(ent, SDKHook_EndTouch, TouchHookAntiGas);

				#if DEBUG
					LogToFileEx(g_szLogFileName,"[L4DOD] Created antigas drop:%i", ent);
				#endif

				new String:addoutput[64];
				Format(addoutput, sizeof(addoutput), "OnUser1 !self:kill::%f:1", 10.0);
				SetVariantString(addoutput);
				AcceptEntityInput(ent, "AddOutput");
				AcceptEntityInput(ent, "FireUser1");

				AttachParticle(ent, "fire_small_base", 10.0);
			}
		}
		else
		{
			new player = GetClosestClient(ClientOrigin, BOTS);

			if (player > 0)
				AddAntiGas(player);
		}
	}

	return Plugin_Handled;
}

public Action:TouchHookAntiGas(entity, client)
{
	if (client > 0 && client <= MaxClients && !g_hasAntiGas[client])
	{
		if (!IsFakeClient(client))
		{
			AddAntiGas(client);
			DestroyEntity(entity);
		}
	}
	return Plugin_Handled;
}

AddAntiGas(client)
{
	if (GetClientTeam(client) == ALLIES && !g_hasAntiGas[client])
	{
		if (IsClientInGame(client) && IsPlayerAlive(client))
		{
			//Pills stuff
			EmitSoundToClient(client, "left4dod/pillsstart.wav");

			g_hasAntiGas[client] = true;

			PrintHelp(client, "*You picked up \x04AntiGas", 0);

			if (g_Hints[client])
				PrintHelp(client, "*Gas will not affect you", 0);

			new duration;
			if (g_bIsSupporter[client])
			{
				duration = 30;
			}
			else if (g_IsMember[client] > 0)
			{
				duration = 20;
			}
			else
				duration = 15;

			CreateTimer(float(duration), StopAntiGasEffect, client, TIMER_FLAG_NO_MAPCHANGE);

		}
	}
	else if (g_ZombieType[client] == GASMAN)
	{
		g_iNumGasBombs[client] += 5;
		if (g_iNumGasBombs[client] >= 20)
			g_iNumGasBombs[client] = 20;

		EmitSoundToClient(client, "weapons/bugbait/bugbait_impact1.wav");
		PrintHelp(client, "*You picked up \x04Gas Bombs", 0);

		if (g_Hints[client])
			PrintHelp(client, "\x05*You have more gas bombs to throw", 0);
	}
}

public Action:StopAntiGasEffect(Handle:timer, any:client)
{
	if (IsClientInGame(client) && IsPlayerAlive(client) && g_hasAntiGas[client])
	{
		g_hasAntiGas[client] = false;

		PrintHelp(client, "*Your \x04AntiGas Pills\x01 have run out", 0);

		if (g_Hints[client])
			PrintHelp(client, "*Gas will now damage you again", 0);
	}

	return Plugin_Handled;
}

public Action:SpawnTNT(Handle:timer, any:client)
{
	new Float: ClientOrigin[3];

	if (IsClientInGame(client))
	{
		GetClientAbsOrigin(client, ClientOrigin);

		if (IsAreaClear(ClientOrigin))
		{
			g_TNTNumber++;

			new ent = CreateEntityByName("prop_physics_override");
			if (ent>0)
			{
				SetEntityModel(ent, "models/weapons/w_tnt.mdl");
				new String:tntname[16];
				Format(tntname, sizeof(tntname), "TNT%i", g_TNTNumber);
				DispatchKeyValue(ent, "StartDisabled", "false");
				DispatchKeyValue(ent, "targetname", tntname);
				SetEntityMoveType(ent, MOVETYPE_VPHYSICS);
				SetEntProp(ent, Prop_Send, "m_CollisionGroup", DROP_COLLISION);
				SetEntProp(ent, Prop_Send, "m_usSolidFlags", DROP_SOLID_FLAGS);
				SetEntProp(ent, Prop_Send, "m_nSolidType", DROP_SOLID);

				//SetEntityRenderFx(ent, RENDERFX_PULSE_FAST_WIDE);

				DispatchSpawn(ent);
				TeleportEntity(ent, ClientOrigin, NULL_VECTOR, NULL_VECTOR);

				SDKHook(ent, SDKHook_StartTouch, TouchHookTNT);
				SDKHook(ent, SDKHook_Touch, TouchHookTNT);
				SDKHook(ent, SDKHook_EndTouch, TouchHookTNT);

				#if DEBUG
					LogToFileEx(g_szLogFileName,"[L4DOD] Created tnt drop:%i", ent);
				#endif

				new String:addoutput[64];
				Format(addoutput, sizeof(addoutput), "OnUser1 !self:kill::%f:1", 10.0);
				SetVariantString(addoutput);
				AcceptEntityInput(ent, "AddOutput");
				AcceptEntityInput(ent, "FireUser1");

				AttachParticle(ent, "fire_small_base", 10.0);
			}
		}
		else
		{
			new player = GetClosestClient(ClientOrigin, AXIS);

			if (player > 0)
				AddTNT(player);
		}
	}

	return Plugin_Handled;
}

public Action:SpawnTNTInFront(Handle:timer, any:iClient)
{
	if (IsClientInGame(iClient))
	{
		new Float:vecClient[3], Float:vecAngle[3], Float:vecAngleVector[3], Float:vecVelocity[3], Float:fDistance;
		GetClientEyePosition(iClient, vecClient);
		GetClientEyeAngles(iClient, vecAngle);
		vecAngle[0] = -5.0;
		vecAngle[1] += 40.0;

		//How far away from the player to spawn the TNT before throwing it
		fDistance = 2.0;

		//Determine the direction the TNT has to go
		//and where it has to spawn from
		GetAngleVectors(vecAngle, vecAngleVector, NULL_VECTOR, NULL_VECTOR);

		vecClient[0]+=vecAngleVector[0]*fDistance;
		vecClient[1]+=vecAngleVector[1]*fDistance;
		vecClient[2]+=vecAngleVector[2]*fDistance;

		vecClient[2] -= 20.0;

		//Determine how hard to throw it
		GetAngleVectors(vecAngle, vecVelocity, NULL_VECTOR, NULL_VECTOR);
		NormalizeVector(vecVelocity, vecVelocity);
		ScaleVector(vecVelocity, 350.0);

		g_TNTNumber++;

		new ent = CreateEntityByName("prop_physics_override");
		if (ent>0)
		{
			SetEntityModel(ent, "models/weapons/w_tnt.mdl");
			new String:tntname2[16];
			Format(tntname2, sizeof(tntname2), "TNT%i", g_TNTNumber);
			DispatchKeyValue(ent, "StartDisabled", "false");
			DispatchKeyValue(ent, "targetname", tntname2);
			SetEntityMoveType(ent, MOVETYPE_VPHYSICS);
			SetEntProp(ent, Prop_Send, "m_CollisionGroup", DROP_COLLISION);
			SetEntProp(ent, Prop_Send, "m_usSolidFlags", DROP_SOLID_FLAGS);
			SetEntProp(ent, Prop_Send, "m_nSolidType", DROP_SOLID);

			//SetEntityRenderFx(ent, RENDERFX_PULSE_FAST_WIDE);

			DispatchSpawn(ent);
			TeleportEntity(ent, vecClient, NULL_VECTOR, vecVelocity);

			SDKHook(ent, SDKHook_StartTouch, TouchHookTNT);
			SDKHook(ent, SDKHook_Touch, TouchHookTNT);
			SDKHook(ent, SDKHook_EndTouch, TouchHookTNT);

			#if DEBUG
				LogToFileEx(g_szLogFileName,"[L4DOD] Created tnt drop:%i", ent);
			#endif

			new String:addoutput[64];
			Format(addoutput, sizeof(addoutput), "OnUser1 !self:kill::%f:1", 10.0);
			SetVariantString(addoutput);
			AcceptEntityInput(ent, "AddOutput");
			AcceptEntityInput(ent, "FireUser1");
		}
	}

	return Plugin_Handled;
}

public Action:SpawnTNTInFrontPrimed(Handle:timer, any:iClient)
{
	if (IsClientInGame(iClient))
	{
		new Float:vecClient[3], Float:vecAngle[3], Float:vecAngleVector[3], Float:vecVelocity[3], Float:fDistance;
		GetClientEyePosition(iClient, vecClient);
		GetClientEyeAngles(iClient, vecAngle);
		vecAngle[0] = -5.0;

		//How far away from the player to spawn the TNT before throwing it
		fDistance = 2.0;

		//Determine the direction the TNT has to go
		//and where it has to spawn from
		GetAngleVectors(vecAngle, vecAngleVector, NULL_VECTOR, NULL_VECTOR);

		vecClient[0]+=vecAngleVector[0]*fDistance;
		vecClient[1]+=vecAngleVector[1]*fDistance;
		vecClient[2]+=vecAngleVector[2]*fDistance;

		vecClient[2] -= 20.0;

		//Determine how hard to throw it
		GetAngleVectors(vecAngle, vecVelocity, NULL_VECTOR, NULL_VECTOR);
		NormalizeVector(vecVelocity, vecVelocity);
		ScaleVector(vecVelocity, 550.0);

		g_TNTNumber++;

		new ent = CreateEntityByName("prop_physics_override");
		if (ent>0)
		{
			SetEntityModel(ent, "models/weapons/w_tnt.mdl");
			new String:tntname2[16];
			Format(tntname2, sizeof(tntname2), "TNT%i", g_TNTNumber);
			DispatchKeyValue(ent, "StartDisabled", "false");
			DispatchKeyValue(ent, "targetname", tntname2);
			SetEntityMoveType(ent, MOVETYPE_VPHYSICS);
			SetEntProp(ent, Prop_Send, "m_CollisionGroup", DROP_COLLISION);
			SetEntProp(ent, Prop_Send, "m_usSolidFlags", DROP_SOLID_FLAGS);
			SetEntProp(ent, Prop_Send, "m_nSolidType", DROP_SOLID);

			//SetEntityRenderFx(ent, RENDERFX_PULSE_FAST_WIDE);

			DispatchSpawn(ent);
			TeleportEntity(ent, vecClient, NULL_VECTOR, vecVelocity);

			SDKHook(ent, SDKHook_StartTouch, TouchHookTNT);
			SDKHook(ent, SDKHook_Touch, TouchHookTNT);
			SDKHook(ent, SDKHook_EndTouch, TouchHookTNT);
			SDKHook(ent, SDKHook_SetTransmit, Hook_SetTransmitTNT);

			#if DEBUG
				LogToFileEx(g_szLogFileName,"[L4DOD] Created tnt drop:%i", ent);
			#endif

			DispatchKeyValue(ent, "physdamagescale", "1.0");
			DispatchKeyValue(ent, "spawnflags", "519");
			SetEntProp(ent, Prop_Data, "m_takedamage", 2);
			DispatchKeyValue(ent, "MinHealthDmg", "20.0");
			SDKHook(ent, SDKHook_OnTakeDamage, EntityTakeDamage);

			SetEntityRenderColor(ent, 255, 0, 128, 255);

			PrintHelp(iClient, "*You primed and dropped \x04TNT", 0);
			if (g_Hints[iClient])
				PrintHelp(iClient, "\x05*Shoot the Red TNT and it will explode", 0);

			g_iDroppedTNT[iClient] = ent;

			new String:addoutput[64];
			Format(addoutput, sizeof(addoutput), "OnUser1 !self:kill::%f:1", 20.0);
			SetVariantString(addoutput);
			AcceptEntityInput(ent, "AddOutput");
			AcceptEntityInput(ent, "FireUser1");
		}
	}

	return Plugin_Handled;
}

public Action:Hook_SetTransmitTNT(entity, client)
{
	//The AXIS should not see the TNT
    if (GetClientTeam(client) == AXIS)
        return Plugin_Handled;

    return Plugin_Continue;
}

public Action:EntityTakeDamage(entity, &attacker, &inflictor, &Float:damage, &damagetype)
{
	if (IsValidEntity(entity))
	{
		new Float:vecExplosion[3];
		GetEntDataVector(entity, g_oEntityOrigin, vecExplosion);

		DestroyEntity(entity);

		new Handle:shakedata = CreateDataPack();
		WritePackFloat(shakedata, vecExplosion[0]);
		WritePackFloat(shakedata, vecExplosion[1]);
		WritePackFloat(shakedata, vecExplosion[2]);

		CreateTimer(0.1, TinyShake, shakedata, TIMER_FLAG_NO_MAPCHANGE);

		// Create the Explosion
		new explosion = CreateEntityByName("env_explosion");
		if (explosion != -1)
		{
			new String:originData[64];
			Format(originData, sizeof(originData), "%f %f %f", vecExplosion[0], vecExplosion[1], vecExplosion[2]);

			DispatchKeyValue(explosion,"Origin", originData);
			DispatchKeyValue(explosion,"iMagnitude", "200");
			DispatchSpawn(explosion);
			SetEntPropEnt(explosion, Prop_Data, "m_hOwnerEntity", attacker);

			AcceptEntityInput(explosion, "Explode");
			AcceptEntityInput(explosion, "Kill");

			PositionParticle(vecExplosion, "explosion_huge_b", 2.0);
		}
	}
}

AddTNT(client)
{
	//Pick up if no airstrike
	if (GetClientTeam(client) == ALLIES && !g_airstrike[client] && !g_Shield[client])
	{
		if (IsClientInGame(client) && IsPlayerAlive(client) && !IsClientObserver(client))
		{
			#if DEBUG
				LogToFileEx(g_szLogFileName,"[L4DOD] Allies - TNT given:%i", client);
			#endif

			// Strip the weapons
			new weaponslot;
			weaponslot = GetPlayerWeaponSlot(client, 4);
			if(weaponslot == -1)
			{
				GivePlayerItem(client, "weapon_basebomb");
				PrintHelp(client, "*You picked up \x04TNT", 0);

				if (g_Hints[client])
				{
					PrintHelp(client, "*To plant it, stand near a wall, press and hold E (+USE)", 0);
					PrintHelp(client, "*Or press E (+USE) to throw it on the ground and shoot it", 0);
				}

				EmitSoundToClient(client, "weapons/c4_pickup.wav");
			}
		}
	}
}

public Action:TouchHookTNT(entity, client)
{
	if (client > 0 && client <= MaxClients)
	{
		if (!IsFakeClient(client) && GetClientTeam(client) == ALLIES)
		{
			AddTNT(client);
			DestroyEntity(entity);
		}
		else
		{
			new owner = 0;
			for (new i = 1; i <= MaxClients; i++)
			{
				if (g_iDroppedTNT[i] == entity)
					owner = i;
			}

			if (IsValidEntity(entity) && owner > 0  && IsValidEntity(owner))
			{
				new Float:vecExplosion[3];
				GetEntDataVector(entity, g_oEntityOrigin, vecExplosion);

				DestroyEntity(entity);

				new Handle:shakedata = CreateDataPack();
				WritePackFloat(shakedata, vecExplosion[0]);
				WritePackFloat(shakedata, vecExplosion[1]);
				WritePackFloat(shakedata, vecExplosion[2]);

				CreateTimer(0.1, TinyShake, shakedata, TIMER_FLAG_NO_MAPCHANGE);

				// Create the Explosion
				new explosion = CreateEntityByName("env_explosion");
				if (explosion != -1 && IsValidEntity(explosion))
				{
					new String:originData[64];
					Format(originData, sizeof(originData), "%f %f %f", vecExplosion[0], vecExplosion[1], vecExplosion[2]);

					DispatchKeyValue(explosion,"Origin", originData);
					DispatchKeyValue(explosion,"iMagnitude", "200");
					DispatchSpawn(explosion);
					SetEntPropEnt(explosion, Prop_Data, "m_hOwnerEntity", owner);

					AcceptEntityInput(explosion, "Explode");
					AcceptEntityInput(explosion, "Kill");

					PositionParticle(vecExplosion, "explosion_huge_b", 2.0);
				}

				g_iDroppedTNT[owner] = 0;
			}
		}
	}
	return Plugin_Handled;
}

public Action:SpawnRadio(Handle:timer, any:client)
{
	new Float: ClientOrigin[3];

	if (IsClientInGame(client))
	{
		GetClientAbsOrigin(client, ClientOrigin);

		if (IsAreaClear(ClientOrigin))
		{
			g_RadioNumber++;

			new ent = CreateEntityByName("prop_physics_override");
			if (ent>0)
			{
				SetEntityModel(ent, "models/props_misc/german_radio.mdl");
				decl String:radioname[16];
				Format(radioname, sizeof(radioname), "Radio%i", g_RadioNumber);
				DispatchKeyValue(ent, "StartDisabled", "false");
				DispatchKeyValue(ent, "targetname", radioname);
				SetEntityMoveType(ent, MOVETYPE_VPHYSICS);
				SetEntProp(ent, Prop_Send, "m_CollisionGroup", DROP_COLLISION);
				SetEntProp(ent, Prop_Send, "m_usSolidFlags", DROP_SOLID_FLAGS);
				SetEntProp(ent, Prop_Send, "m_nSolidType", DROP_SOLID);

				//SetEntityRenderFx(ent, RENDERFX_PULSE_FAST_WIDE);

				DispatchSpawn(ent);
				TeleportEntity(ent, ClientOrigin, NULL_VECTOR, NULL_VECTOR);

				SDKHook(ent, SDKHook_StartTouch, TouchHookRadio);
				SDKHook(ent, SDKHook_Touch, TouchHookRadio);
				SDKHook(ent, SDKHook_EndTouch, TouchHookRadio);

				#if DEBUG
					LogToFileEx(g_szLogFileName,"[L4DOD] Created radio drop:%i", ent);
				#endif

				new String:addoutput[64];
				Format(addoutput, sizeof(addoutput), "OnUser1 !self:kill::%f:1", 10.0);
				SetVariantString(addoutput);
				AcceptEntityInput(ent, "AddOutput");
				AcceptEntityInput(ent, "FireUser1");

				AttachParticle(ent, "fire_small_base", 10.0);
			}
		}
		else
		{
			new player = GetClosestClient(ClientOrigin, AXIS);

			if (player > 0 && !g_airstrike[client] && !g_Shield[client])
				AddRadio(player);
		}
	}

	return Plugin_Handled;
}

public Action:SpawnRadioInFront(Handle:timer, any:iClient)
{
	if (IsClientInGame(iClient))
	{
		new Float:vecClient[3], Float:vecAngle[3], Float:vecAngleVector[3], Float:vecVelocity[3], Float:fDistance;
		GetClientEyePosition(iClient, vecClient);
		GetClientEyeAngles(iClient, vecAngle);
		vecAngle[0] = -5.0;
		vecAngle[1] += 40.0;

		//How far away from the player to spawn the TNT before throwing it
		fDistance = 2.0;

		//Determine the direction the TNT has to go
		//and where it has to spawn from
		GetAngleVectors(vecAngle, vecAngleVector, NULL_VECTOR, NULL_VECTOR);

		vecClient[0]+=vecAngleVector[0]*fDistance;
		vecClient[1]+=vecAngleVector[1]*fDistance;
		vecClient[2]+=vecAngleVector[2]*fDistance;

		vecClient[2] -= 20.0;

		//Determine how hard to throw it
		GetAngleVectors(vecAngle, vecVelocity, NULL_VECTOR, NULL_VECTOR);
		NormalizeVector(vecVelocity, vecVelocity);
		ScaleVector(vecVelocity, 250.0);

		g_RadioNumber++;

		new ent = CreateEntityByName("prop_physics_override");
		if (ent>0)
		{
			SetEntityModel(ent, "models/props_misc/german_radio.mdl");
			decl String:radioname[16];
			Format(radioname, sizeof(radioname), "Radio%i", g_RadioNumber);
			DispatchKeyValue(ent, "StartDisabled", "false");
			DispatchKeyValue(ent, "targetname", radioname);
			SetEntityMoveType(ent, MOVETYPE_VPHYSICS);
			SetEntProp(ent, Prop_Send, "m_CollisionGroup", DROP_COLLISION);
			SetEntProp(ent, Prop_Send, "m_usSolidFlags", DROP_SOLID_FLAGS);
			SetEntProp(ent, Prop_Send, "m_nSolidType", DROP_SOLID);

			//SetEntityRenderFx(ent, RENDERFX_PULSE_FAST_WIDE);

			DispatchSpawn(ent);
			TeleportEntity(ent, vecClient, NULL_VECTOR, vecVelocity);

			SDKHook(ent, SDKHook_StartTouch, TouchHookRadio);
			SDKHook(ent, SDKHook_Touch, TouchHookRadio);
			SDKHook(ent, SDKHook_EndTouch, TouchHookRadio);

			#if DEBUG
				LogToFileEx(g_szLogFileName,"[L4DOD] Created thrown radio drop:%i", ent);
			#endif

			new String:addoutput[64];
			Format(addoutput, sizeof(addoutput), "OnUser1 !self:kill::%f:1", 10.0);
			SetVariantString(addoutput);
			AcceptEntityInput(ent, "AddOutput");
			AcceptEntityInput(ent, "FireUser1");

			AttachParticle(ent, "fire_small_base", 10.0);
		}
	}

	return Plugin_Handled;
}

public Action:TouchHookRadio(entity, client)
{
	if (client > 0 && client <= MaxClients)
	{
		if (!IsFakeClient(client) && GetClientTeam(client) == ALLIES && !g_airstrike[client] && !g_Shield[client])
		{
			AddRadio(client);
			DestroyEntity(entity);
		}
	}
	return Plugin_Handled;
}

AddRadio(client)
{
	if (GetClientTeam(client) == ALLIES && !g_airstrike[client] && !g_Shield[client])
	{
		if (IsClientInGame(client) && IsPlayerAlive(client) && !IsClientObserver(client))
		{
			#if DEBUG
				LogToFileEx(g_szLogFileName,"[L4DOD] Allies - Radio given:%i", client);
			#endif

			g_airstrike[client] = true;

			PrintHelp(client, "*You picked up a \x04Radio", 0);
			PrintHelp(client, "*You can call in an airstrike", 0);

			if (g_Hints[client])
				PrintHelp(client, "To use, point your crosshairs, and press E (+USE)", 0);

			EmitSoundToClient(client, "weapons/c4_pickup.wav");

			new weaponslot = GetPlayerWeaponSlot(client, 4);
			if(weaponslot != -1)
			{
				if (RemovePlayerItem(client, weaponslot))
					RemoveEdict(weaponslot);

				CreateTimer(0.1, SpawnTNTInFront, client, TIMER_FLAG_NO_MAPCHANGE);
			}
		}
	}
}

public Action:SpawnGuts(Handle:timer, any:client)
{
	new Float:ClientOrigin[3];

	if (IsClientInGame(client) && g_StoreEnabled)
	{
		GetClientAbsOrigin(client, ClientOrigin);
		if (IsAreaClear(ClientOrigin))
		{
			new rnd=GetRandomInt(0,100);

			if (rnd > 50)
			{
				if (GetConVarBool(hL4DFright))
				{
					CreateTimer(0.2, SpawnPumpkin, client, TIMER_FLAG_NO_MAPCHANGE);
				}
			}
			else
			{
				new ent = CreateEntityByName("prop_physics_override");
				if (ent > 0)
				{
					SetEntityModel(ent, "models/helmets/helmet_german.mdl");

					DispatchKeyValue(ent, "StartDisabled", "false");
					SetEntityMoveType(ent, MOVETYPE_VPHYSICS);
					SetEntProp(ent, Prop_Send, "m_CollisionGroup", DROP_COLLISION);
					SetEntProp(ent, Prop_Send, "m_usSolidFlags", DROP_SOLID_FLAGS);
					SetEntProp(ent, Prop_Send, "m_nSolidType", DROP_SOLID);


					DispatchSpawn(ent);
					TeleportEntity(ent, ClientOrigin, NULL_VECTOR, NULL_VECTOR);

					if (rnd <= 5)
					{
						SetEntityRenderColor(ent, 64, 0, 128, 255);
						SDKHook(ent, SDKHook_StartTouch, TouchHookPurple);
						SDKHook(ent, SDKHook_Touch, TouchHookPurple);
						SDKHook(ent, SDKHook_EndTouch, TouchHookPurple);
					}
					else if (rnd == 10)
					{
						SetEntityRenderColor(ent, 234, 193, 23, 255);
						SDKHook(ent, SDKHook_StartTouch, TouchHookGold);
						SDKHook(ent, SDKHook_Touch, TouchHookGold);
						SDKHook(ent, SDKHook_EndTouch, TouchHookGold);
					}
					else
					{
						SDKHook(ent, SDKHook_StartTouch, TouchHookJunk);
						SDKHook(ent, SDKHook_Touch, TouchHookJunk);
						SDKHook(ent, SDKHook_EndTouch, TouchHookJunk);
					}

					new String:addoutput[64];
					Format(addoutput, sizeof(addoutput), "OnUser1 !self:kill::%f:1", 10.0);
					SetVariantString(addoutput);
					AcceptEntityInput(ent, "AddOutput");
					AcceptEntityInput(ent, "FireUser1");

					AttachParticle(ent, "fire_small_base", 10.0);
				}
			}
		}
	}

	return Plugin_Handled;
}

public Action:SpawnBigBucks(Handle:timer, any:client)
{
	new Float:ClientOrigin[3];

	if (IsClientInGame(client) && g_StoreEnabled)
	{
		GetClientAbsOrigin(client, ClientOrigin);
		if (IsAreaClear(ClientOrigin))
		{
			new ent = CreateEntityByName("prop_physics_override");
			if (ent > 0)
			{
				SetEntityModel(ent, "models/helmets/helmet_american.mdl");

				DispatchKeyValue(ent, "StartDisabled", "false");
				SetEntityMoveType(ent, MOVETYPE_VPHYSICS);
				SetEntProp(ent, Prop_Send, "m_CollisionGroup", DROP_COLLISION);
				SetEntProp(ent, Prop_Send, "m_usSolidFlags", DROP_SOLID_FLAGS);
				SetEntProp(ent, Prop_Send, "m_nSolidType", DROP_SOLID);


				DispatchSpawn(ent);
				TeleportEntity(ent, ClientOrigin, NULL_VECTOR, NULL_VECTOR);

				SetEntityRenderColor(ent, 234, 193, 23, 255);
				SDKHook(ent, SDKHook_StartTouch, TouchHookUsGold);
				SDKHook(ent, SDKHook_Touch, TouchHookUsGold);
				SDKHook(ent, SDKHook_EndTouch, TouchHookUsGold);

				new String:addoutput[64];
				Format(addoutput, sizeof(addoutput), "OnUser1 !self:kill::%f:1", 10.0);
				SetVariantString(addoutput);
				AcceptEntityInput(ent, "AddOutput");
				AcceptEntityInput(ent, "FireUser1");

				AttachParticle(ent, "fire_small_base", 10.0);
			}
		}
	}

	return Plugin_Handled;
}

public Action:TouchHookJunk(entity, client)
{
	if (client > 0 && client <= MaxClients && g_StoreEnabled)
	{
		if (!IsFakeClient(client))
		{
			if (GetConVarInt(hL4DFright) == 1)
			{
				g_iMoney[client]+= 10;
				PrintToChat(client, "\x01* +\x04$10 \x01Total: \x04$%i", g_iMoney[client]);
			}
			else
			{
				g_iMoney[client]++;
				PrintToChat(client, "\x01* +\x04$1 \x01Total: \x04$%i", g_iMoney[client]);
			}
			EmitSoundToClient(client, "ambient/levels/labs/coinslot1.wav");
		}

		DestroyEntity(entity);
	}
	return Plugin_Handled;
}

public Action:TouchHookPurple(entity, client)
{
	if (client > 0 && client <= MaxClients && g_StoreEnabled)
	{
		if (!IsFakeClient(client))
		{
			if (GetConVarInt(hL4DFright) == 1)
			{
				g_iMoney[client] += 100;
				PrintToChat(client, "\x01* +\x04$100 \x01Total: \x04$%i", g_iMoney[client]);
			}
			else
			{
				g_iMoney[client] += 10;
				PrintToChat(client, "\x01* +\x04$10 \x01Total: \x04$%i", g_iMoney[client]);
			}

			EmitSoundToClient(client, "ambient/levels/labs/coinslot1.wav");
		}

		DestroyEntity(entity);
	}
	return Plugin_Handled;
}

public Action:TouchHookGold(entity, client)
{
	if (client > 0 && client <= MaxClients && g_StoreEnabled)
	{
		if (!IsFakeClient(client))
		{
			if (GetConVarInt(hL4DFright) == 1)
			{
				g_iMoney[client] += 500;
				PrintToChat(client, "\x01* +\x04$500 \x01Total: \x04$%i", g_iMoney[client]);
			}
			else
			{
				g_iMoney[client] += 50;
				PrintToChat(client, "\x01* +\x04$50 \x01Total: \x04$%i", g_iMoney[client]);
			}

			EmitSoundToClient(client, "ambient/levels/labs/coinslot1.wav");
		}

		DestroyEntity(entity);
	}
	return Plugin_Handled;
}

public Action:TouchHookUsGold(entity, client)
{
	if (client > 0 && client <= MaxClients && g_StoreEnabled)
	{
		if (!IsFakeClient(client))
		{
			g_iMoney[client] += 200;
			PrintToChat(client, "\x01* +\x04$200 \x01Total: \x04$%i", g_iMoney[client]);

			EmitSoundToClient(client, "ambient/levels/labs/coinslot1.wav");
		}

		DestroyEntity(entity);
	}
	return Plugin_Handled;
}


public Action:SpawnShield(Handle:timer, any:client)
{
	new Float: ClientOrigin[3];

	if (IsClientInGame(client))
	{
		GetClientAbsOrigin(client, ClientOrigin);

		if (IsAreaClear(ClientOrigin))
		{
			g_ShieldNumber++;

			new ent = CreateEntityByName("prop_physics_override");
			if (ent>0)
			{
				SetEntityModel(ent, "models/items/battery.mdl");
				decl String:shieldname[16];
				Format(shieldname, sizeof(shieldname), "Shield%i", g_ShieldNumber);
				DispatchKeyValue(ent, "StartDisabled", "false");
				DispatchKeyValue(ent, "targetname", shieldname);
				SetEntityMoveType(ent, MOVETYPE_VPHYSICS);
				SetEntProp(ent, Prop_Send, "m_CollisionGroup", DROP_COLLISION);
				SetEntProp(ent, Prop_Send, "m_usSolidFlags", DROP_SOLID_FLAGS);
				SetEntProp(ent, Prop_Send, "m_nSolidType", DROP_SOLID);

				//SetEntityRenderFx(ent, RENDERFX_PULSE_FAST_WIDE);

				DispatchSpawn(ent);
				TeleportEntity(ent, ClientOrigin, NULL_VECTOR, NULL_VECTOR);
				SDKHook(ent, SDKHook_StartTouch, TouchHookShield);
				SDKHook(ent, SDKHook_Touch, TouchHookShield);
				SDKHook(ent, SDKHook_EndTouch, TouchHookShield);

				#if DEBUG
					LogToFileEx(g_szLogFileName,"[L4DOD] Created shield drop:%i", ent);
				#endif

				new String:addoutput[64];
				Format(addoutput, sizeof(addoutput), "OnUser1 !self:kill::%f:1", 10.0);
				SetVariantString(addoutput);
				AcceptEntityInput(ent, "AddOutput");
				AcceptEntityInput(ent, "FireUser1");

				AttachParticle(ent, "fire_small_base", 10.0);
			}
		}
		else
		{
			new player = GetClosestClient(ClientOrigin, AXIS);

			if (player > 0 && !g_Shield[client])
				AddShield(player);
		}
	}

	return Plugin_Handled;
}

public Action:SpawnShieldInFront(Handle:timer, any:iClient)
{
	if (IsClientInGame(iClient))
	{
		new Float:vecClient[3], Float:vecAngle[3], Float:vecAngleVector[3], Float:vecVelocity[3], Float:fDistance;
		GetClientEyePosition(iClient, vecClient);
		GetClientEyeAngles(iClient, vecAngle);
		vecAngle[0] = -5.0;
		vecAngle[1] += 40.0;

		//How far away from the player to spawn the Shield before throwing it
		fDistance = 2.0;

		//Determine the direction the Shield has to go
		//and where it has to spawn from
		GetAngleVectors(vecAngle, vecAngleVector, NULL_VECTOR, NULL_VECTOR);

		vecClient[0]+=vecAngleVector[0]*fDistance;
		vecClient[1]+=vecAngleVector[1]*fDistance;
		vecClient[2]+=vecAngleVector[2]*fDistance;

		vecClient[2] -= 20.0;

		//Determine how hard to throw it
		GetAngleVectors(vecAngle, vecVelocity, NULL_VECTOR, NULL_VECTOR);
		NormalizeVector(vecVelocity, vecVelocity);
		ScaleVector(vecVelocity, 250.0);

		g_ShieldNumber++;

		new ent = CreateEntityByName("prop_physics_override");
		if (ent>0)
		{
			SetEntityModel(ent, "models/items/battery.mdl");
			decl String:shieldname[16];
			Format(shieldname, sizeof(shieldname), "Shield%i", g_ShieldNumber);
			DispatchKeyValue(ent, "StartDisabled", "false");
			DispatchKeyValue(ent, "targetname", shieldname);
			SetEntityMoveType(ent, MOVETYPE_VPHYSICS);
			SetEntProp(ent, Prop_Send, "m_CollisionGroup", DROP_COLLISION);
			SetEntProp(ent, Prop_Send, "m_usSolidFlags", DROP_SOLID_FLAGS);
			SetEntProp(ent, Prop_Send, "m_nSolidType", DROP_SOLID);

			//SetEntityRenderFx(ent, RENDERFX_PULSE_FAST_WIDE);

			DispatchSpawn(ent);
			TeleportEntity(ent, vecClient, NULL_VECTOR, vecVelocity);

			SDKHook(ent, SDKHook_StartTouch, TouchHookShield);
			SDKHook(ent, SDKHook_Touch, TouchHookShield);
			SDKHook(ent, SDKHook_EndTouch, TouchHookShield);

			#if DEBUG
				LogToFileEx(g_szLogFileName,"[L4DOD] Created thrown shield drop:%i", ent);
			#endif

			new String:addoutput[64];
			Format(addoutput, sizeof(addoutput), "OnUser1 !self:kill::%f:1", 10.0);
			SetVariantString(addoutput);
			AcceptEntityInput(ent, "AddOutput");
			AcceptEntityInput(ent, "FireUser1");

			AttachParticle(ent, "fire_small_base", 10.0);
		}
	}

	return Plugin_Handled;
}

public Action:TouchHookShield(entity, client)
{
	if (client > 0 && client <= MaxClients)
	{
		if (GetClientTeam(client) == ALLIES && !g_Shield[client])
		{
			AddShield(client);
			DestroyEntity(entity);
		}
	}
	return Plugin_Handled;
}

AddShield(client)
{
	if (GetClientTeam(client) == ALLIES && !g_Shield[client])
	{
		if (IsClientInGame(client) && IsPlayerAlive(client) && !IsClientObserver(client))
		{
			#if DEBUG
				LogToFileEx(g_szLogFileName,"[L4DOD] Allies - Shield given:%i", client);
			#endif

			g_Shield[client] = true;

			PrintHelp(client, "*You picked up a \x04Shield", 0);
			PrintHelp(client, "*You can use it defend yourself", 0);

			if (g_Hints[client])
				PrintHelp(client, "To use it, press E (+USE)", 0);

			EmitSoundToClient(client, "weapons/c4_pickup.wav");

			new weaponslot = GetPlayerWeaponSlot(client, 4);
			if(weaponslot != -1)
			{
				if (RemovePlayerItem(client, weaponslot))
					RemoveEdict(weaponslot);

				CreateTimer(0.1, SpawnTNTInFront, client, TIMER_FLAG_NO_MAPCHANGE);
			}

			if (g_airstrike[client])
			{
				g_airstrike[client] = false;

				CreateTimer(0.1, SpawnRadioInFront, client, TIMER_FLAG_NO_MAPCHANGE);
			}
		}
	}
}

public Action:SpawnPumpkin(Handle:timer, any:client)
{
	new Float:ClientOrigin[3];

	if (IsClientInGame(client) && g_StoreEnabled)
	{
		GetClientAbsOrigin(client, ClientOrigin);
		if (IsAreaClear(ClientOrigin))
		{
			new ent = CreateEntityByName("prop_physics_override");
			if (ent > 0)
			{
				SetEntityModel(ent, "models/models_kit/hallo_pumpkin_s.mdl");

				DispatchKeyValue(ent, "StartDisabled", "false");
				SetEntityMoveType(ent, MOVETYPE_VPHYSICS);
				SetEntProp(ent, Prop_Send, "m_CollisionGroup", DROP_COLLISION);
				SetEntProp(ent, Prop_Send, "m_usSolidFlags", DROP_SOLID_FLAGS);
				SetEntProp(ent, Prop_Send, "m_nSolidType", DROP_SOLID);


				DispatchSpawn(ent);
				TeleportEntity(ent, ClientOrigin, NULL_VECTOR, NULL_VECTOR);

				SDKHook(ent, SDKHook_StartTouch, TouchHookPumpkin);
				SDKHook(ent, SDKHook_Touch, TouchHookPumpkin);
				SDKHook(ent, SDKHook_EndTouch, TouchHookPumpkin);

				new String:addoutput[64];
				Format(addoutput, sizeof(addoutput), "OnUser1 !self:kill::%f:1", 10.0);
				SetVariantString(addoutput);
				AcceptEntityInput(ent, "AddOutput");
				AcceptEntityInput(ent, "FireUser1");

				AttachParticle(ent, "fire_small_base", 10.0);
			}
		}
	}

	return Plugin_Handled;
}

public Action:TouchHookPumpkin(entity, client)
{
	if (client > 0 && client <= MaxClients)
	{
		if (!IsFakeClient(client))
		{
			new rnd= GetRandomInt(0,100);

			if (rnd > 0 && rnd < 40)
			{
				if (IsValidEntity(entity))
				{
					new Float:vecExplosion[3];
					GetEntDataVector(entity, g_oEntityOrigin, vecExplosion);

					new Handle:shakedata = CreateDataPack();
					WritePackFloat(shakedata, vecExplosion[0]);
					WritePackFloat(shakedata, vecExplosion[1]);
					WritePackFloat(shakedata, vecExplosion[2]);

					CreateTimer(0.1, TinyShake, shakedata, TIMER_FLAG_NO_MAPCHANGE);

					// Create the Explosion
					new explosion = CreateEntityByName("env_explosion");
					if (explosion != -1 && IsValidEntity(explosion))
					{
						new String:originData[64];
						Format(originData, sizeof(originData), "%f %f %f", vecExplosion[0], vecExplosion[1], vecExplosion[2]);

						DispatchKeyValue(explosion,"Origin", originData);
						DispatchKeyValue(explosion,"iMagnitude", "100");
						DispatchSpawn(explosion);

						AcceptEntityInput(explosion, "Explode");
						AcceptEntityInput(explosion, "Kill");

						PositionParticle(vecExplosion, "explosion_huge_flames", 3.0);
					}

					PrintHelp(client, "*Trick or Treat Pumpkin - \x05 Kaboom!", 0);
				}
			}
			else if (rnd > 40 && rnd < 45)
			{
				CreateTimer(0.2, SpawnTNT, client, TIMER_FLAG_NO_MAPCHANGE);
				PrintHelp(client, "*Trick or Treat Pumpkin - \x05 TNT!", 0);
			}
			else if (rnd > 55 && rnd < 58)
			{
				CreateTimer(0.2, SpawnRadio, client, TIMER_FLAG_NO_MAPCHANGE);
				PrintHelp(client, "*Trick or Treat Pumpkin - \x05 Airstrike!", 0);
			}
			else if (rnd > 58 && rnd < 60)
			{
				CreateTimer(0.2, SpawnBoxNades, client, TIMER_FLAG_NO_MAPCHANGE);
				PrintHelp(client, "*Trick or Treat Pumpkin - \x05 Box o Nades!", 0);
			}
			else if (rnd > 60 && rnd < 70)
			{
				CreateTimer(0.2, SpawnHooch, client, TIMER_FLAG_NO_MAPCHANGE);
				PrintHelp(client, "*Trick or Treat Pumpkin - \x05 Hooch!", 0);
			}
			else if (rnd > 70 && rnd < 73)
			{
				CreateTimer(0.2, SpawnZombieBlood, client, TIMER_FLAG_NO_MAPCHANGE);
				PrintHelp(client, "*Trick or Treat Pumpkin - \x05 Zombie Blood!", 0);
			}
			else if (rnd > 73 && rnd < 87)
			{
				CreateTimer(0.2, SpawnHealthBox, client, TIMER_FLAG_NO_MAPCHANGE);
				PrintHelp(client, "*Trick or Treat Pumpkin - \x05 Health Box!", 0);
			}
			else if (rnd > 87 && rnd < 90)
			{
				CreateTimer(0.2, SpawnShield, client, TIMER_FLAG_NO_MAPCHANGE);
				PrintHelp(client, "*Trick or Treat Pumpkin - \x05 Shield!", 0);
			}
			else
			{
				CreateTimer(0.2, SpawnAmmoBox, client, TIMER_FLAG_NO_MAPCHANGE);
				PrintHelp(client, "*Trick or Treat Pumpkin - \x05 Ammo!", 0);
			}
		}

		DestroyEntity(entity);
	}
	return Plugin_Handled;
}

public Action:SpawnAdrenaline(Handle:timer, any:client)
{
	new Float: ClientOrigin[3];

	if (IsClientInGame(client))
	{
		GetClientAbsOrigin(client, ClientOrigin);

		if (IsAreaClear(ClientOrigin))
		{
			g_AdrenalineNumber++;

			new ent = CreateEntityByName("prop_physics_override");
			if (ent>0)
			{
				SetEntityModel(ent, "models/items/HealthKit.mdl");
				new String:adrenalinename[16];
				Format(adrenalinename, sizeof(adrenalinename), "Adrenaline%i", g_AdrenalineNumber);
				DispatchKeyValue(ent, "StartDisabled", "false");
				DispatchKeyValue(ent, "targetname", adrenalinename);
				SetEntityMoveType(ent, MOVETYPE_VPHYSICS);
				SetEntProp(ent, Prop_Send, "m_CollisionGroup", DROP_COLLISION);
				SetEntProp(ent, Prop_Send, "m_usSolidFlags", 152);
				SetEntProp(ent, Prop_Send, "m_nSolidType", DROP_SOLID);

				//SetEntityRenderFx(ent, RENDERFX_PULSE_FAST_WIDE);

				DispatchSpawn(ent);
				TeleportEntity(ent, ClientOrigin, NULL_VECTOR, NULL_VECTOR);

				SDKHook(ent, SDKHook_StartTouch, TouchHookAdrenaline);
				SDKHook(ent, SDKHook_Touch, TouchHookAdrenaline);
				SDKHook(ent, SDKHook_EndTouch, TouchHookAdrenaline);

				#if DEBUG
					LogToFileEx(g_szLogFileName,"[L4DOD] Created adrenaline drop:%i", ent);
				#endif

				new String:addoutput[64];
				Format(addoutput, sizeof(addoutput), "OnUser1 !self:kill::%f:1", 10.0);
				SetVariantString(addoutput);
				AcceptEntityInput(ent, "AddOutput");
				AcceptEntityInput(ent, "FireUser1");

				AttachParticle(ent, "fire_small_base", 10.0);
			}
		}
		else
		{
			new player = GetClosestClient(ClientOrigin, AXIS);

			if (player > 0)
				AddAdrenaline(player);
		}
	}

	return Plugin_Handled;
}

public Action:TouchHookAdrenaline(entity, client)
{
	if (client > 0 && client <= MaxClients)
	{
		if (GetClientTeam(client) == ALLIES && !g_hasAdrenaline[client])
		{
			AddAdrenaline(client);
			DestroyEntity(entity);
		}
	}
	return Plugin_Handled;
}

AddAdrenaline(client)
{
	if (GetClientTeam(client) == ALLIES && !g_hasAdrenaline[client])
	{
		EmitSoundToClient(client, "left4dod/hooch_drink.mp3");

		PrintHelp(client, "*You picked up \x04Adrenaline", 0);

		g_preHealth[client] = g_Health[client];
		new health = g_preHealth[client] + 200;
		SetHealth(client, health);

		if (g_Hints[client])
			PrintHelp(client, "*Your health and speed have been boosted for a little while", 0);

		new duration;
		if (g_bIsSupporter[client])
		{
			duration = 15;
		}
		else if (g_IsMember[client] > 0)
		{
			duration = 13;
		}
		else
		{
			duration = 8;
		}

		SetEntPropFloat(client, Prop_Send, "m_flProgressBarStartTime", GetGameTime());
		SetEntProp(client, Prop_Send, "m_iProgressBarDuration", duration);

		g_hasAdrenaline[client] = true;

		SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", HOOCH_SPEED);

		CreateTimer(float(duration), StopAdrenalineEffect, client, TIMER_FLAG_NO_MAPCHANGE);
	}
}

public Action:StopAdrenalineEffect(Handle:timer, any:client)
{
	if (IsClientInGame(client) && IsPlayerAlive(client) && g_hasAdrenaline[client])
	{
		g_hasAdrenaline[client] = false;

		g_Health[client] = g_preHealth[client];
		g_preHealth[client] = 0;
		SetHealth(client, g_Health[client]);

		SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 1.0);

		SetEntPropFloat(client, Prop_Send, "m_flProgressBarStartTime", GetGameTime());
		SetEntProp(client, Prop_Send, "m_iProgressBarDuration", 0);
	}

	return Plugin_Handled;
}

public Action:SpawnSprings(Handle:timer, any:client)
{
	new Float: ClientOrigin[3];

	if (IsClientInGame(client))
	{
		GetClientAbsOrigin(client, ClientOrigin);

		if (IsAreaClear(ClientOrigin))
		{
			g_SpringNumber++;

			new ent = CreateEntityByName("prop_physics_override");
			if (ent>0)
			{
				SetEntityModel(ent, "models/props_junk/glassjug01.mdl");
				new String:springname[16];
				Format(springname, sizeof(springname), "Springs%i", g_SpringNumber);
				DispatchKeyValue(ent, "StartDisabled", "false");
				DispatchKeyValue(ent, "targetname", springname);
				SetEntityMoveType(ent, MOVETYPE_VPHYSICS);
				SetEntProp(ent, Prop_Send, "m_CollisionGroup", DROP_COLLISION);
				SetEntProp(ent, Prop_Send, "m_usSolidFlags", DROP_SOLID_FLAGS);
				SetEntProp(ent, Prop_Send, "m_nSolidType", DROP_SOLID);

				//SetEntityRenderFx(ent, RENDERFX_PULSE_FAST_WIDE);
				SetEntityRenderColor(ent, 0, 0, 255, 255);

				DispatchSpawn(ent);
				TeleportEntity(ent, ClientOrigin, NULL_VECTOR, NULL_VECTOR);

				SDKHook(ent, SDKHook_StartTouch, TouchHookSprings);

				#if DEBUG
					LogToFileEx(g_szLogFileName,"[L4DOD] Created springs drop:%i", ent);
				#endif

				new String:addoutput[64];
				Format(addoutput, sizeof(addoutput), "OnUser1 !self:kill::%f:1", 10.0);
				SetVariantString(addoutput);
				AcceptEntityInput(ent, "AddOutput");
				AcceptEntityInput(ent, "FireUser1");

				AttachParticle(ent, "fire_small_base", 10.0);
			}
		}
		else
		{
			new player = GetClosestClient(ClientOrigin, 0);

			if (player > 0)
				AddSprings(player);
		}
	}

	return Plugin_Handled;
}

public Action:TouchHookSprings(entity, client)
{
	if (client > 0 && client <= MaxClients && !g_hasParachute[client])
	{
		AddSprings(client);

		DestroyEntity(entity);
	}
	return Plugin_Handled;
}

AddSprings(client)
{
	if (IsClientInGame(client) && IsPlayerAlive(client))
	{
		if (GetClientTeam(client) == ALLIES && !g_hasParachute[client])
		{
			g_hasParachute[client] = true;

			EmitSoundToClient(client, "weapons/c4_pickup.wav");

			PrintHelp(client, "*You picked up a \x04Parachute", 0);

			if (g_Hints[client])
			{
				PrintHelp(client, "\x05*You can use your parachute to advance into the action", 0);
			}

		}
	}
}

DestroyEntity(any:entity)
{
	if (!IsValidEntity(entity) || entity <= MaxClients)
		return;

	if (IsValidEntity(entity) && IsValidEdict(entity))
	{
		new String:classname[256];
		GetEdictClassname(entity, classname, sizeof(classname));
		if (StrEqual(classname, "prop_physics", false))
		{
			AcceptEntityInput(entity, "kill");
		}
	}

	return;
}

stock IsAreaClear(Float:pos[3])
{
	new Float: vecPlayer[3];
	for (new i=1; i<=MaxClients; i++)
	{
		if (!IsClientInGame(i))
			continue;

		if (IsFakeClient(i))
			continue;

		if (!IsPlayerAlive(i))
			continue;

		GetClientAbsOrigin(i, vecPlayer);
		if (GetVectorDistance(pos, vecPlayer) < DROP_RANGE)
		{
			return false;
		}
	}
	return true;
}
