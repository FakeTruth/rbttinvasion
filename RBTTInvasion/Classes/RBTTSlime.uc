class RBTTSlime extends RBTTMonster;

var() skeletalMeshComponent DefaultMonsterMesh;
var() class<UTWeapon> DefaultMonsterWeapon;

//var() int MonsterSkill, 
var() int monsterTeam;
var() int MonsterScale;
//var() string MonsterName;


defaultproperties
{
	health = 75

	bMeleeMonster = True;
	JumpZ=644.0
	bCanStrafe=False
	bCanSwim=False
	bCanClimbCeilings=true
	bInvisibleWeapon = True;
	bCanPickupInventory = False;
	TorsoBoneName="Spine"
	HeadBone="Head"
	bEnableFootPlacement=False
	LeftFootControlName="LeftFrontFootControl"
	RightFootControlName="RightFrontFootControl"
	MonsterName = "Slime"
	MonsterSkill=5
	LightEnvironment=MyLightEnvironment
	BioBurnAway=GooDeath
	ArmsMesh(0)=FirstPersonArms
	ArmsMesh(1)=FirstPersonArms2
	PawnAmbientSound=AmbientSoundComponent
	WeaponAmbientSound=AmbientSoundComponent2
	GroundSpeed=200.000000
   OverlayMesh=OverlayMeshComponent0
   DefaultFamily=Class'RBTTSlimeFamilyInfo'
   
   DefaultMesh=SkeletalMesh'RBTTSlime.RBTTSlime'
   
   WalkableFloorZ=0.300000
   
   ControllerClass=Class'RBTTMonsterControllerMelee'
   InventoryManagerClass=class'RBTTInventoryManager'
  
  
   Begin Object Name=WPawnSkeletalMeshComponent ObjName=WPawnSkeletalMeshComponent Archetype=SkeletalMeshComponent'UTGame.Default__UTPawn:WPawnSkeletalMeshComponent'
      SkeletalMesh=SkeletalMesh'RBTTSlime.RBTTSlime'
      AnimTreeTemplate=AnimTree'RBTTSlime.RBTTSlimeTree'
      AnimSets(0)=AnimSet'RBTTSlime.RBTTSlimeAnims'
      bHasPhysicsAssetInstance=True
      Scale3D=(X=8,Y=8,Z=8)
      Rotation=(Yaw=49149) //(65535 = 360 degrees) (16383 = 90 degrees) | Yaw, Roll, Pitch
      PhysicsAsset=PhysicsAsset'RBTTSlime.RBTTSlime_Physics'
      Name="WPawnSkeletalMeshComponent"
	  ObjectArchetype=SkeletalMeshComponent'UTGame.Default__UTPawn:WPawnSkeletalMeshComponent'
   End Object
   Mesh=WPawnSkeletalMeshComponent
   
   Begin Object Name=CollisionCylinder ObjName=CollisionCylinder Archetype=CylinderComponent'UTGame.Default__UTPawn:CollisionCylinder'
      CollisionHeight=24.000000
      CollisionRadius=24.000000
      Translation=(X=0,Y=0,Z=20)
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
   Name="Default__RBTTSlime"
   ObjectArchetype=UTPawn'UTGame.Default__UTPawn'
	
	// default bone names
	WeaponSocket=WeaponPoint
	WeaponSocket2=DualWeaponPoint
	bNeedWeapon = false
}
