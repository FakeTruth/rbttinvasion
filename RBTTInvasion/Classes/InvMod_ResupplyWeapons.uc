class InvMod_ResupplyWeapons extends InvMod;

/**
 * Resupply all player's ammo for their current weapons
 */
function StartWave(GameRules G)
{
	local Inventory Item;
	local UTInventoryManager InvManager;
	local UTPlayerController PC;
	local int AmmoToAdd;
	local UTWeapon W;

	foreach WorldInfo.AllControllers(class'UTPlayerController', PC)
	{
		if(PC != NONE && PC.Pawn != NONE && PC.Pawn.InvManager != NONE)
		{
			InvManager = UTInventoryManager(PC.Pawn.InvManager);
			
			for (Item = InvManager.InventoryChain; Item != None; Item = Item.Inventory)
			{
				W = UTWeapon(Item);
				if(W != None && !W.bSuperWeapon)
				{
					AmmoToAdd = W.default.AmmoCount - W.AmmoCount;
					
					if(AmmoToAdd > 0)
						InvManager.AddAmmoToWeapon(AmmoToAdd, W.class);
				}
			}
		}
	}

	Super.StartWave(G);
}

defaultproperties
{
}