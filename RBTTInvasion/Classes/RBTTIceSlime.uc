class RBTTIceSlime extends RBTTSlime;

var float IceTime;
var int IceDamage;
var float IceDamageInterval;

simulated function ProcessInstantHit( byte FiringModeZ, ImpactInfo Impact )
{
	local Pawn P;

	if (Impact.HitActor == None)
		return; 
	
	
	Impact.HitActor.TakeDamage( HitDamage, Controller,
				Impact.HitLocation, Weapon.InstantHitMomentum[FiringModeZ] * Impact.RayDir,
				Class'IceDamage', Impact.HitInfo, Weapon );
	
	P = Pawn(Impact.HitActor);
	if(P == None)
		return;
		
	if(RBTTSlime(P) != None)
		return;
	
	AttachIce(P, Controller, WorldInfo, IceTime, IceDamage, IceDamageInterval);
}

static function AttachIce(Pawn P, Controller IC, WorldInfo WI, int Time, float Damage, float Interval)
{
	local RBTTDamageAttachment DA;
	local InventoryManager IM;

	DA = RBTTDamageAttachment(P.FindInventoryType(Class'RBTTDamageAttachment', True)); // WARNING - Also looks for children of the class RBTTDamageAttachment!
	if(DA != None && RBTTIceAttachment(DA) != None)
	{
		if(DA.DamageTime < Time)						// Add some fuel
			DA.DamageTime = Time;
			
		if(DA.DamageInterval > 0 && Interval > 0 && DA.Damage / DA.DamageInterval < Damage / Interval ) 	// if current fire is weaker than new fire, use new fire
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
			
		DA = WI.Spawn(class'RBTTIceAttachment', WI.Game, , vect(0, 0, 0), rot(0, 0, 0));
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
	IceTime = 10
	IceDamage = 0.f
	IceDamageInterval = 0.f
	
	HitDamage = 10
	
	SlimeGlobClass=Class'RBTTIceSlimeGlob'
  
	Begin Object Name=WPawnSkeletalMeshComponent ObjName=WPawnSkeletalMeshComponent Archetype=SkeletalMeshComponent'UTGame.Default__UTPawn:WPawnSkeletalMeshComponent'
		Materials(0)=MaterialInterface'RBTTSlime.IceSlimeMaterial'
	End Object

}
