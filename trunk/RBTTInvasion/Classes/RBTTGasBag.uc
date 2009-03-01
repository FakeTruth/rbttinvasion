class RBTTGasbag extends RBTTMonster;

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

simulated function Projectile ProjectileFire()
{
	local vector		RealStartLoc;
	local Projectile	SpawnedProjectile;
	//local float		AnimLength; // for checking if animation works

	// tell remote clients that we fired, to trigger effects
	Weapon.IncrementFlashCount();

	if( Role == ROLE_Authority )
	{
		// this is the location where the projectile is spawned.
		RealStartLoc = Weapon.GetPhysicalFireStartLoc();

		// Spawn projectile
		SpawnedProjectile = Spawn(Class'RBTTGasBagBelch',,, RealStartLoc);
		if( SpawnedProjectile != None && !SpawnedProjectile.bDeleteMe )
		{
			SpawnedProjectile.Init( Vector(Weapon.GetAdjustedAim( RealStartLoc )) );
		}
		
		/* // IT DOESN'T HAVE AN ANIM SLOT, GOTTO GET ONE FIRST BEFOR DOIN ANIMATIONS!
		LogInternal(">>Doing animation! << FullBodyAnimSlot:"@FullBodyAnimSlot);
		AnimLength = FullBodyAnimSlot.PlayCustomAnim('Taunt_FB_Victory', 1.0, 0.2, 0.2, FALSE, TRUE);
		LogInternal(">>AnimLength is :"@AnimLength);
		*/
		
		// Return it up the line
		return SpawnedProjectile;
	}

	return None;
}

/* BestMode()
choose between regular or alt-fire
*/
function byte BestMode() // Can be used for switching from snipe to melee! 1 projectile 0 instant
{
	return 1; // always do projectile
}

defaultproperties
{
	bEmptyHanded = True
	bNeedWeapon = False
	bCanPickupInventory = False
	InventoryManagerClass=class'RBTTInventoryManager'
	health = 200

	bEnableFootPlacement=False

	MonsterName = "GasBag"
   
	MonsterSkill=2

	LightEnvironment=MyLightEnvironment

	BioBurnAway=GooDeath

	ArmsMesh(0)=FirstPersonArms

	ArmsMesh(1)=FirstPersonArms2

	PawnAmbientSound=AmbientSoundComponent

	WeaponAmbientSound=AmbientSoundComponent2
   
   OverlayMesh=OverlayMeshComponent0
   
   bCanJump=True
   bCanFly=True
   
   GroundSpeed=50.000000
   AirSpeed=50.00000
   
   DefaultFamily=Class'RBTTGasBagFamilyInfo'
   
   DefaultMesh=SkeletalMesh'GasBag.GasBag'
   
   ControllerClass=Class'RBTTMonsterControllerStinger'
  
   Begin Object Name=WPawnSkeletalMeshComponent ObjName=WPawnSkeletalMeshComponent Archetype=SkeletalMeshComponent'UTGame.Default__UTPawn:WPawnSkeletalMeshComponent'
      //SkeletalMesh=SkeletalMesh'CH_MiningBot.Mesh.SK_CH_MiningBot'
      Scale3D=(X=16,Y=16,Z=16)
      SkeletalMesh=SkeletalMesh'GasBag.GasBag'
      AnimTreeTemplate=AnimTree'GasBag.GasBag_Tree'
      AnimSets(0)=AnimSet'GasBag.gasbaganims'
      PhysicsAsset=PhysicsAsset'GasBag.GasBag_Physics'
      bHasPhysicsAssetInstance=True
      Name="WPawnSkeletalMeshComponent"
	  ObjectArchetype=SkeletalMeshComponent'UTGame.Default__UTPawn:WPawnSkeletalMeshComponent'
   End Object
   Mesh=WPawnSkeletalMeshComponent
   
   Begin Object Name=CollisionCylinder ObjName=CollisionCylinder Archetype=CylinderComponent'UTGame.Default__UTPawn:CollisionCylinder'
      CollisionHeight=64.000000
      CollisionRadius=128.000000
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
   Name="Default__RBTTGasBag"
   ObjectArchetype=UTPawn'UTGame.Default__UTPawn'
}
