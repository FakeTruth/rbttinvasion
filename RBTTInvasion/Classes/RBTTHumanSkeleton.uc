class RBTTHumanSkeleton extends RBTTMonster;

var() skeletalMeshComponent DefaultMonsterMesh;
var() class<UTWeapon> DefaultMonsterWeapon;


var() int monsterTeam;
var() int MonsterScale;


//var AnimNodeSlot FullBodyAnimSlot;

simulated function PostBeginPlay()
{
	//FullBodyAnimSlot = AnimNodeSlot(Mesh.FindAnimNode('FullBodySlot'));
	super.PostBeginPlay();
	//SetTimer(3, true, 'EmoteTimer');
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

defaultproperties
{
   MonsterName="HumanSkeleton"
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
      Animations=AnimNodeSequence'RBTTInvasion.Default__RBTTHumanSkeleton:FirstPersonArms.MeshSequenceA'
      ObjectArchetype=UTSkeletalMeshComponent'RBTTInvasion.Default__RBTTMonster:FirstPersonArms'
   End Object
   ArmsMesh(0)=FirstPersonArms
   Begin Object Class=UTSkeletalMeshComponent Name=FirstPersonArms2 ObjName=FirstPersonArms2 Archetype=UTSkeletalMeshComponent'RBTTInvasion.Default__RBTTMonster:FirstPersonArms2'
      Begin Object Class=AnimNodeSequence Name=MeshSequenceB ObjName=MeshSequenceB Archetype=AnimNodeSequence'RBTTInvasion.Default__RBTTMonster:FirstPersonArms2.MeshSequenceB'
         ObjectArchetype=AnimNodeSequence'RBTTInvasion.Default__RBTTMonster:FirstPersonArms2.MeshSequenceB'
      End Object
      Animations=AnimNodeSequence'RBTTInvasion.Default__RBTTHumanSkeleton:FirstPersonArms2.MeshSequenceB'
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
   DefaultFamily=Class'RBTTInvasion.RBTTHumanSkeletonFamilyInfo'
   DefaultMesh=SkeletalMesh'CH_Skeletons.Mesh.SK_CH_Skeleton_Human_Male'
   WalkableFloorZ=0.800000
   ControllerClass=Class'RBTTInvasion.RBTTMonsterControllerNoWeapon'
   Begin Object Class=SkeletalMeshComponent Name=WPawnSkeletalMeshComponent ObjName=WPawnSkeletalMeshComponent Archetype=SkeletalMeshComponent'UTGame.Default__UTPawn:WPawnSkeletalMeshComponent'
      SkeletalMesh=SkeletalMesh'CH_Skeletons.Mesh.SK_CH_Skeleton_Human_Male'
      PhysicsAsset=PhysicsAsset'CH_Skeletons.Mesh.SK_CH_Skeleton_Human_Male_Physics'
      AnimSets(0)=AnimSet'CH_AnimHuman.Anims.K_AnimHuman_BaseMale'
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
   Name="Default__RBTTHumanSkeleton"
}
