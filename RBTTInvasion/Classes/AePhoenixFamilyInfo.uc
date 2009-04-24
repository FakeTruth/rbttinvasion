/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */

class AePhoenixFamilyInfo extends UTFamilyInfo
	abstract;



//okie here we need to add new UTGib_HumanAccessories  which will have shoulder pads and other such sweet things

defaultproperties
{

   FamilyID="AePhoenix"
   Faction="RBTTMonster"
   PhysAsset=PhysicsAsset'AePhoenix.AePhoenix_Physics'
   MasterSkeleton=SkeletalMesh'AePhoenix.AePhoenix'
   AnimSets(0)=AnimSet'AePhoenix.AePhoenix_Anims'

   DeathMeshSkelMesh=SkeletalMesh'AePhoenix.AePhoenix'
   DeathMeshPhysAsset=PhysicsAsset'AePhoenix.AePhoenix_Physics'
   DeathMeshNumMaterialsToSetResident=1
   SkeletonBurnOutMaterials(0)=MaterialInstanceTimeVarying'CH_Skeletons.Materials.MITV_CH_Skeletons_Human_01_BO'
   //SoundGroupClass=Class'RBTTInvasion.ScarySkullSoundGroup'

   Name="AePhoenixFamilyInfo"
   ObjectArchetype=UTFamilyInfo'UTGame.Default__UTFamilyInfo'
}
