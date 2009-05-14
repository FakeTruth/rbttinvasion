Class MonsterFactory extends SequenceAction;

var() class<Pawn> PawnClass;
var() NavigationPoint SpawnPoint;


/**
 * Called when this event is activated.
 */
event Activated()
{
	SpawnMonster(PawnClass);
}

/**
 * Called when this event is deactivated.
 */
event Deactivated();

// Spawn a monster of given class at given location
function bool SpawnMonster(class<Pawn> P, optional Rotator SpawnRotation)
{
	local Pawn NewMonster;
	local UTTeamGame Game;
	local Controller Bot;
	local CharacterInfo MonsterBotInfo;
	local UTTeamInfo RBTTMonsterTeamInfo;
	local PlayerReplicationInfo PRI;
	local string MonsterName;
	
	`log(">>>>>>>>>>>>>>>>>>RBTTInvasionGameRules.SpawnMonster<<<<<<<<<<<<<<<<<<<<");
	//`log(">>>>>>>>>>>>>>>>>> NumMonsters("@NumMonsters@") < MaxMonsters("@WaveConfig[CurrentWave].MaxMonsters@") <<<<<<<<<<<<<<<<<<<<<");
	NewMonster = SpawnPoint.Spawn(P,,,SpawnPoint.Location+(P.Default.CylinderComponent.CollisionHeight)* vect(0,0,1), SpawnPoint.Rotation);
	
	if (NewMonster != None)
	{
		PRI = NewMonster.PlayerReplicationInfo;
		Game = UTTeamGame(SpawnPoint.WorldInfo.Game);
		
		if( Game == None )
		{
			return false;
			NewMonster.Destroy();
		}
		
		//NewMonster.health*=WaveConfig[CurrentWave].MonsterHealthMultiplier;
		
		if(UTCTFGame(Game) != None)
		{
			NewMonster.bCanPickupInventory = True; // FOR CTF GAMES, OTHERWISE THEY CAN'T PICK UP TEH FLAG
		}
		
		Bot = NewMonster.Controller;
		
		if ( NewMonster.IsA('RBTTMonster') )
		{
			MonsterName = RBTTMonster(NewMonster).MonsterName;
			MonsterBotInfo = Game.Teams[1].GetBotInfo(MonsterName);
			RBTTMonsterController(Bot).Initialize(RBTTMonster(NewMonster).MonsterSkill, MonsterBotInfo);
			RBTTMonster(NewMonster).Initialize();
			PRI.PlayerName = MonsterName;
			`log("Setting MonsterName to" @ MonsterBotInfo.CharName @ "Was Successful");
			RBTTMonsterController(Bot).bUseObjectives = (UTCTFGame(Game) != None); // FOR CTF GAMES
		}
		
		if(PRI != None)
		{
			RBTTMonsterTeamInfo=Game.Teams[1];
			RBTTMonsterTeamInfo.AddToTeam(Bot);
			`log("PRI.Team.TeamIndex = "@PRI.Team.TeamIndex@"");
			RBTTMonsterTeamInfo.SetBotOrders(UTBot(Bot));
		}
		
		if(UTPawn(NewMonster) != None)
			UTPawn(NewMonster).SpawnTransEffect(0);
		return True;
	}
	else
		return false;
}

defaultproperties
{
	ObjName="RBTTMonster Factory"
	ObjCategory="Actor"


}