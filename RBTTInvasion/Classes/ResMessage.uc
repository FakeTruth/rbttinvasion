class ResMessage extends UTLocalMessage config(RBTTInvasion);

var config string ResString;

static function string GetString(
	optional int Switch,
	optional bool bPRI1HUD,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	return ReplaceText(default.ResString, "`name", RelatedPRI_1.GetPlayerAlias());
}

// Slightly altered version of Actor::ReplaceText
static function string ReplaceText(string Text, string Replace, string With)
{
	local int i;
	local string Input;

	Input = Text;
	Text = "";
	i = InStr(Input, Replace);
	while(i != -1)
	{
		Text = Text $ Left(Input, i) $ With;
		Input = Mid(Input, i + Len(Replace));
		i = InStr(Input, Replace);
	}
	Text = Text $ Input;
	Return Text;
}

defaultproperties
{
	bIsUnique=False
	bIsConsoleMessage=True
	Lifetime=5
	
	DrawColor=(R=255,G=255,B=64,A=255)
	FontSize=2
	
	MessageArea=2
	
	ResString = "You have been resurrected by `name!"
}