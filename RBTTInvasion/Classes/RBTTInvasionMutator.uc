/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */
class RBTTInvasionMutator extends UTMutator
	config(RBTTInvasion);
	
var int CurrentWave; 		//Current wave we're in
var bool bMatchHasStarted;
var string InitMutatorOptionsString; // For sending the game options to other mutators/gameinfo's spawned by us

struct MutatorList
{
	var class<Mutator> 			MutatorClass;		// The dynamically loaded class of the corresponding MonsterClassName
	var bool				bSpawned;		// Only remove the mutator if it's been spawned by our mutator
	var int 				BeginWave;
	var int					EndWave;
};
var Array<MutatorList> 				MutatorConfig;		// Hold all monsternames and classes


function InitMutator(string Options, out string ErrorMessage)
{
	InitMutatorOptionsString = Options; // Save it for when initializing other gameinfo/mutators

	Super.InitMutator(Options, ErrorMessage);
	SpawnNewGameRules();
	UpdateMutators();
}

function EndWave(GameRules G)
{
	WorldInfo.Game.GameRulesModifiers = G.NextGameRules;
	G.Destroy();
	
	CurrentWave++; //Move on to the next wave
	
	SpawnNewGameRules();
	UpdateMutators();
}

function UpdateMutators()
{
	local int i;
	local Mutator mut;
	local bool bMutRemoved;
	local string ErrorMessage; // for initializing mutators
	
	for(i = MutatorConfig.length; i >= 0; i--)
	{
		if((MutatorConfig[i].BeginWave == CurrentWave) || (MutatorConfig[i].EndWave == CurrentWave)) 
		{
			mut = FindMutatorByClass(MutatorConfig[i].MutatorClass);
			
			if(MutatorConfig[i].EndWave == CurrentWave)
				if(MutatorConfig[i].bSpawned) // Don't remove it if it wasn't spawned by us
					if(mut != None)
					{
						WorldInfo.Game.RemoveMutator( mut );
						bMutRemoved = True;
						MutatorConfig[i].bSpawned = False; // It's removed, so not spawned
						LogInternal(">>Mutator Removed<<");
					}
			
			if(MutatorConfig[i].BeginWave == CurrentWave)
			{
				if(!MutatorConfig[i].bSpawned && mut == None && !bMutRemoved)
				{
					WorldInfo.Game.AddMutator(String(MutatorConfig[i].MutatorClass), False);
					MutatorConfig[i].bSpawned = True; // It's spawned by us
					LogInternal(">>Mutator Added<<");
				}
			}
			
			if(mut == None) // mut =! none only when not spawned by us
			{
				mut = FindMutatorByClass(MutatorConfig[i].MutatorClass); // It just got added, so find it
				if(mut != None)
					mut.InitMutator(InitMutatorOptionsString, ErrorMessage);
			}
		}
	}
}

function Mutator FindMutatorByClass(Class<Mutator> MutClass)
{
	local Mutator mut;

	for ( mut=WorldInfo.Game.BaseMutator; mut!=None; mut=mut.NextMutator )
		if ( mut.Class == MutClass )
			return mut;
}

function SpawnNewGameRules()
{
	local UTTeamGame Game;
	local RBTTInvasionGameRules G;

	Game = UTTeamGame(WorldInfo.Game);				// Get the GameType
	if (Game == None)
	{
		WarnInternal("RBTTInvasion Mutator Only Works With Team Games");
		Destroy();
	}
	else
	{
		Game.bForceAllRed=true;						// Make sure all players are on one team
		G = spawn(class'RBTTInvasionGameRules');	// Spawn the Invasion rules
		G.InvasionMut = self;
		Game.HUDType=Class'RBTTInvasionHUD';
		if (Game.GameRulesModifiers != None)		// Put the rules in the rules list
		G.NextGameRules = Game.GameRulesModifiers;
		Game.GameRulesModifiers = G;
		
		if(bMatchHasStarted)
			G.MatchStarting();
	}
}


function MatchStarting()
{
	//SpawnNewGameRules(); // Spawn before super, in case it needs to do something fancy..
	bMatchHasStarted = True;
	super.MatchStarting();
}

/*
function PostBeginPlay()
{
	Super.PostBeginPlay();
	LogInternal(">>>>>>>>>>>>>>>>>>RBTTInvasionGameMutator<<<<<<<<<<<<<<<<<<<<");
}
*/



defaultproperties
{
   MutatorConfig(0)=(MutatorClass=Class'UTGame.UTMutator_LowGrav', BeginWave=1, EndWave=2)


   GroupNames(0)="RBTTINVASION"  
   bExportMenuData=True
   Begin Object Name=Sprite ObjName=Sprite Archetype=SpriteComponent'UTGame.Default__UTMutator:Sprite'
      ObjectArchetype=SpriteComponent'UTGame.Default__UTMutator:Sprite'
   End Object
   Components(0)=Sprite   
   
   Name="Default__RBTTInvasionMutator"
   ObjectArchetype=Mutator'UTGame.Default__UTMutator'
   
   
}
