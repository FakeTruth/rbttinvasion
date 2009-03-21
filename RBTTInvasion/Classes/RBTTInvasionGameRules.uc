class RBTTInvasionGameRules extends GameRules
	config(RBTTInvasion);

struct MonsterNames
{
	var string 				MonsterName;		// The name of the monster, so we can set it's name in the PRI
	var string 				MonsterClassName;	// The class of the monster as a string
	var class<UTPawn> 			MonsterClass;		// The dynamically loaded class of the corresponding MonsterClassName
};
var config Array<MonsterNames> 			MonsterTable;		// Hold all monsternames and classes

struct PortalStruct
{
	var class<MonsterSpawner>		PortalClass;		// The class of the portal
	var array<Class<UTPawn> > 		SpawnArray;		// The array that holds the monsters it's gonna spawn
	var int 				SpawnInterval;		// Spawn a monster per X seconds
	var int 				WhenToSpawn;		// Time in seconds from the beginning of the wave
};
var Array<PortalStruct>				PortalTable;		// Holds all the different portals

struct WaveTable
{
	var array<int> 				MonsterNum;		// MonsterTable[MonsterNum];
	var array<int> 				PortalNum;		// PortalTable[PortalNum];
	//var array<bool>				bPortalSpawned;		// Has the portal been spawned yet?
	var int					WaveLength;		// How many monsters should be in this wave?
	var int					WaveCountdown;		// Wave countdown per wave!
	var class<UTLocalMessage >		WaveCountdownAnnouncer; // Handles the countdown messages/sounds
	var float 				MonstersPerPlayer;	// Monster per player ratio
	var bool				bIgnoreMPP;		// Ignore monsters per player ratio
	var bool				bIsQueue;		// If this is a queue, spawn the monsters in the given order
	var bool				bTimedWave;		// The wave will last this time in seconds
	var int					MaxMonsters; 		// Maximum monsters in the level at the same time
	var bool				bAllowPortals;		// Should this wave have portals
	
	structdefaultproperties			// Set the defaultproperties for the struct
	{
		WaveLength = 10
		WaveCountdown = 10
		WaveCountdownAnnouncer = Class'RBTTTimerMessage'
		MonstersPerPlayer = 3
		bIsQueue = False
		MaxMonsters = 16
		bAllowPortals = False
	}
};
var config array<WaveTable>			WaveConfig;		// Wave configuration. When to spawn what monsters/portals
var array<int>					WaveConfigBuffer; 	// Fill this up, and drain it down when the monster list is a queue

//var array<int> 					WaveLength; 		// Cheap-ass monstertable, it only holds the wave length (ammount of monsters each wave
var int 					NumMonsters;		// Current number of monsters
var int						NumPortals;		// Current number of portals
var int						CurrentWave;		// The current wave number
var int 					WaveMonsters; 		// The ammount of monsters that have been killed in a wave
var float					LastPortalTime;		// The last time a portal (monsterspawner) was spawned
var config int					PortalSpawnInterval;	// How many second between each portal spawn
var bool 					bTimedWaveOver;		// For timed waves only, see if the wave is over

var array<NavigationPoint> 			MonsterSpawnPoints;	// Holds the spots where monsters can spawn

var array<UTPlayerReplicationInfo> 		Queue; 			// This array holds dead players for ressurecting them
var RBTTInvasionMutator 			InvasionMut; 		// The mutator, might be handy to cache it

var class<UTTeamAI> 				MonsterTeamAIType;	// decides the squads and spawns the squad ai i believe
var class<UTTeamInfo> 				MonsterEnemyRosterClass;// The monsters team info responsible for spawning the team ai
var UTTeamInfo 					Teams[2];		// an array of team infos held within UTGame 

var int 					BetweenWavesCountdown;	// Goes from 10 to 0 every wave begin

var config int					InitialRandomKillTime;	// The initial time before random monster killing happens!
var config int					NextRandomKillTime;	// After one monster was killed, the next will die in this amount of seconds

simulated function PostBeginPlay()
{
	local int i;

	Super.PostBeginPlay();
	`log(">>>>>>>>>>>>>>>>>>RBTTInvasionGameRules Spawned<<<<<<<<<<<<<<<<<<<<");

	`log(">>>>>>>>>>>>>>>>>>MonsterTable.length:"@MonsterTable.Length);
	for(i=0;i < MonsterTable.length;i++)
	{
		`log("#####Loading monster"@i@": "@MonsterTable[i].MonsterClassName);
		MonsterTable[i].MonsterClass = class<UTPawn>(DynamicLoadObject(MonsterTable[i].MonsterClassName,class'Class'));
	}
	
	WorldInfo.Game.GoalScore = 0;			// 0 means no goalscore
	
	//#### SET GAME INFORMATION ####\\
	if(UTTeamGame(WorldInfo.Game) != None)
		UTTeamGame(WorldInfo.Game).bForceAllRed=true;	
		
	//SaveConfig();
}

// FIXME - HUD ISN'T ALWAYS WORKING LIKE THIS!
// So just use it to set the team..
function NotifyLogin(Controller NewPlayer)
{
	//local RBTTClientReplicator ClientReplicator;
	
	`log(">> RBTTInvasionGameRules.NotifyLogin <<");

	if(NewPlayer.PlayerReplicationInfo.Team == UTTeamGame(WorldInfo.Game).Teams[1]) // Put the players in one team, the other team is for monsters
		UTTeamGame(WorldInfo.Game).SetTeam(NewPlayer, UTTeamGame(WorldInfo.Game).Teams[0], False);
	
	/*
	if(UTPlayerController(NewPlayer) != None)
	{
		ClientReplicator = NewPlayer.Spawn(Class'RBTTClientReplicator');
		ClientReplicator.OwnerController = NewPlayer;
	}
	*/
}

function MatchStarting()
{
	//local UTTeamGame Game;
	local PathNode NavPoint;
	local Controller C;
	local int i;
	//local RBTTClientReplicator ClientReplicator;
	
	//#### GET SPAWNPOINTS FOR MONSTERS ####\\
	i = 0;
	foreach WorldInfo.AllNavigationPoints(class'PathNode', NavPoint)
	{
		MonsterSpawnPoints[i] = NavPoint;
		i++;
	}
	
	//#### SET THE HUD ####\\
	// FIXME - NOT WORKING YET!!!
	//WorldInfo.Game.HUDType=Class'RBTTInvasionHUD';
	foreach WorldInfo.AllControllers(class'Controller', C)
	{
		if(C.PlayerReplicationInfo.Team == UTTeamGame(WorldInfo.Game).Teams[1]) // Put the players in one team, the other team is for monsters
			UTTeamGame(WorldInfo.Game).SetTeam(C, UTTeamGame(WorldInfo.Game).Teams[0], False);
		
		/*
		if(UTPlayerController(C) != None && UTPlayerController(C).myHUD.class != Class'RBTTInvasionHUD')
		{
			ClientReplicator = C.Spawn(Class'RBTTClientReplicator');
			ClientReplicator.OwnerController = C;
			if(WorldInfo.NetMode != NM_DedicatedServer)	// For offline play
				ClientReplicator.UpdateClientHUD(C);	
		}
		*/
	}
	
	/*
	foreach WorldInfo.AllControllers(class'UTPlayerController', PC)
	{
		PC.ClientSetHUD( Class'RBTTInvasionHUD', WorldInfo.Game.ScoreboardType );
		PC.bRetrieveSettingsFromProfileOnNextTick = TRUE;
	}
	*/
	
	//#### GET CURRENT WAVE FROM MUTATOR ####\\
	CurrentWave = InvasionMut.CurrentWave;
	
	CreateMonsterTeam();
	SetTimer(1, true, 'InvasionTimer'); 		// InvasionTimer gets called once every second
	LastPortalTime = WorldInfo.TimeSeconds;	 	// Spawn portal after PortalSpawnInterval seconds
	//WorldInfo.Game.GoalScore = 0;			// 0 means no goalscore
	GotoState('BetweenWaves'); 			// Initially start counting down for the first wave.
}

function InvasionTimer()
{
	//#### END-OF-WAVE ####\\
	if ( (WaveMonsters >= WaveConfig[CurrentWave].WaveLength && NumPortals <= 0 && !WaveConfig[CurrentWave].bIsQueue)
		|| (WaveConfig[CurrentWave].bIsQueue && WaveConfigBuffer.length <= 0 && WaveMonsters >= WaveConfig[CurrentWave].MonsterNum.length))
	{
		CountMonstersLeft();
		if(NumMonsters<=0)
		{	EndWave(); return;	}
	}

	//#### AddMonsters ####\\ if there aren't enough monsters in the game
	if (NumMonsters < WaveConfig[CurrentWave].MaxMonsters)
		if( (NumMonsters < WaveConfig[CurrentWave].MonstersPerPlayer * (WorldInfo.Game.NumPlayers + WorldInfo.Game.NumBots))
			|| WaveConfig[CurrentWave].bIgnoreMPP )
		{
			if (!WaveConfig[CurrentWave].bIsQueue)
				if ( (NumMonsters + WaveMonsters) < WaveConfig[CurrentWave].WaveLength )
					AddMonster(MonsterTable[WaveConfig[CurrentWave].MonsterNum[Rand(WaveConfig[CurrentWave ].MonsterNum.length)]].MonsterClass);
			
			if(WaveConfig[CurrentWave].bIsQueue && WaveConfigBuffer.length > 0 && AddMonster(MonsterTable[WaveConfigBuffer[0]].MonsterClass))
			{
				WaveConfigBuffer.Remove(0, 1);
			}
		}
	
	if(LastPortalTime + PortalSpawnInterval < WorldInfo.TimeSeconds)
		if(WaveConfig[CurrentWave].bAllowPortals)
		{
			SpawnPortal();
			LastPortalTime = WorldInfo.TimeSeconds;
		}
}

function EndWave()
{
	`log("Wave "@CurrentWave@" over!!");
	CurrentWave++;
	RespawnPlayersFromQueue();
	ReplenishAmmo();
	if( CurrentWave >= WaveConfig.length ) // You beat the last wave!
	{
		ClearTimer('InvasionTimer'); // Stop this timer, game's over anyway...
		EndInvasionGame("triggered"); // Game's over, end the game.
		return;
	}	
	WaveMonsters=0;
	`log("In Wave "@CurrentWave@" Now!");
	GotoState('BetweenWaves'); 
	InvasionMut.EndWave(self);
	return;
}

function ReplenishAmmo()
{
	local Inventory Item;
	local UTInventoryManager InvManager;
	local UTPlayerController PC;
	local int AmmoToAdd;
	local UTWeapon W;

	foreach WorldInfo.AllControllers(class'UTPlayerController', PC)
	{
		InvManager = UTInventoryManager(PC.Pawn.InvManager);
		
		for (Item = InvManager.InventoryChain; Item != None; Item = Item.Inventory)
		{
			if(!Item.IsA('UTWeap_Redeemer'))
			{
				W = UTWeapon(Item);
				AmmoToAdd = W.default.AmmoCount - W.AmmoCount;
				
				if(AmmoToAdd > 0)
					InvManager.AddAmmoToWeapon(AmmoToAdd, W.class);
			}
		}
	}
}

function RespawnPlayersFromQueue()
{
	local Controller C;
	local int i;
	
	for(i = Queue.length-1; i >= 0; i--)
	{
		C = GetPlayerFromQueue(i);
		if(C != None)
			RestartPlayer(C);
	}
	
	BetweenWavesCountdown = WaveConfig[CurrentWave].WaveCountdown;
}

function SpawnPortal()
{
	local NavigationPoint StartSpot;
	local MonsterSpawner MonsterPortal;

	StartSpot = MonsterSpawnPoints[Rand(MonsterSpawnPoints.length)];
	if ( StartSpot == None )
		return;
	
	MonsterPortal = Spawn(Class'MonsterSpawner',,,StartSpot.Location);
	if(MonsterPortal != None)
	{
		CountMonstersLeft(); // Count how many monsters left here, because portal spawning can screw up the monster killing timer
		MonsterPortal.SpawnArray = PortalTable[0].SpawnArray;
		MonsterPortal.Initialize(PortalTable[0].SpawnInterval);
		NumPortals++;
	}
}

function CountMonstersLeft()
{
	local Pawn P;
	local int NewMonsterNum, i;

	foreach WorldInfo.AllPawns(class'Pawn', P)
	{
		for(i=MonsterTable.Length-1; i >= 0; i--)
		{
			if(P.class == MonsterTable[i].MonsterClass)
			{
				NewMonsterNum++;
				continue;
			}
		}
	}
	
	NumMonsters = NewMonsterNum;
	`log(">> MONSTERS HAVE BEEN COUNTED, THIS MANY LEFT:: "@NewMonsterNum@"<<<");
}

function bool AddMonster(class<UTPawn> UTP)
{
	local NavigationPoint StartSpot;
	//local Class<UTPawn> NewMonsterPawnClass;
		
	`log(">>>>>>>>>>>>>>>>>> ADD MONSTER FUNCTION CALLED <<<<<<<<<<<<<<<<<<<<<");
	StartSpot = MonsterSpawnPoints[Rand(MonsterSpawnPoints.length)];
	//StartSpot = WorldInfo.Game.FindPlayerStart(None,1);
	//StartSpot = ChooseMonsterStart();
	
	if ( StartSpot == None )
		return False;

	
	
	//NewMonsterPawnClass = MonsterTable[WaveConfig[CurrentWave].MonsterNum[Rand(WaveConfig[CurrentWave ].MonsterNum.length)]].MonsterClass;
	//NewMonsterPawnClass = MonsterTable[Rand(MonsterTable.Length)].MonsterClass;
	return SpawnMonster(UTP, StartSpot.Location, StartSpot.Rotation);
}

// This function will force a monster into the game
function bool InsertMonster(class<UTPawn> UTP, Vector SpawnLocation, optional Rotator SpawnRotation, optional bool bIgnoreMaxMonsters)
{
	if(!bIgnoreMaxMonsters
	   && ((NumMonsters >= WaveConfig[CurrentWave].MaxMonsters)
	   || (NumMonsters >= 3 * (WorldInfo.Game.NumPlayers + WorldInfo.Game.NumBots))))
		return False;

	if(!SpawnMonster(UTP, SpawnLocation, SpawnRotation))
	{
		return False;
	}
	WaveMonsters--; // Make sure an extra monster has to be killed (this one, that is)
	
	return True;
}

// Do all the checks before spawning a monster
function bool SafeSpawnMonster(class<UTPawn> UTP, Vector SpawnLocation, optional Rotator SpawnRotation)
{
	if (NumMonsters < WaveConfig[CurrentWave].MaxMonsters) 
		if ( NumMonsters < 3 * (WorldInfo.Game.NumPlayers + WorldInfo.Game.NumBots) 
		  && (NumMonsters + WaveMonsters) < WaveConfig[CurrentWave].WaveLength)
			return SpawnMonster(UTP, SpawnLocation, SpawnRotation);
	
	return false;
}

// Spawn a monster of given class at given location
function bool SpawnMonster(class<UTPawn> UTP, Vector SpawnLocation, optional Rotator SpawnRotation)
{
	local UTPawn NewMonster;
	local UTTeamGame Game;
	local Controller Bot;
	local CharacterInfo MonsterBotInfo;
	local UTTeamInfo RBTTMonsterTeamInfo;
	local PlayerReplicationInfo PRI;
	local string MonsterName;
	
	`log(">>>>>>>>>>>>>>>>>> SPAWN MONSTER FROM SPAWNMONSTER <<<<<<<<<<<<<<<<<<<<<");
	//`log(">>>>>>>>>>>>>>>>>> NumMonsters("@NumMonsters@") < MaxMonsters("@WaveConfig[CurrentWave].MaxMonsters@") <<<<<<<<<<<<<<<<<<<<<");
	NewMonster = Spawn(UTP,,,SpawnLocation+(UTP.Default.CylinderComponent.CollisionHeight)* vect(0,0,1), SpawnRotation);
	
	if (NewMonster != None)
	{
		PRI = NewMonster.PlayerReplicationInfo;
		Game = UTTeamGame(WorldInfo.Game);
		
		if( Game == None )
		{
			return false;
			NewMonster.Destroy();
		}
		
		if ( NewMonster.IsA('RBTTMonster') )
		{
			MonsterName = RBTTMonster(NewMonster).MonsterName;
			Bot = NewMonster.Controller;
			MonsterBotInfo = RBTTMonsterTeamInfo(Game.GameReplicationInfo.teams[1]).GetBotInfo(MonsterName);
			RBTTMonsterController(Bot).Initialize(RBTTMonster(NewMonster).MonsterSkill, MonsterBotInfo);
			PRI.PlayerName = MonsterName;
			`log("Setting MonsterName to" @ MonsterBotInfo.CharName @ "Was Successful");
		}
		
		if(PRI != None)
		{
			RBTTMonsterTeamInfo=UTTeamInfo(Game.GameReplicationInfo.teams[1]);
			RBTTMonsterTeamInfo.AddToTeam(Bot);
			`log("PRI.Team.TeamIndex = "@PRI.Team.TeamIndex@"");
			RBTTMonsterTeamInfo.SetBotOrders(UTBot(Bot));
		}
		
		NumMonsters++;
		NewMonster.SpawnTransEffect(0);
		`log("This many monsters in the game now:"@NumMonsters);
		return True;
	}
	else
		return false;
}
	
function CreateMonsterTeam()
{
	local class<UTTeamInfo> RosterClass;
	local UTTeamGame Game;
	Game = UTTeamGame(WorldInfo.Game);
	Game.Teams[1].Destroy();

	RosterClass = MonsterEnemyRosterClass;
	`log(">>>>>>>>>>>>>>>> RosterClass = " @RosterClass@ " <<<<<<<<<<<<<<<<<");
	Teams[1] = spawn(RosterClass);
	//Teams[1].Faction = TeamFactions[1];//this is somthing i have in mind for later
	Teams[1].Initialize(1);
	Teams[1].AI = Spawn(MonsterTeamAIType);
	Teams[1].AI.Team = Teams[1];
	Game.Teams[1] = Teams[1];
	Game.GameReplicationInfo.SetTeam(1, Teams[1]);
	Game.Teams[1].AI.SetObjectiveLists();
}

function KillRandomMonster()
{
	local RBTTMonsterController MC;

	CountMonstersLeft(); 	// Also count the monsters, because it might have screwed up.
	if(NumMonsters <= 0)
		return;		// No need to kill a monster if there isn't any left
	
	foreach WorldInfo.AllControllers(class'RBTTMonsterController', MC)
	{
		if(MC.Pawn.PlayerCanSeeMe())
		{
			SetTimer(InitialRandomKillTime, true, 'KillRandomMonster'); 
			`log(">> Set timer to : "@InitialRandomKillTime@"<<");
			return;
		}
	}
	
	foreach WorldInfo.AllControllers(class'RBTTMonsterController', MC)
	{
		MC.Pawn.Died(MC, None, MC.Pawn.Location);
		SetTimer(NextRandomKillTime, true, 'KillRandomMonster'); 
		`log(">> Set timer to : "@NextRandomKillTime@"<<");
		return;
	}
}


function ScoreKill(Controller Killer, Controller Other)
{
	local UTPlayerReplicationInfo PRI;
	local Controller C;
	local int AlivePlayerCount, i;

	Super.ScoreKill(Killer, Other);
	
	PRI = UTPlayerReplicationInfo(Other.PlayerReplicationInfo);

	`log(">>>>>>>>>>>>>>> SCOREKILL CALLED <<<<<<<<<<<<<<<<");
	
	if(Killer != Other) // reset the timer. It wasn't killed by itself, so a player probably helped it?
		SetTimer(InitialRandomKillTime, true, 'KillRandomMonster');

	if(PRI != None && PRI.Team.TeamIndex != 1)
	{
		foreach WorldInfo.AllControllers(class'Controller', C)
			if((C.IsA('UTPlayerController') || C.class == Class'UTGame.UTBot')
				&& C != Other)
			{
				for(i=Queue.length-1;i >= 0; i--)
					if(Queue[i] == UTPlayerReplicationInfo(C.PlayerReplicationInfo))
						break;
						
				if(i >= 0 && Queue[i] == UTPlayerReplicationInfo(C.PlayerReplicationInfo))
					continue;
						
				AlivePlayerCount++;
			}
				
		`log(">>>>>>AlivePlayerCount="@AlivePlayerCount@"<<<<<<<");
		if(AlivePlayerCount <= 0)
		{
			EndInvasionGame("TimeLimit"); // you lost actually..
		}
		
		`log(">>>>>>>>>>>>>> ADDING PLAYER TO QUEUE <<<<<<<<<<<<<");
		AddToQueue(PRI);
	}	
	else
	{
		NumMonsters--;
		WaveMonsters++;
		`log(">>>>>>>>>>>>>>>>>>>>> MONSTER KILLED <<<<<<<<<<<<<<<<<<<<<<<");
		if(Rand(2) == 1)
			DropItemFrom(Other.Pawn, class'Pickup_Health', 10);
		else
			DropItemFrom(Other.Pawn, class'Pickup_Armor', 10, 1);
		`log("Monster was killed, number of monsters now:"@NumMonsters);
		`log("This wave's max monsters:"@WaveConfig[CurrentWave].WaveLength);
		`log("WaveMonsters = "@WaveMonsters);		
	}
}

function DropItemFrom(Pawn P, Class<Actor> PickupClass, optional int MiscOption1, optional int MiscOption2)
{
	local Actor MonsterDrop;
	local vector	POVLoc, TossVel;
	local rotator	POVRot;
	local Vector	X,Y,Z;

	P.GetActorEyesViewPoint(POVLoc, POVRot);
	TossVel = Vector(POVRot);
	TossVel = TossVel * ((Velocity Dot TossVel) + 500) + Vect(0,0,200);

	GetAxes(Rotation, X, Y, Z);
	
	MonsterDrop = Spawn(PickupClass,,, P.Location + 0.8 * P.CylinderComponent.CollisionRadius * X - 0.5 * P.CylinderComponent.CollisionRadius * Y);
	if( MonsterDrop == None )
	{
		return;
	}

	if(Pickup_Base(MonsterDrop) != None && (MiscOption1 != 0 || MiscOption2 != 0))
	{
		Pickup_Base(MonsterDrop).MiscOption1 = MiscOption1;
		Pickup_Base(MonsterDrop).MiscOption2 = MiscOption2;
	}
	MonsterDrop.SetPhysics(PHYS_Falling);
	//MonsterDrop.InventoryClass = PF;
	MonsterDrop.Velocity = TossVel;
	MonsterDrop.Instigator = P.Instigator;
	//MonsterDrop.SetPickupMesh(PF.default.PickupMesh);
}

function EndInvasionGame(Optional string Reason)
{
	local RBTTMonsterController MC;
	
	foreach WorldInfo.AllControllers(class'RBTTMonsterController', MC)
		MC.Destroy();
	
	if(Reason ~= "TimeLimit")
	{
		WorldInfo.Game.GameReplicationInfo.Winner = Teams[1]; // Monsters' team
		Teams[1].Score = 9999;
		Teams[0].Score = 0;
	}
	
	Reason = (Reason == "")?"triggered":Reason;
	WorldInfo.Game.EndGame(None,Reason);
	ClearTimer('InvasionTimer');
}


/** removes a player from the queue, sets it up to play, and returns the Controller
 * @note: doesn't spawn the player in (i.e. doesn't call RestartPlayer()), calling code is responsible for that
 */

function Controller GetPlayerFromQueue(int Index)
{
	local Controller C;
	local UTPlayerReplicationInfo PRI;
	local UTTeamInfo NewTeam;

	PRI = Queue[Index];
	Queue.Remove(Index, 1);

	// after a seamless travel some players might still have the old TeamInfo from the previous level
	// so we need to manually count instead of using Size

	NewTeam = UTTeamGame(WorldInfo.Game).Teams[0];
	C = Controller(PRI.Owner);
	//SetTeam(C, NewTeam, false);
	if( C != None )
	{
		if (C.IsA('UTBot'))
			NewTeam.SetBotOrders(UTBot(C));
		return C;
	}
	
	return None;
	
}


function AddToQueue(UTPlayerReplicationInfo Who)
{
	local PlayerController PC;
	//local int i;

	// Add the player to the end of the queue
	//i = Queue.Length;
	//`log(">>>>>>>>>>Queue.Length = "@i@"<<<<<<<<<<<");
	//Queue.Length = i + 1;
	Queue.AddItem(Who);
	`log(">>>>>>>>>>>>Player"@Who@" Added to Queue[]<<<<<<<<<<");
	//`log(">>>>>>>>>>>Queue["@i@"] = "@Queue[i]@"<<<<<<<<<<");
	//Queue[i].QueuePosition = i;

	//WorldInfo.Game.GameReplicationInfo.SetTeam(Controller(Who.Owner), None, false);
	if (!WorldInfo.Game.bGameEnded)
	{
		Who.Owner.GotoState('InQueue');
		PC = PlayerController(Who.Owner);
		if (PC != None)
		{
			PC.ClientGotoState('InQueue');
		
		}
	}
}

function RestartPlayer(Controller aPlayer)
{

	WorldInfo.Game.RestartPlayer(aPlayer);

}
state BetweenWaves
{
	function InvasionTimer()
	{
		local UTPlayerController PC;
		
		if(BetweenWavesCountDown <= 0) // Timer reached zero, let the wave begin.
		{	
			GotoState('');
			BeginWave();
			return;
		}
		
		foreach WorldInfo.AllControllers(class'UTPlayerController', PC)
		{
			//PC.ClientPlayAnnouncement(class'RBTTTimerMessage',BetweenWavesCountdown);
			PC.ReceiveLocalizedMessage( WaveConfig[CurrentWave].WaveCountdownAnnouncer, BetweenWavesCountdown);
			//UTHUD(PC.myHUD).DisplayHUDMessage("wutwutwut!");
		}	
		
		`log(BetweenWavesCountDown@"Seconds before next wave!");
		BetweenWavesCountdown--; // 1 second less left
		//UTHUD(PlayerController(InvasionMut.Instigator.Controller).myHUD).DisplayHUDMessage("wutwutwut!"); //, optional float XOffsetPct = 0.05, optional float YOffsetPct = 0.05)
		
	}

	function BeginState(Name PreviousStateName)
	{
		local Controller C;
		local int i;
		
		for(i = Queue.length-1; i >= 0; i--)
		{
			C = GetPlayerFromQueue(i);
			if(C != None)
				RestartPlayer(C);
		}
		
		BetweenWavesCountdown = WaveConfig[CurrentWave].WaveCountdown;
		
		if(WaveConfig[CurrentWave].bIsQueue == True)
			WaveConfigBuffer = WaveConfig[CurrentWave].MonsterNum;
			

	}
	
	function bool InsertMonster(class<UTPawn> UTP, Vector SpawnLocation, optional Rotator SpawnRotation, optional bool bIgnoreMaxMonsters)
	{
		// GotoState('MatchInProgress');
		// return Global.InsertMonster(UTP, SpawnLocation, SpawnRotation, bIgnoreMaxMonsters);	
		return false;
	}
	
	function bool SafeSpawnMonster(class<UTPawn> UTP, Vector SpawnLocation, optional Rotator SpawnRotation)
	{
		return false; // This function is not allowed to spawn monsters between waves
	}
}

function BeginWave()
{
	SetTimer(InitialRandomKillTime, true, 'KillRandomMonster');
	
	if(WaveConfig[CurrentWave].bTimedWave == True)
		GotoState('TimedWave');
}

state TimedWave
{
	function BeginState(Name PreviousStateName)
	{
		SetTimer(WaveConfig[CurrentWave].WaveLength, true, 'TimedWaveOver'); 
	}
	
	function TimedWaveOver()
	{
		bTimedWaveOver = True;
	}
	
	function InvasionTimer()
	{
		//#### END-OF-WAVE ####\\
		if ( (bTimedWaveOver && NumMonsters <= 0 && NumPortals <= 0) // Not the same statement as in the normal InvasionTimer
			|| (WaveConfig[CurrentWave].bIsQueue && WaveConfigBuffer.length <= 0 && WaveMonsters >= WaveConfig[CurrentWave].MonsterNum.length))
		{
			CountMonstersLeft();
			if(NumMonsters <= 0)
			{	EndWave(); bTimedWaveOver = False; return;	}
		}
		
		if (bTimedWaveOver)
			return; 	// Don't do any spawning, because the time's up!

		//#### AddMonsters ####\\ if there aren't enough monsters in the game
		if (NumMonsters < WaveConfig[CurrentWave].MaxMonsters)
			if( (NumMonsters < WaveConfig[CurrentWave].MonstersPerPlayer * (WorldInfo.Game.NumPlayers + WorldInfo.Game.NumBots))
				|| WaveConfig[CurrentWave].bIgnoreMPP )
			{
				if (!WaveConfig[CurrentWave].bIsQueue)
					if ( (NumMonsters + WaveMonsters) < WaveConfig[CurrentWave].WaveLength )
						AddMonster(MonsterTable[WaveConfig[CurrentWave].MonsterNum[Rand(WaveConfig[CurrentWave ].MonsterNum.length)]].MonsterClass);
				
				if(WaveConfig[CurrentWave].bIsQueue && WaveConfigBuffer.length > 0 && AddMonster(MonsterTable[WaveConfigBuffer[0]].MonsterClass))
				{
					WaveConfigBuffer.Remove(0, 1);
				}
			}
		
		if(LastPortalTime + PortalSpawnInterval < WorldInfo.TimeSeconds)
			if(WaveConfig[CurrentWave].bAllowPortals)
			{
				SpawnPortal();
				LastPortalTime = WorldInfo.TimeSeconds;
			}
	}
}


/* For TeamGame, tell teams about kills rather than each individual bot
*/
function NotifyKilled(Controller Killer, Controller KilledPlayer, Pawn KilledPawn)
{
	Teams[0].AI.NotifyKilled(Killer,KilledPlayer,KilledPawn);
	Teams[1].AI.NotifyKilled(Killer,KilledPlayer,KilledPawn);
}

defaultproperties
{
   MonsterEnemyRosterClass=class'RBTTMonsterTeamInfo'
   MonsterTeamAIType=Class'UTMonsterTeamAI'

   InitialRandomKillTime = 120
   NextRandomKillTime = 30
   
   PortalSpawnInterval = 60 //Portal spawns every 60 seconds!

	MonsterTable(0)=(MonsterName="SkullCrab",MonsterClassName="RBTTInvasion.RBTTSkullCrab")
	MonsterTable(1)=(MonsterName="HumanSkeleton",MonsterClassName="RBTTInvasion.RBTTHumanSkeleton")
	MonsterTable(2)=(MonsterName="KrallSkeleton",MonsterClassName="RBTTInvasion.RBTTKrallSkeleton")
	MonsterTable(3)=(MonsterName="MiningRobot",MonsterClassName="RBTTInvasion.RBTTMiningRobot")
	MonsterTable(4)=(MonsterName="WeldingRobot",MonsterClassName="RBTTInvasion.RBTTWeldingRobot")
	MonsterTable(5)=(MonsterName="Spider",MonsterClassName="RBTTInvasion.RBTTSpider")
	MonsterTable(6)=(MonsterName="Slime",MonsterClassName="RBTTInvasion.RBTTSlime")
	MonsterTable(7)=(MonsterName="ScarySkull",MonsterClassName="RBTTInvasion.RBTTScarySkull")
	
	//MonsterTable(8)=(MonsterName="Raptor",MonsterClassName="JR.JRRaptor")
	//MonsterTable(9)=(MonsterName="Rex",MonsterClassName="JR.JRRex")
	//MonsterTable(10)=(MonsterName="GasBag",MonsterClassName="RBTTInvasion.RBTTGasBag")
	//MonsterTable(11)=(MonsterName="Skaarj GasBag",MonsterClassName="RBTTSkaarjPack.GasBag")
	//MonsterTable(12)=(MonsterName="Skaarj Pupae",MonsterClassName="RBTTSkaarjPack.SkaarjPupae")
   
   //WaveConfig(0)=(MonsterNum=(1,2,4,6),WaveLength=10,WaveCountdown=10)
   WaveConfig(0)=(MonsterNum=(6,6,7,6,6,7,6,6,7,6,6,7),MonstersPerPlayer=2,bIsQueue=True,bAllowPortals=True)
   WaveConfig(1)=(MonsterNum=(7,7,7,0,0,0,6),WaveLength=15,WaveCountdown=15,bAllowPortals=True)
   WaveConfig(2)=(MonsterNum=(0,5,2,1),WaveLength=20,WaveCountdown=20,bAllowPortals=True)
   WaveConfig(3)=(MonsterNum=(1,2,4),WaveLength=10,WaveCountdown=10)
   WaveConfig(4)=(MonsterNum=(6,7),WaveLength=30,MonstersPerPlayer=6,WaveCountDown=15,bAllowPortals=True)
   WaveConfig(5)=(MonsterNum=(0,7),WaveLength=20,MonstersPerPlayer=4,bAllowPortals=True)
   WaveConfig(6)=(MonsterNum=(5),WaveLength=15,MonstersPerPlayer=4,bAllowPortals=False,bAllowPortals=True)
   WaveConfig(7)=(MonsterNum=(0,1,3,4,5,6,7),WaveLength=60,WaveCountdown=60,MonstersPerPlayer=20,bAllowPortals=True)
   
   //WaveConfig(0)=(MonsterNum=(0),WaveLength=10,WaveCountdown=10)
   //WaveConfig(1)=(MonsterNum=(0),WaveLength=10,WaveCountdown=10)
   //WaveConfig(2)=(MonsterNum=(0),WaveLength=10,WaveCountdown=10)
   //WaveConfig(3)=(MonsterNum=(0),WaveLength=10,WaveCountdown=10)
   
   
   PortalTable(0)=(PortalClass=Class'MonsterSpawner',SpawnArray=(Class'RBTTMiningRobot',Class'RBTTSpider',Class'RBTTMiningRobot',Class'RBTTMiningRobot',Class'RBTTSpider',Class'RBTTMiningRobot'),SpawnInterval=5)
   PortalTable(1)=(PortalClass=Class'MonsterSpawner',SpawnArray=(Class'RBTTSkullCrab',Class'RBTTSkullCrab',Class'RBTTSkullCrab',Class'RBTTSkullCrab',Class'RBTTSkullCrab',Class'RBTTSkullCrab',Class'RBTTSkullCrab'),SpawnInterval=5)
   
   Begin Object Name=Sprite ObjName=Sprite Archetype=SpriteComponent'Engine.Default__GameRules:Sprite'
      ObjectArchetype=SpriteComponent'Engine.Default__GameRules:Sprite'
   End Object
   Components(0)=Sprite
   
   Name="Default__RBTTInvasionGameRules"
   ObjectArchetype=GameRules'Engine.Default__GameRules'
}
