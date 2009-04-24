class Pickup_Health extends Pickup_Base;

// ************************************** \\
//  MiscOption1 is the ammount of health  \\
//  MiscOption2 is heal over max yes/no   \\
// ************************************** \\

// Calculate how much the player can get healed
function int HealAmount(Pawn Recipient)
{
	return FClamp(Recipient.HealthMax - Recipient.Health, 0, MiscOption1);
}

// Give pickup to player
function GiveTo( Pawn P )
{
	if(MiscOption2 == 1)
		P.Health += MiscOption1;
	else
		P.Health += HealAmount(P);

	Super.GiveTo(P);
}

defaultproperties
{
   Begin Object Class=DynamicLightEnvironmentComponent Name=PickupLightEnvironment ObjName=PickupLightEnvironment Archetype=DynamicLightEnvironmentComponent'RBTTInvasion.Default__Pickup_Base:PickupLightEnvironment'
      ObjectArchetype=DynamicLightEnvironmentComponent'RBTTInvasion.Default__Pickup_Base:PickupLightEnvironment'
   End Object
   LightEnvironment=PickupLightEnvironment
   PickupSound=SoundCue'A_Pickups.Health.Cue.A_Pickups_Health_Small_Cue_Modulated'
   PickupMessage="You picked up some health!"
   Begin Object Class=SpriteComponent Name=Sprite ObjName=Sprite Archetype=SpriteComponent'RBTTInvasion.Default__Pickup_Base:Sprite'
      ObjectArchetype=SpriteComponent'RBTTInvasion.Default__Pickup_Base:Sprite'
   End Object
   Components(0)=Sprite
   Begin Object Class=CylinderComponent Name=CollisionCylinder ObjName=CollisionCylinder Archetype=CylinderComponent'RBTTInvasion.Default__Pickup_Base:CollisionCylinder'
      ObjectArchetype=CylinderComponent'RBTTInvasion.Default__Pickup_Base:CollisionCylinder'
   End Object
   Components(1)=CollisionCylinder
   Components(2)=PickupLightEnvironment
   Begin Object Class=StaticMeshComponent Name=PickUpComp ObjName=PickUpComp Archetype=StaticMeshComponent'RBTTInvasion.Default__Pickup_Base:PickUpComp'
      StaticMesh=StaticMesh'PICKUPS.Health_Medium.Mesh.S_Pickups_Health_Medium'
      CullDistance=7000.000000
      CachedCullDistance=7000.000000
      ObjectArchetype=StaticMeshComponent'RBTTInvasion.Default__Pickup_Base:PickUpComp'
   End Object
   Components(3)=PickUpComp
   CollisionComponent=CollisionCylinder
   Name="Default__Pickup_Health"
   ObjectArchetype=Pickup_Base'RBTTInvasion.Default__Pickup_Base'
}
