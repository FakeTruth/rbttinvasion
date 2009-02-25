class RBTTSlime extends RBTTMonster;

var() skeletalMeshComponent DefaultMonsterMesh;
var() class<UTWeapon> DefaultMonsterWeapon;

//var() int MonsterSkill, 
var() int monsterTeam;
//var() string MonsterName;
var bool bMotherSlime;
var RBTTInvasionGameRules InvasionGameRules;

var repnotify vector MonsterScale;

replication
{
  if ( bNetDirty && Role == ROLE_Authority)
    MonsterScale;
}

simulated event ReplicatedEvent(name VarName)
{
	if (VarName == 'MonsterScale')
		ClientInitSize(MonsterScale);
	else
		Super.ReplicatedEvent(VarName);
}

simulated function PostBeginPlay()
{
	super.PostBeginPlay();
	if(bMotherSlime)
		InvasionGameRules = RBTTInvasionGameRules(WorldInfo.Game.GameRulesModifiers);
		
	InitializeMonsterInfo();
}

function InitializeMonsterInfo()
{
	local UTTeamGame Game;
	local CharacterInfo MonsterBotInfo;
	local UTTeamInfo RBTTMonsterTeamInfo;
	
	Game = UTTeamGame(WorldInfo.Game);
	
	RBTTMonsterTeamInfo=UTTeamInfo(Game.GameReplicationInfo.teams[1]);
	MonsterBotInfo = RBTTMonsterTeamInfo(RBTTMonsterTeamInfo).GetBotInfo(MonsterName);
	RBTTMonsterController(Controller).Initialize(MonsterSkill, MonsterBotInfo);
	PlayerReplicationInfo.PlayerName = MonsterName;
	LogInternal("Setting MonsterName to" @ MonsterBotInfo.CharName @ "Was Successful");
	
	RBTTMonsterTeamInfo.AddToTeam(Controller);
	RBTTMonsterTeamInfo.SetBotOrders(UTBot(Controller));
}

event TakeDamage(int DamageAmount, Controller EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
{
	local vector NewSize;
	local RBTTSlime NewSlime;

	super.TakeDamage(DamageAmount, EventInstigator, HitLocation, Momentum, DamageType, HitInfo, DamageCauser);
	
	if(bMotherSlime)
	{
		if(DamageAmount > 60)
		{
			LogInternal(">>Gonan spawn now!<<");
			NewSlime = self.Spawn(self.class,,,self.Location+Vect(0,0,128),self.Rotation);
			InvasionGameRules.WaveMonsters--; // Make sure an extra monster has to be killed (this one, that is)
			if(NewSlime != None)
			{
				LogInternal(">>New Slime is: "@NewSlime);
				InvasionGamerules.NumMonsters++;
				NewSlime.bMotherSlime = False;
				NewSlime.InitSize(Vect(8,8,8));
				NewSlime.health = 65;
			}else
				InvasionGameRules.WaveMonsters++; //If the monster fails to spawn, it doesn't need to be killed
				
		}
	
		//InitSize(Mesh.Scale3D/((DamageAmount/20)+1));
		if(DamageAmount <= 10)
			NewSize = Mesh.Scale3D*0.95;
		else
			NewSize = Mesh.Scale3D/((DamageAmount/100)+1);
						
		//LogInternal(DamageAmount);
			
		InitSize(NewSize);
		
		if(Mesh.Scale3D.X < 8)
			Died(EventInstigator, DamageType, HitLocation);
			//KilledBy(EventInstigator.Pawn);
	}
}

function InitSize(vector NewSize)
{
	MonsterScale = NewSize;
	ClientInitSize(NewSize); 	// run it on the server actually
					// see ReplicatedEvent(name VarName) for client replication
}

simulated function ClientInitSize(vector NewSize)
{
	Mesh.SetScale3D(NewSize);
	Mesh.SetMaterial(0, MaterialInterface'RBTTSlime.RBTTSlimeMaterial');
	LogInternal(">> Size has been set<<");
}

defaultproperties
{
	health = 9999
	bMotherSlime=True

	bMeleeMonster = True;
	JumpZ=644.0
	bCanStrafe=False
	bCanSwim=False
	bCanClimbCeilings=true
	bInvisibleWeapon = True;
	bCanPickupInventory = False;
	TorsoBoneName="Spine"
	HeadBone="Head"
	bEnableFootPlacement=False
	LeftFootControlName="LeftFrontFootControl"
	RightFootControlName="RightFrontFootControl"
	MonsterName = "Slime"
	MonsterSkill=5
	LightEnvironment=MyLightEnvironment
	BioBurnAway=GooDeath
	ArmsMesh(0)=FirstPersonArms
	ArmsMesh(1)=FirstPersonArms2
	PawnAmbientSound=AmbientSoundComponent
	WeaponAmbientSound=AmbientSoundComponent2
	GroundSpeed=200.000000
   OverlayMesh=OverlayMeshComponent0
   DefaultFamily=Class'RBTTSlimeFamilyInfo'
   
   DefaultMesh=SkeletalMesh'RBTTSlime.RBTTSlime'
   
   WalkableFloorZ=0.300000
   
   ControllerClass=Class'RBTTMonsterControllerMelee'
   InventoryManagerClass=class'RBTTInventoryManager'
  
  
   Begin Object Name=WPawnSkeletalMeshComponent ObjName=WPawnSkeletalMeshComponent Archetype=SkeletalMeshComponent'UTGame.Default__UTPawn:WPawnSkeletalMeshComponent'
      SkeletalMesh=SkeletalMesh'RBTTSlime.RBTTSlime'
      AnimTreeTemplate=AnimTree'RBTTSlime.RBTTSlimeTree'
      AnimSets(0)=AnimSet'RBTTSlime.RBTTSlimeAnims'
      bHasPhysicsAssetInstance=True
      //Scale=64
      Scale3D=(X=32,Y=32,Z=32)
      Rotation=(Yaw=49149) //(65535 = 360 degrees) (16383 = 90 degrees) | Yaw, Roll, Pitch
      PhysicsAsset=PhysicsAsset'RBTTSlime.RBTTSlime_Physics'
      Name="WPawnSkeletalMeshComponent"
	  ObjectArchetype=SkeletalMeshComponent'UTGame.Default__UTPawn:WPawnSkeletalMeshComponent'
   End Object
   Mesh=WPawnSkeletalMeshComponent
   
   Begin Object Name=CollisionCylinder ObjName=CollisionCylinder Archetype=CylinderComponent'UTGame.Default__UTPawn:CollisionCylinder'
      CollisionHeight=30.000000
      CollisionRadius=24.000000
      Translation=(X=0,Y=0,Z=20)
      ObjectArchetype=CylinderComponent'UTGame.Default__UTPawn:CollisionCylinder'
   End Object
   CylinderComponent=CollisionCylinder
   
   Components(0)=CollisionCylinder
   
   Begin Object Name=Arrow ObjName=Arrow Archetype=ArrowComponent'UTGame.Default__UTPawn:Arrow'
      ObjectArchetype=ArrowComponent'UTGame.Default__UTPawn:Arrow'
   End Object
   
   
   Components(1)=Arrow
   Components(2)=MyLightEnvironment
   Components(3)=WPawnSkeletalMeshComponent
   Components(4)=AmbientSoundComponent
   Components(5)=AmbientSoundComponent2
   Components(6)=MyLightEnvironment
   Components(8)=CollisionCylinder
   CollisionComponent=CollisionCylinder
   Name="Default__RBTTSlime"
   ObjectArchetype=UTPawn'UTGame.Default__UTPawn'
	
	// default bone names
	WeaponSocket=WeaponPoint
	WeaponSocket2=DualWeaponPoint
	bNeedWeapon = false
}
