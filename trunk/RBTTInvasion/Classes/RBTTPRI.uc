class RBTTPRI extends UTLinkedReplicationInfo;

var repnotify UTPlayerController OwnerController;
var bool bClientSetup;

replication
{
	if(Role == ROLE_Authority && bNetInitial)
		OwnerController;
}


simulated event ReplicatedEvent(name VarName)
{
	if(Role < ROLE_Authority && !bClientSetup && VarName == 'OwnerController')
	{
		SpawnInteraction();
		bClientSetup = True;
	}
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

	II = new class'InvasionInteraction';
	II.OwnerController = OwnerController;
	OwnerController.Interactions.AddItem(II);
	
	//Also set the ScoreBoardTemplate to ours
	uth = UTHud(OwnerController.MyHUD);
	if (uth == None)
	{
		SetTimer(5.00, FALSE, 'SpawnInteraction'); //Try again later...?
		return;
	}
	else
		uth.ScoreboardSceneTemplate = UTUIScene_Scoreboard'RBTTInvasionTex.sbInvasion';
}

defaultproperties
{
  Name="RBTTPRI"
}