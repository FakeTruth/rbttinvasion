class RBTTIceSlime extends RBTTSlime;

var float IceTime;
var int IceDamage;
var float IceDamageInterval;

simulated function ProcessInstantHit( byte FiringModeZ, ImpactInfo Impact )
{
	local Pawn P;
	local RBTTIceAttachment IA;
	local InventoryManager IM;

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
	
	IA = RBTTIceAttachment(P.FindInventoryType(Class'RBTTIceAttachment', True)); // WARNING - Also looks for children of the class RBTTIceAttachment!
	if(IA != None)
	{
		if(IA.DamageTime < IceTime)						// Add some fuel
			IA.DamageTime = IceTime;
		if(IA.Damage / IA.DamageInterval < IceDamage / IceDamageInterval ) 	// if current fire is weaker than new fire, use new fire
		{
			IA.Damage = IceDamage;
			IA.DamageInterval = IceDamageInterval;
		}
		
		IA.InitIce();
	}
	else
	{
		IM = P.InvManager;
		if(IM == None)
			return;
			
		IA = Spawn(class'RBTTIceAttachment', WorldInfo.Game, , vect(0, 0, 0), rot(0, 0, 0));
		IM.AddInventory(IA);
		IA.SetBase(P);
		IA.Victim = P;
		IA.InstigatorController = Controller;
		IA.Damage = IceDamage;
		IA.DamageInterval = IceDamageInterval;
		IA.DamageTime = IceTime;
		IA.InitIce();
		IA.InitIceClient();
	}
}

defaultproperties
{
	IceTime = 10.f
	IceDamage = 1.f
	IceDamageInterval = 0.25f
	
	HitDamage = 10
	
	SlimeGlobClass=Class'RBTTIceSlimeGlob'
  
	Begin Object Name=WPawnSkeletalMeshComponent ObjName=WPawnSkeletalMeshComponent Archetype=SkeletalMeshComponent'UTGame.Default__UTPawn:WPawnSkeletalMeshComponent'
		Materials(0)=MaterialInterface'RBTTSlime.IceSlimeMaterial'
	End Object

}
