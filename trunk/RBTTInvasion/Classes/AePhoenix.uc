class AePhoenix extends RBTTMonster;

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

// /////////// WEAPON STUFZZZ ///////////////////////////////// //
function byte BestMode(){	return 0;	}

simulated function float GetFireInterval( byte FireModeNum ){	return 0.5;	}

simulated function float GetTraceRange()
{
	return GetCollisionRadius() + 64;
}

function float SuggestAttackStyle() {	return 1.00;	}

simulated function InstantFire()
{
	if(VSize(Controller.Enemy.Location - Location) > GetCollisionRadius() + 64)
	{
		return; // enemy too far away to punch it in teh face!
	}
	
	`log(">> Animation duration::"@FullBodyAnimSlot.PlayCustomAnim('Sting', 1.0, 0.2, 0.2, FALSE, TRUE));
		
	super.InstantFire();
}

defaultproperties
{
	HitDamage = 10
	AccelRate=+1000.000000

	LeftFootControlName="LeftFrontFootControl"
 
	RightFootControlName="RightFrontFootControl"

	MonsterName = "AePhoenix"
	
	//DefaultMonsterWeapon=class'UTGame.UTWeap_LinkGun'
	
	bCanPickupInventory = False
	
	bCanJump=False
	bCanFly = True
	
	bCanWalk = False
	
	bMeleeMonster = True;
	bEmptyHanded = True
	bInvisibleWeapon = True
   
	MonsterSkill=3

	LightEnvironment=MyLightEnvironment

	BioBurnAway=GooDeath

	ArmsMesh(0)=FirstPersonArms

	ArmsMesh(1)=FirstPersonArms2

	PawnAmbientSound=AmbientSoundComponent

	WeaponAmbientSound=AmbientSoundComponent2
   
   OverlayMesh=OverlayMeshComponent0
   
   DefaultFamily=Class'AePhoenixFamilyInfo'
   
   DefaultMesh=SkeletalMesh'AePhoenix.AePhoenix'
   
   WalkableFloorZ=1.00000
   
   GroundSpeed=400.000000
   
   AirSpeed=400.00000
   
   
   ControllerClass=Class'RBTTMonsterControllerStinger'
   
    // InventoryManagerClass=class'RBTTWRInvManager'
  
   Begin Object Name=WPawnSkeletalMeshComponent ObjName=WPawnSkeletalMeshComponent Archetype=SkeletalMeshComponent'UTGame.Default__UTPawn:WPawnSkeletalMeshComponent'
      SkeletalMesh=SkeletalMesh'AePhoenix.AePhoenix'
      AnimTreeTemplate=AnimTree'AePhoenix.AePhoenix_Tree'
      AnimSets(0)=AnimSet'AePhoenix.AePhoenix_Anims'
      PhysicsAsset=PhysicsAsset'AePhoenix.AePhoenix_Physics'
      bHasPhysicsAssetInstance=True
      Scale3D=(X=5,Y=5,Z=5)
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
   Name="AePhoenix"
   ObjectArchetype=UTPawn'UTGame.Default__UTPawn'
}
