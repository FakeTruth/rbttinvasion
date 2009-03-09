class UTMutator_FriendlyFire_RBTT extends UTMutator_FriendlyFire;

var 	float	OldFriendlyFireScale;				// We will cache the real scale

function InitMutator(string Options, out string ErrorMessage)
{
	OldFriendlyFireScale = UTTeamGame(WorldInfo.Game).FriendlyFireScale;		// Cache the scale before it changes
	Super.InitMutator(Options, ErrorMessage);					// Let the original mutator handle setting the FF scale
}

event Destroyed()
{
	UTTeamGame(WorldInfo.Game).FriendlyFireScale = OldFriendlyFireScale; 		// Set the FriendlyFire scale back to normal
	Super.Destroyed();
}

defaultproperties
{
	bExportMenuData=False	// This mutator should not be selectable
}
