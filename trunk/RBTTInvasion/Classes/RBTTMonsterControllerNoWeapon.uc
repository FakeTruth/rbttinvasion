Class RBTTMonsterControllerNoWeapon Extends RBTTMonsterController;

function name GetOrders()
{
		return 'Attack'; // It doesn't have to do anything else!
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
	`log(">>>>>>ITS TRYING TO GET AWAY!!!<<<<<<<<<");
}

function Initialize(float InSkill, const out CharacterInfo BotInfo)
{
	local UTPlayerReplicationInfo PRI;
	local CustomCharData BotCharData;	
	
	Skill = FClamp(InSkill, 0, 7);

	// copy AI personality
	if (BotInfo.AIData.FavoriteWeapon != "")
	{
		if (WorldInfo.IsConsoleBuild())
		{
			FavoriteWeapon = class<Weapon>(FindObject(BotInfo.AIData.FavoriteWeapon, class'Class'));
		}
		else
		{
			FavoriteWeapon = class<Weapon>(DynamicLoadObject(BotInfo.AIData.FavoriteWeapon, class'Class'));
		}
	}
	Aggressiveness = FClamp(BotInfo.AIData.Aggressiveness, 0, 1);
	BaseAggressiveness = Aggressiveness;
	Accuracy = FClamp(BotInfo.AIData.Accuracy, -5, 5);
	StrafingAbility = FClamp(BotInfo.AIData.StrafingAbility, -5, 5);
	CombatStyle = FClamp(BotInfo.AIData.CombatStyle, -1, 1);
	Jumpiness = FClamp(BotInfo.AIData.Jumpiness, -1, 1);
	Tactics = FClamp(BotInfo.AIData.Tactics, -5, 5);
	ReactionTime = FClamp(BotInfo.AIData.ReactionTime, -5, 5);

	// copy visual properties
	BotCharData = BotInfo.CharData;
	PRI = UTPlayerReplicationInfo(PlayerReplicationInfo);

	if (PRI != None)
	{
		// If we have no 'based on' char ref, just fill it in with this char. Thing like VoiceClass look at this.
		
		if(BotCharData.BasedOnCharID == "")
		{
			BotCharData.BasedOnCharID = BotInfo.CharID;
		}
		
		PRI.SetCharacterData(BotCharData);
	}

	ReSetSkill();
}


/*
function bool FireWeaponAt(Actor A)
{
	local UTProjectile Proj;
	local Rotator Aim;
	
	Aim = GetAdjustedAim(GetPhysicalFireStartLoc());
	Proj = spawn(class'UTGame.UTProj_Rocket',,,Instigator.Location,Aim);
	Proj.Speed = 1000;
	Proj.Init(Vector(Aim));
	return Super.FireWeaponAt(A);
}
*/

function SetCombatTimer()
{
	SetTimer(1.2 - 0.09 * FMin(10,Skill+ReactionTime), True);
	//SetTimer(0.1, True); //For faster firing
}

function bool FireRocket()
{
	local UTProjectile Proj;
	local Rotator Aim;
	
	Aim = GetAdjustedAim(GetPhysicalFireStartLoc());
	Proj = spawn(class'UTGame.UTProj_Rocket',,,Instigator.Location,Aim);
	Proj.Speed = 1000;
	Proj.Init(Vector(Aim));
	
	return True;
}

function bool WeaponFireAgain(bool bFinishedFire)
{
	LastFireAttempt = WorldInfo.TimeSeconds;
	bFireSuccess = false;
	if (ScriptedTarget != None)
	{
		Focus = ScriptedTarget;
	}
	else if (Focus == None)
	{
		Focus = Enemy;
	}
	if (Focus != None)
	{
		if ( !Pawn.IsFiring() )
		{
			if ( (Pawn.Weapon != None && !Pawn.NeedToTurn(FocalPoint) && CanAttack(Focus)) )
			{
				LastCanAttackCheckTime = WorldInfo.TimeSeconds;
				bCanFire = true;
				bStoppedFiring = false;
				bFireSuccess = Pawn.BotFire(bFinishedFire);
				//bFireSuccess = FireRocket();
				LastFireTarget = Focus;
				return bFireSuccess;
			}
			else
			{
				bCanFire = false;
			}
		}
		else if ( bCanFire && ShouldFireAgain() )
		{
			if ( !Focus.bDeleteMe )
			{
				bStoppedFiring = false;
				bFireSuccess = Pawn.BotFire(bFinishedFire);
				//bFireSuccess = FireRocket();
				LastFireTarget = Focus;
				return bFireSuccess;
			}
		}
	}
	StopFiring();
	return false;
}

simulated function vector GetPhysicalFireStartLoc(optional vector AimDir)
{
	//local UTPlayerController PC;
	local vector FireStartLoc, FireDir;
	local rotator FireRot;

	if( Instigator != none )
	{
		//PC = UTPlayerController(self);

		FireRot = Instigator.GetViewRotation();
		FireDir = vector(FireRot);

		FireStartLoc = Instigator.GetPawnViewLocation() + (FireDir * 20); // The 20 is the X from RocketLauncher's FireOffset=(X=20,Y=12,Z=-5)

		return FireStartLoc;
	}

	return Location;
}

simulated function Rotator GetAdjustedAim( vector StartFireLoc )
{
	local rotator R;

	// Start the chain, see Pawn.GetAdjustedAimFor()
	if( Instigator != None )
	{
		R = GetAdjustedAimFor( None, StartFireLoc );
	}

	return R;
}

function bool NeedWeapon()
{
	return False;
}

function bool FindInventoryGoal(float BestWeight)
{
	return Super.FindInventoryGoal(BestWeight);
}

event float SuperDesireability(PickupFactory P)
{
	//return SuperDesireability(P);
	return 0.000;
}


function Destroyed() 
{
	super.Destroyed();
}

function GameHasEnded(optional Actor EndGameFocus, optional bool bIsWinner)
{
	Super.GameHasEnded(EndGameFocus, bIsWinner);
}

/** entry point for AI decision making
 * this gets executed during the physics tick so actions that could change the physics state (e.g. firing weapons) are not allowed
 */
protected event ExecuteWhatToDoNext()
{
	local float StartleRadius, StartleHeight;

	super.ExecuteWhatToDoNext();
	
	if (Pawn == None)
	{
		// pawn got destroyed between WhatToDoNext() and now - abort
		return;
	}
	bHasFired = false;
	bTranslocatorHop = false;
	GoalString = "WhatToDoNext at "$WorldInfo.TimeSeconds;
	// We dont want to be in squad, so remove if in any
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

defaultproperties
{
	Aggressiveness=1.0000
	BaseAggressiveness=1.0000
	bUsingSquadRoute=False

   ReactionTime=0.500000
   Jumpiness=1.000000
   
   Begin Object Name=TheDecider ObjName=TheDecider Archetype=UTBotDecisionComponent'UTGame.Default__UTBot:TheDecider'
      ObjectArchetype=UTBotDecisionComponent'UTGame.Default__UTBot:TheDecider'
   End Object
   DecisionComponent=TheDecider

   Begin Object Name=Sprite ObjName=Sprite Archetype=SpriteComponent'UTGame.Default__UTBot:Sprite'
      ObjectArchetype=SpriteComponent'UTGame.Default__UTBot:Sprite'
   End Object
   Components(0)=Sprite
   Components(1)=TheDecider
   RotationRate=(Pitch=65535,Yaw=65535,Roll=2048)
   Name="Default__RBTTMonsterControllerNoWeapon"
   ObjectArchetype=UTBot'UTGame.Default__UTBot'
}
