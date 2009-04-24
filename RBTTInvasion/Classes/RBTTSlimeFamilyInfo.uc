/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */

class RBTTSlimeFamilyInfo extends UTFamilyInfo
	abstract;



//okie here we need to add new UTGib_HumanAccessories  which will have shoulder pads and other such sweet things

defaultproperties
{
   LeftFootBone="L_FrontFoot"
   RightFootBone="R_FrontFoot"
   TakeHitPhysicsFixedBones(0)="L_FrontFoot"
   TakeHitPhysicsFixedBones(1)="R_FrontFoot"
   SoundGroupClass=Class'RBTTInvasion.RBTTSlimeSoundGroup'
   DeathMeshNumMaterialsToSetResident=1
   SkeletonBurnOutMaterials(0)=MaterialInstanceTimeVarying'CH_Skeletons.Materials.MITV_CH_Skeletons_Human_01_BO'
   DefaultMeshScale=4.000000
   Name="Default__RBTTSlimeFamilyInfo"
   ObjectArchetype=UTFamilyInfo'UTGame.Default__UTFamilyInfo'
}
