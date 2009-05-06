class MonsterCTFSquadAI extends UTCTFSquadAI;

function float VehicleDesireability(UTVehicle V, UTBot B)
{
	if(RBTTMonster(B.Pawn).default.bCanDrive)
	{
		// check VehicleLostTime here so it also applies to stationary turrets in this case
		if (WorldInfo.TimeSeconds < V.VehicleLostTime)
		{
			return 0;
		}
		// if bot has the flag and the vehicle can't carry flags, ignore it
		if ( B.PlayerReplicationInfo.bHasFlag && !V.bCanCarryFlag )
		{
			return 0;
		}
		// if vehicle is low on health, ignore it
		if (V.Health < V.HealthMax * 0.125)
		{
			return 0;
		}
		// otherwise, let vehicle rate itself
		return V.BotDesireability(self, 255, SquadObjective);
	}
	return 0;
}


function bool AssignSquadResponsibility(UTBot B)
{
	local Pawn PlayerPawn;
	local Controller C;
	local actor MoveTarget;
	local UTVehicleFactory VFactory;
	local UTVehicle V;

	if (B.NeedWeapon() && B.FindInventoryGoal(0))
	{
		B.GoalString = "Need weapon or ammo";
		B.SetAttractionState();
		return true;
	}

	if (CheckVehicle(B))
	{
		return true;
	}
	if(RBTTMonster(B.Pawn).default.bCanDrive)
	{
		if (B.Skill > 1.25)
		{
			// search for powerups
			B.RespawnPredictionTime = (B.Skill > 5.0) ? 2.0 : 0.0;
			// consider vehicles as powerups in DM
			foreach WorldInfo.AllNavigationPoints(class'UTVehicleFactory', VFactory)
			{
				V = VFactory.ChildVehicle;
				if ( (V != None && (!V.bHasBeenDriven || V.bStationary) && VehicleDesireability(V, B) > 0.0) ||
					(V == None && VFactory.RespawnProgress < B.RespawnPredictionTime && VFactory.IsInState('Active')) )
				{
					VFactory.bTransientEndPoint = true;
				}
			}
			if (B.FindSuperPickup((WorldInfo.Game.NumPlayers + WorldInfo.Game.NumBots < 4) ? 6000.0 : 3500.0))
			{
				B.GoalString = "Get super item" @ B.RouteGoal;
				B.SetAttractionState();
				return true;
			}
		}
	}
	if (B.Pawn.bStationary)
	{
		if (Vehicle(B.Pawn) != None && WorldInfo.TimeSeconds - FMax(B.AcquireTime, B.LastSeenTime) > 20.0)
		{
			if (B.Pawn.IsA('UTVehicle'))
			{
				// don't use this vehicle again for a while
				UTVehicle(B.Pawn).VehicleLostTime = WorldInfo.TimeSeconds + 30.0;
			}
			B.LeaveVehicle(true);
			return true;
		}
		else
		{
			return false;
		}
	}

	// if have no enemy
	if (B.Enemy == None)
	{
		// maybe hunt player - only if have a fix on player location from sounds he's made
		foreach WorldInfo.AllControllers(class'Controller', C)
		{
			if (C.bIsPlayer && C != self && C.Pawn != None)
			{
				PlayerPawn = C.Pawn;
				if ( (WorldInfo.TimeSeconds - PlayerPawn.Noise1Time < 5) || (WorldInfo.TimeSeconds - PlayerPawn.Noise2Time < 5) )
				{
					B.bHuntPlayer = true;
					if ( (WorldInfo.TimeSeconds - PlayerPawn.Noise1Time < 2) || (WorldInfo.TimeSeconds - PlayerPawn.Noise2Time < 2) )
					{
						B.LastKnownPosition = PlayerPawn.Location;
					}
					break;
				}
				else if ( (VSize(B.LastKnownPosition - PlayerPawn.Location) < 800)
							|| (VSize(B.LastKillerPosition - PlayerPawn.Location) < 800) )
				{
					B.bHuntPlayer = true;
					break;
				}
			}
		}
	
		if ( B.FindInventoryGoal(0) )
		{
			B.GoalString = "Hunt Player";
			B.bHuntPlayer = True;
			B.SetAttractionState();
			return true;
		}
		if ( B.bHuntPlayer )
		{
			B.bHuntPlayer = false;
			B.GoalString = "Hunt Player";
			if ( B.ActorReachable(PlayerPawn) )
				MoveTarget = PlayerPawn;
			else
				MoveTarget = B.FindPathToward(PlayerPawn,B.Pawn.bCanPickupInventory);
			if ( MoveTarget != None )
			{
				B.MoveTarget = MoveTarget;
				if ( B.CanSee(PlayerPawn) )
					SetEnemy(B,PlayerPawn);
				B.SetAttractionState();
				return true;
			}
		}

		// roam around level?
		return B.FindRoamDest();
	}

	return B.FindRoamDest();
}
defaultproperties
{
	MaxSquadSize=4
  	bShouldUseGatherPoints=true
}
