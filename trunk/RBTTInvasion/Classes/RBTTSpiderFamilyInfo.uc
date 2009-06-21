/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */

class RBTTSpiderFamilyInfo extends UTFamilyInfo
	abstract;



//okie here we need to add new UTGib_HumanAccessories  which will have shoulder pads and other such sweet things

defaultproperties
{	
	FamilyID="Spider"
	Faction="RBTTMonster"
	LeftFootBone=L_FrontFoot //b_LeftAnkle
	RightFootBone=R_FrontFoot //b_RightAnkle
	TakeHitPhysicsFixedBones[0]=L_FrontFoot //b_LeftAnkle 
	TakeHitPhysicsFixedBones[1]=R_FrontFoot //b_RightAnkle
	DefaultMeshScale=4.000000
   DeathMeshSkelMesh=SkeletalMesh'RBTTSpiderPackage.Mesh.Spider'
   DeathMeshPhysAsset=PhysicsAsset'RBTTSpiderPackage.Mesh.Spider_Physics'
   PhysAsset=PhysicsAsset'RBTTSpiderPackage.Mesh.Spider_Physics'
   DeathMeshNumMaterialsToSetResident=1
   SkeletonBurnOutMaterials(0)=MaterialInstanceTimeVarying'CH_Skeletons.Materials.MITV_CH_Skeletons_Human_01_BO'
   Name="Default__RBTTSpiderFamilyInfo"
   ObjectArchetype=UTFamilyInfo'UTGame.Default__UTFamilyInfo'
}
