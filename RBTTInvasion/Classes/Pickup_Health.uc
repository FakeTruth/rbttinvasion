class Pickup_Health extends Pickup_Base;

// ************************************** \\
//  MiscOption1 is the ammount of health  \\
//  MiscOption2 is heal over max yes/no   \\
// ************************************** \\

// Calculate how much the player can get healed
function int HealAmount(Pawn Recipient)
{
	return FClamp(Recipient.HealthMax - Recipient.Health, 0, MiscOption1);
}

// Give pickup to player
function GiveTo( Pawn P )
{
	if(MiscOption2 == 1)
		P.Health += MiscOption1;
	else
		P.Health += HealAmount(P);

	Super.GiveTo(P);
}

defaultproperties
{
	PickupMessage = "You picked up some health!";
	PickupSound=SoundCue'A_Pickups.Health.Cue.A_Pickups_Health_Small_Cue_Modulated'

	Begin Object Name=PickUpComp
		StaticMesh=StaticMesh'Pickups.Health_Medium.Mesh.S_Pickups_Health_Medium'
		CullDistance=7000
	End Object
}