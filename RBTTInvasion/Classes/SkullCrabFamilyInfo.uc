/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */

class SkullCrabFamilyInfo extends UTFamilyInfo
	abstract;



//okie here we need to add new UTGib_HumanAccessories  which will have shoulder pads and other such sweet things

defaultproperties
{
	LeftFootBone=L_FrontFoot //b_LeftAnkle
	RightFootBone=R_FrontFoot //b_RightAnkle
	TakeHitPhysicsFixedBones[0]=L_FrontFoot //b_LeftAnkle
	TakeHitPhysicsFixedBones[1]=R_FrontFoot //b_RightAnkle

   DeathMeshSkelMesh=SkeletalMesh'SkullCrabPKG2.SkullCrabA'
   DeathMeshPhysAsset=PhysicsAsset'SkullCrabPKG2.SkullCrabA_Physics'
   DeathMeshNumMaterialsToSetResident=1
   SkeletonBurnOutMaterials(0)=MaterialInstanceTimeVarying'CH_Skeletons.Materials.MITV_CH_Skeletons_Human_01_BO'
   Name="Default__SkullCrabFamilyInfo"
   ObjectArchetype=UTFamilyInfo'UTGame.Default__UTFamilyInfo'
}
