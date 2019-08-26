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

public PlayerSayEvent(Handle:event, const String:name[], bool:dontBroadcast)
{
	new String:text[200];
	GetEventString(event, "text", text, 200);
	new client = GetClientOfUserId(GetEventInt(event, "userid"));

	if (StrEqual(text, "!ip") || StrEqual(text, "ip") || StrContains(text, "ip") != -1)
	{
		new String:port[8], String:ip[32];
		GetConVarString(FindConVar("hostport"), port, sizeof(port));
		GetConVarString(FindConVar("ip"), ip, sizeof(ip));

		PrintToChatAll("IP: %s:%s", ip, port);
	}

	if (StrEqual(text, "!motd") || StrEqual(text, "motd"))
	{
		if (client > 0)
			ShowMOTDPanel(client, "MOTD", "https://www.theville.org/game/left4dod.html", MOTDPANEL_TYPE_URL );
	}

	if (StrContains(text, "error", false) != -1)
	{
		if (client > 0)
			ShowMOTDPanel(client, "FAQ", "http://left4dod.boff.ca/index.html#error", MOTDPANEL_TYPE_URL );
	}
}
