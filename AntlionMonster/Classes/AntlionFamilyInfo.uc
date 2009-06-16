/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */

class AntlionFamilyInfo extends UTFamilyInfo
	abstract;



//okie here we need to add new UTGib_HumanAccessories  which will have shoulder pads and other such sweet things

defaultproperties
{
	LeftFootBone="Antlion.LegR3_Bone" //b_LeftAnkle
	RightFootBone="Antlion.LegL3_Bone" //b_RightAnkle
	TakeHitPhysicsFixedBones[0]="Antlion.LegR3_Bone" //b_LeftAnkle
	TakeHitPhysicsFixedBones[1]="Antlion.LegL3_Bone" //b_RightAnkle

	HeadGib=(BoneName="Antlion.Head_Bone",GibClass=class'UTGib_KrallHead',bHighDetailOnly=false)
	Gibs[0]=(BoneName="Antlion.LegL3_Bone",GibClass=class'UTGib_KrallArm',bHighDetailOnly=false)
	Gibs[1]=(BoneName="Antlion.LegR3_Bone",GibClass=class'UTGib_KrallHand',bHighDetailOnly=true)
	Gibs[2]=(BoneName="Antlion.LegMidL3_Bone",GibClass=class'UTGib_KrallLeg',bHighDetailOnly=false)
	Gibs[3]=(BoneName="Antlion.LegMidR3_Bone",GibClass=class'UTGib_KrallLeg',bHighDetailOnly=false)
	Gibs[4]=(BoneName="Antlion.Chest_Bone",GibClass=class'UTGib_KrallTorso',bHighDetailOnly=false)
	Gibs[5]=(BoneName="Antlion.Chest_Bone",GibClass=class'UTGib_KrallBone',bHighDetailOnly=false)
	
   DeathMeshSkelMesh=SkeletalMesh'AntlionContent.antlion'
   DeathMeshPhysAsset=PhysicsAsset'AntlionContent.antlion_Physics'
   PhysAsset=PhysicsAsset'AntlionContent.antlion_Physics'   
   DeathMeshNumMaterialsToSetResident=1
   SkeletonBurnOutMaterials(0)=MaterialInstanceTimeVarying'CH_Skeletons.Materials.MITV_CH_Skeletons_Human_01_BO'
   
   Name="Default__AntlionFamilyInfo"
   ObjectArchetype=UTFamilyInfo'UTGame.Default__UTFamilyInfo'
}
