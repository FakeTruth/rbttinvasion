/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */

class RBTTGasBagFamilyInfo extends UTFamilyInfo
	abstract;



//okie here we need to add new UTGib_HumanAccessories  which will have shoulder pads and other such sweet things

defaultproperties
{
   FamilyID="GasBag"
   Faction="RBTTMonster"
   MasterSkeleton=SkeletalMesh'GasBag.GasBag'
   PhysAsset=PhysicsAsset'GasBag.GasBag_Physics'

   //DeathMeshSkelMesh=SkeletalMesh'CH_MiningBot.Mesh.SK_CH_MiningBot'
   DeathMeshSkelMesh=SkeletalMesh'GasBag.GasBag'
   DeathMeshPhysAsset=PhysicsAsset'GasBag.GasBag_Physics'
   DeathMeshNumMaterialsToSetResident=1
   SkeletonBurnOutMaterials(0)=MaterialInstanceTimeVarying'CH_Skeletons.Materials.MITV_CH_Skeletons_Human_01_BO'

	HeadShotEffect=ParticleSystem'T_FX.Effects.P_FX_HeadShot_Corrupt'
	BloodSplatterDecalMaterial=MaterialInstanceTimeVarying'T_FX.DecalMaterials.MITV_FX_OilDecal_Small01'

	Gibs[0]=(BoneName=Root,GibClass=class'UTGib_RobotArm',bHighDetailOnly=false)
	Gibs[1]=(BoneName=Root,GibClass=class'UTGib_RobotHand',bHighDetailOnly=true)
	Gibs[2]=(BoneName=Root,GibClass=class'UTGib_RobotLeg',bHighDetailOnly=false)
	Gibs[3]=(BoneName=Root,GibClass=class'UTGib_RobotLeg',bHighDetailOnly=false)
	Gibs[4]=(BoneName=Root,GibClass=class'UTGib_RobotTorso',bHighDetailOnly=false)
	Gibs[5]=(BoneName=Root,GibClass=class'UTGib_RobotChunk',bHighDetailOnly=true)
	Gibs[6]=(BoneName=Root,GibClass=class'UTGib_RobotChunk',bHighDetailOnly=true)
	Gibs[7]=(BoneName=Root,GibClass=class'UTGib_RobotChunk',bHighDetailOnly=true)
	Gibs[8]=(BoneName=Root,GibClass=class'UTGib_RobotArm',bHighDetailOnly=true)

	BloodEffects[0]=(Template=ParticleSystem'T_FX.Effects.P_FX_Bloodhit_Corrupt_Far',MinDistance=750.0)
	BloodEffects[1]=(Template=ParticleSystem'T_FX.Effects.P_FX_Bloodhit_Corrupt_Mid',MinDistance=350.0)
	BloodEffects[2]=(Template=ParticleSystem'T_FX.Effects.P_FX_Bloodhit_Corrupt_Near',MinDistance=0.0)


   Name="Default__RBTTGasBagFamilyInfo"
   ObjectArchetype=UTFamilyInfo'UTGame.Default__UTFamilyInfo'
}
