class Pickup_Armor extends Pickup_Base;

// ************************************** \\
//  MiscOption1 is the ammount of armor   \\
//  MiscOption2 is heal over max yes/no   \\
// ************************************** \\

// Returns how many shield units P could use
function int CanUseShield(UTPawn P)
{
	return Max(0,MiscOption1 - P.VestArmor);
}

// Give pickup to player
function GiveTo( Pawn P )
{
	if(UTPawn(P) == None)
		return;
	
	if(MiscOption2 == 1)
		UTPawn(P).VestArmor += MiscOption1; //P.VestArmor = Max(ShieldAmount, P.VestArmor);
	else
		UTPawn(P).VestArmor += CanUseShield(UTPawn(P));

	Super.GiveTo(P);
}

defaultproperties
{
	PickupSound=SoundCue'A_Pickups.Armor.Cue.A_Pickups_Armor_Chest_Cue'
	PickupMessage = "You picked up some armor!";

	Begin Object Name=PickUpComp
		StaticMesh=StaticMesh'Pickups.Armor.Mesh.S_Pickups_Armor'
		Translation=(X=0.0,Y=0.0,Z=-50.0)
	End Object
}