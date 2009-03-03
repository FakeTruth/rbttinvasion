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

	if( Role == ROLE_Authority )
	{
		//final native function float PlayCustomAnim (name AnimName, float Rate, optional float BlendInTime, optional float BlendOutTime, optional bool bLooping, optional bool bOverride)
		FullBodyAnimSlot.PlayCustomAnim('belch', 0.5, 0.1, 0.1, FALSE, TRUE);
	}

	return None;
}

simulated event DoBelch()
{
	local vector		RealStartLoc;
	local Projectile	SpawnedProjectile;

	LogInternal(">> DoBelch() called<<");
	
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
		
		LogInternal(">> SpawnedProjectile: "@SpawnedProjectile);
	}
}

simulated function float GetFireInterval( byte FireModeNum )
{
	return 2.0;
}

/* BestMode()
choose between regular or alt-fire
*/
function byte BestMode() // Can be used for switching from snipe to melee! 1 projectile 0 instant
{
	return 1; // always do projectile
}

function RangedAttack(Actor A)
{
	local vector adjust;
	local Pawn P;
	
	P = Pawn(A);
	if(P == None)
		return;
	
	if ( bShotAnim )
		return;
	if ( VSize(P.Location - Location) < 128 + GetCollisionRadius() + P.GetCollisionRadius() ) // 128 = MeleeRange
	{
		adjust = vect(0,0,0);
		adjust.Z = Controller.Enemy.GetCollisionHeight();
		Acceleration = AccelRate * Normal(Controller.Enemy.Location - Location + adjust);
		//PlaySound(sound'twopunch1g',SLOT_Talk);
		//if (FRand() < 0.5)
			//SetAnimAction('TwoPunch');
		//else
			//SetAnimAction('Pound');
	}
	else
	{
		FullBodyAnimSlot.PlayCustomAnim('belch', 0.5, 0.1, 0.1, FALSE, TRUE);
		FullBodyAnimSlot.SetActorAnimEndNotification(True);
	}
	bShotAnim = true;
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
   
   ControllerClass=Class'RBTTMonsterControllerGasBag'
  
   Begin Object Name=WPawnSkeletalMeshComponent ObjName=WPawnSkeletalMeshComponent Archetype=SkeletalMeshComponent'UTGame.Default__UTPawn:WPawnSkeletalMeshComponent'
      //SkeletalMesh=SkeletalMesh'CH_MiningBot.Mesh.SK_CH_MiningBot'
      Scale3D=(X=8,Y=8,Z=8)
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
