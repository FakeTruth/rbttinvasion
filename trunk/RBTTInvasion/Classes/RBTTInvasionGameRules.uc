class RBTTInvasionGameRules extends GameRules
	DependsOn(RBTTInvasionMutator)
	config(RBTTInvasion);

var Array<RBTTInvasionMutator.MonsterNames>	MonsterTable;		// Hold all monsternames and classes

struct PortalStruct
{
	var class<MonsterSpawner>		PortalClass;		// The class of the portal
	var array<Class<UTPawn> > 		SpawnArray;		// The array that holds the monsters it's gonna spawn
	var int 				SpawnInterval;		// Spawn a monster per X seconds
	var int 				WhenToSpawn;		// Time in seconds from the beginning of the wave
};
var Array<PortalStruct>				PortalTable;		// Holds all the different portals

var RBTTInvasionMutator 			InvasionMut; 		// The mutator, might be handy to cache it

var class<UTTeamAI> 				MonsterTeamAIType;	// decides the squads and spawns the squad ai i believe
var class<UTTeamAI>				MonsterCTFTeamAIType;	// for CTF
var class<UTTeamInfo> 				MonsterEnemyRosterClass;// The monsters team info responsible for spawning the team ai
var UTTeamInfo 					Teams[2];		// an array of team infos held within UTGame 

var config bool					bShowDeathMessages; 	// If true, monsters will show deathmessages on death

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	
	if(WorldInfo.NetMode != NM_Client)
	{
		WorldInfo.Game.GoalScore = 0;			// 0 means no goalscore
		
		//#### SET GAME INFORMATION ####\\
		if(UTTeamGame(WorldInfo.Game) != None)
			UTTeamGame(WorldInfo.Game).bForceAllRed=true;	
	}
}

// So just use it to set the team..
function NotifyLogin(Controller NewPlayer)
{
	`log(">> RBTTInvasionGameRules.NotifyLogin <<");

	if(NewPlayer.PlayerReplicationInfo.Team == UTTeamGame(WorldInfo.Game).Teams[1]) // Put the players in one team, the other team is for monsters
		UTTeamGame(WorldInfo.Game).SetTeam(NewPlayer, UTTeamGame(WorldInfo.Game).Teams[0], TRUE);
}

function KillAllMonsters()
{
	local Pawn P;
	local int i;
	
	`log(">>>>>>>>>>>>>>>>>>RBTTInvasionGameRules.KillAllMonsters<<<<<<<<<<<<<<<<<<<<");

	foreach WorldInfo.AllPawns(class'Pawn', P)
	{
		for(i=MonsterTable.Length-1; i >= 0; i--)
		{
			if(P.class == MonsterTable[i].MonsterClass)
			{
				P.Died(None, None, P.Location);
				continue;
			}
		}
	}
}

function MatchStarting()
{
	`log(">>>>>>>>>>>>>>>>>>RBTTInvasionGameRules.MatchStarting<<<<<<<<<<<<<<<<<<<<");
	
	//#### GET MONSTERTABLE FROM MUTATOR ####\\
	MonsterTable = InvasionMut.default.MonsterTable;
	
	CreateMonsterTeam();
	SetTimer(1, true, 'InvasionTimer'); 		// InvasionTimer gets called once every second
}

function InvasionTimer();

function EndWave()
{
	InvasionMut.EndWave(self);
}

function ReplenishAmmo()
{
	local Inventory Item;
	local UTInventoryManager InvManager;
	local UTPlayerController PC;
	local int AmmoToAdd;
	local UTWeapon W;
	
	`log(">>>>>>>>>>>>>>>>>>RBTTInvasionGameRules.ReplenishAmmo<<<<<<<<<<<<<<<<<<<<");

	foreach WorldInfo.AllControllers(class'UTPlayerController', PC)
	{
		if(PC != NONE && PC.Pawn != NONE && PC.Pawn.InvManager != NONE)
		{
			InvManager = UTInventoryManager(PC.Pawn.InvManager);
			
			for (Item = InvManager.InventoryChain; Item != None; Item = Item.Inventory)
			{
				if(!Item.IsA('UTWeap_Redeemer'))
				{
					W = UTWeapon(Item);
					if(W != None)
					{
						AmmoToAdd = W.default.AmmoCount - W.AmmoCount;
						
						if(AmmoToAdd > 0)
							InvManager.AddAmmoToWeapon(AmmoToAdd, W.class);
					}
				}
			}
		}
	}
}

function bool IsMonster(Pawn P)
{
	local int i;

	for(i=MonsterTable.Length-1; i >= 0; i--)
		if(P.class == MonsterTable[i].MonsterClass)
				return True;
	
	return false;
}

function class<Pawn> GetMonsterClass(int MonsterNum)
{
	local int index;
	
	index = MonsterTable.Find('MonsterID',MonsterNum);
	if(index == -1)	// Couldn't find the monster!
		return None;
	
	return MonsterTable[index].MonsterClass;
}

// Spawn a monster of given class at given location and return the pawn
function Pawn SpawnMonster(class<Pawn> P, Vector SpawnLocation, optional Rotator SpawnRotation)
{
	local Pawn NewMonster;
	local UTTeamGame Game;
	local Controller Bot;
	local CharacterInfo MonsterBotInfo;
	local UTTeamInfo RBTTMonsterTeamInfo;
	local PlayerReplicationInfo PRI;
	local string MonsterName;
	
	`log(">>>>>>>>>>>>>>>>>>RBTTInvasionGameRules.SpawnMonster<<<<<<<<<<<<<<<<<<<<");
	
	Game = UTTeamGame(WorldInfo.Game);
	if( Game == None ) // Can't use monsters in a NON-TeamGame-Game
		return None;
	
	NewMonster = Spawn(P,,,SpawnLocation+(P.Default.CylinderComponent.CollisionHeight)* vect(0,0,1), SpawnRotation);
	
	if (NewMonster != None)
	{
		PRI = NewMonster.PlayerReplicationInfo;
		
		if(UTCTFGame(Game) != None)
		{
			NewMonster.bCanPickupInventory = True; // FOR CTF GAMES, OTHERWISE THEY CAN'T PICK UP TEH FLAG
		}
		
		Bot = NewMonster.Controller;
		
		if ( NewMonster.IsA('RBTTMonster') )
		{
			MonsterName = MonsterTable[MonsterTable.Find('MonsterClass',NewMonster.class)].MonsterName;
			MonsterBotInfo = Game.Teams[1].GetBotInfo(MonsterName);
			RBTTMonsterController(Bot).Initialize(RBTTMonster(NewMonster).MonsterSkill, MonsterBotInfo);
			RBTTMonster(NewMonster).Initialize();
			PRI.PlayerName = MonsterName;
			`log("Setting MonsterName to" @ MonsterName @ "Was Successful");
			`log("Setting MonsterName to" @ MonsterBotInfo.CharName @ "Was Successful");
			RBTTMonsterController(Bot).bUseObjectives = (UTCTFGame(Game) != None); // FOR CTF GAMES
		}
		
		if(PRI != None)
		{
			RBTTMonsterTeamInfo=Game.Teams[1];
			RBTTMonsterTeamInfo.AddToTeam(Bot);
			`log("PRI.Team.TeamIndex = "@PRI.Team.TeamIndex@"");
			RBTTMonsterTeamInfo.SetBotOrders(UTBot(Bot));
		}
		
		if(UTPawn(NewMonster) != None)
			UTPawn(NewMonster).SpawnTransEffect(0);
		return NewMonster;
	}
	else
		return None;
}
	
function CreateMonsterTeam()
{
	local class<UTTeamInfo> RosterClass;
	local UTTeamGame Game;
	
	`log(">>>>>>>>>>>>>>>>>>RBTTInvasionGameRules.CreateMonsterTeam<<<<<<<<<<<<<<<<<<<<");
	
	Game = UTTeamGame(WorldInfo.Game);
	Game.Teams[1].Destroy();

	// SET THE CORRECT AI TYPE FOR CTF GAMES!!
	if(UTCTFGame(Game) != None)
		MonsterTeamAIType = MonsterCTFTeamAIType; 
	
	RosterClass = MonsterEnemyRosterClass;
	`log(">>>>>>>>>>>>>>>> RosterClass = " @RosterClass@ " <<<<<<<<<<<<<<<<<");
	Teams[1] = spawn(RosterClass);
	//Teams[1].Faction = TeamFactions[1];//this is somthing i have in mind for later
	Teams[1].Initialize(1);
	Teams[1].AI = Spawn(MonsterTeamAIType);
	Teams[1].AI.Team = Teams[1];
	Game.Teams[1] = Teams[1];
	Game.GameReplicationInfo.SetTeam(1, Teams[1]);
	Game.Teams[1].AI.SetObjectiveLists();
	
	// FOR CTF GAMES!!!
	if(UTCTFGame(Game) != None)
		Game.PostBeginPlay(); // SO THAT THE FLAGS WILL WORK WITH THE MONSTERTEAM!
}

function bool PreventDeath(Pawn KilledPawn, Controller Killer, class<DamageType> damageType, vector HitLocation)
{
	if(!bShowDeathMessages)
		if(IsMonster(KilledPawn))
			if(KilledPawn.Controller != None)
				if(KilledPawn.Controller.bIsPlayer)
					if(IsMonster(KilledPawn))
						KilledPawn.Controller.bIsPlayer = False;

	return Super.PreventDeath(KilledPawn,Killer, damageType,HitLocation);
}

function ScoreKill(Controller Killer, Controller Other)
{
	if(InvasionMut.AllInvasionModules != None)
		InvasionMut.AllInvasionModules.ScoreKill(Killer, Other);
		
	Super.ScoreKill(Killer, Other);
}

function DropItemFrom(Pawn P, Class<Actor> PickupClass, optional int MiscOption1, optional int MiscOption2)
{
	local Actor MonsterDrop;
	local vector	POVLoc, TossVel;
	local rotator	POVRot;
	local Vector	X,Y,Z;
	
	`log(">>>>>>>>>>>>>>>>>>RBTTInvasionGameRules.DropItemFrom<<<<<<<<<<<<<<<<<<<<");

	P.GetActorEyesViewPoint(POVLoc, POVRot);
	TossVel = Vector(POVRot);
	TossVel = TossVel * ((Velocity Dot TossVel) + 500) + Vect(0,0,200);

	GetAxes(Rotation, X, Y, Z);
	
	MonsterDrop = Spawn(PickupClass,,, P.Location + 0.8 * P.CylinderComponent.CollisionRadius * X - 0.5 * P.CylinderComponent.CollisionRadius * Y);
	if( MonsterDrop == None )
	{
		return;
	}

	if(Pickup_Base(MonsterDrop) != None && (MiscOption1 != 0 || MiscOption2 != 0))
	{
		Pickup_Base(MonsterDrop).MiscOption1 = MiscOption1;
		Pickup_Base(MonsterDrop).MiscOption2 = MiscOption2;
	}
	MonsterDrop.SetPhysics(PHYS_Falling);
	//MonsterDrop.InventoryClass = PF;
	MonsterDrop.Velocity = TossVel;
	MonsterDrop.Instigator = P.Instigator;
	//MonsterDrop.SetPickupMesh(PF.default.PickupMesh);
}

function EndInvasionGame(Optional string Reason)
{
	`log(">>>>>>>>>>>>>>>>>>RBTTInvasionGameRules.EndInvasionGame<<<<<<<<<<<<<<<<<<<<");
	
	//KillAllMonsters(); // TEST TEST -FAKETRUTH
	
	if(Reason ~= "TimeLimit")
	{
		WorldInfo.Game.GameReplicationInfo.Winner = Teams[1]; // Monsters' team
		Teams[1].Score = 9999;
		Teams[0].Score = 0;
	}
		
	Reason = (Reason == "")?"triggered":Reason;
	WorldInfo.Game.EndGame(None,Reason);
	ClearTimer('InvasionTimer');
}

function bool CheckEndGame(PlayerReplicationInfo Winner, string Reason)
{
	return Super.CheckEndGame(Winner, Reason); 
}


/** If PlayerName is not given, ressurect ALL players */
function ResPlayer(optional string PlayerName, optional PlayerReplicationInfo ResBy);

function RestartPlayer(Controller aPlayer)
{
	`log(">>>>>>>>>>>>>>>>>>RBTTInvasionGameRules.RestartPlayer<<<<<<<<<<<<<<<<<<<<");
	WorldInfo.Game.RestartPlayer(aPlayer);
}

/* For TeamGame, tell teams about kills rather than each individual bot
*/
function NotifyKilled(Controller Killer, Controller KilledPlayer, Pawn KilledPawn)
{
	`log(">>>>>>>>>>>>>>>>>>RBTTInvasionGameRules.NotifyKilled<<<<<<<<<<<<<<<<<<<<");
	Teams[0].AI.NotifyKilled(Killer,KilledPlayer,KilledPawn);
	Teams[1].AI.NotifyKilled(Killer,KilledPlayer,KilledPawn);
}


function string GetSafeMapName()
{
	local string MapName;

	`log(">>>>>>>>>>>>>>>>>>RBTTInvasionGameRules.GetSafeMapName<<<<<<<<<<<<<<<<<<<<");
	
	//MapName = Left(string(Level), InStr(string(Level), "."));
	//MapName = WorldInfo.GetMapName();
	MapName = GetURLMap();
	MapName = Repl(MapName, " ", "_");
	MapName = Repl(MapName, "[", "_");
	MapName = Repl(MapName, "]", "_");

	return MapName;
}

defaultproperties
{
	MonsterEnemyRosterClass=class'RBTTMonsterTeamInfo'
	MonsterTeamAIType=Class'UTMonsterTeamAI'
	MonsterCTFTeamAIType=Class'MonsterCTFTeamAI' // Set to replace MonsterTeamAIType in PostBeginPlay()

	bShowDeathMessages=True
	   
	PortalTable(0)=(PortalClass=Class'MonsterSpawner',SpawnArray=(Class'RBTTMiningRobot',Class'RBTTSpider',Class'RBTTMiningRobot',Class'RBTTMiningRobot',Class'RBTTSpider',Class'RBTTMiningRobot'),SpawnInterval=5)
	PortalTable(1)=(PortalClass=Class'MonsterSpawner',SpawnArray=(Class'RBTTSkullCrab',Class'RBTTSkullCrab',Class'RBTTSkullCrab',Class'RBTTSkullCrab',Class'RBTTSkullCrab',Class'RBTTSkullCrab',Class'RBTTSkullCrab'),SpawnInterval=5)
	   
	Begin Object Name=Sprite ObjName=Sprite Archetype=SpriteComponent'Engine.Default__GameRules:Sprite'
		ObjectArchetype=SpriteComponent'Engine.Default__GameRules:Sprite'
	End Object
	Components(0)=Sprite
	   
	Name="Default__RBTTInvasionGameRules"
	ObjectArchetype=GameRules'Engine.Default__GameRules'
}
