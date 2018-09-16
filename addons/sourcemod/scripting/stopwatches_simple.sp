#pragma semicolon 1

#define DEBUG

#define PLUGIN_AUTHOR "Javierko"
#define PLUGIN_VERSION "1.0.0"

#include <sourcemod>

//Booleans | Floats

bool g_bStopWatch = false;
float g_fStopWatchsTime;
float g_fTimeleft;

#pragma newdecls required

/*
Plugin info
*/

public Plugin myinfo = 
{
	name = "[CS:GO] Simple stopwatch",
	author = PLUGIN_AUTHOR,
	description = "Simple plugin stopwatches",
	version = PLUGIN_VERSION,
	url = "https://github.com/javierko"
};

/*
Plugins start | plugin End
*/

public void OnPluginStart()
{
	//Commands
	RegConsoleCmd("sm_stopwatches", Command_StopWatch);
	
	//Events
	HookEvent("round_start", Event_OnRoundStart);
}

/*
GameFrame
*/

public void OnGameFrame()
{
	if(g_bStopWatch)
	{
		g_fTimeleft = GetGameTime() - g_fStopWatchsTime;
		if(g_fTimeleft > 0.0)
		{
			PrintHintTextToAll("<font color='#00FF00' size='20'>STOPWATCHES IS ON!</font>\n<font color='#FFFFFF' size='30'>TIME: %0.2f</font>", g_fTimeleft);
		}
	}
}

/*
Events
*/

public void Event_OnRoundStart(Handle event, const char[] name, bool dontBroadcast)
{
	g_bStopWatch = false;
}

/*
Commands
*/

public Action Command_StopWatch(int client, int args)
{
	if(IsValidClient(client))
	{
		if(g_bStopWatch)
		{
			g_bStopWatch = false;
			PrintHintTextToAll("<font color='#00FF00' size='20'>%N TURNED OFF STOPWATCHES</font>\n<font color='#FFFFFF' size='30'>TIME: %0.02f</font>", client, g_fTimeleft);
		}
		else
		{
			g_bStopWatch = true;
			g_fStopWatchsTime = GetGameTime();
		}
	}
	
	return Plugin_Handled;
}

/*
Stocks
*/

stock bool IsValidClient(int client, bool alive = false)
{
	if(client >= 1 && client <= MaxClients && IsClientConnected(client) && IsClientInGame(client) && (alive == false || IsPlayerAlive(client)))
	{
		return true;
	}
	return false;
}