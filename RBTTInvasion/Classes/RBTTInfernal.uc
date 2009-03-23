class RBTTInfernal extends RBTTMonster;

var() skeletalMeshComponent DefaultMonsterMesh;
var() class<UTWeapon> DefaultMonsterWeapon;


var() int monsterTeam;
var() int MonsterScale;


//var AnimNodeSlot FullBodyAnimSlot;

simulated function PostBeginPlay()
{
	//FullBodyAnimSlot = AnimNodeSlot(Mesh.FindAnimNode('FullBodySlot'));
	super.PostBeginPlay();
	//SetTimer(3, true, 'EmoteTimer');
}


simulated function EmoteTimer()
{
	//local float AnimLength;
	//`log(">>Doing animation! << FullBodyAnimSlot:"@FullBodyAnimSlot);
	//AnimLength = FullBodyAnimSlot.PlayCustomAnim(Class'UTGame.UTFamilyInfo'.default.FamilyEmotes[0].EmoteAnim, 1.0, 0.2, 0.2, FALSE, TRUE);
	//AnimLength = FullBodyAnimSlot.PlayCustomAnim('Taunt_FB_Victory', 1.0, 0.2, 0.2, FALSE, TRUE);
	//`log(">>AnimLength is :"@AnimLength);
	//PlayEmote('TauntA', 0);
}

defaultproperties
{
	bEmptyHanded = True
	bNeedWeapon = False
	bCanPickupInventory = False
	
	LeftFootControlName="LeftFrontFootControl"
 
	RightFootControlName="RightFrontFootControl"

	MonsterName = "HumanSkeleton"
   
	MonsterSkill=1

	LightEnvironment=MyLightEnvironment

	BioBurnAway=GooDeath

	ArmsMesh(0)=FirstPersonArms

	ArmsMesh(1)=FirstPersonArms2

	PawnAmbientSound=AmbientSoundComponent

	WeaponAmbientSound=AmbientSoundComponent2
   
   OverlayMesh=OverlayMeshComponent0
   
   DefaultFamily=Class'RBTTInfernalFamilyInfo'
   
   DefaultMesh=SkeletalMesh'RBTTInfernal.Infernal'
   
   WalkableFloorZ=0.800000
   
   ControllerClass=Class'RBTTMonsterControllerNoWeapon'
 
   Begin Object Name=WPawnSkeletalMeshComponent ObjName=WPawnSkeletalMeshComponent Archetype=SkeletalMeshComponent'UTGame.Default__UTPawn:WPawnSkeletalMeshComponent'
      Scale3D=(X=3,Y=3,Z=3)
      
      SkeletalMesh=SkeletalMesh'RBTTInfernal.Infernal'
      AnimTreeTemplate=AnimTree'CH_AnimHuman_Tree.AT_CH_Human'
      AnimSets(0)=AnimSet'CH_AnimHuman.Anims.K_AnimHuman_BaseMale'
      PhysicsAsset=PhysicsAsset'CH_Skeletons.Mesh.SK_CH_Skeleton_Human_Male_Physics'
      bHasPhysicsAssetInstance=True
      Name="WPawnSkeletalMeshComponent"
	  ObjectArchetype=SkeletalMeshComponent'UTGame.Default__UTPawn:WPawnSkeletalMeshComponent'
   End Object
   Mesh=WPawnSkeletalMeshComponent
   
   Begin Object Name=CollisionCylinder ObjName=CollisionCylinder Archetype=CylinderComponent'UTGame.Default__UTPawn:CollisionCylinder'
      CollisionHeight=128.000000
      CollisionRadius=64.000000
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
   Name="Default__RBTTHumanSkeleton"
   ObjectArchetype=UTPawn'UTGame.Default__UTPawn'
}
