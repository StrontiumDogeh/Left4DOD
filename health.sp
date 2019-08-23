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
 
 public Action:RestoreHealth(Handle:timer, any:client)
{
	//Set Health to current health level
	if (IsClientInGame(client) && IsPlayerAlive(client))
	{
		SetEntProp(client, Prop_Data, "m_takedamage", 2, 1); 
		
		if (!IsFakeClient(client))
			PrintHelp(client, "*Spawn protection DISABLED", 1);
	}
		
	return Plugin_Handled;
}

public Action:RestoreHealthFromZombieBlood(Handle:timer, any:client)
{
	if (IsClientInGame(client) && IsPlayerAlive(client))
	{
		SetEntProp(client, Prop_Data, "m_takedamage", 2, 1); 
	}
		
	return Plugin_Handled;
}

Suck(client, target, dmg)
{
	if (IsClientInGame(client) && IsPlayerAlive(client) && g_canSuck[client])
	{
		g_canSuck[client] = false;
		
		if (dmg <= 2)
			dmg = 2;
							
		CreateTimer(0.3, AllowMoreSucking, client, TIMER_FLAG_NO_MAPCHANGE);
		
		SetEntProp(target, Prop_Data, "m_takedamage", 2, 1); 
						
		new Handle:pack;			
		CreateDataTimer(0.1, DealDamage, pack, TIMER_FLAG_NO_MAPCHANGE);
		WritePackCell(pack, target);
		WritePackCell(pack, client);
		WritePackCell(pack, dmg);
		WritePackCell(pack, DMG_ACID);
		WritePackString(pack, "weapon_suck");
	}
}

Heal(client, target, heal)
{
	if (IsClientInGame(client) && IsPlayerAlive(client) && g_canSuck[client])
	{
		g_canSuck[client] = false;
							
		CreateTimer(0.2, AllowMoreSucking, client, TIMER_FLAG_NO_MAPCHANGE);
		
		if (g_Health[target] < g_HealthMax[target])
		{
			g_Health[target] += heal;
			SetHealth(target, g_Health[target]);
		}
	}
}

public Action:AllowMoreSucking(Handle:timer, any:client)
{
	g_canSuck[client] = true;
		
	return Plugin_Continue;
}

