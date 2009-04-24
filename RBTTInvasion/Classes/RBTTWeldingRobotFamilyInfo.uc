/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */

class RBTTWeldingRobotFamilyInfo extends UTFamilyInfo
	abstract;



//okie here we need to add new UTGib_HumanAccessories  which will have shoulder pads and other such sweet things

defaultproperties
{
   FamilyID="WeldingRobot"
   Faction="RBTTMonster"
   PhysAsset=PhysicsAsset'CH_Skeletons.Mesh.SK_CH_Skeleton_Human_Male_Physics'
   Gibs(0)=(BoneName="b_LeftForeArm",GibClass=Class'UTGame.UTGib_HumanArm')
   Gibs(1)=(BoneName="b_RightForeArm",GibClass=Class'UTGame.UTGib_HumanArm',bHighDetailOnly=True)
   Gibs(2)=(BoneName="b_LeftLeg",GibClass=Class'UTGame.UTGib_HumanChunk')
   Gibs(3)=(BoneName="b_RightLeg",GibClass=Class'UTGame.UTGib_HumanChunk',bHighDetailOnly=True)
   Gibs(4)=(BoneName="b_Spine",GibClass=Class'UTGame.UTGib_HumanTorso')
   Gibs(5)=(BoneName="b_Spine1",GibClass=Class'UTGame.UTGib_HumanChunk')
   Gibs(6)=(BoneName="b_Spine2",GibClass=Class'UTGame.UTGib_HumanBone')
   Gibs(7)=(BoneName="b_LeftLegUpper",GibClass=Class'UTGame.UTGib_HumanChunk',bHighDetailOnly=True)
   Gibs(8)=(BoneName="b_RightLegUpper",GibClass=Class'UTGame.UTGib_HumanChunk',bHighDetailOnly=True)
   HeadGib=(BoneName="b_Head",GibClass=Class'UTGame.UTGib_HumanHead')
   DeathMeshPhysAsset=PhysicsAsset'CH_Skeletons.Mesh.SK_CH_Skeleton_Human_Male_Physics'
   DeathMeshNumMaterialsToSetResident=1
   DeathMeshBreakableJoints(0)="b_LeftArm"
   DeathMeshBreakableJoints(1)="b_RightArm"
   DeathMeshBreakableJoints(2)="b_LeftLegUpper"
   DeathMeshBreakableJoints(3)="b_RightLegUpper"
   SkeletonBurnOutMaterials(0)=MaterialInstanceTimeVarying'CH_Skeletons.Materials.MITV_CH_Skeletons_Human_01_BO'
   Name="Default__RBTTWeldingRobotFamilyInfo"
   ObjectArchetype=UTFamilyInfo'UTGame.Default__UTFamilyInfo'
}
