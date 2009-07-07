class Kismet_GetPlayerCount extends SequenceAction;

var int HumanPlayers;
var int BotPlayers;

/**
 * Called when this event is activated.
 */
event Activated()
{
	local GameInfo Game;

	Game = GetWorldInfo().Game;
	
	HumanPlayers = Game.NumPlayers;
	BotPlayers = Game.NumBots;
}

defaultproperties
{
	ObjName="Get PlayerCount"
	ObjCategory="RBTTInvasion"

	bCallHandler=false
	
	VariableLinks(1)=(ExpectedType=class'SeqVar_Int',LinkDesc="Human Players",bWriteable=true,PropertyName=HumanPlayers)
	VariableLinks(2)=(ExpectedType=class'SeqVar_Int',LinkDesc="Bots",bWriteable=true,PropertyName=BotPlayers)
}