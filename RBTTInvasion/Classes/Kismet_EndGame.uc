class Kismet_EndGame extends SequenceAction;

var Actor Instigator;
var GameInfo Game;

/**
 * Called when this event is activated.
 */
event Activated()
{
	local Controller C;
	local PlayerReplicationInfo Winner;

	Game = GetWorldInfo().Game;
	if(Game == None)
		return;
	
	C = GetController(Instigator);
	if(C != None)
	{
		Winner = C.PlayerReplicationInfo;
	}
		`log("Kismet_EndGame.C was none!!");
	
	EndGame(Winner,"");
}

/**
 * Modified EndGame function taken from GameInfo to ignore all checks
 * This EndGame node is absolute, this WILL end the game NO MATTER WHAT!!! Dumm dum dum dummmmm
 */
function EndGame( PlayerReplicationInfo Winner, string Reason )
{
	local int Index, i;
	local Sequence GameSequence;
	local array<SequenceObject> Events;
	
	CheckEndGame(Winner, Reason);
	
	// The non-arbitrated route, the server writes all stats
	if (!Game.bUsingArbitration)
	{
		// Write out any online stats
		Game.WriteOnlineStats();
		// Write the player data used in determining skill ratings
		Game.WriteOnlinePlayerScores();
		// Have clients end their games
		Game.GameReplicationInfo.EndGame();
		// Server is handled here
		Game.GameInterface.EndOnlineGame();
	}
	// Arbitrated matches require all participants to report stats
	// This is handled in the end game handshaking process
	else
	{
		Game.GameReplicationInfo.bMatchIsOver = true;
		if (Game.bNeedsEndGameHandshake)
		{
			// Iterate through the inactive list and send them to the clients
			for (Index = 0; Index < Game.InactivePRIArray.Length; Index++)
			{
				Game.InactivePRIArray[Index].bIsInactive = true;
				Game.InactivePRIArray[Index].RemoteRole = Game.InactivePRIArray[Index].default.RemoteRole;
			}
			// Delay a bit so that replication can happen before processing
			Game.SetTimer(2.0,false,'ProcessEndGameHandshake');
			Game.bNeedsEndGameHandshake = false;
			Game.bIsEndGameHandshakeComplete = false;
		}
	}

	Game.bGameEnded = true;
	
	/** Below is from UTGame **/
	
	// trigger any Kismet "Game Ended" events
	GameSequence = GetWorldInfo().GetGameSequence();
	if (GameSequence != None)
	{
		GameSequence.FindSeqObjectsByClass(class'UTSeqEvent_GameEnded', true, Events);
		for (i = 0; i < Events.length; i++)
		{
			UTSeqEvent_GameEnded(Events[i]).CheckActivate(Game, None);
		}
	}
	GotoState('MatchOver');
}

/**
 * Modified CheckEndGame function taken from UTGame
 */
function CheckEndGame(PlayerReplicationInfo Winner, string Reason)
{
	local Controller P;
	local UTGame UTG;

	UTG = UTGame(Game);
	
	Game.CheckModifiedEndGame(Winner, Reason);

	if ( Winner == None )
	{
		// find winner
		foreach GetWorldInfo().AllControllers(class'Controller', P)
		{
			if ( P.bIsPlayer && !P.PlayerReplicationInfo.bOutOfLives
				&& ((Winner == None) || (P.PlayerReplicationInfo.Score >= Winner.Score)) )
			{
				Winner = P.PlayerReplicationInfo;
			}
		}
	}

	if(UTG != None)
		UTG.EndTime = UTG.WorldInfo.RealTimeSeconds + UTG.EndTimeDelay;
	Game.GameReplicationInfo.Winner = Winner;

	if(UTG != None)
		UTG.SetEndGameFocus(Winner);
}

defaultproperties
{
	ObjName="End the game"
	ObjCategory="RBTTInvasion"

	bCallHandler=false
	
	VariableLinks(0)=(ExpectedType=class'SeqVar_Object',LinkDesc="Winner",bWriteable=true,PropertyName=Instigator)
}