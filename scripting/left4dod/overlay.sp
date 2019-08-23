//######################### OVERLAY ###################################################################################

HurtOverlay(victim)
{
	if (IsClientInGame(victim))
	{
		if (!g_isIgnored[victim])
		{
			new rnd = GetRandomInt(1,3);
			if (rnd == 1)
				ClientCommand(victim, "r_screenoverlay effects/mh_blood2");
			else if (rnd == 2)
				ClientCommand(victim, "r_screenoverlay effects/mh_blood3");
			else if (rnd == 3)
				ClientCommand(victim, "r_screenoverlay effects/mh_blood1");
		}
	}	
}

public Action:DeathOverlay(Handle:Timer, any:client)
{
	if (IsClientInGame(client))
		ClientCommand(client, "r_screenoverlay debug/yuv");
	return Plugin_Handled;
}

public Action:RemoveOverlay(Handle:Timer, any:client)
{
	if (IsClientInGame(client))
	{
		ClientCommand(client, "r_screenoverlay 0");
		
		new Handle:message = StartMessageOne("Fade", client);
		BfWriteShort(message, 266);
		BfWriteShort(message, 2255);
		BfWriteShort(message, (0x0001 | 0x0010));
		BfWriteByte(message, 0);
		BfWriteByte(message, 0);
		BfWriteByte(message, 0);
		BfWriteByte(message, 0);
		EndMessage();
	}
	return Plugin_Handled;
}