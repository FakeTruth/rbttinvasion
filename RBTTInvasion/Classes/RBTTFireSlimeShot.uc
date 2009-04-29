class RBTTFireSlimeShot extends UTProj_BioShot;

var float FireTime;
var int FireDamage;
var float FireDamageInterval;

function SetVictimOnFire(Pawn P)
{
	local RBTTFireAttachment FA;
	local InventoryManager IM;

	FA = RBTTFireAttachment(P.FindInventoryType(Class'RBTTFireAttachment', True)); // WARNING - Also looks for children of the class RBTTFireAttachment!
	if(FA != None)
	{
		if(FA.DamageTime < FireTime)						// Add some fuel
			FA.DamageTime = FireTime;
		if(FA.Damage / FA.DamageInterval < FireDamage / FireDamageInterval ) 	// if current fire is weaker than new fire, use new fire
		{
			FA.Damage = FireDamage;
			FA.DamageInterval = FireDamageInterval;
		}
		
		FA.InitFire();
	}
	else
	{
		IM = P.InvManager;
		if(IM == None)
			return;
			
		FA = Spawn(class'RBTTFireAttachment', WorldInfo.Game, , vect(0, 0, 0), rot(0, 0, 0));
		IM.AddInventory(FA);
		FA.SetBase(P);
		FA.Victim = P;
		FA.InstigatorController = InstigatorController;
		FA.Damage = FireDamage;
		FA.DamageInterval = FireDamageInterval;
		FA.DamageTime = FireTime;
		FA.InitFire();
		FA.InitFireClient();
	}
}

defaultproperties
{
	FireTime = 2.f
	FireDamage = 1.f
	FireDamageInterval = 0.25f

	Speed=2000.0
	Damage=21.0
	MomentumTransfer=40000
	MyDamageType=class'FireDamage'
	LifeSpan=12.0
	RotationRate=(Pitch=50000)
	DesiredRotation=(Pitch=30000)
	bCollideWorld=true
	TossZ=0.0
	MaxEffectDistance=7000.0
	Buoyancy=1.5

	RestTime=3.0
	DripTime=1.8
	CheckRadius=40.0


	//	ProjFlightTemplate=ParticleSystem'Envy_Effects.FX.Bio_Splat'
	ProjExplosionTemplate=ParticleSystem'RBTTSlime.Particles.Fire_Bio_Primary_PoP'
	HitPawnTemplate=ParticleSystem'RBTTSlime.Particles.Fire_Bio_Player_Hit'
	HitBioTemplate=ParticleSystem'RBTTSlime.Particles.Fire_Bio_Blob_hits_Blob_Burst'
	ExplosionLightClass=class'UTGame.UTBioExplosionLight'

	Explosionsound=SoundCue'A_Weapon_BioRifle.Weapon.A_BioRifle_FireImpactExplode_Cue'
	ImpactSound=SoundCue'A_Weapon_BioRifle.Weapon.A_BioRifle_FireImpactExplode_Cue'
	Physics=PHYS_Falling

	Begin Object Name=CollisionCylinder
		CollisionRadius=0
		CollisionHeight=0
		CollideActors=true
	End Object

	Begin Object Name=ProjectileMesh
		StaticMesh=StaticMesh'WP_BioRifle.Mesh.S_Bio_Ball'
		CullDistance=12000
		CollideActors=false
		CastShadow=false
		bAcceptsLights=false
		BlockRigidBody=false
		BlockActors=false
		bUseAsOccluder=FALSE
		Materials(0)=MaterialInterface'RBTTSlime.FlameSlimeMaterial'
	End Object
	Components.Add(ProjectileMesh)
	GooMesh=ProjectileMesh

	WallHit=ParticleSystem'RBTTSlime.Particles.Fire_Bio_Impact_Primary_Wall';
	FloorHit=ParticleSystem'RBTTSlime.Particles.Fire_Bio_Impact_Primary_Floor';
	CeilingHit=ParticleSystem'RBTTSlime.Particles.Fire_Bio_Impact_Primary_Ceiling';

	WallThreshold = 0.3f;
	GooDecalTemplate=MaterialInterface'RBTTSlime.Materials.Fire_Bio_Splat_DecalBio_Splat_Decal'
	bWaitForEffects=false

	GooDecalChoices[0]=MaterialInterface'RBTTSlime.Materials.Fire_Bio_Splat_DecalBio_Splat_Decal'
	GooDecalChoices[1]=MaterialInterface'RBTTSlime.Materials.Fire_Bio_Splat_DecalBio_Splat_Decal'
	SteppedInSound=SoundCue'A_Weapon_BioRifle.Weapon.A_BioRifle_FireImpactFizzle_Cue'
	HitMode=HIT_None
}