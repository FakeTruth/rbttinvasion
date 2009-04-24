class Pickup_Base extends Actor;

//-----------------------------------------------------------------------------
// AI related info.
//var	repnotify	class<Inventory>		InventoryClass;		// Class of the inventory object to pickup
var	repnotify	class<PickupFactory>		InventoryClass;
var	repnotify	bool				bFadeOut;
var	transient PrimitiveComponent	PickupMesh;
// The pickup's light environment
var 		DynamicLightEnvironmentComponent 	LightEnvironment;
var		SoundCue				PickupSound;
var		localized string			PickupMessage;			// Human readable description when picked up.

var int MiscOption1, MiscOption2; // Additional parameters for dynamically assigning values

native final function AddToNavigation();			// cache dropped inventory in navigation network
native final function RemoveFromNavigation();


replication
{
	if( Role==ROLE_Authority )
		InventoryClass, bFadeOut;
}

static function string GetLocalString(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2
	)
{
	return Default.PickupMessage;
}

simulated event ReplicatedEvent(name VarName)
{
	if( VarName == 'InventoryClass' )
	{
		//SetPickupMesh( InventoryClass.default.PickupMesh );
	}
	else if ( VarName == 'bFadeOut' )
	{
		GotoState('Fadeout');
	}
	else
	{
		super.ReplicatedEvent(VarName);
	}
}

/* Reset()
reset actor to initial state - used when restarting level without reloading.
*/
function Reset()
{
	Destroy();
}

/**
 * Set Pickup mesh to use.
 * Replicated through InventoryClass to remote clients using Inventory.DroppedPickup component as default mesh.
 */
/*
simulated event SetPickupMesh(PrimitiveComponent PickupMesh)
{
	local ActorComponent Comp;

	if (PickupMesh != None && WorldInfo.NetMode != NM_DedicatedServer )
	{
		Comp = new(self) PickupMesh.Class(PickupMesh);
		AttachComponent(Comp);
	}
}
*/

event EncroachedBy(Actor Other)
{
	Destroy();
}

event Landed(Vector HitNormal, Actor FloorActor)
{
	// force full net update
	bForceNetUpdate = TRUE;
	bNetDirty = true;
	// reduce frequency since the pickup isn't moving anymore
	NetUpdateFrequency = 3;
}

/** give pickup to player */
function GiveTo( Pawn P )
{
	P.PlaySound( PickupSound );
	P.MakeNoise(0.2);
	
	if ( PlayerController(P.Controller) != None )
	{
		PlayerController(P.Controller).ReceiveLocalizedMessage(MessageClass,,,,class);
	}
	
	PickedUpBy(P);
}

function PickedUpBy(Pawn P)
{
	Destroy();
}

function RecheckValidTouch();

//=============================================================================
// Pickup state: this inventory item is sitting on the ground.

auto state Pickup
{
	/*
	 Validate touch (if valid return true to let other pick me up and trigger event).
	*/
	function bool ValidTouch(Pawn Other)
	{
		// make sure its a live player
		if (Other == None || !Other.bCanPickupInventory || (Other.DrivenVehicle == None && Other.Controller == None))
		{
			return false;
		}

		// make sure thrower doesn't run over own weapon
		if ( (Physics == PHYS_Falling) && (Other == Instigator) && (Velocity.Z > 0) )
		{
			return false;
		}

		// make sure not touching through wall
		if ( !FastTrace(Other.Location, Location) )
		{
			SetTimer(0.5, false, 'RecheckValidTouch');
			return false;
		}

		return true;
	}

	/**
	Pickup was touched through a wall.  Check to see if touching pawn is no longer obstructed
	*/
	function RecheckValidTouch()
	{
		CheckTouching();
	}

	// When touched by an actor.
	event Touch( Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal )
	{
		local Pawn P;

		// If touched by a player pawn, let him pick this up.
		P = Pawn(Other);
		if( P != None && ValidTouch(P) )
		{
			GiveTo(P);
		}
	}

	event Timer()
	{
		GotoState('FadeOut');
	}

	function CheckTouching()
	{
		local Pawn P;

		foreach TouchingActors(class'Pawn', P)
		{
			Touch( P, None, Location, vect(0,0,1) );
		}
	}

Begin:
		CheckTouching();
}

State FadeOut extends Pickup
{
	simulated event BeginState(Name PreviousStateName)
	{
		bFadeOut = true;
		RotationRate.Yaw=60000;
		SetPhysics(PHYS_Rotating);
		LifeSpan = 1.0;
	}
}

defaultproperties
{
   Begin Object Class=DynamicLightEnvironmentComponent Name=PickupLightEnvironment ObjName=PickupLightEnvironment Archetype=DynamicLightEnvironmentComponent'Engine.Default__DynamicLightEnvironmentComponent'
      AmbientGlow=(R=0.300000,G=0.300000,B=0.300000,A=1.000000)
      bCastShadows=False
      bDynamic=False
      Name="PickupLightEnvironment"
      ObjectArchetype=DynamicLightEnvironmentComponent'Engine.Default__DynamicLightEnvironmentComponent'
   End Object
   LightEnvironment=PickupLightEnvironment
   PickupSound=SoundCue'A_Pickups.Armor.Cue.A_Pickups_Armor_Chest_Cue'
   PickupMessage="You picked up an item that a monster dropped!"
   Begin Object Class=SpriteComponent Name=Sprite ObjName=Sprite Archetype=SpriteComponent'Engine.Default__SpriteComponent'
      Sprite=Texture2D'EngineResources.S_Inventory'
      HiddenGame=True
      AlwaysLoadOnClient=False
      AlwaysLoadOnServer=False
      Name="Sprite"
      ObjectArchetype=SpriteComponent'Engine.Default__SpriteComponent'
   End Object
   Components(0)=Sprite
   Begin Object Class=CylinderComponent Name=CollisionCylinder ObjName=CollisionCylinder Archetype=CylinderComponent'Engine.Default__CylinderComponent'
      CollisionHeight=20.000000
      CollisionRadius=30.000000
      CollideActors=True
      Name="CollisionCylinder"
      ObjectArchetype=CylinderComponent'Engine.Default__CylinderComponent'
   End Object
   Components(1)=CollisionCylinder
   Components(2)=PickupLightEnvironment
   Begin Object Class=StaticMeshComponent Name=PickUpComp ObjName=PickUpComp Archetype=StaticMeshComponent'Engine.Default__StaticMeshComponent'
      LightEnvironment=DynamicLightEnvironmentComponent'RBTTInvasion.Default__Pickup_Base:PickupLightEnvironment'
      CullDistance=8000.000000
      CachedCullDistance=8000.000000
      bUseAsOccluder=False
      CastShadow=False
      bForceDirectLightMap=True
      bCastDynamicShadow=False
      CollideActors=False
      Name="PickUpComp"
      ObjectArchetype=StaticMeshComponent'Engine.Default__StaticMeshComponent'
   End Object
   Components(3)=PickUpComp
   RemoteRole=ROLE_SimulatedProxy
   bIgnoreRigidBodyPawns=True
   bOrientOnSlope=True
   bUpdateSimulatedPosition=True
   bOnlyDirtyReplication=True
   bShouldBaseAtStartup=True
   bCollideActors=True
   bCollideWorld=True
   NetUpdateFrequency=8.000000
   NetPriority=1.400000
   LifeSpan=16.000000
   CollisionComponent=CollisionCylinder
   RotationRate=(Pitch=0,Yaw=5000,Roll=0)
   DesiredRotation=(Pitch=0,Yaw=30000,Roll=0)
   MessageClass=Class'UTGame.UTPickupMessage'
   Name="Default__Pickup_Base"
   ObjectArchetype=Actor'Engine.Default__Actor'
}
