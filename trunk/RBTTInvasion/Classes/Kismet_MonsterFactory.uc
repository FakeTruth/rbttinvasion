Class Kismet_MonsterFactory extends SeqAct_Latent;

enum EPointSelection
{
	/** Try each spawn point in a linear method */
	PS_Normal,
	/** Pick the first available randomly selected point */
	PS_Random,
	/** PS_Normal, but in reverse */
	PS_Reverse,
};

/** Method of spawn point selection */
var() EPointSelection		PointSelection;

var() class<Pawn> PawnClass;
var() array<Actor> SpawnPoint;
var Actor SpawnedMonster;
var() int SpawnCount;

/** Delay applied after creating an actor before creating the next one */
var() float SpawnDelay;

/** Last index used to spawn at, for PS_Normal/PS_Reverse */
var int LastSpawnIdx;

/** Number of actors spawned so far */
var int	SpawnedCount;

/** Remaining time before attempting the next spawn */
var float RemainingDelay;

var bool bPaused;

/**
 * Called when this event is activated.
 */
event Activated()
{
	`log("Activated!");
	if(InputLinks[0].bHasImpulse)
	{
		`log("Activated::DoSpawn");
		RemainingDelay = 0; // First spawn is immediate, if someone wants to delay this, use a Delay node!
		SpawnedCount = 0;
		LastSpawnIdx = -1;
	}
	if(InputLinks[3].bHasImpulse)
	{
		`log("Activated::bAborted");
		bAborted = True;
	}
}

/** script tick interface
 * the action deactivates when this function returns false and LatentActors is empty
 * @return whether the action needs to keep ticking
 */
event bool Update(float DeltaTime)
{
	`log("Update!!");
	if(InputLinks[2].bHasImpulse)
	{
		`log("Activated::Update Continues");
		bPaused = False;
	}
	if(InputLinks[1].bHasImpulse)
	{
		`log("MonsterFactory::Update is paused");
		bPaused = True;
	}
	if(InputLinks[3].bHasImpulse)
	{
		`log("MonsterFactory::Update is aborted!");
		return false;
	}
	if(bPaused)
	{
		return true;
	}
	//if(bAborted)
	//{
	//	`log("MonsterFactory::Update is aborted");
	//	return false;
	//}
	RemainingDelay -= DeltaTime;
	if(SpawnedCount >= SpawnCount)
	{
		`log("return false");
		`log("SpawnedCount:"@SpawnedCount@", SpawnCount:"@SpawnCount);
		return false;
	}
	else if(RemainingDelay <= 0)
	{
		`log("Update::DoSpawn");
		DoSpawn();
		`log("return true");
		`log("SpawnedCount:"@SpawnedCount@", SpawnCount:"@SpawnCount);
		return true;
	}
	
	return true;
}

function DoSpawn()
{
	local int SpawnIdx;
	
	Switch (PointSelection)
	{
		case PS_Reverse:
			SpawnIdx = LastSpawnIdx-1;
			if(SpawnIdx < 0)
				SpawnIdx = SpawnPoint.Length -1;
		break;
	
		case PS_Random:
			SpawnIdx = Rand(SpawnPoint.Length);
		break;
		
		Default:
			SpawnIdx = LastSpawnIdx+1;
			if(SpawnIdx > SpawnPoint.Length -1)
				SpawnIdx = 0;
		break;
	}
	
	if(SpawnMonster(PawnClass, SpawnPoint[SpawnIdx], SpawnPoint[SpawnIdx].Rotation))
	{
		LastSpawnIdx = SpawnIdx;
		SpawnedCount++;
		RemainingDelay += SpawnDelay;
		PopulateLinkedVariableValues();
		OutputLinks[0].bHasImpulse = true;
	}
}

/**
 * Called when this event is deactivated.
 */
event Deactivated()
{
	`log("Deactivated");
}

// Spawn a monster of given class at given location
function bool SpawnMonster(class<Pawn> P, Actor SpawnLoc, optional Rotator SpawnRotation)
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
	NewMonster = SpawnLoc.Spawn(P,,,SpawnLoc.Location+(P.Default.CylinderComponent.CollisionHeight)* vect(0,0,1), SpawnLoc.Rotation);
	
	if (NewMonster != None)
	{
		PRI = NewMonster.PlayerReplicationInfo;
		Game = UTTeamGame(SpawnLoc.WorldInfo.Game);
		
		if( Game == None )
		{
			return false;
			NewMonster.Died(None, None, NewMonster.Location);
			NewMonster.Destroy();
		}
		
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
			RBTTMonsterController(Bot).bNoRandomTeleport = True;
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
			
		SpawnedMonster = NewMonster;
		return True;
	}
	else
		return false;
}

defaultproperties
{
	ObjName="RBTTMonster Factory"
	ObjCategory="RBTTInvasion"
	
	bCallHandler=false
	bAutoActivateOutputLinks=false
	
	InputLinks(0)=(LinkDesc="Spawn monster")
	InputLinks(1)=(LinkDesc="Pause")
	InputLinks(2)=(LinkDesc="Continue")
	InputLinks(3)=(LinkDesc="Abort")

	VariableLinks(0)=(ExpectedType=class'SeqVar_Object',LinkDesc="SpawnPoint",PropertyName=SpawnPoint)
	VariableLinks(1)=(ExpectedType=class'SeqVar_Int',LinkDesc="SpawnCount",PropertyName=SpawnCount)
	VariableLinks(2)=(ExpectedType=class'SeqVar_Object',LinkDesc="Spawned",bWriteable=true,PropertyName=SpawnedMonster)	
}