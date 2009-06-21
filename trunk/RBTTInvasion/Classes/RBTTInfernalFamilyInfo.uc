/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */

class RBTTInfernalFamilyInfo extends UTFamilyInfo;



//okie here we need to add new UTGib_HumanAccessories  which will have shoulder pads and other such sweet things

defaultproperties
{

   FamilyID="RBTTInfernal"
   Faction="RBTTMonster"
   PhysAsset=PhysicsAsset'CH_Skeletons.Mesh.SK_CH_Skeleton_Human_Male_Physics'
   MasterSkeleton=SkeletalMesh'CH_Skeletons.Mesh.SK_CH_Skeleton_Human_Male'
   AnimSets(0)=AnimSet'CH_AnimHuman.Anims.K_AnimHuman_BaseMale'

   //DeathMeshSkelMesh=SkeletalMesh'CH_Skeletons.Mesh.SK_CH_Skeleton_Human_Male'
   DeathMeshSkelMesh=SkeletalMesh'RBTTInfernal.Infernal'
   DeathMeshPhysAsset=PhysicsAsset'CH_Skeletons.Mesh.SK_CH_Skeleton_Human_Male_Physics'
   DeathMeshNumMaterialsToSetResident=1
   //SkeletonBurnOutMaterials(0)=MaterialInstanceTimeVarying'CH_Skeletons.Materials.MITV_CH_Skeletons_Human_01_BO'
   SkeletonBurnOutMaterials(0)=MaterialInstanceTimeVarying'RBTTInfernal.Infernal_MITV'

	DeathMeshBreakableJoints=("b_LeftArm","b_RightArm","b_LeftLegUpper","b_RightLegUpper")
	
	FamilyEmotes[19]=(CategoryName="SpecialMove",EmoteTag="ThrowPlasma",EmoteAnim="hoverboardjumpland",bTopHalfEmote=true)

   Name="Default__RBTTHumanSkeletonFamilyInfo"
   ObjectArchetype=UTFamilyInfo'UTGame.Default__UTFamilyInfo'
}
