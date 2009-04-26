class RBTTScorpion extends RBTTMonster;

/** Enable or disable IK that keeps hands on IK bones. */
simulated function SetHandIKEnabled(bool bEnabled); // It doesn't have hands

defaultproperties
{
	bMeleeMonster = True;
	JumpZ=300.0
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
	MonsterName = "Scorpion"
	MonsterSkill=4
	LightEnvironment=MyLightEnvironment
	BioBurnAway=GooDeath
	ArmsMesh(0)=FirstPersonArms
	ArmsMesh(1)=FirstPersonArms2
	PawnAmbientSound=AmbientSoundComponent
	WeaponAmbientSound=AmbientSoundComponent2
	GroundSpeed=350.000000
   OverlayMesh=OverlayMeshComponent0
   DefaultFamily=Class'RBTTScorpionFamilyInfo'
   
   DefaultMesh=SkeletalMesh'RBTTScorpion.Scorpion'

   WalkableFloorZ=0.300000

   ControllerClass=Class'RBTTMonsterControllerMelee'
   InventoryManagerClass=class'RBTTInventoryManager'
  
   Begin Object Name=WPawnSkeletalMeshComponent ObjName=WPawnSkeletalMeshComponent Archetype=SkeletalMeshComponent'UTGame.Default__UTPawn:WPawnSkeletalMeshComponent'
      SkeletalMesh=SkeletalMesh'RBTTScorpion.Scorpion'
      AnimTreeTemplate=AnimTree'RBTTScorpion.ScorpionAnimTree'
      AnimSets(0)=AnimSet'RBTTScorpion.ScorpionMoves'
      bHasPhysicsAssetInstance=True
      PhysicsAsset=PhysicsAsset'RBTTScorpion.Scorpion_Physics'
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
   Name="Default__RBTTScorpion"
   ObjectArchetype=UTPawn'UTGame.Default__UTPawn'
	
	// default bone names
	WeaponSocket=WeaponPoint
	WeaponSocket2=DualWeaponPoint
	bNeedWeapon = false
}
