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
public GasBomb(client)
{
	if (IsClientInGame(client) && IsPlayerAlive(client) && g_iNumGasBombs[client] > 0)
	{
		g_bCanGasBomb[client] = false;
		g_bGasBombExploded[client] = false;
				
		g_iNumGasBombs[client]--;
		if (g_iNumGasBombs[client] <= 0)
			g_iNumGasBombs[client] = 0;
		
		if (!IsFakeClient(client))
			PrintHintText(client, "Gas Bombs left: %i", g_iNumGasBombs[client]);
		
		new Float:speed = 1500.0;
		
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
		
		g_iGasBombNumber++;

		new ent = CreateEntityByName("prop_physics_override");
		
		if (IsValidEntity(ent))
		{
			g_iGasBombEntity[client] = ent;
			
			SetEntityModel(ent, "models/shells/shell_large.mdl");	
			new String:iGasBombNumber[16];
			Format(iGasBombNumber, sizeof(iGasBombNumber), "Shell%i", g_iGasBombNumber);
			DispatchKeyValue(ent, "StartDisabled", "false");
			DispatchKeyValue(ent, "targetname", iGasBombNumber);
			SetEntProp(ent, Prop_Data, "m_takedamage", 2);
			
			DispatchSpawn(ent);
			SetEntityMoveType(ent, MOVETYPE_VPHYSICS);
			SetEntProp(ent, Prop_Send, "m_CollisionGroup", 1);
			SetEntProp(ent, Prop_Send, "m_nSolidType", 6);
			SetEntPropVector(ent, Prop_Data, "m_vecAngVelocity", origin);
						
			CreateTimer(0.1, CheckImpact, client, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
			
			#if DEBUG
				LogToFileEx(g_szLogFileName,"[L4DOD] Created Gas Bomb:%i", ent);
			#endif
			
			AttachParticle(ent, "fire_jet_01_flame", 10.0);
						
			TeleportEntity(ent, SpawnAt, rotate, origin);
			
			TE_SetupBeamFollow(ent, BeamSprite, 0, Float:4.0, Float:10.0, Float:10.0, 5, g_AxisColour);
			TE_SendToAll();
			
			
			SetEntPropEnt(ent, Prop_Data, "m_hOwnerEntity", client);
			SetEntPropEnt(ent, Prop_Data, "m_hLastAttacker", client);
			SetEntPropEnt(ent, Prop_Data, "m_hPhysicsAttacker", client);
								
			new String:addoutput[64];
			
			if (IsValidEntity(ent))
			{
				#if DEBUG
					LogToFileEx(g_szLogFileName,"[L4DOD] Removed Gas Bomb:%i", ent);
				#endif
				
				Format(addoutput, sizeof(addoutput), "OnUser1 !self:kill::%f:1", 4.2);
				SetVariantString(addoutput);
				AcceptEntityInput(ent, "AddOutput");
				AcceptEntityInput(ent, "FireUser1");
			}
									
			EmitSoundToAll("left4dod/fireball.mp3", client);
					
			if (IsFakeClient(client))
				CreateTimer(4.1, ReGas, client, TIMER_FLAG_NO_MAPCHANGE);
			else
			{
				CreateTimer(4.1, ReGas, client, TIMER_FLAG_NO_MAPCHANGE);
				SetEntPropFloat(client, Prop_Send, "m_flProgressBarStartTime", GetGameTime());
				SetEntProp(client, Prop_Send, "m_iProgressBarDuration", 4);
			}

		}
	}
}

public Action:CheckImpact(Handle:timer, any:client)
{
	if ((!IsValidEntity(g_iGasBombEntity[client]) && g_iGasBombEntity[client] > 0) || g_bGasBombExploded[client])
	{
		g_iGasBombEntity[client] = 0;
		return Plugin_Stop;
	}
			
	new Float:vLoc[3], Float:fDistance;
	GetEntDataVector(g_iGasBombEntity[client], g_oEntityOrigin, vLoc);
	
	// Find decelaration
	fDistance = GetVectorDistance(vLoc, g_vecLastGasBombLoc[client]);
	
	// Impact
	if (fDistance < 100.0)
	{		
		decl String:addoutput[64];
		Format(addoutput, sizeof(addoutput), "OnUser1 !self:break::%f:1", 0.1);
		SetVariantString(addoutput);
		AcceptEntityInput(g_iGasBombEntity[client], "AddOutput");
		AcceptEntityInput(g_iGasBombEntity[client], "FireUser1");
					
		// Create the Gas Cloud
		new String:gas_name[128];
		Format(gas_name, sizeof(gas_name), "Gas%i", client);
		new gascloud = CreateEntityByName("env_smokestack");
		DispatchKeyValue(gascloud,"targetname", gas_name);
		DispatchKeyValue(gascloud,"BaseSpread", "100");
		DispatchKeyValue(gascloud,"SpreadSpeed", "5");
		DispatchKeyValue(gascloud,"Speed", "5");
		DispatchKeyValue(gascloud,"StartSize", "70");
		DispatchKeyValue(gascloud,"EndSize", "2");
		DispatchKeyValue(gascloud,"Rate", "30");
		DispatchKeyValue(gascloud,"JetLength", "20");
		DispatchKeyValue(gascloud,"Twist", "4");
		DispatchKeyValue(gascloud,"RenderColor", "255 51 51");
		DispatchKeyValue(gascloud,"RenderAmt", "255");
		DispatchKeyValue(gascloud,"SmokeMaterial", "particle/particle_smokegrenade1.vmt");
		DispatchSpawn(gascloud);
		TeleportEntity(gascloud, vLoc, NULL_VECTOR, NULL_VECTOR);
		AcceptEntityInput(gascloud, "TurnOn");
		
		EmitSoundToAll("left4dod/gasbomb.wav", gascloud);
		
		g_bGasBombExploded[client] = true;
					
		Format(addoutput, sizeof(addoutput), "OnUser1 !self:TurnOff::%f:1", 1.0);
		SetVariantString(addoutput);
		AcceptEntityInput(gascloud, "AddOutput");
		AcceptEntityInput(gascloud, "FireUser1");
		
		Format(addoutput, sizeof(addoutput), "OnUser2 !self:kill::%f:1", 6.0);
		SetVariantString(addoutput);
		AcceptEntityInput(gascloud, "AddOutput");
		AcceptEntityInput(gascloud, "FireUser2");
		
		for (new i=1; i <= MaxClients; i++)
		{
			if (!IsClientInGame(i))
				continue;
			
			//if (bot == i)
			//	continue;
				
			if (GetClientTeam(i) == AXIS)
				continue;
				
			if (IsClientObserver(i))
				continue;	
				
			if (!IsPlayerAlive(i))
				continue;	
				
			if (g_isIgnored[i])
				continue;
				
			if (g_hasAntiGas[i])
				continue;
				
			else
			{
				new Float:PlayerVector[3];
				GetClientAbsOrigin(i, PlayerVector);
				new Float:dist = GetVectorDistance(vLoc, PlayerVector);
					
				if ( dist < 220)
				{	
					//Damage between 12 and 100 depending on how close
					new Float:dmg = ((250.0 - dist) / 200.0) * GASBOMB;
					
					if (dmg <= 12.0)
						dmg = 12.0;
					
					PrintToChat(client, "Dmg to %N: %i", i, RoundToCeil(dmg));
						
					new Handle:pack;			
					CreateDataTimer(0.3, DealDamage, pack, TIMER_FLAG_NO_MAPCHANGE);
					WritePackCell(pack, i);
					WritePackCell(pack, client);
					WritePackCell(pack, RoundToCeil(dmg));
					WritePackCell(pack, DMG_ACID);
					WritePackString(pack, "weapon_gasbomb");
					
					g_isInfected[i] = true;
					SetEntityModel(i, "models/player/german_traitor.mdl");
					
					if (g_Hints[i])
							PrintHelp(i, "*You have been {green}infected{yellow} - you will slowly {green}lose health {yellow}until you get a {fullred}Health Pack or Zombie Blood", 0);
				}
			}
		}
	}
	
	g_vecLastGasBombLoc[client][0] = vLoc[0];
	g_vecLastGasBombLoc[client][1] = vLoc[1];
	g_vecLastGasBombLoc[client][2] = vLoc[2];
	
	return Plugin_Handled;
}

public Action:ReGas(Handle:timer, any:client)
{
	g_bCanGasBomb[client] = true;
	g_bGasBombExploded[client] = false;
	
	if (IsClientInGame(client) && !IsFakeClient(client) && IsPlayerAlive(client))
	{
		SetEntPropFloat(client, Prop_Send, "m_flProgressBarStartTime", GetGameTime());
		SetEntProp(client, Prop_Send, "m_iProgressBarDuration", 0);	
		EmitSoundToClient(client, "buttons/blip1.wav");
	}
	return Plugin_Handled;
}

public Smoke(client)
{
	if (IsClientInGame(client) && IsPlayerAlive(client) && g_canSmoke[client])
	{
		g_canSmoke[client] = false;
		
		AddParticle(client, "smoke_burning_engine_01", 6.0, 10.0);
		AddParticle(client, "smokegrenade", 8.0, 10.0);
		
		CreateTimer(15.0, Resmoke, client, TIMER_FLAG_NO_MAPCHANGE);
		SetEntPropFloat(client, Prop_Send, "m_flProgressBarStartTime", GetGameTime());
		SetEntProp(client, Prop_Send, "m_iProgressBarDuration", 15);
	}
	return;
}

public Action:Resmoke(Handle:timer, any:client)
{
	g_canSmoke[client] = true;
	
	if (IsClientInGame(client) && !IsFakeClient(client) && IsPlayerAlive(client))
	{
		SetEntPropFloat(client, Prop_Send, "m_flProgressBarStartTime", GetGameTime());
		SetEntProp(client, Prop_Send, "m_iProgressBarDuration", 0);	
		EmitSoundToClient(client, "buttons/blip1.wav");
	}
	return Plugin_Handled;
}