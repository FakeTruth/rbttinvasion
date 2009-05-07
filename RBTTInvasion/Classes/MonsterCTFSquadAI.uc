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

defaultproperties
{
	MaxSquadSize=4
  	bShouldUseGatherPoints=true
}
