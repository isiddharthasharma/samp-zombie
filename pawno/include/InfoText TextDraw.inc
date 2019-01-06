new Text:ShadInfoBox;
new ShadInfoBoxShowing[MAX_PLAYERS];
 
#define CLOSETIMER 15000
 
forward OnShadowInit();
public OnShadowInit()
{
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
 
stock ShadInfoBoxForPlayer(playerid, text[])
{
    TextDrawHideForPlayer(playerid, ShadInfoBox);
    SetTimerEx("CloseTextdraw", CLOSETIMER, false, "i", playerid);
   
    new string[250];
    ShadInfoBoxShowing[playerid] = 1;
    format(string, sizeof(string), "%s", text);
    TextDrawSetString(ShadInfoBox, string);
    return TextDrawShowForPlayer(playerid, ShadInfoBox);
}
 
forward CloseTextdraw(playerid);
public CloseTextdraw(playerid)
{
    TextDrawHideForPlayer(playerid, ShadInfoBox);
}
