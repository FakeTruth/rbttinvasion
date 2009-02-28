/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 * This object is used as a store for all custom character part and profile information.
 */
class RBTTCustomMonster_Data extends UTCustomChar_Data
	
	config(RBTTCustomMonster_Data);
	

defaultproperties
{
   Parts(0)=(ObjectName="SkullCrabPKG2.SkullCrabA",FamilyID="SkullCrab")
   Parts(1)=(ObjectName="CH_Skeletons.Mesh.SK_CH_Skeleton_Human_Male",FamilyID="HumanSkeleton")
   Parts(2)=(ObjectName="CH_Skeletons.Mesh.SK_CH_Skeleton_Krall_Male",FamilyID="KrallSkeleton")
   Parts(3)=(ObjectName="CH_MiningBot.Mesh.SK_CH_MiningBot",FamilyID="MiningRobot")
   Parts(4)=(ObjectName="WeldingRobot.Mesh.SK_CH_WeldingRobot",FamilyID="WeldingRobot")
   Parts(5)=(ObjectName="RBTTSpiderPackage.Mesh.Spider",FamilyID="Spider")
   Parts(6)=(ObjectName="RBTTScarySkull.ScarySkull",FamilyID="ScarySkull")
   
   Characters(0)=(CharName="SkullCrab",Faction="RBTTMonster",CharData=(FamilyID="SkullCrab",TorsoID=,ShoPadID=,bHasLeftShoPad=False,bHasRightShoPad=False,ArmsID=,ThighsID=,BootsID=))
   Characters(1)=(CharName="HumanSkeleton",Faction="RBTTMonster",CharData=(FamilyID="HumanSkeleton",TorsoID=,ShoPadID=,bHasLeftShoPad=False,bHasRightShoPad=False,ArmsID=,ThighsID=,BootsID=),AIData=(StrafingAbility=1.000000,Accuracy=0.500000,Aggressiveness=0.400000,CombatStyle=0.500000,FavoriteWeapon="UTGame.UTWeap_RocketLauncher"))
   Characters(2)=(CharName="KrallSkeleton",Faction="RBTTMonster",CharData=(FamilyID="KrallSkeleton",TorsoID=,ShoPadID=,bHasLeftShoPad=False,bHasRightShoPad=False,ArmsID=,ThighsID=,BootsID=),AIData=(StrafingAbility=1.000000,Accuracy=0.500000,Aggressiveness=0.400000,CombatStyle=0.500000,FavoriteWeapon="UTGame.UTWeap_RocketLauncher"))
   Characters(3)=(CharName="MiningRobot",Faction="RBTTMonster",CharData=(FamilyID="MiningRobot",TorsoID=,ShoPadID=,bHasLeftShoPad=False,bHasRightShoPad=False,ArmsID=,ThighsID=,BootsID=),AIData=(Tactics=0.300000,Aggressiveness=0.600000,CombatStyle=0.300000,FavoriteWeapon="UTGame.UTWeap_Stinger"))
   Characters(4)=(CharName="MiningWelding",Faction="RBTTMonster",CharData=(FamilyID="WeldingRobot",TorsoID=,ShoPadID=,bHasLeftShoPad=False,bHasRightShoPad=False,ArmsID=,ThighsID=,BootsID=))
   Characters(5)=(CharName="Spider",Faction="RBTTMonster",CharData=(FamilyID="Spider",TorsoID=,ShoPadID=,bHasLeftShoPad=False,bHasRightShoPad=False,ArmsID=,ThighsID=,BootsID=),AIData=(StrafingAbility=0.000000,Accuracy=0.500000,Aggressiveness=1.00000,CombatStyle=0.900000,FavoriteWeapon="RBTTInvasion.RBTTSpider_Weapon"))
   Characters(6)=(CharName="ScarySkull",Faction="RBTTMonster",CharData=(FamilyID="ScarySkull",TorsoID=,ShoPadID=,bHasLeftShoPad=False,bHasRightShoPad=False,ArmsID=,ThighsID=,BootsID=),AIData=(StrafingAbility=0.000000,Accuracy=0.500000,Aggressiveness=1.00000,CombatStyle=0.900000,FavoriteWeapon="RBTTInvasion.RBTTSpider_Weapon"))


	Factions(0)=(Faction="RBTTMonster")
	
   Families(0)=Class'RBTTInvasion.RBTTMonsterFamilyInfo'
   Families(1)=class'RBTTInvasion.RBTTHumanSkeletonFamilyInfo'
   Families(2)=class'RBTTInvasion.RBTTKrallSkeletonFamilyInfo'
   Families(3)=class'RBTTInvasion.RBTTMiningRobotFamilyInfo'
   Families(4)=class'RBTTInvasion.RBTTWeldingRobotFamilyInfo'
   Families(5)=class'RBTTInvasion.RBTTSpiderFamilyInfo'
   Families(6)=class'RBTTInvasion.RBTTScarySkullFamilyInfo'

   Name="Default__RBTTCustomMonster_Data"

}
