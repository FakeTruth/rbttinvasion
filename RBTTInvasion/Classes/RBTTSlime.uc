class RBTTSlime extends RBTTMonster;

var() skeletalMeshComponent DefaultMonsterMesh;
var() class<UTWeapon> DefaultMonsterWeapon;

//var() int MonsterSkill, 
var() int monsterTeam;
//var() string MonsterName;
var bool bMotherSlime;
var RBTTInvasionGameRules InvasionGameRules;

var repnotify vector MonsterScale;	// How big the slime monsters is right now, used for replication
var vector MinMonsterScale;		// The smallest the slime mother can become

replication
{
  if ( bNetDirty && Role == ROLE_Authority)
    MonsterScale;
}

simulated event ReplicatedEvent(name VarName)
{
	if (VarName == 'MonsterScale')
	{
		Mesh.SetScale3D(MonsterScale);
		SetCollisionSize( CylinderComponent.default.CollisionRadius * MonsterScale.X * 2, CylinderComponent.default.CollisionHeight * MonsterScale.Z * 2 );
	}
	else
		Super.ReplicatedEvent(VarName);
}

simulated function PostBeginPlay()
{
	super.PostBeginPlay();

	if(WorldInfo.NetMode == NM_Standalone || WorldInfo.NetMode == NM_DedicatedServer)
		InvasionGameRules = RBTTInvasionGameRules(WorldInfo.Game.GameRulesModifiers);
	
	SetTimer(1, False, 'SpawnBabySlimes');
		
	InitializeMonsterInfo();
	InitSize(Mesh.Scale3D);
	SetLocation(Location + (GetCollisionHeight() * Vect(0,0,1)));
	SetPhysics(PHYS_Falling);
}

function SpawnBabySlimes()
{
	local int i;
	local RBTTSlime NewSlime;
	local Vector SpawnLocation;
	
	if(bMotherSlime)
		for(i=0; i<4; i++)
		{
			if(i == 0)
			{
				SpawnLocation = self.Location+(Vect(1,1,0)*(GetCollisionRadius()+16));
				if ( FastTrace(SpawnLocation, Location) )
					NewSlime = self.Spawn(self.class,,,SpawnLocation,self.Rotation);
			}
			if(i == 1)
			{
				SpawnLocation = self.Location+(Vect(1,-1,0)*(GetCollisionRadius()+16));
				if ( FastTrace(SpawnLocation, Location) )
					NewSlime = self.Spawn(self.class,,,SpawnLocation,self.Rotation);
			}
			if(i == 2)
			{
				SpawnLocation = self.Location+(Vect(-1,1,0)*(GetCollisionRadius()+16));
				if ( FastTrace(SpawnLocation, Location) )
					NewSlime = self.Spawn(self.class,,,SpawnLocation,self.Rotation);
			}
			if(i == 3)
			{
				SpawnLocation = self.Location+(Vect(-1,-1,0)*(GetCollisionRadius()+16));
				if ( FastTrace(SpawnLocation, Location) )
					NewSlime = self.Spawn(self.class,,,SpawnLocation,self.Rotation);
			}
			if(NewSlime != None)
			{
				LogInternal(">>New Slime is: "@NewSlime);
				InvasionGamerules.NumMonsters++;
				NewSlime.bMotherSlime = False;
				NewSlime.health = 65;
				NewSlime.InitSize(Vect(8,8,8));
				NewSlime.SpawnTransEffect(0);
				InvasionGameRules.WaveMonsters--; // Make sure an extra monster has to be killed (this one, that is)
				NewSlime = None;
			}
		}
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
	local Vector SpawnLocation;

	
	if(Class<UTDmgType_BioGoo>(DamageType) == None )
		super.TakeDamage(DamageAmount, EventInstigator, HitLocation, Momentum, DamageType, HitInfo, DamageCauser);
		
	if(RBTTMonsterController(EventInstigator) != None)
		return; // don't make it grow if it's a monster's goo
	
	if(bMotherSlime)
	{
		if(DamageAmount > 60 && health > 0)
		{
			LogInternal(">>Gonan spawn now!<<");
			SpawnLocation = self.Location+(Vect(0,0,1)*(GetCollisionHeight()+16));
			if ( FastTrace(SpawnLocation, Location) )
				NewSlime = self.Spawn(self.class,,,SpawnLocation,self.Rotation);
			if(NewSlime != None)
			{
				LogInternal(">>New Slime is: "@NewSlime);
				InvasionGamerules.NumMonsters++;
				NewSlime.bMotherSlime = False;
				NewSlime.InitSize(Vect(8,8,8));
				NewSlime.health = 65;
				InvasionGameRules.WaveMonsters--; // Make sure an extra monster has to be killed (this one, that is)
			}
		}
		
		if( Class<UTDmgType_BioGoo>(DamageType) != None )
			health+= DamageAmount*2;
	
		//InitSize(Mesh.Scale3D/((DamageAmount/20)+1));
		NewSize = ((default.MonsterScale-MinMonsterScale) / (float(default.health) / float(health))) + MinMonsterScale;
		
		if(NewSize != MonsterScale)
			InitSize(NewSize);
		
		//if(Mesh.Scale3D.X < 8)
		//	Died(EventInstigator, DamageType, HitLocation);
			//KilledBy(EventInstigator.Pawn);
	}
}

function InitSize(vector NewSize)
{
	LogInternal(">>NewSize:"@NewSize);
	MonsterScale = NewSize; // For replication
	Mesh.SetScale3D(NewSize);
	SetCollisionSize( CylinderComponent.default.CollisionRadius * NewSize.X * 2, CylinderComponent.default.CollisionHeight * NewSize.Z * 2 );
	//native(283) final function SetCollisionSize( float NewRadius, float NewHeight );
}

/*
simulated function SpawnGibs(class<UTDamageType> UTDamageType, vector HitLocation)
{
	local UTProj_BioGlob BioGlobSpawn;
	local Vector VNorm;
	
	super.SpawnGibs(UTDamageType, HitLocation);

	BioGlobSpawn = Spawn(Class'UTGameContent.UTProj_BioGlob',,,self.Location);
	BioGlobSpawn.InitBio(None, 25); //make its strength 25
	
	BioGlobSpawn.Velocity = (BioGlobSpawn.GloblingSpeed + FRand()*150.0) * (BioGlobSpawn.SurfaceNormal + VRand()*0.8);
	if (BioGlobSpawn.Physics == PHYS_Falling)
	{
		VNorm = (BioGlobSpawn.Velocity dot BioGlobSpawn.SurfaceNormal) * BioGlobSpawn.SurfaceNormal;
		BioGlobSpawn.Velocity += (-VNorm + (BioGlobSpawn.Velocity - VNorm)) * 0.1;
	}
}
*/

function bool Died(Controller Killer, class<DamageType> damageType, vector HitLocation)
{
	local UTProj_BioGlob BioGlobSpawn;
	local Vector VNorm;

	BioGlobSpawn = self.Spawn(Class'UTGameContent.UTProj_BioGlob',,,self.Location);
	BioGlobSpawn.InitBio(None, 25); //make its strength 25
	//BioGlobSpawn.Instigator = self; // Slime made it, so it should be the instigator
	
	BioGlobSpawn.Velocity = (BioGlobSpawn.GloblingSpeed + FRand()*150.0) * (BioGlobSpawn.SurfaceNormal + VRand()*0.8);
	if (BioGlobSpawn.Physics == PHYS_Falling)
	{
		VNorm = (BioGlobSpawn.Velocity dot BioGlobSpawn.SurfaceNormal) * BioGlobSpawn.SurfaceNormal;
		BioGlobSpawn.Velocity += (-VNorm + (BioGlobSpawn.Velocity - VNorm)) * 0.1;
	}
	
	Super.Died(Killer, damageType, HitLocation);
	
	Destroy();
	return True;
}

// /////////// WEAPON STUFZZZ ///////////////////////////////// //
function byte BestMode(){	return 0;	}

simulated function float GetFireInterval( byte FireModeNum ){	return 0.5;	}

simulated function float GetTraceRange()
{
	return GetCollisionRadius() + 64;
}

function float SuggestAttackStyle() {	return 1.00;	}

simulated function InstantFire()
{
	if(VSize(Controller.Enemy.Location - Location) > GetCollisionRadius() + 64)
	{
		return; // enemy too far away to punch it in teh face!
	}
		
	super.InstantFire();
}

defaultproperties
{
   bMotherSlime=True
   MonsterScale=(X=32.000000,Y=32.000000,Z=32.000000)
   MinMonsterScale=(X=8.000000,Y=8.000000,Z=8.000000)
   MonsterSkill=5
   MonsterName="Slime"
   bInvisibleWeapon=True
   bMeleeMonster=True
   bEmptyHanded=True
   bCanDoubleJump=False
   bEnableFootPlacement=False
   Begin Object Class=DynamicLightEnvironmentComponent Name=MyLightEnvironment ObjName=MyLightEnvironment Archetype=DynamicLightEnvironmentComponent'RBTTInvasion.Default__RBTTMonster:MyLightEnvironment'
      ObjectArchetype=DynamicLightEnvironmentComponent'RBTTInvasion.Default__RBTTMonster:MyLightEnvironment'
   End Object
   LightEnvironment=MyLightEnvironment
   MaxMultiJump=0
   Begin Object Class=ParticleSystemComponent Name=GooDeath ObjName=GooDeath Archetype=ParticleSystemComponent'RBTTInvasion.Default__RBTTMonster:GooDeath'
      ObjectArchetype=ParticleSystemComponent'RBTTInvasion.Default__RBTTMonster:GooDeath'
   End Object
   BioBurnAway=GooDeath
   Begin Object Class=DynamicLightEnvironmentComponent Name=DeathVisionLightEnv ObjName=DeathVisionLightEnv Archetype=DynamicLightEnvironmentComponent'RBTTInvasion.Default__RBTTMonster:DeathVisionLightEnv'
      ObjectArchetype=DynamicLightEnvironmentComponent'RBTTInvasion.Default__RBTTMonster:DeathVisionLightEnv'
   End Object
   FirstPersonDeathVisionLightEnvironment=DeathVisionLightEnv
   TorsoBoneName="Spine"
   ArmsMesh(0)=None
   ArmsMesh(1)=None
   HeadBone="head"
   Begin Object Class=UTAmbientSoundComponent Name=AmbientSoundComponent ObjName=AmbientSoundComponent Archetype=UTAmbientSoundComponent'RBTTInvasion.Default__RBTTMonster:AmbientSoundComponent'
      ObjectArchetype=UTAmbientSoundComponent'RBTTInvasion.Default__RBTTMonster:AmbientSoundComponent'
   End Object
   PawnAmbientSound=AmbientSoundComponent
   Begin Object Class=UTAmbientSoundComponent Name=AmbientSoundComponent2 ObjName=AmbientSoundComponent2 Archetype=UTAmbientSoundComponent'RBTTInvasion.Default__RBTTMonster:AmbientSoundComponent2'
      ObjectArchetype=UTAmbientSoundComponent'RBTTInvasion.Default__RBTTMonster:AmbientSoundComponent2'
   End Object
   WeaponAmbientSound=AmbientSoundComponent2
   Begin Object Class=SkeletalMeshComponent Name=OverlayMeshComponent0 ObjName=OverlayMeshComponent0 Archetype=SkeletalMeshComponent'RBTTInvasion.Default__RBTTMonster:OverlayMeshComponent0'
      ObjectArchetype=SkeletalMeshComponent'RBTTInvasion.Default__RBTTMonster:OverlayMeshComponent0'
   End Object
   OverlayMesh=OverlayMeshComponent0
   Begin Object Class=DynamicLightEnvironmentComponent Name=XRayEffectLightEnv ObjName=XRayEffectLightEnv Archetype=DynamicLightEnvironmentComponent'RBTTInvasion.Default__RBTTMonster:XRayEffectLightEnv'
      ObjectArchetype=DynamicLightEnvironmentComponent'RBTTInvasion.Default__RBTTMonster:XRayEffectLightEnv'
   End Object
   XRayEffectLightEnvironment=XRayEffectLightEnv
   LeftFootControlName="LeftFrontFootControl"
   RightFootControlName="RightFrontFootControl"
   DefaultFamily=Class'RBTTInvasion.RBTTSlimeFamilyInfo'
   DefaultMesh=None
   WalkableFloorZ=0.800000
   bCanCrouch=False
   bCanSwim=False
   GroundSpeed=200.000000
   Health=500
   ControllerClass=Class'RBTTInvasion.RBTTMonsterControllerMelee'
   Begin Object Class=SkeletalMeshComponent Name=WPawnSkeletalMeshComponent ObjName=WPawnSkeletalMeshComponent Archetype=SkeletalMeshComponent'UTGame.Default__UTPawn:WPawnSkeletalMeshComponent'
      AnimTreeTemplate=None
      AnimSets(0)=None
      Rotation=(Pitch=0,Yaw=49149,Roll=0)
      Scale3D=(X=32.000000,Y=32.000000,Z=32.000000)
      ObjectArchetype=SkeletalMeshComponent'UTGame.Default__UTPawn:WPawnSkeletalMeshComponent'
   End Object
   Mesh=WPawnSkeletalMeshComponent
   Begin Object Class=CylinderComponent Name=CollisionCylinder ObjName=CollisionCylinder Archetype=CylinderComponent'UTGame.Default__UTPawn:CollisionCylinder'
      CollisionHeight=2.000000
      CollisionRadius=2.000000
      ObjectArchetype=CylinderComponent'UTGame.Default__UTPawn:CollisionCylinder'
   End Object
   CylinderComponent=CollisionCylinder
   Components(0)=CollisionCylinder
   Begin Object Class=ArrowComponent Name=Arrow ObjName=Arrow Archetype=ArrowComponent'UTGame.Default__UTPawn:Arrow'
      ObjectArchetype=ArrowComponent'UTGame.Default__UTPawn:Arrow'
   End Object
   Components(1)=Arrow
   Components(2)=MyLightEnvironment
   Components(3)=WPawnSkeletalMeshComponent
   Components(4)=AmbientSoundComponent
   Components(5)=AmbientSoundComponent2
   Components(6)=MyLightEnvironment
   Components(7)=None
   Components(8)=CollisionCylinder
   CollisionComponent=CollisionCylinder
   Name="Default__RBTTSlime"
}
