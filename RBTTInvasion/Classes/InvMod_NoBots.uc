class InvMod_NoBots extends InvMod;

/**
 * Kill all the bots at the start of the wave
 */
function StartWave(GameRules G)
{
	local UTBot B;
	local UTGame Game;
	
	Game = UTGame(WorldInfo.Game);

    Game.DesiredPlayerCount = 0;
    Game.bPlayersVsBots = false;

	foreach WorldInfo.AllControllers(class'UTBot', B)
	{
		Game.KillBot(B);
	}

	Super.StartWave(G);
}

defaultproperties
{
}