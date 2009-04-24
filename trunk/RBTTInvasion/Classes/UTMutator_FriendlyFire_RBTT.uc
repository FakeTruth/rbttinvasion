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
   bExportMenuData=False
   Begin Object Class=SpriteComponent Name=Sprite ObjName=Sprite Archetype=SpriteComponent'UTGame.Default__UTMutator_FriendlyFire:Sprite'
      ObjectArchetype=SpriteComponent'UTGame.Default__UTMutator_FriendlyFire:Sprite'
   End Object
   Components(0)=Sprite
   Name="Default__UTMutator_FriendlyFire_RBTT"
   ObjectArchetype=UTMutator_FriendlyFire'UTGame.Default__UTMutator_FriendlyFire'
}
