class Pickup_Armor extends Pickup_Base;

// ************************************** \\
//  MiscOption1 is the ammount of armor   \\
//  MiscOption2 is heal over max yes/no   \\
// ************************************** \\

// Returns how many shield units P could use
function int CanUseShield(UTPawn P)
{
	return Max(0,MiscOption1 - P.VestArmor);
}

// Give pickup to player
function GiveTo( Pawn P )
{
	if(UTPawn(P) == None)
		return;
	
	if(MiscOption2 == 1)
		UTPawn(P).VestArmor += MiscOption1; //P.VestArmor = Max(ShieldAmount, P.VestArmor);
	else
		UTPawn(P).VestArmor += CanUseShield(UTPawn(P));

	Super.GiveTo(P);
}

defaultproperties
{
   Begin Object Class=DynamicLightEnvironmentComponent Name=PickupLightEnvironment ObjName=PickupLightEnvironment Archetype=DynamicLightEnvironmentComponent'RBTTInvasion.Default__Pickup_Base:PickupLightEnvironment'
      ObjectArchetype=DynamicLightEnvironmentComponent'RBTTInvasion.Default__Pickup_Base:PickupLightEnvironment'
   End Object
   LightEnvironment=PickupLightEnvironment
   PickupMessage="You picked up some armor!"
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
      StaticMesh=StaticMesh'PICKUPS.Armor.Mesh.S_Pickups_Armor'
      Translation=(X=0.000000,Y=0.000000,Z=-50.000000)
      ObjectArchetype=StaticMeshComponent'RBTTInvasion.Default__Pickup_Base:PickUpComp'
   End Object
   Components(3)=PickUpComp
   CollisionComponent=CollisionCylinder
   Name="Default__Pickup_Armor"
   ObjectArchetype=Pickup_Base'RBTTInvasion.Default__Pickup_Base'
}
