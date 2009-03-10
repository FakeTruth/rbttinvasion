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


DefaultProperties
{
	VoiceClass=class'UTGame.UTVoice_DefaultMale' // Set this through postbeginplay in the Monster class, so people can specify their own voice set
}