class RBTTInvasion extends UTTeamGame;

struct MonsterNames
{
	var string MonsterName;
	var string MonsterClassName;
	var class<UTPawn> MonsterClass;
};


var Array<MonsterNames> MonsterTable;

var Array<MonsterNames> AddonMonsters;	


/** queue of players that will take on the winner */
var array<UTDuelPRI> Queue;

/** how many rounds before we switch maps */
var config int NumRounds;

/** current round number */
var int CurrentRound;

/** whether to rotate the queue each kill instead of each round (Survival mode) */
var bool bRotateQueueEachKill;

var() config string MonsterEnemyRosterClass;

var int NumMonsters, MaxMonsters;
var int CurrentWave, MaxWaves;
var array<NavigationPoint> MonsterSpawnPoints;

var int WaveMonsters;
var array<int> WaveLength;
var int BetweenWavesCountdown;

var class<UTPawn> FallbackMonster;

var() class<UTPawn>	FallbackMonsterClass;

var float NextMonsterTime;



// Returns whether a mutator should be allowed with this gametype
static function bool AllowMutator( string MutatorClassName )
{
	if ( MutatorClassName ~= "UTGame.UTMutator_Survival")
	{
		// survival mutator only for Duel
		return true;
	}
	if ( MutatorClassName ~= "UTGame.UTMutator_FriendlyFire")
	{
		// survival mutator only for Duel
		return false;
	}
	return Super.AllowMutator(MutatorClassName);
}

function PostBeginPlay()
{
	local int i;
	local PathNode NavPoint;

	Super.PostBeginPlay();

	LogInternal(">>>>>>>>>>>>>>>>>>MonsterTable.length:"@MonsterTable.Length);
	for(i=0;i < MonsterTable.length;i++)
	{
		LogInternal("#####Loading monster"@i@": "@MonsterTable[i].MonsterClassName);
		MonsterTable[i].MonsterClass = class<UTPawn>(DynamicLoadObject(MonsterTable[i].MonsterClassName,class'Class'));
	}

	i=0;
	foreach WorldInfo.AllNavigationPoints(class'PathNode', NavPoint)
	{
		MonsterSpawnPoints[i] = NavPoint;
		i++;
	}
	
	//CreateMonsterTeam();
}

function CreateTeam(int TeamIndex)
{
	local class<UTTeamInfo> RosterClass;
	//local bool bDefualtTeamsGone;
	
	
	
	if(TeamIndex < 1)
	{
		RosterClass = class<UTTeamInfo>(DynamicLoadObject(DefaultEnemyRosterClass,class'Class'));
		LogInternal(">>>>>>>>>>>>>>>> RosterClass = " @RosterClass@ " <<<<<<<<<<<<<<<<<");
	}
	else
	{
		RosterClass = class<UTTeamInfo>(DynamicLoadObject(MonsterEnemyRosterClass,class'Class'));
		LogInternal(">>>>>>>>>>>>>>>> RosterClass = " @RosterClass@ " <<<<<<<<<<<<<<<<<");
	}

	Teams[TeamIndex] = spawn(RosterClass);
	Teams[TeamIndex].Faction = TeamFactions[TeamIndex];
	Teams[TeamIndex].Initialize(TeamIndex);
	Teams[TeamIndex].AI = Spawn(TeamAIType[TeamIndex]);
	Teams[TeamIndex].AI.Team = Teams[TeamIndex];
	GameReplicationInfo.SetTeam(TeamIndex, Teams[TeamIndex]);
	Teams[TeamIndex].AI.SetObjectiveLists();
}

/*
function bool AllowBecomeActivePlayer(PlayerController P)
{
	if ( NumPlayers > 12 )
	{
		P.ReceiveLocalizedMessage(GameMessageClass, 13);
		return false;
	}
	return super.AllowBecomeActivePlayer(P);
}
*/

event InitGame(string Options, out string ErrorMessage)
{
	Super.InitGame(Options, ErrorMessage);
	
	if (WorldInfo.NetMode != NM_Standalone && MinNetPlayers > 0)
	{
		MinNetPlayers = Max(MinNetPlayers, 0);
	}
	else
	{
		DesiredPlayerCount = Max(DesiredPlayerCount, 8);
	}	
	

	GoalScore = 0;
}

/*
event PostLogin(PlayerController NewPlayer)
{
	local UTDuelPRI PRI, BotPRI;
	local UTBot B;

	Super.PostLogin(NewPlayer);

	if (NumPlayers + NumTravellingPlayers + NumBots > 8)
	{
		PRI = UTDuelPRI(NewPlayer.PlayerReplicationInfo);
		if (PRI != None && !PRI.bOnlySpectator)
		{
			if (!bGameEnded && (!GameReplicationInfo.bMatchHasBegun || IsInState('RoundOver')))
			{
				// see if there's a bot we can kick instead
				foreach WorldInfo.AllControllers(class'UTBot', B)
				{
					BotPRI = UTDuelPRI(B.PlayerReplicationInfo);
					if (BotPRI != None && BotPRI.QueuePosition == -1)
					{
						AddToQueue(BotPRI);
						return;
					}
				}
			}
			AddToQueue(PRI);
		}
	}
}
*/

/**
 * returns true if Viewer is allowed to spectate ViewTarget
 **/
function bool CanSpectate( PlayerController Viewer, PlayerReplicationInfo ViewTarget )
{
	if ( (ViewTarget == None) || ViewTarget.bOnlySpectator )
		return false;
	return ( Viewer.PlayerReplicationInfo.bIsSpectator );
}

function AddMonster()
{
	local NavigationPoint StartSpot;
	local RBTTInvasion Game;
	local UTPawn NewMonster;
	local Class<UTPawn> NewMonsterPawnClass;
	//local RBTTMonster FallBackMonster;
	LogInternal(">>>>>>>>>>>>>>>>>> ADD MONSTER FUNCTION CALLED <<<<<<<<<<<<<<<<<<<<<");
	//StartSpot = FindPlayerStart(None,1);
	StartSpot = MonsterSpawnPoints[Rand(MonsterSpawnPoints.length)];
	if ( StartSpot == None )
		return;

	Game = RBTTInvasion(WorldInfo.Game);
		
	FallBackMonster=Game.default.FallbackMonsterClass;
	
	LogInternal(">>>>>>>>>>>>>>>>>> FALLBACKMONSTER = "@FallbackMonster@" <<<<<<<<<<<<<<<<<<<<<");
	
	//NewMonsterClass = WaveMonsterClass[Rand(WaveNumClasses)];
	//NewMonster = Spawn(NewMonsterClass,,,StartSpot.Location+(NewMonsterClass.Default.CollisionHeight - StartSpot.CollisionHeight) * vect(0,0,1),StartSpot.Rotation);
	if ( (WorldInfo.TimeSeconds > NextMonsterTime) && (NumMonsters < MaxMonsters) )
	{
		//FallBackMonster=RBTTMonster(DynamicLoadObject(game.default.FallbackMonsterClass,class'Class'));
		//NewMonster = Spawn(FallBackMonster,,,StartSpot.Location+(class'RBTTSkullCrab'.Default.CylinderComponent.CollisionHeight - StartSpot.CylinderComponent.CollisionHeight)* vect(0,0,1),StartSpot.Rotation);
		NewMonsterPawnClass = MonsterTable[Rand(MonsterTable.Length)].MonsterClass;
		NewMonster = Spawn(NewMonsterPawnClass,,,StartSpot.Location+(NewMonsterPawnClass.Default.CylinderComponent.CollisionHeight - StartSpot.CylinderComponent.CollisionHeight)* vect(0,0,1),StartSpot.Rotation);
		NextMonsterTime = WorldInfo.TimeSeconds + 0.2;
	}
	
	if ( NewMonster != None )
	{
		NumMonsters++;
                LogInternal("This many monsters in the game now:"@NumMonsters);
	}
}

/*
function UTBot AddBot(optional string botName, optional bool bUseTeamIndex, optional int TeamIndex)
{
	local UTBot NewBot;

	NewBot = SpawnBot(botName, bUseTeamIndex, TeamIndex);
	if (NewBot == None)
	{
		WarnInternal("Failed to spawn bot.");
		return None;
	}
	else
	{
		NewBot.PlayerReplicationInfo.PlayerID = CurrentID++;
		NumBots++;

		if (NumPlayers + NumBots > 4)
		{
			AddToQueue(UTDuelPRI(NewBot.PlayerReplicationInfo));
		}
		else if (WorldInfo.NetMode == NM_StandAlone)
		{
			RestartPlayer(NewBot);
		}
		else
		{
			NewBot.GotoState('Dead', 'MPStart');
		}
	}

	return NewBot;
}
*/

function Logout(Controller Exiting)
{
	local int Index;
	local Controller C;
	local UTPlayerController Host;
	local PlayerReplicationInfo Winner;
	local bool HostExiting;

	Super.LogOut(Exiting);

	Index = Queue.Find(UTDuelPRI(Exiting.PlayerReplicationInfo));
	if (Index != INDEX_NONE)
	{
		Queue.Remove(Index, 1);
		UpdateQueuePositions();
	}
	else if ( (!bRotateQueueEachKill || !GameReplicationInfo.bMatchHasBegun || WorldInfo.IsInSeamlessTravel()) &&
		Exiting.PlayerReplicationInfo != None && Exiting.PlayerReplicationInfo.Team != None &&
		Exiting.PlayerReplicationInfo.Team.Size == 1 )
	{
		if (!GameReplicationInfo.bMatchHasBegun || WorldInfo.IsInSeamlessTravel())
		{
			if (Queue.length > 0)
			{
				// just add a new player now
				GetPlayerFromQueue();
			}
		}
		else if (!bGameEnded)
		{
			foreach WorldInfo.AllControllers(class'Controller', C)
			{
				if (C != Exiting && C.bIsPlayer && C.Pawn != None && UTDuelPRI(C.PlayerReplicationInfo) != None)
				{
					Winner = C.PlayerReplicationInfo;
					break;
				}
			}
			HostExiting = false;
			foreach LocalPlayerControllers(class'UTPlayerController', Host)
			{
				// see if the host is exiting
				if (Host == Exiting )
				{
					HostExiting = true;
				}
			}
			// if it's not the host that's leaving
			if (!HostExiting)
			{
			EndGame(Winner, "LastMan");
		}
	}
}
}

function AddToQueue(UTDuelPRI Who)
{
	local PlayerController PC;
	local int i;

	// Add the player to the end of the queue
	i = Queue.Length;
	Queue.Length = i + 1;
	Queue[i] = Who;
	Queue[i].QueuePosition = i;

	SetTeam(Controller(Who.Owner), None, false);
	if (!bGameEnded)
	{
		Who.Owner.GotoState('InQueue');
		PC = PlayerController(Who.Owner);
		if (PC != None)
		{
			PC.ClientGotoState('InQueue');
		
		}
	}
}

function StartHumans()
{
	local Controller C;

	// just start everybody now
	foreach WorldInfo.AllControllers(class'Controller', C)
	{
		if (bGameEnded)
		{
			return;
		}
		else if (C.bIsPlayer && (PlayerController(C) == None || PlayerController(C).CanRestartPlayer() &&  PlayerController(C).Pawn == None))
		{
			RestartPlayer(C);
		}
	}
}

function StartBots();


/** updates QueuePosition for all players in the queue */
function UpdateQueuePositions()
{
	local int i;

	for (i = 0; i < Queue.length; i++)
	{
		if (Queue[i].QueuePosition != i)
		{
			Queue[i].QueuePosition = i;
			if (i == 0 && PlayerController(Queue[i].Owner) != None)
			{
				PlayerController(Queue[i].Owner).ReceiveLocalizedMessage(class'UTDuelMessage', 0, Queue[i]);
			}
		}
	}
}

/** removes a player from the queue, sets it up to play, and returns the Controller
 * @note: doesn't spawn the player in (i.e. doesn't call RestartPlayer()), calling code is responsible for that
 */
function Controller GetPlayerFromQueue()
{
	local Controller C;
	local UTDuelPRI PRI;
	local UTTeamInfo NewTeam;
	//local int TeamCount[2];

	PRI = Queue[0];
	Queue.Remove(0, 1);
	PRI.QueuePosition = -1;
	UpdateQueuePositions();

	// after a seamless travel some players might still have the old TeamInfo from the previous level
	// so we need to manually count instead of using Size

	NewTeam = Teams[0];
	C = Controller(PRI.Owner);
	SetTeam(C, NewTeam, false);
	if (C.IsA('UTBot'))
	{
		NewTeam.SetBotOrders(UTBot(C));
	}
	
	return C;
	
}

function ScoreKill(Controller Killer, Controller Other)
{
	local UTDuelPRI PRI;
	local Controller C;

	Super.ScoreKill(Killer, Other);

	LogInternal(">>>>>>>>>>>>>>> SCOREKILL CALLED <<<<<<<<<<<<<<<<");

	if(Other.IsA('RBTTMonsterController'))
	{
		NumMonsters--;
		WaveMonsters++;
		LogInternal(">>>>>>>>>>>>>>>>>>>>> MONSTER KILLED <<<<<<<<<<<<<<<<<<<<<<<");
		LogInternal("Monster was killed, number of monsters now:"@NumMonsters);
		LogInternal("This wave's max monsters:"@WaveLength[CurrentWave]);
		LogInternal("WaveMonsters = "@WaveMonsters);
		//Logout(Other);
	}
	PRI = UTDuelPRI(Other.PlayerReplicationInfo);
		
	if(Other.IsA('UTPlayerController') || Other.class == Class'UTGame.UTBot'); //&& !Other.IsA('RBTTMonsterController')))
		if (PRI != None)
		{
			AddToQueue(PRI);
		}	
	if (bRotateQueueEachKill && !bGameEnded)
	{
		
		if (PRI != None)
		{
			if (!Other.bPendingDelete)
			{
				AddToQueue(PRI);
			}
			if (Queue.length > 0)
			{
				C = GetPlayerFromQueue();
				RestartPlayer(C);
				if (C.PlayerReplicationInfo.Team != None)
				{
					C.PlayerReplicationInfo.Team.Score = C.PlayerReplicationInfo.Score;
				}
			}
		}
	}
}

/** figures out the new combatants for the next round */
function UpdateCombatants()
{
	local int NumPlayersNeeded;
	local UTDuelPRI PRI;
	local Controller C;

	NumPlayersNeeded = 8;
	foreach WorldInfo.AllControllers(class'Controller', C)
	{
		PRI = UTDuelPRI(C.PlayerReplicationInfo);
		if (PRI != None && !PRI.bOnlySpectator)
		{
			if (C.PlayerReplicationInfo.Team == GameReplicationInfo.Winner)
			{
				PRI.ConsecutiveWins++;
				NumPlayersNeeded--;
			}
			else
			{
				PRI.ConsecutiveWins = 0;
				if (Queue.Find(PRI) == INDEX_NONE)
				{
					AddToQueue(PRI);
				}
			}
		}
	}

	while (NumPlayersNeeded > 0 && Queue.length > 0)
	{
		GetPlayerFromQueue();
		NumPlayersNeeded--;
	}
}

function RestartPlayer(Controller aPlayer)
{
	if ( aPlayer.IsA('RBTTMonsterController'))
        return;
	
	if (Queue.Find(UTDuelPRI(aPlayer.PlayerReplicationInfo)) == INDEX_NONE)
	{
		// force respawn player even if they're processing characters
		// (unfortunate, but better than them potentially hanging the game state)
		if (UTPlayerController(aPlayer) != None)
		{
			UTPlayerController(aPlayer).bInitialProcessingComplete = true;
		}
		Super.RestartPlayer(aPlayer);
	}
}

function bool ChangeTeam(Controller Other, int num, bool bNewTeam)
{
	// not allowed to change team
	return (Other.PlayerReplicationInfo.Team == None) ? Super.ChangeTeam(Other, num, bNewTeam) : false;
}

function byte PickTeam(byte num, Controller C)
{
	return 0;
}

function ResetLevel()
{
	local Controller C;

	Super.ResetLevel();

	// make sure everyone's in the correct state
	foreach WorldInfo.AllControllers(class'Controller', C)
	{
		if (Queue.Find(UTDuelPRI(C.PlayerReplicationInfo)) != INDEX_NONE)
		{
			C.GotoState('InQueue');
			if (C.IsA('PlayerController'))
			{
				PlayerController(C).ClientGotoState('InQueue');
			}
		}
	}
}

state RoundOver
{
	function ResetLevel()
	{
		// note that we need to change the state BEFORE calling ResetLevel() so that we don't unintentionally override
		// functions that ResetLevel() may call
		UpdateCombatants();
		
		GotoState('');
		Global.ResetLevel();
		// redo warmup round for new players
		WarmupRemaining = WarmupTime;
		GotoState('PendingMatch');
		ResetCountDown = 10;

		CurrentRound++;
	}
}

function ProcessServerTravel(string URL, optional bool bAbsolute)
{
	local RBTTMonsterController MC;

	foreach WorldInfo.AllControllers(class'RBTTMonsterController', MC)
		MC.Destroy();

	Super.ProcessServerTravel(URL, bAbsolute);
}

event PostSeamlessTravel()
{
	local int i;
	local UTDuelPRI PRI;

	// reconstruct the Queue from the PRIs
	for (i = 0; i < GameReplicationInfo.PRIArray.length; i++)
	{
		PRI = UTDuelPRI(GameReplicationInfo.PRIArray[i]);
		if (PRI != None && PRI.QueuePosition >= 0)
		{
			Queue[PRI.QueuePosition] = PRI;
		}
	}

	Super.PostSeamlessTravel();
}

event HandleSeamlessTravelPlayer(out Controller C)
{
	local UTDuelPRI OldPRI, NewPRI;
	local int Index;
	local bool bInQueue;

	// replace the old PRI with the new one in the queue array
	// if it's not there, but we already have enough active players, add it
	OldPRI = UTDuelPRI(C.PlayerReplicationInfo);
	Super.HandleSeamlessTravelPlayer(C);
	NewPRI = UTDuelPRI(C.PlayerReplicationInfo);
	if (OldPRI != None)
	{
		if (NewPRI != None)
		{
			Index = Queue.Find(OldPRI);
			if (Index != INDEX_NONE)
			{
				Queue[Index] = NewPRI;
				NewPRI.QueuePosition = Index;
				SetTeam(C, None, false);
				bInQueue = true;
			}
		}
		else
		{
			Queue.RemoveItem(OldPRI);
		}
	}
	else if (NewPRI != None && NumPlayers + NumBots > 2)
	{
		AddToQueue(NewPRI);
		bInQueue = true;
	}

	if (bInQueue)
	{
		C.GotoState('InQueue');
		if (C.IsA('PlayerController'))
		{
			PlayerController(C).ClientGotoState('InQueue');
		}
	}
}

state MatchInProgress
{
	function bool MatchIsInProgress()
	{
		return true;
	}

	function bool ChangeTeam(Controller Other, int Num, bool bNewTeam)
	{
		local bool bSuccess;
		local UTPlayerController UTPC;

		// Call parent implementation
		bSuccess = Global.ChangeTeam(Other, Num, bNewTeam);

		// OK, we changed teams while mid-game.  Update our voice muting state.
		UTPC = UTPlayerController( Other );
		if( UTPC != None )
		{
			SetupPlayerMuteList( UTPC, false );		// Force spectator channel?
		}

		return bSuccess;
	}

	function Timer()
	{
		local PlayerController P;

		Global.Timer();
		if ( !bFinalStartup )
		{
			bFinalStartup = true;
			PlayStartupMessage();
		}
		// force respawn failsafe
		if ( ForceRespawn() )
		{
			foreach WorldInfo.AllControllers(class'PlayerController', P)
			{
				if (P.Pawn == None && !P.PlayerReplicationInfo.bOnlySpectator && !P.IsTimerActive('DoForcedRespawn'))
				{
					P.ServerReStartPlayer();
				}
			}
		}
                //#### ENDWAVE ####
                if ( WaveMonsters >= WaveLength[CurrentWave]  ){
                        LogInternal("Wave "@CurrentWave@" over!!");
			if( CurrentWave >= MaxWaves )
			{
				EndGame(None,"TimeLimit");
				return;
			}

                        CurrentWave++;			
			WaveMonsters=0;
                        LogInternal("In Wave "@CurrentWave@" Now!");
			GotoState('BetweenWaves'); return;
                }		

                if ( NumMonsters < 3 * (NumPlayers + NumBots) && (NumMonsters + WaveMonsters) < WaveLength[CurrentWave] && CurrentWave <= MaxWaves )
		{
			LogInternal(">>>>>>>>>>>>>>>>>> NUMMONSTER: "@NumMonsters@" BELOW PLAYERS RATIO: "@(2*(NumPlayers+NumBots))@" <<<<<<<<<<<<<<<<<<<<<");
			LogInternal(">>>>>>>>>>>>>>>>>> WAVEMONSTERS: "@WaveMonsters@" <<<<<<<<<<<<<<<<<<");
			LogInternal(">>>>>>>>>>>>>>>>>> CURRENTWAVE: "@CurrentWave@" <<>> WAVELENGTH: "@WaveLength[CurrentWave]@"<<<<<<<<<<<<<<<<<<<<");
			LogInternal("(NumMonsters"@NumMonsters@"+WaveMonsters"@WaveMonsters@") < WaveLength[CurrentWave]"@WaveLength[CurrentWave]);
			Global.AddMonster();
		}
		

		if ( NeedPlayers() )
		{
			AddBot();
		}
		if (NumPlayers + NumBots == Queue.Length)
		{
			LogInternal("ALL Players Died!");
			EndGame(NONE,"TimeLimit");
		}
		//if ( bOverTime )
		//{
		//	EndGame(None,"TimeLimit");
		//}
		else if ( TimeLimit > 0 )
		{
			GameReplicationInfo.bStopCountDown = false;
			if ( GameReplicationInfo.RemainingTime <= 0 )
			{
				EndGame(None,"TimeLimit");
			}
		}
		else if ( (MaxLives > 0) && (NumPlayers + NumBots != 1) )
		{
			CheckMaxLives(none);
		}
	}

	function BeginState(Name PreviousStateName)
	{
		local PlayerReplicationInfo PRI;

		if (PreviousStateName != 'RoundOver')
		{
			foreach DynamicActors(class'PlayerReplicationInfo', PRI)
			{
				PRI.StartTime = 0;
			}
			GameReplicationInfo.ElapsedTime = 0;
			bWaitingToStartMatch = false;
			StartupStage = 5;
			PlayStartupMessage();
			StartupStage = 6;
		}
	}
}

state BetweenWaves
{
	function Timer()
	{
		Global.Timer();

		if(BetweenWavesCountDown <= 0)
			GotoState('MatchInProgress');

		LogInternal(BetweenWavesCountDown@"Seconds before next wave!");
		BetweenWavesCountdown--;
	}

	function BeginState(Name PreviousStateName)
	{
		local Controller C;
		
		if (Queue.length > 0)
			{
				C = GetPlayerFromQueue();
				RestartPlayer(C);
				if (C.PlayerReplicationInfo.Team != None)
				{
					C.PlayerReplicationInfo.Team.Score = C.PlayerReplicationInfo.Score;
				}
			}
		
		BetweenWavesCountdown = 10;
	}
}
defaultproperties
{

   WaveLength[0] = 10
   WaveLength[1] = 20
   WaveLength[2] = 30
   WaveLength[3] = 40
   WaveLength[4] = 50
   WaveLength[5] = 60

   CurrentWave = 0
   MaxWaves = 6

   NumRounds=0
   CurrentRound=1
   bWeaponStay=True
   bIgnoreTeamForVoiceChat=True
   Acronym="INV"
   Description="RBTTInvasion"
   ResetTimeDelay=15
   MidgameScorePanelTag="DuelPanel"
   //HUDType=Class'UTGame.UTDuelHUD'
   GameName="RBTTInvasion"
   GoalScore=0
   TimeLimit=5
   PlayerReplicationInfoClass=Class'UTGame.UTDuelPRI'
   OnlineStatsWriteClass=Class'UTGame.UTLeaderboardWriteDUEL'
   OnlineGameSettingsClass=Class'UTGame.UTGameSettingsDUEL'
   Name="Default__RBTTInvasion"
   ObjectArchetype=UTTeamGame'UTGame.Default__UTTeamGame'
   bForceAllRed=true
   MonsterTable(0)=(MonsterName="SkullCrab",MonsterClassName="RBTTInvasion.RBTTSkullCrab")
   MonsterTable(1)=(MonsterName="HumanSkeleton",MonsterClassName="RBTTInvasion.RBTTHumanSkeleton")
   MonsterTable(2)=(MonsterName="KrallSkeleton",MonsterClassName="RBTTInvasion.RBTTKrallSkeleton")
	MonsterTable(3)=(MonsterName="MiningRobot",MonsterClassName="RBTTInvasion.RBTTMiningRobot")
	MonsterTable(4)=(MonsterName="WeldingRobot",MonsterClassName="RBTTInvasion.RBTTWeldingRobot")
	MonsterTable(5)=(MonsterName="Spider",MonsterClassName="RBTTInvasion.RBTTSpider")
     //MonsterTable[1]=(MonsterName="KrallSkeleton",MonsterClassName="RBTTInvasion.RBTTKrallSkeleton")
	MonsterEnemyRosterClass="RBTTInvasion.RBTTMonsterTeamInfo"
	TeamAIType(0)=Class'UTGame.UTTeamAI'
	TeamAIType(1)=Class'RBTTInvasion.UTMonsterTeamAI'
	FallbackMonsterClass=class'RBTTInvasion.RBTTKrallSkeleton'
	MaxMonsters=16
}
