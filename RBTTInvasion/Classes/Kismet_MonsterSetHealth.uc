class Kismet_MonsterSetHealth extends SequenceAction;

var Object TargetMonster;
var() int Health;

/**
 * Called when this event is activated.
 */
event Activated()
{
	local Pawn P;
	
	P = Pawn(TargetMonster);
	if(P == None || Health <= 0)
		return;
	
	P.Health = Health;
}

defaultproperties
{
	ObjName="RBTTMonster SetHealth"
	ObjCategory="RBTTInvasion"

	bCallHandler=false
	
	VariableLinks(0)=(ExpectedType=class'SeqVar_Int',LinkDesc="Health",PropertyName=Health)
	VariableLinks(1)=(ExpectedType=class'SeqVar_Object',LinkDesc="Target Monster",PropertyName=TargetMonster)
}