class UTMutator_LowGrav_RBTT extends UTMutator_LowGrav;

var 	float	OldGravityZ;				// We will cache the real gravity

function InitMutator(string Options, out string ErrorMessage)
{
	OldGravityZ = WorldInfo.WorldGravityZ;		// Cache the gravity before it changes
	Super.InitMutator(Options, ErrorMessage);	// Let the original mutator handle setting the gravity
}

event Destroyed()
{
	WorldInfo.WorldGravityZ = OldGravityZ; 		// Set the gravity back to normal
	Super.Destroyed();
}

defaultproperties
{
	bExportMenuData=False	// This mutator should not be selectable
}
