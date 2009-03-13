class RBTTClientReplicator extends Actor;

var repnotify Controller OwnerController;

replication
{
	if ( bNetDirty && Role == ROLE_Authority)
		OwnerController;
}

simulated event ReplicatedEvent(name VarName)
{
	if (VarName == 'OwnerController')
		UpdateClientHUD(OwnerController);
	else
		Super.ReplicatedEvent(VarName);
}

function PostBeginPlay()
{
	SetTimer(1, true); // Destroy it after one second, hopefully the HUD got replicated by then...
}

function Timer()
{
	Destroy();
}

simulated function UpdateClientHUD(Controller C)
{
	local UTPlayerController PC;
	local UTProfileSettings Profile;
	local int OutIntValue;
	
	`log("?>>Instigator:"@Instigator);

	if(UTPlayerController(C) != None)
	{
		PC = UTPlayerController(C);
		if(PC.myHUD.class == Class'RBTTInvasionHUD')
			return;
		
		PC.ClientSetHUD( Class'RBTTInvasionHUD', None );
		
		Profile = UTProfileSettings(PC.OnlinePlayerData.ProfileProvider.Profile);
		if(Profile.GetProfileSettingValueIntByName('MouseSmoothingStrength', OutIntValue))
		{
			// Fix up non-patch values
			if ( OutIntValue < 2 )
			{
				OutIntValue = 10;
				Profile.SetProfileSettingValueInt(425, OutIntValue); // UTPID_MouseSmoothingStrength = 425
			}
			UTHUD(PC.myHUD).ConfiguredCrosshairScaling = 0.1 * OutIntValue;
		}
		
		if(Profile.GetProfileSettingValueIdByName('DisplayWeaponBar', OutIntValue))
			if(UTHUD(PC.myHUD) != None)
				UTHUD(PC.myHUD).bShowWeaponbar = (OutIntValue==UTPID_VALUE_YES);
	}
	
}

//simulated function Tick(float DeltaTime)
//{
//	`log("RBTTClientReplicator exists!");
//}


defaultproperties
{
	RemoteRole=ROLE_SimulatedProxy
}