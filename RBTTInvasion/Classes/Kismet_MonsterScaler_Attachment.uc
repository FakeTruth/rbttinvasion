class Kismet_MonsterScaler_Attachment extends Actor;

var repnotify Pawn TargetMonster;
var repnotify float Size;
var bool bIsResized;

replication
{
	if(Role == ROLE_Authority && bNetDirty)
		TargetMonster, Size;
}

simulated event ReplicatedEvent(name VarName)
{
	if(VarName == 'TargetMonster' || VarName == 'Size')
	{
		`log("Kismet_MonsterScaler_Attachment::ReplicatedEvent("$VarName$")");
		if(TargetMonster != None && Size > 0.f && !bIsResized)
		{
			ResizeMonster(TargetMonster, Size);
			bIsResized = True;
		}
	}
	else
		Super.ReplicatedEvent(VarName);
}

simulated function PostBeginPlay()
{
	super.PostBeginPlay();
	`log("Kismet_MonsterScaler_Attachment::PostBeginPlay");
	
	if(TargetMonster != None && Size > 0 && bIsResized)
	{
		ResizeMonster(TargetMonster, Size);
	}
}

simulated static function ResizeMonster(Pawn P, float NewSize)
{
	local UTPawn UTP;

	`log("Kismet_MonsterScaler_Attachment::ResizeMonster");
	
	if(P.Mesh != None)
	{
		P.Mesh.SetScale(P.Mesh.Scale * NewSize);
	}
	P.SetCollisionSize( P.GetCollisionRadius() * NewSize, P.GetCollisionHeight() * NewSize );
	
	UTP = UTPawn(P);
	if(UTP != None)
	{
		UTP.DefaultHeight*=NewSize;
		UTP.DefaultRadius*=NewSize;
		
		UTP.DefaultMeshScale*=NewSize;
		UTP.DesiredMeshScale*=NewSize;
	}
}

defaultproperties
{
	RemoteRole=ROLE_SimulatedProxy
	//bAlwaysRelevant=True
	bStatic=False
	bNoDelete=False
}
