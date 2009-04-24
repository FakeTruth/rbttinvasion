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
   LeftFootBone="b_LeftFoot"
   RightFootBone="b_RightFoot"
   TakeHitPhysicsFixedBones(0)="b_LeftFoot"
   TakeHitPhysicsFixedBones(1)="b_RightFoot"
   MasterSkeleton=SkeletalMesh'CH_Skeletons.Mesh.SK_CH_Skeleton_Krall_Male'
   Gibs(0)=(BoneName="b_LeftForeArm",GibClass=Class'UTGame.UTGib_KrallArm')
   Gibs(1)=(BoneName="b_RightForeArm",GibClass=Class'UTGame.UTGib_KrallHand',bHighDetailOnly=True)
   Gibs(2)=(BoneName="b_LeftLeg",GibClass=Class'UTGame.UTGib_KrallLeg')
   Gibs(3)=(BoneName="b_RightLeg",GibClass=Class'UTGame.UTGib_KrallLeg')
   Gibs(4)=(BoneName="b_Spine",GibClass=Class'UTGame.UTGib_KrallTorso')
   Gibs(5)=(BoneName="b_RightClav",GibClass=Class'UTGame.UTGib_KrallBone')
   HeadGib=(BoneName="b_Head",GibClass=Class'UTGame.UTGib_KrallHead')
   DeathMeshSkelMesh=SkeletalMesh'CH_Skeletons.Mesh.SK_CH_Skeleton_Krall_Male'
   DeathMeshPhysAsset=PhysicsAsset'CH_AnimKrall.Mesh.SK_CH_AnimKrall_Male01_Physics'
   DeathMeshNumMaterialsToSetResident=1
   SkeletonBurnOutMaterials(0)=MaterialInstanceTimeVarying'CH_Skeletons.Materials.MITV_CH_Skeletons_Human_01_BO'
   Name="Default__RBTTKrallSkeletonFamilyInfo"
   ObjectArchetype=UTFamilyInfo'UTGame.Default__UTFamilyInfo'
}
