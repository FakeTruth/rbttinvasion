// This is an actor that can modify/mutate invasion
// InvMod is short of Invasion Module
class InvMod extends Actor;

var InvMut NextInvMut;
var RBTTInvasionGameRules InvasionRules;

/**
 * Called after player died and is added to the queue
 */
function PlayerOut( UTPlayerReplicationInfo Who )
{
	if ( NextInvMut != None )
		NextInvMut.PlayerOut(Who);
}

/**
 * Called when a wave is about to start, called after new InvasionRules have been spawned (before countdown)
 */
function StartWave(GameRules G)
{
	InvasionRules = RBTTInvasionGameRules(G);
	if ( NextInvMut != None )
		NextInvMut.StartWave(G);
}

/**
 * Called when a wave has ended, before the InvasionRules are removed/destroyed
 */
function EndWave(GameRules G)
{
	if ( NextInvMut != None )
		NextInvMut.EndWave(G);
}

/**
 * Add a mutator to the chain
 */
function AddInvMut(InvMut IM)
{
	if ( NextInvMut == None )
		NextInvMut = IM;
	else
		NextInvMut.AddInvMut(IM);
}

defaultproperties
{
}