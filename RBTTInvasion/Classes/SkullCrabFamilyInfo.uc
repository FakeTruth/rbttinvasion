/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */

class SkullCrabFamilyInfo extends UTFamilyInfo
	abstract;



//okie here we need to add new UTGib_HumanAccessories  which will have shoulder pads and other such sweet things

defaultproperties
{
   LeftFootBone="L_FrontFoot"
   RightFootBone="R_FrontFoot"
   TakeHitPhysicsFixedBones(0)="L_FrontFoot"
   TakeHitPhysicsFixedBones(1)="R_FrontFoot"
   DeathMeshNumMaterialsToSetResident=1
   SkeletonBurnOutMaterials(0)=MaterialInstanceTimeVarying'CH_Skeletons.Materials.MITV_CH_Skeletons_Human_01_BO'
   Name="Default__SkullCrabFamilyInfo"
   ObjectArchetype=UTFamilyInfo'UTGame.Default__UTFamilyInfo'
}
