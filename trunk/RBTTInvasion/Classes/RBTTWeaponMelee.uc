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

simulated function SetupArmsAnim(); // Arms animations..

 /**
 * Attach Weapon Mesh, Weapon MuzzleFlash and Muzzle Flash Dynamic Light to a SkeletalMesh
 *
 * @param	who is the pawn to attach to
 */
simulated function AttachWeaponTo( SkeletalMeshComponent MeshCpnt, optional Name SocketName ); // Melee weapon doesn't want to be attached!

defaultproperties
{
   MinDamage=15.000000
   MinForce=20000.000000
   AutoFireRange=110.000000
   ChargeEffect(0)=ParticleSystem'WP_ImpactHammer.Particles.P_WP_ImpactHammer_Charge_Primary'
   ChargeEffect(1)=ParticleSystem'WP_ImpactHammer.Particles.P_WP_Impact_Charge_Secondary'
   ImpactKillCameraAnim=CameraAnim'Camera_FX.Gameplay.C_Impact_CharacterGib_Near'
   bExportMenuData=False
   bMuzzleFlashPSCLoops=True
   bFastRepeater=True
   ShotCost(0)=0
   ShotCost(1)=0
   FireCameraAnim(0)=CameraAnim'Camera_FX.ImpactHammer.C_WP_ImpactHammer_Primary_Fire_Shake'
   FireCameraAnim(1)=CameraAnim'Camera_FX.ImpactHammer.C_WP_ImpactHammer_Alt_Fire_Shake'
   InventoryGroup=1
   GroupWeight=0.700000
   WeaponFireAnim(2)="WeaponFire"
   WeaponFireAnim(3)="WeaponFire"
   ArmFireAnim(2)="WeaponFire"
   ArmFireAnim(3)="WeaponFire"
   MuzzleFlashPSCTemplate=ParticleSystem'WP_ImpactHammer.Particles.P_WP_ImpactHammer_Primary_Hit'
   MuzzleFlashAltPSCTemplate=ParticleSystem'WP_ImpactHammer.Particles.P_WP_ImpactHammer_Secondary_Hit'
   CurrentRating=0.450000
   FireInterval(0)=0.500000
   Spread(2)=0.000000
   InstantHitDamage(0)=10.000000
   InstantHitDamageTypes(0)=Class'RBTTInvasion.MeleeDamage'
   InstantHitDamageTypes(1)=None
   InstantHitDamageTypes(2)=None
   InstantHitDamageTypes(3)=None
   FireOffset=(X=20.000000,Y=0.000000,Z=0.000000)
   bCanThrow=False
   bInstantHit=True
   bMeleeWeapon=True
   WeaponRange=110.000000
   Begin Object Class=UTSkeletalMeshComponent Name=FirstPersonMesh ObjName=FirstPersonMesh Archetype=UTSkeletalMeshComponent'UTGame.Default__UTWeapon:FirstPersonMesh'
      ObjectArchetype=UTSkeletalMeshComponent'UTGame.Default__UTWeapon:FirstPersonMesh'
   End Object
   Mesh=FirstPersonMesh
   AIRating=0.350000
   Begin Object Class=SkeletalMeshComponent Name=PickupMesh ObjName=PickupMesh Archetype=SkeletalMeshComponent'UTGame.Default__UTWeapon:PickupMesh'
      ObjectArchetype=SkeletalMeshComponent'UTGame.Default__UTWeapon:PickupMesh'
   End Object
   DroppedPickupMesh=PickupMesh
   PickupFactoryMesh=PickupMesh
   Name="Default__RBTTWeaponMelee"
   ObjectArchetype=UTWeapon'UTGame.Default__UTWeapon'
}
