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
 //g_iMines -> Number of planted mines
 //g_numMines - > total number of Mines 
 //g_iDroppedMine -> entities of mines 

//############################ SKULLS ##########################################

DetonateMines(client)
{
	
	for (new i = 1; i <= MINES; i++)
	{
		if (g_iDroppedMine[client][i] > 0)
			ExplodeMine(g_iDroppedMine[client][i], client);
			
		g_iDroppedMine[client][i] = 0;
	}
}


RemoveMines(client)
{
	for (new i = 1; i <= MINES; i++)
	{
		if (g_iDroppedMine[client][i] > 0)
		{
			if (IsValidEntity(g_iDroppedMine[client][i]))
			{
				AttachParticle(g_iDroppedMine[client][i], "fire_small_base", 1.0);
				AcceptEntityInput(g_iDroppedMine[client][i], "Kill");
			}
		}
			
		g_iDroppedMine[client][i] = 0;
	}
}

ExplodeMine(ent, owner)
{
	if (IsValidEntity(ent) && IsValidEdict(ent))
	{		
		new String:classname[256];
		GetEdictClassname(ent, classname, sizeof(classname));
		if (StrEqual(classname, "prop_physics", false))
		{
			new Float:vecExplosion[3];
			GetEntDataVector(ent, g_oEntityOrigin, vecExplosion);
			
			SetEntPropEnt(ent, Prop_Data, "m_hOwnerEntity", owner);
			
			new String:addoutput[64];
			Format(addoutput, sizeof(addoutput), "OnUser2 !self:break::%f:1", 0.1);
			SetVariantString(addoutput);
			AcceptEntityInput(ent, "AddOutput");
			AcceptEntityInput(ent, "FireUser2");
			
			Format(addoutput, sizeof(addoutput), "OnUser1 !self:kill::%f:1", 1.0);
			SetVariantString(addoutput);
			AcceptEntityInput(ent, "AddOutput");
			AcceptEntityInput(ent, "FireUser1");
			
			new shake = CreateEntityByName("env_shake");
			DispatchKeyValueFloat(shake, "amplitude", 300.0);
			DispatchKeyValueFloat(shake, "radius", 200.0);
			DispatchKeyValueFloat(shake, "duration", 1.0);
			DispatchKeyValueFloat(shake, "frequency", 100.0);
			DispatchKeyValue(shake,"SpawnFlags", "1");
			DispatchSpawn(shake);
			AcceptEntityInput(shake, "StartShake");
			TeleportEntity(shake, vecExplosion, NULL_VECTOR, NULL_VECTOR);
			CreateTimer(1.1, DestroyShake, shake, TIMER_FLAG_NO_MAPCHANGE);
				
			PositionParticle(vecExplosion, "explosion_huge_c", 2.0);	
		}
	}
}

public Action:ReplaceNade(Handle:timer, Handle:pack)
{
	new Float:vLoc[3];
	
	ResetPack(pack);
	new client = ReadPackCell(pack);
	new nade = ReadPackCell(pack);
		
	if (IsValidEntity(nade) && IsValidEdict(nade) && nade > MaxClients)
	{		
		GetEntDataVector(nade, g_oEntityOrigin, vLoc);
			
		new String:classname[256];
		GetEdictClassname(nade, classname, sizeof(classname));
		if (StrEqual(classname, "grenade_frag_ger", false))
		{
			AcceptEntityInput(nade, "kill");
		}
		
		new ent = CreateEntityByName("prop_physics_override");
		
		if (IsValidEntity(ent))
		{
			//look for a free mine slot
			new freemine = 0;
			for (new i = 1; i <= MINES; i++)
			{
				if (g_iDroppedMine[client][i] == 0)
				{
					freemine = i;
					break;
				}
			}
			
			//if all mine slots used, detonate the lot and start again
			if (freemine == 0)
			{
				DetonateMines(client);
				freemine = 1;
			}
			
			g_iDroppedMine[client][freemine] = ent;
			
			SetEntityModel(ent, "models/weapons/w_bugbait.mdl");	
			new String:minename[16];
			Format(minename, sizeof(minename), "Mine%i", g_MineNumber);
			DispatchKeyValue(ent, "StartDisabled", "false");
			DispatchKeyValue(ent, "targetname", minename);
			DispatchKeyValue(ent, "ExplodeRadius", "350");
			DispatchKeyValue(ent, "ExplodeDamage", "500");
			DispatchSpawn(ent);
			SetEntityMoveType(ent, MOVETYPE_VPHYSICS);
			SetEntProp(ent, Prop_Send, "m_CollisionGroup", 5);
			SetEntProp(ent, Prop_Send, "m_usSolidFlags", 24);
			SetEntProp(ent, Prop_Send, "m_nSolidType", 6);
			SetEntPropEnt(ent, Prop_Data, "m_hOwnerEntity", client);
			SetEntPropEnt(ent, Prop_Data, "m_hLastAttacker", client);
			SetEntPropEnt(ent, Prop_Data, "m_hPhysicsAttacker", client);
			
			#if DEBUG
				LogToFileEx(g_szLogFileName,"[L4DOD] Created Mine:%i", ent);
			#endif
									
			TeleportEntity(ent, vLoc, NULL_VECTOR, NULL_VECTOR);
			SetEntityMoveType(ent, MOVETYPE_NONE);
			SDKHook(ent, SDKHook_OnTakeDamage, MineHit);
			
			AttachParticle(ent, "fire_small_base", 10.0);
		}
	}
}

public Action:HookGrenadeThink(ent)
{	
	new Float:vLoc[3], Float:fDistance;
	GetEntDataVector(ent, g_oEntityOrigin, vLoc);
	
	g_iMineData[ent]++;
	
	// Find decelaration
	fDistance = GetVectorLength(vLoc);
	new Float:fSpeed = g_fLastMineLength[ent] - fDistance;
	
	// Impact
	if (g_iMineData[ent] > 5)
	{
		if (fSpeed > -1.0 && fSpeed < 1.0)
		{
			SetEntityMoveType(ent, MOVETYPE_NONE);
			ChangeEdictState(ent, 0);
			
			SDKUnhook(ent, SDKHook_VPhysicsUpdate, HookGrenadeThink);
		}
	}
	
	g_fLastMineLength[ent] = fDistance;
	return Plugin_Handled;
}

public Action:MineHit(entity, &attacker, &inflictor, &Float:fDamage, &damagetype, &weapon, Float:damageForce[3], Float:damagePosition[3])
{	
	SetEntityMoveType(entity, MOVETYPE_VPHYSICS );
}
