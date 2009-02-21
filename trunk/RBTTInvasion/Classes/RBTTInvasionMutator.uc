/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */
class RBTTInvasionMutator extends UTMutator
	
	config(RBTTInvasion);

function InitMutator(string Options, out string ErrorMessage)
{
	local UTTeamGame Game;
	local RBTTInvasionGameRules G;

	Super.InitMutator(Options, ErrorMessage);

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
	}
}

/*
function PostBeginPlay()
{
	Super.PostBeginPlay();
	LogInternal(">>>>>>>>>>>>>>>>>>RBTTInvasionGameMutator<<<<<<<<<<<<<<<<<<<<");
}

function MatchStarting()
{
	local UTTeamGame Game;
	Game = UTTeamGame(WorldInfo.Game);
	RBTTInvasionGameRules(Game.GameRulesModifiers).NumMonsters = 0;
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
