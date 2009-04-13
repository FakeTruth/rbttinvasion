class OutMessage extends UTLocalMessage;

var string OutString;

static function string GetString(
    optional int Switch,
    optional bool bPRI1HUD,
    optional PlayerReplicationInfo RelatedPRI_1, 
    optional PlayerReplicationInfo RelatedPRI_2,
    optional Object OptionalObject
    )
{
    return RelatedPRI_1.GetPlayerAlias()@default.OutString;
}

defaultproperties
{
    bIsUnique=False
    bIsConsoleMessage=False
    Lifetime=5

    DrawColor=(R=255,G=255,B=64,A=255)
    FontSize=3

    MessageArea=2
    
    OutString = "is OUT"
}