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
	var array<int>				BossMonsters;		// MonsterTable[MonsterNum];
	//var array<int> 				PortalNum;		// PortalTable[PortalNum];
	//var array<bool>				bPortalSpawned;		// Has the portal been spawned yet?
	var int					WaveLength;		// How many monsters should be in this wave?
	var int					WaveCountdown;		// Wave countdown per wave!
	var class<UTLocalMessage >		WaveCountdownAnnouncer; // Handles the countdown messages/sounds
	var float 				MonstersPerPlayer;	// Monster per player ratio
	var bool				bIgnoreMPP;		// Ignore monsters per player ratio
	var bool				bIsQueue;		// If this is a queue, spawn the monsters in the given order
	var bool				bTimedWave;		// The wave will last WaveLength time in seconds
	var int					MaxMonsters; 		// Maximum monsters in the level at the same time
	var bool				bAllowPortals;		// Should this wave have portals
	
	structdefaultproperties			// Set the defaultproperties for the struct
	{
		WaveLength = 10
		WaveCountdown = 10
		WaveCountdownAnnouncer = Class'RBTTTimerMessage_Sexy'
		MonstersPerPlayer = 3
		bIsQueue = False
		MaxMonsters = 16
		bAllowPortals = False
	}
};
var array<WaveTable>				WaveConfig;		// Wave configuration. When to spawn what monsters/portals
var array<int>					WaveConfigBuffer; 	// Fill this up, and drain it down when the monster list is a queue

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
var config int					CountMonstersInterval;	// Seconds between each time the monsters get counted

replication
{
	if(Role == ROLE_Authority && bNetDirty)
		NumMonsters;
}

simulated function PostBeginPlay()
{
	local int i;

	Super.PostBeginPlay();
	`log(">>>>>>>>>>>>>>>>>>RBTTInvasionGameRules.PostBeginPlay<<<<<<<<<<<<<<<<<<<<");

	if(LoadCustomWaveConfig())
		`log("Custom Wave Configuration has been loaded");
	
	
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
		UTTeamGame(WorldInfo.Game).SetTeam(NewPlayer, UTTeamGame(WorldInfo.Game).Teams[0], TRUE);
	
	/*
	if(UTPlayerController(NewPlayer) != None)
	{
		ClientReplicator = NewPlayer.Spawn(Class'RBTTClientReplicator');
		ClientReplicator.OwnerController = NewPlayer;
	}
	*/
}

function KillAllMonsters()
{
	local Pawn P;
	local int i;
	
	`log(">>>>>>>>>>>>>>>>>>RBTTInvasionGameRules.KillAllMonsters<<<<<<<<<<<<<<<<<<<<");

	foreach WorldInfo.AllPawns(class'Pawn', P)
	{
		for(i=MonsterTable.Length-1; i >= 0; i--)
		{
			if(P.class == MonsterTable[i].MonsterClass)
			{
				P.Died(None, None, P.Location);
				continue;
			}
		}
	}
}

function MatchStarting()
{
	local PathNode NavPoint;
	local int i;
	
	`log(">>>>>>>>>>>>>>>>>>RBTTInvasionGameRules.MatchStarting<<<<<<<<<<<<<<<<<<<<");
	
	//#### GET SPAWNPOINTS FOR MONSTERS ####\\
	i = 0;
	foreach WorldInfo.AllNavigationPoints(class'PathNode', NavPoint)
	{
		MonsterSpawnPoints[i] = NavPoint;
		i++;
	}
	
	//#### GET CURRENT WAVE FROM MUTATOR ####\\
	CurrentWave = InvasionMut.CurrentWave;
	
	CreateMonsterTeam();
	SetTimer(1, true, 'InvasionTimer'); 		// InvasionTimer gets called once every second
	LastPortalTime = WorldInfo.TimeSeconds;	 	// Spawn portal after PortalSpawnInterval seconds
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
		{	
			if(WaveConfig[CurrentWave].BossMonsters.length > 0)
			{	GotoState('BossWave'); return;	}
			EndWave(); 
			return;	
		}
	}

	//#### AddMonsters ####\\ if there aren't enough monsters in the game
	if (NumMonsters < WaveConfig[CurrentWave].MaxMonsters)
		if( (NumMonsters < WaveConfig[CurrentWave].MonstersPerPlayer * (WorldInfo.Game.NumPlayers + WorldInfo.Game.NumBots))
			|| WaveConfig[CurrentWave].bIgnoreMPP )
		{
			if (!WaveConfig[CurrentWave].bIsQueue)
				if ( (NumMonsters + WaveMonsters) < WaveConfig[CurrentWave].WaveLength )
				{
					SetTimer(CountMonstersInterval, TRUE, 'CountMonstersLeft');
					AddMonster(MonsterTable[WaveConfig[CurrentWave].MonsterNum[Rand(WaveConfig[CurrentWave ].MonsterNum.length)]].MonsterClass);
				}
			
			if(WaveConfig[CurrentWave].bIsQueue && WaveConfigBuffer.length > 0 && AddMonster(MonsterTable[WaveConfigBuffer[0]].MonsterClass))
			{
				WaveConfigBuffer.Remove(0, 1);
				SetTimer(CountMonstersInterval, TRUE, 'CountMonstersLeft');
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
	`log(">>>>>>>>>>>>>>>>>>RBTTInvasionGameRules.EndWave<<<<<<<<<<<<<<<<<<<<");
	`log("Wave "@CurrentWave@" over!!");
	RespawnPlayersFromQueue();
	ReplenishAmmo();
	if( CurrentWave >= WaveConfig.length ) // You beat the last wave!
	{
		ClearTimer('InvasionTimer'); // Stop this timer, game's over anyway...
		EndInvasionGame("triggered"); // Game's over, end the game.
		return;
	}	
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
	
	`log(">>>>>>>>>>>>>>>>>>RBTTInvasionGameRules.ReplenishAmmo<<<<<<<<<<<<<<<<<<<<");

	foreach WorldInfo.AllControllers(class'UTPlayerController', PC)
	{
		InvManager = UTInventoryManager(PC.Pawn.InvManager);
		
		for (Item = InvManager.InventoryChain; Item != None; Item = Item.Inventory)
		{
			if(!Item.IsA('UTWeap_Redeemer'))
			{
				W = UTWeapon(Item);
				if(W != None)
				{
					AmmoToAdd = W.default.AmmoCount - W.AmmoCount;
					
					if(AmmoToAdd > 0)
						InvManager.AddAmmoToWeapon(AmmoToAdd, W.class);
				}
			}
		}
	}
}

function RespawnPlayersFromQueue()
{
	local Controller C;
	local int i;
	
	`log(">>>>>>>>>>>>>>>>>>RBTTInvasionGameRules.RespawnPlayersFromQueue<<<<<<<<<<<<<<<<<<<<");
	
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

	`log(">>>>>>>>>>>>>>>>>>RBTTInvasionGameRules.SpawnPortal<<<<<<<<<<<<<<<<<<<<");
	
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

	`log(">>>>>>>>>>>>>>>>>>RBTTInvasionGameRules.CountMonstersLeft<<<<<<<<<<<<<<<<<<<<");
	
	foreach WorldInfo.AllPawns(class'Pawn', P)
	{
		for(i=MonsterTable.Length-1; i >= 0; i--)
		{
			if(P.class == MonsterTable[i].MonsterClass && P.Health > 0)
			{
				NewMonsterNum++;
				continue;
			}
		}
	}
	
	NumMonsters = NewMonsterNum;
	`log(">> MONSTERS HAVE BEEN COUNTED, THIS MANY LEFT:: "@NewMonsterNum@"<<<");
}

function bool IsMonster(Pawn P)
{
	local int i;

	foreach WorldInfo.AllPawns(class'Pawn', P)
	{
		for(i=MonsterTable.Length-1; i >= 0; i--)
		{
			if(P.class == MonsterTable[i].MonsterClass)
			{
				return True;
			}
		}
	}
}

function bool AddMonster(class<UTPawn> UTP)
{
	local NavigationPoint StartSpot;
	//local Class<UTPawn> NewMonsterPawnClass;
		
	`log(">>>>>>>>>>>>>>>>>>RBTTInvasionGameRules.AddMonster<<<<<<<<<<<<<<<<<<<<");
	
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
	`log(">>>>>>>>>>>>>>>>>>RBTTInvasionGameRules.InsertMonster<<<<<<<<<<<<<<<<<<<<");

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
	`log(">>>>>>>>>>>>>>>>>>RBTTInvasionGameRules.SafeSpawnMonster<<<<<<<<<<<<<<<<<<<<");

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
	
	`log(">>>>>>>>>>>>>>>>>>RBTTInvasionGameRules.SpawnMonster<<<<<<<<<<<<<<<<<<<<");
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
	
	`log(">>>>>>>>>>>>>>>>>>RBTTInvasionGameRules.CreateMonsterTeam<<<<<<<<<<<<<<<<<<<<");
	
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

	`log(">>>>>>>>>>>>>>>>>>RBTTInvasionGameRules.KillRandomMonster<<<<<<<<<<<<<<<<<<<<");
	
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

function bool PreventDeath(Pawn KilledPawn, Controller Killer, class<DamageType> damageType, vector HitLocation)
{
	if(KilledPawn.Controller != None)
		if(KilledPawn.Controller.bIsPlayer)
			if(IsMonster(KilledPawn))
				KilledPawn.Controller.bIsPlayer = False;

	return Super.PreventDeath(KilledPawn,Killer, damageType,HitLocation);
}

function ScoreKill(Controller Killer, Controller Other)
{
	local UTPlayerReplicationInfo PRI;
	local Controller C;
	local int AlivePlayerCount, i;
	
	`log(">>>>>>>>>>>>>>>>>>RBTTInvasionGameRules.ScoreKill<<<<<<<<<<<<<<<<<<<<");

	Super.ScoreKill(Killer, Other);
	
	PRI = UTPlayerReplicationInfo(Other.PlayerReplicationInfo);
	
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
	
	`log(">>>>>>>>>>>>>>>>>>RBTTInvasionGameRules.DropItemFrom<<<<<<<<<<<<<<<<<<<<");

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
	
	`log(">>>>>>>>>>>>>>>>>>RBTTInvasionGameRules.EndInvasionGame<<<<<<<<<<<<<<<<<<<<");
	
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

function bool CheckEndGame(PlayerReplicationInfo Winner, string Reason)
{
	`log(">>>>>>>>>>>>>>>>>>RBTTInvasionGameRules.CheckEndGame<<<<<<<<<<<<<<<<<<<<");
	return Super.CheckEndGame(Winner, Reason); 
}


/** removes a player from the queue, sets it up to play, and returns the Controller
 * @note: doesn't spawn the player in (i.e. doesn't call RestartPlayer()), calling code is responsible for that
 */

function Controller GetPlayerFromQueue(int Index, optional bool bDontRemoveFromQueue)
{
	local Controller C;
	local UTPlayerReplicationInfo PRI;
	local UTTeamInfo NewTeam;
	
	`log(">>>>>>>>>>>>>>>>>>RBTTInvasionGameRules.GetPlayerFromQueue<<<<<<<<<<<<<<<<<<<<");

	PRI = Queue[Index];
	if(!bDontRemoveFromQueue)
		Queue.Remove(Index, 1);
		
	if(PRI == None)
		return None;

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

/** If PlayerName is not given, ressurect ALL players */
function ResPlayer(optional string PlayerName)
{
	local Controller C;
	local int i;
	
	`log(">>>>>>>>>>>>>>>>>>RBTTInvasionGameRules.Resplayer<<<<<<<<<<<<<<<<<<<<");

	if(PlayerName ~= "")
	{
		for(i = Queue.length-1; i >= 0; i--)
		{
			C = GetPlayerFromQueue(i);
			if(C != None)
				RestartPlayer(C);
		}
	}
	else
	{
		for(i = Queue.length-1; i >= 0; i--)
		{
			C = GetPlayerFromQueue(i, True);
			if(C != None && C.PlayerReplicationInfo != None)
			{
				`log(">> C.PlayerName "@C.PlayerReplicationInfo.PlayerName@"<<");
				if(Left(C.PlayerReplicationInfo.PlayerName, Len(PlayerName)) ~= PlayerName)
				{
					GetPlayerFromQueue(i);
					RestartPlayer(C);
				}
			}
		}
	}
}


function AddToQueue(UTPlayerReplicationInfo Who)
{
	local PlayerController PC;
	//local int i;

	`log(">>>>>>>>>>>>>>>>>>RBTTInvasionGameRules.AddToQueue<<<<<<<<<<<<<<<<<<<<");
	
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
		WorldInfo.Game.BroadcastLocalized(self, class'OutMessage',,Who);
		PC = PlayerController(Who.Owner);
		if (PC != None)
		{
			PC.ClientGotoState('InQueue');
		
		}
	}
}

function RestartPlayer(Controller aPlayer)
{
	`log(">>>>>>>>>>>>>>>>>>RBTTInvasionGameRules.RestartPlayer<<<<<<<<<<<<<<<<<<<<");
	WorldInfo.Game.RestartPlayer(aPlayer);

}
state BetweenWaves
{
	function InvasionTimer()
	{
		//local UTPlayerController PC;
		
		`log(">>>>>>>>>>>>>>>>>>RBTTInvasionGameRules.BetweenWaves.InvasionTimer<<<<<<<<<<<<<<<<<<<<");
		
		if(BetweenWavesCountDown <= 0) // Timer reached zero, let the wave begin.
		{	
			GotoState('');
			BeginWave();
			return;
		}
		
		`log(">> WaveConfig[CurrentWave].WaveCountdownAnnouncer :: "@WaveConfig[CurrentWave].WaveCountdownAnnouncer@" <<");
		//foreach WorldInfo.AllControllers(class'UTPlayerController', PC)
		//{
			//PC.ClientPlayAnnouncement(class'RBTTTimerMessage',BetweenWavesCountdown);
			//PC.ReceiveLocalizedMessage( WaveConfig[CurrentWave].WaveCountdownAnnouncer, BetweenWavesCountdown);
			//UTHUD(PC.myHUD).DisplayHUDMessage("wutwutwut!");
		//}	
		WorldInfo.Game.BroadcastLocalized(self,WaveConfig[CurrentWave].WaveCountdownAnnouncer, BetweenWavesCountdown);
		
		`log(BetweenWavesCountDown@"Seconds before next wave!");
		BetweenWavesCountdown--; // 1 second less left
		//UTHUD(PlayerController(InvasionMut.Instigator.Controller).myHUD).DisplayHUDMessage("wutwutwut!"); //, optional float XOffsetPct = 0.05, optional float YOffsetPct = 0.05)
		`log("##################RBTTInvasionGameRules.BetweenWaves.InvasionTimer####################");
	}

	function BeginState(Name PreviousStateName)
	{		
		local UTPlayerController PC;
	
		`log(">>>>>>>>>>>>>>>>>>RBTTInvasionGameRules.BetweenWaves.BeginState<<<<<<<<<<<<<<<<<<<<");
	
		ResPlayer();
		
		foreach WorldInfo.AllControllers(class'UTPlayerController', PC)
		{
			PC.ClientMessage( "Wave:"@CurrentWave+1);
		}
		
		BetweenWavesCountdown = WaveConfig[CurrentWave].WaveCountdown;
		
		if(WaveConfig[CurrentWave].bIsQueue == True)
			WaveConfigBuffer = WaveConfig[CurrentWave].MonsterNum;
			
		`log("##################RBTTInvasionGameRules.BetweenWaves.BeginState####################");
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
	`log(">>>>>>>>>>>>>>>>>>RBTTInvasionGameRules.BeginWave<<<<<<<<<<<<<<<<<<<<");

	SetTimer(InitialRandomKillTime, true, 'KillRandomMonster');
	
	if(WaveConfig[CurrentWave].bTimedWave == True)
		GotoState('TimedWave');
}

state TimedWave
{
	function BeginState(Name PreviousStateName)
	{
		`log(">>>>>>>>>>>>>>>>>>RBTTInvasionGameRules.TimedWave.BeginState<<<<<<<<<<<<<<<<<<<<");
		SetTimer(WaveConfig[CurrentWave].WaveLength, true, 'TimedWaveOver'); 
	}
	
	function TimedWaveOver()
	{
		`log(">>>>>>>>>>>>>>>>>>RBTTInvasionGameRules.TimedWave.TimedWaveOver<<<<<<<<<<<<<<<<<<<<");
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
			{	
				if(WaveConfig[CurrentWave].BossMonsters.length > 0)
				{	GotoState('BossWave'); return;	}
				
				bTimedWaveOver = False;
				EndWave();
				return;	
			}
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

state BossWave
{
	function BeginState(Name PreviousStateName)
	{
		local int i;
	
		`log(">>>>>>>>>>>>>>>>>>RBTTInvasionGameRules.BossWave.BeginState<<<<<<<<<<<<<<<<<<<<");
		
		WaveConfigBuffer = WaveConfig[CurrentWave].BossMonsters;
		
		// Make SURE ALL monsters have been spawned at once
		for(i = WaveConfigBuffer.length-1; WaveConfigBuffer.length > 0; i--)
		{
			if(i < 0)
				i = WaveConfigBuffer.length;
			if(AddMonster(MonsterTable[WaveConfigBuffer[i]].MonsterClass))
				WaveConfigBuffer.Remove(i, 1);
		}
	}

	function InvasionTimer()
	{
		`log(">> BossWave.InvasionTimer() <<");
		`log(">> NumMonsters: "@NumMonsters@" <<");
		//#### END-OF-WAVE ####\\
		if (NumMonsters <= 0)
		{
			CountMonstersLeft();
			if(NumMonsters<=0)
			{	EndWave(); return;	}
		}
	}
}

/* For TeamGame, tell teams about kills rather than each individual bot
*/
function NotifyKilled(Controller Killer, Controller KilledPlayer, Pawn KilledPawn)
{
	`log(">>>>>>>>>>>>>>>>>>RBTTInvasionGameRules.NotifyKilled<<<<<<<<<<<<<<<<<<<<");
	Teams[0].AI.NotifyKilled(Killer,KilledPlayer,KilledPawn);
	Teams[1].AI.NotifyKilled(Killer,KilledPlayer,KilledPawn);
}


//############################# PER MAP WAVE CONFIGURATION #############################
// THAAAAANKS SUDVASION!!!
/** Return the MapName, where some signs are replaced by a "_" */
function string GetSafeMapName()
{
	local string MapName;

	`log(">>>>>>>>>>>>>>>>>>RBTTInvasionGameRules.GetSafeMapName<<<<<<<<<<<<<<<<<<<<");
	
	//MapName = Left(string(Level), InStr(string(Level), "."));
	//MapName = WorldInfo.GetMapName();
	MapName = GetURLMap();
	MapName = Repl(MapName, " ", "_");
	MapName = Repl(MapName, "[", "_");
	MapName = Repl(MapName, "]", "_");

	return MapName;
}

/** Get the wave configuration for configName (usually the mapname) */
static function CustomWaveConfig FindCustomWaveConfig(string configName)
{
	local array<string> CustomWaveConfigNames;
	local int bestMatch, bestLength, newLength, maxLength;
	local int i;

	`log(">>>>>>>>>>>>>>>>>>RBTTInvasionGameRules.FindCustomWaveConfig<<<<<<<<<<<<<<<<<<<<");
	
	bestMatch = -1;
	bestLength = 0;
	maxLength = Len(configName);


	//CustomWaveConfigNames = class'CustomWaveConfig'.static.GetPerObjectNames(class'CustomWaveConfig'.default.ConfigFile);
	//native static final function bool GetPerObjectConfigSections( class SearchClass, out array<string> out_SectionNames, optional Object ObjectOuter, optional int MaxResults=1024 );
	GetPerObjectConfigSections( class'CustomWaveConfig', CustomWaveConfigNames );
	//array<string> GetPerObjectNames (string ININame) [static] 
	
	// find wave config with the longest match prefix to configName
	for (i = 0; i < CustomWaveConfigNames.Length; i++)
	{
		newLength = Len(CustomWaveConfigNames[i])-Len(" CustomWaveConfig");
		CustomWaveConfigNames[i] = Left(CustomWaveConfigNames[i], newLength);
		
		`log(">> CustomWaveConfigNames["@i@"] = "@CustomWaveConfigNames[i]@" <<");
		
		if ((newLength > bestLength) && (newLength <= maxLength) && (Left(configName, newLength) ~= CustomWaveConfigNames[i]))
		{
			bestMatch = i;
			bestLength = newLength;

			if (newLength == maxLength)
				break;                 // found configname's wave config
		}
	}

	if (bestMatch != -1)
	{
		`log(">> USING WAVE CONFIGURATION FOR "@CustomWaveConfigNames[bestMatch]@"<<");
		return new(None, CustomWaveConfigNames[bestMatch]) class'CustomWaveConfig';
	}

	//return None;
	`log(">> USING DEFAULT WAVE CONFIGURATION <<");
	return new(None, "Default") class'CustomWaveConfig';
}

/** Load the wave configuration for the current map */
function bool LoadCustomWaveConfig()
{
	local CustomWaveConfig CWaveConfig;
//	local array<string> CustomWaveConfigNames;
	local string configName;
	//local int i;

	`log(">>>>>>>>>>>>>>>>>>RBTTInvasionGameRules.LoadCustomWaveConfig<<<<<<<<<<<<<<<<<<<<");

	configName = GetSafeMapName();
	`log(">> SafeMapName = "@configName@" <<");
	CWaveConfig = static.FindCustomWaveConfig(configName);

	if (CWaveConfig == None)
		return false;       // no custom wave config

	`log(">> Setting WaveConfig.length to 0 <<");
	//WaveConfig.Length = 0;

	//for (i = 0; i < WaveConfig.Waves.Length; i++)
	//	Waves[i] = WaveConfig.Waves[i];
	`log(">> Replacing WaveConfig with CWaveConfig.WaveConfig <<");
	WaveConfig = CWaveConfig.WaveConfig;

	`log(">> Clearing CWaveConfig <<");
	CWaveConfig = None;

	`log("Invasion Custom Wave Config successfully loaded for"@configName);
	return true;
}

defaultproperties
{
   MonsterEnemyRosterClass=class'RBTTMonsterTeamInfo'
   MonsterTeamAIType=Class'UTMonsterTeamAI'

   InitialRandomKillTime = 120
   NextRandomKillTime = 30
   CountMonstersInterval = 10
   
   PortalSpawnInterval = 60 //Portal spawns every 60 seconds!

	//MonsterTable(0)=(MonsterName="SkullCrab",MonsterClassName="RBTTInvasion.RBTTSkullCrab")
	//MonsterTable(1)=(MonsterName="HumanSkeleton",MonsterClassName="RBTTInvasion.RBTTHumanSkeleton")
	//MonsterTable(2)=(MonsterName="KrallSkeleton",MonsterClassName="RBTTInvasion.RBTTKrallSkeleton")
	//MonsterTable(3)=(MonsterName="MiningRobot",MonsterClassName="RBTTInvasion.RBTTMiningRobot")
	//MonsterTable(4)=(MonsterName="WeldingRobot",MonsterClassName="RBTTInvasion.RBTTWeldingRobot")
	//MonsterTable(5)=(MonsterName="Spider",MonsterClassName="RBTTInvasion.RBTTSpider")
	//MonsterTable(6)=(MonsterName="Slime",MonsterClassName="RBTTInvasion.RBTTSlime")
	//MonsterTable(7)=(MonsterName="ScarySkull",MonsterClassName="RBTTInvasion.RBTTScarySkull")
	
	//MonsterTable(8)=(MonsterName="Raptor",MonsterClassName="JR.JRRaptor")
	//MonsterTable(9)=(MonsterName="Rex",MonsterClassName="JR.JRRex")
	//MonsterTable(10)=(MonsterName="GasBag",MonsterClassName="RBTTInvasion.RBTTGasBag")
	//MonsterTable(11)=(MonsterName="Skaarj GasBag",MonsterClassName="RBTTSkaarjPack.GasBag")
	//MonsterTable(12)=(MonsterName="Skaarj Pupae",MonsterClassName="RBTTSkaarjPack.SkaarjPupae")
   
   WaveConfig(0)=(MonsterNum=) // The array needs at least 1 wave for the struct defaultproperties to kick in
   
   //WaveConfig(0)=(MonsterNum=(6,6,7,6,6,7,6,6,7,6,6,7),MonstersPerPlayer=2,bIsQueue=True,bAllowPortals=True)
   //WaveConfig(1)=(MonsterNum=(7,7,7,0,0,0,6),WaveLength=15,WaveCountdown=15,bAllowPortals=True)
   //WaveConfig(2)=(MonsterNum=(0,5,2,1),WaveLength=20,WaveCountdown=20,bAllowPortals=True)
   //WaveConfig(3)=(MonsterNum=(1,2,4),WaveLength=10,WaveCountdown=10)
   //WaveConfig(4)=(MonsterNum=(6,7),WaveLength=30,MonstersPerPlayer=6,WaveCountDown=15,bAllowPortals=True)
   //WaveConfig(5)=(MonsterNum=(0,7),WaveLength=20,MonstersPerPlayer=4,bAllowPortals=True)
   //WaveConfig(6)=(MonsterNum=(5),WaveLength=15,MonstersPerPlayer=4,bAllowPortals=False,bAllowPortals=True)
   //WaveConfig(7)=(MonsterNum=(0,1,3,4,5,6,7),WaveLength=60,WaveCountdown=60,MonstersPerPlayer=20,bAllowPortals=True)
   
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
   
	bAlwaysRelevant=true
	RemoteRole=ROLE_SimulatedProxy
	NetUpdateFrequency=0.5
}
