Class RBTTMonsterControllerGasBag Extends RBTTMonsterController;

var string VeryOldGoalString;

//function FightEnemy(bool bCanCharge, float EnemyStrength);

function name GetOrders()
{
		return 'Attack'; // Attack! Be more agressive yo!
}

simulated function Tick( float DeltaTime )
{
	if(VeryOldGoalString == GoalString)
		return;

	VeryOldGoalString = GoalString;
	LogInternal(GoalString);
}

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
	LogInternal(">>>>>>ITS TRYING TO GET AWAY!!!<<<<<<<<<");
}

event WhatToDoNext()
{
	super.WhatToDoNext();
	
	if(Pawn.Velocity.Z < 128)
	{
		Pawn.Velocity.Z += 50;
		LogInternal(">>Monster goes up!<<");
	}
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
	// if we don't have a squad, try to find one
	//@fixme FIXME: doesn't work for FFA gametypes
	if (Squad == None && PlayerReplicationInfo != None && UTTeamInfo(PlayerReplicationInfo.Team) != None)
	{
		UTTeamInfo(PlayerReplicationInfo.Team).SetBotOrders(self);
	}
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
	// check deployables
	if (UTStealthVehicle(Pawn) != None && UTStealthVehicle(Pawn).ShouldDropDeployable())
	{
		return;
	}
	if (UTDeployable(Pawn.Weapon) != None && UTDeployable(Pawn.Weapon).ShouldDeploy(self))
	{
		// can't use during physics tick, have to wait
		SetTimer(0.01, false, 'UseDeployable');
	}

	bIgnoreEnemyChange = false;
	if ( AssignSquadResponsibility() )
	{
		return;
	}
	if ( ShouldDefendPosition() )
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

function WanderOrCamp()
{
	GotoState('Defending', 'Begin');
}

function bool FindRoamDest()
{
	return false;
}

state Defending
{
	function SetRouteGoal()
	{
		//local Actor NextMoveTarget;

		if (DefensePoint == None || PlayerReplicationInfo.bHasFlag )
		{
			// if in good position, tend to stay there
			if ( (WorldInfo.TimeSeconds - FMax(LastSeenTime, AcquireTime) < 5.0 || FRand() < 0.85))
			{
				CampTime = 3;
				GotoState('Defending','Pausing');
			}
		}
	}
	
}

function TimedFireWeaponAtEnemy()
{
	if ( (Enemy == None) || FireWeaponAt(Enemy) )
		SetCombatTimer();
	else
		SetTimer(RBTTMonster(Pawn).GetFireInterval(0), True);
}

function bool FireWeaponAt(Actor A)
{
	if ( A == None )
		A = Enemy;
	if ( (A == None) || (Focus != A) )
		return false;
	//Target = A;
	RBTTMonster(Pawn).RangedAttack(A);
	return false;
}

function StopFiring()
{
	//Monster(Pawn).StopFiring();
	bCanFire = false;
}

function bool FindNewEnemy()
{
	local Pawn BestEnemy;
	local bool bSeeNew, bSeeBest;
	local float BestDist, NewDist;
	local Controller C;

	if ( WorldInfo.Game.bGameEnded )
		return false;
	//for ( C=WorldInfo.Game.ControllerList; C!=None; C=C.NextController )
	foreach WorldInfo.AllControllers(class'Controller', C)
		if ( C.bIsPlayer && (C.Pawn != None) )
		{
			if ( BestEnemy == None )
			{
				BestEnemy = C.Pawn;
				BestDist = VSize(BestEnemy.Location - Pawn.Location);
				bSeeBest = CanSee(BestEnemy);
			}
			else
			{
				NewDist = VSize(C.Pawn.Location - Pawn.Location);
				if ( !bSeeBest || (NewDist < BestDist) )
				{
					bSeeNew = CanSee(C.Pawn);
					if ( bSeeNew || (!bSeeBest && (NewDist < BestDist))  )
					{
						BestEnemy = C.Pawn;
						BestDist = NewDist;
						bSeeBest = bSeeNew;
					}
				}
			}
		}

	if ( BestEnemy == Enemy )
		return false;

	if ( BestEnemy != None )
	{
		ChangeEnemy(BestEnemy,CanSee(BestEnemy));
		return true;
	}
	return false;
}

function ChangeEnemy(Pawn NewEnemy, bool bCanSeeNewEnemy)
{
	//OldEnemy = Enemy;
	Enemy = NewEnemy;
	EnemyChanged(bCanSeeNewEnemy);
}

// EnemyChanged() called when current enemy changes
function EnemyChanged(bool bNewEnemyVisible)
{
	bEnemyAcquired = false;
	SetEnemyInfo(bNewEnemyVisible);
	//Monster(Pawn).PlayChallengeSound();
}

defaultproperties
{
   bUsingSquadRoute=False
   Aggressiveness=1.000000
   BaseAggressiveness=1.000000
   CombatStyle=0.400000
   Begin Object Class=UTBotDecisionComponent Name=TheDecider ObjName=TheDecider Archetype=UTBotDecisionComponent'UTGame.Default__UTBot:TheDecider'
      ObjectArchetype=UTBotDecisionComponent'UTGame.Default__UTBot:TheDecider'
   End Object
   DecisionComponent=TheDecider
   Begin Object Class=SpriteComponent Name=Sprite ObjName=Sprite Archetype=SpriteComponent'UTGame.Default__UTBot:Sprite'
      ObjectArchetype=SpriteComponent'UTGame.Default__UTBot:Sprite'
   End Object
   Components(0)=Sprite
   Components(1)=TheDecider
   Name="Default__RBTTMonsterControllerGasBag"
}
