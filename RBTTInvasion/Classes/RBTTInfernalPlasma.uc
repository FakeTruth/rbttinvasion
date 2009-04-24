class RBTTInfernalPlasma extends UTProj_SeekingRocket;

simulated function PostBeginPlay()
{
	// force ambient sound if not vehicle game mode
	bImportantAmbientSound = !WorldInfo.bDropDetail && (UTOnslaughtGRI(WorldInfo.GRI) == None);
	Super.PostBeginPlay();
}

defaultproperties
{
   ProjFlightTemplate=None
   CheckRadius=44.000000
   Speed=2000.000000
   MaxSpeed=2000.000000
   Damage=20.000000
   MyDamageType=Class'RBTTInvasion.RBTTInfernalPlasmaDamage'
   Begin Object Class=CylinderComponent Name=CollisionCylinder ObjName=CollisionCylinder Archetype=CylinderComponent'UTGame.Default__UTProj_SeekingRocket:CollisionCylinder'
      ObjectArchetype=CylinderComponent'UTGame.Default__UTProj_SeekingRocket:CollisionCylinder'
   End Object
   CylinderComponent=CollisionCylinder
   Components(0)=CollisionCylinder
   LifeSpan=16.000000
   CollisionComponent=CollisionCylinder
   Name="Default__RBTTInfernalPlasma"
   ObjectArchetype=UTProj_SeekingRocket'UTGame.Default__UTProj_SeekingRocket'
}
