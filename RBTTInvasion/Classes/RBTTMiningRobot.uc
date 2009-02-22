class RBTTMiningRobot extends RBTTMonster;

var() skeletalMeshComponent DefaultMonsterMesh;
var() class<UTWeapon> DefaultMonsterWeapon;

//var() int MonsterSkill, 
var() int monsterTeam;
var() int MonsterScale;
//var() string MonsterName;

function bool PerformDodge(eDoubleClickDir DoubleClickMove, vector Dir, vector Cross)
{
	super.PerformDodge(DoubleClickMove, Dir, Cross);
	
	SetPhysics(PHYS_Flying);
	return true;
}

function DropToGround()
{
	super.DropToGround();
	SetPhysics(PHYS_Flying);
}

function AddVelocity( vector NewVelocity, vector HitLocation, class<DamageType> damageType, optional TraceHitInfo HitInfo )
{
	super.AddVelocity(NewVelocity, HitLocation, damageType, HitInfo );
	SetPhysics(PHYS_Flying);
}

function SetMovementPhysics()
{
	SetPhysics(PHYS_Flying);
}

function JumpOffPawn()
{
	SetPhysics(PHYS_Flying);
}

defaultproperties
{
	WeaponSpeedMultiplier = 1.500

	bEnableFootPlacement=False

	MonsterName = "MiningRobot"
   
	MonsterSkill=2

	LightEnvironment=MyLightEnvironment

	BioBurnAway=GooDeath

	ArmsMesh(0)=FirstPersonArms

	ArmsMesh(1)=FirstPersonArms2

	PawnAmbientSound=AmbientSoundComponent

	WeaponAmbientSound=AmbientSoundComponent2
   
   OverlayMesh=OverlayMeshComponent0
   
   MaxStepHeight=26.000000
   
   bCanJump=True
   bCanFly=True
   
   GroundSpeed=50.000000
   AirSpeed=50.00000
   
   DefaultFamily=Class'RBTTMiningRobotFamilyInfo'
   
   //DefaultMesh=SkeletalMesh'CH_MiningBot.Mesh.SK_CH_MiningBot'
   DefaultMesh=SkeletalMesh'NewMiningBot.Mesh.SK_CH_MiningBot'
   //InventoryManagerClass=class'RBTTMRInvManager'
   WalkableFloorZ=0.800000
   
   ControllerClass=Class'RBTTMonsterControllerStinger'
   MonsterweaponClass=Class'UTGame.UTWeap_Stinger'
   bCanPickupInventory=False
   bInvisibleWeapon = false;
   JumpZ=100.000000
  
   Begin Object Name=WPawnSkeletalMeshComponent ObjName=WPawnSkeletalMeshComponent Archetype=SkeletalMeshComponent'UTGame.Default__UTPawn:WPawnSkeletalMeshComponent'
      //SkeletalMesh=SkeletalMesh'CH_MiningBot.Mesh.SK_CH_MiningBot'
      SkeletalMesh=SkeletalMesh'NewMiningBot.Mesh.SK_CH_MiningBot'
      AnimTreeTemplate=AnimTree'NewMiningBot.SK_CH_MiningBot_Tree'
      AnimSets(0)=AnimSet'CH_MiningBot.Anims.K_HC_MiningBot'
      PhysicsAsset=PhysicsAsset'NewMiningBot.Mesh.SK_CH_MiningBot_Physics'
      bHasPhysicsAssetInstance=True
      Name="WPawnSkeletalMeshComponent"
	  ObjectArchetype=SkeletalMeshComponent'UTGame.Default__UTPawn:WPawnSkeletalMeshComponent'
   End Object
   Mesh=WPawnSkeletalMeshComponent
   
   Begin Object Name=CollisionCylinder ObjName=CollisionCylinder Archetype=CylinderComponent'UTGame.Default__UTPawn:CollisionCylinder'
      CollisionHeight=35.000000
      CollisionRadius=21.000000
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
   Name="Default__RBTTMiningRobot"
   ObjectArchetype=UTPawn'UTGame.Default__UTPawn'
}
