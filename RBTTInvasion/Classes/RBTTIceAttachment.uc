class RBTTIceAttachment extends Inventory;

var repnotify Pawn Victim;
var Controller InstigatorController;
var float Damage;
var float DamageInterval;
var int DamageTime;
var int Level; // Server
var bool bShownMessage; // Client
var bool bChangedSettings; // Client
var String FrozenMessage;
// IceEmitter
var ParticleSystemComponent IceEmitter;
var ParticleSystem EmitterTemplate;
var class<UTEmitCameraEffect> InsideCameraEffect;

// Victim's parameters
var float OldGroundSpeed;


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
	local UTPlayerController UTPC;

	if (WorldInfo.NetMode != NM_DedicatedServer && Victim != None)
	{
		Victim.Mesh.AttachComponent(IceEmitter, 'b_Spine');
		IceEmitter.SetRotation(Rotator(vect(0,0,-1)));
		IceEmitter.SetTemplate(EmitterTemplate);
		IceEmitter.ActivateSystem();
		
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

function InitIce()
{
	`log(">>"@Victim@" Is Frozen!! WAAAAA <<");

	PostBeginPlay();
	
	if (Role == ROLE_Authority && !bChangedSettings) 
	{
		if (Victim == None)
		{
			Destroy();
			return;
		}
		ClientServerSlowdown (Victim, 5);
		bChangedSettings = True;
	}
	
	SetTimer(DamageInterval, True, 'DamageTimer');
	SetTimer(1.f, True, 'Timer');
}

reliable client function InitIceClient()
{
	Victim = Instigator;
	PostBeginPlay();
}

function DamageTimer()
{
	Victim.TakeDamage( Damage, InstigatorController, Victim.Location, Vect(0,0,0), Class'IceDamage');
											// IceDamage!
}

function Timer()
{
	DamageTime--;
	if(DamageTime <= 0)
	{
		Destroy();
	}
}

simulated event Destroyed()
{
	local UTPlayerController UPC;
  
	if (Role == ROLE_Authority && Victim != None && bChangedSettings) 
	{
		//Victim.CustomTimeDilation = 1.0;
		Victim.GroundSpeed = OldGroundSpeed;
		`log(">>Victim.GroundSpeed = "@Victim.GroundSpeed);
	}
	
	if (InsideCameraEffect != None)
	{
		UPC = UTPlayerController(Victim.Controller);
		if(UPC != None)
			UPC.ClearCameraEffect();
	}
	
	Super.Destroyed();
	IceEmitter.DeactivateSystem();
	IceEmitter.KillParticlesForced();
}

function ClientServerSlowdown (Pawn P, int TheLevel)
{
  //local UTPlayerController UPC;

  //if (P != None) {
  //  P.CustomTimeDilation = 0.50 - 0.05 * Min (5, TheLevel);
  //}
  
	if (P != None)
	{	
		OldGroundSpeed = P.GroundSpeed;
		P.GroundSpeed = 200.f;
	}
  
  //foreach WorldInfo.AllControllers(class'UTPlayerController', UPC)
  //{  
//	if (P != None) 
//	{
//		P.CustomTimeDilation = 0.50 - 0.05 * Min (5, TheLevel);
//	}
//  }
}

DefaultProperties
{
	InsideCameraEffect=Class'RBTTInvasion.RBTTCameraEffect_Frozen'
	Begin Object Class=ParticleSystemComponent Name=IcePSC
	End Object
	Components.Add(IcePSC)
	IceEmitter=IcePSC
	EmitterTemplate=ParticleSystem'RBTTSlime.Effects.FrozenEffect'
	FrozenMessage="you have been frozen!"
	Damage = 10.f
	DamageInterval = 0.25f
	DamageTime = 2
	
	RemoteRole=ROLE_SimulatedProxy
	bAlwaysRelevant=true
}
