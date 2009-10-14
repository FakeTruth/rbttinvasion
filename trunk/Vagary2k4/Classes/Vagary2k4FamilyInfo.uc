/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */

class Vagary2k4FamilyInfo extends UTFamilyInfo;



//okie here we need to add new UTGib_HumanAccessories  which will have shoulder pads and other such sweet things

defaultproperties
{

   FamilyID="Vagary2k4"
   Faction="RBTTMonster"
   PhysAsset=PhysicsAsset'Vagary2k4.vagarymesh_Physics'
   MasterSkeleton=SkeletalMesh'Vagary2k4.vagarymesh'
   AnimSets(0)=AnimSet'CH_AnimHuman.Anims.K_AnimHuman_BaseMale'

   //DeathMeshSkelMesh=SkeletalMesh'CH_Skeletons.Mesh.SK_CH_Skeleton_Human_Male'
   DeathMeshSkelMesh=SkeletalMesh'Vagary2k4.vagarymesh'
   DeathMeshPhysAsset=PhysicsAsset'Vagary2k4.vagarymesh_Physics'
   DeathMeshNumMaterialsToSetResident=1
   SkeletonBurnOutMaterials(0)=MaterialInstanceTimeVarying'CH_Skeletons.Materials.MITV_CH_Skeletons_Human_01_BO'

	DeathMeshBreakableJoints=("b_LeftArm","b_RightArm","b_LeftLegUpper","b_RightLegUpper")
	
	FamilyEmotes[19]=(CategoryName="SpecialMove",EmoteTag="ThrowPlasma",EmoteAnim="hoverboardjumpland",bTopHalfEmote=true)

   Name="Default__RBTTHumanSkeletonFamilyInfo"
   ObjectArchetype=UTFamilyInfo'UTGame.Default__UTFamilyInfo'
}
