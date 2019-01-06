/* Script: Wallet [Y_INI & ZCMD]
-» Release Date:       		26.09.2018
-» Description:        		Wallet Script specially designed for RP/RPG/MMO servers.
-» Saving System Used: 		Y_INI (by Y_Less)
-» Command Processor Used:  	ZCMD (by Zeex)
-» Version:                 	0.2 (Beta)
*/

/*============================================================================*/
#define FILTERSCRIPT
#include <a_samp>
#include <zcmd>
#include <sscanf>
#include <YSI\y_ini>

#define buywallet 100
#define playerfile			"Users/%s.ini"

enum PlayerInfo
{
	pWallet, pCash
}

new
	rp[MAX_PLAYERS],
	rp1[MAX_PLAYERS],
    pInfo[MAX_PLAYERS][PlayerInfo];

forward LoadUser_UserData(playerid,name[],value[]);
public LoadUser_UserData(playerid,name[],value[])
{
    INI_Int("Wallet", pInfo[playerid][pWallet]);
    INI_Int("Cash", pInfo[playerid][pCash]);
    return 1;
}
//--------------------------------------------------------------------
#if defined FILTERSCRIPT
public OnFilterScriptInit()
{
	for(new i, j = GetPlayerPoolSize(); i <= j; i++)
	{
		if(fexist(UserPath(i)))
		{
			INI_ParseFile(UserPath(i), "LoadUser_%s", .bExtra = true, .extra = i);
		}
	}
	return 1;
}

public OnFilterScriptExit()
{
	return 1;
}
#endif

public OnPlayerConnect(playerid)
{
	if(fexist(UserPath(playerid)))
	{
		INI_ParseFile(UserPath(playerid), "LoadUser_%s", .bExtra = true, .extra = playerid);
	}
	//pInfo[playerid][pWallet] = 1;
	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
	new name[MAX_PLAYER_NAME], tname[MAX_PLAYER_NAME], targetid, money = GetPlayerMoney(playerid);

	GetPlayerName(playerid, name, sizeof(name));
	GetPlayerName(targetid, tname, sizeof(tname));
    switch(reason)
    {
        case 0: // Timeout / Crashed
		{
			if(rp[playerid] == 1 || rp1[targetid] ==1)
			{
			    if(pInfo[targetid][pWallet] == 0)
			    {
			        new string [200];
					format(string,sizeof(string), "You've recovered your wallet(0$). Reason: %s(%d) has crashed.", name, playerid);
					SendClientMessage(targetid, -1, string);
					pInfo[targetid][pWallet] = 1;
					pInfo[playerid][pWallet] = 0;
					pInfo[playerid][pCash] = 0;
				} else return 1;
			}
			return 1;
		}
        case 1: // Left
		{
			if(rp[playerid] == 1 || rp1[targetid] ==1)
			{
			    if(pInfo[targetid][pWallet] == 0)
			    {
			        new string [200];
					format(string,sizeof(string), "You've recovered your wallet(0$). Reason: %s(%d) has left.", name, playerid);
					SendClientMessage(targetid, -1, string);
					pInfo[targetid][pWallet] = 1;
					pInfo[playerid][pWallet] = 0;
					pInfo[playerid][pCash] = 0;
				} else return 1;
			}
		}
        case 2: // Kicked / Banned
		{
			if(rp[playerid] == 1 || rp1[targetid] ==1)
			{
			    if(pInfo[targetid][pWallet] == 0)
			    {
			        new string [200];
			        GivePlayerMoney(targetid, money);
			        GivePlayerMoney(playerid, -money);
					format(string,sizeof(string), "You've recovered your wallet(%d$). Reason: %s(%d) has been kicked/banned.", name, playerid, money);
					SendClientMessage(targetid, -1, string);
					pInfo[targetid][pWallet] = 1;
					pInfo[playerid][pWallet] = 0;
					pInfo[playerid][pCash] = 0;
				} else return 1;
			}
		}
    }
   	SaveStats(playerid);
	return 1;
}

public OnPlayerDeath(playerid, killerid, reason)
{
	new money = GetPlayerMoney(playerid), string[150], name[MAX_PLAYER_NAME], tname[MAX_PLAYER_NAME];

	GivePlayerMoney(killerid, money);
	GivePlayerMoney(playerid, -money);

	GetPlayerName(killerid, name, sizeof(name));
	GetPlayerName(playerid, tname, sizeof(tname));

	if(rp[playerid] == 1 || rp1[killerid] == 1)
	{
		format(string,sizeof(string), "You're killed by %s(%d) and lost your '%d$'.", name, killerid, money);
		SendClientMessage(playerid, -1, string);

		format(string,sizeof(string), "You killed %s(%d) and recovered your money and also looted his cash('%d$').", tname, playerid, money);
		SendClientMessage(killerid, -1, string);

		pInfo[playerid][pWallet] = 0;
		pInfo[killerid][pWallet] = 1;

	} else SendClientMessage(playerid, -1, "You'll not recieve any money he robbed from you.");
	return 1;
}

CMD:rob(playerid, params[])
{
	new rob = random(10), targetid, Float:x, Float:y, Float:z, money = GetPlayerMoney(targetid);
	GetPlayerPos(targetid, x, y, z);

	if(sscanf(params, "u", targetid)) return SendClientMessage(playerid, -1, "SERVER: /rob <playerid>");
	if(!IsPlayerConnected(targetid) || targetid == playerid) return SendClientMessage(playerid, -1, "SERVER: Target ID is offline/yourself.");

	if(!IsPlayerInRangeOfPoint(playerid, 5, x, y, z)) return SendClientMessage(playerid, -1, "SERVER: Target ID is not in range.");
	if(GetPlayerMoney(targetid) < 1) return SendClientMessage(playerid, -1, "SERVER: Target ID doesn't have any cash.");
	if(pInfo[targetid][pWallet] == 0) return SendClientMessage(playerid, -1, "SERVER: Target ID doesn't have any wallet to be robbed.");
	if(pInfo[playerid][pWallet] == 0) return SendClientMessage(playerid, -1, "SERVER: You don't have wallet to store robbed money. (/buywallet)");

 	if(rob == 0 || rob == 2 || rob == 4 || rob == 6 || rob == 8 || rob == 10)
	{
		new name[MAX_PLAYER_NAME], string[150], tname[MAX_PLAYER_NAME];
		GetPlayerName(playerid, name, sizeof(name));
		GetPlayerName(targetid, tname, sizeof(tname));

        GivePlayerMoney(playerid, money);
        GivePlayerMoney(targetid, -money);
        format(string, sizeof(string), "You robbed %d$ from %s(%d). If player kills you then you'll loose money you've robbed!", money, tname, targetid);
        SendClientMessage(playerid, -1, string);
        format(string,sizeof(string), "%s(%d) has robbed your wallet containing '%d$'.", name, playerid, money);
        SendClientMessage(targetid, -1, string);
        SendClientMessage(targetid, -1, "Kill the player to regain your wallet before they hide it somewhere else you'll loose money.");
        pInfo[targetid][pWallet] = 0;
        rp[playerid] = 1;
        rp1[targetid] = 1;
        SetTimerEx("robbedplayer", 30000, false, "i", playerid);
        SetTimerEx("beingrobbed", 30000, false, "i", targetid);
    }
    else
    {
		new name[MAX_PLAYER_NAME], string[150], tname[MAX_PLAYER_NAME];
		GetPlayerName(playerid, name, sizeof(name));
		GetPlayerName(targetid, tname, sizeof(tname));
        SendClientMessage(playerid, -1, "Player noticed you robbing them, attempt failed.");
        format(string,sizeof(string), "%s(%d) tried to rob your wallet.", name, playerid);
        SendClientMessage(targetid, -1, string);
    }
	return 1;
}

CMD:wallet(playerid, params[])
{
	if(GetPlayerMoney(playerid) < buywallet) return SendClientMessage(playerid, -1, "SERVER: You don't have enough money to buy wallet");
	if(pInfo[playerid][pWallet] == 1)
	{
		new string [150];
		format(string,sizeof(string), "SERVER: You have a wallet containing '%d$'.", GetPlayerMoney(playerid));
		SendClientMessage(playerid, -1, string);
	}
	else
	{
		SendClientMessage(playerid, -1, "SERVER: You don't have a wallet. (/buywallet)");
	}
	return 1;
}

CMD:buywallet(playerid, params[])
{
	if(pInfo[playerid][pWallet] == 0)
	{
		new string [150];
		format(string,sizeof(string), "SERVER: You bought a wallet for '%d'.", buywallet);
		SendClientMessage(playerid, -1, string);
		GivePlayerMoney(playerid, -buywallet);
		pInfo[playerid][pWallet] = 1;
		new INI:File = INI_Open(UserPath(playerid));
		INI_SetTag(File,"WALLET-DATA");
		INI_WriteInt(File, "Wallet", 1);
		INI_Close(File);
	} else SendClientMessage(playerid, -1, "SERVER: You already have a wallet.");
	return 1;
}
//----------------------------------------------------------------------------//
// TEST COMMANDS FOR RCON ADMIN
//----------------------------------------------------------------------------//

CMD:givewallet(playerid, params[])
{
    if(IsPlayerAdmin(playerid))
	{
	    new targetid, tname[MAX_PLAYER_NAME], string [150];
	    GetPlayerName(targetid, tname, sizeof(tname));
	    if(sscanf(params, "u", targetid)) SendClientMessage(playerid, -1, "SERVER(A): /givewallet <playerid>");
	    else if(!IsPlayerConnected(targetid) || targetid == playerid) return SendClientMessage(playerid, -1, "SERVER: Target ID is offline/yourself.");
	    else
	    {
			if(pInfo[targetid][pWallet] == 1)
			{
				format(string,sizeof(string), "SERVER: %s(%d) already have a wallet.", tname, targetid);
				SendClientMessage(playerid, -1, string);
			}
			else
			{
				new string1 [150];
				format(string1,sizeof(string1), "SERVER: You've given %s(%d) a wallet.", tname, targetid);
				SendClientMessage(playerid, -1, string1);
				SendClientMessage(targetid, -1, "Administrator has given you a wallet.");
				pInfo[targetid][pWallet] = 1;
			}
   			if(IsPlayerConnected(targetid) || targetid == playerid)
   			{
				SendClientMessage(targetid, -1, "You've given yourself a wallet.");
				pInfo[targetid][pWallet] = 1;
			}
		}
	} else SendClientMessage(playerid, -1, "SERVER: Not Authorized!");
    return 1;
}

CMD:revokewallet(playerid, params[])
{
    if(IsPlayerAdmin(playerid))
	{
	    new targetid, tname[MAX_PLAYER_NAME], string [150];
	    GetPlayerName(targetid, tname, sizeof(tname));
	    if(sscanf(params, "u", targetid)) SendClientMessage(playerid, -1, "SERVER(A): /revokewallet <playerid>");
	    else if(!IsPlayerConnected(targetid) || targetid == playerid) return SendClientMessage(playerid, -1, "SERVER: Target ID is offline/yourself.");
	    else
	    {
			if(pInfo[targetid][pWallet] == 1)
			{
				format(string,sizeof(string), "SERVER: %s(%d) wallet has been revoked.", tname, targetid);
				SendClientMessage(playerid, -1, string);
				SendClientMessage(targetid, -1, "Administrator has revoked your wallet.");
				pInfo[targetid][pWallet] = 0;
			}
			else
			{
				new string1 [150];
				format(string1,sizeof(string1), "SERVER: %s(%d) doesn't own a wallet.", tname, targetid);
				SendClientMessage(playerid, -1, string1);
			}
		}
	} else SendClientMessage(playerid, -1, "SERVER: Not Authorized!");
    return 1;
}
//----------------------------------------------------------------------------//
stock UserPath(playerid)
{
    new string[128], vname[MAX_PLAYER_NAME];
    GetPlayerName(playerid, vname, sizeof(vname));
    format(string, sizeof(string), playerfile, vname);
    return string;
}

forward robbedplayer(playerid);
public robbedplayer(playerid)
{
	rp[playerid] = 0;
    SendClientMessage(playerid, -1, "You're safe now from loosing money you've just robbed by getting killed.");
    return 1;
}

forward beingrobbed(targetid);
public beingrobbed(targetid)
{
	rp1[targetid] = 0;
    SendClientMessage(targetid, -1, "You're no longer being able to recover your money by killing that person.");
    return 1;
}

forward SaveStats(playerid);
public SaveStats(playerid)
{
	new INI:File = INI_Open(UserPath(playerid));
	INI_SetTag(File,"WALLET-DATA");
	INI_WriteInt(File, "Wallet", pInfo[playerid][pWallet]);
	INI_WriteInt(File, "Cash", GetPlayerMoney(playerid));
	INI_Close(File);
}
