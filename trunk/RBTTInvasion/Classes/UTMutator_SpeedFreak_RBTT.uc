// Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
class UTMutator_SpeedFreak_RBTT extends UTMutator_SpeedFreak;

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
	bExportMenuData=False	// This mutator should not be selectable
}
