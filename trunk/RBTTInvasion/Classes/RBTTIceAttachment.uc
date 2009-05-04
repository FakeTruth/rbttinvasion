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
		Victim.Mesh.AttachComponent(IceEmitter, 'b_Spine');
		IceEmitter.SetRotation(Rotator(vect(0,0,-1)));
		IceEmitter.SetTemplate(EmitterTemplate);
		IceEmitter.ActivateSystem();
	}
}

function InitIce()
{
	`log(">>"@Victim@" Is Frozen!! WAAAAA <<");

	PostBeginPlay();
	
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
	
	if (Owner == None) return;

	if (Role == ROLE_Authority && !bChangedSettings) 
	{
		if (Owner == None)
		{
			Destroy();
			return;
		}
		ClientServerSlowdown (Pawn (Owner), 5);
		bChangedSettings = true;
	}

	if (Role == ROLE_Authority) 
	{
		if (!bShownMessage) 
		{
			if (InstigatorController != None) 
			{
				//Pawn(Owner).ReceiveLocalizedMessage(FrozenMessage);
			} 
			else 
			{
				//Pawn(Owner).ReceiveLocalizedMessage(FrozenMessage);
			}
			bShownMessage = true;
		}	    
	}	
}

simulated event Destroyed()
{
  local Pawn P;
  local UTPlayerController UPC;

	if (Role == ROLE_Authority && Pawn(Owner) != None) 
	{
		P = Pawn (Owner);
		if (P != None) 
		{
			P.CustomTimeDilation = 1.0;
		}
		foreach WorldInfo.AllControllers(class'UTPlayerController', UPC)
		{
			if (P != None) 		
			{
				P.CustomTimeDilation = 1.0;
			}
		}
	}
	
	Super.Destroyed();
	IceEmitter.DeactivateSystem();
	IceEmitter.KillParticlesForced();
}

function ClientServerSlowdown (Pawn P, int TheLevel)
{
  local UTPlayerController UPC;

  if (P != None) {
    P.CustomTimeDilation = 0.50 - 0.05 * Min (5, TheLevel);
  }
  foreach WorldInfo.AllControllers(class'UTPlayerController', UPC)
  {  
	if (P != None) 
	{
		P.CustomTimeDilation = 0.50 - 0.05 * Min (5, TheLevel);
	}
  }
}

DefaultProperties
{
	Begin Object Class=ParticleSystemComponent Name=IcePSC
	End Object
	Components.Add(IcePSC)
	IceEmitter=IcePSC
	EmitterTemplate=ParticleSystem'RBTTSlime.Effects.FrozenEffect'
	FrozenMessage="you have been frozen!"
	Damage = 1.f
	DamageInterval = 0.25f
	DamageTime = 2
	
	RemoteRole=ROLE_SimulatedProxy
	bAlwaysRelevant=true
}
