class RBTTFireSlimeGlobling extends RBTTFireSlimeShot;

simulated function ProcessTouch(Actor Other, Vector HitLocation, Vector HitNormal)
{
	if ( Other.bProjTarget && (RBTTFireSlimeGlob(Other) == None) && !bExploded )
	{
		Other.TakeDamage(Damage, InstigatorController, Location, MomentumTransfer * Normal(Velocity), MyDamageType,, self);
		if(Pawn(Other) != None && RBTTFireSlime(Other) == None)
			SetVictimOnFire(Pawn(Other));
			
		Explode( HitLocation, HitNormal );
	}
}

auto state Flying
{
	simulated function ProcessTouch(Actor Other, Vector HitLocation, Vector HitNormal)
	{
		Global.ProcessTouch(Other, HitLocation, HitNormal);
   	}
}

state OnGround
{
	simulated function ProcessTouch(Actor Other, Vector HitLocation, Vector HitNormal)
	{
		Global.ProcessTouch(Other, HitLocation, HitNormal);
	}
}