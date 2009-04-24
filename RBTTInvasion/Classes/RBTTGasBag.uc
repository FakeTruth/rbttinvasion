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
   MonsterSkill=2
   MonsterName="GasBag"
   bEmptyHanded=True
   bEnableFootPlacement=False
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
      Animations=AnimNodeSequence'RBTTInvasion.Default__RBTTGasbag:FirstPersonArms.MeshSequenceA'
      ObjectArchetype=UTSkeletalMeshComponent'RBTTInvasion.Default__RBTTMonster:FirstPersonArms'
   End Object
   ArmsMesh(0)=FirstPersonArms
   Begin Object Class=UTSkeletalMeshComponent Name=FirstPersonArms2 ObjName=FirstPersonArms2 Archetype=UTSkeletalMeshComponent'RBTTInvasion.Default__RBTTMonster:FirstPersonArms2'
      Begin Object Class=AnimNodeSequence Name=MeshSequenceB ObjName=MeshSequenceB Archetype=AnimNodeSequence'RBTTInvasion.Default__RBTTMonster:FirstPersonArms2.MeshSequenceB'
         ObjectArchetype=AnimNodeSequence'RBTTInvasion.Default__RBTTMonster:FirstPersonArms2.MeshSequenceB'
      End Object
      Animations=AnimNodeSequence'RBTTInvasion.Default__RBTTGasbag:FirstPersonArms2.MeshSequenceB'
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
   DefaultFamily=Class'RBTTInvasion.RBTTGasBagFamilyInfo'
   DefaultMesh=None
   bCanFly=True
   GroundSpeed=50.000000
   AirSpeed=50.000000
   Health=200
   ControllerClass=Class'RBTTInvasion.RBTTMonsterControllerGasBag'
   Begin Object Class=SkeletalMeshComponent Name=WPawnSkeletalMeshComponent ObjName=WPawnSkeletalMeshComponent Archetype=SkeletalMeshComponent'UTGame.Default__UTPawn:WPawnSkeletalMeshComponent'
      AnimTreeTemplate=None
      AnimSets(0)=None
      Scale3D=(X=8.000000,Y=8.000000,Z=8.000000)
      ObjectArchetype=SkeletalMeshComponent'UTGame.Default__UTPawn:WPawnSkeletalMeshComponent'
   End Object
   Mesh=WPawnSkeletalMeshComponent
   Begin Object Class=CylinderComponent Name=CollisionCylinder ObjName=CollisionCylinder Archetype=CylinderComponent'UTGame.Default__UTPawn:CollisionCylinder'
      CollisionHeight=64.000000
      CollisionRadius=128.000000
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
   Name="Default__RBTTGasbag"
}
