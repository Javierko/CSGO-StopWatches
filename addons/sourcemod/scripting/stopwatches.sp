#pragma semicolon 1

#define DEBUG

#define PLUGIN_AUTHOR "Javierko"
#define PLUGIN_VERSION "1.0.0"

#include <sourcemod>

#pragma newdecls required

//Booleans | Ints | Handles

Handle g_hTimerCount = null;
Handle g_hPrintHint = null;

int g_iStopWatchesTimer[MAXPLAYERS + 1] = 0;
bool g_bStopkyOn[MAXPLAYERS + 1] = false;
bool g_bTimerUpdate[MAXPLAYERS + 1];
bool g_bHintUpdate[MAXPLAYERS + 1];

/*
Plugin info
*/

public Plugin myinfo = 
{
	name = "[CS:GO] StopWatches",
	author = PLUGIN_AUTHOR,
	description = "CS:GO StopWatches",
	version = PLUGIN_VERSION,
	url = "github.com/Javierko"
};

/*
Plugin Start
*/

public void OnPluginStart()
{
	//Commands
	RegConsoleCmd("sm_stopwatches", Command_StopWatches);
	
	//Events
	HookEvent("round_start", Event_RoundStart, EventHookMode_Pre);
}

/*
Connect | Disconnect
*/

public void OnClientDisconnect(int client) 
{
	g_iStopWatchesTimer[client] = 0;
	g_bTimerUpdate[client] = false;
	g_bHintUpdate[client] = false;
}

/*
Events
*/

public void Event_RoundStart(Handle hEvent, const char[] name, bool dontBroadcast) 
{
	for (int client = 1; client <= MaxClients; client++) 
	{
		g_iStopWatchesTimer[client] = 0;
		g_bStopkyOn[client] = false;
		g_bTimerUpdate[client] = false;
		g_bHintUpdate[client] = false;
	}
}

/*
Map Start | Map End
*/

public void OnMapStart() 
{
	for (int client = 1; client <= MaxClients; client++) 
	{
		g_iStopWatchesTimer[client] = 0;
		g_bTimerUpdate[client] = false;
		g_bHintUpdate[client] = false;
	}
}

/*
Commands
*/

public Action Command_StopWatches(int client, int args)
{
	if(IsValidClient(client))
	{
		if(!g_bStopkyOn[client])
		{
			if (g_iStopWatchesTimer[client] == 0)
			{
				g_hTimerCount = CreateTimer(1.0, Timer_Count, GetClientUserId(client), TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
				g_hPrintHint = CreateTimer(0.50, Timer_PrintHint, GetClientUserId(client), TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
				g_bTimerUpdate[client] = true;
				g_bHintUpdate[client] = true;
				g_bStopkyOn[client] = true;
			}	
			else if (g_iStopWatchesTimer[client] > 0)
			{
				g_iStopWatchesTimer[client] = 0;
			}
		}
		else
		{		
			if(g_iStopWatchesTimer[client] >= 0)
			{
				char buffer[255];
				SecondsToTime(client, g_iStopWatchesTimer[client], buffer);
				g_bStopkyOn[client] = false;
				g_bTimerUpdate[client] = false;
				g_bHintUpdate[client] = false;
				PrintToChat(client, " [\x02StopWatches\x01] End time was: %s", buffer);
			}
		}
	}
	
	return Plugin_Handled;
}

/*
Timers
*/

public Action Timer_Count(Handle Timer, any cId) 
{
	int client = GetClientOfUserId(cId);
	
	if(IsValidClient(client))
	{
		g_iStopWatchesTimer[client]++;
		if (g_bTimerUpdate[client] == false) 
		{
			ClearTimer(g_hTimerCount);
		}
	}
	
	return Plugin_Continue;
}

public Action Timer_PrintHint(Handle Timer, any cId) 
{
	int client = GetClientOfUserId(cId);
	
	if(IsValidClient(client))
	{
		char buffer[255];
		SecondsToTime(client, g_iStopWatchesTimer[client], buffer);
		
		if (g_bTimerUpdate[client] == true) 
		{
			PrintHintText(client, "<font color='#e5e500' size='30'><u>TIME:</u> %s</font>", buffer);
		}
		else if (g_bTimerUpdate[client] == false && g_bHintUpdate[client] == true) 
		{
			PrintHintText(client, "<font color='#e5e500' size='30'><u>TIME:</u> %s</font>", buffer);
		}
		else if (g_bHintUpdate[client] == false && g_bTimerUpdate[client] == false) 
		{
			ClearTimer(g_hPrintHint);
			PrintHintText(client, "<font color='#e5e500' size='30'><u>OFF</u></font>");
			g_iStopWatchesTimer[client] = 0;
		}
	}
	
	return Plugin_Continue;
}

/*
Stocks | Booleans
*/

stock void ClearTimer(Handle hTimer) 
{
	if (hTimer != null) 
	{
		KillTimer(hTimer);
		hTimer = null;
	}
}

//Thanks Walgrim
stock int SecondsToTime(int client, int seconds, char[] buffer) 
{
	int mins, secs;
	if (seconds >= 60)
	{
		mins = RoundToFloor(float(seconds / 60));
		seconds = seconds % 60;
	}
	
	secs = RoundToFloor(float(seconds));
	if (secs || mins) 
	{
		if (secs < 10) 
		{
			if (mins < 10) 
			{
				Format(buffer, 70, "%s0%d:0%d", buffer, mins, secs);
			}
			else if (mins >= 10) 
			{
				Format(buffer, 70, "%s%d:0%d", buffer, mins, secs);
			}
		}
		else if (secs >= 10) 
		{
			if (mins < 10) 
			{
				Format(buffer, 70, "%s0%d:%d", buffer, mins, secs);
			}
			else if (mins >= 10) 
			{
				Format(buffer, 70, "%s%d:%d", buffer, mins, secs);
			}
		}
	}
	else if (g_bHintUpdate[client] == true) 
	{
		if (secs == 0 && mins == 0) 
		{
			Format(buffer, 70, "%s00:00", buffer);
		}
	}
}

stock bool IsValidClient(int client, bool alive = false)
{
	if(client >= 1 && client <= MaxClients && IsClientConnected(client) && IsClientInGame(client) && (alive == false || IsPlayerAlive(client)))
	{
		return true;
	}
	return false;
}