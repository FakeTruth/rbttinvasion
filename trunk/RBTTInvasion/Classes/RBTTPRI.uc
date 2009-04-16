class RBTTPRI extends UTLinkedReplicationInfo;

var repnotify PlayerController PlayerOwner;
var int CurrentWave;
var bool bCreatedHUD;

replication
{
	if(Role == ROLE_Authority && bNetInitial)
		PlayerOwner;
	if(Role == ROLE_Authority && bNetDirty)
		CurrentWave;
}


simulated event ReplicatedEvent(name VarName)
{
	if(VarName == 'PlayerOwner')
	{
		if(!bCreatedHUD)
		{
			if(PlayerOwner != None)
			{
				SpawnInteraction();
			}
		}
	}
	//else
	//if(Role < ROLE_Authority && VarName == 'PlayerOwner')
	//{
	//	
	//}
	else
		Super.ReplicatedEvent(VarName);
}

function PostBeginPlay()
{
	super.PostBeginPlay();

	`log(">> You got the RBTTPRI yay~ <<");
}

function ServerSetup()
{
	if(WorldInfo.NetMode == NM_Standalone)
	{
		SpawnInteraction();
	}
}

simulated function SpawnInteraction()
{
	local InvasionInteraction II;
	local UTHud uth;
	
	//Also set the ScoreBoardTemplate to ours
	uth = UTHud(PlayerOwner.MyHUD);
	if (uth == None)
	{
		SetTimer(5.00, FALSE, 'SpawnInteraction'); //Try again later...?
		return;
	}
	else
		uth.ScoreboardSceneTemplate = UTUIScene_Scoreboard'RBTTInvasionTex.sbInvasion';
		

	// Give player an interaction
	if(GetInvInteraction(PlayerOwner.Interactions) == None)
	{		
		II = new class'InvasionInteraction';
		II.PlayerOwner = PlayerOwner;
		II.RBPRI = self;
		PlayerOwner.Interactions.AddItem(II);
	}
}

simulated static function InvasionInteraction GetInvInteraction(array<Interaction> Inter)
{
	local int i;

	if (Inter.length == 0) return None;
	for (i = Inter.length-1; i >= 0; i--) {
		if (InvasionInteraction(Inter[i]) != None) return InvasionInteraction(Inter[i]);
	}
	return None;
}

defaultproperties
{
  Name="RBTTPRI"
}