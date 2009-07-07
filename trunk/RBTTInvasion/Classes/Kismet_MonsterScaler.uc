class Kismet_MonsterScaler extends SequenceAction;

var Object TargetMonster;
var float Size;

/**
 * Called when this event is activated.
 */
simulated event Activated()
{
	local Pawn P;
	local Kismet_MonsterScaler_Attachment Attachment;
	
	`log("Kismet_MonsterScaler::Activated()");
	
	P = Pawn(TargetMonster);
	if(P == None || Size <= 0.f)
		return;
	
	`log("Kismet_MonsterScaler.P = "@P);
	
	if(P.Mesh != None)
	{
		`log("Kismet_MonsterScaler.P.Mesh = "@P.Mesh);
	
		// No need to replicate anything when playing offline
		if(P.WorldInfo.NetMode == NM_Standalone)
		{
			Class'Kismet_MonsterScaler_Attachment'.static.ResizeMonster(P, Size);
			return;
		}
	
		Attachment = P.Spawn(Class'Kismet_MonsterScaler_Attachment');
	
		Attachment.TargetMonster = P;
		Attachment.Size = Size;
		
		`log("Kismet_MonsterScaler.Attachment = "@Attachment);
		
		// Make sure monster ('s collision) also gets resized on the server side
		if(P.WorldInfo.NetMode == NM_DedicatedServer || P.WorldInfo.NetMode == NM_ListenServer)
		{
			Attachment.ResizeMonster(P, Size);
		}
	}
}

defaultproperties
{
	ObjName="RBTTMonster Scaler"
	ObjCategory="RBTTInvasion"

	bCallHandler=false
	
	VariableLinks(0)=(ExpectedType=class'SeqVar_Float',LinkDesc="Size",PropertyName=Size)
	VariableLinks(1)=(ExpectedType=class'SeqVar_Object',LinkDesc="Target Monster",PropertyName=TargetMonster)
}