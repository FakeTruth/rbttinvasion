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
}

simulated function bool HasAnyAmmo()
{
	return true;
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
	if(VSize(Instigator.Controller.Enemy.Location - Owner.Location) > 64)
		return; // enemy too far away to punch it in teh face!
	
	super.InstantFire();
	
	// Do an animation
	UTPawn(Instigator).FullBodyAnimSlot.PlayCustomAnim('Taunt_FB_Victory', 2.5, 0.2, 0.2, FALSE, TRUE);
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
	local float EnemyDist;

	if (Instigator.Controller.Enemy != None)
	{
		// recommend backing off if target is too close
		EnemyDist = VSize(Instigator.Controller.Enemy.Location - Owner.Location);
		if ( EnemyDist < 750 )
		{
			return (EnemyDist < 500) ? 1.0 : 0.5;
		}
		else if (EnemyDist > 1600)
		{
			return 0.5;
		}
	}

	return -0.1;
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
	local float EnemyDist;
	local UTBot B;

	B = UTBot(Instigator.Controller);
	if ( B == None )
	{
		bMeleeWeapon = False;
		return 1;
	}

	if ( B.Enemy == None )
	{
		bMeleeWeapon = False;
		return 1;
	}
	
	EnemyDist = VSize(B.Enemy.Location - Instigator.Location); // Player close > Melee, player not close > Fire
	if ( EnemyDist > MeleeWeaponRange )
	{
		bMeleeWeapon = False;
		return 1;
	}
	bMeleeWeapon = True;
	return 0;
}

// for bot combos
simulated function Projectile ProjectileFire()
{
	local Projectile p;

	p = Super.ProjectileFire();
	return p;
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

simulated function AttachWeaponTo(SkeletalMeshComponent MeshCpnt, optional name SocketName)
{
	Super(UTWeapon).AttachWeaponTo(MeshCpnt, SocketName);
}

defaultproperties
{
	MeleeWeaponRange = 500
	bDropOnDeath = False
	DroppedPickupClass = None

	// Weapon SkeletalMesh
	Begin Object class=AnimNodeSequence Name=MeshSequenceA
	End Object

	// Weapon SkeletalMesh
	Begin Object Name=FirstPersonMesh
		SkeletalMesh=SkeletalMesh'WP_ShockRifle.Mesh.SK_WP_ShockRifle_1P'
		AnimSets(0)=AnimSet'WP_ShockRifle.Anim.K_WP_ShockRifle_1P_Base'
		Animations=MeshSequenceA
		Rotation=(Yaw=-16384)
		FOV=60.0
	End Object

	//AttachmentClass=class'UTGame.UTAttachment_ShockRifle'

	Begin Object Name=PickupMesh
		SkeletalMesh=SkeletalMesh'WP_ShockRifle.Mesh.SK_WP_ShockRifle_3P'
	End Object

	InstantHitMomentum(0)=+20000.0

	WeaponFireTypes(0)=EWFT_InstantHit
	WeaponFireTypes(1)=EWFT_Projectile
	WeaponProjectiles(1)=class'UTProj_ShockBall'

	InstantHitDamage(0)=10
	FireInterval(0)=+0.77
	FireInterval(1)=+1.5
	InstantHitDamageTypes(0)=class'UTDmgType_ImpactHammer'
	InstantHitDamageTypes(1)=None

	WeaponFireSnd[0]=SoundCue'A_Weapon_ShockRifle.Cue.A_Weapon_SR_FireCue'
	WeaponFireSnd[1]=SoundCue'A_Weapon_ShockRifle.Cue.A_Weapon_SR_AltFireCue'
	WeaponEquipSnd=SoundCue'A_Weapon_ShockRifle.Cue.A_Weapon_SR_RaiseCue'
	WeaponPutDownSnd=SoundCue'A_Weapon_ShockRifle.Cue.A_Weapon_SR_LowerCue'
	PickupSound=SoundCue'A_Pickups.Weapons.Cue.A_Pickup_Weapons_Shock_Cue'

	MaxDesireability=0.65
	AIRating=0.65
	CurrentRating=0.65
	bInstantHit=true
	bSplashJump=false
	bRecommendSplashDamage=false
	bSniping=true
	ShouldFireOnRelease(0)=0
	ShouldFireOnRelease(1)=1

	ShotCost(0)=0
	ShotCost(1)=0

	FireOffset=(X=20,Y=5)
	PlayerViewOffset=(X=17,Y=10.0,Z=-8.0)

	AmmoCount=20
	LockerAmmoCount=30
	MaxAmmoCount=50

	FireCameraAnim(1)=CameraAnim'Camera_FX.ShockRifle.C_WP_ShockRifle_Alt_Fire_Shake'

	WeaponFireAnim(1)=WeaponAltFire

	MuzzleFlashSocket=MF
	MuzzleFlashPSCTemplate=WP_ShockRifle.Particles.P_ShockRifle_MF_Alt
	MuzzleFlashAltPSCTemplate=WP_ShockRifle.Particles.P_ShockRifle_MF_Alt
	MuzzleFlashColor=(R=200,G=120,B=255,A=255)
	MuzzleFlashDuration=0.33
	MuzzleFlashLightClass=class'UTGame.UTShockMuzzleFlashLight'
	CrossHairCoordinates=(U=256,V=0,UL=64,VL=64)
	LockerRotation=(Pitch=32768,Roll=16384)

	IconCoordinates=(U=728,V=382,UL=162,VL=45)

	QuickPickGroup=0
	QuickPickWeight=0.9

	WeaponColor=(R=160,G=0,B=255,A=255)

	InventoryGroup=4
	GroupWeight=0.5

	IconX=400
	IconY=129
	IconWidth=22
	IconHeight=48
}

