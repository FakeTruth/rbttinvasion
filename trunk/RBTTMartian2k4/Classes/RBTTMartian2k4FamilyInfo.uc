/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */

class RBTTMartian2k4FamilyInfo extends UTFamilyInfo
	abstract;



//okie here we need to add new UTGib_HumanAccessories  which will have shoulder pads and other such sweet things

defaultproperties
{

   FamilyID="Martian"
   Faction="RBTTMonster"
   PhysAsset=PhysicsAsset'Martian2k4.MartianMeshRedMartianHeadSkeleton_Physics'
   MasterSkeleton=SkeletalMesh'Martian2k4.MartianMeshRedMartianHeadSkeleton'

   DeathMeshSkelMesh=SkeletalMesh'Martian2k4.MartianMeshRedMartianHeadSkeleton'
   DeathMeshPhysAsset=PhysicsAsset'Martian2k4.MartianMeshRedMartianHeadSkeleton_Physics'
   DeathMeshNumMaterialsToSetResident=1
   SkeletonBurnOutMaterials(0)=MaterialInstanceTimeVarying'CH_Skeletons.Materials.MITV_CH_Skeletons_Human_01_BO'
   SoundGroupClass=Class'RBTTMartian2k4.Martian2k4SoundGroup'
   
        DeathMeshBreakableJoints=("Bip01-L-Forearm","Bip01-R-Forearm","Bip01-L-Thigh","Bip01-R-Thigh")
	HeadGib=(BoneName=b_Head,GibClass=class'UTGib_HumanHead',bHighDetailOnly=false)
	Gibs[0]=(BoneName=Bip01-L-Forearm,GibClass=class'UTGib_HumanArm',bHighDetailOnly=false)
 	Gibs[1]=(BoneName=Bip01-R-Forearm,GibClass=class'UTGib_HumanArm',bHighDetailOnly=true)
 	Gibs[2]=(BoneName=Bip01-L-Thigh,GibClass=class'UTGib_HumanChunk',bHighDetailOnly=false)
 	Gibs[3]=(BoneName=Bip01-R-Thigh,GibClass=class'UTGib_HumanChunk',bHighDetailOnly=true)
 	Gibs[4]=(BoneName=b_Spine,GibClass=class'UTGib_HumanTorso',bHighDetailOnly=false)
 	Gibs[5]=(BoneName=b_Spine1,GibClass=class'UTGib_HumanChunk',bHighDetailOnly=false)
 	Gibs[6]=(BoneName=b_Spine2,GibClass=class'UTGib_HumanBone',bHighDetailOnly=false)
 	Gibs[7]=(BoneName=b_LeftLegUpper,GibClass=class'UTGib_HumanChunk',bHighDetailOnly=true)
 	Gibs[8]=(BoneName=b_RightLegUpper,GibClass=class'UTGib_HumanChunk',bHighDetailOnly=true)


   Name="Default__RBTTMartianFamilyInfo"
   ObjectArchetype=UTFamilyInfo'UTGame.Default__UTFamilyInfo'
}
