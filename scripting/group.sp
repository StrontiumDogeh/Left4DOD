#include <sourcemod>

#define AUTOLOAD_EXTENSIONS
#define REQUIRE_EXTENSIONS
#include <steamtools>

#define PLUGIN_VERSION "1.0.0"

#define STEAMGROUP 1174424

new Handle:hDatabase = INVALID_HANDLE;

new g_iMemberType[MAXPLAYERS+1];
new g_iLevel[MAXPLAYERS+1];

new String:g_szSteamID[MAXPLAYERS+1][256];

public Plugin:myinfo = {
	name        = "Left4DoD Group",
	author      = "Dog",
	description = "Standalone Plugin for creating list of Left4DoD Group Members",
	version     = PLUGIN_VERSION,
	url         = "https://www.theville.org/"
};

public OnPluginStart()
{
	CreateConVar("left4dod_group", PLUGIN_VERSION, " Left4DoD Group Check Version", FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_REPLICATED);
	LoadTranslations("common.phrases");

	Steam_SetGameDescription("Left4DoD");

	if (hDatabase == INVALID_HANDLE)
	{
		SQL_TConnect(StartUpConnect, "l4dod");
	}
}

public StartUpConnect(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	if (hndl == INVALID_HANDLE)
	{
		LogError("GROUP: Unable to connect to database");
		return;
	}

	hDatabase = hndl;
}

public OnMapStart()
{
	Steam_SetGameDescription("Left4DoD");
}

public OnClientPostAdminCheck(client)
{
	if (!IsFakeClient(client))
	{
		new String:authid[64];
		GetClientAuthString(client, authid, sizeof(authid));

		//Grabs details from the database
		if (hDatabase != INVALID_HANDLE)
		{
			new String:query[1024];
			Format(query, sizeof(query), "SELECT * FROM players WHERE authid REGEXP '^STEAM_[0-9]:%s$' LIMIT 1;", authid[8]);
			//PrintToServer("Query: %s", query);
			SQL_TQuery(hDatabase, GetPlayerStats, query, client, DBPrio_High);
		}
		else
		{
			LogError("GROUP: Lost Database Connection - Invalid Database");
		}
	}
}

public GetPlayerStats(Handle:owner, Handle:hQuery, const String:error[], any:client)
{
	if(hQuery != INVALID_HANDLE)
	{
		if (client > 0)
		{
			//Found in database
			if (SQL_GetRowCount(hQuery) > 0)
			{
				while(SQL_FetchRow(hQuery))
				{
					g_iLevel[client] = SQL_FetchInt(hQuery, 2);
					g_iMemberType[client] = SQL_FetchInt(hQuery, 3);
				}

				//PrintToServer( "GROUP: %N [%i] found in Database", client, g_iMemberType[client]);

				Steam_RequestGroupStatus(client, STEAMGROUP);
			}

			//Not found in database
			else
			{
				g_iMemberType[client] = 0;

				Steam_RequestGroupStatus(client, STEAMGROUP);
			}

			CloseHandle(hQuery);
		}
	}
	else
	{
		LogError("GROUP: Lost Database Connection - Unable to retrieve membership");
		LogError("GROUP: %s", error);

		//Try database again...
	}
}

public Steam_GroupStatusResult(client, groupAccountID, bool:groupMember, bool:groupOfficer)
{
	if (client > 0 && IsClientConnected(client) && !IsFakeClient(client))
	{
		if (groupAccountID == STEAMGROUP && groupMember)
		{
			g_iMemberType[client]  = 1;
		}
		else
		{
			g_iMemberType[client]  = 0;
		}

		if (groupAccountID == STEAMGROUP && groupOfficer)
		{
			g_iMemberType[client]  = 2;
		}

		//PrintToServer( "GROUP: After processing %N Membership is now [%i] ", client, g_iMemberType[client]);

		SetGroupData(client);
	}
}

SetGroupData(client)
{
	if (g_iMemberType[client]  > 0)
	{
		new String:query[1024];

		new String:clientname[128];
		Format(clientname, sizeof(clientname), "%N", client);

		Format(query, sizeof(query), "UPDATE players SET authid='%s', playername='%s', level='%i', member='%i') WHERE authid='%s');", g_szSteamID[client], clientname, g_iLevel[client], g_iMemberType[client], g_szSteamID[client]);

		//PrintToServer("Query: %s", query);
		SQL_TQuery(hDatabase, AddToDatabase, query, client, DBPrio_High);
	}
}

public AddToDatabase(Handle:owner, Handle:hQuery, const String:error[], any:client)
{
	if (hQuery == INVALID_HANDLE)
	{
		if (client > 0 && IsClientInGame(client))
			LogError("GROUP: Error writing to DB [%N]:%s", client, error);
		else
			LogError("GROUP: Error writing to DB:%s", error);

		return;
	}
	else
	{
		CloseHandle(hQuery);
	}
}
