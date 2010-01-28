// This is an actor that can modify/mutate invasion
// InvMod is short of Invasion Module
class InvMod extends Actor;

var InvMod NextInvMod;
var RBTTInvasionGameRules InvasionRules;

/**
 * Called when someone uses a mutate command
 */
function Mutate (string MutateString, PlayerController Sender)
{
	if( NextInvMod != None )
		NextInvMod.Mutate(MutateString, Sender);
}

/**
 * Called when something has been killed
 */
function ScoreKill(Controller Killer, Controller Other)
{
	if( NextInvMod != None)
		NextInvMod.ScoreKill(Killer, Other);
}

/**
 * Called after player died and is added to the queue
 */
function PlayerOut( UTPlayerReplicationInfo Who )
{
	if ( NextInvMod != None )
		NextInvMod.PlayerOut(Who);
}

/**
 * Called when a wave is about to start, called after new InvasionRules have been spawned (before countdown)
 */
function StartWave(GameRules G)
{
	InvasionRules = RBTTInvasionGameRules(G);
	if ( NextInvMod != None )
		NextInvMod.StartWave(G);
}

/**
 * Called when a wave has ended, before the InvasionRules are removed/destroyed
 */
function EndWave(GameRules G)
{
	if ( NextInvMod != None )
		NextInvMod.EndWave(G);
}

/**
 * Add a mutator to the chain
 */
function AddInvMod(InvMod IM)
{
	if ( NextInvMod == None )
		NextInvMod = IM;
	else
		NextInvMod.AddInvMod(IM);
}

defaultproperties
{
}