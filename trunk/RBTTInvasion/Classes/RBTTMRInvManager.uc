class RBTTMRInvManager extends InventoryManager;

var Inventory Stinger;

event PostBeginPlay()
{
	local Inventory NewWeapon;

	Super.PostBeginPlay();

	NewWeapon = Instigator.Spawn(class'UTGame.UTWeap_Stinger');
	UTWeapon(NewWeapon).AttachmentClass=class'UTAttachment_Stinger';
	AddInventory(NewWeapon);
	SetCurrentWeapon(Weapon(NewWeapon));
	Instigator.Weapon = Weapon(NewWeapon);
	Stinger = NewWeapon;
}



/**
 * Handle Pickup. Can Pawn pickup this item?
 *
 * @param	ItemClass Class of Inventory our Owner is trying to pick up
 * @param	Pickup the Actor containing that item (this may be a PickupFactory or it may be a DroppedPickup)
 *
 * @return	whether or not the Pickup actor should give its item to Other
 */
function bool HandlePickupQuery(class<Inventory> ItemClass, Actor Pickup)
{
	return False;
}

/**
 * Switch to best weapon available in loadout
 * Network: LocalPlayer
 */
simulated function SwitchToBestWeapon( optional bool bForceADifferentWeapon )
{
	local Weapon BestWeapon;

	//`log(">>>>>>>>>>>>>>>>>>>>>>>>>>SWITCH TO BEST WEAPON<<<<<<<<<<<<<<<<<<<<<<<<<<<");


	BestWeapon = Weapon(Stinger); //None;
	PendingWeapon = None;
	Instigator.Weapon.Activate();

	SetCurrentWeapon(BestWeapon);
}

defaultproperties
{

}
