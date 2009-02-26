class RBTTSpider_Weapon extends UTWeapon;

var float MinDamage;
var float MaxDamage;
var float MinForce;
var float MaxForce;
var float MinSelfDamage;
var float SelfForceScale;
var float SelfDamageScale;

var int PowerLevel;

/** This holds when the hammer began charging */
var float ChargeTime;

/** The charging animations*/
var name ChargeAnim;
var name ChargeIdleAnim;

/** How long does it take for a full charge */
var float MaxChargeTime;

/** Each shot will have at least this amount of charge */
var float MinChargeTime;

/** The sound that plays while charging */
var SoundCue WeaponChargeSnd;

/** The sound that plays while charging EMP */
var SoundCue WeaponEMPChargeSnd;

/** Sound played when you take damage from your own hammer */
var SoundCue ImpactJumpSound;

/** This is the actor that was hit automatically */
var actor AutoHitActor;

/** auto fire range */
var float AutoFireRange;

/** Max damage done to vehicle by EMP (alt-fire) */
var float EMPDamage;

/** currently charging hammer */
var bool bIsCurrentlyCharging;

var particlesystem ChargeEffect[2];

var MaterialInstanceConstant BloodMIC;

var ParticleSystem AltHitEffect;
/** played when target is killed by hammer */
var CameraAnim ImpactKillCameraAnim;



function float RelativeStrengthVersus(Pawn P, float Dist)
{
	return FMax(0, (2500 - Dist)/2500);
}

simulated function SetSkin(Material NewMaterial)
{
	super.SetSkin(NewMaterial);
	BloodMIC = Mesh.CreateAndSetMaterialInstanceConstant(0);
}

function GivenTo(Pawn ThisPawn, optional bool bDoNotActivate)
{
	Super.GivenTo(ThisPawn, bDoNotActivate);
}

simulated function rotator GetAdjustedAim(vector StartFireLoc)
{
	return Super.GetAdjustedAim(StartFireLoc);
}

function float GetAIRating()
{
	local UTBot B;
	local float EnemyDist;

	B = UTBot(Instigator.Controller);
	if (B == None)
	{
		return AIRating;
	}

	if (B.Enemy == None)
	{
		return AIRating;
	}

	EnemyDist = VSize(B.Enemy.Location - Instigator.Location);
	if (B.Stopped() && EnemyDist > 100.f)
	{
		return 0.1;
	}

	if (EnemyDist > 400)
	{
		return 0.1;
	}
	if (Instigator.Weapon != self && EnemyDist < 120)
	{
		return 1;
	}
	return 1;
}

function byte BestMode()
{

	return 0;

}

/**
  * Always keep charging impact hammer
  */
function bool CanAttack(Actor Other)
{
	return true;
}

function float SuggestAttackStyle()
{
	return 1.0;
}

reliable client function ClientAutoFire()
{
	if (Role < ROLE_Authority)
	{
		//PlayFireEffects(0, Location);
		ImpactFire();
	}
}

simulated function ImpactFire()
{
	FireAmmunition();
	//Gonna add the function call to play effects on the pawn 
}

simulated function bool HasAnyAmmo()
{
	return true;
}

/**  figure out how close P is to aiming at the center of Target
	@return the cosine of the angle of P's aim
*/
function float CalcAim(Pawn P, Pawn Target)
{
	local float Aim, EffectiveSkill;
	local UTBot B;

	Aim = vector(P.GetViewRotation()) dot Normal(Target.Location - P.Location);
	B = UTBot(P.Controller);
	if (B != None)
	{
		EffectiveSkill = B.Skill + B.Accuracy;
		if (B.FavoriteWeapon == Class)
		{
			EffectiveSkill += 3.0;
		}
		// if the bot just happens to be looking away from the target, use the real angle, otherwise make one up based on the bot's skill
		Aim = FMin(Aim, FMin(1.0, 1.0 - 0.30 + (0.02 * EffectiveSkill) + (0.10 * FRand())));
	}

	return Aim;
}

simulated function InstantFire()
{
	super.InstantFire();
	//SetFlashLocation(Location);
}


simulated function ProcessInstantHit( byte FiringMode, ImpactInfo Impact )
{
	local float Damage, SelfDamage, Force, Scale, Aim, EnemyAim;
	local UTInventoryManager UTInvManager;
	local UTPawn P;
	local UTVehicle_Hoverboard H;
	local class<UTEmitCameraEffect> CameraEffect;
	local class<UTDamageType> UTDT;
	local UTPlayerController PC;

	if (WorldInfo.NetMode != NM_DedicatedServer && Impact.HitActor != None)
	{
		//PlayImpactEffect(FiringMode, Impact);
	}

	if (Role == Role_Authority )
	{
		// If we auto-hit something, guarantee the strike
		if ( AutoHitActor != none )
		{
			Impact.HitActor = AutoHitActor;
			AutoHitActor = none;
		}

		if ( Impact.HitActor != None && Instigator != None && Instigator.Health > 0 )
		{
			// if we hit something on the server, then deal damage to it.
		    Scale = (FRand());
			P = UTPawn(Impact.HitActor);
			if ( P == None )
			{
				H = UTVehicle_Hoverboard(Impact.HitActor);
				if ( H != None )
				{
					P = UTPawn(H.Driver);
					if ( P == None )
					{
						return;
					}
				}
			}

			if ( FiringMode == 0 )
			{
				Damage = MinDamage + Scale * (MaxDamage - MinDamage);
				Force = MinForce + Scale * (MaxForce - MinForce);
				if (P != None && P != Instigator)
				{
					if ( VSize(Impact.HitLocation - Instigator.GetWeaponStartTraceLocation()) > AutoFireRange )
					{
						// no damage if out of close range
						Damage = 0;
					}

					P.TakeDamage(Damage, Instigator.Controller, Impact.HitLocation, Force * Impact.RayDir, InstantHitDamageTypes[0], Impact.HitInfo, self);

					PC = UTPlayerController(Instigator.Controller);
					if (P.Health <= 0 && PC != None )
					{
						if ( !class'GameInfo'.static.UseLowGore(WorldInfo) )
						{
							UTDT = class<UTDamageType>(InstantHitDamageTypes[0]);
							if (UTDT != None)
							{
								CameraEffect = UTDT.static.GetDeathCameraEffectInstigator(P);
								if (CameraEffect != None)
								{
									UTPlayerController(Instigator.Controller).ClientSpawnCameraEffect(CameraEffect);
								}
							}
						}
						PC.ClientPlayCameraAnim(ImpactKillCameraAnim);
					}

				}
				else
				{
					SelfDamage = MinSelfDamage + (SelfDamageScale * Damage);
					Impact.HitActor.TakeDamage(0, Instigator.Controller, Impact.HitLocation, Force * Impact.RayDir, InstantHitDamageTypes[0], Impact.HitInfo, self);
					Instigator.TakeDamage(SelfDamage, Instigator.Controller, Location, SelfForceScale * Force * Impact.RayDir, InstantHitDamageTypes[0], Impact.HitInfo, self);
					WeaponPlaySound(ImpactJumpSound);
				}
			}

			PowerLevel = 0;
		}
	}
}

// always have hammer and always have EMPPulse.
simulated function bool HasAmmo( byte FireModeNum, optional int Amount )
{
	return true;
}

simulated event float GetPowerPerc()
{
	return 0;
}

simulated function AttachWeaponTo(SkeletalMeshComponent MeshCpnt, optional name SocketName)
{
	Super.AttachWeaponTo(MeshCpnt, SocketName);

	// so replication is guaranteed to happen when we start charging and set it to 0 or 1
	SetCurrentFireMode(2);
}

simulated state Active
{
	simulated function BeginState(name PreviousStateName)
	{
		Super.BeginState(PreviousStateName);
	}
}

event ImpactAutoFire()
{
	local Vector		StartTrace, EndTrace;
	local vector		HitLocation, HitNormal;
	local actor			HitActor;

	// define trace end points
	StartTrace	= Instigator.GetWeaponStartTraceLocation();
	EndTrace	= StartTrace + Vector(GetAdjustedAim( StartTrace )) * AutoFireRange;

	// Perform trace to retrieve hit info
	HitActor = Trace(HitLocation, HitNormal, EndTrace, StartTrace, true,,,TRACEFLAG_Blocking);
	if ( (HitActor != None) && !HitActor.bWorldGeometry )
	{
		AutoHitActor = None;
		if ( CurrentFireMode == 0 )
		{
			// auto fire against non-vehicles and translocators
			if ( ((Pawn(HitActor) != None) && ((Vehicle(HitActor) == None) || HitActor.IsA('UTVehicle_Hoverboard'))) || (UTProj_TransDisc(HitActor) != None) )
			{
				AutoHitActor = HitActor;
				ClientAutoFire();
				//PlayFireEffects(0, Location);
				ImpactFire();
			}
		}
		else
		{
			// auto fire against vehicles, UTPawns, and deployables
			if ( (Vehicle(HitActor) != None) || (UTDeployedActor(HitActor) != None) || UTPawn(HitActor) != none )
			{
				AutoHitActor = HitActor;
				ClientAutoFire();
				//PlayFireEffects(0, Location);
				ImpactFire();
			}
		}
	}
}


simulated function StopFireEffects(byte FireModeNum);

defaultproperties
{
	WeaponColor=(R=255,G=255,B=128,A=255)
	PlayerViewOffset=(X=0,Y=0.0,Z=0)
	SmallWeaponsOffset=(X=12.0,Y=6.0,Z=-6.0)

	WeaponCanvasXPct=0.45
	WeaponCanvasYPct=0.45

	Begin Object class=AnimNodeSequence Name=MeshSequenceA
	End Object

	Begin Object Name=FirstPersonMesh
		SkeletalMesh=SkeletalMesh'WP_ImpactHammer.Mesh.SK_WP_Impact_1P'
		Materials(0)=Material'WP_ImpactHammer.Materials.M_WP_ImpactHammer_Base'
		PhysicsAsset=None
		AnimSets(0)=AnimSet'WP_ImpactHammer.Anims.K_WP_Impact_1P_Base'
		Animations=MeshSequenceA
		FOV=75
	End Object
	AttachmentClass=class'UTGame.UTAttachment_ImpactHammer'

	Components.Remove(PickupMesh)

	WeaponChargeSnd=SoundCue'A_Weapon_ImpactHammer.ImpactHammer.A_Weapon_ImpactHammer_FireLoop_Cue'
	WeaponEMPChargeSnd=SoundCue'A_Weapon_ImpactHammer.ImpactHammer.A_Weapon_ImpactHammer_AltFireLoop_Cue'
	WeaponFireSnd[0]=SoundCue'A_Weapon_ImpactHammer.ImpactHammer.A_Weapon_ImpactHammer_AltFire_Cue'
	WeaponFireSnd[1]=SoundCue'A_Weapon_ImpactHammer.ImpactHammer.A_Weapon_ImpactHammer_AltImpact_Cue'
	WeaponPutDownSnd=SoundCue'A_Weapon_ImpactHammer.ImpactHammer.A_Weapon_ImpactHammer_Lower_Cue'
	WeaponEquipSnd=SoundCue'A_Weapon_ImpactHammer.ImpactHammer.A_Weapon_ImpactHammer_Raise_Cue'

	WeaponFireTypes(0)=EWFT_InstantHit
	WeaponFireTypes(1)=EWFT_InstantHit
	WeaponFireTypes(2)=EWFT_None
	WeaponFireTypes(3)=EWFT_None
	Spread(2)=0.0

	FiringStatesArray(0)=WeaponChargeUp
	FiringStatesArray(1)=WeaponChargeUp

	WeaponRange=110.0
	AutoFireRange=110.0

	FireInterval[0]=1.1//+0.1
	FireInterval[1]=1.1//+0.1
	FireInterval[2]=1.1
	FireInterval[3]=1.1

	FireOffset=(X=20)

	InstantHitDamageTypes(0)=class'UTDmgType_ImpactHammer'
	InstantHitDamage(0)=10
	InstantHitDamageTypes(1)=class'UTDmgType_EMP'
	InstantHitDamage(1)=10
	InstantHitDamageTypes(2)=none
	InstantHitDamageTypes(3)=class'UTDmgType_ImpactHammer' // 3 is when bloody from firetype 0

	MuzzleFlashSocket=MuzzleFlashSocket
	MuzzleFlashPSCTemplate=ParticleSystem'WP_ImpactHammer.Particles.P_WP_ImpactHammer_Primary_Hit'
	MuzzleFlashAltPSCTemplate=ParticleSystem'WP_ImpactHammer.Particles.P_WP_ImpactHammer_Secondary_Hit'
	bMuzzleFlashPSCLoops=true
	MuzzleFlashDuration=0.33
	ChargeEffect[0]=ParticleSystem'WP_ImpactHammer.Particles.P_WP_ImpactHammer_Charge_Primary'
	ChargeEffect[1]=ParticleSystem'WP_ImpactHammer.Particles.P_WP_Impact_Charge_Secondary'


	AIRating=+0.35
	CurrentRating=+0.45
	bFastRepeater=true
	bInstantHit=true
	bSplashJump=false
	bRecommendSplashDamage=false
	bSniping=false
	ShouldFireOnRelease(0)=0
	ShouldFireOnRelease(1)=0
	bCanThrow=false
	bMeleeWeapon=true

	InventoryGroup=1
	GroupWeight=0.7

	ShotCost(0)=0
	ShotCost(1)=1

	FireCameraAnim[0]=CameraAnim'Camera_FX.ImpactHammer.C_WP_ImpactHammer_Primary_Fire_Shake'
	FireCameraAnim[1]=CameraAnim'Camera_FX.ImpactHammer.C_WP_ImpactHammer_Alt_Fire_Shake'

 	WeaponFireAnim(0)=WeaponFire
	WeaponFireAnim(1)=WeaponFire
	WeaponFireAnim(2)=WeaponFire
	WeaponFireAnim(3)=WeaponFire
	ArmFireAnim(0)=WeaponFire
	ArmFireAnim(1)=WeaponFire
	ArmFireAnim(2)=WeaponFire
	ArmFireAnim(3)=WeaponFire

 	WeaponPutDownAnim=WeaponPutDown
	ArmsPutDownAnim=WeaponPutDown
	WeaponEquipAnim=WeaponEquip
	ArmsEquipAnim=WeaponEquip

	ChargeAnim=weaponcharge
	ChargeIdleAnim=weaponchargedidle

	MaxDamage=140.0
	MinDamage=20.0
	MinForce=40000.0
	MaxForce=100000.0
	MinSelfDamage=8
	SelfForceScale=-1.2
	SelfDamageScale=0.3

	MaxChargeTime=2.5
	MinChargeTime=1.0

	CrossHairCoordinates=(U=64,V=0,UL=64,VL=64)
	IconCoordinates=(U=453,V=327,UL=135,VL=57)

	AmmoCount=0;
	MaxAmmoCount=5;
	EMPDamage=150.0
	AmmoDisplayType=EAWDS_None

	ArmsAnimSet=AnimSet'WP_ImpactHammer.Anims.K_WP_Impact_1P_Arms'
	ImpactJumpSound=SoundCue'A_Weapon_ImpactHammer.ImpactHammer.A_Weapon_ImpactHammer_FireBodyThrow_Cue'

	AltHitEffect=ParticleSystem'WP_ImpactHammer.Particles.P_WP_ImpactHammer_Secondary_Hit_Impact'

	ImpactKillCameraAnim=CameraAnim'Camera_FX.Gameplay.C_Impact_CharacterGib_Near'
}