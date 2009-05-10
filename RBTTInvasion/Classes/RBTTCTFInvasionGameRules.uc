class RBTTCTFInvasionGameRules extends RBTTInvasionGameRules;


function MatchStarting()
{
	local UTTeamPlayerStart P;
	
	`log("CTF RULES YEAHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH");
	
	//#### GET SPAWNPOINTS FOR MONSTERS ####\\
	foreach WorldInfo.AllNavigationPoints(class'UTTeamPlayerStart', P)
	{
		if(P.TeamNumber == 1)			// Blue/Monster team
			MonsterSpawnPoints.AddItem(P);
	}
	
	//#### GET CURRENT WAVE FROM MUTATOR ####\\
	CurrentWave = InvasionMut.CurrentWave;
	
	//#### GET MONSTERTABLE FROM MUTATOR ####\\
	MonsterTable = InvasionMut.MonsterTable;
	
	CreateMonsterTeam();
	SetTimer(1, true, 'InvasionTimer'); 		// InvasionTimer gets called once every second
	LastPortalTime = WorldInfo.TimeSeconds;	 	// Spawn portal after PortalSpawnInterval seconds
	GotoState('BetweenWaves'); 			// Initially start counting down for the first wave.
}


defaultproperties
{

}