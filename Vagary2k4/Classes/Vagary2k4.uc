class Vagary2k4 extends RBTTMonster
	config(RBTTInvasion);


/** Melee attack properties */
var class <DamageType> MeleeDmgClass;

var config float ProjectileDamage;
var bool bInitializedExtraAnimSets;

/** Particle Emitters */
var ParticleSystemComponent InfernalEmitters[11];

var array<name> DeResBoneNames;




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


		for(i = DeResBoneNames.length-1; i >= 0; i--)
		{
			WorldInfo.MyEmitterPool.SpawnEmitter( ParticleSystem'WP_BioRifle.Particles.P_WP_Bio_Alt_Blob_POP', Mesh.GetBoneLocation( DeResBoneNames[i] ), Rotator(vect(0,0,1)), self );           

		}
	}

	SetTimer(2, False, 'Destroy');
}

simulated function Projectile ProjectileFire()
{
	local vector		RealStartLoc;
	local Projectile	SpawnedProjectile;



	// tell remote clients that we fired, to trigger effects
	Weapon.IncrementFlashCount();

	// The animation for tossing projectile
	PlayEmote('ThrowPlasma', -1);
	
	if( Role == ROLE_Authority )
	{
		// this is the location where the projectile is spawned.
		RealStartLoc = Weapon.GetPhysicalFireStartLoc();

		// Spawn projectile
		SpawnedProjectile = Spawn(Class'VagaryProj',,, RealStartLoc);
		if( SpawnedProjectile != None && !SpawnedProjectile.bDeleteMe )
		{
			SpawnedProjectile.Damage = ProjectileDamage;
			SpawnedProjectile.Init( Vector(Weapon.GetAdjustedAim( RealStartLoc )) );
			UTProj_SeekingRocket(SpawnedProjectile).Seeking = Controller.Enemy;
		}
		
		
		
		// Return it up the line
		return SpawnedProjectile;
	}
	return None;
}




/** Play an emote given a category and index within that category. */
simulated function DoPlayEmote(name InEmoteTag, int InPlayerID)
{
	if(WorldInfo.NetMode != NM_DedicatedServer)
	{
		if(!bInitializedExtraAnimSets)
		{
			bInitializedExtraAnimSets = True;
			Mesh.AnimSets[Mesh.AnimSets.Length] = GetFamilyInfo().default.VagaryAnims;
		}
	}

	Super.DoPlayEmote(InEmoteTag, InPlayerID);
}


	}
}




// Infernal shouldn't gib, it's too collosal
/** @return whether or not we should gib due to damage from the passed in damagetype */
simulated function bool ShouldGib(class<UTDamageType> UTDamageType)
{
	return FALSE;
}

defaultproperties
{
	DeResBoneNames(0)=b_RightForeArm
	DeResBoneNames(1)=b_LeftForeArm
	DeResBoneNames(2)=b_Neck
	DeResBoneNames(3)=b_RightHand
	DeResBoneNames(4)=b_LeftHand
	DeResBoneNames(5)=b_Spine1
	DeResBoneNames(6)=b_RightLeg
	DeResBoneNames(7)=b_LeftLeg

	health = 1000

	PlasmaDamage = 50.0
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
      Scale3D=(X=4,Y=4,Z=4)
      
      SkeletalMesh=SkeletalMesh'RBTTInfernal.Infernal'
      AnimTreeTemplate=AnimTree'CH_AnimHuman_Tree.AT_CH_Human'
      AnimSets(0)=AnimSet'CH_AnimHuman.Anims.K_AnimHuman_BaseMale'
      PhysicsAsset=PhysicsAsset'CH_Skeletons.Mesh.SK_CH_Skeleton_Human_Male_Physics'
      bHasPhysicsAssetInstance=True
      Name="WPawnSkeletalMeshComponent"
	  ObjectArchetype=SkeletalMeshComponent'UTGame.Default__UTPawn:WPawnSkeletalMeshComponent'
   End Object
   Mesh=WPawnSkeletalMeshComponent
   
   DefaultRadius = 85.0000
   DefaultHeight = 171.0000
   
   Begin Object Name=CollisionCylinder ObjName=CollisionCylinder Archetype=CylinderComponent'UTGame.Default__UTPawn:CollisionCylinder'
      CollisionHeight=171.000000
      CollisionRadius=85.000000
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
