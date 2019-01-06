/* Sample Script: V.I.P [MYSQL & ZCMD]
-» Release Date:       		06.02.2018
-» Description:        		V.I.P Script specially designed for TDM servers.
-» Saving System Used: 		MYSQL (by BlueG)
-» Command Processor Used:  	ZCMD (by Zeex)
-» Version:                 	0.9(Stable)
*/

/*============================================================================*/
// INCLUDES AND COLORS/COLOURS
#define FILTERSCRIPT
#include <a_samp>
#include <zcmd>
#include <sscanf2>
#include <a_mysql>
#include <foreach>

#define COLOR_VIP  			(0xF6BB0AA)
#define COLOR_DGRAY 			(0x808080FF)
/*============================================================================*/
/*CONFIGURATION*/

#define USE_MYSQL		  	true

#if USE_MYSQL == true
#define MYSQL_HOST        	"localhost" // Change this to your MySQL Remote IP or "localhost".
#define MYSQL_USER        	"root" // Change this to your MySQL Database username.
#define MYSQL_PASS        	"" // Change this to your MySQL Database password.
#define MYSQL_DATABASE    	"sVIP-Users" // Change this to your MySQL Database name.
#endif

//Change it to any symbol if you want VIP(s) to chat.
//How to chat as VIP in game: #Hi
#define VIPCHATKEY 			'#'
//NOTE: You can only use first %s as name here, %d as playerid here and %s as text. Also you can use the HTML colors here as default color is white.
#define VIPCHAT             "{B3343A}[VIP-CHAT]:{FFFFFF} %s(%d): %s"

//Set true/false if you want VIP(s) to use /vsay which can be seen by everyone i.e [VIP]: Siddharth(1): Hi
#define VSAY_CMD 			true

//Check the last dialog ID of your all filterscripts and gamemodes then put the last ID over here(in place of 9999).
#define MAXGMDIALOG         9999

//Edit these if you want your VIP's Level Name to be recognized by something else
#define LEVEL1NAME      	"Bronze VIP"
#define LEVEL2NAME      	"Silver VIP"
#define LEVEL3NAME       	"Gold VIP"

//Edit this if you want to change the label above the player or disable showing above their head
#define VIPHEADSHOW
#define	VIPHEADTAG       	"Very Important Player"
#define COLOR_VIPHEADTAG    	(0xFF0000AA) // Red Color

//Edit this if you want normal players to have less health and armour than VIP(s).
#define NORMALPLAYERHEALTH  		100
#define NORMALPLAYERARMOUR  		10

//NOTE: These will also apply where VIP use /healme and /armourme commands!
#define LVL1HEALTH  			100
#define LVLL1ARMOUR			40

#define LVL3HEALTH 			100
#define LVLL2ARMOUR 			50

#define LVL3HEALTH 			100
#define LVLL3ARMOUR 			100

//Edit this to give VIP players additional "x" amount of ammo to all weapons.
#define LVL1SPAWNAMMO     		200
#define LVL2SPAWNAMMO     		400
#define LVL3SPAWNAMMO     		600

//Edit this if you want to change the ERROR messages for those who try to access VIP commands.
#define VIPERROR 			"{FFFFFF}[{B3343A}ERROR{FFFFFF}]: You must buy VIP package from forum to use this command!"
#define RCONERROR 			"{FFFFFF}[{B3343A}ERROR{FFFFFF}]: You must be RCON Administrator to use this command!"
/*============================================================================*/
// VARIABLES
new vlevel[24];
new tune[MAX_PLAYERS];
new Text3D:vehicle3Dtext[MAX_VEHICLES],vehicle_id;
new o,ob2,ob3,ob4,ob5,ob6,ob7,ob8,ob9,ob10,ob11,ob12,ob13,ob14,ob15,ob16,ob17,ob18,ob19,ob20,ob21,ob22;

new spawntimer[MAX_PLAYERS];
new Anti_heal[MAX_PLAYERS];
new Anti_armour[MAX_PLAYERS];

new Text:ShadInfoBox;
new ShadInfoBoxShowing[MAX_PLAYERS];

new MySQL: Database, Corrupt_Check[MAX_PLAYERS];
/*============================================================================*/
// SAVING PLAYER DATA
enum pInfo
{
	pVipLevel,
	ID,
	Cache: Player_Cache
}
new PlayerInfo[MAX_PLAYERS][pInfo];
/*============================================================================*/

#if defined FILTERSCRIPT
public OnFilterScriptInit()
{
	print("_____________________________________________");
	print("sVIP (v1.0) (Stable Release)");
	print("SCRIPT: Loading...");
	print("SCRIPT: Loaded.");
	print("MYSQL: Connecting to the server...");
	new MySQLOpt: option_id = mysql_init_options();
	mysql_set_option(option_id, AUTO_RECONNECT, true);
	Database = mysql_connect(MYSQL_HOST, MYSQL_USER, MYSQL_PASS, MYSQL_DATABASE, option_id);

	if(Database == MYSQL_INVALID_HANDLE || mysql_errno(Database) != 0)
	{
		print("MYSQL: Couldn't connect to server, server is exiting.");
		SendRconCommand("exit");
		return 1;
	}
	print("MYSQL: Connected to Server.");
	mysql_tquery(Database, "CREATE TABLE IF NOT EXISTS `VIPUSERS` (`LEVEL` mediumint(7) NOT NULL DEFAULT '0')");
	print("_____________________________________________");
	
	ShadInfoBox = TextDrawCreate(36.000000, 144.000000, "___");
	TextDrawBackgroundColor(ShadInfoBox, 255);
	TextDrawFont(ShadInfoBox, 2);
	TextDrawLetterSize(ShadInfoBox, 0.250000, 1.099999);
	TextDrawColor(ShadInfoBox, -1);
	TextDrawSetOutline(ShadInfoBox, 0);
	TextDrawSetProportional(ShadInfoBox, 1);
	TextDrawSetShadow(ShadInfoBox, 1);
	TextDrawUseBox(ShadInfoBox, 1);
	TextDrawBoxColor(ShadInfoBox, 118);
	TextDrawTextSize(ShadInfoBox, 180.000000, 5.000000);
	return 1;
}

#endif
public OnFilterScriptExit()
{
	print("_____________________________________________");
	print("[V.I.P]: Script v1.0(Stable)");
	print("Unloaded!");
	print("_____________________________________________");
	return 1;
}

public OnPlayerConnect(playerid)
{
	Anti_heal[playerid] = 0;
	Anti_armour[playerid] = 0;
	
	new DB_Query[115];
	new vipname[MAX_PLAYER_NAME];
	GetPlayerName(playerid, vipname, sizeof(vipname));

	Corrupt_Check[playerid]++;
	mysql_format(Database, DB_Query, sizeof(DB_Query), "SELECT * FROM `PLAYERS` WHERE `USERNAME` = '%e' LIMIT 1", vipname);
	mysql_tquery(Database, DB_Query, "OnPlayerDataCheck", "ii", playerid, Corrupt_Check[playerid]);
	cache_get_value_int(0, "VIPLEVEL", PlayerInfo[playerid][pVipLevel]);
	if(PlayerInfo[playerid][pVipLevel] >=1)
	{
	    new string[250];
		new vname[MAX_PLAYER_NAME];
		GetPlayerName(playerid,vname,sizeof(vname));
	    format(string, sizeof(string), "~y~Welcome ~y~~h~~h~%s!~N~~y~ID: ~y~~h~~h~%d~w~~N~~y~LEVEL: ~y~~h~~h~%d", vname, playerid, PlayerInfo[playerid][pVipLevel]);
		ShadInfoBoxForPlayer(playerid, string);

		//format(string, sizeof(string), "[VIP]: %s(%d) has joined the server.", vname, playerid);
		//SendClientMessageToAll(-1, string);
	}
	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
	Corrupt_Check[playerid]++;

	new DB_Query[256];
	mysql_format(Database, DB_Query, sizeof(DB_Query), "UPDATE `PLAYERS` SET `VIPLEVEL` = %d WHERE `ID` = %d LIMIT 1", PlayerInfo[playerid][pVipLevel], PlayerInfo[playerid][ID]);
	mysql_tquery(Database, DB_Query);

	if(cache_is_valid(PlayerInfo[playerid][Player_Cache]))
	{
		cache_delete(PlayerInfo[playerid][Player_Cache]);
		PlayerInfo[playerid][Player_Cache] = MYSQL_INVALID_CACHE;
	}
	Anti_heal[playerid] = 0;
	Anti_armour[playerid] = 0;
 	new vehicleid;
    vehicleid= GetPlayerVehicleID(playerid);
    DestroyVehicle(vehicleid);
    TextDrawHideForPlayer(playerid, ShadInfoBox);
    TextDrawDestroy(ShadInfoBox);
	return 1;
}


public OnPlayerSpawn(playerid)
{
	Anti_heal[playerid] = 0;
	Anti_armour[playerid] = 0;
	if(PlayerInfo[playerid][pVipLevel] >=0)
	{
	 	TogglePlayerControllable(playerid, false);
	 	ShadInfoBoxForPlayer(playerid, "~g~~h~~h~~h~SPAWN INFO~n~~n~~y~Processing....");
	 	spawntimer[playerid] = SetTimerEx("Processed", 5000, true, "i", playerid);
	}
	new vehicleid;
	vehicleid= GetPlayerVehicleID(playerid);
	DestroyVehicle(vehicleid);
 	return 1;
}

public OnPlayerDeath(playerid, killerid, reason)
{
	Anti_heal[playerid] = 0;
	Anti_armour[playerid] = 0;
	new vehicleid;
	vehicleid= GetPlayerVehicleID(playerid);
	DestroyVehicle(vehicleid);
	return 1;
}

public OnPlayerText(playerid, text[])
{
	new name[24];
	if(text[0] == VIPCHATKEY && PlayerInfo[playerid][pVipLevel] >=1)
	{
		if(PlayerInfo[playerid][pVipLevel] == 1) { vlevel = ""LEVEL1NAME""; }
		else if(PlayerInfo[playerid][pVipLevel] == 2) { vlevel = ""LEVEL2NAME""; }
		else if(PlayerInfo[playerid][pVipLevel] == 3) { vlevel = ""LEVEL3NAME""; }
		new string[250];
		GetPlayerName(playerid,name,sizeof(name));
		format(string,sizeof(string),VIPCHAT,name, playerid, text[1]);
		SendVIPMessage(-1, string);
		PlayerPlaySound(playerid, 1058, 0.0, 0.0, 10.0);
	}
	return 1;
}

CMD:setvip(playerid, params[])
{
	if(IsPlayerAdmin(playerid))
    {
		if(PlayerInfo[playerid][pVipLevel] == 1) { vlevel = ""LEVEL1NAME""; }
		else if(PlayerInfo[playerid][pVipLevel] == 2) { vlevel = ""LEVEL2NAME""; }
		else if(PlayerInfo[playerid][pVipLevel] == 3) { vlevel = ""LEVEL3NAME""; }
		{
			new playername[MAX_PLAYER_NAME], aname[MAX_PLAYER_NAME], Level, targetid, string[128];
			if(sscanf(params, "ui", targetid, Level)) return SendClientMessage(playerid, COLOR_DGRAY, "Syntax: /setvip [playerid] [level]");
			if(targetid == INVALID_PLAYER_ID) return SendClientMessage(playerid, -1, "{FFFFFF}[{B3343A}ERROR{FFFFFF}]: Player is not connected");
			if(Level > 3 || Level < 0) return SendClientMessage(playerid, -1, "{FFFFFF}[{B3343A}ERROR{FFFFFF}]: Valid levels: 1-3");

			PlayerInfo[targetid][pVipLevel] = Level;
			PlayerInfo[targetid][pVipLevel] = Level;

			GetPlayerName(playerid, aname, sizeof(aname));
			GetPlayerName(targetid, playername, sizeof(playername));

			format(string,sizeof(string),"Administrator %s(%d) has set you as Very Important Person(%d)", aname, playerid, Level);
			SendClientMessage(playerid, COLOR_VIP, string);

			format(string, sizeof(string), ">> You've set %s(%d) as Very Important Person(%d).", playername, playerid, Level);
			SendClientMessage(playerid, COLOR_DGRAY, string);
   			PlayerInfo[playerid][pVipLevel] = Level;
   			//format(string,sizeof(string),"MYSQL: %s has set %s V.I.P Level %d.", aname, playername, Level);
   			print(string);

			format(string,sizeof(string),"'%s' has set '%s' VIP level to '%d'", aname, playername, Level);
		}
    }
    else SendClientMessage(playerid, -1, RCONERROR);
	return 1;
}

CMD:donors(playerid, params[]) return cmd_vips (playerid, params);
CMD:vips(playerid,  params[])
{
    new name[24], string[250];
    new vips = 0;
    for(new i = 0; i < MAX_PLAYERS; i++)
	{
        if (IsPlayerConnected(i))
		{
   			if(PlayerInfo[i][pVipLevel] >= 3 || PlayerInfo[i][pVipLevel] < 2 || PlayerInfo[i][pVipLevel] < 1)
			{
                GetPlayerName(i, name,sizeof(name));
                format(string,sizeof string, "~g~~h~%s(%d)~N~~y~~h~Level: "LEVEL3NAME"(1)", name, playerid);
                ShadInfoBoxForPlayer(playerid, string);
                vips ++;
            }
            else if(PlayerInfo[i][pVipLevel] >= 2 || PlayerInfo[i][pVipLevel] < 1)
			{
                GetPlayerName(i, name,sizeof(name));
                format(string,sizeof string, "~g~~h~%s(%d)~N~~y~~h~Level: "LEVEL2NAME"(2)", name, playerid);
                ShadInfoBoxForPlayer(playerid, string);
                vips ++;
            }
            else if(PlayerInfo[i][pVipLevel] >= 1)
			{
                GetPlayerName(i, name,sizeof(name));
                format(string,sizeof string, "~g~~h~%s(%d)~N~~y~~h~Level: "LEVEL1NAME"(3)", name, playerid);
                ShadInfoBoxForPlayer(playerid, string);
                vips ++;
            }
        }
    }
    if(vips== 0)
	{
        ShadInfoBoxForPlayer(playerid, "~w~None.");
 	}
    return 1;
}

CMD:vipcmds(playerid, params[]) return cmd_vcmds (playerid, params);
CMD:vcmds(playerid ,params[])
{
    new string[950];
	if(PlayerInfo[playerid][pVipLevel] < 1) return SendClientMessage(playerid, -1, VIPERROR);
	if(PlayerInfo[playerid][pVipLevel] == 1) { vlevel = ""LEVEL1NAME""; }
	else if(PlayerInfo[playerid][pVipLevel] == 2) { vlevel = ""LEVEL2NAME""; }
	else if(PlayerInfo[playerid][pVipLevel] == 3) { vlevel = ""LEVEL3NAME""; }
	{
		strcat(string, "{FFFFFF}"LEVEL1NAME"(1) Commands:\n");
		strcat(string, "{3DE3B1}/vsay /vbullet(/vcar) /vnrg(/vbike)\n");
		strcat(string, "/vvertex(/vboat) /vcycle(/vbmx)\n");
		strcat(string, "Use '# text' as VIP Chat\n\n");
		
		strcat(string, "{FFFFFF}"LEVEL2NAME"(2) Commands:\n");
		strcat(string, "{3DE3B1}Access to level "LEVEL1NAME"(1) commands.\n");
		strcat(string, "/myw(eather) /myt(ime) /vtune \n");
		strcat(string, "/vnitros(/vnos) /vcolor /vfix\n");
		strcat(string, "Invisible on map on spawn.\n\n");
		
		strcat(string, "{FFFFFF}"LEVEL3NAME"(3) Commands:\n");
		strcat(string, "{3DE3B1}Access to level "LEVEL1NAME"(1) and "LEVEL2NAME"(2) commands.\n");
		strcat(string, "/healme /armourme /vhydra(/vplane)\n");
		strcat(string, "/vheli(/vleviathan) /vheli1(/vhunter) /vheli2(/vseasparrow)\n");
		strcat(string, "/vheli3(/vmaverick) /vheli4(/vcargobob) /vheli5(/vraindance)\n");
		strcat(string, "Invisible on map on spawn.\n\n");
		ShowPlayerDialog(playerid, MAXGMDIALOG+1 ,DIALOG_STYLE_MSGBOX,"Donator Commands", string, "Close","");
 	}
	return 1;
}
/*============================================================================*/
#if VSAY_CMD == true
CMD:vsay(playerid, params[])
{
	if(PlayerInfo[playerid][pVipLevel] < 1) return SendClientMessage(playerid, -1, VIPERROR);
	new string[128], name[24];
	{
		if(PlayerInfo[playerid][pVipLevel] == 1) { vlevel = ""LEVEL1NAME""; }
		else if(PlayerInfo[playerid][pVipLevel] == 2) { vlevel = ""LEVEL2NAME""; }
		else if(PlayerInfo[playerid][pVipLevel] == 3) { vlevel = ""LEVEL3NAME""; }
		if(sscanf(params, "s[128]", string)) return ShadInfoBoxForPlayer(playerid, "~B~~H~SYNTAX~W~:~N~~Y~/VSAY <TEXT>~N~~G~EXAMPLE: /VSAY Hi all!");
		GetPlayerName(playerid, name ,sizeof(name));
		format(string, sizeof(string), "[VIP]: %s(%d): %s", name, playerid, params);
		SendClientMessageToAll(COLOR_VIP, string);
	}
    return 1;
}
#endif

CMD:vcar(playerid, params[]) return cmd_vbullet(playerid, params);
CMD:vbullet(playerid, params[])
{
    if(PlayerInfo[playerid][pVipLevel] < 1) return SendClientMessage(playerid, -1, VIPERROR);
	if(PlayerInfo[playerid][pVipLevel] == 1) { vlevel = ""LEVEL1NAME""; }
	else if(PlayerInfo[playerid][pVipLevel] == 2) { vlevel = ""LEVEL2NAME""; }
	else if(PlayerInfo[playerid][pVipLevel] == 3) { vlevel = ""LEVEL3NAME""; }
	{
 		if(!IsPlayerInAnyVehicle(playerid))
   	    {
			new Float:x, Float:y, Float:z, Float:Angle;
			GetPlayerPos(playerid, x,y,z);
			GetPlayerFacingAngle(playerid, Angle);
			new name[24], string[250];
			GetPlayerName(playerid, name, sizeof(name));
			new vehicleid;
			vehicleid= GetPlayerVehicleID(playerid);
			DestroyVehicle(vehicleid);
			format(string, sizeof(string), "%s's Bullet",name);
			vehicle_id = CreateVehicle( 541, x, y, z, Angle, 0,1, 120 );
			vehicle3Dtext[ vehicle_id ] = Create3DTextLabel(string, COLOR_VIP, 0.0, 0.0, 0.0, 50.0, 0, 1 );
			Attach3DTextLabelToVehicle( vehicle3Dtext[ vehicle_id ] , vehicle_id, 0.0, 0.0, 1.0);
			PutPlayerInVehicle(playerid, vehicle_id, 0);
			ShadInfoBoxForPlayer(playerid, "~G~~H~SUCCESS:~N~~Y~BULLET CAR SPAWNED!");
		} else ShadInfoBoxForPlayer(playerid, "~r~~H~ERROR~W~:~N~~Y~YOU ALREADY HAVE A VEHICLE!");
	}
	SendVIPMessage(playerid, "BULLET");
    return 1;
}

CMD:vbike(playerid, params[]) return cmd_vnrg(playerid, params);
CMD:vnrg(playerid, params[])
{
    if(PlayerInfo[playerid][pVipLevel] < 2) return SendClientMessage(playerid, -1, VIPERROR);
	if(PlayerInfo[playerid][pVipLevel] == 1) { vlevel = ""LEVEL1NAME""; }
	else if(PlayerInfo[playerid][pVipLevel] == 2) { vlevel = ""LEVEL2NAME""; }
	else if(PlayerInfo[playerid][pVipLevel] == 3) { vlevel = ""LEVEL3NAME""; }
	{
 		if(!IsPlayerInAnyVehicle(playerid))
   	    {
			new name[24], string[250];
			new Float:x, Float:y, Float:z, Float:Angle;
			GetPlayerPos(playerid, x,y,z);
			GetPlayerFacingAngle(playerid, Angle);
		    GetPlayerName(playerid, name, sizeof(name));
		    new vehicleid;
		    vehicleid= GetPlayerVehicleID(playerid);
		    DestroyVehicle(vehicleid);
		    format(string, sizeof(string), "%s's NRG",name);
		    vehicle_id = CreateVehicle( 522, x, y, z, Angle, 0,0, 120 );
		    vehicle3Dtext[ vehicle_id ] = Create3DTextLabel(string, COLOR_VIP, 0.0, 0.0, 0.0, 50.0, 0, 1 );
		    Attach3DTextLabelToVehicle( vehicle3Dtext[ vehicle_id ] , vehicle_id, 0.0, 0.0, 1.0);
		    PutPlayerInVehicle(playerid, vehicle_id, 0);
		    ShadInfoBoxForPlayer(playerid, "~G~~H~SUCCESS~N~~Y~NRG MOTORBIKE SPAWNED!");
		} else ShadInfoBoxForPlayer(playerid, "~r~~H~ERROR~W~:~N~~Y~YOU ALREADY HAVE A VEHICLE!");
	}
	SendVIPMessage(playerid, "NRG(/VBIKE)");
    return 1;
}

CMD:vvertex(playerid, params[]) return cmd_vboat(playerid, params);
CMD:vboat(playerid, params[])
{
    if(PlayerInfo[playerid][pVipLevel] < 1) return SendClientMessage(playerid, -1, VIPERROR);
	if(PlayerInfo[playerid][pVipLevel] == 1) { vlevel = ""LEVEL1NAME""; }
	else if(PlayerInfo[playerid][pVipLevel] == 2) { vlevel = ""LEVEL2NAME""; }
	else if(PlayerInfo[playerid][pVipLevel] == 3) { vlevel = ""LEVEL3NAME""; }
 	{
 		if(!IsPlayerInAnyVehicle(playerid))
   	    {
			new Float:x, Float:y, Float:z, Float:Angle;
			new name[24], string[250];
			GetPlayerPos(playerid, x,y,z);
			GetPlayerFacingAngle(playerid, Angle);
		    GetPlayerName(playerid, name, sizeof(name));
		    new vehicleid;
		    vehicleid= GetPlayerVehicleID(playerid);
		    DestroyVehicle(vehicleid);
		    format(string, sizeof(string), "%s's Boat",name);
		    vehicle_id = CreateVehicle( 446, x, y, z, Angle, 0,1, 120 );
		    vehicle3Dtext[ vehicle_id ] = Create3DTextLabel(string, COLOR_VIP, 0.0, 0.0, 0.0, 50.0, 0, 1 );
		    Attach3DTextLabelToVehicle( vehicle3Dtext[ vehicle_id ] , vehicle_id, 0.0, 0.0, 2.0);
		    PutPlayerInVehicle(playerid, vehicle_id, 0);
			ShadInfoBoxForPlayer(playerid, "~G~~H~SUCCESS:~N~ ~Y~JETMAX BOAT SPAWNED!");
		} else ShadInfoBoxForPlayer(playerid, "~r~~H~ERROR~W~:~N~~Y~YOU ALREADY HAVE A VEHICLE!");
	}
	SendVIPMessage(playerid, "VBOAT");
    return 1;
}

CMD:vcycle(playerid, params[]) return cmd_vbmx (playerid, params);
CMD:vbmx(playerid, params[])
{
    if(PlayerInfo[playerid][pVipLevel] < 1) return SendClientMessage(playerid, -1, VIPERROR);
	if(PlayerInfo[playerid][pVipLevel] == 1) { vlevel = ""LEVEL1NAME""; }
	else if(PlayerInfo[playerid][pVipLevel] == 2) { vlevel = ""LEVEL2NAME""; }
	else if(PlayerInfo[playerid][pVipLevel] == 3) { vlevel = ""LEVEL3NAME""; }
	{
 		if(!IsPlayerInAnyVehicle(playerid))
   	    {
			new Float:x, Float:y, Float:z, Float:Angle;
			GetPlayerPos(playerid, x,y,z);
			GetPlayerFacingAngle(playerid, Angle);

			new name[24], string[250];
		    GetPlayerName(playerid, name, sizeof(name));
		    new vehicleid;
		    vehicleid= GetPlayerVehicleID(playerid);
		    DestroyVehicle(vehicleid);
		    format(string, sizeof(string), "%s's Bike",name);
		    vehicle_id = CreateVehicle( 481, x, y, z, Angle, 0,1, 120 );
		    vehicle3Dtext[ vehicle_id ] = Create3DTextLabel(string, COLOR_VIP, 0.0, 0.0, 0.0, 50.0, 0, 1 );
		    Attach3DTextLabelToVehicle( vehicle3Dtext[ vehicle_id ] , vehicle_id, 0.0, 0.0, 1.0);
		    PutPlayerInVehicle(playerid, vehicle_id, 0);
			ShadInfoBoxForPlayer(playerid, "~G~~H~SUCCESS:~N~ ~Y~BMX BIKE SPAWNED!");
		} else ShadInfoBoxForPlayer(playerid, "~r~~H~ERROR~W~:~N~~Y~YOU ALREADY HAVE A VEHICLE!");
	}
	SendVIPMessage(playerid, "BMX");
    return 1;
}
/*============================================================================*/
CMD:myw(playerid, params[]) return cmd_myweather(playerid, params);
CMD:myweather(playerid, params[])
{
    if(PlayerInfo[playerid][pVipLevel] < 2) return SendClientMessage(playerid, -1, VIPERROR);
	if(PlayerInfo[playerid][pVipLevel] == 1) { vlevel = ""LEVEL1NAME""; }
	else if(PlayerInfo[playerid][pVipLevel] == 2) { vlevel = ""LEVEL2NAME""; }
	else if(PlayerInfo[playerid][pVipLevel] == 3) { vlevel = ""LEVEL3NAME""; }
	{
	    new pos, level;
	    new string[250];
		if(isnull(params)) return ShadInfoBoxForPlayer(playerid, "~B~~H~SYNTAX~W~:~N~~Y~/MYWEATHER <1 TO 44>~N~/MYW <1 TO 44>");
		level = strval(params[pos]);
		if(level < 1 || level > 44) return ShadInfoBoxForPlayer(playerid, "~r~~H~ERROR~W~:~N~~Y~INVALID VALUE~N~~N~~G~WEATHER PERIMETER: 1 TO 44");
		SetWeather(level);
		format(string, sizeof(string), "~G~~H~SUCCESS:~N~ ~Y~WEATHER CHANGED! (%i)", level);
        ShadInfoBoxForPlayer(playerid, string);
	}
    return 1;
}

CMD:myt(playerid, params[]) return cmd_mytime(playerid, params);
CMD:mytime(playerid, params[])
{
	new time, string[256];
	if(PlayerInfo[playerid][pVipLevel] < 2) return SendClientMessage(playerid, -1, VIPERROR);
	if(sscanf(params, "i", time)) return ShadInfoBoxForPlayer(playerid, "~B~~H~SYNTAX~W~:~N~~Y~/MYTIME <0 TO 23>~N~/MYT <0 TO 23>");
	if(time < 0 || time > 23) return ShadInfoBoxForPlayer(playerid, "~R~~H~ERROR~W~: ~Y~CHOOSE TIME BETWEEN 0 TO 23!");
	format(string, sizeof(string), "~G~~H~SUCCESS~N~~Y~TIME CHANGED! (%02d:00)", time);
	ShadInfoBoxForPlayer(playerid, string);
	SetPlayerTime(playerid, time, 0);
    return 1;
}

CMD:vtune(playerid, params[])
{
	if(PlayerInfo[playerid][pVipLevel] < 2) return SendClientMessage(playerid, -1, VIPERROR);
	if(PlayerInfo[playerid][pVipLevel] == 1) { vlevel = ""LEVEL1NAME""; }
	else if(PlayerInfo[playerid][pVipLevel] == 2) { vlevel = ""LEVEL2NAME""; }
	else if(PlayerInfo[playerid][pVipLevel] == 3) { vlevel = ""LEVEL3NAME""; }
	{
		new vehicleid = GetPlayerVehicleID(playerid);
		if(GetVehicleModel(vehicleid) == 411) // 411 is the infernus model
		{
			tune[playerid] = 1;
			AttachObjectToVehicle(o, GetPlayerVehicleID(playerid), -0.300000,0.000000,0.675000,0.000000,0.000000,0.000000);
			AttachObjectToVehicle(ob2, GetPlayerVehicleID(playerid), 1.049999,2.174999,-0.599999,0.000005,180.899887,180.899963);
			AttachObjectToVehicle(ob3, GetPlayerVehicleID(playerid), -1.049999,-1.950001,-0.599999,0.000005,180.899887,361.799743);
			AttachObjectToVehicle(ob4, GetPlayerVehicleID(playerid), 0.000000,0.000000,0.000000,0.000000,0.000000,0.000000);
			AttachObjectToVehicle(ob5, GetPlayerVehicleID(playerid), -0.074999,-2.325000,0.375000,0.000000,0.000000,0.000000);
			AttachObjectToVehicle(ob6, GetPlayerVehicleID(playerid), 0.225000,0.000000,0.674999,0.000000,0.000000,0.000000);
			AttachObjectToVehicle(ob7, GetPlayerVehicleID(playerid), -0.074999,-2.325000,0.524999,0.000000,0.000000,0.000000);
			AttachObjectToVehicle(ob8, GetPlayerVehicleID(playerid), 0.000000,1.800000,0.149999,0.000000,0.000000,0.000000);
			AttachObjectToVehicle(ob9, GetPlayerVehicleID(playerid), 0.000000,1.650000,0.150000,0.000000,0.000000,0.000000);
			AttachObjectToVehicle(ob10, GetPlayerVehicleID(playerid), 0.000000,1.950000,0.150000,-10.800001,0.000000,0.000000);
			AttachObjectToVehicle(ob11, GetPlayerVehicleID(playerid), -1.049999,-0.824999,-0.599999,0.000000,0.000000,0.000000);
			AttachObjectToVehicle(ob12, GetPlayerVehicleID(playerid), 0.974999,-0.824999,-0.599999,0.000000,0.000000,0.000000);
			AttachObjectToVehicle(ob13, GetPlayerVehicleID(playerid), -0.074999,-2.325000,0.449999,0.000000,0.000000,0.000000);
			AddVehicleComponent(vehicleid, 1079);
			ChangeVehicleColor(vehicleid,0,3);
			ShadInfoBoxForPlayer(playerid, "~G~~H~SUCCESS~N~~Y~INFERNUS CAR TUNED!");
		}
		else
		if(GetVehicleModel(vehicleid) == 541) // 541 is the Bullet model
		{
			tune[playerid] = 1;
			AttachObjectToVehicle(ob14, GetPlayerVehicleID(playerid), 0.000000,-2.025000,0.300000,0.000000,0.000000,0.000000);
			AttachObjectToVehicle(ob15, GetPlayerVehicleID(playerid), -0.375000,-1.275000,-0.375000,0.000000,0.000000,0.000000);
			AttachObjectToVehicle(ob16, GetPlayerVehicleID(playerid), 1.049999,-1.500000,0.075000,0.000000,0.000000,0.000000);
			AttachObjectToVehicle(ob17, GetPlayerVehicleID(playerid), 0.374999,-1.275000,-0.375000,0.000000,0.000000,0.000000);
			AttachObjectToVehicle(ob18, GetPlayerVehicleID(playerid), 0.000000,0.224999,0.600000,0.000000,0.000000,0.000000);
			AttachObjectToVehicle(ob19, GetPlayerVehicleID(playerid), 1.049999,1.575000,0.000000,0.000000,0.000000,0.000000);
			AttachObjectToVehicle(ob20, GetPlayerVehicleID(playerid), -0.075000,1.200000,0.300000,0.000000,0.000000,0.000000);
			AttachObjectToVehicle(ob21, GetPlayerVehicleID(playerid), 1.049999,-0.899999,-0.375000,0.000000,0.000000,0.000000);
			AttachObjectToVehicle(ob22, GetPlayerVehicleID(playerid), -1.049999,-0.974999,-0.449999,0.000000,0.000000,0.000000);
			AddVehicleComponent(vehicleid, 1079);
			ChangeVehicleColor(vehicleid,0,3);
			ShadInfoBoxForPlayer(playerid, "~G~~H~SUCCESS~N~~Y~BULLET CAR TUNED!");
		}
		else
		{
			tune[playerid] = 0;
			ShadInfoBoxForPlayer(playerid, "~r~~H~ERROR:~W~:~N~~Y~YOU'RE NOT IN VEHICLE!~N~OR~N~VEHICLE NOT SUPPORTED!~N~~G~BULLET AND INFERNUS ARE SUPPORTED!");
		}
	}
	return 1;
}

CMD:vnitro(playerid, params[]) return cmd_vnos(playerid, params);
CMD:vnos(playerid, params[])
{
    if(PlayerInfo[playerid][pVipLevel] < 2) return SendClientMessage(playerid, -1, VIPERROR);
	if(PlayerInfo[playerid][pVipLevel] == 1) { vlevel = ""LEVEL1NAME""; }
	else if(PlayerInfo[playerid][pVipLevel] == 2) { vlevel = ""LEVEL2NAME""; }
	else if(PlayerInfo[playerid][pVipLevel] == 3) { vlevel = ""LEVEL3NAME""; }
	if(!IsPlayerInAnyVehicle(playerid)) return ShadInfoBoxForPlayer(playerid, "~r~~H~ERROR:~W~:~N~~Y~YOU'RE NOT IN VEHICLE!");

  	AddVehicleComponent(GetPlayerVehicleID(playerid), 1010);
  	ShadInfoBoxForPlayer(playerid, "~G~~H~SUCCESS:~N~ ~Y~NITROS ADDED!");

	SendVIPMessage(playerid, "NITRO");
    return 1;
}

CMD:vcolor(playerid, params[])
{
    if(PlayerInfo[playerid][pVipLevel] < 2) return SendClientMessage(playerid, -1, VIPERROR);
	if(PlayerInfo[playerid][pVipLevel] == 1) { vlevel = ""LEVEL1NAME""; }
	else if(PlayerInfo[playerid][pVipLevel] == 2) { vlevel = ""LEVEL2NAME""; }
	else if(PlayerInfo[playerid][pVipLevel] == 3) { vlevel = ""LEVEL3NAME""; }
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
	}
    return 1;
}

CMD:vehfix(playerid, params[]) return cmd_vfix(playerid, params);
CMD:vfix(playerid, params[])
{
    if(PlayerInfo[playerid][pVipLevel] < 2) return SendClientMessage(playerid, -1, VIPERROR);
	if(PlayerInfo[playerid][pVipLevel] == 1) { vlevel = ""LEVEL1NAME""; }
	else if(PlayerInfo[playerid][pVipLevel] == 2) { vlevel = ""LEVEL2NAME""; }
	else if(PlayerInfo[playerid][pVipLevel] == 3) { vlevel = ""LEVEL3NAME""; }
	{
		if(!IsPlayerInAnyVehicle(playerid)) return ShadInfoBoxForPlayer(playerid, "~r~~H~ERROR:~W~:~N~~Y~YOU'RE NOT IN VEHICLE!");
		RepairVehicle(GetPlayerVehicleID(playerid));
		ShadInfoBoxForPlayer(playerid, "~G~~H~SUCCESS:~N~ ~Y~VEHICLE FIXED!");
	}
	SendVIPMessage(playerid, "VFIX(/VEHFIX)");
    return 1;
}

/*============================================================================*/
CMD:vheal(playerid, params[]) return cmd_healme(playerid, params);
CMD:healme(playerid, params[])
{
    if(PlayerInfo[playerid][pVipLevel] < 3) return SendClientMessage(playerid, -1, VIPERROR);
	if(PlayerInfo[playerid][pVipLevel] == 1) { vlevel = ""LEVEL1NAME""; }
	else if(PlayerInfo[playerid][pVipLevel] == 2) { vlevel = ""LEVEL2NAME""; }
	else if(PlayerInfo[playerid][pVipLevel] == 3) { vlevel = ""LEVEL3NAME""; }
	{
		if(Anti_heal[playerid] == 0)
		{
			if(PlayerInfo[playerid][pVipLevel] == 1)
			{
				ShadInfoBoxForPlayer(playerid, "~G~~H~SUCCESS~N~~Y~HEALTH RESTORED!");
				SetPlayerHealth(playerid, LVL1HEALTH);
				Anti_heal[playerid] = 1;
			}
			else if(PlayerInfo[playerid][pVipLevel] == 2)
			{
				ShadInfoBoxForPlayer(playerid, "~G~~H~SUCCESS~N~~Y~HEALTH RESTORED!");
				SetPlayerHealth(playerid, LVL3HEALTH);
				Anti_heal[playerid] = 1;
			}
			else if(PlayerInfo[playerid][pVipLevel] == 3)
			{
				ShadInfoBoxForPlayer(playerid, "~G~~H~SUCCESS~N~~Y~HEALTH RESTORED!");
				SetPlayerHealth(playerid, LVL3HEALTH);
				Anti_heal[playerid] = 1;
			}
		}
		else return ShadInfoBoxForPlayer(playerid, "~r~~H~ERROR:~W~:~N~~Y~YOU CAN USE THIS COMMAND AFTER DEATH ONLY!");
	}
	SendVIPMessage(playerid, "HEALME");
 	return 1;
}

CMD:varmour(playerid, params[]) return cmd_armourme(playerid, params);
CMD:armourme(playerid, params[])
{
    if(PlayerInfo[playerid][pVipLevel] < 3) return SendClientMessage(playerid, -1, VIPERROR);
	if(PlayerInfo[playerid][pVipLevel] == 1) { vlevel = ""LEVEL1NAME""; }
	else if(PlayerInfo[playerid][pVipLevel] == 2) { vlevel = ""LEVEL2NAME""; }
	else if(PlayerInfo[playerid][pVipLevel] == 3) { vlevel = ""LEVEL3NAME""; }
	{
		if(Anti_armour[playerid] == 0 || PlayerInfo[playerid][pVipLevel] == 1)
		{
			if(PlayerInfo[playerid][pVipLevel] == 1)
			{
				ShadInfoBoxForPlayer(playerid, "~G~~H~SUCCESS~N~~Y~ARMOUR RESTORED!");
				SetPlayerArmour(playerid, LVLL1ARMOUR);
				Anti_armour[playerid] = 1;
			}
			else if(PlayerInfo[playerid][pVipLevel] == 3)
			{
				ShadInfoBoxForPlayer(playerid, "~G~~H~SUCCESS~N~~Y~ARMOUR RESTORED!");
				SetPlayerArmour(playerid, LVLL2ARMOUR);
				Anti_armour[playerid] = 1;
			}
			else if(PlayerInfo[playerid][pVipLevel] == 3)
			{
				ShadInfoBoxForPlayer(playerid, "~G~~H~SUCCESS~N~~Y~ARMOUR RESTORED!");
				SetPlayerArmour(playerid, LVLL3ARMOUR);
				Anti_armour[playerid] = 1;
			}
		}
		else return ShadInfoBoxForPlayer(playerid, "~r~~H~ERROR:~W~:~N~~Y~YOU CAN USE THIS COMMAND AFTER DEATH ONLY!");
	}
	SendVIPMessage(playerid, "ARMOURME");
    return 1;
}

CMD:vhydra(playerid, params[]) return cmd_vplane(playerid, params);
CMD:vplane(playerid, params[])
{
    if(PlayerInfo[playerid][pVipLevel] < 3) return SendClientMessage(playerid, -1, VIPERROR);
	if(PlayerInfo[playerid][pVipLevel] == 1) { vlevel = ""LEVEL1NAME""; }
	else if(PlayerInfo[playerid][pVipLevel] == 2) { vlevel = ""LEVEL2NAME""; }
	else if(PlayerInfo[playerid][pVipLevel] == 3) { vlevel = ""LEVEL3NAME""; }
	{
	 	if(!IsPlayerInAnyVehicle(playerid))
   	    {
			new name[24], string[250];
			new Float:x, Float:y, Float:z, Float:Angle;
			GetPlayerPos(playerid, x,y,z);
			GetPlayerFacingAngle(playerid, Angle);
		    GetPlayerName(playerid, name, sizeof(name));
		    new vehicleid;
		    vehicleid= GetPlayerVehicleID(playerid);
		    DestroyVehicle(vehicleid);
		    format(string, sizeof(string), "%s's Hydra",name);
		    vehicle_id = CreateVehicle( 520, x, y, z, Angle, 0,0, 120 );
		    vehicle3Dtext[ vehicle_id ] = Create3DTextLabel(string, COLOR_VIP, 0.0, 0.0, 0.0, 50.0, 0, 1 );
		    Attach3DTextLabelToVehicle( vehicle3Dtext[ vehicle_id ] , vehicle_id, 0.0, 0.0, 2.0);
		    PutPlayerInVehicle(playerid, vehicle_id, 0);
			ShadInfoBoxForPlayer(playerid, "~G~~H~SUCCESS~N~~Y~HYDRA SPAWNED!");
		} else ShadInfoBoxForPlayer(playerid, "~r~~H~ERROR~W~:~N~~Y~YOU ALREADY HAVE A VEHICLE!");
	}
	SendVIPMessage(playerid, "VPLANE(/VHYDRA)");
    return 1;
}

CMD:vleviathan(playerid, params[]) return cmd_vheli(playerid, params);
CMD:vheli(playerid, params[])
{
    if(PlayerInfo[playerid][pVipLevel] < 3) return SendClientMessage(playerid, -1, VIPERROR);
	if(PlayerInfo[playerid][pVipLevel] == 1) { vlevel = ""LEVEL1NAME""; }
	else if(PlayerInfo[playerid][pVipLevel] == 2) { vlevel = ""LEVEL2NAME""; }
	else if(PlayerInfo[playerid][pVipLevel] == 3) { vlevel = ""LEVEL3NAME""; }
	{
 		if(!IsPlayerInAnyVehicle(playerid))
   	    {
			new string[128], name[24];
			new Float:x, Float:y, Float:z, Float:Angle;
			GetPlayerPos(playerid, x,y,z);
			GetPlayerFacingAngle(playerid, Angle);
			GetPlayerName(playerid, name, sizeof(name));
			new vehicleid;
		    vehicleid= GetPlayerVehicleID(playerid);
			DestroyVehicle(vehicleid);
			format(string, sizeof(string), "%s's Leviathan",name);
			vehicle_id = CreateVehicle( 417, x, y, z, Angle, 0,0, 120);
		    vehicle3Dtext[ vehicle_id ] = Create3DTextLabel(string, COLOR_VIP, 0.0, 0.0, 0.0, 50.0, 0, 1 );
		    Attach3DTextLabelToVehicle( vehicle3Dtext[ vehicle_id ] , vehicle_id, 0.0, 0.0, 2.0);
			PutPlayerInVehicle(playerid, vehicle_id, 0);
			ShadInfoBoxForPlayer(playerid, "~G~~H~SUCCESS~N~~Y~LEVIATHAN SPAWNED!");
		} else ShadInfoBoxForPlayer(playerid, "~r~~H~ERROR~W~:~N~~Y~YOU ALREADY HAVE A VEHICLE!");
	}
	SendVIPMessage(playerid, "VLEVIATHAN(/VHELI)");
    return 1;
}

CMD:vhunter(playerid, params[]) return cmd_vheli1(playerid, params);
CMD:vheli1(playerid, params[])
{
    if(PlayerInfo[playerid][pVipLevel] < 3) return SendClientMessage(playerid, -1, VIPERROR);
	if(PlayerInfo[playerid][pVipLevel] == 1) { vlevel = ""LEVEL1NAME""; }
	else if(PlayerInfo[playerid][pVipLevel] == 2) { vlevel = ""LEVEL2NAME""; }
	else if(PlayerInfo[playerid][pVipLevel] == 3) { vlevel = ""LEVEL3NAME""; }
	{
 		if(!IsPlayerInAnyVehicle(playerid))
   	    {
			new string[128], name[24];
			new Float:x, Float:y, Float:z, Float:Angle;
			GetPlayerPos(playerid, x,y,z);
			GetPlayerFacingAngle(playerid, Angle);
			GetPlayerName(playerid, name, sizeof(name));
			new vehicleid;
		    vehicleid= GetPlayerVehicleID(playerid);
			DestroyVehicle(vehicleid);
			format(string, sizeof(string), "%s's Hunter",name);
			vehicle_id = CreateVehicle( 425, x, y, z, Angle, 0,0, 120);
		    vehicle3Dtext[ vehicle_id ] = Create3DTextLabel(string, COLOR_VIP, 0.0, 0.0, 0.0, 50.0, 0, 1 );
		    Attach3DTextLabelToVehicle( vehicle3Dtext[ vehicle_id ] , vehicle_id, 0.0, 0.0, 2.0);
			PutPlayerInVehicle(playerid, vehicle_id, 0);
			ShadInfoBoxForPlayer(playerid, "~G~~H~SUCCESS~N~~Y~HUNTER SPAWNED!");
		} else ShadInfoBoxForPlayer(playerid, "~r~~H~ERROR~W~:~N~~Y~YOU ALREADY HAVE A VEHICLE!");
	}
	SendVIPMessage(playerid, "VHUNTER(/VHELI1)");
    return 1;
}

CMD:vseaparrow(playerid, params[]) return cmd_vheli2(playerid, params);
CMD:vheli2(playerid, params[])
{
    if(PlayerInfo[playerid][pVipLevel] < 3) return SendClientMessage(playerid, -1, VIPERROR);
	if(PlayerInfo[playerid][pVipLevel] == 1) { vlevel = ""LEVEL1NAME""; }
	else if(PlayerInfo[playerid][pVipLevel] == 2) { vlevel = ""LEVEL2NAME""; }
	else if(PlayerInfo[playerid][pVipLevel] == 3) { vlevel = ""LEVEL3NAME""; }
	{
 		if(!IsPlayerInAnyVehicle(playerid))
   	    {
			new string[128], name[24];
			new Float:x, Float:y, Float:z, Float:Angle;
			GetPlayerPos(playerid, x,y,z);
			GetPlayerFacingAngle(playerid, Angle);
			GetPlayerName(playerid, name, sizeof(name));
			new vehicleid;
		    vehicleid= GetPlayerVehicleID(playerid);
			DestroyVehicle(vehicleid);
			format(string, sizeof(string), "%s's Seasparrow",name);
			vehicle_id = CreateVehicle( 447, x, y, z, Angle, 0,0, 120);
		    vehicle3Dtext[ vehicle_id ] = Create3DTextLabel(string, COLOR_VIP, 0.0, 0.0, 0.0, 50.0, 0, 1 );
		    Attach3DTextLabelToVehicle( vehicle3Dtext[ vehicle_id ] , vehicle_id, 0.0, 0.0, 2.0);
			PutPlayerInVehicle(playerid, vehicle_id, 0);
			ShadInfoBoxForPlayer(playerid, "~G~~H~SUCCESS~N~~Y~SEASPARROW SPAWNED!");
		} else ShadInfoBoxForPlayer(playerid, "~r~~H~ERROR~W~:~N~~Y~YOU ALREADY HAVE A VEHICLE!");
	}
	SendVIPMessage(playerid, "VSEASPARROW(/VHELI2)");
    return 1;
}

CMD:vmaverick(playerid, params[]) return cmd_vheli3(playerid, params);
CMD:vheli3(playerid, params[])
{
    if(PlayerInfo[playerid][pVipLevel] < 3) return SendClientMessage(playerid, -1, VIPERROR);
	if(PlayerInfo[playerid][pVipLevel] == 1) { vlevel = ""LEVEL1NAME""; }
	else if(PlayerInfo[playerid][pVipLevel] == 2) { vlevel = ""LEVEL2NAME""; }
	else if(PlayerInfo[playerid][pVipLevel] == 3) { vlevel = ""LEVEL3NAME""; }
	{
 		if(!IsPlayerInAnyVehicle(playerid))
   	    {
			new string[128], name[24];
			new Float:x, Float:y, Float:z, Float:Angle;
			GetPlayerPos(playerid, x,y,z);
			GetPlayerFacingAngle(playerid, Angle);
			GetPlayerName(playerid, name, sizeof(name));
			new vehicleid;
		    vehicleid= GetPlayerVehicleID(playerid);
			DestroyVehicle(vehicleid);
			format(string, sizeof(string), "%s's Maverick",name);
			vehicle_id = CreateVehicle( 487, x, y, z, Angle, 0,0, 120);
		    vehicle3Dtext[ vehicle_id ] = Create3DTextLabel(string, COLOR_VIP, 0.0, 0.0, 0.0, 50.0, 0, 1 );
		    Attach3DTextLabelToVehicle( vehicle3Dtext[ vehicle_id ] , vehicle_id, 0.0, 0.0, 2.0);
			PutPlayerInVehicle(playerid, vehicle_id, 0);
			ShadInfoBoxForPlayer(playerid, "~G~~H~SUCCESS~N~~Y~MAVERICK SPAWNED!");
		} else ShadInfoBoxForPlayer(playerid, "~r~~H~ERROR~W~:~N~~Y~YOU ALREADY HAVE A VEHICLE!");
	}
	SendVIPMessage(playerid, "VMAVERICK(/VHELI3)");
    return 1;
}

CMD:vcargobob(playerid, params[]) return cmd_vheli4(playerid, params);
CMD:vheli4(playerid, params[])
{
    if(PlayerInfo[playerid][pVipLevel] < 3) return SendClientMessage(playerid, -1, VIPERROR);
	if(PlayerInfo[playerid][pVipLevel] == 1) { vlevel = ""LEVEL1NAME""; }
	else if(PlayerInfo[playerid][pVipLevel] == 2) { vlevel = ""LEVEL2NAME""; }
	else if(PlayerInfo[playerid][pVipLevel] == 3) { vlevel = ""LEVEL3NAME""; }
	{
 		if(!IsPlayerInAnyVehicle(playerid))
   	    {
			new string[128], name[24];
			new Float:x, Float:y, Float:z, Float:Angle;
			GetPlayerPos(playerid, x,y,z);
			GetPlayerFacingAngle(playerid, Angle);
			GetPlayerName(playerid, name, sizeof(name));
			new vehicleid;
		    vehicleid= GetPlayerVehicleID(playerid);
			DestroyVehicle(vehicleid);
			format(string, sizeof(string), "%s's Cargobob",name);
			vehicle_id = CreateVehicle( 548, x, y, z, Angle, 0,0, 120);
		    vehicle3Dtext[ vehicle_id ] = Create3DTextLabel(string, COLOR_VIP, 0.0, 0.0, 0.0, 50.0, 0, 1 );
		    Attach3DTextLabelToVehicle( vehicle3Dtext[ vehicle_id ] , vehicle_id, 0.0, 0.0, 2.0);
			PutPlayerInVehicle(playerid, vehicle_id, 0);
			ShadInfoBoxForPlayer(playerid, "~G~~H~SUCCESS~N~~Y~CARGOBOB SPAWNED!");
		} else ShadInfoBoxForPlayer(playerid, "~r~~H~ERROR~W~:~N~~Y~YOU ALREADY HAVE A VEHICLE!");
	}
	SendVIPMessage(playerid, "VCARGOBOB(/VHELI4)");
    return 1;
}

CMD:vraindance(playerid, params[]) return cmd_vheli5(playerid, params);
CMD:vheli5(playerid, params[])
{
    if(PlayerInfo[playerid][pVipLevel] < 3) return SendClientMessage(playerid, -1, VIPERROR);
	if(PlayerInfo[playerid][pVipLevel] == 1) { vlevel = ""LEVEL1NAME""; }
	else if(PlayerInfo[playerid][pVipLevel] == 2) { vlevel = ""LEVEL2NAME""; }
	else if(PlayerInfo[playerid][pVipLevel] == 3) { vlevel = ""LEVEL3NAME""; }
	{
 		if(!IsPlayerInAnyVehicle(playerid))
   	    {
			new string[128], name[24];
			new Float:x, Float:y, Float:z, Float:Angle;
			GetPlayerPos(playerid, x,y,z);
			GetPlayerFacingAngle(playerid, Angle);
			GetPlayerName(playerid, name, sizeof(name));
			new vehicleid;
		    vehicleid= GetPlayerVehicleID(playerid);
			DestroyVehicle(vehicleid);
			format(string, sizeof(string), "%s's Raindance",name);
			vehicle_id = CreateVehicle( 563, x, y, z, Angle, 0,0, 120);
		    vehicle3Dtext[ vehicle_id ] = Create3DTextLabel(string, COLOR_VIP, 0.0, 0.0, 0.0, 50.0, 0, 1 );
		    Attach3DTextLabelToVehicle( vehicle3Dtext[ vehicle_id ] , vehicle_id, 0.0, 0.0, 2.0);
			PutPlayerInVehicle(playerid, vehicle_id, 0);
			ShadInfoBoxForPlayer(playerid, "~G~~H~SUCCESS~N~~Y~RAINDANCE SPAWNED!");
		} else ShadInfoBoxForPlayer(playerid, "~r~~H~ERROR~W~:~N~~Y~YOU ALREADY HAVE A VEHICLE!");
	}
	SendVIPMessage(playerid, "VRAINDANCE(/VHELI5)");
    return 1;
}
/*============================================================================*/
forward Processed(playerid);
public Processed(playerid)
{
	if(PlayerInfo[playerid][pVipLevel] == 3)
	{
	    #if defined VIPHEADSHOW
		new Text3D:label = Create3DTextLabel(""VIPHEADTAG"(3)", COLOR_VIPHEADTAG,30.0,40.0,50.0,40.0,-1,0);
		Attach3DTextLabelToPlayer(label, playerid, 0,0,0.5);
		#endif
		
        SetPlayerArmour(playerid, LVLL3ARMOUR);
        SetPlayerHealth(playerid, LVL3HEALTH);

		new ammo, weaponid;
		for (new i = 0; i <= 12; i++)
		{
		    GetPlayerWeaponData(playerid, i, weaponid, ammo);
		    SetPlayerAmmo(playerid, weaponid, ammo+LVL3SPAWNAMMO);
		}
		
        new info[300];
        format(info, sizeof(info), "~g~~h~~h~~h~SPAWN INFO~n~~n~~r~Health: ~y~%d (Non-VIP: %d)~n~~w~Armour: ~y~%d (Non-VIP: %d)~n~~g~Weapon Ammo: ~y~+%d~n~~g~~h~~h~Invisible on map!",LVL3HEALTH,NORMALPLAYERHEALTH,LVLL3ARMOUR,NORMALPLAYERARMOUR,LVL3SPAWNAMMO);
        ShadInfoBoxForPlayer(playerid, info);
        TogglePlayerControllable(playerid, true);
        KillTimer(spawntimer[playerid]);
        SetTimerEx("CloseTextdraw", 5000, true, "i", playerid);
        for(new i; i < MAX_PLAYERS; i++)
		{
		    SetPlayerMarkerForPlayer(playerid, i, (GetPlayerColor(playerid) & 0xFFFFFF00));
		}
	}
	else if(PlayerInfo[playerid][pVipLevel] == 2)
	{
	    #if defined VIPHEADSHOW
		new Text3D:label = Create3DTextLabel(""VIPHEADTAG"(2)", COLOR_VIPHEADTAG,30.0,40.0,50.0,40.0,-1,0);
		Attach3DTextLabelToPlayer(label, playerid, 0,0,0.5);
		#endif
		
		SetPlayerArmour(playerid, LVLL2ARMOUR);
		SetPlayerHealth(playerid, LVL3HEALTH);
		new ammo, weaponid;
		for (new i = 0; i <= 12; i++)
		{
		    GetPlayerWeaponData(playerid, i, weaponid, ammo);
		    SetPlayerAmmo(playerid, weaponid, ammo+LVL2SPAWNAMMO);
		}

        new info[300];
        format(info, sizeof(info), "~g~~h~~h~~h~SPAWN INFO~n~~n~~r~Health: ~y~%d (Non-VIP: %d)~n~~w~Armour: ~y~%d (Non-VIP: %d)~n~~g~Weapon Ammo: ~y~+%d~n~~g~~h~~h~Invisible on map!",LVL3HEALTH,NORMALPLAYERHEALTH,LVLL2ARMOUR,NORMALPLAYERARMOUR,LVL2SPAWNAMMO);
		ShadInfoBoxForPlayer(playerid, info);
		TogglePlayerControllable(playerid, true);
		KillTimer(spawntimer[playerid]);
		SetTimerEx("CloseTextdraw", 5000, true, "i", playerid);
  		for(new i; i < MAX_PLAYERS; i++)
		{
		    SetPlayerMarkerForPlayer(playerid, i, (GetPlayerColor(playerid) & 0xFFFFFF00));
		}
	}
	else if(PlayerInfo[playerid][pVipLevel] == 1)
	{
	    #if defined VIPHEADSHOW
		new Text3D:label = Create3DTextLabel(""VIPHEADTAG"(1)", COLOR_VIPHEADTAG,30.0,40.0,50.0,40.0,-1,0);
		Attach3DTextLabelToPlayer(label, playerid, 0,0,0.5);
		#endif
		
		SetPlayerArmour(playerid, LVLL1ARMOUR);
		SetPlayerHealth(playerid, LVL1HEALTH);
		new ammo, weaponid;
		for (new i = 0; i <= 12; i++)
		{
		    GetPlayerWeaponData(playerid, i, weaponid, ammo);
		    SetPlayerAmmo(playerid, weaponid, ammo+LVL1SPAWNAMMO);
		}

        new info[300];
        format(info, sizeof(info), "~g~~h~~h~~h~SPAWN INFO~n~~n~~r~Health: ~y~%d (Non-VIP: %d)~n~~w~Armour: ~y~%d (Non-VIP: %d)~n~~g~Weapon Ammo: ~y~+%d",LVL1HEALTH,NORMALPLAYERHEALTH,LVLL1ARMOUR,NORMALPLAYERARMOUR,LVL1SPAWNAMMO);
		ShadInfoBoxForPlayer(playerid, info);
		TogglePlayerControllable(playerid, true);
		KillTimer(spawntimer[playerid]);
		SetTimerEx("CloseTextdraw", 5000, true, "i", playerid);
	}
   	else if(PlayerInfo[playerid][pVipLevel] == 0)
	{
		SetPlayerArmour(playerid, NORMALPLAYERARMOUR);
		SetPlayerHealth(playerid, NORMALPLAYERHEALTH);

        new info[250];
        format(info, sizeof(info), "~g~~h~~h~~h~SPAWN INFO~n~~n~~r~Health: ~y~%d~n~~w~Armour: ~y~%d",NORMALPLAYERHEALTH,NORMALPLAYERARMOUR);
		ShadInfoBoxForPlayer(playerid, info);
		TogglePlayerControllable(playerid, true);
		KillTimer(spawntimer[playerid]);
		SetTimerEx("CloseTextdraw", 5000, true, "i", playerid);
	}
    return 1;
}

/*============================================================================*/
forward public OnPlayerDataCheck(playerid, corrupt_check);
public OnPlayerDataCheck(playerid, corrupt_check)
{
	if (corrupt_check != Corrupt_Check[playerid]) return Kick(playerid);
	if(cache_num_rows() > 0)
	{
		cache_get_value(0, "LEVEL", PlayerInfo[playerid][pVipLevel], 5);
		PlayerInfo[playerid][Player_Cache] = cache_save();
	}
	return 1;
}
/*============================================================================*/
forward CloseTextdraw(playerid);
public CloseTextdraw(playerid)
{
    TextDrawHideForPlayer(playerid, ShadInfoBox);
}

stock ShadInfoBoxForPlayer(playerid, text[])
{
    TextDrawHideForPlayer(playerid, ShadInfoBox);
	new info[250];
	ShadInfoBoxShowing[playerid] = 1;
	format(info, sizeof(info), "%s", text);
	TextDrawSetString(ShadInfoBox, info);
	return TextDrawShowForPlayer(playerid, ShadInfoBox);
}

stock SendVIPMessage(playerid, vipcmd[])
{
	for(new i = 0; i < MAX_PLAYERS; i++)
	{
		if(IsPlayerConnected(i) == 1)
		if(IsPlayerAdmin(playerid))
		{
			new string[250], vipname[MAX_PLAYER_NAME];
		  	GetPlayerName(playerid, vipname, sizeof(vipname));
		  	format(string, sizeof(string), "%s(%d) has used the command '/%s'",vipname, playerid, vipcmd);
			SendClientMessage(playerid, COLOR_DGRAY, string);
		}
	}
	return 1;
}
