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
	PickupMessage = "You picked up an item that a monster dropped!";
	MessageClass=class'UTPickupMessage'
	PickupSound=SoundCue'A_Pickups.Armor.Cue.A_Pickups_Armor_Chest_Cue'

	Begin Object Class=SpriteComponent Name=Sprite
		Sprite=Texture2D'EngineResources.S_Inventory'
		HiddenGame=True
		AlwaysLoadOnClient=False
		AlwaysLoadOnServer=False
	End Object
	Components.Add(Sprite)

	Begin Object Class=CylinderComponent NAME=CollisionCylinder
		CollisionRadius=+00030.000000
		CollisionHeight=+00020.000000
		CollideActors=true
	End Object
	CollisionComponent=CollisionCylinder
	Components.Add(CollisionCylinder)

 	Begin Object Class=DynamicLightEnvironmentComponent Name=PickupLightEnvironment
 	    bDynamic=FALSE
 	    bCastShadows=FALSE
		AmbientGlow=(R=0.3f,G=0.3f,B=0.3f,A=1.0f)
 	End Object
  	LightEnvironment=PickupLightEnvironment
  	Components.Add(PickupLightEnvironment)
	
	Begin Object Class=StaticMeshComponent Name=PickUpComp
		AlwaysLoadOnClient=true
		AlwaysLoadOnServer=true

		CastShadow=FALSE
		bAcceptsLights=TRUE
		bForceDirectLightMap=TRUE
		bCastDynamicShadow=FALSE
		LightEnvironment=PickupLightEnvironment

		CollideActors=false
		CullDistance=8000
		bUseAsOccluder=FALSE
	End Object
	PickupMesh=PickUpComp
	Components.Add(PickUpComp)
	
	bOnlyDirtyReplication=true
	NetUpdateFrequency=8
	RemoteRole=ROLE_SimulatedProxy
	bHidden=false
	NetPriority=+1.4
	bCollideActors=true
	bCollideWorld=true
	RotationRate=(Yaw=5000)
	DesiredRotation=(Yaw=30000)
	bOrientOnSlope=true
	bShouldBaseAtStartup=true
	bIgnoreEncroachers=false
	bIgnoreRigidBodyPawns=true
	bUpdateSimulatedPosition=true
	LifeSpan=+16.0
}