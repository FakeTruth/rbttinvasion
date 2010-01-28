class InvMod_PlayerQueue extends InvMod;

var array<UTPlayerReplicationInfo> Queue; // This array holds dead players for ressurecting them


/** If PlayerName is not given, ressurect ALL players */
function Mutate (string MutateString, PlayerController Sender)
{
	local Controller C;
	local int i;
	local string PlayerName;
	local PlayerReplicationInfo ResBy;
	
	if (Sender.PlayerReplicationInfo.bAdmin || Sender.WorldInfo.NetMode == NM_Standalone)
	{
		if( Left(MutateString, Len("resplayer")) ~= "resplayer")
		{
			PlayerName = Right(MutateString, Len(MutateString) - Len("resplayer "));
			ResBy = Sender.PlayerReplicationInfo;
		
			if(PlayerName ~= "")
			{
				for(i = Queue.length-1; i >= 0; i--)
				{
					C = GetPlayerFromQueue(i);
					if(C != None)
					{
						WorldInfo.Game.RestartPlayer(C);
						if(ResBy != None && PlayerController(C) != None)
						{
							PlayerController(C).ReceiveLocalizedMessage( Class'ResMessage',, ResBy);
						}
					}
				}
			}
			else
			{
				for(i = Queue.length-1; i >= 0; i--)
				{
					C = GetPlayerFromQueue(i, True);
					if(C != None && C.PlayerReplicationInfo != None)
					{
						if(Left(C.PlayerReplicationInfo.PlayerName, Len(PlayerName)) ~= PlayerName)
						{
							GetPlayerFromQueue(i);
							WorldInfo.Game.RestartPlayer(C);
							if(ResBy != None && PlayerController(C) != None)
							{
								PlayerController(C).ReceiveLocalizedMessage( Class'ResMessage',, ResBy);
							}
						}
					}
				}
			}
		}
	}
	
	super.Mutate(MutateString, Sender);
}


/**
 * Find out whether this controller is not a monster, and add it to the queue
 */
function ScoreKill(Controller Killer, Controller Other)
{
	local UTPlayerReplicationInfo UTPRI;
	
	if( Other != None)
	{
		if( Other.PlayerReplicationInfo != None )
		{
			UTPRI = UTPlayerReplicationInfo( Other.PlayerReplicationInfo );
			if(UTPRI != None && UTPRI.Team != NONE && UTPRI.Team.TeamIndex != 1)		// Only add players from human team
				AddToQueue( UTPlayerReplicationInfo( Other.PlayerReplicationInfo ) );
		}
	}

	super.ScoreKill(Killer, Other);
}

/**
 * Called when a wave is about to start, called after new InvasionRules have been spawned (before countdown)
 */
function StartWave(GameRules G)
{
	RespawnPlayersFromQueue();

	Super.StartWave(G);
}

function RespawnPlayersFromQueue()
{
	local Controller C;
	local int i;
	
	`log(">>>>>>>>>>>>>>>>>>RBTTInvasionGameRules.RespawnPlayersFromQueue<<<<<<<<<<<<<<<<<<<<");
	
	for(i = Queue.length-1; i >= 0; i--)
	{
		C = GetPlayerFromQueue(i);
		if(C != None)
			WorldInfo.Game.RestartPlayer(C);
	}
}

/** removes a player from the queue, sets it up to play, and returns the Controller
 * @note: doesn't spawn the player in (i.e. doesn't call RestartPlayer()), calling code is responsible for that
 */
function Controller GetPlayerFromQueue(int Index, optional bool bDontRemoveFromQueue)
{
	local Controller C;
	local UTPlayerReplicationInfo PRI;
	local UTTeamInfo NewTeam;

	PRI = Queue[Index];
	if(!bDontRemoveFromQueue)
		Queue.Remove(Index, 1);
		
	if(PRI == None)
		return None;

	// after a seamless travel some players might still have the old TeamInfo from the previous level
	// so we need to manually count instead of using Size
	NewTeam = UTTeamGame(WorldInfo.Game).Teams[0];
	C = Controller(PRI.Owner);
	if( C != None )
	{
		if (C.IsA('UTBot'))
			NewTeam.SetBotOrders(UTBot(C));
		return C;
	}
	
	return None;
}


function AddToQueue(UTPlayerReplicationInfo Who)
{
	local PlayerController PC;
	//local int i;

	`log(">>>>>>>>>>>>>>>>>>RBTTInvasionGameRules.AddToQueue<<<<<<<<<<<<<<<<<<<<");
	
	// Add the player to the end of the queue
	//i = Queue.Length;
	//`log(">>>>>>>>>>Queue.Length = "@i@"<<<<<<<<<<<");
	//Queue.Length = i + 1;
	Queue.AddItem(Who);
	`log(">>>>>>>>>>>>Player"@Who@" Added to Queue[]<<<<<<<<<<");
	//`log(">>>>>>>>>>>Queue["@i@"] = "@Queue[i]@"<<<<<<<<<<");
	//Queue[i].QueuePosition = i;

	//WorldInfo.Game.GameReplicationInfo.SetTeam(Controller(Who.Owner), None, false);
	if (!WorldInfo.Game.bGameEnded)
	{
		Who.Owner.GotoState('InQueue');
		WorldInfo.Game.BroadcastLocalized(self, class'OutMessage',,Who);
		PC = PlayerController(Who.Owner);
		if (PC != None)
		{
			PC.ClientGotoState('InQueue');
		}
		if( InvasionRules.InvasionMut.AllInvasionModules != None )
		{
			InvasionRules.InvasionMut.AllInvasionModules.PlayerOut( Who );
		}
	}
}

defaultproperties
{
}