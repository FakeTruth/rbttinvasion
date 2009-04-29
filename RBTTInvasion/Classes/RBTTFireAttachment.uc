class RBTTFireAttachment extends Inventory;

var repnotify Pawn Victim;
var Controller InstigatorController;
var float Damage;
var float DamageInterval;
var int DamageTime;

// FireEmitter
var ParticleSystemComponent FireEmitter;
var ParticleSystem EmitterTemplate;

replication
{
	if(Role == ROLE_Authority && bNetInitial)
		Victim;
}

simulated event ReplicatedEvent(name VarName)
{
	if(Role < ROLE_Authority && VarName == 'Victim')
	{
		if(Victim != None)
			PostBeginPlay();
	}
	else
		Super.ReplicatedEvent(VarName);
}

simulated function PostBeginPlay()
{
	if (WorldInfo.NetMode != NM_DedicatedServer && Victim != None)
	{
		Victim.Mesh.AttachComponent(FireEmitter, 'b_Spine');
		FireEmitter.SetRotation(Rotator(vect(0,0,-1)));
		FireEmitter.SetTemplate(EmitterTemplate);
		FireEmitter.ActivateSystem();
	}
}

function InitFire()
{
	`log(">>"@Victim@" Is on fire!! WAAAAA <<");

	PostBeginPlay();
	
	SetTimer(DamageInterval, True, 'DamageTimer');
	SetTimer(1.f, True, 'Timer');
}

reliable client function InitFireClient()
{
	Victim = Instigator;
	PostBeginPlay();
}

function DamageTimer()
{
	Victim.TakeDamage( Damage, InstigatorController, Victim.Location, Vect(0,0,0), Class'FireDamage');
											// FireDamage!
}

function Timer()
{
	DamageTime--;
	if(DamageTime <= 0)
	{
		Destroy();
	}
}

simulated function Destroyed()
{
	FireEmitter.DeactivateSystem();
	FireEmitter.KillParticlesForced();
}

DefaultProperties
{
	Begin Object Class=ParticleSystemComponent Name=FirePSC
	End Object
	Components.Add(FirePSC)
	FireEmitter=FirePSC
	EmitterTemplate=ParticleSystem'RBTTScarySkull.FireEmitter'

	Damage = 1.f
	DamageInterval = 0.25f
	DamageTime = 5
	
	RemoteRole=ROLE_SimulatedProxy
	bAlwaysRelevant=true
}
