/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */
class DummyWeapon extends UTWeapon;

// AI properties (for shock combos)
var bool bRegisterTarget;

var int CurrentPath;
var int MeleeWeaponRange;
//-----------------------------------------------------------------
// AI Interface
function float GetAIRating()
{
	return 9.f;
/*
	local UTBot B;

	B = UTBot(Instigator.Controller);
	if ( (B == None) || (B.Enemy == None) || Pawn(B.Focus) == None )
		return AIRating;

	if ( !B.ProficientWithWeapon() )
		return AIRating;
	if ( B.Stopped() )
	{
		if ( !B.LineOfSightTo(B.Enemy) && (VSize(B.Enemy.Location - Instigator.Location) < 5000) )
			return (AIRating + 0.5);
		return (AIRating + 0.3);
	}
	else if ( VSize(B.Enemy.Location - Instigator.Location) > 1600 )
		return (AIRating + 0.1);
	else if ( B.Enemy.Location.Z > B.Location.Z + 200 )
		return (AIRating + 0.15);

	return AIRating;
*/
}

function float RelativeStrengthVersus(Pawn P, float Dist)
{
	return 1.0000;
}

// Monster weapons always have ammo
simulated function bool HasAnyAmmo()
{
	return true;
}

/**
 * Fires a projectile.
 * Spawns the projectile, but also increment the flash count for remote client effects.
 * Network: Local Player and Server
 */
simulated function Projectile ProjectileFire()
{
	if(RBTTMonster(Instigator) != None)
		return RBTTMonster(Instigator).ProjectileFire();
		
	return none;
}

/**
* Overriden to use GetPhysicalFireStartLoc() instead of Instigator.GetWeaponStartTraceLocation()
* @returns position of trace start for instantfire()
*/
simulated function vector InstantFireStartTrace()
{
	return GetPhysicalFireStartLoc();
}

/**
 * Performs an 'Instant Hit' shot.
 * Also, sets up replication for remote clients,
 * and processes all the impacts to deal proper damage and play effects.
 *
 * Network: Local Player and Server
 */
simulated function InstantFire()
{
	if(RBTTMonster(Instigator) != None)
		RBTTMonster(Instigator).InstantFire();
}

function float RangedAttackTime()
{
	local UTBot B;

	B = UTBot(Instigator.Controller);
	if ( (B == None) || (B.Enemy == None) )
		return 0;

	return FMin(2,0.3 + VSize(B.Enemy.Location - Instigator.Location)/class'UTProj_ShockBall'.default.Speed);
}

function float SuggestAttackStyle() // -1 to 1, low = stay off/snipe, high = charge/melee
{
	if(RBTTMonster(Instigator) != None)
		return RBTTMonster(Instigator).SuggestAttackStyle();

	return 0.00;
}

simulated function StartFire(byte FireModeNum)
{
	Super.StartFire(FireModeNum);
}


/* BestMode()
choose between regular or alt-fire
*/
function byte BestMode() // Can be used for switching from snipe to melee! 1 projectile 0 instant
{
	if(RBTTMonster(Instigator) != None)
		return RBTTMonster(Instigator).BestMode();
		
	return 0;
}

simulated function float GetFireInterval( byte FireModeNum )
{
	if(RBTTMonster(Instigator) != None)
		return RBTTMonster(Instigator).GetFireInterval(FireModeNum);
		
	return FireInterval[FireModeNum] * ((UTPawn(Owner)!= None) ? UTPawn(Owner).FireRateMultiplier : 1.0);
}

simulated function rotator GetAdjustedAim( vector StartFireLoc )
{
	return Super.GetAdjustedAim(StartFireLoc);
}

simulated state WeaponFiring
{
	/**
	 * Called when the weapon is done firing, handles what to do next.
	 */
	simulated event RefireCheckTimer()
	{
		Super.RefireCheckTimer();
	}
}

simulated function ImpactInfo CalcWeaponFire(vector StartTrace, vector EndTrace, optional out array<ImpactInfo> ImpactList)
{
	local ImpactInfo II;
	II = Super.CalcWeaponFire(StartTrace, EndTrace, ImpactList);
	return ii;
}

function SetFlashLocation( vector HitLocation )
{
	local byte NewFireMode;
	if( Instigator != None )
	{
		NewFireMode = CurrentFireMode;
		Instigator.SetFlashLocation( Self, NewFireMode , HitLocation );
	}
}


simulated function SetMuzzleFlashParams(ParticleSystemComponent PSC)
{
	Super.SetMuzzleFlashparams(PSC);
	if (CurrentFireMode == 0)
	{
		PSC.SetFloatParameter('Path1',1.0);
		PSC.SetFloatParameter('Path2',1.0);
		PSC.SetFloatParameter('Path3',1.0);
	}
	else
	{
		PSC.SetFloatParameter('Path1',0.0);
		PSC.SetFloatParameter('Path2',0.0);
		PSC.SetFloatParameter('Path3',0.0);
	}

}

simulated function PlayFireEffects( byte FireModeNum, optional vector HitLocation )
{
	if (FireModeNum>1)
	{
		Super.PlayFireEffects(0,HitLocation);
	}
	else
	{
		Super.PlayFireEffects(FireModeNum, HitLocation);
	}
}

/**
 * Skip over the Instagib rifle code */

simulated function SetSkin(Material NewMaterial)
{
	Super(UTWeapon).SetSkin(NewMaterial);
}

simulated function float GetTraceRange()
{
	if(RBTTMonster(Instigator) != None)
		return RBTTMonster(Instigator).GetTraceRange();
		
	return WeaponRange;
}

simulated function FireAmmunition()
{
	// Use ammunition to fire
	ConsumeAmmo( CurrentFireMode );

	// if this is the local player, play the firing effects
	// I rather play the sound from the pawn -FakeTruth
	// PlayFiringSound(); 

	// Handle the different fire types
	switch( WeaponFireTypes[CurrentFireMode] )
	{
		case EWFT_InstantHit:
			InstantFire();
			break;

		case EWFT_Projectile:
			ProjectileFire();
			break;

		case EWFT_Custom:
			CustomFire();
			break;
	}

	if( ( Instigator != None)
		&& ( AIController(Instigator.Controller) != None )
		)
	{
		AIController(Instigator.Controller).NotifyWeaponFired(self,CurrentFireMode);
	}
}

simulated function StopFireEffects(byte FireModeNum);

simulated function SetupArmsAnim(); // Arms animations..

 /**
 * Attach Weapon Mesh, Weapon MuzzleFlash and Muzzle Flash Dynamic Light to a SkeletalMesh
 *
 * @param	who is the pawn to attach to
 */
simulated function AttachWeaponTo( SkeletalMeshComponent MeshCpnt, optional Name SocketName ); // This weapon doesn't want to be attached! (I hope)

defaultproperties
{
   MeleeWeaponRange=500
   bExportMenuData=False
   bSniping=True
   AmmoCount=20
   LockerAmmoCount=30
   MaxAmmoCount=50
   ShotCost(0)=0
   ShotCost(1)=0
   FireCameraAnim(0)=None
   FireCameraAnim(1)=CameraAnim'Camera_FX.ShockRifle.C_WP_ShockRifle_Alt_Fire_Shake'
   IconX=400
   IconY=129
   IconWidth=22
   IconHeight=48
   IconCoordinates=(U=728.000000,V=382.000000,UL=162.000000,VL=45.000000)
   CrossHairCoordinates=(U=256.000000,V=0.000000)
   InventoryGroup=4
   GroupWeight=0.500000
   QuickPickGroup=0
   QuickPickWeight=0.900000
   WeaponFireAnim(1)="WeaponAltFire"
   WeaponFireSnd(0)=SoundCue'A_Weapon_ShockRifle.Cue.A_Weapon_SR_FireCue'
   WeaponFireSnd(1)=SoundCue'A_Weapon_ShockRifle.Cue.A_Weapon_SR_AltFireCue'
   WeaponPutDownSnd=SoundCue'A_Weapon_ShockRifle.Cue.A_Weapon_SR_LowerCue'
   WeaponEquipSnd=SoundCue'A_Weapon_ShockRifle.Cue.A_Weapon_SR_RaiseCue'
   WeaponColor=(B=255,G=0,R=160,A=255)
   MuzzleFlashSocket="MF"
   MuzzleFlashPSCTemplate=ParticleSystem'WP_ShockRifle.Particles.P_ShockRifle_MF_Alt'
   MuzzleFlashAltPSCTemplate=ParticleSystem'WP_ShockRifle.Particles.P_ShockRifle_MF_Alt'
   MuzzleFlashColor=(B=255,G=120,R=200,A=255)
   MuzzleFlashLightClass=Class'UTGame.UTShockMuzzleFlashLight'
   PlayerViewOffset=(X=17.000000,Y=10.000000,Z=-8.000000)
   LockerRotation=(Pitch=32768,Yaw=0,Roll=16384)
   CurrentRating=0.650000
   ShouldFireOnRelease(1)=1
   WeaponFireTypes(1)=EWFT_Projectile
   WeaponProjectiles(1)=Class'UTGame.UTProj_ShockBall'
   InstantHitDamage(0)=10.000000
   InstantHitMomentum(0)=20000.000000
   InstantHitDamageTypes(0)=Class'RBTTInvasion.MeleeDamage'
   InstantHitDamageTypes(1)=None
   FireOffset=(X=20.000000,Y=5.000000,Z=0.000000)
   bCanThrow=False
   bInstantHit=True
   Begin Object Class=UTSkeletalMeshComponent Name=FirstPersonMesh ObjName=FirstPersonMesh Archetype=UTSkeletalMeshComponent'UTGame.Default__UTWeapon:FirstPersonMesh'
      ObjectArchetype=UTSkeletalMeshComponent'UTGame.Default__UTWeapon:FirstPersonMesh'
   End Object
   Mesh=FirstPersonMesh
   AIRating=0.650000
   MaxDesireability=0.650000
   PickupSound=SoundCue'A_Pickups.Weapons.Cue.A_Pickup_Weapons_Shock_Cue'
   DroppedPickupClass=None
   Begin Object Class=SkeletalMeshComponent Name=PickupMesh ObjName=PickupMesh Archetype=SkeletalMeshComponent'UTGame.Default__UTWeapon:PickupMesh'
      ObjectArchetype=SkeletalMeshComponent'UTGame.Default__UTWeapon:PickupMesh'
   End Object
   DroppedPickupMesh=PickupMesh
   PickupFactoryMesh=PickupMesh
   Name="Default__DummyWeapon"
   ObjectArchetype=UTWeapon'UTGame.Default__UTWeapon'
}
