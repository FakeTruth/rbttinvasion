class RBTTWeaponMelee extends UTWeapon;

var float MinDamage;
var float MaxDamage;
var float MinForce;
var float MaxForce;
var float MinSelfDamage;
var float SelfForceScale;
var float SelfDamageScale;

/** This holds when the hammer began charging */
var float ChargeTime;

/** The charging animations*/
var name ChargeAnim;
var name ChargeIdleAnim;

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
	return 1.0000;
}

simulated function SetSkin(Material NewMaterial)
{
	super.SetSkin(NewMaterial);
	BloodMIC = Mesh.CreateAndSetMaterialInstanceConstant(0);
}

function float GetAIRating()
{
	return 9.f;
}

function byte BestMode()
{
	return 0;
}

/**
 * return false if out of range, cant see target, etc.
 */
function bool CanAttack(Actor Other)
{
	return true;
}

function float SuggestAttackStyle()
{
	return 1.0;
}

simulated function bool HasAnyAmmo()
{
	return true;
}

/**  figure out how close P is to aiming at the center of Target
	@return the cosine of the angle of Ps aim
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

simulated function ProcessInstantHit( byte FiringMode, ImpactInfo Impact )
{
	local UTPawn P;
	local UTVehicle_Hoverboard H;
	local class<UTEmitCameraEffect> CameraEffect;
	local class<UTDamageType> UTDT;
	local UTPlayerController PC;

	if (Role == Role_Authority )
	{
		if ( Impact.HitActor != None && Instigator != None && Instigator.Health > 0 )
		{
			// if we hit something on the server, then deal damage to it.
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
			
			if (P != None && P != Instigator)
			{				
				P.TakeDamage(MinDamage, Instigator.Controller, Impact.HitLocation, MinForce * Impact.RayDir, InstantHitDamageTypes[0], Impact.HitInfo, self);
				
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

// not needed, so clear it!
event ImpactAutoFire(){ LogInternal(">>> ImpactAutoFire() <<<"); }
simulated function ImpactFire(){ LogInternal(">>> ImpactFire() <<<"); }
reliable client function ClientAutoFire(){ LogInternal(">>> ClientAutoFire() <<<"); }

simulated function FireAmmunition()
{
	LogInternal(">>>FireAmmunition()<<<");
	
	// Use ammunition to fire
	ConsumeAmmo( CurrentFireMode );

	// if this is the local player, play the firing effects
	PlayFiringSound();

	// It's an InstantFire weapon, so fire instantly! wut!
	InstantFire();

	if( ( Instigator != None)
		&& ( AIController(Instigator.Controller) != None )
		)
	{
		AIController(Instigator.Controller).NotifyWeaponFired(self,CurrentFireMode);
	}
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
	local vector StartTrace, EndTrace;
	local Array<ImpactInfo>	ImpactList;
	local ImpactInfo RealImpact, NearImpact;
	local int i, FinalImpactIndex;

	LogInternal(">>>>>>>>>>InstantFire()<<<<<<<<<");
	
	// define range to use for CalcWeaponFire()
	StartTrace = InstantFireStartTrace();
	EndTrace = InstantFireEndTrace(StartTrace);
	bUsingAimingHelp = false;
	// Perform shot
	RealImpact = CalcWeaponFire(StartTrace, EndTrace, ImpactList);
	FinalImpactIndex = ImpactList.length - 1;

	if (FinalImpactIndex >= 0 && (ImpactList[FinalImpactIndex].HitActor == None || !ImpactList[FinalImpactIndex].HitActor.bProjTarget))
	{
		// console aiming help
		NearImpact = InstantAimHelp(StartTrace, EndTrace, RealImpact);
		if ( NearImpact.HitActor != None )
		{
			bUsingAimingHelp = true;
			ImpactList[FinalImpactIndex] = NearImpact;
		}
	}

	for (i = 0; i < ImpactList.length; i++)
	{
		ProcessInstantHit(CurrentFireMode, ImpactList[i]);
	}

	if (Role == ROLE_Authority)
	{
		// Set flash location to trigger client side effects.
		// if HitActor == None, then HitLocation represents the end of the trace (maxrange)
		// Remote clients perform another trace to retrieve the remaining Hit Information (HitActor, HitNormal, HitInfo...)
		// Here, The final impact is replicated. More complex bullet physics (bounce, penetration...)
		// would probably have to run a full simulation on remote clients.
		if ( NearImpact.HitActor != None )
		{
			SetFlashLocation(NearImpact.HitLocation);
		}
		else
		{
			SetFlashLocation(RealImpact.HitLocation);
		}
	}
}

simulated function StopFireEffects(byte FireModeNum);

defaultproperties
{
	Begin Object class=AnimNodeSequence Name=MeshSequenceA
	End Object

	Begin Object Name=FirstPersonMesh
	End Object
	//AttachmentClass=class'UTGame.UTAttachment_ImpactHammer'

	Components.Remove(PickupMesh)

	WeaponChargeSnd=SoundCue'A_Weapon_ImpactHammer.ImpactHammer.A_Weapon_ImpactHammer_FireLoop_Cue'
	WeaponEMPChargeSnd=SoundCue'A_Weapon_ImpactHammer.ImpactHammer.A_Weapon_ImpactHammer_AltFireLoop_Cue'
	WeaponFireSnd[0]=SoundCue'A_Weapon_ImpactHammer.ImpactHammer.A_Weapon_ImpactHammer_AltFire_Cue'
	WeaponFireSnd[1]=SoundCue'A_Weapon_ImpactHammer.ImpactHammer.A_Weapon_ImpactHammer_AltImpact_Cue'
	WeaponPutDownSnd=SoundCue'A_Weapon_ImpactHammer.ImpactHammer.A_Weapon_ImpactHammer_Lower_Cue'
	WeaponEquipSnd=SoundCue'A_Weapon_ImpactHammer.ImpactHammer.A_Weapon_ImpactHammer_Raise_Cue'

	WeaponFireTypes(0)=EWFT_InstantHit
	Spread(2)=0.0

	WeaponRange=110.0
	AutoFireRange=110.0

	FireInterval[0]=0.5

	FireOffset=(X=20)

	InstantHitDamageTypes(0)=class'UTDmgType_ImpactHammer'
	InstantHitDamage(0)=10
	InstantHitDamageTypes(1)=none
	InstantHitDamageTypes(2)=none
	InstantHitDamageTypes(3)=none

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
	ShotCost(1)=0

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

	MinDamage=20.0
	MinForce=20000.0

	ImpactKillCameraAnim=CameraAnim'Camera_FX.Gameplay.C_Impact_CharacterGib_Near'
}

