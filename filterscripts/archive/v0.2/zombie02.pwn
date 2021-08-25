/* Zombie A.I
Code Name: ZAIv02MA
Base: MapAndreas
NPC Engine: FCNPC
Version: 0.2
*/
a
#include <a_samp>
#include <fcnpc>
#include <YSI\y_timers>
#include <mapandreas>

#define MAX_ZOMBIES     250
#define ZOMBIE_RANGE 	25.0
#define ZOMBIE_SKIN 	162
#define ZOMBIE_HEALTH   100
#define ZOMBIE_COLOR    (0xFF0000FF)

forward CreateZombies(newkeys);
forward OnPlayerKillZombie(playerid, zombieid);
forward ResetDetectRange(playerid);
forward ZombieHealthLabel(npcid);

new SpawnedZombies = 0,
	CreationTimer,
	IsAZombie[MAX_PLAYERS],
	Text3D:ZombieLabel[MAX_PLAYERS],
	Timer:ZombieTimer[MAX_PLAYERS],
	HumanFound[MAX_PLAYERS];

public OnFilterScriptInit()
{
	MapAndreas_Init(MAP_ANDREAS_MODE_FULL); //MapAndreas
	CreationTimer = SetTimer("CreateZombies", 50, true);
	ShowPlayerMarkers(0); //Comment this if you want to see zombies on your radar
	return 1;
}

public CreateZombies(newkeys)
{
	new string[50], zombie;
	if(SpawnedZombies < MAX_ZOMBIES)
	{
		format(string,sizeof(string),"Zombie(%d)",MAX_PLAYERS-(SpawnedZombies));
		zombie = FCNPC_Create(string);

		ZombieLabel[zombie] = Create3DTextLabel("Zombie\n••••••••••", ZOMBIE_COLOR, 30.0, 40.0, 50.0, 60.0, -1, 0);
		Attach3DTextLabelToPlayer(ZombieLabel[zombie], zombie, 0.0, 0.0, 0.4);

		new	Float:pos[3], x=random(4000)-2000, y=random(4000)-2000, Float:z;
		for(new a; a < 100; a++)
		{
			MapAndreas_FindZ_For2DCoord(x, y, z);
			if(z >= 5.0 && z < 30.0)
			{
				pos[0] = x;
				pos[1] = y;
				pos[2] = z;
				FCNPC_Spawn(zombie, ZOMBIE_SKIN, x, y, z);
				break;
			}
		}

  		new Rand = random(9);
	    switch(Rand)
	    {
		    case 0: FCNPC_SetWeapon(zombie, 1);
		    case 1: FCNPC_SetWeapon(zombie, 2);
		    case 2: FCNPC_SetWeapon(zombie, 3);
		    case 3: FCNPC_SetWeapon(zombie, 4);
		    case 4: FCNPC_SetWeapon(zombie, 5);
		    case 5: FCNPC_SetWeapon(zombie, 6);
		    case 6: FCNPC_SetWeapon(zombie, 7);
		    case 7: FCNPC_SetWeapon(zombie, 8);
		    case 8: FCNPC_SetWeapon(zombie, 15);
	    }
		FCNPC_SetHealth(zombie, ZOMBIE_HEALTH);

  		ZombieTimer[zombie] = repeat MoveZombie(zombie, newkeys);
		SetPlayerColor(zombie,ZOMBIE_COLOR);
		IsAZombie[zombie] = 1;
		SpawnedZombies++;
	}
	else
	{
		KillTimer(CreationTimer);
		printf("Zombies creation done!");
	}
	return 1;
}

public OnPlayerDeath(playerid, killerid, reason)
{
	return 1;
}

public FCNPC_OnDeath(npcid, killerid, reason)
{
	HumanFound[npcid] = 0;
    SendDeathMessage(killerid, npcid, reason);
 	ApplyAnimation(npcid, "PED", "BIKE_fall_off", 4.1, 0, 1, 1, 1, 0, 1);
	CallLocalFunction("OnPlayerKillZombie","ii", killerid, npcid);
	return 1;
}

public FCNPC_OnTakeDamage(npcid, issuerid, Float:amount, weaponid, bodypart)
{
    switch(weaponid)
    {
        case 24: //DesertEagle
        {
			FCNPC_SetHealth(npcid, FCNPC_GetHealth(npcid)-50);
        }
        case 32: //Tec9
        {
			FCNPC_SetHealth(npcid, FCNPC_GetHealth(npcid)-10);
		}
        case 22: //Colt45
        {
			FCNPC_SetHealth(npcid, FCNPC_GetHealth(npcid)-50);
        }
        case 28: //UZI
        {
			FCNPC_SetHealth(npcid, FCNPC_GetHealth(npcid)-10);
        }
        case 23: //Silenced
        {
			FCNPC_SetHealth(npcid, FCNPC_GetHealth(npcid)-50);
        }
        case 31: //M4
        {
			FCNPC_SetHealth(npcid, FCNPC_GetHealth(npcid)-35);
        }
        case 30: //AK
        {
			FCNPC_SetHealth(npcid, FCNPC_GetHealth(npcid)-40);
        }
        case 29: //MP5
        {
			FCNPC_SetHealth(npcid, FCNPC_GetHealth(npcid)-18);
        }
        case 34: //Sniper
        {
			FCNPC_SetHealth(npcid, FCNPC_GetHealth(npcid)-300);
        }
		case 33: //CuntGun
        {
			FCNPC_SetHealth(npcid, FCNPC_GetHealth(npcid)-35);
        }
        case 25: //PumpShotGun
        {
			FCNPC_SetHealth(npcid, FCNPC_GetHealth(npcid)-90);
        }
   		case 27: //Spaz12
        {
			FCNPC_SetHealth(npcid, FCNPC_GetHealth(npcid)-70);
		}
	}
	if(weaponid >= 22 && weaponid <= 38 && bodypart == 9)
	{
  		FCNPC_SetHealth(npcid, 0);
		GameTextForPlayer(issuerid, "~r~HEADSHOT",3000,4);
	}
	if(weaponid == 38 && !IsPlayerAdmin(issuerid))
	{
		Ban(issuerid);
	}
    if(GetPlayerState(issuerid) == PLAYER_STATE_DRIVER)
    {
        FCNPC_SetHealth(npcid, FCNPC_GetHealth(npcid)-70);
        ApplyAnimation(npcid, "PED", "BIKE_fall_off", 4.1, 0, 1, 1, 1, 0, 1);
    }
	ZombieHealthLabel(npcid);
	return 1;
}


public OnPlayerTakeDamage(playerid, issuerid, Float: amount, weaponid)
{
    new Float:HP;
    GetPlayerHealth(playerid, HP);
    switch(weaponid)
    {
        case 0:
        {
			SetPlayerHealth(playerid, HP-1);
        }
        case 1:
        {
            SetPlayerHealth(playerid, HP-7);
        }
        case 2:
        {
            SetPlayerHealth(playerid, HP-9);
        }
        case 3:
        {
        	SetPlayerHealth(playerid, HP-8);
        }
        case 4:
        {
        	SetPlayerHealth(playerid, HP-10);
        }
        case 5:
        {
        	SetPlayerHealth(playerid, HP-8);
        }
        case 6:
        {
        	SetPlayerHealth(playerid, HP-9);
        }
        case 7:
        {
        	SetPlayerHealth(playerid, HP-7);
        }
        case 8:
        {
        	SetPlayerHealth(playerid, HP-10);
        }
        case 15:
		{
			SetPlayerHealth(playerid, HP-5);
		}
	}
    return 1;
}

timer MoveZombie[100](zombieid, newkeys)
{
	new Float:xa,Float:ya,Float:za;
	if(FCNPC_IsDead(zombieid)) return 1;
    foreach(new playerid : Player)
	{
		GetPlayerPos(playerid,xa,ya,za);
        if(IsPlayerInRangeOfPoint(zombieid,1.0, xa, ya, za))
		{
			HumanFound[zombieid] = 2;
			FCNPC_MeleeAttack(zombieid,100);
			break;
		}
		else if(IsPlayerInRangeOfPoint(zombieid, ZOMBIE_RANGE / 4, xa, ya, za) || GetPlayerSpecialAction(zombieid) == SPECIAL_ACTION_DUCK)
  		{
			if(HumanFound[zombieid] == 2)
			{
				FCNPC_StopAttack(zombieid);
			}
			HumanFound[zombieid] = 1;
			FCNPC_GoTo(zombieid, xa, ya, za, FCNPC_MOVE_TYPE_RUN);
			break;
		}
		else if(IsPlayerInRangeOfPoint(zombieid, ZOMBIE_RANGE, xa, ya, za))
		{
			if(HumanFound[zombieid] == 2)
			{
				FCNPC_Stop(zombieid);
				FCNPC_StopAttack(zombieid);
			}
			HumanFound[zombieid] = 1;
			FCNPC_GoToPlayerEx(zombieid, playerid, 5, 5, FCNPC_MOVE_TYPE_RUN);
			break;
		}
		else if(IsPlayerInRangeOfPoint(zombieid, ZOMBIE_RANGE, xa, ya, za))
		{
			if(HumanFound[zombieid] == 2)
			{
				FCNPC_Stop(zombieid);
				FCNPC_StopAttack(zombieid);
			}
			HumanFound[zombieid] = 1;
			FCNPC_GoToPlayerEx(zombieid, playerid, 5, 5, FCNPC_MOVE_TYPE_RUN);
			break;
		}
		else if(IsPlayerInRangeOfPoint(zombieid, ZOMBIE_RANGE * 2 , xa, ya, za) || newkeys & KEY_SPRINT)
		{
			if(HumanFound[zombieid] == 2)
			{
				FCNPC_Stop(zombieid);
				FCNPC_StopAttack(zombieid);
			}
			HumanFound[zombieid] = 1;
			FCNPC_GoToPlayerEx(zombieid, playerid, 5, 5, FCNPC_MOVE_TYPE_RUN);
			break;
		}
		else if(IsPlayerInRangeOfPoint(zombieid, ZOMBIE_RANGE * 5, xa, ya, za) || GetPlayerWeapon(playerid) == 22 && GetPlayerWeapon(playerid) >= 23 && GetPlayerWeapon(playerid) <= 38)
		{
			if(HumanFound[zombieid] == 2)
			{
				FCNPC_Stop(zombieid);
				FCNPC_StopAttack(zombieid);
			}
			HumanFound[zombieid] = 1;
			FCNPC_GoToPlayerEx(zombieid, playerid, 5, 5, FCNPC_MOVE_TYPE_RUN);
			break;
		}
		else
		{
  			HumanFound[zombieid] = 0;
			new Float:x, Float:y, Float:z;
			GetPlayerPos(zombieid, x, y, z);
			FCNPC_StopAttack(zombieid);
			if(HumanFound[zombieid] == 0)
			{
				new pos = random(6);
				if(pos == 0) { x = x + 100.0; }
				else if(pos == 1) { x = x - 100.0; }
				else if(pos == 2) { y = y + 100.0; }
				else if(pos == 3) { y = y - 100.0; }
   				else if(pos == 4) { z = z + 100.0; }
				else if(pos == 5) { z = z - 100.0; }

				FCNPC_SetKeys(zombieid, 0, 0, 0);
				FCNPC_GoTo(zombieid, x, y, z, FCNPC_MOVE_TYPE_WALK);
            }
		}
	}
	return 1;
}

public ZombieHealthLabel(npcid)
{
    new Float:HP = FCNPC_GetHealth(npcid), dots[64];
    if(HP >= 100)
        dots = "Zombie\n••••••••••";
    else if(HP >= 90)
        dots = "Zombie\n•••••••••{660000}•";
    else if(HP >= 80)
        dots = "Zombie\n••••••••{660000}••";
    else if(HP >= 70)
        dots = "Zombie\n•••••••{660000}•••";
    else if(HP >= 60)
        dots = "Zombie\n••••••{660000}••••";
    else if(HP >= 50)
        dots = "Zombie\n•••••{660000}•••••";
    else if(HP >= 40)
        dots = "Zombie\n••••{660000}••••••";
    else if(HP >= 30)
        dots = "Zombie\n•••{660000}•••••••";
    else if(HP >= 20)
        dots = "Zombie\n••{660000}••••••••";
    else if(HP >= 10)
        dots = "Zombie\n•{660000}•••••••••";
    else if(HP >= 0)
        dots = "Zombie\n{660000}••••••••••";
    Update3DTextLabelText(ZombieLabel[npcid], ZOMBIE_COLOR, dots);
    return 1;
}

public OnPlayerKillZombie(playerid, zombieid)
{
	FCNPC_Respawn(zombieid);
	return 1;
}

public FCNPC_OnRespawn(npcid)
{
	new Rand = random(9);
    switch(Rand)
    {
	    case 0: FCNPC_SetWeapon(npcid, 1);
	    case 1: FCNPC_SetWeapon(npcid, 2);
	    case 2: FCNPC_SetWeapon(npcid, 3);
	    case 3: FCNPC_SetWeapon(npcid, 4);
	    case 4: FCNPC_SetWeapon(npcid, 5);
	    case 5: FCNPC_SetWeapon(npcid, 6);
	    case 6: FCNPC_SetWeapon(npcid, 7);
	    case 7: FCNPC_SetWeapon(npcid, 8);
	    case 8: FCNPC_SetWeapon(npcid, 15);
    }
	new	Float:pos[3], x=random(4000)-2000, y=random(4000)-2000, Float:z;
	for(new a; a < 100; a++)
	{
		MapAndreas_FindZ_For2DCoord(x, y, z);
		if(z >= 5.0 && z < 30.0)
		{
			pos[0] = x;
			pos[1] = y;
			pos[2] = z;
			FCNPC_SetPosition(npcid, x, y, z);
			break;
		}
	}
	return 1;
}

stock FCNPC_GoToPlayerEx(npcid, playerid, Float:dist, Float:rangle, movetype = FCNPC_MOVE_TYPE_RUN)
{
	new Float:xa, Float:ya, Float:za, Float:fa;
	GetPlayerPos(playerid, xa, ya, za);
	GetPlayerFacingAngle(playerid, fa);
	rangle += fa;
	xa = (xa + dist * floatsin(-rangle,degrees));
	ya = (ya + dist * floatcos(-rangle,degrees));
    FCNPC_GoTo(npcid, xa, ya, za,movetype, 0.4, true);
    return 1;
}
