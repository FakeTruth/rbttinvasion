class RBTTFireSlime extends RBTTSlime;

var float FireTime;
var int FireDamage;
var float FireDamageInterval;

simulated function ProcessInstantHit( byte FiringModeZ, ImpactInfo Impact )
{
	local Pawn P;

	if (Impact.HitActor == None)
		return; 
	
	
	Impact.HitActor.TakeDamage( HitDamage, Controller,
				Impact.HitLocation, Weapon.InstantHitMomentum[FiringModeZ] * Impact.RayDir,
				Class'FireDamage', Impact.HitInfo, Weapon );
	
	P = Pawn(Impact.HitActor);
	if(P == None)
		return;
		
	if(RBTTSlime(P) != None)
		return;
		
	AttachFire(P, Controller, WorldInfo, FireTime, FireDamage, FireDamageInterval);
}

static function AttachFire(Pawn P, Controller IC, WorldInfo WI, int Time, float Damage, float Interval)
{
	local RBTTDamageAttachment DA;
	local InventoryManager IM;

	DA = RBTTDamageAttachment(P.FindInventoryType(Class'RBTTDamageAttachment', True)); // WARNING - Also looks for children of the class RBTTDamageAttachment!
	if(DA != None && RBTTFireAttachment(DA) != None)
	{
		if(DA.DamageTime < Time)						// Add some fuel
			DA.DamageTime = Time;
		if(DA.Damage / DA.DamageInterval < Damage / Interval ) 	// if current fire is weaker than new fire, use new fire
		{
			DA.Damage = Damage;
			DA.DamageInterval = Interval;
		}
		
		DA.InstigatorController = IC;
		DA.Init();
	}
	else
	{
		if(DA != None)
		{
			DA.Destroy();
		}
		
		IM = P.InvManager;
		if(IM == None)
			return;
			
		DA = WI.Spawn(class'RBTTFireAttachment', WI.Game, , vect(0, 0, 0), rot(0, 0, 0));
		IM.AddInventory(DA);
		DA.SetBase(P);
		DA.Victim = P;
		DA.InstigatorController = IC;
		DA.Damage = Damage;
		DA.DamageInterval = Interval;
		DA.DamageTime = Time;
		DA.Init();
		DA.InitClient();
	}

}

defaultproperties
{
	FireTime = 10
	FireDamage = 1.f
	FireDamageInterval = 0.25f
	
	HitDamage = 10
	
	SlimeGlobClass=Class'RBTTFireSlimeGlob'
  
	Begin Object Name=WPawnSkeletalMeshComponent ObjName=WPawnSkeletalMeshComponent Archetype=SkeletalMeshComponent'UTGame.Default__UTPawn:WPawnSkeletalMeshComponent'
		Materials(0)=MaterialInterface'RBTTSlime.FlameSlimeMaterial'
	End Object

}
