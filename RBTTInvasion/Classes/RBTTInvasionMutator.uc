class RBTTInvasionMutator extends UTMutator
	config(RBTTInvasion); // Our config ini, UT gets put in front of it, so it's "UTRBTTInvasion.ini" in your settings folder
	
var int CurrentWave; 			// Current wave we're in
var bool bMatchHasStarted;		// A check to see if the match has actually started before we send MatchStarting to the gamerules
var string InitMutatorOptionsString; 	// For sending the game options to other mutators/gameinfo's spawned by us
var string InvasionVersion;		// Version of the invasion mutator, added in the serverdetails when querying server
var GameRules CurrentRules;		// The last Invasion GameRules that spawned

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


function InitMutator(string Options, out string ErrorMessage)
{
	local int i;
	InitMutatorOptionsString = Options; 		// Save it for when initializing other gameinfo/mutators

	Super.InitMutator(Options, ErrorMessage);
	//SaveConfig();
	
	if(UTTeamGame(WorldInfo.Game) == None)
	{
		WarnInternal("RBTTInvasion Mutator Only Works With Team Games");
		Destroy();
		return;
	}
	
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
		
		}
	}
	
	//SpawnNewGameRules();				// Let the very first GameRules do things before playtime, enabling them to do special things
	UpdateMutators();				// Set the mutators up for the first wave
	UTTeamGame(WorldInfo.Game).HUDType=Class'RBTTInvasionHUD';		// Set the HUD to ours for the blurry screen
}

// Wave has ended, probably gets called by the gamerules
function EndWave(GameRules G)
{
	WorldInfo.Game.GameRulesModifiers = G.NextGameRules;	// Take the gamerules out of the list
	G.Destroy();						// Destroy the gamerules
	
	CurrentWave++;		 				// Move on to the next wave
	
	SpawnNewGameRules();					// Spawn the new gamerules
	UpdateMutators();					// Update the mutators
}

// Spawn the mutators that need spawning and remove which has to be removed
function UpdateMutators()
{
	local int i;			// The first letter of... integer! Wewt! ^_^;
	local Mutator mut;		// The mutator we will spawn/initialize/remove
	local class<Mutator> MutClass;	// The class of the mutator
	local bool bMutRemoved;		// True if we just removed this mutator;
	local string ErrorMessage; 	// for initializing mutators
	
	for(i = MutatorConfig.length-1; i >= 0; i--) // Take a look at the entire mutatorlist
		if((MutatorConfig[i].BeginWave == CurrentWave) || (MutatorConfig[i].EndWave == CurrentWave)) // Only get relevant mutators
		{
			MutClass = class<Mutator>(DynamicLoadObject(MutatorConfig[i].MutatorClass,class'Class'));
			mut = FindMutatorByClass(MutClass);				// Find the mutator so we can see if it exists or remove it
			
			if(MutatorConfig[i].EndWave == CurrentWave)			// Remove the mutator if it's his time...
				if(MutatorConfig[i].bSpawned) 				// Don't remove it if it wasn't spawned by us
					if(mut != None)					// Make sure the mutator actually exists
					{
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
					//WorldInfo.Game.AddMutator("RBTTInvasion.UTMutator_LowGrav_RBTT", False);
					MutatorConfig[i].bSpawned = True; 						// It's spawned by us
					`log(">>Mutator Added<<");
				}
			}
			
			if(mut == None) // mut =! none only when not spawned by us
			{
				mut = FindMutatorByClass(MutClass); 				// It just got added, so find it
				if(mut != None)							// See if it was actually found
					mut.InitMutator(InitMutatorOptionsString, ErrorMessage);// Initialize the mutator
			}
		}
}

// Find a mutator by it's class
function Mutator FindMutatorByClass(Class<Mutator> MutClass)
{
	local Mutator mut;

	if(MutClass != None)
		for ( mut=WorldInfo.Game.BaseMutator; mut!=None; mut=mut.NextMutator ) 	// Search the entire chain
			if ( mut.Class == MutClass )					// We found the mutator if the classes match
				return mut;						// Return the mutator we were looking for, for further handling

	return None; 	// We couldn't find anything, so return None
}

// Spawn the gamerules for a wave
function SpawnNewGameRules()
{
	local UTTeamGame Game;			// Quick reference
	local RBTTInvasionGameRules G;		// We're gonna spawn this, yes

	Game = UTTeamGame(WorldInfo.Game);	// Get the GameType
	if (Game == None)			// If it's not a teamgame, our monsters won't work! (yet)
	{
		WarnInternal("RBTTInvasion Mutator Only Works With Team Games");
		Destroy();			// Destroy this mutator, because it would only result in lotsa errors!
	}
	else
	{
		//Game.bForceAllRed=true;			// This is done in the GameRules itself now
		G = spawn(class'RBTTInvasionGameRules');	// Spawn the Invasion rules
		CurrentRules = G;				// Cache it to a global variable
		G.InvasionMut = self;				// Quick reference to our mutator
		//Game.HUDType=Class'RBTTInvasionHUD';		// Set the HUD to ours for the blurry screen
		if (Game.GameRulesModifiers != None)		// Put the rules in the rules list
		G.NextGameRules = Game.GameRulesModifiers;	// Complete the chain
		Game.GameRulesModifiers = G;			// Set our GameRules as head of the chain
		
		if(bMatchHasStarted)				// See if the match has actually started
			G.MatchStarting();			// If so, send MatchStarting() to the GameRules
	}
}

// This function gets called when the match starts, that's when the players actually spawn.
function MatchStarting()
{
	bMatchHasStarted = True;	// The match has started, so set the flag
	SpawnNewGameRules(); 	// Spawn before super, in case it needs to do something fancy..
	super.MatchStarting();		// Let the super handle the rest of the function
}


// Use this function to send NotifyLogin to the Invasion GameRules
// This is used to spawn the HUD when a player joins mid-game
/*
function NotifyLogin(Controller NewPlayer)
{
	super.NotifyLogin(NewPlayer);
	`log(">> RBTTInvasionMutator.NotifyLogin <<");
	if(CurrentRules != None)
		RBTTInvasionGameRules(CurrentRules).NotifyLogin(NewPlayer);
}
*/

/*
function PostBeginPlay()
{
	Super.PostBeginPlay();
	`log(">>>>>>>>>>>>>>>>>>RBTTInvasionGameMutator<<<<<<<<<<<<<<<<<<<<");
}
*/

//
// server querying
//
function GetServerDetails( out GameInfo.ServerResponseLine ServerState )
{
	// append the mutator name.
	local int i;
	i = ServerState.ServerInfo.Length;
	ServerState.ServerInfo.Length = i+1;
	ServerState.ServerInfo[i].Key = "Mutator";
	ServerState.ServerInfo[i].Value = "UT3 Invasion"@InvasionVersion;
	i++;
	ServerState.ServerInfo.Length = i+1;
	ServerState.ServerInfo[i].Key = "UT3 Invasion";
	ServerState.ServerInfo[i].Value = InvasionVersion;
}

defaultproperties
{
   MutatorConfig(0)=(MutatorClass="UTGame.UTMutator_LowGrav", BeginWave=1, EndWave=2)

   InvasionVersion="Rev 42"

   GroupNames(0)="INVASION"  
   bExportMenuData=True
   Begin Object Name=Sprite ObjName=Sprite Archetype=SpriteComponent'UTGame.Default__UTMutator:Sprite'
      ObjectArchetype=SpriteComponent'UTGame.Default__UTMutator:Sprite'
   End Object
   Components(0)=Sprite   
   
   Name="Default__RBTTInvasionMutator"
   ObjectArchetype=Mutator'UTGame.Default__UTMutator'
   
   
}
