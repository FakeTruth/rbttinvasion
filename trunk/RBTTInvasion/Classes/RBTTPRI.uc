class RBTTPRI extends UTLinkedReplicationInfo;

var repnotify UTPlayerController OwnerController;
var repnotify int CurrentWave;
var bool bClientSetup;

replication
{
	if(Role == ROLE_Authority && bNetInitial)
		OwnerController;
	if(Role == ROLE_Authority && bNetDirty)
		CurrentWave;
}


simulated event ReplicatedEvent(name VarName)
{
	if(Role < ROLE_Authority && !bClientSetup && VarName == 'OwnerController')
	{
		SpawnInteraction();
		bClientSetup = True;
	}
	//else
	//if(Role < ROLE_Authority && VarName == 'OwnerController')
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
	`log(">> Instigator: "@Instigator@" <<");
	`log(">> OwnerController: "@OwnerController@" <<");
}

function ServerInit()
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
	uth = UTHud(OwnerController.MyHUD);
	if (uth == None)
	{
		SetTimer(5.00, FALSE, 'SpawnInteraction'); //Try again later...?
		return;
	}
	else
		uth.ScoreboardSceneTemplate = UTUIScene_Scoreboard'RBTTInvasionTex.sbInvasion';
		

	// Give player an interaction
	if(GetInvInteraction(OwnerController.Interactions) == None)
	{		
		II = new class'InvasionInteraction';
		II.OwnerController = OwnerController;
		II.RBPRI = self;
		OwnerController.Interactions.AddItem(II);
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