class MonsterSpawner extends Actor;

var StaticMeshComponent FloorMesh;
var MaterialInstanceConstant FloorMaterialInstance;
var LinearColor NeutralFloorColor;
var array<LinearColor> TeamFloorColors;

/** component that plays ambient effects for the node teleporters current state */
var ParticleSystemComponent AmbientEffect;
/** component that plays the render-to-texture portal effect */
var ParticleSystemComponent PortalEffect;
var ParticleSystemComponent VortexEffect;
var ParticleSystem VortexEffectTemplate;

/** materials for the portal effect */
var MaterialInterface PortalMaterial;
var MaterialInstanceConstant PortalMaterialInstance;
/** the component that captures the portal scene */
var SceneCapture2DComponent PortalCaptureComponent;

/** base ambient effects */
var ParticleSystem NeutralEffectTemplate;
var array<ParticleSystem> TeamEffectTemplates;
/** teamcolored templates for portal effect */
var array<ParticleSystem> TeamPortalEffectTemplates;

var soundcue ConstructedSound, ActiveSound;

var AudioComponent AmbientSoundComponent;

var array<Class<UTPawn> > SpawnArray;
var RBTTInvasionGameRules InvasionGameRules;
var bool bInitialized;

var	CylinderComponent		CylinderComponent;
var	int 				Health;

/** increase in vortex force per second */
var float VortexForcePerSecond;
/** radius in which ragdolls have the force applied */
var float VortexRadius;
/** duration in seconds of the physics effect, or zero for it to be the same as the emitter */
var float VortexDuration;

simulated function PostBeginPlay()
{
	super.PostBeginPlay();

	//Get the game rules so we can make it summon monsters
	if(WorldInfo.NetMode == NM_Standalone || WorldInfo.NetMode == NM_DedicatedServer)
		InvasionGameRules = RBTTInvasionGameRules(WorldInfo.Game.GameRulesModifiers);

	if (WorldInfo.NetMode != NM_DedicatedServer)
	{
		PortalEffect.SetTemplate(TeamPortalEffectTemplates[0]);
		
		PlaySound(ConstructedSound);
		//Ambient Sound
		AmbientSoundComponent.SoundCue = ActiveSound;
		AmbientSoundComponent.Play();
		PortalEffect.SetActive(true);
		PortalEffect.SetHidden(false);
		SpawnTransEffect(0);
	}
	
	if(!bInitialized)
		Initialize(5, 15);
}

function Initialize(int SpawnInterval, optional int SpawnAfter)
{
	if(SpawnAfter == 0)
		StartSpawning();
	else
		SetTimer(SpawnAfter, False, 'StartSpawning');
		
	SetTimer(SpawnInterval, True, 'SpawnMonster');
	bInitialized = True;
}

function StartSpawning()
{
	GotoState('Spawning');
}

function SpawnMonster();

function Destroyed()
{
	InvasionGameRules.NumPortals--;
	SpawnTransEffect(0);
	Super.Destroyed();
}

simulated event TakeDamage(int DamageAmount, Controller EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
{
	//if(PlayerController(UTPawn(DamageCauser).Controller) != None)
	if(DamageCauser.Instigator.Controller.IsA('PlayerController'))
	{
		LogInternal(">>>DamageCauser == "@DamageCauser);
		super.TakeDamage(DamageAmount, EventInstigator, HitLocation, Momentum, DamageType, HitInfo, DamageCauser);
		
		Health-=DamageAmount;
		if(Health < 0.3 * default.Health)
		{
			PortalEffect.SetTemplate(TeamPortalEffectTemplates[1]);
		}
		
		if(Health <= 0)
		{
			ClearTimer('StartSpawning');
			ClearTimer('SpawnMonster');
			GotoState('PhysicsVortex');
		}
	}
}

function SpawnTransEffect(int TeamNum)
{
	Spawn(class'UTGame.UTPawn'.default.TransInEffects[TeamNum],self,,Location + vect(0,0,64));
}

state Spawning
{
	function SpawnMonster()
	{
		if( WorldInfo.Game.IsInState('MatchOver') || WorldInfo.Game.IsInState('RoundOver') ) // Game has ended.. so destroy
		{	Destroy(); return; 	}
		
		if(InvasionGameRules.IsInState('BetweenWaves')) // This shouldn't happen..
		{	Destroy(); return; 	}
			
		if(InvasionGameRules.InsertMonster(SpawnArray[SpawnArray.length-1],self.Location,self.Rotation))
		{
			SpawnArray.Remove(SpawnArray.length-1, 1);
		}
		
		if(SpawnArray.length <= 0)
			Destroy();
	}
}

simulated function EndVortex()
{
	HurtRadius(250, 256, class'VortexDamageType', 150000, Location);
	Spawn(class'UTGame.UTEmit_ShockCombo',,,Location);
	GotoState('');
	Destroy();
}


/** this state does the cool physics vortex effect */
state PhysicsVortex // Taken from UTGame.UTEmit_ShockCombo
{
	simulated event BeginState(name PreviousStateName)
	{
		if (VortexDuration > 0.0)
		{
			SetTimer(VortexDuration, false, 'EndVortex');
			VortexEffect.SetTemplate(VortexEffectTemplate);
		}
	
 	//bCollideActors=False;
 	bBlockActors=False;
	}

	simulated event Tick(float DeltaTime)
	{
		local float CurrentForce;
		local UTPawn P;
		local vector OtherLocation, Dir;

		CurrentForce = VortexForcePerSecond * (WorldInfo.TimeSeconds - CreationTime);

		foreach CollidingActors(class'UTPawn', P, VortexRadius,, true)
		{
			if (P.Physics == PHYS_RigidBody)
			{
				OtherLocation = P.Mesh.GetPosition();
				if (FastTrace(Location, OtherLocation))
				{
					// if it has reached the center, gib it
					Dir = (Location + Vect(0,0,64) - OtherLocation);
					if (VSize(Dir) < P.Mesh.Bounds.SphereRadius && Normal(P.Velocity) dot Dir > 0.0 && !class'GameInfo'.static.UseLowGore(WorldInfo) )
					{
						P.SpawnGibs(class'UTGame.UTDmgType_ShockCombo', Location);
					}
					else
					{
						P.Mesh.AddForce(Normal(Dir) * CurrentForce);
						// 1 / VSize(B.Enemy.Location - Instigator.Location)
					}
				}
				return;
			}
				
			OtherLocation = P.Location;
			if (FastTrace(Location, OtherLocation))
			{
				Dir = (Location + Vect(0,0,64) - OtherLocation);
				//P.Mesh.AddForce(Normal(Dir) * CurrentForce);
				P.AddVelocity(((Dir * CurrentForce)*DeltaTime)/(VSize(Location - OtherLocation)*0.1), OtherLocation, None);
			}
		}
	}
}

defaultproperties
{
   NeutralFloorColor=(R=0.000000,G=0.000000,B=0.000000,A=1.000000)
   Begin Object Class=ParticleSystemComponent Name=ParticleSystemComponent0 ObjName=ParticleSystemComponent0 Archetype=ParticleSystemComponent'Engine.Default__ParticleSystemComponent'
      Name="ParticleSystemComponent0"
      ObjectArchetype=ParticleSystemComponent'Engine.Default__ParticleSystemComponent'
   End Object
   PortalEffect=ParticleSystemComponent0
   Begin Object Class=ParticleSystemComponent Name=ParticleSystemComponent1 ObjName=ParticleSystemComponent1 Archetype=ParticleSystemComponent'Engine.Default__ParticleSystemComponent'
      Translation=(X=0.000000,Y=0.000000,Z=64.000000)
      Name="ParticleSystemComponent1"
      ObjectArchetype=ParticleSystemComponent'Engine.Default__ParticleSystemComponent'
   End Object
   VortexEffect=ParticleSystemComponent1
   PortalMaterial=Material'PICKUPS.Base_Teleporter.Material.M_T_Pickups_Teleporter_Portal_Destination'
   TeamPortalEffectTemplates(0)=ParticleSystem'PICKUPS.Base_Teleporter.Effects.P_Pickups_Teleporter_Idle_Red'
   TeamPortalEffectTemplates(1)=ParticleSystem'PICKUPS.Base_Teleporter.Effects.P_Pickups_Teleporter_Idle_Blue'
   ConstructedSound=SoundCue'A_Gameplay.ONS.A_Gameplay_ONS_ConduitActivated'
   ActiveSound=SoundCue'A_Gameplay.Portal.Portal_Loop01Cue'
   Begin Object Class=AudioComponent Name=AmbientSoundComponent0 ObjName=AmbientSoundComponent0 Archetype=AudioComponent'Engine.Default__AudioComponent'
      bAutoPlay=True
      bStopWhenOwnerDestroyed=True
      Name="AmbientSoundComponent0"
      ObjectArchetype=AudioComponent'Engine.Default__AudioComponent'
   End Object
   AmbientSoundComponent=AmbientSoundComponent0
   SpawnArray(0)=Class'RBTTInvasion.RBTTMiningRobot'
   SpawnArray(1)=Class'RBTTInvasion.RBTTMiningRobot'
   SpawnArray(2)=Class'RBTTInvasion.RBTTMiningRobot'
   SpawnArray(3)=Class'RBTTInvasion.RBTTMiningRobot'
   SpawnArray(4)=Class'RBTTInvasion.RBTTMiningRobot'
   SpawnArray(5)=Class'RBTTInvasion.RBTTMiningRobot'
   Begin Object Class=CylinderComponent Name=CollisionCylinder ObjName=CollisionCylinder Archetype=CylinderComponent'Engine.Default__CylinderComponent'
      CollisionHeight=64.000000
      CollisionRadius=32.000000
      CollideActors=True
      BlockActors=True
      Translation=(X=0.000000,Y=0.000000,Z=64.000000)
      Name="CollisionCylinder"
      ObjectArchetype=CylinderComponent'Engine.Default__CylinderComponent'
   End Object
   CylinderComponent=CollisionCylinder
   Health=150
   VortexForcePerSecond=50.000000
   VortexRadius=512.000000
   VortexDuration=2.500000
   Components(0)=ParticleSystemComponent0
   Components(1)=ParticleSystemComponent1
   Components(2)=AmbientSoundComponent0
   Components(3)=CollisionCylinder
   RemoteRole=ROLE_SimulatedProxy
   bAlwaysRelevant=True
   bCollideActors=True
   bBlockActors=True
   NetUpdateFrequency=1.000000
   CollisionComponent=CollisionCylinder
   MessageClass=Class'UTGameContent.UTOnslaughtMessage'
   Name="Default__MonsterSpawner"
   ObjectArchetype=Actor'Engine.Default__Actor'
}
