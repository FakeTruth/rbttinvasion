class RBTTScarySkull extends RBTTMonster;

var() skeletalMeshComponent DefaultMonsterMesh;
var() class<UTWeapon> DefaultMonsterWeapon;


var() int monsterTeam;
var() int MonsterScale;

function AddDefaultInventory()
{
    Super.AddDefaultInventory();
    CreateInventory(DefaultMonsterWeapon);
}

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
	bMeleeMonster = True;
	AccelRate=+500.000000

	LeftFootControlName="LeftFrontFootControl"
 
	RightFootControlName="RightFrontFootControl"

	MonsterName = "ScarySkull"
	
	//DefaultMonsterWeapon=class'UTGame.UTWeap_LinkGun'
	
	bCanPickupInventory = False
	
	bCanJump=False
	bCanFly = True
	
	bCanWalk = False
	
	bInvisibleWeapon = True
   
	MonsterSkill=3

	LightEnvironment=MyLightEnvironment

	BioBurnAway=GooDeath

	ArmsMesh(0)=FirstPersonArms

	ArmsMesh(1)=FirstPersonArms2

	PawnAmbientSound=AmbientSoundComponent

	WeaponAmbientSound=AmbientSoundComponent2
   
   OverlayMesh=OverlayMeshComponent0
   
   DefaultFamily=Class'RBTTScarySkullFamilyInfo'
   
   DefaultMesh=SkeletalMesh'RBTTScarySkull.ScarySkull'
   
   WalkableFloorZ=1.00000
   
   GroundSpeed=400.000000
   
   AirSpeed=400.00000
   
   
   ControllerClass=Class'RBTTMonsterControllerStinger'
   
    // InventoryManagerClass=class'RBTTWRInvManager'
  
   Begin Object Name=WPawnSkeletalMeshComponent ObjName=WPawnSkeletalMeshComponent Archetype=SkeletalMeshComponent'UTGame.Default__UTPawn:WPawnSkeletalMeshComponent'
      SkeletalMesh=SkeletalMesh'RBTTScarySkull.ScarySkull'
      AnimTreeTemplate=AnimTree'RBTTScarySkull.RBTTScarySkullAnimTree'
      AnimSets(0)=AnimSet'RBTTScarySkull.ScarySkullAnims'
      PhysicsAsset=PhysicsAsset'RBTTScarySkull.ScarySkull_Physics'
      bHasPhysicsAssetInstance=True
      Name="WPawnSkeletalMeshComponent"
	  ObjectArchetype=SkeletalMeshComponent'UTGame.Default__UTPawn:WPawnSkeletalMeshComponent'
   End Object
   Mesh=WPawnSkeletalMeshComponent
   
   Begin Object Name=CollisionCylinder ObjName=CollisionCylinder Archetype=CylinderComponent'UTGame.Default__UTPawn:CollisionCylinder'
      CollisionHeight=44.000000
      CollisionRadius=21.000000
      ObjectArchetype=CylinderComponent'UTGame.Default__UTPawn:CollisionCylinder'
   End Object
   CylinderComponent=CollisionCylinder
   
   Components(0)=CollisionCylinder
   
   Begin Object Name=Arrow ObjName=Arrow Archetype=ArrowComponent'UTGame.Default__UTPawn:Arrow'
      ObjectArchetype=ArrowComponent'UTGame.Default__UTPawn:Arrow'
   End Object
   
   SoundGroupClass=Class'RBTTInvasion.ScarySkullSoundGroup'
   
   Components(1)=Arrow
   Components(2)=MyLightEnvironment
   Components(3)=WPawnSkeletalMeshComponent
   Components(4)=AmbientSoundComponent
   Components(5)=AmbientSoundComponent2
   Components(6)=MyLightEnvironment
   Components(8)=CollisionCylinder
   CollisionComponent=CollisionCylinder
   Name="Default__RBTTScarySkull"
   ObjectArchetype=UTPawn'UTGame.Default__UTPawn'
}
