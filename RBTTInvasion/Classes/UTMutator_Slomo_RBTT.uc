// Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
class UTMutator_Slomo_RBTT extends UTMutator_Slomo;

/** Game speed modifier. */
var	float	OldGameSpeed;

function InitMutator(string Options, out string ErrorMessage)
{
	OldGameSpeed = WorldInfo.Game.GameSpeed;
	Super.InitMutator(Options, ErrorMessage);
}

event Destroyed()
{
	WorldInfo.Game.SetGameSpeed(OldGameSpeed);
	Super.Destroyed();
}

defaultproperties
{
   bExportMenuData=False
   Begin Object Class=SpriteComponent Name=Sprite ObjName=Sprite Archetype=SpriteComponent'UTGame.Default__UTMutator_Slomo:Sprite'
      ObjectArchetype=SpriteComponent'UTGame.Default__UTMutator_Slomo:Sprite'
   End Object
   Components(0)=Sprite
   Name="Default__UTMutator_Slomo_RBTT"
   ObjectArchetype=UTMutator_Slomo'UTGame.Default__UTMutator_Slomo'
}
