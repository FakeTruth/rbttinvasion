/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 * This object is used as a store for all custom character part and profile information.
 */
class RBTTCustomMonster_Data extends UTCustomChar_Data
	
	config(RBTTInvasion);
	

defaultproperties
{
   Parts(0)=(Part=PART_Head,ObjectName="SkullCrabPKG2.SkullCrabA",PartID="SkullCrab",FamilyID="SkullCrab")
   Parts(1)=(Part=PART_Head,ObjectName="CH_Skeletons.Mesh.SK_CH_Skeleton_Human_Male",PartID="HumanSkeleton",FamilyID="HumanSkeleton")
   Parts(2)=(Part=PART_Head,ObjectName="CH_Skeletons.Mesh.SK_CH_Skeleton_Krall_Male",PartID="KrallSkeleton",FamilyID="KrallSkeleton")
   Parts(3)=(Part=PART_Head,ObjectName="CH_MiningBot.Mesh.SK_CH_MiningBot",PartID="MiningRobot",FamilyID="MiningRobot")
   Parts(4)=(Part=PART_Head,ObjectName="WeldingRobot.Mesh.SK_CH_WeldingRobot",PartID="WeldingRobot",FamilyID="WeldingRobot")
   Parts(5)=(Part=PART_Head,ObjectName="RBTTSpiderPackage.Mesh.Spider",PartID="Spider",FamilyID="Spider")
   Parts(6)=(Part=PART_Head,ObjectName="RBTTScarySkull.ScarySkull",PartID="ScarySkull",FamilyID="ScarySkull")
   Parts(7)=(Part=PART_Head,ObjectName="RBTTSlime.RBTTSlime",PartID="Slime",FamilyID="Slime")
   
   Characters(0)=(CharName="SkullCrab",Faction="RBTTMonster",CharData=(FamilyID="SkullCrab",TorsoID=,ShoPadID=,bHasLeftShoPad=False,bHasRightShoPad=False,ArmsID=,ThighsID=,BootsID=))
   Characters(1)=(CharName="HumanSkeleton",Faction="RBTTMonster",CharData=(FamilyID="HumanSkeleton",TorsoID=,ShoPadID=,bHasLeftShoPad=False,bHasRightShoPad=False,ArmsID=,ThighsID=,BootsID=),AIData=(StrafingAbility=1.000000,Accuracy=0.500000,Aggressiveness=0.400000,CombatStyle=0.500000,FavoriteWeapon="UTGame.UTWeap_RocketLauncher"))
   Characters(2)=(CharName="KrallSkeleton",Faction="RBTTMonster",CharData=(FamilyID="KrallSkeleton",TorsoID=,ShoPadID=,bHasLeftShoPad=False,bHasRightShoPad=False,ArmsID=,ThighsID=,BootsID=),AIData=(StrafingAbility=1.000000,Accuracy=0.500000,Aggressiveness=0.400000,CombatStyle=0.500000,FavoriteWeapon="UTGame.UTWeap_RocketLauncher"))
   Characters(3)=(CharName="MiningRobot",Faction="RBTTMonster",CharData=(FamilyID="MiningRobot",TorsoID=,ShoPadID=,bHasLeftShoPad=False,bHasRightShoPad=False,ArmsID=,ThighsID=,BootsID=),AIData=(Tactics=0.300000,Aggressiveness=0.600000,CombatStyle=0.300000,FavoriteWeapon="UTGame.UTWeap_Stinger"))
   Characters(4)=(CharName="MiningWelding",Faction="RBTTMonster",CharData=(FamilyID="WeldingRobot",TorsoID=,ShoPadID=,bHasLeftShoPad=False,bHasRightShoPad=False,ArmsID=,ThighsID=,BootsID=))
   Characters(5)=(CharName="Spider",Faction="RBTTMonster",CharData=(FamilyID="Spider",TorsoID=,ShoPadID=,bHasLeftShoPad=False,bHasRightShoPad=False,ArmsID=,ThighsID=,BootsID=),AIData=(StrafingAbility=0.000000,Accuracy=0.500000,Aggressiveness=1.00000,CombatStyle=0.900000,FavoriteWeapon="RBTTInvasion.RBTTSpider_Weapon"))
   Characters(6)=(CharName="ScarySkull",Faction="RBTTMonster",CharData=(FamilyID="ScarySkull",TorsoID=,ShoPadID=,bHasLeftShoPad=False,bHasRightShoPad=False,ArmsID=,ThighsID=,BootsID=),AIData=(StrafingAbility=0.000000,Accuracy=0.500000,Aggressiveness=1.00000,CombatStyle=0.900000,FavoriteWeapon="RBTTInvasion.RBTTSpider_Weapon"))
   Characters(7)=(CharName="Slime",CharID="S",Faction="RBTTMonster",CharData=(FamilyID="Slime",HeadID="Slime"),AIData=(StrafingAbility=0.000000,Accuracy=0.500000,Aggressiveness=1.00000,CombatStyle=0.900000,FavoriteWeapon="RBTTInvasion.RBTTSpider_Weapon"))
   Characters(8)=(CharName="FireSlime",CharID="FS",Faction="RBTTMonster",CharData=(FamilyID="Slime",HeadID="Slime"),AIData=(StrafingAbility=0.000000,Accuracy=0.500000,Aggressiveness=1.00000,CombatStyle=0.900000,FavoriteWeapon="RBTTInvasion.RBTTSpider_Weapon"))
   Characters(9)=(CharName="IceSlime",CharID="IS",Faction="RBTTMonster",CharData=(FamilyID="Slime",HeadID="Slime"),AIData=(StrafingAbility=0.000000,Accuracy=0.500000,Aggressiveness=1.00000,CombatStyle=0.900000,FavoriteWeapon="RBTTInvasion.RBTTSpider_Weapon"))
	

	Factions(0)=(Faction="RBTTMonster")
	
   ModFamilies(0)=Class'RBTTInvasion.RBTTMonsterFamilyInfo'
   ModFamilies(1)=class'RBTTInvasion.RBTTHumanSkeletonFamilyInfo'
   ModFamilies(2)=class'RBTTInvasion.RBTTKrallSkeletonFamilyInfo'
   ModFamilies(3)=class'RBTTInvasion.RBTTMiningRobotFamilyInfo'
   ModFamilies(4)=class'RBTTInvasion.RBTTWeldingRobotFamilyInfo'
   ModFamilies(5)=class'RBTTInvasion.RBTTSpiderFamilyInfo'
   ModFamilies(6)=class'RBTTInvasion.RBTTScarySkullFamilyInfo'
   ModFamilies(7)=class'RBTTInvasion.RBTTSlimeFamilyInfo'

   
   
   Name="Default__RBTTCustomMonster_Data"

}
