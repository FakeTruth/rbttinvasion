Class RBTTMonsterController Extends UTBot;

var bool bNeedWeapon;

function PostBeginPlay()
{
	
	Super.PostBeginPlay();
	
	//InitPlayerReplicationInfo();
	bNeedWeapon = RBTTMonster(Pawn).bNeedWeapon;
	//GotoState('Roaming', 'Begin');
	

}
function InitPlayerReplicationInfo() {
	
	//local CustomCharData BotCharData;
	
	//BotCharData = BotInfo.CharData;
	//		if(BotCharData.BasedOnCharID == "")
	//	{
	//		BotCharData.BasedOnCharID = BotInfo.CharID;
	//	}
		
	PlayerReplicationInfo = Spawn(class'MonsterReplicationInfo', self,, vect(0,0,0), rot(0,0,0));
	
	if (PlayerReplicationInfo.PlayerName == "") {
		PlayerReplicationInfo.SetPlayerName("RBTTMonster");
	}
}
function Initialize(float InSkill, const out CharacterInfo BotInfo)
{
	local UTPlayerReplicationInfo PRI;
	local CustomCharData BotCharData;
	//local UTGameReplicationInfo GRI;
	
	
	Skill = FClamp(InSkill, 0, 7);

	// copy AI personality
	if (BotInfo.AIData.FavoriteWeapon != "")
	{
		if (WorldInfo.IsConsoleBuild())
		{
			FavoriteWeapon = class<Weapon>(FindObject(BotInfo.AIData.FavoriteWeapon, class'Class'));
		}
		else
		{
			FavoriteWeapon = class<Weapon>(DynamicLoadObject(BotInfo.AIData.FavoriteWeapon, class'Class'));
		}
	}
	Aggressiveness = FClamp(BotInfo.AIData.Aggressiveness, 0, 1);
	BaseAggressiveness = Aggressiveness;
	Accuracy = FClamp(BotInfo.AIData.Accuracy, -5, 5);
	StrafingAbility = FClamp(BotInfo.AIData.StrafingAbility, -5, 5);
	CombatStyle = FClamp(BotInfo.AIData.CombatStyle, -1, 1);
	Jumpiness = FClamp(BotInfo.AIData.Jumpiness, -1, 1);
	Tactics = FClamp(BotInfo.AIData.Tactics, -5, 5);
	ReactionTime = FClamp(BotInfo.AIData.ReactionTime, -5, 5);

	// copy visual properties
	BotCharData = BotInfo.CharData;
	PRI = UTPlayerReplicationInfo(PlayerReplicationInfo);
	//GRI = UTGameReplicationInfo(GameReplicationInfo);
	//if (PRI == None)
	//{
		//Spawn(WorldInfo.Game.PlayerReplicationInfoClass, self,, vect(0,0,0),rot(0,0,0));
		//PRI.SetCharacterData(BotCharData);
		//PlayerReplicationInfo.ClientInitialize(self);
		//BotCharData.BasedOnCharID = BotInfo.CharID;
		//PRI.SetCharacterData(BotCharData);
		//GRI.ProcessCharacterData(self);
		//InitPlayerReplicationInfo();
		//LogInternal(">>>>>>>>>>>>>>>>>>>>WTF Why ARE WE sPAWNING THE PRI HERE<<<<<<<<<<<<<<<<<<<<<<<<<<");
		//LogInternal(">>>>>>>>>>>>>>>>>>>>WTF Why ARE WE sPAWNING THE PRI HERE<<<<<<<<<<<<<<<<<<<<<<<<<<");
	
	//}
	if (PRI != None)
	{
		// If we have no 'based on' char ref, just fill it in with this char. Thing like VoiceClass look at this.
		
		if(BotCharData.BasedOnCharID == "")
		{
			BotCharData.BasedOnCharID = BotInfo.CharID;
		}
		
		PRI.SetCharacterData(BotCharData);
	}

	ReSetSkill();
}

function ChooseAttackMode()
{
	local float EnemyStrength, WeaponRating, RetreatThreshold;

	GoalString = " ChooseAttackMode last seen "$(WorldInfo.TimeSeconds - LastSeenTime);
	// should I run away?
	if ( (Squad == None) || (Enemy == None) || (Pawn == None) )
		`log("HERE 1 Squad "$Squad$" Enemy "$Enemy$" pawn "$Pawn);
	EnemyStrength = RelativeStrength(Enemy);
	if ( EnemyStrength > RetreatThreshold && (PlayerReplicationInfo.Team != None) && (FRand() < 0.25)
		&& (WorldInfo.TimeSeconds - LastInjuredVoiceMessageTime > 45.0) )
	{
		LastInjuredVoiceMessageTime = WorldInfo.TimeSeconds;
		SendMessage(None, 'INJURED', 25);
	}
	if ( Vehicle(Pawn) != None )
	{
		VehicleFightEnemy(true, EnemyStrength);
		return;
	}
	if ( !bFrustrated && !Squad.MustKeepEnemy(Enemy) )
	{
		RetreatThreshold = Aggressiveness;
		if ( Pawn.Weapon != None && UTWeapon(Pawn.Weapon).CurrentRating > 0.5 )
			RetreatThreshold = RetreatThreshold + 0.35 - skill * 0.05;
		else if( Pawn.Weapon == None )
			RetreatThreshold = 0;
		if ( EnemyStrength > RetreatThreshold )
		{
			GoalString = "Retreat";
			if ( (PlayerReplicationInfo.Team != None) && (FRand() < 0.05)
				&& (WorldInfo.TimeSeconds - LastInjuredVoiceMessageTime > 45.0) )
			{
				LastInjuredVoiceMessageTime = WorldInfo.TimeSeconds;
				SendMessage(None, 'INJURED', 25);
			}
			DoRetreat();
			return;
		}
	}

	if ( (Squad.PriorityObjective(self) == 0) && (Skill + Tactics > 2) && ((EnemyStrength > -0.3) || (Pawn.Weapon != None && (Pawn.Weapon.AIRating < 0.5))) )
	{
		if ( Pawn.Weapon != None)
		{
			if ( Pawn.Weapon.AIRating < 0.5 )
			{
				if ( EnemyStrength > 0.3 )
					WeaponRating = 0;
				else
					WeaponRating = UTWeapon(Pawn.Weapon).CurrentRating/2000;
			}
			else if ( EnemyStrength > 0.3 )
				WeaponRating = UTWeapon(Pawn.Weapon).CurrentRating/2000;
			else
				WeaponRating = UTWeapon(Pawn.Weapon).CurrentRating/1000;
		}
		else
			WeaponRating = 0; // He gots no weaponz!

		// fallback to better pickup?
		if ( FindInventoryGoal(WeaponRating) )
		{
			if ( PickupFactory(RouteGoal) == None )
				GoalString = "fallback - inventory goal is not pickup but "$RouteGoal;
			else
				GoalString = "Fallback to better pickup " $ RouteGoal $ " hidden " $ RouteGoal.bHidden;
			GotoState('FallBack');
			return;
		}
	}

	GoalString = "ChooseAttackMode FightEnemy";
	FightEnemy(true, EnemyStrength);
}

/*

function FightEnemy(bool bCanCharge, float EnemyStrength)
{
	//if(Pawn.Weapon != None)
		Super.FightEnemy(bCanCharge, EnemyStrength);
}

function bool NeedWeapon()
{
	if (!bNeedWeapon)
		return false;

	return Super.NeedWeapon();
}

function bool FindInventoryGoal(float BestWeight)
{
	if(!bNeedWeapon)
		return false;

	return Super.FindInventoryGoal(BestWeight);
}

event float SuperDesireability(PickupFactory P)
{
	if(!bNeedWeapon)
		return 0;

	return SuperDesireability(P);
}
*/


function Destroyed() 
{
	// Don't let monsters respawn into the game. Just remove them.
	bIsPlayer = false;
	LogInternal(">>>>>>>>>> Destroyed() called from Controller <<<<<<<<<<<<");
	LogInternal(">>>>>>>>>> PlayerReplicationInfo: "@PlayerReplicationInfo);
	PlayerReplicationInfo.Destroy();
	LogInternal(">>>>>>>>>> Replicationinfo destroyed <<<<<<<<<<<<");
	LogInternal(">>>>>>>>>> PlayerReplicationInfo: "@PlayerReplicationInfo);
	super.Destroyed();
}

function GameHasEnded(optional Actor EndGameFocus, optional bool bIsWinner)
{
	Self.Destroy();
	Super.GameHasEnded(EndGameFocus, bIsWinner);
}

defaultproperties
{
   ReactionTime=0.500000
   Jumpiness=1.000000
   Begin Object Name=TheDecider ObjName=TheDecider Archetype=UTBotDecisionComponent'UTGame.Default__UTBot:TheDecider'
      ObjectArchetype=UTBotDecisionComponent'UTGame.Default__UTBot:TheDecider'
   End Object
   DecisionComponent=TheDecider
   //bIsPlayer=False
   Begin Object Name=Sprite ObjName=Sprite Archetype=SpriteComponent'UTGame.Default__UTBot:Sprite'
      ObjectArchetype=SpriteComponent'UTGame.Default__UTBot:Sprite'
   End Object
   Components(0)=Sprite
   Components(1)=TheDecider
   RotationRate=(Pitch=65535,Yaw=65535,Roll=2048)
   Name="Default__RBTTMonsterController"
   ObjectArchetype=UTBot'UTGame.Default__UTBot'
}
