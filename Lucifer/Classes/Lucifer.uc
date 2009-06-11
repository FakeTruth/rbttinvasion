class Lucifer extends RBTTMonster config(Lucifer);


var name DeathAnim[4];
var byte sprayoffset;
var	float Momentum;
var	class<DamageType>  MyDamageType;
var	vector				mHitLocation,mHitNormal;
var	rotator				mHitRot;
var  Sound DeathSound[2];
var config float fHealth;
var LuciferFlames Flames; 
var FireProperties RocketFireProperties;
var class<Ammunition> RocketAmmoClass;
var Ammunition RocketAmmo;
var()  bool	bNoTelefrag; 
var()	float	InvalidityMomentumSize;
var() bool bNoCrushVehicle;
var()  array<class<DamageType> >	ReducedDamTypes;
var()  float	ReducedDamPct;
var()  array<class<DamageType> >	WeakDamTypes;
var()  float	WeakDamPct;
var()  bool	bReduceDamPlayerNum; 
var		bool				bStomped,bThrowed;
var		int					ThrowCount;
var() name StompEvent;
var() name StepEvent;
var() sound Step;
var() sound StompSound;
var() sound Laugh;

replication
{
  reliable if ( Role == ROLE_Authority )
    mHitLocation, mHitNormal, Smoke;
}

function PreBeginPlay()
{
	Super.PreBeginPlay();
	Health = fHealth;
}

event PostBeginPlay()
{
	Super.PostBeginPlay();
        RocketAmmo=spawn(RocketAmmoClass);
        PlaySound(Sound'LuciferBOSS.LuciferLaugh');
}

event EncroachedBy( actor Other )
{
	local float Speed;
	local vector Dir,Momentum;
	if ( xPawn(Other) != None && bNoTelefrag)
		return;
	if(bNoCrushVehicle && Vehicle(Other)!=none)
	{
		Speed=VSize(Vehicle(Other).Velocity);
		Dir=Normal(Vehicle(Other).Velocity);
		log("dot=" $ Dir dot Normal(Location-Other.Location));

		if(Dir dot Normal(Location-Other.Location)>0)
		{
			Dir=-Dir;
			Momentum=Dir*Speed*Mass*0.1;
			Vehicle(Other).KAddImpulse(Momentum, Other.location);
		}
	}

	super.EncroachedBy(Other);
}

function PlayVictory()
{
	Controller.bPreparingMove = true;
	Acceleration = vect(0,0,0);
	bShotAnim = true;
    	PlaySound(Sound'LuciferBOSS.LuciferLaugh');
	SetAnimAction('gesture_cheer');
	Controller.Destination = Location;
	Controller.GotoState('TacticalMove','WaitForAnim');
}

function PlaySoundINI()
{
	PlaySound(Sound'LuciferBOSS.LuciferHit3');
}

function SpawnRocket()
{
	local vector RotX,RotY,RotZ,StartLoc;
	local LuciferProj R;

	GetAxes(Rotation, RotX, RotY, RotZ);
	StartLoc=GetFireStart(RotX, RotY, RotZ);
	if ( !RocketFireProperties.bInitialized )
	{
		RocketFireProperties.AmmoClass = RocketAmmo.Class;
		RocketFireProperties.ProjectileClass = RocketAmmo.default.ProjectileClass;
		RocketFireProperties.WarnTargetPct = RocketAmmo.WarnTargetPct;
		RocketFireProperties.MaxRange = RocketAmmo.MaxRange;
		RocketFireProperties.bTossed = RocketAmmo.bTossed;
		RocketFireProperties.bTrySplash = RocketAmmo.bTrySplash;
		RocketFireProperties.bLeadTarget = RocketAmmo.bLeadTarget;
		RocketFireProperties.bInstantHit = RocketAmmo.bInstantHit;
		RocketFireProperties.bInitialized = true;
	}

	R=LuciferProj(Spawn(RocketAmmo.ProjectileClass,,,StartLoc,Controller.AdjustAim(RocketFireProperties,StartLoc,600))); 
	}
	
simulated function PlayDirectionalHit(Vector HitLoc)
{
    local Vector X,Y,Z, Dir;

	if ( DrivenVehicle != None )
		return;

    GetAxes(Rotation, X,Y,Z);
    HitLoc.Z = Location.Z;

    // random
    if ( VSize(Location - HitLoc) < 1.0 )
    {
        Dir = VRand();
    }
    // hit location based
    else
    {
        Dir = -Normal(Location - HitLoc);
    }

    if ( Dir Dot X > 0.7 || Dir == vect(0,0,0))
    {
        PlayAnim('HitF',, 0.1);
    }
    else if ( Dir Dot X < -0.7 )
    {
        PlayAnim('HitB',, 0.1);
    }
    else if ( Dir Dot Y > 0 )
    {
        PlayAnim('HitL',, 0.1);
    }
    else
    {
        PlayAnim('HitR',, 0.1);
    }
}

function bool SameSpeciesAs(Pawn P)
{
	return ( Monster(P) != none &&
		(P.IsA('SMPTitan') || P.IsA('SMPQueen') || P.IsA('Monster')|| P.IsA('Skaarj') || P.IsA('SkaarjPupae') || P.IsA('LuciferBOSS')));
}

simulated function Smoke()
{
 	Flames = Spawn(class'LuciferFlames',,,Location - vect(0,0,+50),Rotation); ///add flames here (xemitter)
}

function RangedAttack(Actor A)
{
	local float decision;
	if ( bShotAnim )
		return;
	bShotAnim=true;
	decision = FRand();

	if ( Physics == PHYS_Swimming )
		SetAnimAction('Swim_Tread');
	else if ( Velocity == vect(0,0,0) )
	{
		if (decision < 0.35)
		{
			SetAnimAction('Weapon_Switch');
                      DoFireEffect();
		}
		else
		{
			sprayoffset = 0;
			SetAnimAction('Weapon_Switch');
                       DoFireEffect();
		}
		Acceleration = vect(0,0,0);
	}
	else
	{
		if (decision < 0.35)
		{
			SetAnimAction('Weapon_Switch');
			DoFireEffect();
			Stomp();
		}
		else
		{
			sprayoffset = 0;
			SetAnimAction('Weapon_Switch');
			DoFireEffect();
			Stomp();
			

		}
	}
}

function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation,
						vector momentum, class<DamageType> damageType)
{
	local int i;
	local float DamageProb;

	if(InvalidityMomentumSize>VSize(momentum))
		momentum=vect(0,0,0);

	for(i=0;i<ReducedDamTypes.length;i++)
		if(damageType==ReducedDamTypes[i])
			Damage*=ReducedDamPct;

	for(i=0;i<WeakDamTypes.length;i++)
		if(damageType==WeakDamTypes[i])
			Damage*=WeakDamPct;


	if(Damage>0)
	{
		if(bReduceDamPlayerNum)
		{
			DamageProb=float(Damage)/(Level.Game.NumPlayers+Level.Game.NumBots);
			if(DamageProb<1 && Frand()<DamageProb)
				Damage=1;
			else
				Damage=DamageProb;

		}
	}

	if(bNoCrushVehicle && class<DamTypeRoadkill>(damageType)!=none && Damage>10)
		Damage=10;
	super.TakeDamage(Damage,instigatedBy,hitlocation,momentum,damageType);
}

function Stomp()
{
	local pawn Thrown;

	TriggerEvent(StompEvent,Self, Instigator);
 	Mass=default.Mass*(CollisionRadius/default.CollisionRadius);
	foreach CollidingActors( class 'Pawn', Thrown,Mass)
		ThrowOther(Thrown,Mass/4);
	PlaySound(Step, SLOT_Interact, 24);
	bStomped=true;
}

function FootStep()
{
	local pawn Thrown;

	TriggerEvent(StepEvent,Self, Instigator);
	foreach CollidingActors( class 'Pawn', Thrown,Mass*0.5)
		ThrowOther(Thrown,Mass/12);
	PlaySound(Step, SLOT_Interact, 24);
}

function ThrowOther(Pawn Other,int Power)
{
	local float dist, shake;
	local vector Momentum;


	if ( Other.mass >= Mass )
		return;

	if (xPawn(Other)==none)
	{
		if ( Power<400 || (Other.Physics != PHYS_Walking) )
			return;
		dist = VSize(Location - Other.Location);
		if (dist > Mass)
			return;
	}
	else
	{

		dist = VSize(Location - Other.Location);
		shake = 0.4*FMax(500, Mass - dist);
		shake=FMin(2000,shake);
		if ( dist > Mass )
			return;
		if(Other.Controller!=none)
			Other.Controller.ShakeView( vect(0.0,0.02,0.0)*shake, vect(0,1000,0),0.003*shake, vect(0.02,0.02,0.02)*shake, vect(1000,1000,1000),0.003*shake);

		if ( Other.Physics != PHYS_Walking )
			return;
	}

	Momentum = 100 * Vrand();
	Momentum.Z = FClamp(0,Power,Power - ( 0.4 * dist + Max(10,Other.Mass)*10));
	Other.AddVelocity(Momentum);
}

simulated function vector GetFireStart(vector X, vector Y, vector Z)
{
		return Location + CollisionRadius * ( X + 0.4 * Y + 0.1 * Z);
}

simulated function InitEffects()
{
	local vector RotX,RotY,RotZ;
	local vector FireStartLoc;

    // don't even spawn on server
    if ( Level.NetMode == NM_DedicatedServer )
		return;
	GetAxes(Rotation, RotX, RotY, RotZ);
	FireStartLoc=GetFireStart(RotX, RotY, RotZ);

}

simulated function DoFireEffect() 
{

Smoke(); 
SpawnRocket(); 
PlaySoundINI(); 

}

simulated function PlayDying(class<DamageType> DamageType, vector HitLoc)
{
    bCanTeleport = false; 
    bReplicateMovement = false;
    bTearOff = true;
    bPlayedDeath = true;

	LifeSpan = RagdollLifeSpan;
    GotoState('Dying');
		
	Velocity += TearOffMomentum;
    BaseEyeHeight = Default.BaseEyeHeight;
    SetInvisibility(0.0);
    PlayDirectionalDeath(HitLoc);
    SetPhysics(PHYS_Falling);
    PlaySound(DeathSound[Rand(2)], SLOT_Pain,1000*TransientSoundVolume, true,800); //correct code
}

defaultproperties
{
     DeathAnim(0)="DeathF"
     DeathAnim(1)="DeathL"
     DeathAnim(2)="DeathR"
     DeathSound(0)=Sound'LuciferBOSS.LuciferDeath'
     DeathSound(1)=Sound'LuciferBOSS.LuciferDeath'
     fHealth=3000.000000
     RocketAmmoClass=Class'LuciferBOSS.LuciferAmmo'
     bNoTeleFrag=True
     InvalidityMomentumSize=100000.000000
     bNoCrushVehicle=True
     Step=Sound'LuciferBOSS.LuciferStep'
     StompSound=Sound'LuciferBOSS.LuciferStomp'
     Laugh=Sound'LuciferBOSS.LuciferLaugh'
     bCanDodge=False
     bBoss=True
     HitSound(0)=Sound'LuciferBOSS.LuciferHit1'
     HitSound(1)=Sound'LuciferBOSS.LuciferHit2'
     HitSound(2)=Sound'LuciferBOSS.LuciferHit1'
     HitSound(3)=Sound'LuciferBOSS.LuciferHit2'
     AmmunitionClass=Class'LuciferBOSS.LuciferAmmo'
     ScoringValue=25
     bCanSwim=False
     MeleeRange=150.000000
     GroundSpeed=350.000000
     AccelRate=2000.000000
     JumpZ=0.000000
     Health=900
     MovementAnims(0)="WalkF"
     MovementAnims(1)="WalkF"
     MovementAnims(2)="WalkF"
     MovementAnims(3)="WalkF"
     TurnLeftAnim="TurnL"
     TurnRightAnim="TurnR"
     WalkAnims(1)="WalkF"
     WalkAnims(2)="WalkF"
     WalkAnims(3)="WalkF"
     AirAnims(0)="Jump_Takeoff"
     AirAnims(1)="Jump_Takeoff"
     AirAnims(2)="Jump_Takeoff"
     AirAnims(3)="Jump_Takeoff"
     TakeoffAnims(0)="Jump_Takeoff"
     TakeoffAnims(1)="Jump_Takeoff"
     TakeoffAnims(2)="Jump_Takeoff"
     TakeoffAnims(3)="Jump_Takeoff"
     LandAnims(0)="Jump_Land"
     LandAnims(1)="Jump_Land"
     LandAnims(2)="Jump_Land"
     LandAnims(3)="Jump_Land"
     DodgeAnims(0)="DodgeF"
     DodgeAnims(1)="DodgeF"
     DodgeAnims(2)="DodgeF"
     DodgeAnims(3)="DodgeF"
     AirStillAnim="Jump_Takeoff"
     TakeoffStillAnim="Jump_Takeoff"
     IdleWeaponAnim="Idle_Biggun"
     AmbientSound=Sound'LuciferBOSS.LuciferAmbient'
     Mesh=SkeletalMesh'Lucifer.Lucifer'
     DrawScale=3.000000
     PrePivot=(Z=-35.000000)
     Skins(0)=Texture'Lucifertex.Map'
     Skins(1)=Texture'Lucifertex.Map'
     CollisionRadius=110.000000
     CollisionHeight=170.000000
     Mass=400.000000
     RotationRate=(Yaw=60000)
}
