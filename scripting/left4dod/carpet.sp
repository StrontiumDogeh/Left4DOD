// CARPET NADES #######################################################################
public Action:Carpet(Handle:timer, any:ent)
{
	new Float:vLoc[3];
	if (IsValidEntity(ent))
	{
		GetEntDataVector(ent, g_oEntityOrigin, vLoc);
		new owner;

		for (new i = 1; i <= MaxClients; i++)
		{
			if (IsClientInGame(i) && g_Bomblet[i] == ent)
			{
				owner = i;
				g_Bomblet[i] = 0;
				break;
			}
		}
		if (owner > 0)
		{
			new bomblet_number = 2;

			if (g_bIsSupporter[owner])
				bomblet_number = 5;

			for (new bomblets = 1; bomblets <= bomblet_number; bomblets++)
			{
				new Float:dettime;

				dettime = (0.1 * bomblets);

				new Handle:bomblet_data = CreateDataPack();
				WritePackCell(bomblet_data, owner);
				WritePackFloat(bomblet_data, vLoc[0]);
				WritePackFloat(bomblet_data, vLoc[1]);
				WritePackFloat(bomblet_data, vLoc[2]);

				CreateTimer(dettime, CreateBomblets, bomblet_data);
			}
		}
	}
	return Plugin_Handled;
}

public Action:CreateBomblets(Handle:timer, Handle:bomblet_data)
{
	new Float:location[3];

	ResetPack(bomblet_data);
	new client = ReadPackCell(bomblet_data);
	location[0] = ReadPackFloat(bomblet_data) + (GetRandomFloat(0.1, 0.8) * 50 * GetMathSign());
	location[1] = ReadPackFloat(bomblet_data) + (GetRandomFloat(0.1, 0.8) * 50 * GetMathSign());
	location[2] = ReadPackFloat(bomblet_data) + 10.0;

	g_BombletNumber++;

	new ent = CreateEntityByName("prop_physics_override");

	if (g_bIsSupporter[client])
	{
		SetEntityModel(ent, "models/gibs/hgibs.mdl");
	}
	else
	{
		SetEntityModel(ent, "models/weapons/w_garand_rg_grenade.mdl");
	}

	new String:bombletname[16];
	Format(bombletname, sizeof(bombletname), "Bomblet%i", g_BombletNumber);
	DispatchKeyValue(ent, "StartDisabled", "false");
	DispatchKeyValue(ent, "targetname", bombletname);
	DispatchKeyValue(ent, "Spawnflags", "48");
	DispatchKeyValue(ent, "MinHealthDmg", "10.0");
	DispatchKeyValue(ent, "ExplodeRadius", "200");
	DispatchKeyValue(ent, "ExplodeDamage", "200");
	SetEntityMoveType(ent, MOVETYPE_VPHYSICS);
	SetEntProp(ent, Prop_Send, "m_CollisionGroup", DROP_COLLISION);
	SetEntProp(ent, Prop_Send, "m_usSolidFlags", 28);
	SetEntProp(ent, Prop_Send, "m_nSolidType", 6);

	DispatchSpawn(ent);
	SetEntPropEnt(ent, Prop_Data, "m_hOwnerEntity", client);
	SetEntPropEnt(ent, Prop_Data, "m_hLastAttacker", client);
	SetEntPropEnt(ent, Prop_Data, "m_hPhysicsAttacker", client);
	TeleportEntity(ent, location, NULL_VECTOR, NULL_VECTOR);

	EmitSoundToAll("weapons/grenade/tick1.wav", ent);

	//TE_SetupBeamFollow(ent, BeamSprite, 0, Float:5.0, Float:10.0, Float:10.0, 5, g_AlliesColour);
	//TE_SendToAll();

	new String:addoutput[64];
	Format(addoutput, sizeof(addoutput), "OnUser1 !self:break::%f:1", 2.0);
	SetVariantString(addoutput);
	AcceptEntityInput(ent, "AddOutput");
	AcceptEntityInput(ent, "FireUser1");

	Format(addoutput, sizeof(addoutput), "OnBreak !self:kill::%f:1", 2.1);
	SetVariantString(addoutput);
	AcceptEntityInput(ent, "AddOutput");
	return Plugin_Handled;
}
