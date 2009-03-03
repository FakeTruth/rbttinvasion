/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */
class RBTTInvasionMutator extends UTMutator
	config(RBTTInvasion);
	
var int CurrentWave; 		//Current wave we're in
var bool bMatchHasStarted;

function InitMutator(string Options, out string ErrorMessage)
{
	Super.InitMutator(Options, ErrorMessage);
	SpawnNewGameRules();
}

function EndWave(GameRules G)
{
	WorldInfo.Game.GameRulesModifiers = G.NextGameRules;
	G.Destroy();
	
	CurrentWave++; //Move on to the next wave
	
	SpawnNewGameRules();
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
   GroupNames(0)="RBTTINVASION"  
   bExportMenuData=True
   Begin Object Name=Sprite ObjName=Sprite Archetype=SpriteComponent'UTGame.Default__UTMutator:Sprite'
      ObjectArchetype=SpriteComponent'UTGame.Default__UTMutator:Sprite'
   End Object
   Components(0)=Sprite   
   
   Name="Default__RBTTInvasionMutator"
   ObjectArchetype=Mutator'UTGame.Default__UTMutator'
   
   
}
