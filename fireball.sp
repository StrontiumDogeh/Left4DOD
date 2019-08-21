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

//############################ FIREBALLS ##########################################
public FireBalls(client)
{
	if (IsClientInGame(client) && IsPlayerAlive(client) && g_numFireball[client] > 0 && g_canFireball[client] && hFireballData[client] == INVALID_HANDLE)
	{
		g_canFireball[client] = false;
		
		g_numFireball[client]--;
		if (g_numFireball[client] <= 0)
			g_numFireball[client] = 0;
		
		if (!IsFakeClient(client))
			PrintHintText(client, "Fireballs left: %i", g_numFireball[client]);
		
		new Float:speed = 1200.0;
		
		new Float:ClientOrigin[3], Float:ClientAngle[3], Float:origin[3], Float:rotate[3], Float:AngleVector[3], Float:SpawnAt[3];
		GetClientEyePosition(client, ClientOrigin);
		GetClientEyeAngles(client, ClientAngle);
		
		GetAngleVectors(ClientAngle, AngleVector, NULL_VECTOR, NULL_VECTOR);
		NormalizeVector(AngleVector, AngleVector);
		ScaleVector(AngleVector, 60.0);
		AddVectors(ClientOrigin, AngleVector, SpawnAt);
		SpawnAt[2]+=10.0;

		GetAngleVectors(ClientAngle, origin, NULL_VECTOR, NULL_VECTOR);
		NormalizeVector(origin, origin);
		ScaleVector(origin, speed);
		GetVectorAngles(origin, rotate); 
		
		g_FireballNumber++;

		new ent = CreateEntityByName("prop_physics_override");
		
		if (IsValidEntity(ent))
		{
			SetEntityModel(ent, "models/gibs/hgibs.mdl");	
			new String:fireballname[16];
			Format(fireballname, sizeof(fireballname), "Fireball%i", g_FireballNumber);
			DispatchKeyValue(ent, "StartDisabled", "false");
			DispatchKeyValue(ent, "targetname", fireballname);
			DispatchSpawn(ent);
			SetEntityMoveType(ent, MOVETYPE_VPHYSICS);
			SetEntProp(ent, Prop_Send, "m_CollisionGroup", 11);
			SetEntProp(ent, Prop_Send, "m_usSolidFlags", 152);
			SetEntProp(ent, Prop_Send, "m_nSolidType", 6);
			SetEntPropVector(ent, Prop_Data, "m_vecAngVelocity", origin);
			
			#if DEBUG
				LogToFileEx(g_szLogFileName,"[L4DOD] Created Fireball:%i", ent);
			#endif
									
			TeleportEntity(ent, SpawnAt, rotate, origin);
			
			#if DEBUG
				LogToFileEx(g_szLogFileName,"[L4DOD] Launched Fireball:%i", ent);
			#endif
						
			SetEntPropEnt(ent, Prop_Data, "m_hOwnerEntity", client);
			SetEntPropEnt(ent, Prop_Data, "m_hLastAttacker", client);
			SetEntPropEnt(ent, Prop_Data, "m_hPhysicsAttacker", client);
			
			#if DEBUG
				LogToFileEx(g_szLogFileName,"[L4DOD] Changed Props:%i", ent);
			#endif
			
			AttachParticle(ent, "fire_medium_03", 8.0);
			
			#if DEBUG
				LogToFileEx(g_szLogFileName,"[L4DOD] Attached Particle to Fireball:%i", ent);
			#endif
			
			TE_SetupBeamFollow(ent, BeamSprite, 0, Float:4.0, Float:10.0, Float:10.0, 5, g_AxisColour);
			TE_SendToAll();
							
			new Handle:pack;
			hFireballData[client] = CreateDataTimer(2.0, CheckFireball, pack, TIMER_FLAG_NO_MAPCHANGE);
			WritePackCell(pack, client);
			WritePackCell(pack, ent);
		
			new String:addoutput[64];
			
			if (IsValidEntity(ent))
			{
				#if DEBUG
					LogToFileEx(g_szLogFileName,"[L4DOD] Removed Fireball:%i", ent);
				#endif
					
				Format(addoutput, sizeof(addoutput), "OnUser1 !self:kill::%f:1", 4.2);
				SetVariantString(addoutput);
				AcceptEntityInput(ent, "AddOutput");
				AcceptEntityInput(ent, "FireUser1");
			}
									
			EmitSoundToAll("left4dod/fireball.mp3", client);
					
			if (IsFakeClient(client))
			{
				CreateTimer(10.1, ReFireball, client, TIMER_FLAG_NO_MAPCHANGE);
			}
			else
			{
				SetEntPropFloat(client, Prop_Send, "m_flProgressBarStartTime", GetGameTime());
				SetEntProp(client, Prop_Send, "m_iProgressBarDuration", 5);	
				EmitSoundToClient(client, "buttons/blip1.wav");
				
				CreateTimer(10.1, ReFireball, client, TIMER_FLAG_NO_MAPCHANGE);
			}
		}
	}
}

public Action:CheckFireball(Handle:timer, Handle:datapack)
{
	ResetPack(datapack);
	new client = ReadPackCell(datapack);
	new ent = ReadPackCell(datapack);

	hFireballData[client] = INVALID_HANDLE;
	
	if (IsValidEntity(ent))
	{
		new Float:FireballLoc[3];
		GetEntDataVector(ent, g_oEntityOrigin, FireballLoc);	

		#if DEBUG
			LogToFileEx(g_szLogFileName,"[L4DOD] Broke Fireball:%i", ent);
		#endif
					
		new String:addoutput[64];
		Format(addoutput, sizeof(addoutput), "OnUser2 !self:break::%f:1", 0.1);
		SetVariantString(addoutput);
		AcceptEntityInput(ent, "AddOutput");
		AcceptEntityInput(ent, "FireUser2");
		
		if (CheckLocationNearAlliedSpawn(FireballLoc, 200.0))
			return Plugin_Handled;
			
		new Handle:pack;				
		hFireTimer[client]  = CreateDataTimer(0.5, CheckFire, pack, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
		CreateTimer(8.0, KillFireTimer, client, TIMER_FLAG_NO_MAPCHANGE);
		WritePackCell(pack, client);
		WritePackFloat(pack, FireballLoc[0]);
		WritePackFloat(pack, FireballLoc[1]);
		WritePackFloat(pack, FireballLoc[2]);
		
		PositionParticle(FireballLoc, "fire_large_01", 8.0);
		// Create the smoke
		new String:gas_name[128];
		
		Format(gas_name, sizeof(gas_name), "Smoke%i", client);
		new gascloud = CreateEntityByName("env_smokestack");
		DispatchKeyValue(gascloud,"targetname", gas_name);
		DispatchKeyValue(gascloud,"BaseSpread", "300");
		DispatchKeyValue(gascloud,"SpreadSpeed", "10");
		DispatchKeyValue(gascloud,"Speed", "80");
		DispatchKeyValue(gascloud,"StartSize", "200");
		DispatchKeyValue(gascloud,"EndSize", "2");
		DispatchKeyValue(gascloud,"Rate", "15");
		DispatchKeyValue(gascloud,"JetLength", "400");
		DispatchKeyValue(gascloud,"Twist", "4");
		DispatchKeyValue(gascloud,"RenderColor", "45 45 45");
		DispatchKeyValue(gascloud,"RenderAmt", "150");
		DispatchKeyValue(gascloud,"SmokeMaterial", "particle/particle_smokegrenade1.vmt");
		DispatchSpawn(gascloud);
		TeleportEntity(gascloud, FireballLoc, NULL_VECTOR, NULL_VECTOR);
		AcceptEntityInput(gascloud, "TurnOn");
		
		Format(addoutput, sizeof(addoutput), "OnUser1 !self:TurnOff::%f:1", 6.0);
		SetVariantString(addoutput);
		AcceptEntityInput(gascloud, "AddOutput");
		AcceptEntityInput(gascloud, "FireUser1");
		
		Format(addoutput, sizeof(addoutput), "OnUser2 !self:kill::%f:1", 9.0);
		SetVariantString(addoutput);
		AcceptEntityInput(gascloud, "AddOutput");
		AcceptEntityInput(gascloud, "FireUser2");
		
		new shake = CreateEntityByName("env_shake");
		DispatchKeyValueFloat(shake, "amplitude", 300.0);
		DispatchKeyValueFloat(shake, "radius", 200.0);
		DispatchKeyValueFloat(shake, "duration", 0.5);
		DispatchKeyValueFloat(shake, "frequency", 80.0);
		DispatchKeyValue(shake,"SpawnFlags", "1");
		DispatchSpawn(shake);
		AcceptEntityInput(shake, "StartShake");
		TeleportEntity(shake, FireballLoc, NULL_VECTOR, NULL_VECTOR);
		CreateTimer(1.1, DestroyShake, shake, TIMER_FLAG_NO_MAPCHANGE);
		
	}
	return Plugin_Handled;
}


public Action:ReFireball(Handle:timer, any:client)
{
	g_canFireball[client] = true;
	
	if (IsClientInGame(client) && !IsFakeClient(client) && IsPlayerAlive(client))
	{
		SetEntPropFloat(client, Prop_Send, "m_flProgressBarStartTime", GetGameTime());
		SetEntProp(client, Prop_Send, "m_iProgressBarDuration", 0);	
		EmitSoundToClient(client, "buttons/blip1.wav");
	}
	return Plugin_Handled;
}