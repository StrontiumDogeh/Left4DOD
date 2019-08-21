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
 
 
// ON SCREEN DISPLAY ####################################################################
/// MMX's amazing routine to escape characters to print LF etc
stock Unescape(String:buffer[])
{
	new inPos = 0,
	outPos    = 0,
	count     = 0,
	bufferlen = strlen(buffer);
	
	for (; inPos < bufferlen; inPos++, outPos++)
	{
		// non escape char found
		if (buffer[inPos] != 0x5C)
		{
			if (count == 0)
			{
				continue;
			}
			buffer[outPos] = buffer[inPos];
			continue;
		}
		// escape char found ("\\")
		inPos++;
		count++;
		switch (buffer[inPos])
		{
			// \t Horizontal Tab
			case 0x54, 0x74:
				buffer[outPos] = 0x09;
			// \n Line feed
			case 0x4E, 0x6E:
				buffer[outPos] = 0x0A;
			// \" Double quote
			case 0x22:
				buffer[outPos] = 0x22;
			// \% Percent sign
			case 0x25:
				buffer[outPos] = 0x25;
			// \' Single quote
			case 0x27:
				buffer[outPos] = 0x27;
			// \\ Backslash
			case 0x5C:
				buffer[outPos] = 0x5C;
			// ^\\o[0-7]+$ character code octal
			case 0x4F, 0x6F:
			{
				inPos++;
				decl String:number[16];
				new i;
				while (IsCharOctal(buffer[inPos]))
				{
					number[i++] = buffer[inPos++];
				}
				number[i] = 0x00;
				inPos--;
				buffer[outPos] = StringToInt(number, 8);
			}
			// ^\\[0-9]+$ character code decimal
			case 0x30, 0x31, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37, 0x38, 0x39:
			{
				decl String:number[16];
				new i;
				while (IsCharNumeric(buffer[inPos]))
				{
					number[i++] = buffer[inPos++];
				}
				number[i] = 0x00;
				inPos--;
				buffer[outPos] = StringToInt(number, 10);
			}
			// ^\\x[0-9A-Fa-f]+$ character code hexadecimal
			case 0x58, 0x78:
			{
				inPos++;
				decl String:number[16];
				new i;
				while (IsCharHexNumeric(buffer[inPos]))
				{
					number[i++] = buffer[inPos++];
				}
				number[i] = 0x00;
				inPos--;
				buffer[outPos] = StringToInt(number, 16);
			}
			// invalid escape sequence found, ignoring escape char
			default:
			{
				inPos--;
				count--;
				buffer[outPos] = buffer[inPos];
			}
		}
	}
	// shorten buffer to new length
	if (count > 0)
	{
		buffer[bufferlen - (inPos - outPos)] = 0x00;
	}
	return count;
}

stock bool:IsCharHexNumeric(chr)
{
	// 0-9 || A-F || a-f
	return IsCharNumeric(chr) || (0x41 <= chr && chr <= 0x46) || (0x61 <= chr && chr <= 0x66);
}

stock bool:IsCharOctal(chr)
{
	// 0-7
	return (0x30 <= chr && chr <= 0x37);
}

PrintHelp(any:client, String:text[], any:type=0)
{
	// 0 CHAT
	// 1 HINT
	// 2 MENU
	// 3 CENTER
	if (IsClientInGame(client))
	{
		Unescape(text);
		if (type == 0)
			CPrintToChat(client, "{yellow}%s", text);
		else if (type == 1)
			PrintHintText(client, text);
		else if (type == 2)
		{
			new Handle:kv = CreateKeyValues("Stuff", "title", text);
			KvSetColor(kv, "color", 255, 255, 0, 255);
			KvSetNum(kv, "level", 1);
			KvSetNum(kv, "time", 10);
			
			CreateDialog(client, kv, DialogType_Msg);
			
			CloseHandle(kv);
		}
		else if (type == 3)
			PrintCenterText(client, text);
	}
}

public Action:RandomHelp(Handle:Timer, any:client)
{
	if (IsClientInGame(client) && g_Hints[client])
	{		
		new randomnumber = GetRandomInt(0, 5);
		switch (randomnumber)
		{
			case 0:
				PrintHelp(client, "*Visit TheVilluns.Org for more information", 2);

			case 1:
				PrintHelp(client, "*[HINT] Say \x04!menu\x01 for the Menu", 0);
			
			case 2:
				PrintHelp(client, "*[HINT] Say \x04!faq\x01 for help", 0);
				
			case 3:
				PrintHelp(client, "*DoDS:Left4DoD Mod written by Dog", 2);
				
			case 4:
				PrintHelp(client, "*DoDS:Left4DoD Mod written by Dog", 2);
				
			case 5:
				PrintHelp(client, "*Got problems with L4DoD? Go to www.thevilluns.org", 2);
		}
		
		if (GetClientTeam(client) == AXIS)
		{
			if (g_ZombieType[client] == 0)
				PrintHelp(client, "*[HINT] \x04Right click\x01 to make the witch teleport", 0);
				
			else if (g_ZombieType[client] == 2)
				PrintHelp(client, "*[HINT] \x04Right click\x01 to make the Gasman release his gas", 0);
				
			else if (g_ZombieType[client] == 3)
				PrintHelp(client, "*[HINT] \x04Right click\x01 to make the Infected One disappear", 0);
				
			else if (g_ZombieType[client] == 4)
				PrintHelp(client, "*[HINT] \x04Right click\x01 to make the Emo suicide", 0);
			
			else if (g_ZombieType[client] == 1)
				PrintHelp(client, "*[HINT] \x04Right click\x01 to teleport reinforcements", 0);
			
			else if (g_ZombieType[client] == 5)
				PrintHelp(client, "*[HINT] \x04Right click\x01 to launch exploding flaming skulls", 0);
		}
		else if (GetClientTeam(client) == ALLIES)
		{
			randomnumber = GetRandomInt(0, 10);
			switch (randomnumber)
			{
				case 0:
					PrintHelp(client, "*[HINT] \x04Zombie Blood\x01 makes you invisible to Zombies", 0);
					
				case 1:
					PrintHelp(client, "*[HINT] Say \x04!drophealth\x01 to give a team mate health", 0);
				
				case 2:
					PrintHelp(client, "*[HINT] Pick up \x04RED\x01 health boxes if you need healing", 0);
					
				case 3:
					PrintHelp(client, "*[HINT] Pick up \x04GREEN\x01 ammo boxes for ammo", 0);
				
				case 4:
					PrintHelp(client, "*[HINT] Pick up \x04pill bottles\x01 for extra health", 0);
					
				case 5:
					PrintHelp(client, "*[HINT] Say \x04!menu\x01 at spawn for German weapons", 0);
				
				case 6:
					PrintHelp(client, "*[HINT] Smoke grenades are \x04Molotovs\x01", 0);
					
				case 7:
					PrintHelp(client, "*[HINT] \x04Hooch\x01 will make you sprint faster!", 0);
					
				case 8:
					PrintHelp(client, "*[HINT] Pick up \x04BROWN\x01 ammo boxes for ammo", 0);
				
				case 9:
					PrintHelp(client, "*[HINT] Pick up \x04orange pill bottles\x01 for AntiGas", 0);
				
				case 10:
					PrintHelp(client, "*[HINT] Press the USE key to use your TNT", 0);
			}
		}
	}
	return Plugin_Handled;
}

//Hide Console messages with 'Damaga' in them
public Action:TextMsg(UserMsg:msg_id, Handle:bf, const players[], playersNum, bool:reliable, bool:init)
{
    decl String:msg[256];
    BfReadString(bf, msg, sizeof(msg), false);

    if(StrContains(msg, "damage", false) != -1 || StrContains(msg, "-------", false) != -1)
    {
        return Plugin_Handled;
    }

    return Plugin_Continue;
}