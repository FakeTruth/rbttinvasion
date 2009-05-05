class RBTTIceSlimeGlobling extends RBTTIceSlimeShot;

simulated function ProcessTouch(Actor Other, Vector HitLocation, Vector HitNormal)
{
	if ( Other.bProjTarget && (RBTTIceSlimeGlobling(Other) == None) && !bExploded )
	{
		Other.TakeDamage(Damage, InstigatorController, Location, MomentumTransfer * Normal(Velocity), MyDamageType,, self);
		if(Pawn(Other) != None && RBTTIceSlime(Other) == None)
			FreezeVictim(Pawn(Other));
		
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