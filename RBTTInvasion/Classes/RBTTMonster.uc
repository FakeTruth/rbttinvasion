class RBTTMonster extends UTPawn;

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
var MaterialInterface MonsterSkinMaterial;

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	SpawnDefaultController();
	AddDefaultInventory();
	DeactivateSpawnProtection(); // No spawn protection for this monster! :D
}

// Make sure the skin is applied on the client
simulated function Tick(float DeltaTime)
{
	if(MonsterSkinMaterial != None)
		if(Mesh.GetMaterial(0) != MonsterSkinMaterial)
			Mesh.SetMaterial(0, MonsterSkinMaterial);
}

function SpawnDefaultController()
{
	Super(Pawn).SpawnDefaultController();
	MonsterController = Controller;

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



function bool Died(Controller Killer, class<DamageType> damageType, vector HitLocation)
{
	local bool DiedReturn;

	DiedReturn = Super.Died(Killer, damageType, HitLocation);
	
	LogInternal(">>>>>>>>>>>>>>>>>>>Pawn Destroyed!<<<<<<<<<<<<<<<<<<<");
	MonsterController.Destroy();
	LogInternal(">>>>>>>>>>>>>> CONTROLLER DESTROYED <<<<<<<<<<<<<<<");

	return DiedReturn;
}

defaultproperties
{
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
	bCanPickupInventory=True
	bCanDoubleJump=true
	SightRadius=+12000.0
}
