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
// KABOOM ###########################################################

AirStrike(any:client)
{
	if (client > 0 && IsClientInGame(client) && IsPlayerAlive(client))
	{
		if (g_airstrike[client] && GetClientTeam(client) == ALLIES)
		{
			new Float:vAngles[3];
			new Float:vOrigin[3];
			new Float:pos[3];
			
			GetClientEyePosition(client,vOrigin);
			GetClientEyeAngles(client, vAngles);

			new Handle:trace = TR_TraceRayFilterEx(vOrigin, vAngles, MASK_SHOT, RayType_Infinite, TraceEntityFilterPlayer);

			if(TR_DidHit(trace))
			{
				TR_GetEndPosition(pos, trace);
				pos[2] += 10.0;
			}
			CloseHandle(trace);
			
			if (CheckLocationNearAxisSpawn(pos, 500.0))
			return;
			
			g_airstrike[client] = false;
			
			//FakeClientCommand(client, "say_team Airstrike incoming...take cover!");
			
			TE_SetupSparks(pos, NULL_VECTOR, 2, 1);
			TE_SendToAll(0.1);
			TE_SetupSparks(pos, NULL_VECTOR, 2, 2);
			TE_SendToAll(0.4);
			TE_SetupSparks(pos, NULL_VECTOR, 1, 1);
			TE_SendToAll(1.0);
			//stock TE_SetupGlowSprite(const Float:pos[3], Model, Float:Life, Float:Size, Brightness)
			TE_SetupGlowSprite(pos, BallSprite, 2.0, 2.0, 200);
			TE_SendToAll(1.2);
			TE_SetupGlowSprite(pos, BallSprite, 2.0, 1.5, 100);
			TE_SendToAll(3.2);
			TE_SetupGlowSprite(pos, BallSprite, 1.0, 1.0, 100);
			TE_SendToAll(5.2);
			TE_SetupGlowSprite(pos, BallSprite, 1.0, 1.0, 100);
			TE_SendToAll(6.2);
			
			EmitSoundToAll("left4dod/prop.mp3");
			
			CreateTimer(2.5, BigWhoosh, client, TIMER_FLAG_NO_MAPCHANGE);
			
			new Handle:shakedata = CreateDataPack();
			WritePackFloat(shakedata, pos[0]);
			WritePackFloat(shakedata, pos[1]);
			WritePackFloat(shakedata, pos[2]);
				
			CreateTimer(6.0, BigShake, shakedata, TIMER_FLAG_NO_MAPCHANGE);
			
			new strikenum = 3;
			if (g_bIsSupporter[client])
			{
				strikenum = 10;
			}
			else if (g_IsMember[client] == 1)
			{
				strikenum = 5;
			}
			else
			{
				strikenum = 3;
			}
			//Begin airstrikes
			for (new numAirstrikes = 1; numAirstrikes <= strikenum; numAirstrikes++)
			{
				new Float:randomtime = GetRandomFloat(0.2, 1.0);
				
				if (numAirstrikes == 1)
					randomtime = 6.0;
				else
					randomtime = (randomtime * numAirstrikes) + 6.0;
					
				new Handle:strikedata = CreateDataPack();
				WritePackCell(strikedata, client);
				WritePackFloat(strikedata, pos[0]);
				WritePackFloat(strikedata, pos[1]);
				WritePackFloat(strikedata, pos[2]);
				
				CreateTimer(randomtime, CreateStrike, strikedata, TIMER_FLAG_NO_MAPCHANGE);
			} 
		}
	}
}

public Action:BigWhoosh(Handle:timer, any:client)
{
	EmitSoundToAll("weapons/mortar.wav", _, _, _, _, 0.8);
	return Plugin_Handled;
}

public Action:BigShake(Handle:timer, Handle:shakedata)
{	
	new Float:location[3];
	ResetPack(shakedata);
	location[0] = ReadPackFloat(shakedata);
	location[1] = ReadPackFloat(shakedata);
	location[2] = ReadPackFloat(shakedata);
	CloseHandle(shakedata);
	
	new ent = CreateEntityByName("env_shake");

	DispatchKeyValueFloat(ent, "amplitude", 400.0);
	DispatchKeyValueFloat(ent, "radius", 2000.0);
	DispatchKeyValueFloat(ent, "duration", 5.0);
	DispatchKeyValueFloat(ent, "frequency", 100.0);
	DispatchKeyValue(ent,"SpawnFlags", "16");
	DispatchSpawn(ent);
	AcceptEntityInput(ent, "StartShake");
	TeleportEntity(ent, location, NULL_VECTOR, NULL_VECTOR);
	CreateTimer(6.0, DestroyShake, ent, TIMER_FLAG_NO_MAPCHANGE);
		
	return Plugin_Handled;
}

public Action:TinyShake(Handle:timer, Handle:shakedata)
{	
	new Float:location[3];
	ResetPack(shakedata);
	location[0] = ReadPackFloat(shakedata);
	location[1] = ReadPackFloat(shakedata);
	location[2] = ReadPackFloat(shakedata);
	CloseHandle(shakedata);
	
	new ent = CreateEntityByName("env_shake");

	DispatchKeyValueFloat(ent, "amplitude", 400.0);
	DispatchKeyValueFloat(ent, "radius", 2000.0);
	DispatchKeyValueFloat(ent, "duration", 0.5);
	DispatchKeyValueFloat(ent, "frequency", 100.0);
	DispatchKeyValue(ent,"SpawnFlags", "28");
	DispatchSpawn(ent);
	AcceptEntityInput(ent, "StartShake");
	TeleportEntity(ent, location, NULL_VECTOR, NULL_VECTOR);
	CreateTimer(6.0, DestroyShake, ent, TIMER_FLAG_NO_MAPCHANGE);
		
	return Plugin_Handled;
}

public Action:CreateStrike(Handle:timer, Handle:strikedata)
{
	new Float:location[3];
	
	ResetPack(strikedata);
	new client = ReadPackCell(strikedata);
	location[0] = ReadPackFloat(strikedata) + (GetRandomFloat(0.1, 0.8) * 200 * GetMathSign());
	location[1] = ReadPackFloat(strikedata) + (GetRandomFloat(0.1, 0.8) * 200 * GetMathSign());
	location[2] = ReadPackFloat(strikedata);
	CloseHandle(strikedata);
	
	if (IsClientInGame(client))
	{
		new String:originData[64];
		Format(originData, sizeof(originData), "%f %f %f", location[0], location[1], location[2]);
				
		// Create the Explosion
		new explosion = CreateEntityByName("env_explosion");
		if (explosion != -1)
		{
			DispatchKeyValue(explosion,"Origin", originData);
			DispatchKeyValue(explosion,"iMagnitude", "300");
			DispatchSpawn(explosion);
			SetEntPropEnt(explosion, Prop_Data, "m_hOwnerEntity", client);

			AcceptEntityInput(explosion, "Explode");
			AcceptEntityInput(explosion, "Kill");
			
			new push = CreateEntityByName("env_physexplosion");
			DispatchKeyValue(push, "Magnitude", "300");
			DispatchKeyValue(push, "Spawnflags", "27");
			DispatchKeyValue(push, "Origin", originData);
			DispatchSpawn(push);
			AcceptEntityInput(push, "Explode");
			AcceptEntityInput(push, "Kill");
			
			PositionParticle(location, "explosion_huge", 2.0);	

		}
	}
	return Plugin_Handled;
}

stock GetMathSign()
{
	new sign = 1;
	new randomnum = GetRandomInt(1,2);
	if (randomnum == 1)
		sign = 1;
	else
		sign = -1;
	return sign;
}