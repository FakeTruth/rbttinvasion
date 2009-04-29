class RBTTMonster extends UTPawn;

var() float MonsterHealth;
var() int MonsterSkill;
var() string MonsterName;
var Controller MonsterController;
var bool bNeedWeapon;
var class<UTWeapon> MonsterWeaponClass;
var float WeaponSpeedMultiplier;
var bool bInvisibleWeapon;
var bool bMeleeMonster;
var bool bEmptyHanded;
var bool bCanDrive;
var bool bShotAnim;
var float HitDamage;

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	
	if(MonsterHealth > 0)
		health = MonsterHealth;
	
	SpawnDefaultController();
	//AddDefaultInventory();
	DeactivateSpawnProtection(); // No spawn protection for this monster! :D

}

function SpawnDefaultController()
{
	Super(Pawn).SpawnDefaultController();
	MonsterController = Controller;
	
	UTPlayerReplicationInfo(Controller.PlayerReplicationInfo).SetCharacterMesh(Mesh.SkeletalMesh, True);
	RBTTMonsterController(Controller).bNeedWeapon = bNeedWeapon;
}


simulated function class<UTFamilyInfo> GetFamilyInfo()
{
	local class<UTFamilyInfo> FamilyInfo;
	local UTPlayerReplicationInfo UTPRI;
	UTPRI = UTPlayerReplicationInfo(PlayerReplicationInfo);

	if( CurrFamilyInfo != none )
	{
		FamilyInfo = CurrFamilyInfo;
	}
	else
	{
	
		if( UTPRI != None )
		{
			FamilyInfo = class'RBTTCustomMonster_Data'.static.FindFamilyInfo(UTPRI.CharacterData.FamilyID);
		}
	}

	// If we couldn't find it (or empty), use the default
	if(FamilyInfo == None)
	{
		FamilyInfo = DefaultFamily;
	}

	return FamilyInfo;
}

/* *************************************************************************************
** // Weapon stuff!!!
************************************************************************************* */
 // Gets called from DummyWeapon.ProjectileFire()
simulated function Projectile ProjectileFire()
{
	local vector		RealStartLoc;
	local Projectile	SpawnedProjectile;

	// tell remote clients that we fired, to trigger effects
	Weapon.IncrementFlashCount();

	if( Role == ROLE_Authority )
	{
		// this is the location where the projectile is spawned.
		RealStartLoc = Weapon.GetPhysicalFireStartLoc();

		// Spawn projectile
		SpawnedProjectile = Spawn(Weapon.GetProjectileClass(),,, RealStartLoc);
		if( SpawnedProjectile != None && !SpawnedProjectile.bDeleteMe )
		{
			SpawnedProjectile.Init( Vector(Weapon.GetAdjustedAim( RealStartLoc )) );
		}

		// Return it up the line
		return SpawnedProjectile;
	}

	return None;
}

/* BestMode()
choose between regular or alt-fire
*/
function byte BestMode() // Can be used for switching from snipe to melee! 1 projectile 0 instant
{
	local float EnemyDist;
	local UTBot B;

	B = UTBot(Controller);
	if ( B == None )
	{
		Weapon.bMeleeWeapon = False;
		return 1;
	}

	if ( B.Enemy == None )
	{
		Weapon.bMeleeWeapon = False;
		return 1;
	}
	
	if(DummyWeapon(Weapon) != None)
	{
		EnemyDist = VSize(B.Enemy.Location - Location); // Player close > Melee, player not close > Fire
		if ( EnemyDist > DummyWeapon(Weapon).MeleeWeaponRange )
		{
			Weapon.bMeleeWeapon = False;
			return 1;
		}
	}
	Weapon.bMeleeWeapon = True;
	return 0;
}

simulated function float GetFireInterval( byte FireModeNum )
{
	return Weapon.FireInterval[FireModeNum] * FireRateMultiplier;
}

simulated function float GetTraceRange()
{
	return Weapon.WeaponRange;
}

function float SuggestAttackStyle() // -1 to 1, low = stay off/snipe, high = charge/melee
{
	local float EnemyDist;

	if (Controller.Enemy != None)
	{
		// recommend backing off if target is too close
		EnemyDist = VSize(Controller.Enemy.Location - Location);
		if ( EnemyDist < 750 )
		{
			return (EnemyDist < 500) ? 1.0 : 0.5;
		}
		else if (EnemyDist > 1600)
		{
			return 0.5;
		}
	}

	return -0.1;
}

simulated function InstantFire()
{
	local vector StartTrace, EndTrace;
	local Array<ImpactInfo>	ImpactList;
	local ImpactInfo RealImpact, NearImpact;
	local int i, FinalImpactIndex;
	local UTWeapon UTWeap;
	
	UTWeap = UTWeapon(Weapon);

	// define range to use for CalcWeaponFire()
	StartTrace = UTWeap.InstantFireStartTrace();
	EndTrace = UTWeap.InstantFireEndTrace(StartTrace);
	// Perform shot
	RealImpact = UTWeap.CalcWeaponFire(StartTrace, EndTrace, ImpactList);
	FinalImpactIndex = ImpactList.length - 1;

	if (FinalImpactIndex >= 0 && (ImpactList[FinalImpactIndex].HitActor == None || !ImpactList[FinalImpactIndex].HitActor.bProjTarget))
	{
		// console aiming help
		NearImpact = UTWeap.InstantAimHelp(StartTrace, EndTrace, RealImpact);
		if ( NearImpact.HitActor != None )
		{
			ImpactList[FinalImpactIndex] = NearImpact;
		}
	}

	for (i = 0; i < ImpactList.length; i++)
	{
		UTWeap.ProcessInstantHit(UTWeap.CurrentFireMode, ImpactList[i]);
	}

	if (Role == ROLE_Authority)
	{
		// Set flash location to trigger client side effects.
		// if HitActor == None, then HitLocation represents the end of the trace (maxrange)
		// Remote clients perform another trace to retrieve the remaining Hit Information (HitActor, HitNormal, HitInfo...)
		// Here, The final impact is replicated. More complex bullet physics (bounce, penetration...)
		// would probably have to run a full simulation on remote clients.
		if ( NearImpact.HitActor != None )
		{
			UTWeap.SetFlashLocation(NearImpact.HitLocation);
		}
		else
		{
			UTWeap.SetFlashLocation(RealImpact.HitLocation);
		}
	}
}
//					It's FiringModeZ because otherwise it conflicts with Pawn.FiringMode
simulated function ProcessInstantHit( byte FiringModeZ, ImpactInfo Impact )
{
	if (Impact.HitActor != None)
	{
		Impact.HitActor.TakeDamage( Weapon.InstantHitDamage[Weapon.CurrentFireMode], Controller,
						Impact.HitLocation, Weapon.InstantHitMomentum[FiringModeZ] * Impact.RayDir,
						Weapon.InstantHitDamageTypes[FiringModeZ], Impact.HitInfo, Weapon );
	}
}


/*
Event called when an AnimNodeSequence (in the animation tree of one of this Actors SkeletalMeshComponents) reaches the end and stops. Will not get called if bLooping is 'true' on the AnimNodeSequence. bCauseActorAnimEnd must be set 'true' on the AnimNodeSequence for this event to get generated.
SeqNode - Node that finished playing. You can get to the SkeletalMeshComponent by looking at SeqNode->SkelComponent
PlayedTime - Time played on this animation. (play rate independant).
ExcessTime - how much time overlapped beyond end of animation. (play rate independant). 
*/
event OnAnimEnd (AnimNodeSequence SeqNode, float PlayedTime, float ExcessTime)
{
	//AnimAction = '';
	//if ( bVictoryNext && (Physics != PHYS_Falling) )
	//{
	//	bVictoryNext = false;
	//	PlayVictory();
	//}
	if ( bShotAnim )
	{	
		bShotAnim = false;
		//Controller.bPreparingMove = false;
	}
	super.OnAnimEnd (SeqNode, PlayedTime, ExcessTime);
}

function RangedAttack(Actor A);



//*******************************************************************

/*
function bool Died(Controller Killer, class<DamageType> damageType, vector HitLocation)
{

	WorldInfo.MyEmitterPool.SpawnEmitter( ParticleSystem'WP_LinkGun.Effects.P_WP_Linkgun_Skeleton_Dissolve', Location, Rotator(vect(0,0,1)), self );

	return Super.Died(Killer, damageType, HitLocation);
}
*/

simulated function NotifyTeamChanged()
{
	local UTPlayerReplicationInfo PRI;
	local int i;
	local class<UTFamilyInfo> Family;

	// set mesh to the one in the PRI, or default for this team if not found
	PRI = UTPlayerReplicationInfo(PlayerReplicationInfo);
	if (PRI == None && DrivenVehicle != None)
	{
		PRI = UTPlayerReplicationInfo(DrivenVehicle.PlayerReplicationInfo);
	}
	if (PRI != None)
	{
		if ( (PRI.Team != None) && !IsHumanControlled() || !IsLocallyControlled()  )
		{
			LightEnvironment.LightDesaturation = 1.0;
		}
		Family = class'UTCustomChar_Data'.static.FindFamilyInfo(PRI.CharacterData.FamilyID);
		if (PRI.CharacterMesh != None && PRI.CharacterMesh != DefaultMesh)
		{
			SetInfoFromFamily(Family, PRI.CharacterMesh);

			if (OverlayMesh != None)
			{
				OverlayMesh.SetSkeletalMesh(PRI.CharacterMesh);
			}
		}
		else
		{
			// force proper LOD levels for default mesh (hack code fix)
			for ( i=0; i<DefaultMesh.LODInfo.Length; i++ )
			{
				DefaultMesh.LODInfo[i].DisplayFactor = FMax(0.0, 0.6 - 0.2*i);
			}

			//bMeshChanged = (DefaultMesh != Mesh.SkeletalMesh);

			SetInfoFromFamily(DefaultFamily, DefaultMesh);
			// exception: always use the sounds for the intended character
			// so that even if the server doesn't construct the mesh, the owning client still gets the correct sounds
			// (of course, players who see the default character will then have wrong sounds,
			// but this is both less likely to happen and less likely to be noticed when it does)

			// JG: actually - we always want the soundgroup to match the mesh - your own effects are not replicated from server
			if (Family != None)
			{
				SoundGroupClass = Family.default.SoundGroupClass;
			}

			if (OverlayMesh != None)
			{
				OverlayMesh.SetSkeletalMesh(DefaultMesh);
			}
		}
	}
}

/**
 * Called when a weapon is changed and is responsible for making sure
 * the new weapon respects the current pawns states/etc.
 */
simulated function WeaponChanged(UTWeapon NewWeapon); // This function only does animations and sheet.. we don't need that for monsters

defaultproperties
{
	MonsterHealth = 0
	HitDamage = 10
	WeaponSpeedMultiplier = 1.000 //0.5 = half speed, 1 = standard, 2 = twice as fast, etc.
	MonsterSkill = 1
	bCanDrive = True
	bNeedWeapon = True
	WalkingPct=+0.4
	CrouchedPct=+0.4
	BaseEyeHeight=38.0
	EyeHeight=38.0
	GroundSpeed=440.0
	AirSpeed=440.0
	WaterSpeed=220.0
	DodgeSpeed=600.0
	DodgeSpeedZ=295.0
	AccelRate=2048.0
	JumpZ=322.0
	CrouchHeight=29.0
	CrouchRadius=21.0
	WalkableFloorZ=0.78
	InventoryManagerClass=class'RBTTInventoryManager' // class'UTInventoryManager'
	MeleeRange=+20.0
	bMuffledHearing=False
	Buoyancy=+000.99000000
	UnderWaterTime=+00020.000000
	bCanStrafe=True
	bCanSwim=true
	RotationRate=(Pitch=20000,Yaw=20000,Roll=20000)
	MaxLeanRoll=2048
	AirControl=+0.35
	DefaultAirControl=+0.35
	bStasis=false
	bCanCrouch=true
	bCanClimbLadders=True
	bCanPickupInventory=False
	bCanDoubleJump=true
	SightRadius=+12000.0
}
