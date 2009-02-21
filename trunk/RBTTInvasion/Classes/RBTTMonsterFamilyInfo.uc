/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */

class RBTTMonsterFamilyInfo extends UTFamilyInfo
	abstract;



//okie here we need to add new UTGib_HumanAccessories  which will have shoulder pads and other such sweet things

defaultproperties
{
   FamilyID="SkullCrab"
   Faction="RBTTMonster"
   PhysAsset=PhysicsAsset'SkullCrabPKG2.SkullCrabA_Physics'
   AnimSets(0)=AnimSet'SkullCrabPKG2.SkullCrabAnims'
   TakeHitPhysicsFixedBones(0)="b_Root"
   TakeHitPhysicsFixedBones(1)="Spine"
   TakeHitPhysicsFixedBones(2)="Spine1"
   TakeHitPhysicsFixedBones(3)="head"
   TakeHitPhysicsFixedBones(4)="HeadTop"
   TakeHitPhysicsFixedBones(5)="jaw"
   TakeHitPhysicsFixedBones(6)="joint2"
   TakeHitPhysicsFixedBones(7)="R_FrontKnee"
   TakeHitPhysicsFixedBones(8)="joint1"
   TakeHitPhysicsFixedBones(9)="R_BackKnee"
   TakeHitPhysicsFixedBones(10)="joint4"
   TakeHitPhysicsFixedBones(11)="L_BackKnee"
   TakeHitPhysicsFixedBones(12)="joint3"
   TakeHitPhysicsFixedBones(13)="L_BackKnee"
   MasterSkeleton=SkeletalMesh'SkullCrabPKG2.SkullCrabA'
   DeathMeshSkelMesh=SkeletalMesh'SkullCrabPKG2.SkullCrabA'
   DeathMeshPhysAsset=PhysicsAsset'SkullCrabPKG2.SkullCrabA_Physics'
   DefaultMeshScale=4.000000
   Name="Default__RBTTMonsterFamilyInfo"
   ObjectArchetype=UTFamilyInfo'UTGame.Default__UTFamilyInfo'
}
