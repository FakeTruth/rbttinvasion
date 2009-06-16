class AePhoenix extends RBTTScarySkull;

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
	HeadBone="joint5"
	MonsterName = "AePhoenix"
	
	//DefaultMonsterWeapon=class'UTGame.UTWeap_LinkGun'

	bEmptyHanded = True

   DefaultFamily=Class'AePhoenixFamilyInfo'
   
   DefaultMesh=SkeletalMesh'AePhoenix.AePhoenix'

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
   
   //SoundGroupClass=Class'RBTTInvasion.ScarySkullSoundGroup'
   
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
