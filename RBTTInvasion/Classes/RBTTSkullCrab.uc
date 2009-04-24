class RBTTSkullCrab extends RBTTMonster placeable;

var() class<UTWeapon> DefaultMonsterWeapon;


defaultproperties
{
	bMeleeMonster = True;
	bInvisibleWeapon = True;

	TorsoBoneName="Spine"
	HeadBone="Head"
	bEnableFootPlacement=False
	LeftFootControlName="LeftFrontFootControl"
	RightFootControlName="RightFrontFootControl"
	MonsterName = "SkullCrab"
	MonsterSkill=5
	LightEnvironment=MyLightEnvironment
	BioBurnAway=GooDeath
	ArmsMesh(0)=FirstPersonArms
	ArmsMesh(1)=FirstPersonArms2
	PawnAmbientSound=AmbientSoundComponent
	WeaponAmbientSound=AmbientSoundComponent2
	GroundSpeed=500.000000
   OverlayMesh=OverlayMeshComponent0
   DefaultFamily=Class'RBTTMonsterFamilyInfo'
   
   DefaultMesh=SkeletalMesh'SkullCrabPKG2.SkullCrabA'
   
   WalkableFloorZ=0.300000
   
   ControllerClass=Class'RBTTMonsterControllerMelee'
   InventoryManagerClass=class'RBTTInventoryManager'
  
   Begin Object Name=WPawnSkeletalMeshComponent ObjName=WPawnSkeletalMeshComponent Archetype=SkeletalMeshComponent'UTGame.Default__UTPawn:WPawnSkeletalMeshComponent'
      SkeletalMesh=SkeletalMesh'SkullCrabPKG2.SkullCrabA'
      AnimTreeTemplate=AnimTree'SkullCrabPKG2.SkullCrabAnimTree'
      AnimSets(0)=AnimSet'SkullCrabPKG2.SkullCrabAnims'
      bHasPhysicsAssetInstance=True
      PhysicsAsset=PhysicsAsset'SkullCrabPKG2.SkullCrabA_Physics'
      Name="WPawnSkeletalMeshComponent"
	  ObjectArchetype=SkeletalMeshComponent'UTGame.Default__UTPawn:WPawnSkeletalMeshComponent'
   End Object
   Mesh=WPawnSkeletalMeshComponent
   
   DefaultHeight = 24.0000
   DefaultRadius = 24.0000

   Begin Object Name=CollisionCylinder ObjName=CollisionCylinder Archetype=CylinderComponent'UTGame.Default__UTPawn:CollisionCylinder'
      CollisionHeight=24.000000
      CollisionRadius=24.000000
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
   Name="Default__RBTTSkullCrab"
   ObjectArchetype=UTPawn'UTGame.Default__UTPawn'

	// default bone names
	WeaponSocket=WeaponPoint
	WeaponSocket2=DualWeaponPoint
	bNeedWeapon = false
}
