/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */

class RBTTScarySkullFamilyInfo extends UTFamilyInfo
	abstract;



//okie here we need to add new UTGib_HumanAccessories  which will have shoulder pads and other such sweet things

defaultproperties
{

   FamilyID="ScarySkull"
   Faction="RBTTMonster"
   PhysAsset=PhysicsAsset'RBTTScarySkull.ScarySkull_Physics'
   MasterSkeleton=SkeletalMesh'RBTTScarySkull.ScarySkull'

   DeathMeshSkelMesh=SkeletalMesh'RBTTScarySkull.ScarySkull'
   DeathMeshPhysAsset=PhysicsAsset'RBTTScarySkull.ScarySkull_Physics'
   DeathMeshNumMaterialsToSetResident=1
   SkeletonBurnOutMaterials(0)=MaterialInstanceTimeVarying'CH_Skeletons.Materials.MITV_CH_Skeletons_Human_01_BO'
   SoundGroupClass=Class'RBTTInvasion.ScarySkullSoundGroup'

   Name="Default__RBTTScarySkullFamilyInfo"
   ObjectArchetype=UTFamilyInfo'UTGame.Default__UTFamilyInfo'
}
