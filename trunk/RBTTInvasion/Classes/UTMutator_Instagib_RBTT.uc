class UTMutator_Instagib_RBTT extends UTMutator;

var	float	OldTeammateBoost;

function InitMutator(string Options, out string ErrorMessage)
{
	local UTGame Game;
	local Controller C;
	local Weapon Weap;

	Game = UTGame(WorldInfo.Game);
	
	if ( Game != None )
	{
		Game.DefaultInventory.AddItem(class'UTGame.UTWeap_InstagibRifle');
		
		if ( UTTeamGame(Game) != None )
		{
			OldTeammateBoost = UTTeamGame(Game).TeammateBoost;
			UTTeamGame(Game).TeammateBoost = 0.6;
		}
		
		foreach WorldInfo.AllControllers(class'Controller', C)
		{	
			if(C.IsA('UTPlayerController') || C.class == Class'UTGame.UTBot')
			{
				C.Pawn.InvManager.CreateInventory(class'UTGame.UTWeap_InstagibRifle');
				Weap = Weapon(C.Pawn.InvManager.FindInventoryType(class'UTGame.UTWeap_InstagibRifle'));
				UTWeapon(Weap).CurrentRating = 1.f;
				C.Pawn.InvManager.SetCurrentWeapon(Weap);
			}
		}
	}

	Super.InitMutator(Options, ErrorMessage);
}

event Destroyed()
{
	local UTGame Game;
	local Controller C;
	local int i;
	
	Game = UTGame(WorldInfo.Game);
	
	if ( Game != None )
	{
		for(i = Game.DefaultInventory.Length-1; i >= 0; i--)
		{
			if(Game.DefaultInventory[i] == class'UTGame.UTWeap_InstagibRifle')
			{
				Game.DefaultInventory.Remove(i, 1);
				break;
			}
		}
		
		foreach WorldInfo.AllControllers(class'Controller', C)
		{	
			if(C.IsA('UTPlayerController') || C.class == Class'UTGame.UTBot')
				C.Pawn.InvManager.RemoveFromInventory(C.Pawn.InvManager.FindInventoryType(class'UTGame.UTWeap_InstagibRifle'));
		}
	
		if ( UTTeamGame(Game) != None )
		{
			UTTeamGame(Game).TeammateBoost = OldTeammateBoost;
		}
	}
	
	Super.Destroyed();
}


defaultproperties
{
	bExportMenuData=False	// This mutator should not be selectable
}
