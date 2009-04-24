class RBTTKrallSkeleton extends RBTTMonster;

var() skeletalMeshComponent DefaultMonsterMesh;
var() class<UTWeapon> DefaultMonsterWeapon;

//var() int MonsterSkill;
var() int monsterTeam;
var() int MonsterScale;
//var() string MonsterName;


simulated function Projectile ProjectileFire()
{
	local vector		RealStartLoc;
	local Projectile	SpawnedProjectile;

	// tell remote clients that we fired, to trigger effects
	Weapon.IncrementFlashCount();

	if( Role == ROLE_Authority )
	{
		// this is the location where the projectile is spawned.
		RealStartLoc = Weapon.GetPhysicalFireStartLoc();

		// Spawn projectile
		SpawnedProjectile = Spawn(Class'UTGame.UTProj_Rocket',,, RealStartLoc);
		if( SpawnedProjectile != None && !SpawnedProjectile.bDeleteMe )
		{
			SpawnedProjectile.Init( Vector(Weapon.GetAdjustedAim( RealStartLoc )) );
		}

		// Return it up the line
		return SpawnedProjectile;
	}

	return None;
}

defaultproperties
{
   MonsterName="KrallSkeleton"
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
      Animations=AnimNodeSequence'RBTTInvasion.Default__RBTTKrallSkeleton:FirstPersonArms.MeshSequenceA'
      ObjectArchetype=UTSkeletalMeshComponent'RBTTInvasion.Default__RBTTMonster:FirstPersonArms'
   End Object
   ArmsMesh(0)=FirstPersonArms
   Begin Object Class=UTSkeletalMeshComponent Name=FirstPersonArms2 ObjName=FirstPersonArms2 Archetype=UTSkeletalMeshComponent'RBTTInvasion.Default__RBTTMonster:FirstPersonArms2'
      Begin Object Class=AnimNodeSequence Name=MeshSequenceB ObjName=MeshSequenceB Archetype=AnimNodeSequence'RBTTInvasion.Default__RBTTMonster:FirstPersonArms2.MeshSequenceB'
         ObjectArchetype=AnimNodeSequence'RBTTInvasion.Default__RBTTMonster:FirstPersonArms2.MeshSequenceB'
      End Object
      Animations=AnimNodeSequence'RBTTInvasion.Default__RBTTKrallSkeleton:FirstPersonArms2.MeshSequenceB'
      ObjectArchetype=UTSkeletalMeshComponent'RBTTInvasion.Default__RBTTMonster:FirstPersonArms2'
   End Object
   ArmsMesh(1)=FirstPersonArms2
   HeadBone="head"
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
   DefaultFamily=Class'RBTTInvasion.RBTTKrallSkeletonFamilyInfo'
   DefaultMesh=SkeletalMesh'CH_Skeletons.Mesh.SK_CH_Skeleton_Krall_Male'
   WalkableFloorZ=0.800000
   ControllerClass=Class'RBTTInvasion.RBTTMonsterControllerNoWeapon'
   Begin Object Class=SkeletalMeshComponent Name=WPawnSkeletalMeshComponent ObjName=WPawnSkeletalMeshComponent Archetype=SkeletalMeshComponent'UTGame.Default__UTPawn:WPawnSkeletalMeshComponent'
      SkeletalMesh=SkeletalMesh'CH_Skeletons.Mesh.SK_CH_Skeleton_Krall_Male'
      PhysicsAsset=PhysicsAsset'CH_AnimKrall.Mesh.SK_CH_AnimKrall_Male01_Physics'
      AnimSets(0)=AnimSet'CH_AnimKrall.Anims.K_AnimKrall_Base'
      ObjectArchetype=SkeletalMeshComponent'UTGame.Default__UTPawn:WPawnSkeletalMeshComponent'
   End Object
   Mesh=WPawnSkeletalMeshComponent
   Begin Object Class=CylinderComponent Name=CollisionCylinder ObjName=CollisionCylinder Archetype=CylinderComponent'UTGame.Default__UTPawn:CollisionCylinder'
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
   Name="Default__RBTTKrallSkeleton"
}
