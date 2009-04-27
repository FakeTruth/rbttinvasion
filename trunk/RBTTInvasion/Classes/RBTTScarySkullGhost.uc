class RBTTScarySkullGhost extends RBTTScarySkull;

simulated function RemoveSkullEffects(); // Don't wanna turn ghost effects off when dead

defaultproperties
{
	EmitterTemplate=ParticleSystem'RBTTScarySkull.GhostEmitter'
	AccelRate=750.000000
	GroundSpeed=750.000000
	AirSpeed=750.00000
}