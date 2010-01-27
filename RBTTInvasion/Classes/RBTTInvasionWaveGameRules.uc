class RBTTInvasionWaveGameRules extends RBTTInvasionGameRules
	DependsOn(RBTTInvasionMutator)
	config(RBTTInvasion);

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
	var float				MonsterHealthMultiplier;// Monster's health will be multiplied by this
	var int					FallbackMonster;	// The MonsterID of the FallbackMonster that'll be used to prevent wave hangs
	
	structdefaultproperties			// Set the defaultproperties for the struct
	{
		WaveLength = 10
		WaveCountdown = 10
		WaveCountdownAnnouncer = Class'RBTTTimerMessage_Sexy'
		MonstersPerPlayer = 3
		bIsQueue = False
		MaxMonsters = 16
		bAllowPortals = False
		MonsterHealthMultiplier = 1.f
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
	Super.PostBeginPlay();
	
	if(WorldInfo.NetMode != NM_Client)
	{
		if(LoadCustomWaveConfig())
			`log("Custom Wave Configuration has been loaded");
	}
}

function MatchStarting()
{
	local NavigationPoint NP;
	local PathNode PN;
	local PlayerStart PS;
	local UTTeamPlayerStart TPS;
	local int i;
	
	`log(">>>>>>>>>>>>>>>>>>RBTTInvasionGameRules.MatchStarting<<<<<<<<<<<<<<<<<<<<");
	
	super.MatchStarting();
	
	//#### GET SPAWNPOINTS FOR MONSTERS ####\\
	if(InvasionMut.MonsterSpawnPoints ~= "PlayerStart")
	{
		foreach WorldInfo.AllNavigationPoints(class'PlayerStart', PS)
			MonsterSpawnPoints[MonsterSpawnPoints.length] = PS;
	}
	else if(InvasionMut.MonsterSpawnPoints ~= "NavigationPoint")
	{
		foreach WorldInfo.AllNavigationPoints(class'NavigationPoint', NP)
			MonsterSpawnPoints[MonsterSpawnPoints.length] = NP;
	}
	else if(InvasionMut.MonsterSpawnPoints ~= "RedPlayerStart")
	{
		foreach WorldInfo.AllNavigationPoints(class'UTTeamPlayerStart', TPS)
			if(TPS.TeamNumber == 0)
				MonsterSpawnPoints[MonsterSpawnPoints.length] = TPS;
	}
	else if(InvasionMut.MonsterSpawnPoints ~= "BluePlayerStart")
	{
		foreach WorldInfo.AllNavigationPoints(class'UTTeamPlayerStart', TPS)
			if(TPS.TeamNumber == 1)
				MonsterSpawnPoints[MonsterSpawnPoints.length] = TPS;
	}
	else // Pathnode yo! Fallback!
	{
		foreach WorldInfo.AllNavigationPoints(class'PathNode', PN)
			MonsterSpawnPoints[MonsterSpawnPoints.length] = PN;
	}
	
	//#### GET CURRENT WAVE FROM MUTATOR ####\\
	CurrentWave = InvasionMut.CurrentWave;

	// Go through the WaveConfig for this wave and do some FallbackMonster fixin'
	// It only needs fixin' if there's somethin' to fix
	if(GetMonsterClass(WaveConfig[i].FallbackMonster) == None)
	{
		`log("RBTTInvasionGameRules::PostBeginPlay  Found wave #"$CurrentWave@"without a FallbackMonster! Fixin...");
		// Go through the MonsterTable in normal order, because easy monsters tend to stay up highest
		for(i = 0; i < MonsterTable.length-1; i++)
		{
			// This may not be pretty, but it should stop waves from hanging!
			if(GetMonsterClass(MonsterTable[i].MonsterID) != None)
			{
				WaveConfig[i].FallbackMonster = MonsterTable[i].MonsterID;
				`log("RBTTInvasionGameRules::PostBeginPlay  FallbackMonster for wave #"$CurrentWave@"has been set to MonsterID "$MonsterTable[i].MonsterID);
				break;
			}
		}
	}
	
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
					//AddMonster(MonsterTable[MonsterTable.Find('MonsterID', WaveConfig[CurrentWave].MonsterNum[Rand(WaveConfig[CurrentWave].MonsterNum.length)])].MonsterClass);
					AddMonster(GetMonsterClass(WaveConfig[CurrentWave].MonsterNum[Rand(WaveConfig[CurrentWave ].MonsterNum.length)]));
				}
			
			if(WaveConfig[CurrentWave].bIsQueue && WaveConfigBuffer.length > 0 && AddMonster(GetMonsterClass(WaveConfigBuffer[0])))
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
	Super.EndWave();
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

function bool AddMonster(class<Pawn> P)
{
	local NavigationPoint StartSpot;
	//local Class<UTPawn> NewMonsterPawnClass;
		
	`log(">>>>>>>>>>>>>>>>>>RBTTInvasionGameRules.AddMonster<<<<<<<<<<<<<<<<<<<<");
	
	StartSpot = MonsterSpawnPoints[Rand(MonsterSpawnPoints.length)];
	//StartSpot = WorldInfo.Game.FindPlayerStart(None,1);
	//StartSpot = ChooseMonsterStart();
	
	if ( StartSpot == None )
		return False;
	
	// Use fallback monster here, as this is the only function used by the InvasionTimer
	if(P == None)
	{
		WarnInternal("AddMonster: Can't add monster, because pawn class P is None! Using FallbackMonster, but you should check your INI for errors");
		P = GetMonsterClass(WaveConfig[CurrentWave].FallbackMonster);
		if(P == None)
		{
			WarnInternal("AddMonster: Couldn't find FallbackMonster, you're in trouble now!");
			return False;
		}
	}
	
	//NewMonsterPawnClass = MonsterTable[WaveConfig[CurrentWave].MonsterNum[Rand(WaveConfig[CurrentWave ].MonsterNum.length)]].MonsterClass;
	//NewMonsterPawnClass = MonsterTable[Rand(MonsterTable.Length)].MonsterClass;
	return (SpawnMonster(P, StartSpot.Location, StartSpot.Rotation) != None);
}

// This function will force a monster into the game
function bool InsertMonster(class<Pawn> P, Vector SpawnLocation, optional Rotator SpawnRotation, optional bool bIgnoreMaxMonsters)
{
	`log(">>>>>>>>>>>>>>>>>>RBTTInvasionGameRules.InsertMonster<<<<<<<<<<<<<<<<<<<<");

	if(!bIgnoreMaxMonsters
	   && ((NumMonsters >= WaveConfig[CurrentWave].MaxMonsters)
	   || (NumMonsters >= 3 * (WorldInfo.Game.NumPlayers + WorldInfo.Game.NumBots))))
		return False;

	if(SpawnMonster(P, SpawnLocation, SpawnRotation) == None)
	{
		return False;
	}
	WaveMonsters--; // Make sure an extra monster has to be killed (this one, that is)
	
	return True;
}

// Do all the checks before spawning a monster
function bool SafeSpawnMonster(class<Pawn> P, Vector SpawnLocation, optional Rotator SpawnRotation)
{
	`log(">>>>>>>>>>>>>>>>>>RBTTInvasionGameRules.Safe<<<<<<<<<<<<<<<<<<<<");

	if (NumMonsters < WaveConfig[CurrentWave].MaxMonsters) 
		if ( NumMonsters < 3 * (WorldInfo.Game.NumPlayers + WorldInfo.Game.NumBots) 
		  && (NumMonsters + WaveMonsters) < WaveConfig[CurrentWave].WaveLength)
			return (SpawnMonster(P, SpawnLocation, SpawnRotation) != None);
	
	return false;
}

// Spawn a monster of given class at given location and return the pawn
function Pawn SpawnMonster(class<Pawn> P, Vector SpawnLocation, optional Rotator SpawnRotation)
{
	local Pawn NewMonster;
	
	NewMonster = Super.SpawnMonster(P, SpawnLocation, SpawnRotation);
	if(NewMonster != None)
	{
		NewMonster.Health*=WaveConfig[CurrentWave].MonsterHealthMultiplier;
		NewMonster.HealthMax = NewMonster.Health;
		NumMonsters++;
		`log("This many monsters in the game now:"@NumMonsters);
	}
	else
		return None;
		
	return NewMonster;
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

	if(PRI != None && PRI.Team != NONE && PRI.Team.TeamIndex != 1)
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
		`log("Monsters killed:"@WaveMonsters@"out of"@WaveConfig[CurrentWave].WaveLength);
	}
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
function ResPlayer(optional string PlayerName, optional PlayerReplicationInfo ResBy)
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
			{
				RestartPlayer(C);
				if(ResBy != None && PlayerController(C) != None)
				{
					PlayerController(C).ReceiveLocalizedMessage( Class'ResMessage',, ResBy);
				}
			}
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
					if(ResBy != None && PlayerController(C) != None)
					{
						PlayerController(C).ReceiveLocalizedMessage( Class'ResMessage',, ResBy);
					}
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
		if( InvasionMut.AllInvasionMutators != None )
		{
			InvasionMut.AllInvasionMutators.PlayerOut( Who );
		}
	}
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
	
	function bool InsertMonster(class<Pawn> P, Vector SpawnLocation, optional Rotator SpawnRotation, optional bool bIgnoreMaxMonsters)
	{
		// GotoState('MatchInProgress');
		// return Global.InsertMonster(UTP, SpawnLocation, SpawnRotation, bIgnoreMaxMonsters);	
		return false;
	}
	
	function bool SafeSpawnMonster(class<Pawn> P, Vector SpawnLocation, optional Rotator SpawnRotation)
	{
		return false; // This function is not allowed to spawn monsters between waves
	}
//Begin:
//Wait a couple of seconds before actually starting the countdown and ressurecting players
//Sleep(3);
}

function BeginWave()
{
	`log(">>>>>>>>>>>>>>>>>>RBTTInvasionGameRules.BeginWave<<<<<<<<<<<<<<<<<<<<");

	SetTimer(InitialRandomKillTime, true, 'KillRandomMonster');
	
	// If no monsters are supposed to spawn, end the wave
	if(WaveConfig[CurrentWave].MonsterNum.length <= 0 || WaveConfig[CurrentWave].WaveLength <= 0)
	{
		if(WaveConfig[CurrentWave].BossMonsters.length > 0)
		{	GotoState('BossWave'); return;	}
				
		EndWave();
		return;	
	}
	
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
						AddMonster(GetMonsterClass(WaveConfig[CurrentWave].MonsterNum[Rand(WaveConfig[CurrentWave ].MonsterNum.length)]));
				
				if(WaveConfig[CurrentWave].bIsQueue && WaveConfigBuffer.length > 0 && AddMonster(GetMonsterClass(WaveConfigBuffer[0])))
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
		local int FailedSpawnCount;
	
		`log(">>>>>>>>>>>>>>>>>>RBTTInvasionGameRules.BossWave.BeginState<<<<<<<<<<<<<<<<<<<<");
		
		WaveConfigBuffer = WaveConfig[CurrentWave].BossMonsters;
		
		// Make SURE ALL monsters have been spawned at once
		While(WaveConfigBuffer.length > 0)
		{
			if(AddMonster(GetMonsterClass(WaveConfigBuffer[0])) || FailedSpawnCount >= 5)	// Give monster 5 chances to spawn, otherwise goto next monster
			{
				WaveConfigBuffer.Remove(0, 1);
				FailedSpawnCount = 0;
			}
			else
			{
				FailedSpawnCount++;
				WarnInternal("FAILED TO SPAWN MONSTER (ID:"$WaveConfigBuffer[0]$") FAILED"@FailedSpawnCount@"TIME(S)");
			}
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
	InitialRandomKillTime = 120
	NextRandomKillTime = 30
	CountMonstersInterval = 10
	
	PortalSpawnInterval = 60 //Portal spawns every 60 seconds!
	
	WaveConfig(0)=(MonsterNum=) // The array needs at least 1 wave for the struct defaultproperties to kick in   

	Name="Default__RBTTInvasionWaveGameRules"
	ObjectArchetype=GameRules'Engine.Default__GameRules'
	
	bAlwaysRelevant=true
	RemoteRole=ROLE_SimulatedProxy
	NetUpdateFrequency=0.5
}
