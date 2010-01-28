class RBTTMartian2k4 extends RBTTMonster;

var() skeletalMeshComponent DefaultMonsterMesh;
var() class<UTWeapon> DefaultMonsterWeapon;


var() int monsterTeam;
var() int MonsterScale;
var array<name> DeResBoneNames;
function AddDefaultInventory()
{
    Super.AddDefaultInventory();
    CreateInventory(DefaultMonsterWeapon);
}
simulated function PlayDying(class<DamageType> DamageType, vector HitLoc)
{
	local MaterialInstanceTimeVarying MITV_BurnOut;
	local int i;

	
	super.PlayDying(DamageType, HitLoc);
	
	if (WorldInfo.NetMode != NM_DedicatedServer)
	{
		MITV_BurnOut = new(Mesh.outer) class'MaterialInstanceTimeVarying';
		MITV_BurnOut.SetParent( GetFamilyInfo().default.SkeletonBurnOutMaterials[0] );
		// this can have a max of 6 before it wraps and become visible again
		Mesh.SetMaterial( 0, MITV_BurnOut );
		Mesh.SetMaterial( 1, MITV_BurnOut );
		Mesh.SetMaterial( 2, MITV_BurnOut );
		//MITV_BurnOut.SetScalarStartTime( 'BurnAmount', 1.0f );	
		MITV_BurnOut.SetScalarStartTime( 'BurnAmount', 0 );	


		for(i = DeResBoneNames.length-1; i >= 0; i--)
		{
			WorldInfo.MyEmitterPool.SpawnEmitter( ParticleSystem'WP_BioRifle.Particles.P_WP_Bio_Alt_Blob_POP', Mesh.GetBoneLocation( DeResBoneNames[i] ), Rotator(vect(0,0,1)), self );           

		}
	}

	SetTimer(2, False, 'Destroy');
}


defaultproperties
{
	DeResBoneNames(0)=Bip01-R-Forearm
	DeResBoneNames(1)=Bip01-L-Forearm
	DeResBoneNames(2)=Bip01-Neck
	DeResBoneNames(3)=Bip01-R-Hand
	DeResBoneNames(4)=bip01-l-Hand
	DeResBoneNames(5)=Bip01-Spine1
	DeResBoneNames(6)=Bip01-R-Thigh
	DeResBoneNames(7)=Bip01-L-Thigh

        LeftFootControlName="LeftFrontFootControl"
 
	RightFootControlName="RightFrontFootControl"

	MonsterName = "Martian"

	//DefaultMonsterWeapon=class'UTGame.UTWeap_LinkGun'
	MonsterweaponClass=Class'UTGame.UTWeap_LinkGun'
	bWeaponAttachmentVisible=true
        bEmptyHanded = False
        TorsoBoneName=bip01-Spine2
        WeaponSocket=WeaponPoint
	HeadBone=Bip01-Head
        MonsterHealth = 200
	HitDamage = 75
	MonsterSkill=1
        bCanDoubleJump=true
	LightEnvironment=MyLightEnvironment

	BioBurnAway=GooDeath
        bCanRagdoll=false
	ArmsMesh(0)=FirstPersonArms

	ArmsMesh(1)=FirstPersonArms2

	PawnAmbientSound=AmbientSoundComponent

	WeaponAmbientSound=AmbientSoundComponent2

    OverlayMesh=OverlayMeshComponent0
   
   DefaultFamily=Class'RBTTMartian2k4FamilyInfo'
   
   DefaultMesh=SkeletalMesh'Martian2k4.MartianMeshRedMartianHeadSkeleton'

   WalkableFloorZ=0.00000

   ControllerClass=Class'RBTTMonsterController'
   
    // InventoryManagerClass=class'RBTTWRInvManager'
  
   Begin Object Name=WPawnSkeletalMeshComponent ObjName=WPawnSkeletalMeshComponent Archetype=SkeletalMeshComponent'UTGame.Default__UTPawn:WPawnSkeletalMeshComponent'
      Scale3D=(X=.25,Y=.25,Z=.25)
      SkeletalMesh=SkeletalMesh'Martian2k4.MartianMeshRedMartianHeadSkeleton'
      AnimTreeTemplate=AnimTree'Martian2k4.MartianAnimTree'
      AnimSets(0)=AnimSet'Martian2k4.MartianAnims'
      PhysicsAsset=PhysicsAsset'Martian2k4.MartianMeshRedMartianHeadSkeleton_Physics'
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
   
   SoundGroupClass=Class'RBTTMartian2k4.Martian2k4SoundGroup'
   
   Components(1)=Arrow
   Components(2)=MyLightEnvironment
   Components(3)=WPawnSkeletalMeshComponent
   Components(4)=AmbientSoundComponent
   Components(5)=AmbientSoundComponent2
   Components(6)=MyLightEnvironment
   Components(8)=CollisionCylinder
   CollisionComponent=CollisionCylinder
   Name="Default__RBTTMartian"
   ObjectArchetype=UTPawn'UTGame.Default__UTPawn'
}