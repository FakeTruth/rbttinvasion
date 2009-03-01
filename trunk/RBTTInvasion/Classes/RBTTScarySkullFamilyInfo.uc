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

	//DeathMeshBreakableJoints=("b_LeftArm","b_RightArm","b_LeftLegUpper","b_RightLegUpper")
	HeadGib=(BoneName=b_Head,GibClass=class'UTGib_HumanHead',bHighDetailOnly=false)
	Gibs[0]=(BoneName=b_LeftForeArm,GibClass=class'UTGib_HumanArm',bHighDetailOnly=false)
 	Gibs[1]=(BoneName=b_RightForeArm,GibClass=class'UTGib_HumanArm',bHighDetailOnly=true)
 	Gibs[2]=(BoneName=b_LeftLeg,GibClass=class'UTGib_HumanChunk',bHighDetailOnly=false)
 	Gibs[3]=(BoneName=b_RightLeg,GibClass=class'UTGib_HumanChunk',bHighDetailOnly=true)
 	Gibs[4]=(BoneName=b_Spine,GibClass=class'UTGib_HumanTorso',bHighDetailOnly=false)
 	Gibs[5]=(BoneName=b_Spine1,GibClass=class'UTGib_HumanChunk',bHighDetailOnly=false)
 	Gibs[6]=(BoneName=b_Spine2,GibClass=class'UTGib_HumanBone',bHighDetailOnly=false)
 	Gibs[7]=(BoneName=b_LeftLegUpper,GibClass=class'UTGib_HumanChunk',bHighDetailOnly=true)
 	Gibs[8]=(BoneName=b_RightLegUpper,GibClass=class'UTGib_HumanChunk',bHighDetailOnly=true)

   Name="Default__RBTTScarySkullFamilyInfo"
   ObjectArchetype=UTFamilyInfo'UTGame.Default__UTFamilyInfo'
}