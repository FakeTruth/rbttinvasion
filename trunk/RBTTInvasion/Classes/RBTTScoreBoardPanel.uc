class RBTTScoreBoardPanel extends UTScoreboardPanel;

/** Sets the header strings using localized values */
function SetHeaderStrings()
{
	HeaderTitle_Name = Localize( "Scoreboards", "Name", "UTGameUI" );
	//HeaderTitle_Score = Localize( "Scoreboards", "Kills", "UTGameUI" );
	HeaderTitle_Score = "Score";
	HeaderTitle_Deaths = Localize( "Scoreboards", "Deaths", "UTGameUI" );
}

/** Draw the panel headers. */
function DrawScoreHeader()
{
	local float xl,yl,columnWidth, numXL, numYL;

	if ( HeaderFont != none )
	{
		Canvas.SetDrawColor(255,255,255,255);

		Canvas.Font = Fonts[EFT_Large].Font;
		Canvas.StrLen("0000",numXL,numYL);

		// Name
		Canvas.Font = HeaderFont;
		Canvas.SetPos(Canvas.ClipX * HeaderXPct,Canvas.ClipY * HeaderYPos);
		Canvas.DrawTextClipped(HeaderTitle_Name);

		// Deaths
		Canvas.StrLen(HeaderTitle_Deaths,xl,yl);
		RightColumnWidth = xl;
		columnWidth = Max(xl+0.25f*numXL, numXL);
		RightColumnPosX = Canvas.ClipX - columnWidth;
		Canvas.SetPos(RightColumnPosX,Canvas.ClipY * HeaderYPos);
		Canvas.DrawTextClipped(HeaderTitle_Deaths);

		// Score
		Canvas.StrLen(HeaderTitle_Score,xl,yl);
		LeftColumnWidth = xl;
		columnWidth = Max(xl, numXL);
		columnWidth += 0.25f*numXL;
		LeftColumnPosX = RightColumnPosX - columnWidth;
		Canvas.SetPos(LeftColumnPosX, Canvas.ClipY * HeaderYPos);
		Canvas.DrawTextClipped(HeaderTitle_Score);
	}
}

/**
* Draw the Players Score
*/
function float DrawScore(UTPlayerReplicationInfo PRI, float YPos, int FontIndex, float FontScale)
{
	local string Spot;
	local float Width, Height;

	// Draw the player's deaths 
	Spot = GetPlayerDeaths(PRI);
	Canvas.Font = Fonts[FontIndex].Font;
	Canvas.StrLen( Spot, Width, Height );
	DrawString( Spot, RightColumnPosX+RightColumnWidth-Width, YPos,FontIndex,FontScale);

	// Draw the player's score
	Spot = GetPlayerScore(PRI);
	Canvas.StrLen( Spot, Width, Height );
	DrawString( Spot, LeftColumnPosX+LeftColumnWidth-Width, YPos,FontIndex,FontScale);

	return RightColumnPosX;
}

function DrawTeamScore()
{
	local string ScoreStr;
	local float xl,yl, xPos;
	local WorldInfo WI;
	local int ScoreToDraw;

	Canvas.DrawColor = class'UTHUD'.default.Whitecolor;
	if ( ScoreFont != none )
	{
		WI = GetScene().GetWorldInfo();
		ScoreStr = "0";

		Canvas.Font = Font'UI_Fonts_Final.HUD.MF_Large';
		if ( WI != none && WI.GRI != none && (WI.GRI.Teams.Length > AssociatedTeamIndex) && (WI.GRI.Teams[AssociatedTeamIndex] != None) )
		{
			ScoreToDraw = Min(WI.GRI.Teams[AssociatedTeamIndex].Score, 9999);
			ScoreStr = string(ScoreToDraw);
		}
		Canvas.StrLen(ScoreStr,XL,YL);
		xPos = Canvas.ClipX * ScorePosition.X - XL * 0.5;
		Canvas.SetPos(xPos, Canvas.ClipY * ScorePosition.Y - YL * 0.5);
		Canvas.DrawText(ScoreStr);
	}
}

/**
 * Draw an full cell.. Call the functions above.
 */
function DrawPRI(int PIndex, UTPlayerReplicationInfo PRI, float CellHeight, int FontIndex, int ClanTagFontIndex, int MiscFontIndex, float FontScale, out float YPos)
{
	local float NameOfst, NameClipX;

	// Set the default Drawing Color
	DrawHighlight(PRI, YPos, CellHeight, FontScale);

	if ( PRI == UTUIScene(GetScene()).GetPRIOwner() )
	{
		Canvas.DrawColor = class'UTHUD'.default.GoldColor;
	}
	else
	{
		Canvas.DrawColor = class'HUD'.default.WhiteColor;
	}

	// Line up the names with the header.
	NameOfst = Canvas.ClipX * HeaderXPct;

	YPos += (HighlightPad*ResolutionScale);

	Canvas.DrawColor.A = 105;
	DrawClanTag(PRI, NameOfst, YPos, ClanTagFontIndex, FontScale);

	// Draw the player's Score so we can see how much room we have to draw the name
	if ( PRI == UTUIScene(GetScene()).GetPRIOwner() )
	{
		Canvas.DrawColor.A = 255;
	}
	else
	{
		Canvas.DrawColor.A = 128;
	}
	if ( PRI == None || !PRI.bFromPreviousLevel || PRI.WorldInfo.IsInSeamlessTravel() ||
		(PlayerOwner != None && PlayerOwner.PlayerReplicationInfo != None && PlayerOwner.PlayerReplicationInfo.bFromPreviousLevel) )
	{
		NameClipX = DrawScore(PRI, YPos, FontIndex, FontScale);
	}
	else
	{
		NameClipX = Canvas.ClipX;
	}


	// Draw the Player's Name and position on the team - NOTE it doesn't increment YPos
	if (bDrawPlayerNum)
	{
		DrawPlayerNum(PRI, PIndex, YPos, FontIndex, FontScale);
	}

	DrawPlayerName(PRI, NameOfst, NameClipX, YPos, FontIndex, FontScale, (ClanTagFontIndex >= 0));

	Canvas.DrawColor.A = 105;
	DrawMisc(PRI, NameOfst, YPos, MiscFontIndex, FontScale);

	YPos += (HighlightPad*ResolutionScale);
}

/** Get the header color */ //Set it to a cool color :) normally used for teams, but can be used to manually set a color!
/* 
function LinearColor GetHeaderColor()
{
	local LinearColor LC;
	local Color C;
	class'UTHUD'.static.GetTeamColor(AssociatedTeamIndex, LC,C);
	LC.A = 1.0f;
	return LC;
}
*/

function string GetLeftMisc(UTPlayerReplicationInfo PRI)
{
	if ( PRI != None )
	{
		if(PRI.Owner.IsInState('InQueue'))
		{
			return "is OUT!";
		}
		if (LeftMiscStr != "")
		{
			return UserString(LeftMiscStr, PRI);
		}
		else
		{
			if ( PRI.WorldInfo.GRI.OnSameTeam(PRI, PlayerOwner) )
			{
				return ""$PRI.GetLocationName();
			}
			else
			{
				return "";
			}
		}
	}
	else // if it got no ReplicationInfo, it's probably dead? 0.o
		return "is OUT!";
		
	return "LMisc";
}



defaultproperties
{
	bDrawPlayerNum=false
}
