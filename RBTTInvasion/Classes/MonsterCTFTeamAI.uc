class MonsterCTFTeamAI extends UTCTFTeamAI;


function SetBotOrders(UTBot NewBot)
{
	if ( Objectives == None )
		SetObjectiveLists();

	PutOnOffense(NewBot);
}

defaultproperties
{
	OrderList(0)=ATTACK
	OrderList(1)=FREELANCE
	OrderList(2)=ATTACK
	OrderList(3)=FREELANCE
	OrderList(4)=ATTACK
	OrderList(5)=FREELANCE
	OrderList(6)=ATTACK
	OrderList(7)=ATTACK
	SquadType=class'RBTTInvasion.MonsterCTFSquadAI'
}
