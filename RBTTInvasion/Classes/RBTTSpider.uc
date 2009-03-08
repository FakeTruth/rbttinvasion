class RBTTSpider extends RBTTMonster;

var() skeletalMeshComponent DefaultMonsterMesh;
var() class<UTWeapon> DefaultMonsterWeapon;

//var() int MonsterSkill, 
var() int monsterTeam;
var() int MonsterScale;
//var() string MonsterName;

/*
function bool Died(Controller Killer, class<DamageType> damageType, vector HitLocation)
{
	local bool DiedReturn;

	DiedReturn = Super.Died(Killer, damageType, HitLocation);
	
	LogInternal(">>>>>>>>>>>>>>>>>>>Pawn Destroyed!<<<<<<<<<<<<<<<<<<<");
	MonsterController.Destroy();
	LogInternal(">>>>>>>>>>>>>> CONTROLLER DESTROYED <<<<<<<<<<<<<<<");
	Destroy();

	return DiedReturn;
}
*/


defaultproperties
{
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
	MonsterName = "Spider"
	MonsterSkill=5
	LightEnvironment=MyLightEnvironment
	BioBurnAway=GooDeath
	ArmsMesh(0)=FirstPersonArms
	ArmsMesh(1)=FirstPersonArms2
	PawnAmbientSound=AmbientSoundComponent
	WeaponAmbientSound=AmbientSoundComponent2
	GroundSpeed=500.000000
   OverlayMesh=OverlayMeshComponent0
   DefaultFamily=Class'RBTTSpiderFamilyInfo'
   
   DefaultMesh=SkeletalMesh'RBTTSpiderPackage.Mesh.Spider'
   
   WalkableFloorZ=0.300000
   
   ControllerClass=Class'RBTTMonsterControllerMelee'
   InventoryManagerClass=class'RBTTInventoryManager'
  
   Begin Object Name=WPawnSkeletalMeshComponent ObjName=WPawnSkeletalMeshComponent Archetype=SkeletalMeshComponent'UTGame.Default__UTPawn:WPawnSkeletalMeshComponent'
      SkeletalMesh=SkeletalMesh'RBTTSpiderPackage.Mesh.Spider'
      AnimTreeTemplate=AnimTree'RBTTSpiderPackage.Anims.SpiderAnimTree'
      AnimSets(0)=AnimSet'RBTTSpiderPackage.Anims.SpiderAnimSet'
      bHasPhysicsAssetInstance=True
      PhysicsAsset=PhysicsAsset'RBTTSpiderPackage.Mesh.Spider_Physics'
      Name="WPawnSkeletalMeshComponent"
	  ObjectArchetype=SkeletalMeshComponent'UTGame.Default__UTPawn:WPawnSkeletalMeshComponent'
   End Object
   Mesh=WPawnSkeletalMeshComponent
   
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
   Name="Default__RBTTSpider"
   ObjectArchetype=UTPawn'UTGame.Default__UTPawn'
	
	// default bone names
	WeaponSocket=WeaponPoint
	WeaponSocket2=DualWeaponPoint
	bNeedWeapon = false
}
