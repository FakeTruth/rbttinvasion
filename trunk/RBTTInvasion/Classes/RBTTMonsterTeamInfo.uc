/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */
//=============================================================================
// RBTTMonsterTeamInfo.
// includes list of bots on team for multiplayer games
//
//=============================================================================

class RBTTMonsterTeamInfo extends UTTeamInfo;

simulated function string GetHumanReadableName()
{
	if ( TeamName == Default.TeamName )
	{
		if ( TeamIndex < 4 )
			return TeamColorNames[TeamIndex];
		return TeamName@TeamIndex;
	}
	return TeamName;
}

function GetAvailableBotList(out array<int> AvailableBots, optional string FactionFilter, optional bool bMalesOnly)
{
	local int i;

	AvailableBots.length = 0;
	for (i=0;i<class'RBTTCustomMonster_Data'.default.Characters.length;i++)
	{
		if(	(FactionFilter == "" || class'RBTTCustomMonster_Data'.default.Characters[i].Faction ~= FactionFilter) &&
			(!bMalesOnly || FamilyIsMale(class'RBTTCustomMonster_Data'.default.Characters[i].CharData.FamilyID)) &&
			!BotNameTaken(class'RBTTCustomMonster_Data'.default.Characters[i].CharName) )
		{
			AvailableBots[AvailableBots.Length] = i;
		}
	}
}
function bool BotNameTaken(string BotName)
{
	//DUNNO IF THIS WILL BREAK STUFF BUT WANT THE BOTS ALWAYS AVAILABLE!!
	return false;
}
/** retrieves bot info, for the named bot if a valid name is specified, otherwise from a random bot */
function CharacterInfo GetBotInfo(string BotName)
{
	local int Index;
	local array<int> AvailableBots;
	local bool bMalesOnly;

	// Only allow male chars once game is in progress..
	bMalesOnly = WorldInfo.Game.IsInState('MatchInProgress');

	Index = class'RBTTCustomMonster_Data'.default.Characters.Find('CharName', BotName);
	if (Index == INDEX_NONE)
	{
		// First attempt to add a bot from the Faction
		if (Faction != "")
		{
			GetAvailableBotList(AvailableBots,Faction,bMalesOnly);
			if (AvailableBots.Length > 0)
			{
				Index = AvailableBots[0];
			}
		}

		// If we still haven't found a good match, take a bot from any faction
		if (Index == INDEX_None)
		{
			GetAvailableBotList(AvailableBots,,bMalesOnly);
			if (AvailableBots.Length > 0)
			{
				Index = AvailableBots[Rand(AvailableBots.Length)];
			}
		}

		// If we still haven't found a good match looking for men, take a female
		if (bMalesOnly && Index == INDEX_None)
		{
			GetAvailableBotList(AvailableBots);
			if (AvailableBots.Length > 0)
			{
				Index = AvailableBots[Rand(AvailableBots.Length)];
			}
		}

		// At this point, if we haven't found a bot, just take any bot
		if ( Index == INDEX_None )
		{
			Index = Rand(class'RBTTCustomMonster_Data'.default.Characters.length);
		}
	}

	return class'RBTTCustomMonster_Data'.default.Characters[Index];
}

defaultproperties
{
   TeamName="RBTTMonsterTeam"
   Name="Default__RBTTMonsterTeamInfo"
   ObjectArchetype=UTTeamInfo'UTGame.Default__UTTeamInfo'
}
