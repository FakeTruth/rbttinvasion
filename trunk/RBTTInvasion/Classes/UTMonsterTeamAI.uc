/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */
//=============================================================================
// UTTeamAI.
// strategic team AI control for TeamGame
//
//=============================================================================
class UTMonsterTeamAI extends UTTeamAI;

defaultproperties
{
   SquadType=Class'RBTTMonsterSquadAI'
   OrderList(0)="Follow"
   OrderList(1)="ATTACK"
   OrderList(2)="Defend"
   OrderList(3)="Freelance"
   OrderList(4)="Follow"
   OrderList(5)="ATTACK"
   OrderList(6)="Defend"
   OrderList(7)="Freelance"
   CollisionType=COLLIDE_CustomDefault
   Name="Default__RBTTMonsterTeamAI"
   ObjectArchetype=Info'Engine.Default__Info'
}
