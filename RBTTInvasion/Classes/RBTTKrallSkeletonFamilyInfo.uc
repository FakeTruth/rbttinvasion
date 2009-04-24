/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */

class RBTTKrallSkeletonFamilyInfo extends UTFamilyInfo
	abstract;



//okie here we need to add new UTGib_HumanAccessories  which will have shoulder pads and other such sweet things

defaultproperties
{
   FamilyID="KrallSkeleton"
   Faction="RBTTMonster"
   PhysAsset=PhysicsAsset'CH_AnimKrall.Mesh.SK_CH_AnimKrall_Male01_Physics'
   MasterSkeleton=SkeletalMesh'CH_Skeletons.Mesh.SK_CH_Skeleton_Krall_Male'

   DeathMeshSkelMesh=SkeletalMesh'CH_Skeletons.Mesh.SK_CH_Skeleton_Krall_Male'
   DeathMeshPhysAsset=PhysicsAsset'CH_AnimKrall.Mesh.SK_CH_AnimKrall_Male01_Physics'
   DeathMeshNumMaterialsToSetResident=1
   SkeletonBurnOutMaterials(0)=MaterialInstanceTimeVarying'CH_Skeletons.Materials.MITV_CH_Skeletons_Human_01_BO'

	HeadGib=(BoneName=b_Head,GibClass=class'UTGib_KrallHead',bHighDetailOnly=false)
	Gibs[0]=(BoneName=b_LeftForeArm,GibClass=class'UTGib_KrallArm',bHighDetailOnly=false)
	Gibs[1]=(BoneName=b_RightForeArm,GibClass=class'UTGib_KrallHand',bHighDetailOnly=true)
	Gibs[2]=(BoneName=b_LeftLeg,GibClass=class'UTGib_KrallLeg',bHighDetailOnly=false)
	Gibs[3]=(BoneName=b_RightLeg,GibClass=class'UTGib_KrallLeg',bHighDetailOnly=false)
	Gibs[4]=(BoneName=b_Spine,GibClass=class'UTGib_KrallTorso',bHighDetailOnly=false)
	Gibs[5]=(BoneName=b_RightClav,GibClass=class'UTGib_KrallBone',bHighDetailOnly=false)

   Name="Default__RBTTKrallSkeletonFamilyInfo"
   ObjectArchetype=UTFamilyInfo'UTGame.Default__UTFamilyInfo'

	LeftFootBone=b_LeftFoot
	RightFootBone=b_RightFoot
	TakeHitPhysicsFixedBones[0]=b_LeftFoot
	TakeHitPhysicsFixedBones[1]=b_RightFoot
}
