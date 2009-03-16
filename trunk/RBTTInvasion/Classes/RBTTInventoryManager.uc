class RBTTInventoryManager extends InventoryManager;

var Inventory MonsterWeapon;
var bool bCanPickupInventory;

event PostBeginPlay()
{
	local Inventory NewWeapon;

	Super.PostBeginPlay();

	// Get some info
	bCanPickupInventory = Instigator.bCanPickupInventory;
	


	if(RBTTMonster(Instigator).MonsterWeaponClass != None)
		NewWeapon = Instigator.Spawn(RBTTMonster(Instigator).MonsterWeaponClass);
	else if(RBTTMonster(Instigator).bEmptyHanded)
	{
		NewWeapon = Instigator.Spawn(class'DummyWeapon');
		if(RBTTMonster(Instigator).bMeleeMonster)
			UTWeapon(NewWeapon).bMeleeWeapon=true;
	}
	else if(RBTTMonster(Instigator).bMeleeMonster)
		NewWeapon = Instigator.Spawn(class'RBTTWeaponMelee');
	else
		NewWeapon = Instigator.Spawn(class'UTGame.UTWeap_ImpactHammer');

	UTWeapon(NewWeapon).FireInterval[0] /= RBTTMonster(Instigator).WeaponSpeedMultiplier;
	UTWeapon(NewWeapon).FireInterval[1] /= RBTTMonster(Instigator).WeaponSpeedMultiplier;

	if(RBTTMonster(Instigator).bInvisibleWeapon)
		UTWeapon(NewWeapon).AttachmentClass=None; //Components.Remove(Sprite)

	AddInventory(NewWeapon);
	SetCurrentWeapon(Weapon(NewWeapon));
	Instigator.Weapon = Weapon(NewWeapon);
	MonsterWeapon = NewWeapon;
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
	return (bCanPickupInventory) ? Super.HandlePickupQuery(ItemClass, Pickup) : False;
}

/**
 * Switch to best weapon available in loadout
 * Network: LocalPlayer
 */
simulated function SwitchToBestWeapon( optional bool bForceADifferentWeapon )
{
	local Weapon BestWeapon;

	if(bCanPickupInventory)
	{
		Super.SwitchToBestWeapon(bForceADifferentWeapon);
		return;
	}

	//`log(">>>>>>>>>>>>>>>>>>>>>>>>>>SWITCH TO BEST WEAPON<<<<<<<<<<<<<<<<<<<<<<<<<<<");


	BestWeapon = Weapon(MonsterWeapon);
	PendingWeapon = None;
	Instigator.Weapon.Activate();

	SetCurrentWeapon(BestWeapon);
}

defaultproperties
{
	PendingFire(0) = 0 // Set them, so it don't give accessed none
	PendingFire(1) = 0

}
