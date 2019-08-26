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


CreateSprite(any:client)
{
	if (IsClientInGame(client) && IsPlayerAlive(client) && GetClientTeam(client) == AXIS && g_ZombieType[client] == INFECTEDONE )
	{
		if (g_SpriteEntity[client] != -1)
			RemoveSprite(client);

		new Float:ClientOrigin[3];
		new String:tName[32],String:cName[32];
		GetClientAbsOrigin(client, ClientOrigin);
		ClientOrigin[2] += 84;

		new somerandom = GetRandomInt(0,7);

		g_SpriteEntity[client] = CreateEntityByName("env_sprite");
		SetEntityModel(g_SpriteEntity[client], g_AlliedSprites[somerandom]);

		Format(cName, sizeof(cName), "icon%i", client);
		Format(tName, sizeof(tName), "player%i", client);
		DispatchKeyValue(client, "targetname", tName);

		DispatchKeyValue(g_SpriteEntity[client], "RenderMode", "5");
		DispatchKeyValue(g_SpriteEntity[client], "RenderFX", "0");
		DispatchKeyValue(g_SpriteEntity[client], "Framerate", "10.0");
		DispatchKeyValue(g_SpriteEntity[client], "targetname", cName);
		DispatchSpawn(g_SpriteEntity[client]);
		SetEntityRenderMode(g_SpriteEntity[client], RENDER_TRANSCOLOR);
		TeleportEntity(g_SpriteEntity[client], ClientOrigin, NULL_VECTOR, NULL_VECTOR);

		SetVariantString(tName);
		AcceptEntityInput(g_SpriteEntity[client], "SetParent", g_SpriteEntity[client], g_SpriteEntity[client], 0);
		ActivateEntity(g_SpriteEntity[client]);
		AcceptEntityInput(g_SpriteEntity[client], "ShowSprite");

		SDKHook(g_SpriteEntity[client], SDKHook_SetTransmit, SpriteControl);
	}
}

RemoveSprite(any:client)
{
	if (g_SpriteEntity[client] > 0 && IsValidEntity(g_SpriteEntity[client]))
	{
		new String:classname[256];
		GetEdictClassname(g_SpriteEntity[client], classname, sizeof(classname));
		if (StrEqual(classname, "env_sprite", false))
		{
			AcceptEntityInput(g_SpriteEntity[client], "Kill");
		}
	}

	g_SpriteEntity[client] = -1;
}

public Action:SpriteControl(entity, client)
{
	//If on Axis or Spectator, hide
	if (GetClientTeam(client) == AXIS || IsFakeClient(client) || IsClientObserver(client) || GetClientTeam(client) == 0)
	{
		return Plugin_Handled;
	}
	else if (GetClientTeam(client) == ALLIES)
	{
		new owner = 0;
		//If client is in Limbo or is invisible, hide
		for (new i=1; i<=MaxClients; i++)
		{
			if (g_SpriteEntity[i] == entity)
			{
				owner = i;
			}
		}
		if (owner > 0 && g_Invisible[owner])
		{
			return Plugin_Handled;
		}
	}

	return Plugin_Continue;

}
