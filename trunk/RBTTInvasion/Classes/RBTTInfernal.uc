class RBTTInfernal extends RBTTMonster;

var() skeletalMeshComponent DefaultMonsterMesh;
var() class<UTWeapon> DefaultMonsterWeapon;


var() int monsterTeam;
var() int MonsterScale;

var ParticleSystemComponent HeroGroundPoundEmitter;
var class<UTReplicatedEmitter> HeroMeleeEmitterClass;
var ParticleSystem HeroGroundPoundTemplate;
var bool bInHeroMelee;
var SoundCue MeleeSound;
var float MeleeRadius;

/** camera anim played when foot lands nearby */
var CameraAnim FootStepShake;
var float FootStepShakeRadius;
var soundcue footsound;

/** Melee attack properties */
var class <DamageType> MeleeDmgClass;

var float PoundDamage;


//var AnimNodeSlot FullBodyAnimSlot;

simulated function PostBeginPlay()
{
	local ParticleSystem GroundPoundTemplate;

	super.PostBeginPlay();
	
	Mesh.AnimSets[Mesh.AnimSets.Length] = AnimSet'CH_AnimHuman_Hero.Anims.K_AnimHuman_Hero';
	
	HeroMeleeEmitterClass = class'UTEmit_HeroMelee';
	GroundPoundTemplate = HeroGroundPoundTemplate;
	
	if ( HeroGroundPoundEmitter == None || GroundPoundTemplate != HeroGroundPoundEmitter.Template )
	{
		`log(">> CREATING EMITTER IN POSTBEGINPLAY <<");
		HeroGroundPoundEmitter = new(self) class'UTParticleSystemComponent';
		HeroGroundPoundEmitter.SetTemplate(GroundPoundTemplate);
		HeroGroundPoundEmitter.bAutoActivate = false;
		Mesh.AttachComponentToSocket(HeroGroundPoundEmitter, WeaponSocket);
	}
}


simulated function EmoteTimer()
{
	//local float AnimLength;
	//`log(">>Doing animation! << FullBodyAnimSlot:"@FullBodyAnimSlot);
	//AnimLength = FullBodyAnimSlot.PlayCustomAnim(Class'UTGame.UTFamilyInfo'.default.FamilyEmotes[0].EmoteAnim, 1.0, 0.2, 0.2, FALSE, TRUE);
	//AnimLength = FullBodyAnimSlot.PlayCustomAnim('Taunt_FB_Victory', 1.0, 0.2, 0.2, FALSE, TRUE);
	//`log(">>AnimLength is :"@AnimLength);
	//PlayEmote('TauntA', 0);
}

simulated function Projectile ProjectileFire()
{
	local vector		RealStartLoc;
	local Projectile	SpawnedProjectile;

	if(bInHeroMelee)
		return none;
	
	// tell remote clients that we fired, to trigger effects
	Weapon.IncrementFlashCount();

	if( Role == ROLE_Authority )
	{
		// this is the location where the projectile is spawned.
		RealStartLoc = Weapon.GetPhysicalFireStartLoc();

		// Spawn projectile
		SpawnedProjectile = Spawn(Class'RBTTInfernalPlasma',,, RealStartLoc);
		if( SpawnedProjectile != None && !SpawnedProjectile.bDeleteMe )
		{
			SpawnedProjectile.Init( Vector(Weapon.GetAdjustedAim( RealStartLoc )) );
		}

		// Return it up the line
		return SpawnedProjectile;
	}

	return None;
}

simulated function InstantFire()
{
	if(bInHeroMelee)
		return;
	
	DoPound();

	super.InstantFire();
}

simulated function DoPound()
{
	FullBodyAnimSlot.PlayCustomAnim('GroundPound_A', 1.0, 0.2, 0.2, FALSE, TRUE);
	TopHalfAnimSlot.PlayCustomAnim('GroundPound_A', 1.0, 0.2, 0.2, FALSE, TRUE);
	PlaySound(SoundCue'A_Gameplay_UT3G.Titan.A_Gameplay_UT3G_Titan_TitanMelee01_Cue');
	HeroGroundPoundEmitter.ActivateSystem();
	bInHeroMelee = true;
	//PlayEmote('MeleeA', -1);
	AccelRate = 0;
	SetTimer(2.0, false, 'StopMeleeAttack');
	SetTimer(0.84, false, 'CauseMeleeDamage');

	HeroGroundPoundEmitter.SetActive(true);
	HeroGroundPoundEmitter.SetHidden(false);
}

simulated function StopMeleeAttack()
{
	if ( !WorldInfo.GRI.bMatchIsOver )
	{
		AccelRate = default.AccelRate;
		bInHeroMelee = false;
		//bInHeroMelee = false;
		//bClientInHeroMelee = false;
		//if ( Weapon != None )
		//{
			//if ( PendingHeroFire[0] == 1 )
			//{
			//	Weapon.StartFire(0);
			//}
			//else if ( PendingHeroFire[1] == 1 )
			//{
			//	Weapon.StartFire(1);
			//}
		//}

		if (HeroGroundPoundEmitter != None)
		{
			HeroGroundPoundEmitter.DeactivateSystem();
		}
	}
}

function CauseMeleeDamage()
{
	local Actor HitActor;
	local Pawn HitPawn;
	local InterpActor HitIA;
	local vector HornImpulse, MeleeLocation;
	local Pawn BoardPawn;
	local UTVehicle_Scavenger UTScav;
	local UTPawn OldDriver;
	local UTVehicle UTV;
	local float pct, Dist;
	local UTPlayerController PC;

	local bool bValidOtherTeamPawn, bValidInterpActor;

	// FIXMESTEVE only if ground underneath Titan
	PlaySound(MeleeSound, false, true,,, true);

	Spawn(HeroMeleeEmitterClass,,,Location+Vect(0,0,-128));

	foreach WorldInfo.AllControllers(class'UTPlayerController', PC)
	{
		Dist = (PC == Controller) ? MeleeRadius : VSize(Location - PC.ViewTarget.Location);
		if (Dist < 2.0 * MeleeRadius)
		{
			PC.ClientPlayCameraAnim(FootStepShake, 1.0 - (Dist/(2.0 * MeleeRadius)));
		}
	}

	// kill close by players
	// knock down further away players
	MeleeLocation = Location + vect(0,0,1) * GetCollisionHeight();

	ForEach OverlappingActors(class 'Actor', HitActor, MeleeRadius, Location)
	{
		HitPawn = Pawn(HitActor);
		if ( HitPawn != None )
		{
			bValidOtherTeamPawn = HitPawn != self && HitPawn.Mesh != None && !WorldInfo.GRI.OnSameTeam(HitPawn, self);
			bValidOtherTeamPawn = bValidOtherTeamPawn && (FastTrace(MeleeLocation, HitPawn.Location) || FastTrace(MeleeLocation, HitPawn.Location + vect(0,0,1)*HitPawn.GetCollisionHeight()));
		}
		else
		{
			HitIA = InterpActor(HitActor);
			bValidInterpActor = HitIA != None && HitIA.StaticMeshComponent != None;
			bValidOtherTeamPawn = false;
		}	

		if ( HitPawn != self && ( bValidInterpActor || bValidOtherTeamPawn ) )// && ((Normal(HitActor.Location - Location) dot LookDir) > 0.7))
		{
			// throw him outwards also
			HornImpulse = HitActor.Location - Location;
			pct = (MeleeRadius - VSize(HornImpulse))/MeleeRadius;
			HornImpulse.Z = 0;
			HornImpulse = 1000.0 * Normal(HornImpulse);
			HornImpulse.Z = 400.0;

			if ( !bValidOtherTeamPawn || FastTrace(MeleeLocation, HitPawn.Location) || FastTrace(MeleeLocation, HitPawn.Location + vect(0,0,1)*HitPawn.GetCollisionHeight()) )
			{
				HitActor.TakeDamage(PoundDamage*pct, Controller, HitActor.Location, HornImpulse*FMax(0.5, pct), MeleeDmgClass);
			}

			//Throw the pawns around
			if (bValidOtherTeamPawn)
			{
				if (HitPawn.Physics != PHYS_RigidBody && HitPawn.IsA('UTPawn'))
				{
					HitPawn.Velocity += HornImpulse;
					UTPawn(HitPawn).ForceRagdoll();
					UTPawn(HitPawn).FeignDeathStartTime = WorldInfo.TimeSeconds + 1.5;
					HitPawn.LastHitBy = Controller;
				}
				else if( UTVehicle_Hoverboard(HitPawn) != none)
				{
					HitPawn.Velocity += HornImpulse;
					BoardPawn = UTVehicle_Hoverboard(HitPawn).Driver; // just in case the board gets destroyed from the ragdoll
					UTVehicle_Hoverboard(HitPawn).RagdollDriver();
					HitPawn = BoardPawn;
					HitPawn.LastHitBy = Controller;
				}
				else if ( HitPawn.Physics == PHYS_RigidBody )
				{
					UTV = UTVehicle(HitPawn);
					if(UTV != none)
					{
						// Special case for scavenger - force into ball mode for a bit.
						UTScav = UTVehicle_Scavenger(UTV);
						if(UTScav != None && UTScav.bDriving)
						{
							UTScav.BallStatus.bIsInBallMode = TRUE;
							UTScav.BallStatus.bBoostOnTransition = FALSE;
							UTScav.NextBallTransitionTime = WorldInfo.TimeSeconds + 2.0; // Stop player from putting legs out for 2 secs.
							UTScav.BallModeTransition();
						}
						// See if darkwalker forces this player out of vehicle.
						else if(UTV.bRagdollDriverOnDarkwalkerHorn)
						{
							OldDriver = UTPawn(UTV.Driver);
							if (OldDriver != None)
							{
								UTV.DriverLeave(true);
								OldDriver.Velocity += HornImpulse;
								OldDriver.ForceRagdoll();
								OldDriver.FeignDeathStartTime = WorldInfo.TimeSeconds + 1.5;
								OldDriver.LastHitBy = Controller;
							}
						}

						HitPawn.Mesh.AddImpulse(HornImpulse*5.3, Location);
					}
					else
					{
						HitPawn.Mesh.AddImpulse(HornImpulse, Location,, true);
					}
				}
			}
		}
	}
}

function bool Died(Controller Killer, class<DamageType> damageType, vector HitLocation)
{
	ClearTimer('CauseMeleeDamage');
	return Super.Died(Killer, damageType, HitLocation);
}

event Landed(vector HitNormal, actor FloorActor)
{
	Super.Landed(HitNormal, FloorActor);

	PlayFootStepSound(0);
}

simulated event PlayFootStepSound(int FootDown)
{
	local UTPlayerController PC;
	local float Dist;


	PlaySound(FootSound, false, true,,, true);

	foreach LocalPlayerControllers(class'UTPlayerController', PC)
	{
		if (PC == Controller)
		{
			Dist = 0.7*FootStepShakeRadius;
		}
		else
		{
			Dist = VSize(Location - PC.ViewTarget.Location);
		}
		if (Dist < FootStepShakeRadius)
		{
			PC.PlayCameraAnim(FootStepShake, 1.0 - (Dist/FootStepShakeRadius));
		}
	}
}

defaultproperties
{
	health = 500

	PoundDamage = 50.0

	FootStepShakeRadius=1000.0
	FootStepShake=CameraAnim'Camera_FX.DarkWalker.C_VH_DarkWalker_Step_Shake'
	FootSound=SoundCue'A_Titan_Extras.Cue.A_Vehicle_DarkWalker_FootstepCue'
	
	MeleeDmgClass=class'UTDmgType_HeroMelee'

	HeroGroundPoundTemplate=ParticleSystem'UN_HeroEffects.Effects.FX_GroundPoundHands'
	MeleeSound=SoundCue'A_Titan_Extras.SoundCues.A_Vehicle_Goliath_Collide'
	MeleeRadius=900.0
	
	bEmptyHanded = True
	bNeedWeapon = False
	bCanPickupInventory = False
	
	LeftFootControlName="LeftFrontFootControl"
 
	RightFootControlName="RightFrontFootControl"

	MonsterName = "Infernal"
   
	MonsterSkill=1

	LightEnvironment=MyLightEnvironment

	BioBurnAway=GooDeath

	ArmsMesh(0)=FirstPersonArms

	ArmsMesh(1)=FirstPersonArms2

	PawnAmbientSound=AmbientSoundComponent

	WeaponAmbientSound=AmbientSoundComponent2
   
   OverlayMesh=OverlayMeshComponent0
   
   DefaultFamily=Class'RBTTInfernalFamilyInfo'
   
   DefaultMesh=SkeletalMesh'RBTTInfernal.Infernal'
   
   WalkableFloorZ=0.800000
   
   ControllerClass=Class'RBTTMonsterControllerNoWeapon'
 
   Begin Object Name=WPawnSkeletalMeshComponent ObjName=WPawnSkeletalMeshComponent Archetype=SkeletalMeshComponent'UTGame.Default__UTPawn:WPawnSkeletalMeshComponent'
      Scale3D=(X=3,Y=3,Z=3)
      
      SkeletalMesh=SkeletalMesh'RBTTInfernal.Infernal'
      AnimTreeTemplate=AnimTree'CH_AnimHuman_Tree.AT_CH_Human'
      AnimSets(1)=AnimSet'CH_AnimHuman.Anims.K_AnimHuman_BaseMale'
      PhysicsAsset=PhysicsAsset'CH_Skeletons.Mesh.SK_CH_Skeleton_Human_Male_Physics'
      bHasPhysicsAssetInstance=True
      Name="WPawnSkeletalMeshComponent"
	  ObjectArchetype=SkeletalMeshComponent'UTGame.Default__UTPawn:WPawnSkeletalMeshComponent'
   End Object
   Mesh=WPawnSkeletalMeshComponent
   
   Begin Object Name=CollisionCylinder ObjName=CollisionCylinder Archetype=CylinderComponent'UTGame.Default__UTPawn:CollisionCylinder'
      CollisionHeight=128.000000
      CollisionRadius=64.000000
      ObjectArchetype=CylinderComponent'UTGame.Default__UTPawn:CollisionCylinder'
   End Object
   CylinderComponent=CollisionCylinder
   
   Components(0)=CollisionCylinder
   
   Begin Object Name=Arrow ObjName=Arrow Archetype=ArrowComponent'UTGame.Default__UTPawn:Arrow'
      ObjectArchetype=ArrowComponent'UTGame.Default__UTPawn:Arrow'
   End Object
   
   
   Components(1)=Arrow
   Components(2)=MyLightEnvironment
   Components(3)=WPawnSkeletalMeshComponent
   Components(4)=AmbientSoundComponent
   Components(5)=AmbientSoundComponent2
   Components(6)=MyLightEnvironment
   Components(8)=CollisionCylinder
   CollisionComponent=CollisionCylinder
   Name="RBTTInfernal"
   ObjectArchetype=UTPawn'UTGame.Default__UTPawn'
}
