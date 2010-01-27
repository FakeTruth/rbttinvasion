class RBTTInvasionMutator extends UTMutator
	config(RBTTInvasion); // Our config ini, UT gets put in front of it, so it's "UTRBTTInvasion.ini" in your settings folder
	
var int CurrentWave; 			// Current wave we're in
var bool bMatchHasStarted;		// A check to see if the match has actually started before we send MatchStarting to the gamerules
var string InitMutatorOptionsString; 	// For sending the game options to other mutators/gameinfo's spawned by us
var int InvasionVersion;		// Version of the invasion mutator, added in the serverdetails when querying server
var GameRules CurrentRules;		// The last Invasion GameRules that spawned
var config bool bAllowTranslocator;	// Add translocator ??
var config bool bForceAllRed;		// Force all players to the red team?
var bool bThisIsMonsterHunt;		// Whether the ThisIsMonsterHunt actor was found
var string MonsterSpawnPoints;		// Is set in the map's INI file, where monsters should spawn

var int DesiredPlayerCount;         // Track this ourselves, because the gametypes FAIL in doing so

var config Array< string > InvasionMutators;	// Array of InvMut classes we want to use in this game
var InvMut AllInvasionMutators;		// Makes invasion modular. This is a chain of InvMut's

struct MonsterNames
{
	var string 				MonsterName;		// The name of the monster, so we can set it's name in the PRI
	var string 				MonsterClassName;	// The class of the monster as a string
	var class<Pawn> 			MonsterClass;		// The dynamically loaded class of the corresponding MonsterClassName
	var int					MonsterID;		// The ID of the monster, used in the wave configuration
	var int					Score;			// Points you get for killing this monster
	
	structdefaultproperties
	{
		MonsterName = "Monster"
		Score = 1;
	}
};
var config Array<MonsterNames> 			MonsterTable;		// Hold all monsternames and classes

struct MutatorList
{
	var string	 			MutatorClass;		// The class of the mutator you want in the game
	var bool				bSpawned;		// Be sure it's spawned by us, and not something else
	var int 				BeginWave;		// The wave the mutator will be spawned
	var int					EndWave;		// The wave in which beginning the mutator will be removed
	
	structdefaultproperties	
	{
		bSpawned = False
	}
};
var config Array<MutatorList> 			MutatorConfig;		// Hold the mutator configuration

replication
{
	if(Role == ROLE_Authority && bNetDirty)
		CurrentWave, CurrentRules;
}

function AddInvMut(string mutName)
{
	local class<InvMut> mutClass;
	local InvMut mut;
	
	mutClass = class<InvMut>(DynamicLoadObject(mutname, class'Class'));
	if(mutClass == none)
		return;
		
	// Make sure it's not added already
	for ( mut=AllInvasionMutators; mut!=None; mut=mut.NextInvMut )
		if ( mut.Class == mutClass )
		{
			`log("Not adding "$mutName$" because this InvMut is already added - "$mut);
			return;
		}
		
	mut = Spawn(mutClass);
	if (mut == None)
		return;
	
	if (AllInvasionMutators == None)
		AllInvasionMutators = mut;
	else
		AllInvasionMutators.AddInvMut(mut);
}

function RemoveInvMut( InvMut InvMutToRemove )
{
	local InvMut M;

	// remove from InvMut list
	if ( AllInvasionMutators == InvMutToRemove )
	{
		AllInvasionMutators = InvMutToRemove.NextInvMut;
	}
	else if ( AllInvasionMutators != None )
	{
		for ( M=AllInvasionMutators; M!=None; M=M.NextInvMut )
		{
			if ( M.NextInvMut == InvMutToRemove )
			{
				M.NextInvMut = InvMutToRemove.NextInvMut;
				break;
			}
		}
	}
}

function PostBeginPlay()
{
	local UTGame Game;
	local int i;
	
	`log(">>>>>>>>>>>>>>>>>>RBTTInvasionMutator.PostBeginPlay<<<<<<<<<<<<<<<<<<<<");

	Game = UTGame(WorldInfo.Game);
	
	`log(">>> ADDING TRANSLOCATOR <<<");
	if (bAllowTranslocator && !Game.bAllowTranslocator)
	{
		`log(">>> TRANSLOCATOR ALLOWED <<<");
		if(Game.TranslocatorClass == None)
			Game.TranslocatorClass = class'UTGameContent.UTWeap_Translocator_Content';
		Game.bAllowTranslocator = True;
	}
	
	for (i = 0; i < InvasionMutators.length; i++)
	{
		AddInvMut( InvasionMutators[i] );
	}
	
	`log("##################RBTTInvasionMutator.PostBeginPlay####################");
}

function bool CheckReplacement(Actor Other)
{
/*
	if(UTCTFBlueFlagBase(Other) != None)	// Replace blue flag by our 'improved' flag.
		UTCTFBlueFlagBase(Other).FlagType = Class'RBTTCTFMonsterFlag';
*/

	if(ThisIsMonsterHunt(Other) != None)
	{
		`log(">>>>>>>>>>>>>>>>>>><<<<<<<<<<<<<<<<<<<<<<<<<");
		`log("MONSTERHUNT WAS FOUND!!");
		`log("MONSTERHUNT WAS FOUND!!");
		`log("MONSTERHUNT WAS FOUND!!");
		`log("MONSTERHUNT WAS FOUND!!");
		`log(">>>>>>>>>>>>>>>>>>><<<<<<<<<<<<<<<<<<<<<<<<<");
		bThisIsMonsterHunt = True;
	}
		
	return True;
}

function Mutate (string MutateString, PlayerController Sender)
{
	local Actor A;
	local Array<Class> 	ActorList;
	local Array<Int>	ActorNumber;
	local int i;
	local bool bNoNew;
	
	`log(">>>>>>>>>>>>>>>>>>RBTTInvasionMutator.Mutate<<<<<<<<<<<<<<<<<<<<");

	if (Sender.PlayerReplicationInfo.bAdmin || Sender.WorldInfo.NetMode == NM_Standalone) {
		switch( Locs(MutateString) )
		{
			case "killallmonsters":
				RBTTInvasionGameRules(CurrentRules).KillAllMonsters();
				break;
				
			case "gotonextwave":
				RBTTInvasionGameRules(CurrentRules).KillAllMonsters();
				RBTTInvasionGameRules(CurrentRules).EndWave();
				break;
			case "listallactors":
				LogInternal("############List of actors############");
				ForEach WorldInfo.AllActors(Class'Actor', A)
				{
					bNoNew = False;
					if(String(A.Class) == "BattlePRI")
					{
						Sender.ClientMessage ("BPRI Owner:"@PlayerReplicationInfo(A).Owner);
						Sender.ClientMessage ("BPRI.PlayerName:"@PlayerReplicationInfo(A).PlayerName);
						Sender.ClientMessage ("BPRI Instigator:"@PlayerReplicationInfo(A).Instigator);
					}
					For(i = 0; i < ActorList.length; i++)
					{
						if(ActorList[i] == A.Class)
						{
							bNoNew = True;
							if(ActorNumber.length < i+1)
								ActorNumber[i] = 1;
							else
								ActorNumber[i]++;
						}
					}
					if(!bNoNew)
						ActorList.AddItem(A.Class);
				}
				For(i = 0; i < ActorList.length; i++)
					Sender.ClientMessage (ActorNumber[i]@"  :"@ActorList[i]);
				LogInternal("######################################");
				break;
			case "showserveroptions":
				if(WorldInfo.Game != None)
				{   
					Sender.ClientMessage ("ServerOptions:"@WorldInfo.Game.ServerOptions);
					Sender.ClientMessage ("BotRatio:"@UTGame(WorldInfo.Game).BotRatio);
					Sender.ClientMessage ("bPlayersVsBots:"@UTGame(WorldInfo.Game).bPlayersVsBots);
					Sender.ClientMessage ("MinNetPlayers:"@UTGame(WorldInfo.Game).MinNetPlayers);
					Sender.ClientMessage ("bAutoNumBots:"@UTGame(WorldInfo.Game).bAutoNumBots@" //Match bots to map's recommended bot count");
					Sender.ClientMessage ("DesiredPlayerCount:"@UTGame(WorldInfo.Game).DesiredPlayerCount@" // bots will fill in to reach this value as needed");
					
				}
				break;
		}
		
		if( Left(MutateString, Len("resplayer")) ~= "resplayer")
		{
			`log(">> Mutate "@MutateString@" <<");
			`log(">> Player to ressurect: "@Right(MutateString, Len(MutateString) - Len("resplayer "))@"<<");
			RBTTInvasionGameRules(CurrentRules).ResPlayer(Right(MutateString, Len(MutateString) - Len("resplayer ")), Sender.PlayerReplicationInfo);
			
		}
	//} else {
		//Sender.ClientMessage ("You need to be administrator for that!");
	}
	Super.Mutate(MutateString, Sender);
	`log("##################RBTTInvasionMutator.Mutate####################");
}

function InitMutator(string Options, out string ErrorMessage)
{
	local int i;
	`log(">>>>>>>>>>>>>>>>>>RBTTInvasionMutator.InitMutator<<<<<<<<<<<<<<<<<<<<");
	
	InitMutatorOptionsString = Options; 		// Save it for when initializing other gameinfo/mutators

	// We track this, so gamerules can't screw it up
	DesiredPlayerCount = Clamp(Class'GameInfo'.static.GetIntOption( Options, "NumPlay", 1 ),1,32);

	Super.InitMutator(Options, ErrorMessage);
	//SaveConfig();
	
	if(UTTeamGame(WorldInfo.Game) == None)
	{
		WarnInternal("RBTTInvasion Mutator Only Works With Team Games");
		Destroy();
		return;
	}
	
	UTTeamGame(WorldInfo.Game).bForceAllRed = bForceAllRed;
	
	for(i = MutatorConfig.length-1; i >= 0; i--) // Take a look at the entire mutatorlist
	{
		//change the classnames of the original mutators to ours, since they work better
		switch(MutatorConfig[i].MutatorClass)
		{
			case "UTGame.UTMutator_LowGrav":
			case "UTMutator_LowGrav":
				MutatorConfig[i].MutatorClass = "RBTTInvasion.UTMutator_LowGrav_RBTT";
				break;
			case "UTGame.UTMutator_FriendlyFire":
			case "UTMutator_FriendlyFire":
				MutatorConfig[i].MutatorClass = "RBTTInvasion.UTMutator_FriendlyFire_RBTT";
				break;
			case "UTGame.UTMutator_SpeedFreak":
			case "UTMutator_SpeedFreak":
				MutatorConfig[i].MutatorClass = "RBTTInvasion.UTMutator_SpeedFreak_RBTT";
				break;
			case "UTGame.UTMutator_Slomo":
			case "UTMutator_Slomo":
				MutatorConfig[i].MutatorClass = "RBTTInvasion.UTMutator_Slomo_RBTT";
				break;
			case "UTGame.UTMutator_Instagib":
			case "UTMutator_Instagib":
				MutatorConfig[i].MutatorClass = "RBTTInvasion.UTMutator_Instagib_RBTT";
				break;
			
		
		}
	}
	
	`log(">>>>>>>>>>>>>>>>>>default.MonsterTable.length:"@default.MonsterTable.Length);
	for(i=0;i < default.MonsterTable.length;i++)
	{
		`log("#####Loading monster"@i@": "@default.MonsterTable[i].MonsterClassName);
		default.MonsterTable[i].MonsterClass = class<Pawn>(DynamicLoadObject(default.MonsterTable[i].MonsterClassName,class'Class'));
	}
	
	//SpawnNewGameRules();				// Let the very first GameRules do things before playtime, enabling them to do special things
	//UpdateMutators();				// Set the mutators up for the first wave
	//UTTeamGame(WorldInfo.Game).HUDType=Class'RBTTInvasionHUD';		// Set the HUD to ours for the blurry screen
	
	GetMonsterSpawnPoints();
	`log("##################RBTTInvasionMutator.InitMutator####################");
}

// Get sum sheet
function GetMonsterSpawnPoints()
{
	local array<UTUIResourceDataProvider> MapProviders;
	local int i, j;
	local String Point, MapName;

	Class'UTUIDataStore_MenuItems'.static.GetAllResourceDataProviders(Class'UTUIDataProvider_InvasionMapInfo', MapProviders);
	i = MapProviders.Length;

	`log("====================================");
	`log("====GETTING MAP SETTING STUFFS======");
	for (j=0; j<i; ++j)
	{
		Point = UTUIDataProvider_InvasionMapInfo(MapProviders[j]).MonsterSpawnPoints;
		MapName = String(UTUIDataProvider_MapInfo(MapProviders[j]).name);
		if(Point != "")
		{
			if(MapName != "")
			{
				if(MapName == WorldInfo.GetMapName(True))
				{
					`log(MapName$":"$Point$"<- Current map");
					if(Point ~= "PathNode" || Point ~= "NavigationPoint" || Point ~= "PlayerStart" || Point ~= "RedPlayerStart" || Point ~= "BluePlayerStart")
						MonsterSpawnPoints = Point;
					else
					{
						`log("Unknown value for MonsterSpawnPoints"@Point$", defaulting to"@default.MonsterSpawnPoints);
						MonsterSpawnPoints = default.MonsterSpawnPoints;
					}
				}
				else
					`log(MapName$":"$Point);
			}
		}
	}
	`log("====================================");
}

// Wave has ended, probably gets called by the gamerules
function EndWave(GameRules G)
{
	`log(">>>>>>>>>>>>>>>>>>RBTTInvasionMutator.EndWave<<<<<<<<<<<<<<<<<<<<");

	if(AllInvasionMutators != None)
		AllInvasionMutators.EndWave(G);
	
	WorldInfo.Game.GameRulesModifiers = G.NextGameRules;	// Take the gamerules out of the list
	G.Destroy();						// Destroy the gamerules
	
	CurrentWave++;		 				// Move on to the next wave
	
	SpawnNewGameRules();					// Spawn the new gamerules
	UpdateMutators();					// Update the mutators
	
	if(AllInvasionMutators != None)
		AllInvasionMutators.StartWave(G);
	
	`log("##################RBTTInvasionMutator.EndWave####################");
}

// Spawn the mutators that need spawning and remove which has to be removed
function UpdateMutators()
{
	local int i;			// The first letter of... integer! Wewt! ^_^;
	local Mutator mut;		// The mutator we will spawn/initialize/remove
	local class<Mutator> MutClass;	// The class of the mutator
	local bool bMutRemoved;		// True if we just removed this mutator;
	local string ErrorMessage; 	// for initializing mutators
	//local UTPlayerController PC;	// For sending messages to this player
	
	`log(">>>>>>>>>>>>>>>>>>RBTTInvasionMutator.UpdateMutators<<<<<<<<<<<<<<<<<<<<");
	
	for(i = MutatorConfig.length-1; i >= 0; i--) // Take a look at the entire mutatorlist
		if((MutatorConfig[i].BeginWave == CurrentWave) || (MutatorConfig[i].EndWave == CurrentWave)) // Only get relevant mutators
		{
			`log(">> MutatorConfig["@i@"].bSpawned == "@MutatorConfig[i].bSpawned@" <<");
		
			MutClass = class<Mutator>(DynamicLoadObject(MutatorConfig[i].MutatorClass,class'Class'));
			mut = FindMutatorByClass(MutClass);				// Find the mutator so we can see if it exists or remove it
			
			if(MutatorConfig[i].EndWave == CurrentWave)			// Remove the mutator if it's his time...
				if(MutatorConfig[i].bSpawned) 				// Don't remove it if it wasn't spawned by us
					if(mut != None)					// Make sure the mutator actually exists
					{
						//foreach WorldInfo.AllControllers(class'UTPlayerController', PC)
						//{	PC.ReceiveLocalizedMessage(Class'RBTTMutatorMessage',0,,,mut.class);	}
						WorldInfo.game.BroadcastLocalized(Self,Class'RBTTMutatorMessage',0,,,mut.class);
						WorldInfo.Game.RemoveMutator( mut );	// Remove the mutator (takes it out of the chain)
						mut.Destroy();				// Destroy the mutator
						bMutRemoved = True;			// Set the flag that we just removed this mutator
						MutatorConfig[i].bSpawned = False; 	// It's removed, so not spawned
						`log(">>Mutator Removed<<");
					}
			
			if(MutatorConfig[i].BeginWave == CurrentWave)				// Spawn the mutator if we're in it's begin wave
			{
				if(!MutatorConfig[i].bSpawned && mut == None && !bMutRemoved)	// See if WE spawned it, and the mutator isn't spawned already, and we didn't just remove it
				{
					`log(MutatorConfig[i].MutatorClass);
					WorldInfo.Game.AddMutator(MutatorConfig[i].MutatorClass, False);		// Add the mutator
					MutatorConfig[i].bSpawned = True; 						// It's spawned by us
					`log(">>Mutator Added<<");
				}
			}
			
			if(mut == None) // mut =! none only when not spawned by us
			{
				mut = FindMutatorByClass(MutClass); 				// It just got added, so find it
				if(mut != None)							// See if it was actually found
				{
					mut.InitMutator(InitMutatorOptionsString, ErrorMessage);// Initialize the mutator
					//foreach WorldInfo.AllControllers(class'UTPlayerController', PC)			// Go through all players
					//{	PC.ReceiveLocalizedMessage(Class'RBTTMutatorMessage',1,,,mut.class);	}	// Send a message that this mutator has been added
					WorldInfo.game.BroadcastLocalized(Self,Class'RBTTMutatorMessage',1,,,mut.class);
				}
			}
		}
		
	`log("##################RBTTInvasionMutator.UpdateMutators####################");
}

// Find a mutator by it's class
function Mutator FindMutatorByClass(Class<Mutator> MutClass)
{
	local Mutator mut;

	`log(">>>>>>>>>>>>>>>>>>RBTTInvasionMutator.FindMutatorByClass<<<<<<<<<<<<<<<<<<<<");
	
	if(MutClass != None)
		for ( mut=WorldInfo.Game.BaseMutator; mut!=None; mut=mut.NextMutator ) 	// Search the entire chain
			if ( mut.Class == MutClass )					// We found the mutator if the classes match
				return mut;						// Return the mutator we were looking for, for further handling

	`log("##################RBTTInvasionMutator.FindMutatorByClass####################");
	return None; 	// We couldn't find anything, so return None
}

// Spawn the gamerules for a wave
function SpawnNewGameRules()
{
	local UTTeamGame Game;			// Quick reference
	local RBTTInvasionGameRules G;		// We're gonna spawn this, yes

	`log(">>>>>>>>>>>>>>>>>>RBTTInvasionMutator.SpawnNewGameRules<<<<<<<<<<<<<<<<<<<<");
	
	Game = UTTeamGame(WorldInfo.Game);	// Get the GameType
	if (Game == None)			// If it's not a teamgame, our monsters won't work! (yet)
	{
		WarnInternal("RBTTInvasion Mutator Only Works With Team Games");
		Destroy();			// Destroy this mutator, because it would only result in lotsa errors!
	}
	else
	{
		if(UTCTFGame(Game) != None)				// Special rules for CTF games
			G = spawn(class'RBTTCTFInvasionGameRules');	// Spawn the CTF Invasion rules
		else
			G = spawn(class'RBTTInvasionWaveGameRules');	// Spawn the regular Invasion rules
		CurrentRules = G;				// Cache it to a global variable
		G.InvasionMut = self;				// Quick reference to our mutator
		if (Game.GameRulesModifiers != None)		// Put the rules in the rules list
			G.NextGameRules = Game.GameRulesModifiers;	// Complete the chain
		Game.GameRulesModifiers = G;			// Set our GameRules as head of the chain
		
		if(bMatchHasStarted)				// See if the match has actually started
			G.MatchStarting();			// If so, send MatchStarting() to the GameRules
	}
	
	`log("##################RBTTInvasionMutator.SpawnNewGameRules####################");
}

// This function gets called when the match starts, that's when the players actually spawn.
function MatchStarting()
{
	`log(">>>>>>>>>>>>>>>>>>RBTTInvasionMutator.MatchStarting<<<<<<<<<<<<<<<<<<<<");

	UpdateMutators();
	if(!bThisIsMonsterHunt)
	{
		SpawnNewGameRules(); 		// Spawn before super, in case it needs to do something fancy..
		if(AllInvasionMutators != None)
			AllInvasionMutators.StartWave(CurrentRules);
	}
	bMatchHasStarted = True;	// The match has started, so set the flag
	super.MatchStarting();		// Let the super handle the rest of the function
	
	`log("##################RBTTInvasionMutator.MatchStarting####################");
}


/**
 * Use this function to send NotifyLogin to the Invasion GameRules
 * This is used to spawn the HUD when a player joins mid-game
 * 
 * Also use this, when somebody decides to add a bot, we need to adjust
 * the DesiredPlayerCount
 */
function NotifyLogin(Controller NewPlayer)
{
	`log(">>>>>>>>>>>>>>>>>>RBTTInvasionMutator.NotifyLogin<<<<<<<<<<<<<<<<<<<<");

	if(UTBot(NewPlayer) != None && UTGame(WorldInfo.Game) != none)
		DesiredPlayerCount = UTGame(WorldInfo.Game).DesiredPlayerCount;

	super.NotifyLogin(NewPlayer);
	if(RBTTInvasionGameRules(CurrentRules) != None)
		RBTTInvasionGameRules(CurrentRules).NotifyLogin(NewPlayer);
		
	GiveRBTTPRI(NewPlayer);
	
	`log("##################RBTTInvasionMutator.NotifyLogin####################");
}

function GiveRBTTPRI (Controller C)
{
	local RBTTPRI PRI;
	local UTPlayerReplicationInfo UTPRI;

	UTPRI = UTPlayerReplicationInfo(C.PlayerReplicationInfo);
	if (UTPRI != None) {
		PRI = Spawn (class'RBTTPRI',WorldInfo.Game, , vect(0, 0, 0), rot(0, 0, 0));
		if(PlayerController(C) != None && PRI != None)
		{
			PRI.PlayerOwner = PlayerController(C);
			PRI.InvasionMut = self;
			PRI.ServerSetup();
			
			PRI.NextReplicationInfo = UTPRI.CustomReplicationInfo;
			UTPRI.CustomReplicationInfo = PRI;
		}
		else
		{
			WarnInternal("Failed to spawn RBTTPlayerReplicationInfo!");
		}
	}
}

simulated static function RBTTPRI GetRBTTPRI(UTPlayerReplicationInfo PRI)
{
	local UTLinkedReplicationInfo LPRI;

	if (PRI == None) return None;
		if (PRI.CustomReplicationInfo == None) return None;
	for (LPRI = PRI.CustomReplicationInfo; LPRI != None; LPRI = LPRI.NextReplicationInfo) {
		if (RBTTPRI (LPRI) != None) return RBTTPRI (LPRI);
	}
	
  return None;
}

function bool AllowChangeTeam(Controller Other, out int num, bool bNewTeam)
{
	// You can't go to the monster team!!
	if(num == 1)
		return false;
	else
		return Super.AllowChangeTeam(Other, num, bNewTeam);
}

function NotifySetTeam(Controller Other, TeamInfo OldTeam, TeamInfo NewTeam, bool bNewTeam)
{
	Super.NotifySetTeam(Other, OldTeam, NewTeam, bNewTeam);
}

simulated static function RBTTInvasionMutator GetInvasionMutatorFrom(UTGame Game)
{
	local Mutator mut;

	if(Game == None)
		return None;
	
	for ( mut=Game.BaseMutator; mut!=None; mut=mut.NextMutator ) 		// Search the entire chain
		if ( RBTTInvasionMutator(mut) != None )				// We found the mutator if it's ours
			return RBTTInvasionMutator(mut);			// Return the mutator we were looking for, for further handling

	return None; 	// We couldn't find anything, so return None	
}

static function int IsMonster(Pawn P)
{
	if(P == None)
		return -1;
	
	return Default.MonsterTable.Find('MonsterClass', P.Class);
}

static function int GetMonsterScore(int Index)
{
	return Default.MonsterTable[Index].Score;
}

//
// server querying
//
function GetServerDetails( out GameInfo.ServerResponseLine ServerState )
{
	// append the mutator name.
	local int i;
	`log(">>>>>>>>>>>>>>>>>>RBTTInvasionMutator.GetServerDetails<<<<<<<<<<<<<<<<<<<<");
	i = ServerState.ServerInfo.Length;
	ServerState.ServerInfo.Length = i+1;
	ServerState.ServerInfo[i].Key = "Mutator";
	ServerState.ServerInfo[i].Value = "UT3 Invasion"@InvasionVersion;
	i++;
	ServerState.ServerInfo.Length = i+1;
	ServerState.ServerInfo[i].Key = "UT3 Invasion";
	ServerState.ServerInfo[i].Value = "Rev."@InvasionVersion;
	`log("##################RBTTInvasionMutator.GetServerDetails####################");
}

/**
 * Use this function to make sure no friggin bots keep on joining the game when a player leaves
 */
function NotifyLogout(Controller Exiting)
{
	local UTGame Game;

	Game = UTGame(WorldInfo.Game);
	if(Game != none)
	{
		if(Game.DesiredPlayerCount > DesiredPlayerCount)
			Game.DesiredPlayerCount = DesiredPlayerCount;
		else
			DesiredPlayerCount = Game.DesiredPlayerCount;
	}

	super.NotifyLogout(Exiting);
}

/** called on the server during seamless level transitions to get the list of Actors that should be moved into the new level
 * PlayerControllers, Role < ROLE_Authority Actors, and any non-Actors that are inside an Actor that is in the list
 * (i.e. Object.Outer == Actor in the list)
 * are all automatically moved regardless of whether theyre included here
 * only dynamic (!bStatic and !bNoDelete) actors in the PersistentLevel may be moved (this includes all actors spawned during gameplay)
 * this is called for both parts of the transition because actors might change while in the middle (e.g. players might join or leave the game)
 * @param bToEntry true if we are going from old level -> entry, false if we are going from entry -> new level
 * @param ActorList (out) list of actors to maintain
 */
function GetSeamlessTravelActorList(bool bToEntry, out array<Actor> ActorList)
{
	local int i;

	`log("=============================================");
	`log("==========GetSeamlessTravelActorList=========");
	
	for(i = 0; i < ActorList.Length; i++)
	{
		`log("Class ::"@ActorList[i]);
		if(MonsterReplicationInfo(ActorList[i]) != none)
			ActorList.Remove(i,1);
		if(RBTTMonsterController(ActorList[i]) != none)
			ActorList.Remove(i,1);
	}

	Super.GetSeamlessTravelActorList(bToEntry, ActorList);
	`log("=============================================");
	`log("=============================================");
}

defaultproperties
{
   //MutatorConfig(0)=()
   
   MonsterSpawnPoints="PathNode"
   
   bForceAllRed=True
   bAllowTranslocator=True
   InvasionVersion=333

   GroupNames(0)="INVASION"  
   bExportMenuData=True
   Begin Object Name=Sprite ObjName=Sprite Archetype=SpriteComponent'UTGame.Default__UTMutator:Sprite'
      ObjectArchetype=SpriteComponent'UTGame.Default__UTMutator:Sprite'
   End Object
   Components(0)=Sprite   
   
   Name="Default__RBTTInvasionMutator"
   ObjectArchetype=Mutator'UTGame.Default__UTMutator'
   
   bAlwaysRelevant=true
   RemoteRole=ROLE_SimulatedProxy
   NetUpdateFrequency=2
}
