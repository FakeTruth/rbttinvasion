class RBTTIceAttachment extends RBTTDamageAttachment;

var bool bChangedSettings;

// IceEmitter
var ParticleSystemComponent IceEmitter;
var ParticleSystem EmitterTemplate;
var class<UTEmitCameraEffect> InsideCameraEffect;

// Victim's parameters
var float OldGroundSpeed;

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

function Init()
{
	super.Init();

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
	
	IceEmitter.DeactivateSystem();
	IceEmitter.KillParticlesForced();
	
	Super.Destroyed();
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
		P.GroundSpeed = 150.f;
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
	MyDamageType=Class'IceDamage'

	InsideCameraEffect=Class'RBTTInvasion.RBTTCameraEffect_Frozen'
	Begin Object Class=ParticleSystemComponent Name=IcePSC
	End Object
	Components.Add(IcePSC)
	IceEmitter=IcePSC
	EmitterTemplate=ParticleSystem'RBTTSlime.Effects.FrozenEffect'

	Damage = 0
	DamageInterval = 0
	DamageTime = 5
	
	RemoteRole=ROLE_SimulatedProxy
	bAlwaysRelevant=true
}
