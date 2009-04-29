class RBTTFireSlime extends RBTTSlime;

var float FireTime;
var int FireDamage;
var float FireDamageInterval;

simulated function ProcessInstantHit( byte FiringModeZ, ImpactInfo Impact )
{
	local Pawn P;
	local RBTTFireAttachment FA;
	local InventoryManager IM;

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
		FA.InstigatorController = Controller;
		FA.Damage = FireDamage;
		FA.DamageInterval = FireDamageInterval;
		FA.DamageTime = FireTime;
		FA.InitFire();
		FA.InitFireClient();
	}
}

defaultproperties
{
	FireTime = 10.f
	FireDamage = 1.f
	FireDamageInterval = 0.25f
	
	HitDamage = 10
	
	SlimeGlobClass=Class'RBTTFireSlimeGlob'
  
	Begin Object Name=WPawnSkeletalMeshComponent ObjName=WPawnSkeletalMeshComponent Archetype=SkeletalMeshComponent'UTGame.Default__UTPawn:WPawnSkeletalMeshComponent'
		Materials(0)=MaterialInterface'RBTTSlime.FlameSlimeMaterial'
	End Object

}
