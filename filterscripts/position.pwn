/* Script: Position - Save, Load & Delete[Y_INI][ZCMD]
-» Release Date:       		  09.03.2018
-» Description:             Save/load/delete position of player with 1 command
-» Saving System Used: 		  Y_INI (by Y_Less)
-» Command Processor Used:  ZCMD (by Zeex)
-» Version:                 1.0(Stable)
*/

/*============================================================================*/
/*INCLUDES*/
#include <a_samp>
#include <YSI\y_ini>
#include <sscanf2>
#include <zcmd>

#define POSITIONPATH 		  "Positions/%s.ini"
#define LOADPOSONSPAWN		true
/*============================================================================*/
enum PlayerInfo
{
	Int,
	Vw,
	Float:Apos,
	Float:Xpos,
	Float:Ypos,
	Float:Zpos,
	bool:SavedPos
}

new pInfo[MAX_PLAYERS][PlayerInfo];

forward LoadPos_UserData(playerid,name[],value[]);
public LoadPos_UserData(playerid,name[],value[])
{
    INI_Int("Interior", pInfo[playerid][Int]);
    INI_Int("VirtualWorld", pInfo[playerid][Vw]);
	  INI_Float("Angle", pInfo[playerid][Apos]);
	  INI_Float("Xpos", pInfo[playerid][Xpos]);
	  INI_Float("Ypos", pInfo[playerid][Ypos]);
	  INI_Float("Zpos", pInfo[playerid][Zpos]);
	  INI_Bool("Saved", pInfo[playerid][SavedPos]);
    return 1;
}
/*============================================================================*/
public OnFilterScriptInit()
{
	print("\n______________________________________");
	print("Position (v1.0) (Stable Release)");
	print("SCRIPT: Loading...");
	print("SCRIPT: Loaded.");
	for(new i, j = GetPlayerPoolSize(); i <= j; i++)
	{
		if(fexist(PositionPath(i)))
		{
			INI_ParseFile(PositionPath(i), "LoadPos_%s", .bExtra = true, .extra = i);
			SendClientMessageToAll(-1, "SERVER: Position database has been refreshed!");
		}
	}
	print("Y_INI: Position Data Loading...");
	print("Y_INI: Loaded.");
	print("______________________________________\n");
	return 1;
}

public OnFilterScriptExit()
{
	print("\n______________________________________");
	print("Position (v1.0) (Stable Release)");
	print("Unloaded!");
	print("______________________________________\n");
	return 1;
}
/*============================================================================*/
public OnPlayerConnect(playerid)
{
	if(fexist(PositionPath(playerid)))
	{
		INI_ParseFile(PositionPath(playerid), "LoadPos_%s", .bExtra = true, .extra = playerid);
	}
	return 1;
}

public OnPlayerSpawn(playerid)
{
	#if LOADPOSONSPAWN == true
	SetPlayerPos(playerid, pInfo[playerid][Xpos], pInfo[playerid][Ypos], pInfo[playerid][Zpos]+0.3);
	#endif
    return 1;
}

/*============================================================================*/
CMD:mypos(playerid, params[])
{
	new pos;
	if(sscanf(params, "u", pos)) return SendClientMessage(playerid, -1, "SYNTAX: /mypos <save/load/delete>");
	if(!strcmp(params, "save", true))
    {
		if(pInfo[playerid][SavedPos] == false)
		{
			pInfo[playerid][SavedPos] = true;
			new Float:Xpos1, Float:Ypos1, Float:Zpos1, Float:Angle;
			GetPlayerPos(playerid, Xpos1, Ypos1, Zpos1);
			GetPlayerFacingAngle(playerid, Angle);

			pInfo[playerid][Xpos] = Xpos1;
			pInfo[playerid][Ypos] = Ypos1;
			pInfo[playerid][Zpos] = Zpos1;
			pInfo[playerid][Apos] = Angle;
			pInfo[playerid][Int] = GetPlayerInterior(playerid);
			pInfo[playerid][Vw] = GetPlayerVirtualWorld(playerid);

		    new INI:File = INI_Open(PositionPath(playerid));
		    INI_SetTag(File,"PositionData");
			INI_WriteInt(File, "Interior", pInfo[playerid][Int]);
			INI_WriteInt(File, "VirtualWorld", pInfo[playerid][Vw]);
			INI_WriteFloat(File, "Angle", pInfo[playerid][Apos]);
			INI_WriteFloat(File, "Xpos", pInfo[playerid][Xpos]);
			INI_WriteFloat(File, "Ypos", pInfo[playerid][Ypos]);
			INI_WriteFloat(File, "Zpos", pInfo[playerid][Zpos]);
			INI_WriteBool(File, "Saved", pInfo[playerid][SavedPos]);
			INI_Close(File);

			SendClientMessage(playerid, -1, "SUCCESS: Position is saved! Use /mypos load to teleport.");
		} else SendClientMessage(playerid, -1, "ERROR: You already saved one position, use /mypos delete to delete it!");
	}
    else if(!strcmp(params,"load",true))
    {
		if(pInfo[playerid][SavedPos] == true)
		{
			SetPlayerPos(playerid, pInfo[playerid][Xpos], pInfo[playerid][Ypos], pInfo[playerid][Zpos]+0.3);
			SetPlayerVirtualWorld(playerid, pInfo[playerid][Vw]);
			SetPlayerInterior(playerid, pInfo[playerid][Int]);
			SendClientMessage(playerid, -1, "SUCCESS: Teleported to Position.");
		} else SendClientMessage(playerid, -1, "ERROR: You didn't save any Position. Use /mypos save.");
	}
 	else if(!strcmp(params,"delete",true))
  {
    if(pInfo[playerid][SavedPos] == true)
		{
		  pInfo[playerid][SavedPos] = false;
			new INI:File = INI_Open(PositionPath(playerid));
			INI_SetTag(File,"PositionData");
			INI_WriteInt(File, "Interior", 0);
			INI_WriteInt(File, "VirtualWorld", 0);
			INI_WriteFloat(File, "Angle", 0);
			INI_WriteFloat(File, "Xpos", 0);
			INI_WriteFloat(File, "Ypos", 0);
			INI_WriteFloat(File, "Zpos", 0);
			INI_WriteBool(File, "Saved", pInfo[playerid][SavedPos]);
			INI_Close(File);

			SendClientMessage(playerid, -1, "SUCCESS: Position is deleted! Use /mypos save.");
		} else SendClientMessage(playerid, -1, "ERROR: You didn't save any Position. Use /mypos save.");
 	}
	return 1;
}
/*============================================================================*/
stock PositionPath(playerid)
{
    new string[46], pName[MAX_PLAYER_NAME];
    GetPlayerName(playerid, pName, sizeof(pName));
    format(string,sizeof(string), POSITIONPATH, pName);
    return string;
}
/*============================================================================*/
