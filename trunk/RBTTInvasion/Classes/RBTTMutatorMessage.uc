class RBTTMutatorMessage extends UTLocalMessage
	abstract;

var color AddColor, RemoveColor;
	
static function string GetString( optional int Switch, optional bool bPRI1HUD, optional PlayerReplicationInfo RelatedPRI_1,
					optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject )
{
	local String MessageString;


	if(Switch == 0)
		MessageString = "removed";
	else
		MessageString = "added";
	
	return "Mutator"@OptionalObject@"was"@MessageString;
}

static function color GetColor(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	if(Switch == 0)
		return Default.RemoveColor;
	else
		return Default.AddColor;
}

static function int GetFontSize( int Switch, PlayerReplicationInfo RelatedPRI1, PlayerReplicationInfo RelatedPRI2, PlayerReplicationInfo LocalPlayer )
{
	return default.FontSize;
}

defaultproperties
{
	FontSize=2
	Lifetime=5
	MessageArea=1
	bIsConsoleMessage=False
	bIsUnique=FALSE
	//bBeep=false
	DrawColor=(R=255,G=255,B=0,A=255)
	Addcolor=(R=255,G=255,B=0,A=255)
	RemoveColor=(R=128,G=128,B=255,A=255)
}
