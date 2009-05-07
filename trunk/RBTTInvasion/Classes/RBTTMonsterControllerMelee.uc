Class RBTTMonsterControllerMelee Extends RBTTMonsterController;

var string VeryOldGoalString;

//function FightEnemy(bool bCanCharge, float EnemyStrength);

function name GetOrders()
{
		return 'Attack'; // Attack! Be more agressive yo!
}

/*
simulated function Tick( float DeltaTime )
{
	if(VeryOldGoalString == GoalString)
		return;

	VeryOldGoalString = GoalString;
	`log(GoalString);
}
*/


/* ChooseAttackMode()
Handles tactical attacking state selection - choose which type of attack to do from here
*/
function ChooseAttackMode()
{
	GoalString = "ChooseAttackMode FightEnemy";
	FightEnemy(true, 0);
}

function bool PickRetreatDestination() // Retreat is for pussies
{
	RouteGoal = None;
	return false;
}

function DoRetreat()
{
	`log(">>>>>>ITS TRYING TO GET AWAY!!!<<<<<<<<<");
}

function Destroyed() 
{
	// Don't let monsters respawn into the game. Just remove them.
	bIsPlayer = false;
	`log(">>>>>>>>>> Destroyed() called from Controller <<<<<<<<<<<<");
	`log(">>>>>>>>>> PlayerReplicationInfo: "@PlayerReplicationInfo);
	PlayerReplicationInfo.Destroy();
	`log(">>>>>>>>>> Replicationinfo destroyed <<<<<<<<<<<<");
	`log(">>>>>>>>>> PlayerReplicationInfo: "@PlayerReplicationInfo);
	super.Destroyed();
}

/** entry point for AI decision making
 * this gets executed during the physics tick so actions that could change the physics state (e.g. firing weapons) are not allowed
 */
protected event ExecuteWhatToDoNext()
{
	local float StartleRadius, StartleHeight;

	if (Pawn == None)
	{
		// pawn got destroyed between WhatToDoNext() and now - abort
		return;
	}
	bHasFired = false;
	bTranslocatorHop = false;
	GoalString = "WhatToDoNext at "$WorldInfo.TimeSeconds;
	if (Squad == None && PlayerReplicationInfo != None && UTTeamInfo(PlayerReplicationInfo.Team) != None)
	{
		UTTeamInfo(PlayerReplicationInfo.Team).SetBotOrders(self);
	}
	//If it's not using weapon, switch to a weapon
	if(Pawn.Weapon == None)
		SwitchToBestWeapon();

	if (Pawn.Physics == PHYS_None)
		Pawn.SetMovementPhysics();
	if ( (Pawn.Physics == PHYS_Falling) && DoWaitForLanding() )
		return;
	if ( (StartleActor != None) && !StartleActor.bDeleteMe )
	{
		StartleActor.GetBoundingCylinder(StartleRadius, StartleHeight);
		if ( VSize(StartleActor.Location - Pawn.Location) < StartleRadius  )
		{
			Startle(StartleActor);
			return;
		}
	}
	bIgnoreEnemyChange = true;
	if ( (Enemy != None) && ((Enemy.Health <= 0) || (Enemy.Controller == None)) )
		LoseEnemy();
	if ( Enemy == None )
		Squad.FindNewEnemyFor(self,false);
	else if ( !Squad.MustKeepEnemy(Enemy) && !LineOfSightTo(Enemy) )
	{
		// decide if should lose enemy
		if ( Squad.IsDefending(self) )
		{
			if ( LostContact(4) )
				LoseEnemy();
		}
		else if ( LostContact(7) )
			LoseEnemy();
	}

	bIgnoreEnemyChange = false;
	if ( bUseObjectives && AssignSquadResponsibility() )	// MAKES 'M PICK UP FLAGS, AND MAYBE DO MORE!!
	{
		return;
	}
	if ( Enemy != None )
		ChooseAttackMode();
	else
	{
		if (Pawn.FindAnchorFailedTime == WorldInfo.TimeSeconds)
		{
			// we failed the above actions because we couldn't find an anchor.
			GoalString = "No anchor" @ WorldInfo.TimeSeconds;
			if (Pawn.LastValidAnchorTime > 5.0)
			{
				if (bSoaking)
				{
					SoakStop("NO PATH AVAILABLE!!!");
				}
				if ( (NumRandomJumps > 4) || PhysicsVolume.bWaterVolume )
				{
					// can't suicide during physics tick, delay it
					Pawn.SetTimer(0.01, false, 'Suicide');
					return;
				}
				else
				{
					// jump
					NumRandomJumps++;
					if (!Pawn.IsA('Vehicle') && Pawn.Physics != PHYS_Falling && Pawn.DoJump(false))
					{
						Pawn.SetPhysics(PHYS_Falling);
						Pawn.Velocity = 0.5 * Pawn.GroundSpeed * VRand();
						Pawn.Velocity.Z = Pawn.JumpZ;
					}
				}
			}
		}

		GoalString @= "- Wander or Camp at" @ WorldInfo.TimeSeconds;
		bShortCamp = PlayerReplicationInfo.bHasFlag;
		WanderOrCamp();
	}
}

function bool WeaponFireAgain(bool bFinishedFire)
{
	if ( Enemy != None && VSize(Enemy.Location - Instigator.Location) > UTWeapon(Pawn.Weapon).WeaponRange ) // Check if the monster is within firing range
		return false;
		
	return Super.WeaponFireAgain(bFinishedFire);
}

defaultproperties
{
	Aggressiveness=1.0000
	BaseAggressiveness=1.0000
	CombatStyle=1.0000
	bUsingSquadRoute=False

   ReactionTime=0.500000
   Jumpiness=1.000000
   Begin Object Name=TheDecider ObjName=TheDecider Archetype=UTBotDecisionComponent'UTGame.Default__UTBot:TheDecider'
      ObjectArchetype=UTBotDecisionComponent'UTGame.Default__UTBot:TheDecider'
   End Object
   DecisionComponent=TheDecider
   //bIsPlayer=False
   Begin Object Name=Sprite ObjName=Sprite Archetype=SpriteComponent'UTGame.Default__UTBot:Sprite'
      ObjectArchetype=SpriteComponent'UTGame.Default__UTBot:Sprite'
   End Object
   Components(0)=Sprite
   Components(1)=TheDecider
   RotationRate=(Pitch=65535,Yaw=65535,Roll=2048)
   Name="Default__RBTTMonsterControllerMelee"
   ObjectArchetype=UTBot'UTGame.Default__UTBot'
}
