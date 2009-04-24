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
    return RelatedPRI_1.GetPlayerAlias()@default.OutString; // FIXME, OutString must contain %PlayerName% and it'll get replaced by the player's name
}

defaultproperties
{
   OutString="is OUT"
   MessageArea=2
   Lifetime=5.000000
   DrawColor=(B=64,G=255,R=255,A=255)
   FontSize=3
   Name="Default__OutMessage"
   ObjectArchetype=UTLocalMessage'UTGame.Default__UTLocalMessage'
}
