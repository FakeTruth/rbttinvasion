class RBTTDamageAttachment extends Inventory;

var repnotify Pawn Victim;
var Controller InstigatorController;
var float Damage;
var float DamageInterval;
var int DamageTime;
var Class<DamageType> MyDamageType;

replication
{
	if(Role == ROLE_Authority && bNetInitial)
		Victim;
}

simulated function PostBeginPlay();

function Init()
{
	if(DamageTime < 1)
	{
		Destroy();
		return;
	}

	if(Damage > 0 && DamageInterval > 0)
		SetTimer(DamageInterval, True, 'DamageTimer');
	
	SetTimer(1.f, True, 'Timer');
}

reliable client function InitClient()
{
	Victim = Instigator;
	PostBeginPlay();
}

function DamageTimer()
{
	Victim.TakeDamage( Damage, InstigatorController, Victim.Location, Vect(0,0,0), MyDamageType);
}

function Timer()
{
	`log(">> RBTTDamageAttachment Timer <<");
	DamageTime--;
	if(DamageTime <= 0)
	{
		Destroy();
	}
}

defaultproperties
{
}