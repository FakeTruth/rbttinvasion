class RBTTInfernal extends RBTTMonster
	config(RBTTInvasion);

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

var config float PlasmaDamage;
var config float PoundDamage;
var bool bInitializedExtraAnimSets;

/** Particle Emitters */
var ParticleSystemComponent InfernalEmitters[11];

var array<name> DeResBoneNames;


simulated function PostBeginPlay()
{
	local ParticleSystem GroundPoundTemplate;
	local AnimTree	AnimTreeRootNode;
	local int i, j;
	
	super.PostBeginPlay();
	
	Mesh.AnimSets[Mesh.AnimSets.Length] = GetFamilyInfo().default.HeroMeleeAnimSet;
	
	HeroMeleeEmitterClass = class'UTEmit_HeroMelee';
	GroundPoundTemplate = HeroGroundPoundTemplate;
	

	
	if (WorldInfo.NetMode != NM_DedicatedServer)
	{
		if ( HeroGroundPoundEmitter == None || GroundPoundTemplate != HeroGroundPoundEmitter.Template )
		{
			LogInternal(">> CREATING EMITTER IN POSTBEGINPLAY <<");
			HeroGroundPoundEmitter = new(self) class'UTParticleSystemComponent';
			HeroGroundPoundEmitter.SetTemplate(GroundPoundTemplate);
			HeroGroundPoundEmitter.bAutoActivate = false;
			Mesh.AttachComponentToSocket(HeroGroundPoundEmitter, WeaponSocket);
		}
	
		InfernalEmitters[0] = new(self) class'UTParticleSystemComponent';
		Mesh.AttachComponent(InfernalEmitters[0], 'b_Hips');
		InfernalEmitters[0].SetTemplate(ParticleSystem'RBTTInfernal.InfernalAmbient');
	
		AttachFireEmitterTo(InfernalEmitters[1], 'b_RightForeArm');
		AttachFireEmitterTo(InfernalEmitters[2], 'b_LeftForeArm');
		AttachFireEmitterTo(InfernalEmitters[3], 'b_Neck');
		AttachFireEmitterTo(InfernalEmitters[4], 'b_RightHand');
		AttachFireEmitterTo(InfernalEmitters[5], 'b_LeftHand');
		AttachFireEmitterTo(InfernalEmitters[6], 'b_Spine');
		AttachFireEmitterTo(InfernalEmitters[7], 'b_Spine1');
		AttachFireEmitterTo(InfernalEmitters[8], 'b_Spine2');
		AttachFireEmitterTo(InfernalEmitters[9], 'b_RightLeg');
		AttachFireEmitterTo(InfernalEmitters[10], 'b_LeftLeg');
	}
	
	// Slow down infernal's movement animations
	AnimTreeRootNode = AnimTree(Mesh.Animations);
	if( AnimTreeRootNode != None )
	{
		for(i=0; i<AnimTreeRootNode.AnimGroups.Length; i++)
		{
			for ( j=0; j<AnimTreeRootNode.AnimGroups[i].SeqNodes.Length; j++ )
			{
				AnimTreeRootNode.AnimGroups[i].SeqNodes[j].Rate *= 0.3;
			}
		}
	}
	
	SaveConfig();
}

simulated function AttachFireEmitterTo(out ParticleSystemComponent ParticleSystem, name BoneName)
{
	ParticleSystem = new(self) class'UTParticleSystemComponent';
	Mesh.AttachComponent(ParticleSystem, BoneName);
	ParticleSystem.SetTemplate(ParticleSystem'RBTTInfernal.InfernalFire');
}

function bool Died(Controller Killer, class<DamageType> damageType, vector HitLocation)
{	
	ClearTimer('CauseMeleeDamage');
	return Super.Died(Killer, damageType, HitLocation);
	SetTimer(2, False, 'Destroy');
}

simulated function PlayDying(class<DamageType> DamageType, vector HitLoc)
{
	local MaterialInstanceTimeVarying MITV_BurnOut;
	local int i;
	
	
	super.PlayDying(DamageType, HitLoc);
	
	if (WorldInfo.NetMode != NM_DedicatedServer)
	{
		MITV_BurnOut = new(Mesh.outer) class'MaterialInstanceTimeVarying';
		MITV_BurnOut.SetParent( GetFamilyInfo().default.SkeletonBurnOutMaterials[0] );
		// this can have a max of 6 before it wraps and become visible again
		Mesh.SetMaterial( 0, MITV_BurnOut );
		Mesh.SetMaterial( 1, MITV_BurnOut );
		Mesh.SetMaterial( 2, MITV_BurnOut );
		//MITV_BurnOut.SetScalarStartTime( 'BurnAmount', 1.0f );	
		MITV_BurnOut.SetScalarStartTime( 'BurnAmount', 0 );	

		//Class'UTDamageType'.static.CreateDeathSkeleton(self, None, HitInfo, Location);
		
		for(i = ArrayCount(InfernalEmitters)-1; i>=0; i--)
		{	// Deactivate all the emitters on the Infernal
			InfernalEmitters[i].DeactivateSystem();
		}
	}
	
	for(i = DeResBoneNames.length-1; i >= 0; i--)
	{
		WorldInfo.MyEmitterPool.SpawnEmitter( ParticleSystem'WP_LinkGun.Effects.P_WP_Linkgun_Skeleton_Dissolve', Mesh.GetBoneLocation( DeResBoneNames[i] ), Rotator(vect(0,0,1)), self );
		//WorldInfo.MyEmitterPool.SpawnEmitter( ParticleSystem'RBTTInfernal.DeRez_Emitter', Mesh.GetBoneLocation( DeResBoneNames[i] ), Rotator(vect(0,0,1)), self );
	}
	
	SetTimer(2, False, 'Destroy');
}

simulated function Projectile ProjectileFire()
{
	local vector		RealStartLoc;
	local Projectile	SpawnedProjectile;

	if(bInHeroMelee)
		return none;
	
	// tell remote clients that we fired, to trigger effects
	Weapon.IncrementFlashCount();

	//FullBodyAnimSlot.PlayCustomAnim('hoverboardjumpland', 1, 0.2, 0.2, FALSE, TRUE); // The animation for shooting plasma
	PlayEmote('ThrowPlasma', -1);
	
	if( Role == ROLE_Authority )
	{
		// this is the location where the projectile is spawned.
		RealStartLoc = Weapon.GetPhysicalFireStartLoc();

		// Spawn projectile
		SpawnedProjectile = Spawn(Class'RBTTInfernalPlasma',,, RealStartLoc);
		if( SpawnedProjectile != None && !SpawnedProjectile.bDeleteMe )
		{
			SpawnedProjectile.Damage = PlasmaDamage;
			SpawnedProjectile.Init( Vector(Weapon.GetAdjustedAim( RealStartLoc )) );
			UTProj_SeekingRocket(SpawnedProjectile).Seeking = Controller.Enemy;
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
	PlaySound(SoundCue'A_Gameplay_UT3G.Titan.A_Gameplay_UT3G_Titan_TitanMelee01_Cue');
	HeroGroundPoundEmitter.ActivateSystem();
	bInHeroMelee = true;
	PlayEmote('MeleeA', -1);
	AccelRate = 0;
	SetTimer(2.0, false, 'StopMeleeAttack');
	SetTimer(0.84, false, 'CauseMeleeDamage');

	//HeroGroundPoundEmitter.SetActive(true);
	//HeroGroundPoundEmitter.SetHidden(false);
}

/** Play an emote given a category and index within that category. */
simulated function DoPlayEmote(name InEmoteTag, int InPlayerID)
{
	if(WorldInfo.NetMode != NM_DedicatedServer)
	{
		if(!bInitializedExtraAnimSets)
		{
			bInitializedExtraAnimSets = True;
			Mesh.AnimSets[Mesh.AnimSets.Length] = GetFamilyInfo().default.HeroMeleeAnimSet;
		}
	}

	Super.DoPlayEmote(InEmoteTag, InPlayerID);
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

event TakeDamage(int Damage, Controller EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
{
	Momentum = vect(0,0,0); // Infernals are way to heavy to get pushed around

	if( IsValidTargetFor( EventInstigator ) )
	{
		RBTTMonsterController(Controller).Squad.SetEnemy(UTBot(Controller), EventInstigator.Pawn);
		Controller.Enemy = EventInstigator.Pawn;
	}
	
	super.TakeDamage(Damage, EventInstigator, HitLocation, Momentum, DamageType, HitInfo);
}



// Infernal shouldn't gib, it's too collosal
/** @return whether or not we should gib due to damage from the passed in damagetype */
simulated function bool ShouldGib(class<UTDamageType> UTDamageType)
{
	return FALSE;
}

defaultproperties
{
   HeroGroundPoundTemplate=ParticleSystem'UN_HeroEffects.Effects.FX_GroundPoundHands'
   MeleeSound=SoundCue'A_Titan_Extras.SoundCues.A_Vehicle_Goliath_Collide'
   MeleeRadius=900.000000
   FootStepShake=CameraAnim'Camera_FX.DarkWalker.C_VH_DarkWalker_Step_Shake'
   FootStepShakeRadius=1000.000000
   FootSound=SoundCue'A_Titan_Extras.Cue.A_Vehicle_DarkWalker_FootstepCue'
   MeleeDmgClass=Class'UTGame.UTDmgType_HeroMelee'
   PlasmaDamage=50.000000
   PoundDamage=50.000000
   DeResBoneNames(0)="b_RightForeArm"
   DeResBoneNames(1)="b_LeftForeArm"
   DeResBoneNames(2)="b_Neck"
   DeResBoneNames(3)="b_RightHand"
   DeResBoneNames(4)="b_LeftHand"
   DeResBoneNames(5)="b_Spine1"
   DeResBoneNames(6)="b_RightLeg"
   DeResBoneNames(7)="b_LeftLeg"
   MonsterName="Infernal"
   bEmptyHanded=True
   Begin Object Class=DynamicLightEnvironmentComponent Name=MyLightEnvironment ObjName=MyLightEnvironment Archetype=DynamicLightEnvironmentComponent'RBTTInvasion.Default__RBTTMonster:MyLightEnvironment'
      ObjectArchetype=DynamicLightEnvironmentComponent'RBTTInvasion.Default__RBTTMonster:MyLightEnvironment'
   End Object
   LightEnvironment=MyLightEnvironment
   Begin Object Class=ParticleSystemComponent Name=GooDeath ObjName=GooDeath Archetype=ParticleSystemComponent'RBTTInvasion.Default__RBTTMonster:GooDeath'
      ObjectArchetype=ParticleSystemComponent'RBTTInvasion.Default__RBTTMonster:GooDeath'
   End Object
   BioBurnAway=GooDeath
   Begin Object Class=DynamicLightEnvironmentComponent Name=DeathVisionLightEnv ObjName=DeathVisionLightEnv Archetype=DynamicLightEnvironmentComponent'RBTTInvasion.Default__RBTTMonster:DeathVisionLightEnv'
      ObjectArchetype=DynamicLightEnvironmentComponent'RBTTInvasion.Default__RBTTMonster:DeathVisionLightEnv'
   End Object
   FirstPersonDeathVisionLightEnvironment=DeathVisionLightEnv
   Begin Object Class=UTSkeletalMeshComponent Name=FirstPersonArms ObjName=FirstPersonArms Archetype=UTSkeletalMeshComponent'RBTTInvasion.Default__RBTTMonster:FirstPersonArms'
      Begin Object Class=AnimNodeSequence Name=MeshSequenceA ObjName=MeshSequenceA Archetype=AnimNodeSequence'RBTTInvasion.Default__RBTTMonster:FirstPersonArms.MeshSequenceA'
         ObjectArchetype=AnimNodeSequence'RBTTInvasion.Default__RBTTMonster:FirstPersonArms.MeshSequenceA'
      End Object
      Animations=AnimNodeSequence'RBTTInvasion.Default__RBTTInfernal:FirstPersonArms.MeshSequenceA'
      ObjectArchetype=UTSkeletalMeshComponent'RBTTInvasion.Default__RBTTMonster:FirstPersonArms'
   End Object
   ArmsMesh(0)=FirstPersonArms
   Begin Object Class=UTSkeletalMeshComponent Name=FirstPersonArms2 ObjName=FirstPersonArms2 Archetype=UTSkeletalMeshComponent'RBTTInvasion.Default__RBTTMonster:FirstPersonArms2'
      Begin Object Class=AnimNodeSequence Name=MeshSequenceB ObjName=MeshSequenceB Archetype=AnimNodeSequence'RBTTInvasion.Default__RBTTMonster:FirstPersonArms2.MeshSequenceB'
         ObjectArchetype=AnimNodeSequence'RBTTInvasion.Default__RBTTMonster:FirstPersonArms2.MeshSequenceB'
      End Object
      Animations=AnimNodeSequence'RBTTInvasion.Default__RBTTInfernal:FirstPersonArms2.MeshSequenceB'
      ObjectArchetype=UTSkeletalMeshComponent'RBTTInvasion.Default__RBTTMonster:FirstPersonArms2'
   End Object
   ArmsMesh(1)=FirstPersonArms2
   Begin Object Class=UTAmbientSoundComponent Name=AmbientSoundComponent ObjName=AmbientSoundComponent Archetype=UTAmbientSoundComponent'RBTTInvasion.Default__RBTTMonster:AmbientSoundComponent'
      ObjectArchetype=UTAmbientSoundComponent'RBTTInvasion.Default__RBTTMonster:AmbientSoundComponent'
   End Object
   PawnAmbientSound=AmbientSoundComponent
   Begin Object Class=UTAmbientSoundComponent Name=AmbientSoundComponent2 ObjName=AmbientSoundComponent2 Archetype=UTAmbientSoundComponent'RBTTInvasion.Default__RBTTMonster:AmbientSoundComponent2'
      ObjectArchetype=UTAmbientSoundComponent'RBTTInvasion.Default__RBTTMonster:AmbientSoundComponent2'
   End Object
   WeaponAmbientSound=AmbientSoundComponent2
   Begin Object Class=SkeletalMeshComponent Name=OverlayMeshComponent0 ObjName=OverlayMeshComponent0 Archetype=SkeletalMeshComponent'RBTTInvasion.Default__RBTTMonster:OverlayMeshComponent0'
      ObjectArchetype=SkeletalMeshComponent'RBTTInvasion.Default__RBTTMonster:OverlayMeshComponent0'
   End Object
   OverlayMesh=OverlayMeshComponent0
   Begin Object Class=DynamicLightEnvironmentComponent Name=XRayEffectLightEnv ObjName=XRayEffectLightEnv Archetype=DynamicLightEnvironmentComponent'RBTTInvasion.Default__RBTTMonster:XRayEffectLightEnv'
      ObjectArchetype=DynamicLightEnvironmentComponent'RBTTInvasion.Default__RBTTMonster:XRayEffectLightEnv'
   End Object
   XRayEffectLightEnvironment=XRayEffectLightEnv
   LeftFootControlName="LeftFrontFootControl"
   RightFootControlName="RightFrontFootControl"
   DefaultFamily=Class'RBTTInvasion.RBTTInfernalFamilyInfo'
   DefaultMesh=None
   DefaultRadius=85.000000
   DefaultHeight=171.000000
   WalkableFloorZ=0.800000
   Health=1000
   ControllerClass=Class'RBTTInvasion.RBTTMonsterControllerNoWeapon'
   Begin Object Class=SkeletalMeshComponent Name=WPawnSkeletalMeshComponent ObjName=WPawnSkeletalMeshComponent Archetype=SkeletalMeshComponent'UTGame.Default__UTPawn:WPawnSkeletalMeshComponent'
      PhysicsAsset=PhysicsAsset'CH_Skeletons.Mesh.SK_CH_Skeleton_Human_Male_Physics'
      AnimSets(0)=AnimSet'CH_AnimHuman.Anims.K_AnimHuman_BaseMale'
      Scale3D=(X=4.000000,Y=4.000000,Z=4.000000)
      ObjectArchetype=SkeletalMeshComponent'UTGame.Default__UTPawn:WPawnSkeletalMeshComponent'
   End Object
   Mesh=WPawnSkeletalMeshComponent
   Begin Object Class=CylinderComponent Name=CollisionCylinder ObjName=CollisionCylinder Archetype=CylinderComponent'UTGame.Default__UTPawn:CollisionCylinder'
      CollisionHeight=171.000000
      CollisionRadius=85.000000
      ObjectArchetype=CylinderComponent'UTGame.Default__UTPawn:CollisionCylinder'
   End Object
   CylinderComponent=CollisionCylinder
   Components(0)=CollisionCylinder
   Begin Object Class=ArrowComponent Name=Arrow ObjName=Arrow Archetype=ArrowComponent'UTGame.Default__UTPawn:Arrow'
      ObjectArchetype=ArrowComponent'UTGame.Default__UTPawn:Arrow'
   End Object
   Components(1)=Arrow
   Components(2)=MyLightEnvironment
   Components(3)=WPawnSkeletalMeshComponent
   Components(4)=AmbientSoundComponent
   Components(5)=AmbientSoundComponent2
   Components(6)=MyLightEnvironment
   Components(7)=None
   Components(8)=CollisionCylinder
   CollisionComponent=CollisionCylinder
   Name="Default__RBTTInfernal"
}
