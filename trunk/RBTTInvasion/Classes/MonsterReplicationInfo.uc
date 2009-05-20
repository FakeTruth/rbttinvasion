class MonsterReplicationInfo extends UTPlayerReplicationInfo;

simulated function bool ShouldBroadCastWelcomeMessage() 
{
	return false;
}

/** Util to swamp the team skin colour on a custom character mesh. */
simulated function bool UpdateCustomTeamSkin()
{
	`log(">>>UpdateCustomTeamSkin()<<<");
	return FALSE; // We dont want this happening on monsters
}

/** Save the materials off the supplied mesh as the 'other' team materials. */
simulated function SetOtherTeamSkin(SkeletalMesh NewSkelMesh)
{
	`log(">>>SetOtherTeamSkin(SkeletalMesh NewSkelMesh)<<<");
	return;
}

/** Accessor that sets the custom character mesh to use for this PRI, and updates instance of player in map if there is one. */
simulated function SetCharacterMesh(SkeletalMesh NewSkelMesh, optional bool bIsReplacement)
{
	`log(">>>SetCharacterMesh()<<<");
	return;
}
simulated event Destroyed()
{
	local UTLinkedReplicationInfo NextReplicationInfo;
	
	`log(">> MonsterReplicationInfo.Destroyed()<<");
	While(CustomReplicationInfo != None)
	{
		NextReplicationInfo = CustomReplicationInfo.NextReplicationInfo;
		`log(">> Gonna remove LRI:"@CustomReplicationInfo.class@"<<");
		CustomReplicationInfo.Destroy();
		CustomReplicationInfo = NextReplicationInfo;
	}
	Super.Destroyed();
}

function Reset()
{
	`log(">> Reset() <<");
	Super.Reset();
	Destroy();
}

function PlayerReplicationInfo Duplicate()
{
	`log(">> PlayerReplicationInfo Duplicate() <<");
	Destroy();
	return None;
}

function OverrideWith(PlayerReplicationInfo PRI)
{
	`log(">> OverrideWith(PlayerReplicationInfo PRI) <<");
	Destroy();
}

function CopyProperties(PlayerReplicationInfo PRI)
{
	`log(">> CopyProperties(PlayerReplicationInfo PRI) <<");
	Destroy();
}

function SeamlessTravelTo(PlayerReplicationInfo NewPRI)
{
	`log(">> SeamlessTravelTo(PlayerReplicationInfo NewPRI) <<");
	Destroy();
	Owner.Destroy();
}

DefaultProperties
{
	VoiceClass=class'UTGame.UTVoice_DefaultMale' // Set this through postbeginplay in the Monster class, so people can specify their own voice set
}