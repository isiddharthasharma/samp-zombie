/* Sample Script: V.I.P [Y_INI & ZCMD]
-» Release Date:       		06.02.2018 (Unreleased Build)
-» Description:        		V.I.P Script specially designed for TDM/DM servers.
-» Saving System Used: 		Y_INI (by Y_Less)
-» Command Processor Used:  	ZCMD (by Zeex)
-» Version:                 	1.0(Stable)
*/

/*============================================================================*/
#define FILTERSCRIPT
#include <a_samp>
#include <YSI\y_ini>
#include <sscanf2>
#include <zcmd>
#include <infotext>

#define COLOR_VIP  			(0xF6BB0AA)
#define COLOR_VIPCARTAG		(0xFF0000AA)
/*============================================================================*/
/*CONFIGURATION*/

//You can change the path where VIP users will save.
//NOTE: Once you change your path here, you've to create the folder in the scriptfiles too.
#define VIPUSERPATH			"VIP/Users/%s.ini"
#define LOGFILE				"VIP/Logs/%s.log"
#define VIPCONFIGPATH 		"VIP/Config.cfg"

//Change it to any symbol if you want VIP(s) to chat.
//How to chat as VIP in game: #Hi
#define VIPCHATKEY 			'!'
//You can set the chat tag which will look like this
//[VIP-CHAT] Sid(15): Hi all!
//You can also change the colour of the chat from here.
#define VIPCHATTAG          "{88AA88}[VIP-CHAT]"

//Set true/false if you want VIP(s) to use /vsay which can be seen by everyone i.e [VIP]: Siddharth(1): Hi
#define VSAY_CMD 			true
#define VSAYTEXT            "%s(%d){3DE3B1}[VIP]{FFFFFF}: %s"
//Here you can only use first '%s' as name, second '%s' as text and '%d' as playerid

//Check the last dialog ID of your all filterscripts and gamemodes then put the last ID over here(in place of 9999).
#define MAXGMDIALOG         9999

//Edit these if you want your VIP's Level Name to be recognized by something else
#define LEVEL1NAME      	"Bronze VIP"
#define LEVEL2NAME      	"Silver VIP"
#define LEVEL3NAME       	"Gold VIP"

//Edit this if you want to change the label above the player or disable showing above their head
#define SHOWVIPCARTAG
#define SHOWVIPHEADTAG
#define	VIPHEADTAG       	"Very Important Person"
#define COLOR_VIPHEADTAG    (0xFF0000AA) // Red Color

//Edit this if you want normal players to have less health and armour than VIP(s).
#define NORMALPLAYERHEALTH  100
#define NORMALPLAYERARMOUR  10

//NOTE: These will also apply where VIP use /healme and /armourme commands!
#define LVL1HEALTH  		100
#define LVL1ARMOUR			40

#define LVL2HEALTH 			100
#define LVL2ARMOUR 			50

#define LVL3HEALTH 			100
#define LVL3ARMOUR 			100

//Edit this to give VIP players additional "x" amount of ammo to all weapons.
#define LVL1SPAWNAMMO       200
#define LVL2SPAWNAMMO       400
#define LVL3SPAWNAMMO       600

//Edit this to give VIP players additional "x" amount of cash and score per kill. (Set 0 if to disable)
#define LVL1KILLSCORE       2
#define LVL1KILLCASH        2000

#define LVL2KILLSCORE       3
#define LVL2KILLCASH        3000

#define LVL3KILLSCORE       4
#define LVL3KILLCASH        4000

//Edit this if you want to change the ERROR messages for those who try to access VIP commands.
#define NO_VIP_ERROR 		"SERVER: You must buy VIP package from forum to use this command!"
#define NO_RCON_ERROR 		"SERVER: You must be RCON Administrator to use this command!"
#define NOT_PROCESSED_ERROR "SERVER: You can't use the command while processing."
#define ABUSEERROR 	        "SERVER: Please wait 10 seconds to use this command."
#define PERDEATHERROR       "~r~~H~ERROR:~W~:~N~~Y~YOU CAN USE THIS COMMAND AFTER DEATH ONLY!"
#define VEH_EXIST_ERROR		"~r~~H~ERROR~W~:~N~~Y~YOU ALREADY HAVE A VEHICLE!"
/*============================================================================*/
// VARIABLES
new timer[MAX_PLAYERS];
new vehicle_id;
new vscar[MAX_PLAYERS];
new hpabuse[MAX_PLAYERS];
new hprotection[MAX_PLAYERS];
new aprotection[MAX_PLAYERS];
new sprotection[MAX_PLAYERS];
new jprotection[MAX_PLAYERS];

#if !defined IsNull
	#define IsNull(%1) \
		((!(%1[0])) || (((%1[0]) == '\1') && (!(%1[1]))))
#endif
/*============================================================================*/
// SAVING PLAYER DATA

enum PlayerInfo
{
	pVipLevel, pVipTime, pVeh, pSkin, Int, Vw, vOwner,
	Float:Xpos, Float:Ypos, Float:Zpos, Float:Apos,
	bool:SavedPos, bool:SavedSkin
}
new pInfo[MAX_PLAYERS][PlayerInfo];

forward LoadUser_UserData(playerid,name[],value[]);
public LoadUser_UserData(playerid,name[],value[])
{
    INI_Int("vLevel", pInfo[playerid][pVipLevel]);
    INI_Int("vTime", pInfo[playerid][pVipTime]);

    INI_Int("SavedVehicle", pInfo[playerid][pVeh]);

    INI_Int("Interior", pInfo[playerid][Int]);
    INI_Int("VirtualWorld", pInfo[playerid][Vw]);

	INI_Float("Angle", pInfo[playerid][Apos]);
	INI_Float("Xpos", pInfo[playerid][Xpos]);
	INI_Float("Ypos", pInfo[playerid][Ypos]);
	INI_Float("Zpos", pInfo[playerid][Zpos]);
    return 1;
}

/*============================================================================*/

#if defined FILTERSCRIPT
public OnFilterScriptInit()
{
	for(new i, j = GetPlayerPoolSize(); i <= j; i++)
	{
		if(fexist(UserPath(i)))
		{
			INI_ParseFile(UserPath(i), "LoadUser_%s", .bExtra = true, .extra = i);
		}
		sprotection[i] = 0;
		hprotection[i] = 0;
		aprotection[i] = 0;
	}
	for(new i = 0; i < MAX_VEHICLES; i++) pInfo[i][vOwner] = INVALID_PLAYER_ID;
	OnShadowInit();
 	
	print("\n |===============================================================|");
	print(" |               V.I.P(v1.0)                                     |");
	print(" |      Designed for (Team) Death Match	                         |");
	print(" | > Y_INI: Config Data Loading...                             < |");
	print(" | > Y _INI: Config Data Loaded!                               < |");
	print(" |===============================================================|\n");

	SendClientMessageToAll(COLOR_VIP, "SERVER: {FFFFFF}V.I.P database has been refreshed!");
	return 1;
}

public OnFilterScriptExit()
{
	print("_____________________________________________");
	print("[V.I.P]: Script v1.0(Stable)");
	print("Unloaded!");
	print("_____________________________________________");
	return 1;
}
#endif

public OnPlayerConnect(playerid)
{
	if(pInfo[playerid][pVipLevel] >= 1)
	{
	    new string[250];
		new vname[MAX_PLAYER_NAME];
		GetPlayerName(playerid,vname,sizeof(vname));
	    format(string, sizeof(string), "~y~Welcome ~y~~h~~h~%s!~N~~y~ID: ~y~~h~~h~%d~w~~N~~y~LEVEL: ~y~~h~~h~%d", vname, playerid, pInfo[playerid][pVipLevel]);
		ShadInfoBoxForPlayer(playerid, string);
		if(pInfo[playerid][pVipTime] > gettime())
		{
			new TotalVipTime, Days, Hours, Minutes, Msg[200];

			TotalVipTime = pInfo[playerid][pVipTime] - gettime();

			if (TotalVipTime >= 86400)
			{
				Days = TotalVipTime / 86400;
				TotalVipTime = TotalVipTime - (Days * 86400);
			}
			if (TotalVipTime >= 3600)
			{
				Hours = TotalVipTime / 3600;
				TotalVipTime = TotalVipTime - (Hours * 3600);
			}
			if (TotalVipTime >= 60)
			{
				Minutes = TotalVipTime / 60;
				TotalVipTime = TotalVipTime - (Minutes * 60);
			}
			format(Msg, 200, "VIP-INFO:{FFFFFF} Your V.I.P is valid for {6BB0AA}%i {FFFFFF}day(s), {88AA88}%i {FFFFFF}hour(s) and {88AA88}%i {FFFFFF}minute(s).\n", Days, Hours, Minutes);
			SendClientMessage(playerid, COLOR_VIP, Msg);
		}
		else
	 	{
			SendClientMessage(playerid, COLOR_VIP, "VIP-INFO:{FFFFFF} Your V.I.P time period is expired! Renew it today!");
			pInfo[playerid][pVipLevel] = 0;
		}
		format(string, sizeof(string), "* VIP %s(%d) has joined the server.", vname, playerid);
		SendClientMessageToAll(COLOR_VIP, string);
	}
	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
	SaveStats(playerid);
	CloseTextdraw(playerid);
	DestroyVeh(playerid);
	
    TextDrawHideForPlayer(playerid, ShadInfoBox);
    TextDrawDestroy(ShadInfoBox);
    for(new i = 0; i < MAX_VEHICLES; i++) if(pInfo[i][vOwner] == playerid) pInfo[i][vOwner]=INVALID_PLAYER_ID;
	return 1;
}

public OnPlayerSpawn(playerid)
{
	if(pInfo[playerid][pVipLevel] >= 0)
	{
	 	TogglePlayerControllable(playerid, false);
	 	ShadInfoBoxForPlayer(playerid, "~g~~h~~h~~h~SPAWN INFO~n~~n~~y~Processing....");
	 	timer[playerid] = SetTimerEx("Processed", 5000, true, "i", playerid);
	}
	hpabuse[playerid] = 0;
	sprotection[playerid] = 1;
	DestroyVeh(playerid);
 	return 1;
}

public OnPlayerDeath(playerid, killerid, reason)
{
	if(pInfo[killerid][pVipLevel] == 1)
	{
		SetPlayerScore(killerid, GetPlayerScore(killerid) + LVL1KILLSCORE);
		GivePlayerMoney(killerid, LVL1KILLCASH);
	}
 	if(pInfo[killerid][pVipLevel] == 2)
	{
		SetPlayerScore(killerid, GetPlayerScore(killerid) + LVL2KILLSCORE);
		GivePlayerMoney(killerid, LVL2KILLCASH);
	}
 	if(pInfo[killerid][pVipLevel] == 3)
	{
		SetPlayerScore(killerid, GetPlayerScore(killerid) + LVL3KILLSCORE);
		GivePlayerMoney(killerid, LVL3KILLCASH);
	}
	hprotection[playerid] = 1;
	aprotection[playerid] = 0;
	DestroyVeh(playerid);
	CloseTextdraw(playerid);
	return 1;
}

public OnPlayerText(playerid, text[])
{
	if(text[0] == VIPCHATKEY && pInfo[playerid][pVipLevel] >= 1)
	{
	    new vname[24], string[128]; GetPlayerName(playerid, vname,sizeof(vname));
		format(string,sizeof(string), ""VIPCHATTAG" %s(%d): %s", vname, playerid, text[1]);
		SendTextToVIP(-1, string);
		savelog("chat",string);
	}
	return 0;
}

public OnPlayerEnterVehicle(playerid, vehicleid, ispassenger)
{
    new Float:x, Float:y, Float:z;
    if(pInfo[vehicle_id][vOwner] != INVALID_PLAYER_ID)
    {
        if(pInfo[vehicle_id][vOwner] != playerid)
        {
            SendClientMessage(playerid, COLOR_VIP, "SERVER: {FFFFFF}You're not allowed to use vehicles owned by V.I.P(s)!");
            GetPlayerPos(playerid, x, y, z);
            return SetPlayerPos(playerid, x, y, z+3);
        }
    }
	#if defined SHOWVIPCARTAG
	if(pInfo[playerid][pVipLevel] >= 1)
	{
 		if(vscar[playerid] == 1)
	    {
		    new pname[MAX_PLAYER_NAME], Text3D:Veh3DText[MAX_VEHICLES], string[40];
		    GetPlayerName(playerid, pname, sizeof(pname));

			format(string, sizeof(string), "%s's Vehicle", pname);
		    Veh3DText[vehicle_id] = Create3DTextLabel(string, COLOR_VIPCARTAG, 0.0, 0.0, 0.0, 50.0, 0, 1 );
	   		Attach3DTextLabelToVehicle(Veh3DText[vehicle_id], vehicle_id, 0.0, 0.0, 2.0);
		}
	}
	#endif
	return 1;
}


CMD:setvip(playerid, params[])
{
	if(IsPlayerAdmin(playerid))
    {
		new tname[MAX_PLAYER_NAME], aname[MAX_PLAYER_NAME], vlevel, targetid, days, string[128];
		if(sscanf(params, "udd", targetid, vlevel, days)) return SendClientMessage(playerid, COLOR_VIP, "SERVER: {FFFFFF}/setvip [playerid] [level] [day(s)]");
		if(targetid == INVALID_PLAYER_ID) return SendClientMessage(playerid, COLOR_VIP, "SERVER: {FFFFFF}Player is not connected!");
		if(vlevel == pInfo[targetid][pVipLevel]) return SendClientMessage(playerid, COLOR_VIP, "SERVER: {FFFFFF}Player you're trying to set vip have the same level or day(s) are 0!");
		if(vlevel > 3 || vlevel < 0) return SendClientMessage(playerid, COLOR_VIP, "SERVER: {FFFFFF}Please set the level between 1 to 3.");
		{
			GetPlayerName(playerid, aname, sizeof(aname));
			GetPlayerName(targetid, tname, sizeof(tname));

			format(string,sizeof(string),"SERVER: {FFFFFF}%s(%d) has set you as Very Important Person(%d) for %i day(s).", aname, playerid, vlevel, days);
			SendClientMessage(playerid, COLOR_VIP, string);

			format(string, sizeof(string), "SERVER: {6BB0AA}You've set %s(%d) as V.I.P(%d) for %i day(s).", tname, playerid, vlevel, days);
			SendClientMessage(playerid, COLOR_VIP, string);
			pInfo[playerid][pVipLevel] = vlevel;
			pInfo[playerid][pVipTime] = gettime() + days * 86400;

			new INI:File = INI_Open(UserPath(playerid));
			INI_SetTag(File,"UserData");
			INI_WriteInt(File, "vLevel", pInfo[playerid][pVipLevel]);
			INI_WriteInt(File, "vTime", pInfo[playerid][pVipTime]);
			INI_Close(File);
			format(string,sizeof(string),"'%s' has set '%s' V.I.P level to '%d' for %i day(s).", aname, tname, vlevel, days);
			savelog("setvip",string);
		}
    }
    else SendClientMessage(playerid, -1, NO_RCON_ERROR);
	return 1;
}

CMD:myvip(playerid, params[])
{
	if(pInfo[playerid][pVipLevel] >= 1 || pInfo[playerid][pVipTime] > gettime())
	{
		new TotalVipTime, Days, Hours, Minutes, Msg[200];
		TotalVipTime = pInfo[playerid][pVipTime] - gettime();

		if (TotalVipTime >= 86400)
		{
			Days = TotalVipTime / 86400;
			TotalVipTime = TotalVipTime - (Days * 86400);
		}
		if (TotalVipTime >= 3600)
		{
			Hours = TotalVipTime / 3600;
			TotalVipTime = TotalVipTime - (Hours * 3600);
		}
		if (TotalVipTime >= 60)
		{
			Minutes = TotalVipTime / 60;
			TotalVipTime = TotalVipTime - (Minutes * 60);
		}
		format(Msg, 200, "SERVER: {FFFFFF}Level: (%d) | Valid Thru: {6BB0AA}%i {FFFFFF}day(s), {88AA88}%i {FFFFFF}hour(s) and {88AA88}%i {FFFFFF}minute(s).", pInfo[playerid][pVipLevel], Days, Hours, Minutes);
		SendClientMessage(playerid, COLOR_VIP, Msg);
	}
	else
 	{
		SendClientMessage(playerid, COLOR_VIP, "SERVER: {FFFFFF}Your V.I.P has been expired!");
		pInfo[playerid][pVipLevel] = 0;
	}
	return 1;
}

CMD:donors(playerid, params[]) return cmd_vips (playerid, params);
CMD:vips(playerid,params[])
{
	if(pInfo[playerid][pVipLevel] >= 0)
	{
 		new bool:First2 = false;
 		new Count, i;
	    new string[128];
		new vipname[MAX_PLAYER_NAME];
		new VIPRANK[MAX_PLAYERS];
	    for(i = 0; i < MAX_PLAYERS; i++)
		if(IsPlayerConnected(i) && pInfo[i][pVipLevel] > 0)
		Count++;

		if(Count == 0)
		return ShowPlayerDialog(playerid, MAXGMDIALOG+1 ,DIALOG_STYLE_MSGBOX,"V.I.P(s) Online", "{FFFFFF}None.", "Close", "");
	    for(i = 0; i < MAX_PLAYERS; i++)
		if(IsPlayerConnected(i) && pInfo[i][pVipLevel] >= 0)
		{
			if(pInfo[i][pVipLevel] > 0)
			{
				switch(pInfo[i][pVipLevel])
				{
					case 1:
					{
						VIPRANK = ""LEVEL1NAME"";
					}
					case 2:
					{
						VIPRANK = ""LEVEL2NAME"";
					}
					case 3:
					{
						VIPRANK = ""LEVEL3NAME"";
					}
				}
			}
			GetPlayerName(i, vipname, sizeof(vipname));
			if(!First2)
			{
				format(string, sizeof(string), "%s(%d): {991643}%s(%d)\n", vipname, i, VIPRANK, pInfo[i][pVipLevel]);
				First2 = true;
			}
			else format(string,sizeof(string),"%s(%d): {991643}%s(%d)\n",string, i, VIPRANK);
        }
	    return ShowPlayerDialog(playerid, MAXGMDIALOG+1 ,DIALOG_STYLE_MSGBOX,"V.I.P(s) Online", "{FFFFFF}None.", "Close", "");
	}
	return 1;
}

CMD:vipfeatures(playerid, params[]) return cmd_perks (playerid, params);
CMD:vfeatures(playerid, params[]) return cmd_perks (playerid, params);
CMD:perks(playerid ,params[])
{
	new string[1020];
	strcat(string, "{991643}"LEVEL1NAME"(1) Features:\n");
	strcat(string, "{FFFFFF}* Spawn Health: 100.0 | Armour: 40.0 | Ammo: +200 to all weapons.\n");
	strcat(string, "{FFFFFF}* +$2000 and 2 score per kill.\n");
	strcat(string, "{FFFFFF}* Able to spawn road and water vehicles.\n\n");

	strcat(string, "{991643}"LEVEL3NAME"(2) Features:\n");
	strcat(string, "{991643}* Access to level "LEVEL1NAME"(1) features.\n");
	strcat(string, "{FFFFFF}* Spawn Health: 100.0 | Armour: 50.0 | Ammo: +400 to all weapons.\n");
	strcat(string, "{FFFFFF}* +$3000 and 3 score per kill.\n");
	strcat(string, "{FFFFFF}* Able to tune road vehicles.\n");
	strcat(string, "{FFFFFF}* Able to set their own time and weather.\n\n");

	strcat(string, "{991643}"LEVEL3NAME"(3) Features:\n");
    strcat(string, "{991643}* Access to level "LEVEL1NAME"(1) and "LEVEL2NAME"(2) features.\n");
	strcat(string, "{FFFFFF}* Invisible on map.\n");
	strcat(string, "{FFFFFF}* Personal Vehicle only owned by V.I.P\n");
	strcat(string, "{FFFFFF}* Spawn Health: 100.0 | Armour: 100.0 | Ammo: +600 to all weapons.\n");
	strcat(string, "{FFFFFF}* +$4000 and 4 score per kill.\n");
	strcat(string, "{FFFFFF}* Able to spawn road, water and air vehicles.\n\n");

	strcat(string, "{88AA88}* Special chat only available for V.I.P(s).\n");
	ShowPlayerDialog(playerid, MAXGMDIALOG+2 ,DIALOG_STYLE_MSGBOX,"{991643}V.I.P Features", string, "Close","");
	return 1;
}

CMD:vipcmds(playerid, params[]) return cmd_vcmds (playerid, params);
CMD:vcmds(playerid ,params[])
{
    new string[950];
	if(pInfo[playerid][pVipLevel] >= 1)
	{
		if(pInfo[playerid][pVipLevel] == 1)
		{
			strcat(string, "{991643}"LEVEL1NAME"(1) Commands:\n");
			strcat(string, "{FFFFFF}/vsay /healme /armourme\n");
			strcat(string, "{FFFFFF}/vflip{656565}(vehicle) {FFFFFF}/vfix /vveh{656565}(1, 2, 3, 4)\n");
			strcat(string, "{FFFFFF}/myw{656565}(eather) {FFFFFF}/myt{656565}(ime)\n");
			strcat(string, "{FFFFFF}Use '# text' as VIP Chat\n\n");
		}
		if(pInfo[playerid][pVipLevel] == 2)
		{
			strcat(string, "{991643}"LEVEL1NAME"(1) Commands:\n");
			strcat(string, "{FFFFFF}/vsay /healme /armourme\n");
			strcat(string, "{FFFFFF}/vflip{656565}(vehicle) {FFFFFF}/vfix /vveh{656565}(1, 2, 3, 4)\n");
			strcat(string, "{FFFFFF}/myw{656565}(eather) {FFFFFF}/myt{656565}(ime)\n");
			strcat(string, "{FFFFFF}Use '# text' as VIP Chat\n\n");

			strcat(string, "{991643}"LEVEL2NAME"(2) Commands:\n");
			strcat(string, "{FFF2E7}* Access to level "LEVEL1NAME"(1) commands.\n");
			strcat(string, "{FFFFFF}/mypos{656565}(0, 1, 2) {FFFFFF}/myskin{656565}(0 to 310)\n");
			strcat(string, "{FFFFFF}/vnos{656565}(/vnitros) {FFFFFF}/vcolor /vheli{656565}(1, 2, 3, 4, 5, 6)\n\n");
		}
		if(pInfo[playerid][pVipLevel] == 3)
		{
			strcat(string, "{991643}"LEVEL1NAME"(1) Commands:\n");
			strcat(string, "{FFFFFF}/vsay /healme /armourme\n");
			strcat(string, "{FFFFFF}/vflip{656565}(vehicle) {FFFFFF}/vfix /vveh{656565}(1, 2, 3, 4)\n");
			strcat(string, "{FFFFFF}/myw{656565}(eather) {FFFFFF}/myt{656565}(ime)\n");
			strcat(string, "{FFFFFF}Use '# text' as VIP Chat\n\n");

			strcat(string, "{991643}"LEVEL2NAME"(2) Commands:\n");
			strcat(string, "{FFF2E7}* Access to level "LEVEL1NAME"(1) commands.\n");
			strcat(string, "{FFFFFF}/mypos{656565}(0, 1, 2) {FFFFFF}/myskin{656565}(0 to 310)\n");
			strcat(string, "{FFFFFF}/vnos{656565}(/vnitros) {FFFFFF}/vcolor /vheli{656565}(1, 2, 3, 4, 5, 6)\n\n");

			strcat(string, "{991643}"LEVEL3NAME"(3) Commands:\n");
			strcat(string, "{FFF2E7}* Access to level "LEVEL1NAME"(1) and "LEVEL2NAME"(2) commands.\n");
			strcat(string, "{FFFFFF}/vsaveveh{656565}(icle) {FFFFFF}/vloadveh{656565}(icle) /vjp{656565}(/vjetpack)\n");
		}
		ShowPlayerDialog(playerid, MAXGMDIALOG+3 ,DIALOG_STYLE_MSGBOX,"V.I.P Commands", string, "Close","");
 	} else SendClientMessage(playerid, -1, NO_VIP_ERROR);
	return 1;
}

/*============================================================================*/
#if VSAY_CMD == true
CMD:vsay(playerid, params[])
{
	if(pInfo[playerid][pVipLevel] >= 1)
	{
		new string[128], name[24];
		if(sscanf(params, "s[128]", string)) return ShadInfoBoxForPlayer(playerid, "~B~~H~SYNTAX~W~:~N~~Y~/VSAY <TEXT>~N~~G~EXAMPLE: /VSAY Hi all!");
		GetPlayerName(playerid, name ,sizeof(name));
		format(string, sizeof(string), VSAYTEXT, name, playerid, params);
		SendClientMessageToAll(GetPlayerColor(playerid), string);
	} else SendClientMessage(playerid, -1, NO_VIP_ERROR);
    return 1;
}
#endif

CMD:vheal(playerid, params[]) return cmd_healme(playerid, params);
CMD:healme(playerid, params[])
{
	if(sprotection[playerid] == 0)
	{
	    if(pInfo[playerid][pVipLevel] >= 1)
		{
			if(hpabuse[playerid] == 0)
			{
				if(hprotection[playerid] == 1)
				{
					if(pInfo[playerid][pVipLevel] == 1)
					{
						ShadInfoBoxForPlayer(playerid, "~G~~H~SUCCESS~N~~Y~HEALTH RESTORED!");
						SetPlayerHealth(playerid, LVL1HEALTH);
     					hprotection[playerid] = 0;
						SendTextToAdmin(playerid, "HEALME");
					}
					else if(pInfo[playerid][pVipLevel] == 2)
					{
   						ShadInfoBoxForPlayer(playerid, "~G~~H~SUCCESS~N~~Y~HEALTH RESTORED!");
						SetPlayerHealth(playerid, LVL2HEALTH);
						hprotection[playerid] = 0;
						SendTextToAdmin(playerid, "HEALME");
					}
					else if(pInfo[playerid][pVipLevel] == 3)
					{
      					ShadInfoBoxForPlayer(playerid, "~G~~H~SUCCESS~N~~Y~HEALTH RESTORED!");
						SetPlayerHealth(playerid, LVL3HEALTH);
						hprotection[playerid] = 0;
						SendTextToAdmin(playerid, "HEALME");
					}
				} else return ShadInfoBoxForPlayer(playerid, PERDEATHERROR);
			} else SendClientMessage(playerid, -1, ABUSEERROR);
		} else SendClientMessage(playerid, -1, NO_VIP_ERROR);
	} else SendClientMessage(playerid, -1, NOT_PROCESSED_ERROR);
 	return 1;
}

CMD:varmour(playerid, params[]) return cmd_armourme(playerid, params);
CMD:armourme(playerid, params[])
{
	if(sprotection[playerid] == 0)
	{
	    if(pInfo[playerid][pVipLevel] >= 1)
		{
			if(hpabuse[playerid] == 0)
			{
				if(aprotection[playerid] == 0)
				{
					if(pInfo[playerid][pVipLevel] == 1)
					{
      					ShadInfoBoxForPlayer(playerid, "~G~~H~SUCCESS~N~~Y~ARMOUR RESTORED!");
						SetPlayerArmour(playerid, LVL1ARMOUR);
						aprotection[playerid] = 1;
						SendTextToAdmin(playerid, "ARMOURME");
					}
					else if(pInfo[playerid][pVipLevel] == 3)
					{
      					ShadInfoBoxForPlayer(playerid, "~G~~H~SUCCESS~N~~Y~ARMOUR RESTORED!");
						SetPlayerArmour(playerid, LVL2ARMOUR);
						aprotection[playerid] = 1;
						SendTextToAdmin(playerid, "ARMOURME");
					}
					else if(pInfo[playerid][pVipLevel] == 3)
					{
      					ShadInfoBoxForPlayer(playerid, "~G~~H~SUCCESS~N~~Y~ARMOUR RESTORED!");
						SetPlayerArmour(playerid, LVL3ARMOUR);
						aprotection[playerid] = 1;
						SendTextToAdmin(playerid, "ARMOURME");
					}
				} else return ShadInfoBoxForPlayer(playerid, PERDEATHERROR);
			} else SendClientMessage(playerid, -1, ABUSEERROR);
		} else SendClientMessage(playerid, -1, NO_VIP_ERROR);
	} else SendClientMessage(playerid, -1, NOT_PROCESSED_ERROR);
    return 1;
}
CMD:vveh(playerid, params[])
{
    if(pInfo[playerid][pVipLevel] >= 3)
	{
 		if(!IsPlayerInAnyVehicle(playerid))
   	    {
			new vid;
			if(sscanf(params, "i", vid)) return ShadInfoBoxForPlayer(playerid, "~B~~H~SYNTAX~W~:~N~~Y~/SavedVehicle <1 TO 4>~N~~G~1 ~w~= ~y~BULLET~N~~G~2 ~w~= ~y~NRG~N~~G~3 ~w~= ~y~JETMAX~N~~G~4 ~w~= ~y~BMX~N~~G~5 ~w~= ~y~MAVERICK~N~~G~6 ~w~= ~y~STUNT PLANE");
			if(vid < 1 || vid > 6) return ShadInfoBoxForPlayer(playerid, "~r~~H~ERROR~W~:~N~~Y~INVALID VALUE~N~~N~~G~VEHICLE PERIMETER: 1 TO 6");
			switch(vid)
			{
				case 1:
				{
					new Float:x, Float:y, Float:z, Float:Angle, name[24];
					GetPlayerPos(playerid, x, y, z);
					GetPlayerFacingAngle(playerid, Angle);
				    GetPlayerName(playerid, name, sizeof(name));

					DestroyVeh(playerid);

				    vscar[playerid] = 1;
					vehicle_id = CreateVehicle(541, x, y, z, Angle, 0,1, 120 );
	    			//PutPlayerInVehicle(playerid, vehicle_id, 0);
					ShadInfoBoxForPlayer(playerid, "~G~~H~SUCCESS:~N~~Y~BULLET CAR SPAWNED!");
					SendTextToAdmin(playerid, "VVEH(BULLET)");
				}
				case 2:
				{
					new Float:x, Float:y, Float:z, Float:Angle, name[24];
					GetPlayerPos(playerid, x, y, z);
					GetPlayerFacingAngle(playerid, Angle);
					GetPlayerName(playerid, name, sizeof(name));

					DestroyVeh(playerid);

					vscar[playerid] = 1;
					vehicle_id = CreateVehicle(522, x, y, z, Angle, 0,0, 120 );
					//PutPlayerInVehicle(playerid, vehicle_id, 0);
					ShadInfoBoxForPlayer(playerid, "~G~~H~SUCCESS~N~~Y~NRG MOTORBIKE SPAWNED!");
					SendTextToAdmin(playerid, "VVEH2(NRG500)");
				}
				case 3:
				{
					new Float:x, Float:y, Float:z, Float:Angle, name[24];
					GetPlayerPos(playerid, x, y, z);
					GetPlayerFacingAngle(playerid, Angle);
				    GetPlayerName(playerid, name, sizeof(name));

					DestroyVeh(playerid);

				    vscar[playerid] = 1;
				    vehicle_id = CreateVehicle(446, x, y, z, Angle, 0,1, 120 );
		   			//PutPlayerInVehicle(playerid, vehicle_id, 0);
					ShadInfoBoxForPlayer(playerid, "~G~~H~SUCCESS:~N~ ~Y~JETMAX BOAT SPAWNED!");
					SendTextToAdmin(playerid, "VVEH3(JETMAX)");
				}
				case 4:
				{
					new Float:x, Float:y, Float:z, Float:Angle, name[24];
					GetPlayerPos(playerid, x, y, z);
					GetPlayerFacingAngle(playerid, Angle);
				    GetPlayerName(playerid, name, sizeof(name));

					DestroyVeh(playerid);

				    vscar[playerid] = 1;
					vehicle_id = CreateVehicle(481, x, y, z, Angle, 0,1, 120 );
					//PutPlayerInVehicle(playerid, vehicle_id, 0);
					ShadInfoBoxForPlayer(playerid, "~G~~H~SUCCESS:~N~ ~Y~BMX BIKE SPAWNED!");
					SendTextToAdmin(playerid, "VVEH4(BMX)");
				}
				case 5:
				{
					new Float:x, Float:y, Float:z, Float:Angle, name[24];
					GetPlayerPos(playerid, x, y, z);
					GetPlayerFacingAngle(playerid, Angle);
				    GetPlayerName(playerid, name, sizeof(name));

					DestroyVeh(playerid);

				    vscar[playerid] = 1;
					vehicle_id = CreateVehicle(487, x, y, z, Angle, 0,1, 120 );
					//PutPlayerInVehicle(playerid, vehicle_id, 0);
					ShadInfoBoxForPlayer(playerid, "~G~~H~SUCCESS:~N~ ~Y~HELICOPTER SPAWNED!");
					SendTextToAdmin(playerid, "VVEH5(MAVERICK)");
				}
				case 6:
				{
					new Float:x, Float:y, Float:z, Float:Angle, name[24];
					GetPlayerPos(playerid, x, y, z);
					GetPlayerFacingAngle(playerid, Angle);
				    GetPlayerName(playerid, name, sizeof(name));

					DestroyVeh(playerid);

				    vscar[playerid] = 1;
					vehicle_id = CreateVehicle(513, x, y, z, Angle, 0,1, 120 );
					//PutPlayerInVehicle(playerid, vehicle_id, 0);
					ShadInfoBoxForPlayer(playerid, "~G~~H~SUCCESS:~N~ ~Y~PLANE SPAWNED!");
					SendTextToAdmin(playerid, "VVEH6(STUNT PLANE)");
				}
			}
		} else ShadInfoBoxForPlayer(playerid, VEH_EXIST_ERROR);
	} else SendClientMessage(playerid, -1, NO_VIP_ERROR);
    return 1;
}


CMD:flipvehicle(playerid, params[]) return cmd_vflip(playerid, params);
CMD:vflip(playerid, params[])
{
    if(pInfo[playerid][pVipLevel] >= 1)
	{
	    if(IsPlayerInAnyVehicle(playerid))
		{
			new VehicleID, Float:X, Float:Y, Float:Z, Float:Angle;
			GetPlayerPos(playerid, X, Y, Z);
			VehicleID = GetPlayerVehicleID(playerid);
			GetVehicleZAngle(VehicleID, Angle);
			SetVehiclePos(VehicleID, X, Y, Z);
			SetVehicleZAngle(VehicleID, Angle);
			ShadInfoBoxForPlayer(playerid, "~G~~H~SUCCESS~N~~Y~VEHICLE FLIPPED!");
			SendTextToAdmin(playerid,"VFLIP(/FLIPVEHICLE)");
		} else ShadInfoBoxForPlayer(playerid, "~r~~H~ERROR~W~:~N~~Y~YOU'RE NOT IN VEHICLE!");
	} else SendClientMessage(playerid, -1, NO_VIP_ERROR);
	return 1;
}

CMD:myw(playerid, params[]) return cmd_myweather(playerid, params);
CMD:myweather(playerid, params[])
{
    if(pInfo[playerid][pVipLevel] >= 1)
	{
	    new wid, string[250];
		if(sscanf(params, "i", wid)) return ShadInfoBoxForPlayer(playerid, "~B~~H~SYNTAX~W~:~N~~Y~/MYW(EATHER) <1 TO 44>");
		if(wid < 1 || wid > 44) return ShadInfoBoxForPlayer(playerid, "~r~~H~ERROR~W~:~N~~Y~INVALID VALUE~N~~N~~G~WEATHER PERIMETER: 1 TO 44");
		SetWeather(wid);
		format(string, sizeof(string), "~G~~H~SUCCESS:~N~ ~Y~WEATHER CHANGED! (%i)", wid);
        ShadInfoBoxForPlayer(playerid, string);
	} else SendClientMessage(playerid, -1, NO_VIP_ERROR);
    return 1;
}

CMD:myt(playerid, params[]) return cmd_mytime(playerid, params);
CMD:mytime(playerid, params[])
{
	if(pInfo[playerid][pVipLevel] >= 1)
	{
		new hour, minute, string[250];
		if(sscanf(params, "i", hour)) return ShadInfoBoxForPlayer(playerid, "~B~~H~SYNTAX~W~:~N~~Y~/MYTIME <0 TO 23>~N~/MYT <0 TO 23>");
		if(sscanf(params, "i", minute)) return ShadInfoBoxForPlayer(playerid, "~B~~H~SYNTAX~W~:~N~~Y~/MYTIME <0 TO 23>~N~/MYT <0 TO 23>");
		if(hour < 0 || hour > 23) return ShadInfoBoxForPlayer(playerid, "~R~~H~ERROR~W~: ~Y~CHOOSE HOUR(S) BETWEEN 0 TO 23!");
		if(minute < 0 || minute > 60) return ShadInfoBoxForPlayer(playerid, "~R~~H~ERROR~W~: ~Y~CHOOSE MINUTE(S) BETWEEN 0 TO 60!");
		format(string, sizeof(string), "~G~~H~SUCCESS~N~~Y~TIME CHANGED! (%02d:%02d)", hour, minute);
		ShadInfoBoxForPlayer(playerid, string);
		SetPlayerTime(playerid, hour, minute);
	} else SendClientMessage(playerid, -1, NO_VIP_ERROR);
    return 1;
}

CMD:vehfix(playerid, params[]) return cmd_vfix(playerid, params);
CMD:vfix(playerid, params[])
{
    if(pInfo[playerid][pVipLevel] >= 1)
	{
		if(!IsPlayerInAnyVehicle(playerid)) return ShadInfoBoxForPlayer(playerid, "~r~~H~ERROR:~W~:~N~~Y~YOU'RE NOT IN VEHICLE!");
		RepairVehicle(GetPlayerVehicleID(playerid));
		ShadInfoBoxForPlayer(playerid, "~G~~H~SUCCESS:~N~ ~Y~VEHICLE FIXED!");
		SendTextToAdmin(playerid, "VFIX(/VEHFIX)");
	} else SendClientMessage(playerid, -1, NO_VIP_ERROR);
    return 1;
}

/*============================================================================*/
CMD:vnitro(playerid, params[]) return cmd_vnos(playerid, params);
CMD:vnos(playerid, params[])
{
    if(pInfo[playerid][pVipLevel] >= 2)
	{
		if(!IsPlayerInAnyVehicle(playerid)) return ShadInfoBoxForPlayer(playerid, "~r~~H~ERROR:~W~:~N~~Y~YOU'RE NOT IN VEHICLE!");
	  	AddVehicleComponent(GetPlayerVehicleID(playerid), 1010);
  		ShadInfoBoxForPlayer(playerid, "~G~~H~SUCCESS:~N~ ~Y~NITROS ADDED!");
    	SendTextToAdmin(playerid, "NITRO");
	} else SendClientMessage(playerid, -1, NO_VIP_ERROR);
	return 1;
}

CMD:vcolor(playerid, params[])
{
    if(pInfo[playerid][pVipLevel] >= 2)
	{
		new ColorID, ColorID2, vehicleid;
		new string[250];
		if(!IsPlayerInAnyVehicle(playerid)) return ShadInfoBoxForPlayer(playerid, "~r~~H~ERROR:~W~:~N~~Y~YOU'RE NOT IN VEHICLE!");
	    if(sscanf(params, "dd", ColorID,ColorID2)) return ShadInfoBoxForPlayer(playerid, "~B~~H~SYNTAX~W~:~N~~Y~/VCOLOR <C1> <C2>~N~~N~~G~COLORS PERIMETER: 0 TO 126");
	    else if(ColorID < 0 || ColorID > 126) return ShadInfoBoxForPlayer(playerid, "~r~~H~ERROR~W~:~N~~Y~INVALID VALUE(C1)~N~~N~~G~COLORS PERIMETER: 0 TO 126");
	    else if(ColorID2 < 0 || ColorID2 > 126) return ShadInfoBoxForPlayer(playerid, "~r~~H~ERROR~W~:~N~~Y~INVALID VALUE(C2)~N~~N~~G~COLORS PERIMETER: 0 TO 126");
	    else
	    {
	        vehicleid = GetPlayerVehicleID(playerid);
	        ChangeVehicleColor(vehicleid, ColorID, ColorID2);
	        format(string, sizeof(string), "~G~~H~SUCCESS:~N~~Y~VEHICLE COLOR CHANGED! (%i,%i)", ColorID, ColorID2);
        	ShadInfoBoxForPlayer(playerid, string);
		}
	} else SendClientMessage(playerid, -1, NO_VIP_ERROR);
    return 1;
}

CMD:vheli(playerid, params[])
{
    if(pInfo[playerid][pVipLevel] >= 3)
	{
 		if(!IsPlayerInAnyVehicle(playerid))
   	    {
			new vid;
			if(sscanf(params, "i", vid)) return ShadInfoBoxForPlayer(playerid, "~B~~H~SYNTAX~W~:~N~~Y~/VHELI <1 TO 6>~N~~G~1 ~w~= ~y~LEVIATHAN~N~~G~2 ~w~= ~y~HUNTER~N~~G~3 ~w~= ~y~SEA SPARROW~N~~G~4 ~w~= ~y~MAVERICK~N~~G~5 ~w~= ~y~CARGOBOB~N~~G~6 ~w~= ~y~RAINDANCE");
			if(vid < 1 || vid > 6) return ShadInfoBoxForPlayer(playerid, "~r~~H~ERROR~W~:~N~~Y~INVALID VALUE~N~~N~~G~VEHICLE PERIMETER: 0 TO 6");
			switch(vid)
			{
				case 1:
				{
					new Float:x, Float:y, Float:z, Float:Angle, name[24];
					GetPlayerPos(playerid, x, y, z);
					GetPlayerFacingAngle(playerid, Angle);
				    GetPlayerName(playerid, name, sizeof(name));

					DestroyVeh(playerid);

				    vscar[playerid] = 1;
					vehicle_id = CreateVehicle(417, x, y, z, Angle, 0,0, 120);
					//PutPlayerInVehicle(playerid, vehicle_id, 0);
					ShadInfoBoxForPlayer(playerid, "~G~~H~SUCCESS~N~~Y~LEVIATHAN SPAWNED!");
					SendTextToAdmin(playerid, "VHELI1(LEVIATHAN");
				}
				case 2:
				{
					new Float:x, Float:y, Float:z, Float:Angle, name[24];
					GetPlayerPos(playerid, x, y, z);
					GetPlayerFacingAngle(playerid, Angle);
				    GetPlayerName(playerid, name, sizeof(name));

					DestroyVeh(playerid);

				    vscar[playerid] = 1;
					vehicle_id = CreateVehicle(425, x, y, z, Angle, 0,0, 120);
					//PutPlayerInVehicle(playerid, vehicle_id, 0);
					ShadInfoBoxForPlayer(playerid, "~G~~H~SUCCESS~N~~Y~HUNTER SPAWNED!");
					SendTextToAdmin(playerid, "VHELI2(HUNTER)");
				}
				case 3:
				{
					new Float:x, Float:y, Float:z, Float:Angle, name[24];
					GetPlayerPos(playerid, x, y, z);
					GetPlayerFacingAngle(playerid, Angle);
				    GetPlayerName(playerid, name, sizeof(name));

					DestroyVeh(playerid);

				    vscar[playerid] = 1;
					vehicle_id = CreateVehicle(447, x, y, z, Angle, 0,0, 120);
					//PutPlayerInVehicle(playerid, vehicle_id, 0);
					ShadInfoBoxForPlayer(playerid, "~G~~H~SUCCESS~N~~Y~SEASPARROW SPAWNED!");
					SendTextToAdmin(playerid, "VHELI3(SEASPARROW)");
				}
				case 4:
				{
					new Float:x, Float:y, Float:z, Float:Angle, name[24];
					GetPlayerPos(playerid, x, y, z);
					GetPlayerFacingAngle(playerid, Angle);
				    GetPlayerName(playerid, name, sizeof(name));

					DestroyVeh(playerid);

				    vscar[playerid] = 1;
					vehicle_id = CreateVehicle(487, x, y, z, Angle, 0,0, 120);
					//PutPlayerInVehicle(playerid, vehicle_id, 0);
					ShadInfoBoxForPlayer(playerid, "~G~~H~SUCCESS~N~~Y~MAVERICK SPAWNED!");
					SendTextToAdmin(playerid, "VHELI4(MAVERICK)");
				}
				case 5:
				{
					new Float:x, Float:y, Float:z, Float:Angle, name[24];
					GetPlayerPos(playerid, x, y, z);
					GetPlayerFacingAngle(playerid, Angle);
				    GetPlayerName(playerid, name, sizeof(name));

					DestroyVeh(playerid);

				    vscar[playerid] = 1;
					vehicle_id = CreateVehicle(548, x, y, z, Angle, 0,0, 120);
					//PutPlayerInVehicle(playerid, vehicle_id, 0);
					ShadInfoBoxForPlayer(playerid, "~G~~H~SUCCESS~N~~Y~CARGOBOB SPAWNED!");
					SendTextToAdmin(playerid, "VHELI5(CARGOBOB)");
				}
				case 6:
				{
					new Float:x, Float:y, Float:z, Float:Angle, name[24];
					GetPlayerPos(playerid, x, y, z);
					GetPlayerFacingAngle(playerid, Angle);
				    GetPlayerName(playerid, name, sizeof(name));

					DestroyVeh(playerid);

				    vscar[playerid] = 1;
					vehicle_id = CreateVehicle(563, x, y, z, Angle, 0,0, 120);
					//PutPlayerInVehicle(playerid, vehicle_id, 0);
					ShadInfoBoxForPlayer(playerid, "~G~~H~SUCCESS~N~~Y~RAINDANCE SPAWNED!");
					SendTextToAdmin(playerid, "VHELI6(RAINDANCE)");
				}
			}
		} else ShadInfoBoxForPlayer(playerid, VEH_EXIST_ERROR);
	} else SendClientMessage(playerid, -1, NO_VIP_ERROR);
    return 1;
}

CMD:mypos(playerid, params[])
{
	new pos;
	if(sscanf(params, "u", pos)) return ShadInfoBoxForPlayer(playerid, "~B~~H~SYNTAX~W~:~N~~Y~/MYPOS <SAVE/LOAD/DELETE>");
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

			SaveStats(playerid);

			ShadInfoBoxForPlayer(playerid, "~G~~H~SUCCESS~N~~Y~POSITION SAVED!~N~~G~/MYPOS LOAD");
		} else ShadInfoBoxForPlayer(playerid, "~r~~H~ERROR~W~:~N~~Y~YOU ALREADY SAVED ONE POSITION!~N~~Y~/MYPOS DELETE");
	}
    else if(!strcmp(params,"load",true))
    {
		if(pInfo[playerid][SavedPos] == true)
		{
			SetPlayerPos(playerid, pInfo[playerid][Xpos], pInfo[playerid][Ypos], pInfo[playerid][Zpos]+0.3);
			SetPlayerVirtualWorld(playerid, pInfo[playerid][Vw]);
			SetPlayerInterior(playerid, pInfo[playerid][Int]);
			ShadInfoBoxForPlayer(playerid, "~G~~H~SUCCESS~N~~Y~TELEPORTED TO POSTION");
		} else ShadInfoBoxForPlayer(playerid, "~r~~H~ERROR~W~:~N~~Y~YOU DIDN'T SAVE ANY POSITION!~N~/MYPOS SAVE");
	}
 	else if(!strcmp(params,"delete",true))
    {
    	if(pInfo[playerid][SavedPos] == true)
		{
		    pInfo[playerid][SavedPos] = false;
			new INI:File = INI_Open(UserPath(playerid));
			INI_SetTag(File,"PositionData");
			INI_WriteInt(File, "Interior", 0);
			INI_WriteInt(File, "VirtualWorld", 0);
			INI_WriteFloat(File, "Angle", 0);
			INI_WriteFloat(File, "Xpos", 0);
			INI_WriteFloat(File, "Ypos", 0);
			INI_WriteFloat(File, "Zpos", 0);
			INI_WriteBool(File, "Saved", pInfo[playerid][SavedPos]);
			INI_Close(File);

			ShadInfoBoxForPlayer(playerid, "~G~~H~SUCCESS~N~~Y~POSITION DELETED!");
		} else ShadInfoBoxForPlayer(playerid, "~r~~H~ERROR~W~:~N~~Y~YOU DIDN'T SAVE ANY POSITION!~N~/MYPOS SAVE");
 	}
	return 1;
}

CMD:myskin(playerid, params[])
{
    if(pInfo[playerid][pVipLevel] >= 1)
    {
        if(IsNull(params)) return ShadInfoBoxForPlayer(playerid, "~B~~H~SYNTAX~W~:~N~~Y~/MYSKIN <0 TO 310>~N~~G~~H~true = LOAD~N~~R~~H~false = DELETE");
        if(!strcmp(params,"true",true))
        {
            if(pInfo[playerid][SavedSkin] == false)
            {
                pInfo[playerid][SavedSkin] = true;
                SetPlayerSkin(playerid, pInfo[playerid][pSkin]);
                ShadInfoBoxForPlayer(playerid, "~G~~H~SUCCESS~N~~Y~SKIN LOADED!");
            } else ShadInfoBoxForPlayer(playerid, "~r~~H~ERROR~W~:~N~~Y~YOU DIDN'T SAVE ANY SKIN!");
        }
        else if(!strcmp(params,"false",true))
        {
            if(pInfo[playerid][SavedSkin] == true)
            {
                pInfo[playerid][SavedSkin] = false;
                ShadInfoBoxForPlayer(playerid, "~G~~H~SUCCESS~N~~Y~SKIN DELETED!");
            }
            else ShadInfoBoxForPlayer(playerid, "~r~~H~ERROR~W~:~N~~Y~YOU DIDN'T SAVE ANY SKIN!");
        }
        else if(IsNumeric(params))
        {
            new skinid=strval(params);
            if(skinid < 0 || skinid > 310) return ShadInfoBoxForPlayer(playerid, "~r~~H~ERROR~W~:~N~~Y~INVALID VALUE~N~~N~~G~SKIN PERIMETER: 0 TO 310");
            pInfo[playerid][SavedSkin] = true;
            pInfo[playerid][pSkin] = skinid;
            SetPlayerSkin(playerid, skinid);
            ShadInfoBoxForPlayer(playerid, "~G~~H~SUCCESS~N~~Y~SKIN SAVED!~n~~G~AUTO SET ON SPAWN!");
        }
        else return ShadInfoBoxForPlayer(playerid, "~B~~H~SYNTAX~W~:~N~~Y~/MYSKIN <0 TO 310>~N~~G~~H~true = LOAD~N~~R~~H~false = DELETE");
    } else ShadInfoBoxForPlayer(playerid, NO_VIP_ERROR);
    return 1;
}
/*============================================================================*/
CMD:vjp(playerid, params[]) return cmd_vjetpack(playerid, params);
CMD:vjetpack(playerid, params[])
{
    if(pInfo[playerid][pVipLevel] >= 3)
	{
		SetPlayerSpecialAction(playerid, 2);
		SendTextToAdmin(playerid, "VJP(/VJETPACK)");
		ShadInfoBoxForPlayer(playerid, "~G~~H~SUCCESS~N~~Y~JETPACK SPAWNED!");
	} else SendClientMessage(playerid, -1, NO_VIP_ERROR);
	return 1;
}

CMD:vsaveveh(playerid, params[]) return cmd_vsavevehicle (playerid, params);
CMD:vsavevehicle(playerid, params[])
{
    if(pInfo[playerid][pVipLevel] >= 3)
	{
		new carid;
		if(sscanf(params, "d", carid)) return ShadInfoBoxForPlayer(playerid, "~B~~H~SYNTAX~W~:~N~~Y~/VSAVEVEH(ICLE) <ID>~N~~G~PERIMETER~W~:~N~~Y~400 TO 611");
		if(carid < 400 || carid > 611) return ShadInfoBoxForPlayer(playerid, "~r~~H~ERROR~W~:~N~~Y~INVALID VALUE~N~~N~~G~VEHICLE PERIMETER~W~:~N~~Y~ 400 TO 611");
		{
			pInfo[playerid][pVeh] = carid;
			SaveStats(playerid);
			ShadInfoBoxForPlayer(playerid, "~G~~H~SUCCESS~N~~Y~VEHICLE SAVED!~N~~G~~H~/VLOADVEH(ICLE) TO SPAWN.");
		}
	} else SendClientMessage(playerid, -1, NO_VIP_ERROR);
	return 1;
}

CMD:vloadveh(playerid, params[]) return cmd_vloadvehicle (playerid, params);
CMD:vloadvehicle(playerid, params[])
{
    if(pInfo[playerid][pVipLevel] >= 3)
	{
		new Float:x, Float:y, Float:z, Float:Angle, name[24];
		GetPlayerPos(playerid, x, y, z);
		GetPlayerFacingAngle(playerid, Angle);
	    GetPlayerName(playerid, name, sizeof(name));

		DestroyVeh(playerid);

	    vscar[playerid] = 1;
		jprotection[playerid] = 1;

		vehicle_id = CreateVehicle(pInfo[playerid][pVeh], x, y, z, Angle, 0,0, 120);
		pInfo[vehicle_id][vOwner] = playerid;
		//PutPlayerInVehicle(playerid, vehicle_id, 0);
		if(vehicle_id == 448 || 461 || 462 || 463 || 468 || 471 || 509 || 510 || 521 || 522 || 523 || 581 || 586 || 449)
		{
		    return 1;
		}
		else
		{
			AddVehicleComponent(vehicle_id, 1010);
		}
		ShadInfoBoxForPlayer(playerid, "~G~~H~SUCCESS~N~~Y~VEHICLE SPAWNED!");
		SendTextToAdmin(playerid, "VLOADVEH");
	} else SendClientMessage(playerid, -1, NO_VIP_ERROR);
	return 1;
}
/*============================================================================*/
forward Processed(playerid);
public Processed(playerid)
{
	if(pInfo[playerid][pVipLevel] == 3)
	{
	    #if defined SHOWVIPHEADTAG
		new Text3D:label = Create3DTextLabel(""VIPHEADTAG"(3)", COLOR_VIPHEADTAG,30.0,40.0,50.0,40.0,-1,0);
		Attach3DTextLabelToPlayer(label, playerid, 0,0,0.5);
		#endif

        SetPlayerArmour(playerid, LVL3ARMOUR);
        SetPlayerHealth(playerid, LVL3HEALTH);

		new ammo, weaponid;
		for (new i = 0; i <= 12; i++)
		{
		    GetPlayerWeaponData(playerid, i, weaponid, ammo);
		    SetPlayerAmmo(playerid, weaponid, ammo+LVL3SPAWNAMMO);
		}
        SetPlayerSkillLevel(playerid, WEAPONSKILL_PISTOL, 999);
        SetPlayerSkillLevel(playerid, WEAPONSKILL_PISTOL_SILENCED, 999);
        SetPlayerSkillLevel(playerid, WEAPONSKILL_DESERT_EAGLE, 999);
        SetPlayerSkillLevel(playerid, WEAPONSKILL_SHOTGUN, 999);
        SetPlayerSkillLevel(playerid, WEAPONSKILL_SAWNOFF_SHOTGUN, 999);
        SetPlayerSkillLevel(playerid, WEAPONSKILL_SPAS12_SHOTGUN, 999);
        SetPlayerSkillLevel(playerid, WEAPONSKILL_MICRO_UZI, 999);
        SetPlayerSkillLevel(playerid, WEAPONSKILL_MP5, 999);
        SetPlayerSkillLevel(playerid, WEAPONSKILL_AK47, 999);
        SetPlayerSkillLevel(playerid, WEAPONSKILL_M4, 999);
        SetPlayerSkillLevel(playerid, WEAPONSKILL_SNIPERRIFLE, 999);
        new info[300];
        format(info, sizeof(info), "~g~~h~~h~~h~SPAWN INFO~n~~n~~r~Health: ~y~%d (Non-VIP: %d)~n~~w~Armour: ~y~%d (Non-VIP: %d)~n~~g~Weapon Ammo: ~y~+%d~n~~b~~h~Skin ID: ~y~%d~n~~g~~h~~h~Invisible on map!",LVL3HEALTH,NORMALPLAYERHEALTH,LVL3ARMOUR,NORMALPLAYERARMOUR,LVL3SPAWNAMMO,pInfo[playerid][pSkin]);
        ShadInfoBoxForPlayer(playerid, info);
        TogglePlayerControllable(playerid, true);
        SetPlayerSkin(playerid, pInfo[playerid][pSkin]);
        KillTimer(timer[playerid]);
        SetTimerEx("CloseTextdraw", 5000, true, "i", playerid);
        sprotection[playerid] = 0;
        for(new i; i < MAX_PLAYERS; i++)
		{
		    SetPlayerMarkerForPlayer(playerid, i, (GetPlayerColor(playerid) & 0xFFFFFF00));
		}
	}
	else if(pInfo[playerid][pVipLevel] == 2)
	{
	    #if defined SHOWVIPHEADTAG
		new Text3D:label = Create3DTextLabel(""VIPHEADTAG"(2)", COLOR_VIPHEADTAG,30.0,40.0,50.0,40.0,-1,0);
		Attach3DTextLabelToPlayer(label, playerid, 0,0,0.5);
		#endif

		SetPlayerArmour(playerid, LVL2ARMOUR);
		SetPlayerHealth(playerid, LVL2HEALTH);
		new ammo, weaponid;
		for (new i = 0; i <= 12; i++)
		{
		    GetPlayerWeaponData(playerid, i, weaponid, ammo);
		    SetPlayerAmmo(playerid, weaponid, ammo+LVL2SPAWNAMMO);
		}
		if(pInfo[playerid][SavedSkin] == true)
		{
		    new info[300];
		    format(info, sizeof(info), "~g~~h~~h~~h~SPAWN INFO~n~~n~~r~Health: ~y~%d (Non-VIP: %d)~n~~w~Armour: ~y~%d (Non-VIP: %d)~n~~g~Weapon Ammo: ~y~+%d~n~~b~~h~Skin ID: ~y~%d~n~~g~~h~~h~Invisible on map!",LVL2HEALTH,NORMALPLAYERHEALTH,LVL2ARMOUR,NORMALPLAYERARMOUR,LVL2SPAWNAMMO,pInfo[playerid][pSkin]);
   			ShadInfoBoxForPlayer(playerid, info);
			TogglePlayerControllable(playerid, true);
			SetPlayerSkin(playerid, pInfo[playerid][pSkin]);
		}
		else
		{
		    new info[300];
		    format(info, sizeof(info), "~g~~h~~h~~h~SPAWN INFO~n~~n~~r~Health: ~y~%d (Non-VIP: %d)~n~~w~Armour: ~y~%d (Non-VIP: %d)~n~~g~Weapon Ammo: ~y~+%d~n~~g~~h~~h~Invisible on map!",LVL2HEALTH,NORMALPLAYERHEALTH,LVL2ARMOUR,NORMALPLAYERARMOUR,LVL2SPAWNAMMO);
   			ShadInfoBoxForPlayer(playerid, info);
			TogglePlayerControllable(playerid, true);
			SetPlayerSkin(playerid, pInfo[playerid][pSkin]);
		}
		KillTimer(timer[playerid]);
		sprotection[playerid] = 0;
		SetTimerEx("CloseTextdraw", 5000, true, "i", playerid);
	}
	else if(pInfo[playerid][pVipLevel] == 1)
	{
	    #if defined SHOWVIPHEADTAG
		new Text3D:label = Create3DTextLabel(""VIPHEADTAG"(1)", COLOR_VIPHEADTAG,30.0,40.0,50.0,40.0,-1,0);
		Attach3DTextLabelToPlayer(label, playerid, 0,0,0.5);
		#endif

		SetPlayerArmour(playerid, LVL1ARMOUR);
		SetPlayerHealth(playerid, LVL1HEALTH);
		new ammo, weaponid;
		for (new i = 0; i <= 12; i++)
		{
		    GetPlayerWeaponData(playerid, i, weaponid, ammo);
		    SetPlayerAmmo(playerid, weaponid, ammo+LVL1SPAWNAMMO);
		}

        new info[300];
        format(info, sizeof(info), "~g~~h~~h~~h~SPAWN INFO~n~~n~~r~Health: ~y~%d (Non-VIP: %d)~n~~w~Armour: ~y~%d (Non-VIP: %d)~n~~g~Weapon Ammo: ~y~+%d~n~~b~~h~Skin ID: ~y~%d",LVL1HEALTH,NORMALPLAYERHEALTH,LVL1ARMOUR,NORMALPLAYERARMOUR,LVL1SPAWNAMMO,pInfo[playerid][pSkin]);
  		ShadInfoBoxForPlayer(playerid, info);
		TogglePlayerControllable(playerid, true);
		SetPlayerSkin(playerid, pInfo[playerid][pSkin]);
		KillTimer(timer[playerid]);
		sprotection[playerid] = 0;
		SetTimerEx("CloseTextdraw", 5000, true, "i", playerid);
	}
   	else if(pInfo[playerid][pVipLevel] == 0)
	{
		SetPlayerArmour(playerid, NORMALPLAYERARMOUR);
		SetPlayerHealth(playerid, NORMALPLAYERHEALTH);

        new info[250];
        format(info, sizeof(info), "~g~~h~~h~~h~SPAWN INFO~n~~n~~r~Health: ~y~%d~n~~w~Armour: ~y~%d",NORMALPLAYERHEALTH,NORMALPLAYERARMOUR);
		ShadInfoBoxForPlayer(playerid, info);
		TogglePlayerControllable(playerid, true);
		KillTimer(timer[playerid]);
		sprotection[playerid] = 0;
		SetTimerEx("CloseTextdraw", 5000, true, "i", playerid);
	}
    return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	return 0;
}

public OnPlayerTakeDamage(playerid, issuerid, Float:amount, weaponid)
{
 	if(issuerid != INVALID_PLAYER_ID)
	{
		SetTimerEx("hpabuse_cool", 10000, false, "i", playerid);
		hpabuse[playerid] = 1;
	}
    return 1;
}
/*============================================================================*/
IsNumeric(const string[])
{
    for (new i = 0, j = strlen(string); i < j; i++)
    {
        if (string[i] > '9' || string[i] < '0') return 0;
    }
    return 1;
}
/*============================================================================*/
forward DestroyVeh(playerid);
public DestroyVeh(playerid)
{
	new vehicleid;
    vehicleid = GetPlayerVehicleID(playerid);
    DestroyVehicle(vehicleid);
}

forward SaveStats(playerid);
public SaveStats(playerid)
{
	new INI:File = INI_Open(UserPath(playerid));
	INI_SetTag(File,"UserData");
	INI_WriteInt(File, "vLevel", pInfo[playerid][pVipLevel]);
	INI_WriteInt(File, "vTime", pInfo[playerid][pVipTime]);
	INI_SetTag(File,"VehicleData");
    INI_WriteInt(File, "SavedVehicle", pInfo[playerid][pVeh]);
	INI_SetTag(File,"PositionData");
    INI_WriteInt(File, "Interior", pInfo[playerid][Int]);
    INI_WriteInt(File, "VirtualWorld", pInfo[playerid][Vw]);
	INI_WriteFloat(File, "Angle", pInfo[playerid][Apos]);
	INI_WriteFloat(File, "Xpos", pInfo[playerid][Xpos]);
	INI_WriteFloat(File, "Ypos", pInfo[playerid][Ypos]);
	INI_WriteFloat(File, "Zpos", pInfo[playerid][Zpos]);
	INI_Close(File);
}

forward hpabuse_cool(playerid);
public hpabuse_cool(playerid)
{
    hpabuse[playerid] = 0;
    return 1;
}

forward SendTextToVIP(color,const string[]);
public SendTextToVIP(color,const string[])
{
	for(new i = 0; i < MAX_PLAYERS; i++)
	{
		if(IsPlayerConnected(i) == 1)
		if(pInfo[i][pVipLevel] >= 1)
		SendClientMessage(i, color, string);
	}
	return 1;
}
/*============================================================================*/
stock UserPath(playerid)
{
    new string[128], vname[MAX_PLAYER_NAME];
    GetPlayerName(playerid, vname, sizeof(vname));
    format(string, sizeof(string), VIPUSERPATH, vname);
    return string;
}

stock SendTextToAdmin(playerid, vipcmd[])
{
	for(new i = 0; i < MAX_PLAYERS; i++)
	{
		if(IsPlayerConnected(i) == 1)
		{
			if(IsPlayerAdmin(playerid))
			{
				new string[250], vipname[MAX_PLAYER_NAME];
			  	GetPlayerName(playerid, vipname, sizeof(vipname));
			  	format(string, sizeof(string), "{656565}RCON-MSG: %s(%d) has used the command '/%s'",vipname, playerid, vipcmd);
				SendClientMessage(playerid, -1, string);
				savelog("command",string);
			}
		}
	}
	return 1;
}

stock savelog(file[], string[])
{
	new Hour, Minute, Second, Day, Month, Year;
	getdate(Year, Month, Day);
	gettime(Hour,Minute,Second);
	new timestr[32], data[128];
	format(timestr,32,"[%02d/%02d/%d] @ [%02d:%02d:%02d]:",Day,Month,Year,Hour,Minute,Second);
	format(data, sizeof(data), "%s %s\r\n",timestr, string);
	new File:hFile, thefile[32];
	format(thefile, sizeof(thefile), LOGFILE, file);
    hFile = fopen(thefile, io_append);
    fwrite(hFile, data);
    fclose(hFile);
	return 1;
}
/*============================================================================*/
