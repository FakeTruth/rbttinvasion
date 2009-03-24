class RBTTInfernalPlasma extends UTProjectile;

simulated function PostBeginPlay()
{
	// force ambient sound if not vehicle game mode
	bImportantAmbientSound = !WorldInfo.bDropDetail && (UTOnslaughtGRI(WorldInfo.GRI) == None);
	Super.PostBeginPlay();
}

defaultproperties
{
	//ProjFlightTemplate=ParticleSystem'WP_RocketLauncher.Effects.P_WP_RocketLauncher_RocketTrail'
	ProjFlightTemplate=ParticleSystem'RBTTInfernal.InfernalPlasma'
	ProjExplosionTemplate=ParticleSystem'WP_RocketLauncher.Effects.P_WP_RocketLauncher_RocketExplosion'
	ExplosionDecal=MaterialInstanceTimeVarying'WP_RocketLauncher.Decals.MITV_WP_RocketLauncher_Impact_Decal01'
	DecalWidth=128.0
	DecalHeight=128.0
	speed=2000.0
	MaxSpeed=2000.0
	Damage=20.0
	DamageRadius=220.0
	MomentumTransfer=85000
	MyDamageType=class'UTGame.UTDmgType_Rocket'
	LifeSpan=16.0
	AmbientSound=SoundCue'A_Weapon_RocketLauncher.Cue.A_Weapon_RL_Travel_Cue'
	ExplosionSound=SoundCue'A_Weapon_RocketLauncher.Cue.A_Weapon_RL_Impact_Cue'
	RotationRate=(Roll=50000)
	DesiredRotation=(Roll=30000)
	bCollideWorld=true
	CheckRadius=44.0
	bCheckProjectileLight=true
	ProjectileLightClass=class'UTGame.UTRocketLight'
	ExplosionLightClass=class'UTGame.UTRocketExplosionLight'

	bWaitForEffects=true
	bAttachExplosionToVehicles=false
}
