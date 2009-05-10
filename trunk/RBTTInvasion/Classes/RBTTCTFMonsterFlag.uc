class RBTTCTFMonsterFlag extends UTCTFBlueFlag;

function bool ValidHolder(Actor Other)
{
	local Controller C;

	C = Pawn(Other).Controller;
	if ( WorldInfo.GRI.OnSameTeam(self,C) )
		SameTeamTouch(c);

	return false;	// Nobody can pick up this flag!! It's the monsters'!
}

defaultproperties
{
	Begin Object Name=TheFlagSkelMesh
		Materials(1)=Material'RBTTInvasionTex.Materials.MonsterFlag'
	End Object
}