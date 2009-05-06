class RBTTFireAttachment extends RBTTDamageAttachment;

// FireEmitter
var ParticleSystemComponent FireEmitter;
var ParticleSystem EmitterTemplate;
var class<UTEmitCameraEffect> InsideCameraEffect;

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
	local UTPlayerController UTPC;

	if (WorldInfo.NetMode != NM_DedicatedServer && Victim != None)
	{
		Victim.Mesh.AttachComponent(FireEmitter, 'b_Spine');
		FireEmitter.SetRotation(Rotator(vect(0,0,-1)));
		FireEmitter.SetTemplate(EmitterTemplate);
		FireEmitter.ActivateSystem();
		
		if (InsideCameraEffect != None)
		{
			UTPC = UTPlayerController(Victim.Controller);
			if (UTPC != None)
			{
				UTPC.ClientSpawnCameraEffect(InsideCameraEffect);
			}
		}
	}
}

function Init()
{
	`log(">>"@Victim@" Is on fire!! WAAAAA <<");

	Super.Init();
	
	PostBeginPlay();
}

simulated function Destroyed()
{
	local UTPlayerController UPC;
	
	if (InsideCameraEffect != None)
	{
		UPC = UTPlayerController(Victim.Controller);
		if(UPC != None)
			UPC.ClearCameraEffect();
	}

	FireEmitter.DeactivateSystem();
	FireEmitter.KillParticlesForced();
	
	super.Destroyed();
}

DefaultProperties
{
	InsideCameraEffect=Class'RBTTInvasion.RBTTCameraEffect_Fire'
	MyDamageType=Class'FireDamage'

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
