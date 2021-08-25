#include <a_samp>
#include <fcnpc>
#include <YSI\y_timers>
#include <colandreas>

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
	
new Float:ZombieSpawns[][4] =
{
    //LS
    {1751.1097,-2106.4529,13.5469,183.1979}, // El-Corona - Outside random house
    {2652.6418,-1989.9175,13.9988,182.7107}, // Random house in willowfield - near playa de seville and stadium
    {2489.5225,-1957.9258,13.5881,2.3440}, // Hotel in willowfield - near cluckin bell
    {2689.5203,-1695.9354,10.0517,39.5312}, // Outside stadium - lots of cars
    {2770.5393,-1628.3069,12.1775,4.9637}, // South in east beach - north of stadium - carparks nearby
    {2807.9282,-1176.8883,25.3805,173.6018}, // North in east beach - near apartments
    {2552.5417,-958.0850,82.6345,280.2542}, // Random house north of Las Colinas
    {2232.1309,-1159.5679,25.8906,103.2939}, // Jefferson motel
    {2388.1003,-1279.8933,25.1291,94.3321}, // House south of pig pen
    {2481.1885,-1536.7186,24.1467,273.4944}, // East LS - near clucking bell and car wash
    {2495.0720,-1687.5278,13.5150,359.6696}, // Outside CJ's house - lots of cars nearby
    {2306.8252,-1675.4340,13.9221,2.6271}, // House in ganton - lots of cars nearby
    {2191.8403,-1455.8251,25.5391,267.9925}, // House in south jefferson - lots of cars nearby
    {1830.1359,-1092.1849,23.8656,94.0113}, // Mulholland intersection carpark
    {2015.3630,-1717.2535,13.5547,93.3655}, // Idlewood house
    {1654.7091,-1656.8516,22.5156,177.9729}, // Right next to PD
    {1127.6726,-2037.4873,69.8059,271.5750}, // Conference Center
    {1508.6849,-1059.0846,25.0625,1.8058}, // Across the street of BANK - lots of cars in intersection carpark
    {1421.0819,-885.3383,50.6531,3.6516}, // Outside house in vinewood
    {1133.8237,-1272.1558,13.5469,192.4113}, // Near hospital
    {1235.2196,-1608.6111,13.5469,181.2655}, // Backalley west of mainstreet
    {590.4648,-1252.2269,18.2116,25.0473}, // Outside "BAnk of San Andreas"
    {842.5260,-1007.7679,28.4185,213.9953}, // North of Graveyard
    {911.9332,-1232.6490,16.9766,5.2999}, // LS Film Studio
    {477.6021,-1496.6207,20.4345,266.9252}, // Rodeo Place
    {255.4621,-1366.3256,53.1094,312.0852}, // Outside propery in richman
    {281.5446,-1261.4562,73.9319,305.0017}, // Another richman property
    {790.1918,-839.8533,60.6328,191.9514}, // Mulholland house
    {1299.1859,-801.4249,84.1406,269.5274}, // Maddoggs
    {1240.3170,-2036.6886,59.9575,276.4659}, // Verdant Bluffs
    {2215.5181,-2627.8174,13.5469,273.7786}, // Ocean docks 1
    {2509.4346,-2637.6543,13.6453,358.3565}, // Ocean Docks spawn 2

    //LV
    {1435.8024,2662.3647,11.3926,1.1650}, //  Northern train station
    {1457.4762,2773.4868,10.8203,272.2754}, //  Northern golf club
    {1739.6390,2803.0569,14.2735,285.3929}, //  Northern housing estate 1
    {1870.3096,2785.2471,14.2734,42.3102}, //  Northern housing estate 2
    {1959.7142,2754.6863,10.8203,181.4731}, //  Northern house 1
    {2314.2556,2759.4504,10.8203,93.2711}, //  Northern industrial estate 1
    {2216.5674,2715.0334,10.8130,267.6540}, //  Northern industrial estate 2
    {2101.4192,2678.7874,10.8130,92.0607}, //  Northern near railway line
    {1951.1090,2660.3877,10.8203,180.8461}, //  Northern house 2
    {1666.6949,2604.9861,10.8203,179.8495}, //  Northern house 3
    {2808.3367,2421.5107,11.0625,136.2060}, //  Northern shopping centre
    {2633.3203,2349.7061,10.6719,178.7175}, //  V-Rock
    {2606.6348,2161.7490,10.8203,88.7508}, //  South V-Rock
    {2616.5286,2100.6226,10.8158,177.7834}, //  North Ammunation 1
    {2491.8816,2397.9370,10.8203,266.6003}, //  North carpark 1
    {2531.7891,2530.3223,21.8750,91.6686}, //  North carpark 2
    {2340.6677,2530.4324,10.8203,177.8630}, //  North Pizza Stack
    {2097.6855,2491.3313,14.8390,181.8117}, //  Emerald Isle
    {1893.1000,2423.2412,11.1782,269.4385}, //  Souvenir shop
    {1698.9330,2241.8320,10.8203,357.8584}, //  Northern casino
    {1479.4559,2249.0769,11.0234,306.3790}, //  Baseball stadium 1
    {1298.1548,2083.4016,10.8127,256.7034}, //  Baseball stadium 2
    {1117.8785,2304.1514,10.8203,81.5490}, //  North carparks
    {1108.9878,1705.8639,10.8203,0.6785}, //  Dirtring racing 1
    {1423.9780,1034.4188,10.8203,90.9590}, //  Sumo
    {1537.4377,752.0641,11.0234,271.6893}, //  Church
    {1917.9590,702.6984,11.1328,359.2682}, //  Southern housing estate
    {2089.4785,658.0414,11.2707,357.3572}, //  Southern house 1
    {2489.8286,928.3251,10.8280,67.2245}, //  Wedding chapel
    {2697.4717,856.4916,9.8360,267.0983}, //  Southern construction site
    {2845.6104,1288.1444,11.3906,3.6506}, //  Southern train station
    {2437.9370,1293.1442,10.8203,86.3830}, //  Wedding chapel (near Pyramid)
    {2299.5430,1451.4177,10.8203,269.1287}, //  Carpark (near Pyramid)
    {2214.3008,2041.9165,10.8203,268.7626}, //  Central parking lot
    {2005.9174,2152.0835,10.8203,270.1372}, //  Central motel
    {2222.1042,1837.4220,10.8203,88.6461}, //  Clowns Pocket
    {2025.6753,1916.4363,12.3382,272.5852}, //  The Visage
    {2087.9902,1516.5336,10.8203,48.9300}, //  Royal Casino
    {2172.1624,1398.7496,11.0625,91.3783}, //  Auto Bahn
    {2139.1841,987.7975,10.8203,0.2315}, //  Come-a-lot
    {1860.9672,1030.2910,10.8203,271.6988}, //  Behind 4 Dragons
    {1673.2345,1316.1067,10.8203,177.7294}, //  Airport carpark
    {1412.6187,2000.0596,14.7396,271.3568}, //  South baseball stadium houses

    //SF
    {-2723.4639,-314.8138,7.1839,43.5562},  // golf course spawn
    {-2694.5344,64.5550,4.3359,95.0190},  // in front of a house
    {-2458.2000,134.5419,35.1719,303.9446},  // hotel
    {-2796.6589,219.5733,7.1875,88.8288},  // house
    {-2706.5261,397.7129,4.3672,179.8611},  // park
    {-2866.7683,691.9363,23.4989,286.3060},  // house
    {-2764.9543,785.6434,52.7813,357.6817},  // donut shop
    {-2660.9402,883.2115,79.7738,357.4440},  // house
    {-2861.0796,1047.7109,33.6068,188.2750}, //  parking lot
    {-2629.2009,1383.1367,7.1833,179.7006},  // parking lot at the bridge
    {-2079.6802,1430.0189,7.1016,177.6486},  // pier
    {-1660.2294,1382.6698,9.8047,136.2952}, //  pier 69
    {-1674.1964,430.3246,7.1797,226.1357},  // gas station]
    {-1954.9982,141.8080,27.1747,277.7342},  // train station
    {-1956.1447,287.1091,35.4688,90.4465},  // car shop
    {-1888.1117,615.7245,35.1719,128.4498},  // random
    {-1922.5566,886.8939,35.3359,272.1293},  // random
    {-1983.3458,1117.0645,53.1243,271.2390},  // church
    {-2417.6458,970.1491,45.2969,269.3676},  // gas station
    {-2108.0171,902.8030,76.5792,5.7139},  // house
    {-2097.5664,658.0771,52.3672,270.4487},  // random
    {-2263.6650,393.7423,34.7708,136.4152},  // random
    {-2287.5027,149.1875,35.3125,266.3989},  // baseball parking lot
    {-2039.3571,-97.7205,35.1641,7.4744},  // driving school
    {-1867.5022,-141.9203,11.8984,22.4499},  // factory
    {-1537.8992,116.0441,17.3226,120.8537},  // docks ship
    {-1708.4763,7.0187,3.5489,319.3260},  // docks hangar
    {-1427.0858,-288.9430,14.1484,137.0812},  // airport
    {-2173.0654,-392.7444,35.3359,237.0159},  // stadium
    {-2320.5286,-180.3870,35.3135,179.6980},  // burger shot
    {-2930.0049,487.2518,4.9141,3.8258}  // harbor
};

public OnFilterScriptInit()
{
	CA_Init(); //ColAndreas
	CreationTimer = SetTimer("CreateZombies", 50, true);
	ShowPlayerMarkers(0); //Comment this if you want to see zombies on your radar
	return 1;
}

public CreateZombies(newkeys)
{
	new string[50], zombie, SpawnRandom = random(sizeof(ZombieSpawns));
	if(SpawnedZombies < MAX_ZOMBIES)
	{
		format(string,sizeof(string),"Zombie(%d)",MAX_PLAYERS-(SpawnedZombies));
		zombie = FCNPC_Create(string);

		ZombieLabel[zombie] = Create3DTextLabel("Zombie\n••••••••••", ZOMBIE_COLOR, 30.0, 40.0, 50.0, 60.0, -1, 0);
		Attach3DTextLabelToPlayer(ZombieLabel[zombie], zombie, 0.0, 0.0, 0.4);

		FCNPC_Spawn(zombie,ZOMBIE_SKIN,ZombieSpawns[SpawnRandom][0],ZombieSpawns[SpawnRandom][1],ZombieSpawns[SpawnRandom][2]);

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
	new Rand = random(9), spawn = random(sizeof(ZombieSpawns));
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
	FCNPC_SetPosition(npcid, ZombieSpawns[spawn][0], ZombieSpawns[spawn][1], ZombieSpawns[spawn][2]);
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
