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

//############################ SKULLS ##########################################
public FireSkulls(client)
{
	if (IsClientInGame(client) && IsPlayerAlive(client) && g_numSkull[client] > 0 && g_canSkull[client] && hSkullData[client] == INVALID_HANDLE)
	{
		g_canSkull[client] = false;
		
		g_numSkull[client]--;
		if (g_numSkull[client] <= 0)
			g_numSkull[client] = 0;
		
		if (!IsFakeClient(client))
			PrintHintText(client, "Skulls left: %i", g_numSkull[client]);
		
		new Float:speed = 1400.0;
		
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
		
		g_SkullNumber++;

		new ent = CreateEntityByName("prop_physics_override");
		
		if (IsValidEntity(ent))
		{
			SetEntityModel(ent, "models/gibs/hgibs.mdl");	
			new String:skullname[16];
			Format(skullname, sizeof(skullname), "Skull%i", g_SkullNumber);
			DispatchKeyValue(ent, "StartDisabled", "false");
			DispatchKeyValue(ent, "targetname", skullname);
			DispatchKeyValue(ent, "ExplodeRadius", "250");
			DispatchKeyValue(ent, "ExplodeDamage", "250");
			DispatchSpawn(ent);
			SetEntityMoveType(ent, MOVETYPE_VPHYSICS);
			SetEntProp(ent, Prop_Send, "m_CollisionGroup", 11);
			SetEntProp(ent, Prop_Send, "m_usSolidFlags", 152);
			SetEntProp(ent, Prop_Send, "m_nSolidType", 6);
			SetEntPropVector(ent, Prop_Data, "m_vecAngVelocity", origin);
			
			#if DEBUG
				LogToFileEx(g_szLogFileName,"[L4DOD] Created Skull:%i", ent);
			#endif
									
			TeleportEntity(ent, SpawnAt, rotate, origin);
			
			#if DEBUG
				LogToFileEx(g_szLogFileName,"[L4DOD] Launched Skull:%i", ent);
			#endif
						
			SetEntPropEnt(ent, Prop_Data, "m_hOwnerEntity", client);
			SetEntPropEnt(ent, Prop_Data, "m_hLastAttacker", client);
			SetEntPropEnt(ent, Prop_Data, "m_hPhysicsAttacker", client);
			//DispatchKeyValue(ent, "classname", "weapon_skull");
			
			#if DEBUG
				LogToFileEx(g_szLogFileName,"[L4DOD] Changed Props:%i", ent);
			#endif
			
			AttachParticle(ent, "fire_medium_03", 8.0);
			
			#if DEBUG
				LogToFileEx(g_szLogFileName,"[L4DOD] Attached Particle to Skull:%i", ent);
			#endif
			
			TE_SetupBeamFollow(ent, BeamSprite, 0, Float:4.0, Float:10.0, Float:10.0, 5, g_AxisColour);
			TE_SendToAll();
							
			new Handle:pack;
			hSkullData[client] = CreateDataTimer(2.0, CheckSkull, pack, TIMER_FLAG_NO_MAPCHANGE);
			WritePackCell(pack, client);
			WritePackCell(pack, ent);
		
			new String:addoutput[64];
			
			if (IsValidEntity(ent))
			{
				#if DEBUG
					LogToFileEx(g_szLogFileName,"[L4DOD] Removed Skull:%i", ent);
				#endif
					
				Format(addoutput, sizeof(addoutput), "OnUser1 !self:kill::%f:1", 4.2);
				SetVariantString(addoutput);
				AcceptEntityInput(ent, "AddOutput");
				AcceptEntityInput(ent, "FireUser1");
			}
									
			EmitSoundToAll("left4dod/fireball.mp3", client);
					
			if (IsFakeClient(client))
			{
				CreateTimer(4.1, ReSkull, client, TIMER_FLAG_NO_MAPCHANGE);
			}
			else
			{
				SetEntPropFloat(client, Prop_Send, "m_flProgressBarStartTime", GetGameTime());
				SetEntProp(client, Prop_Send, "m_iProgressBarDuration", 5);	
				EmitSoundToClient(client, "buttons/blip1.wav");
				
				CreateTimer(5.1, ReSkull, client, TIMER_FLAG_NO_MAPCHANGE);
			}
		}
	}
}

public Action:CheckSkull(Handle:timer, Handle:datapack)
{
	ResetPack(datapack);
	new client = ReadPackCell(datapack);
	new ent = ReadPackCell(datapack);

	hSkullData[client] = INVALID_HANDLE;
	
	if (IsValidEntity(ent))
	{
		new Float:SkullLoc[3];
		GetEntDataVector(ent, g_oEntityOrigin, SkullLoc);	

		#if DEBUG
			LogToFileEx(g_szLogFileName,"[L4DOD] Broke Skull:%i", ent);
		#endif
					
		new String:addoutput[64];
		Format(addoutput, sizeof(addoutput), "OnUser2 !self:break::%f:1", 0.1);
		SetVariantString(addoutput);
		AcceptEntityInput(ent, "AddOutput");
		AcceptEntityInput(ent, "FireUser2");
		
		new shake = CreateEntityByName("env_shake");
		DispatchKeyValueFloat(shake, "amplitude", 300.0);
		DispatchKeyValueFloat(shake, "radius", 200.0);
		DispatchKeyValueFloat(shake, "duration", 1.0);
		DispatchKeyValueFloat(shake, "frequency", 100.0);
		DispatchKeyValue(shake,"SpawnFlags", "1");
		DispatchSpawn(shake);
		AcceptEntityInput(shake, "StartShake");
		TeleportEntity(shake, SkullLoc, NULL_VECTOR, NULL_VECTOR);
		CreateTimer(1.1, DestroyShake, shake, TIMER_FLAG_NO_MAPCHANGE);
	}
	return Plugin_Handled;
}


public Action:ReSkull(Handle:timer, any:client)
{
	g_canSkull[client] = true;
	
	if (IsClientInGame(client) && !IsFakeClient(client) && IsPlayerAlive(client))
	{
		SetEntPropFloat(client, Prop_Send, "m_flProgressBarStartTime", GetGameTime());
		SetEntProp(client, Prop_Send, "m_iProgressBarDuration", 0);	
		EmitSoundToClient(client, "buttons/blip1.wav");
	}
	return Plugin_Handled;
}