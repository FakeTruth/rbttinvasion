class RBTTGasBagBelch extends UTProjectile;

simulated function PostBeginPlay()
{
	// force ambient sound if not vehicle game mode
	bImportantAmbientSound = !WorldInfo.bDropDetail && (UTOnslaughtGRI(WorldInfo.GRI) == None);
	Super.PostBeginPlay();
}

defaultproperties
{
   bWaitForEffects=True
   bAttachExplosionToVehicles=False
   bCheckProjectileLight=True
   AmbientSound=SoundCue'A_Weapon_RocketLauncher.Cue.A_Weapon_RL_Travel_Cue'
   ExplosionSound=SoundCue'A_Weapon_RocketLauncher.Cue.A_Weapon_RL_Impact_Cue'
   ProjExplosionTemplate=ParticleSystem'WP_RocketLauncher.Effects.P_WP_RocketLauncher_RocketExplosion'
   ExplosionDecal=MaterialInstanceTimeVarying'WP_RocketLauncher.Decals.MITV_WP_RocketLauncher_Impact_Decal01'
   DecalWidth=128.000000
   DecalHeight=128.000000
   CheckRadius=44.000000
   ProjectileLightClass=Class'UTGame.UTRocketLight'
   ExplosionLightClass=Class'UTGame.UTRocketExplosionLight'
   Speed=500.000000
   MaxSpeed=500.000000
   Damage=20.000000
   DamageRadius=220.000000
   MomentumTransfer=85000.000000
   MyDamageType=Class'UTGame.UTDmgType_Rocket'
   Begin Object Class=CylinderComponent Name=CollisionCylinder ObjName=CollisionCylinder Archetype=CylinderComponent'UTGame.Default__UTProjectile:CollisionCylinder'
      ObjectArchetype=CylinderComponent'UTGame.Default__UTProjectile:CollisionCylinder'
   End Object
   CylinderComponent=CollisionCylinder
   Components(0)=CollisionCylinder
   LifeSpan=16.000000
   CollisionComponent=CollisionCylinder
   RotationRate=(Pitch=0,Yaw=0,Roll=50000)
   DesiredRotation=(Pitch=0,Yaw=0,Roll=30000)
   Name="Default__RBTTGasBagBelch"
   ObjectArchetype=UTProjectile'UTGame.Default__UTProjectile'
}
