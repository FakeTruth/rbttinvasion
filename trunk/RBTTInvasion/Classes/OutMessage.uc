class OutMessage extends UTLocalMessage config(RBTTInvasion);

var config string OutString;

static function string GetString(
	optional int Switch,
	optional bool bPRI1HUD,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	// Just use ResMessage's function to save resources..
	return Class'ResMessage'.static.ReplaceText(default.OutString, "`name", RelatedPRI_1.GetPlayerAlias());
	//return RelatedPRI_1.GetPlayerAlias()@default.OutString; // FIXME, OutString must contain %PlayerName% and it'll get replaced by the player's name
}

defaultproperties
{
    bIsUnique=False
    bIsConsoleMessage=True
    Lifetime=5

    DrawColor=(R=255,G=255,B=64,A=255)
    FontSize=3

    MessageArea=2
    
    OutString = "`name is OUT"
}