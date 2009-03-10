class RBTTInvasionHud extends UTTeamHud 
		config(RBTTMonsters);


var float RadarPulse,RadarScale;
var config float RadarPosX, RadarPosY;
var float LastDrawRadar;
var float MinEnemyDist;
var string GameName;

/** camera emitter played on player in volume */
var class<UTEmitCameraEffect> InsideCameraEffect;
var PostProcessChain EntryPostProcessChain;
var array<PostProcessChain> OldPostProcessChain;

var bool bScreenBlurred;
var bool bBlurInitialized;
var float LastBlurTime;

var config bool bEnableLowHealthBlur;
var config float BlurBelowHealthRatio;

/* // Only do this when new default values need to be in the INI file
simulated function PostBeginPlay()
{
SaveConfig; // Save the config to the INI
super.PostBeginPlay();
}
*/

function DisplayTeamScore()
{
	local float DestScale, Dist, MaxDist, W, H, POSX, OffsetY, Angle, OffsetScale, DotSize, RadarWidth,PulseWidth, PulseBrightness;
	local vector2d Logo;
	local byte TeamIndex;
	local LinearColor TeamLC;
	local color TextC;
	local int NewScore;
	local rotator Dir;
	local vector Start;
	local Pawn P;	
	local UTPlayerReplicationInfo PRI;
	
	Canvas.DrawColor = WhiteColor;
    W = 214 * ResolutionScaleX;
    H = 87 * ResolutionScale;

	// Draw the Left Team Indicator
	DestScale = 1.0;
	TeamIndex = UTPlayerOwner.GetTeamNum();
	if ( (TeamIndex == 255) || bIsSplitScreen )
	{
		// spectator
		TeamIndex = 0;
		DestScale = TeamScaleModifier;
	}
	GetTeamColor(TeamIndex, TeamLC, TextC);
	POSX = Canvas.ClipX * 0.49 - W;

	Canvas.SetPos(POSX, 0);
	Canvas.DrawColorizedTile(IconHudTexture, W * DestScale, H * DestScale, 0, 491, 214, 87, TeamLC);

	NewScore = GetTeamScore(TeamIndex);
	if ( NewScore != OldLeftScore )
	{
		LeftTeamPulseTime = WorldInfo.TimeSeconds;
	}
	OldLeftScore = NewScore;

	if (DestScale < 1.0)
	{
		DrawGlowText(string(NewScore), POSX + 97 * ResolutionScaleX, -2 * ResolutionScale, 50 * ResolutionScale, LeftTeamPulseTime, true);
	}
	else
	{
		DrawGlowText(string(NewScore), POSX + 124 * ResolutionScaleX, -2 * ResolutionScale, 60 * ResolutionScale, LeftTeamPulseTime, true);
	}

	Logo.X = POSX + ((TeamIconCenterPoints[0].X) * DestScale * ResolutionScaleX) + (30 * ResolutionScaleX);
	Logo.Y = ((TeamIconCenterPoints[0].Y) * DestScale * ResolutionScale) + (27.5 * ResolutionScale);

   	DisplayTeamLogos(TeamIndex,Logo, 1.5);


///////////////////////////////////////////////////////////////

	RadarScale = Default.RadarScale * HudCanvasScale;
	RadarWidth = 0.5 * RadarScale * Canvas.ClipX;
	PulseWidth = RadarScale * Canvas.ClipX;
	Canvas.DrawColor = RedColor;
	//Canvas.Style = ERenderStyle.STY_Translucent;
	PulseBrightness = FMax(0,(1 - 2*RadarPulse) * 255.0);
	Canvas.DrawColor.A = PulseBrightness;
	Canvas.SetPos(RadarPosX*Canvas.ClipX - 0.5*PulseWidth,RadarPosY*Canvas.ClipY+RadarWidth-0.5*PulseWidth);
	//Canvas.DrawColorizedTile( Texture2D'RBTTInvasionTex.SkinA', PulseWidth, PulseWidth, 0, 880, 142, 142, TeamLC);
	PulseWidth = RadarPulse * RadarScale * Canvas.ClipX; Canvas.DrawColor = RedColor;
	Canvas.SetPos(RadarPosX*Canvas.ClipX - 0.5*PulseWidth,RadarPosY*Canvas.ClipY+RadarWidth-0.5*PulseWidth); 
	Canvas.DrawColorizedTile( Texture2D'RBTTInvasionTex.SkinA', PulseWidth, PulseWidth, 0, 880, 142, 142, TeamLC); 
	//Canvas.Style = ERenderStyle.STY_Alpha;
	//Canvas.DrawColor = GetTeamColor( PawnOwner.GetTeamNum() );
	Canvas.SetPos(RadarPosX*Canvas.ClipX - RadarWidth,RadarPosY*Canvas.ClipY+RadarWidth);
	Canvas.DrawColorizedTile( Texture2D'RBTTInvasionTex.AssaultRadar2', RadarWidth, RadarWidth, 0, 512, 512, -512, TeamLC);
	Canvas.SetPos(RadarPosX*Canvas.ClipX,RadarPosY*Canvas.ClipY+RadarWidth);
	Canvas.DrawColorizedTile( Texture2D'RBTTInvasionTex.AssaultRadar2', RadarWidth, RadarWidth, 512, 512, -512, -512, TeamLC);
	Canvas.SetPos(RadarPosX*Canvas.ClipX - RadarWidth,RadarPosY*Canvas.ClipY);
	Canvas.DrawColorizedTile( Texture2D'RBTTInvasionTex.AssaultRadar2', RadarWidth, RadarWidth, 0, 0, 512, 512, TeamLC);
	Canvas.SetPos(RadarPosX*Canvas.ClipX,RadarPosY*Canvas.ClipY);
	Canvas.DrawColorizedTile( Texture2D'RBTTInvasionTex.AssaultRadar2', RadarWidth, RadarWidth, 512, 0, -512, 512, TeamLC);

	///////////////////////////////////////////////////////////////////////////
	
	LastDrawRadar = WorldInfo.TimeSeconds;
	RadarWidth = 0.5 * RadarScale * Canvas.ClipX;
	DotSize = 24*Canvas.ClipX*HudCanvasScale/1600;
	if ( PawnOwner == None )
		Start = PlayerOwner.Location;
	else
		Start = PawnOwner.Location;
	
	MaxDist = 3000 * RadarPulse;
	//C.Style = ERenderStyle.STY_Translucent;
	OffsetY = RadarPosY + RadarWidth/Canvas.ClipY;
	MinEnemyDist = 3000;
	ForEach DynamicActors(class'Pawn',P)
		if ( P.Health > 0 )
		{
			Dist = VSize(Start - P.Location);
			if ( Dist < 3000 )
			{
				if ( Dist < MaxDist )
					PulseBrightness = 255 - 255*Abs(Dist*0.00033 - RadarPulse);
				else
					PulseBrightness = 255 - 255*Abs(Dist*0.00033 - RadarPulse - 1);
				
				PRI = UTPlayerReplicationInfo(P.PlayerReplicationInfo);
				
				if ( PRI != none)
				{
					
					if ( PRI.Team.TeamIndex == 0)
					{
						MinEnemyDist = FMin(MinEnemyDist, Dist);
						Canvas.DrawColor.R = 0;
						Canvas.DrawColor.G = PulseBrightness;
						Canvas.DrawColor.B = 0;
						Canvas.DrawColor.A = PulseBrightness;
					}
					else
					{
						MinEnemyDist = FMin(MinEnemyDist, Dist);
						Canvas.DrawColor.R = PulseBrightness;
						Canvas.DrawColor.G = 0;
						Canvas.DrawColor.B = 0;
						Canvas.DrawColor.A = PulseBrightness;
					}
				}
				else
				{
					Canvas.DrawColor.R = 0;
					Canvas.DrawColor.G = 0;
					Canvas.DrawColor.B = PulseBrightness;
					Canvas.DrawColor.A = PulseBrightness;
				}
				Dir = rotator(P.Location - Start);
				OffsetScale = RadarScale*Dist*0.000167;
				if ( PawnOwner == None )
					Angle = ((Dir.Yaw - PlayerOwner.Rotation.Yaw) & 65535) * 6.2832/65536;
				else
					Angle = ((Dir.Yaw - PawnOwner.Rotation.Yaw) & 65535) * 6.2832/65536;
				Canvas.SetPos(RadarPosX * Canvas.ClipX + OffsetScale * Canvas.ClipX * sin(Angle) - 0.5*DotSize,
						OffsetY * Canvas.ClipY - OffsetScale * Canvas.ClipX * cos(Angle) - 0.5*DotSize);
				Canvas.DrawTile( Texture2D'RBTTInvasionTex.SkinA',DotSize,DotSize,838,238,144,144);
			}
		}			
}




function int GetTeamScore(byte TeamIndex)
{

		return INT(UTGRI.Teams[0].Score);	

}


simulated function Tick(float DeltaTime)
{
	//local MotionBlurEffect MotionBlur;

	Super.Tick(DeltaTime);
	RadarPulse = RadarPulse + 0.5 * DeltaTime;
	if ( RadarPulse >= 1 )
	{
		if (WorldInfo.TimeSeconds - LastDrawRadar < 0.2) 
		PlayerOwner.ClientPlaySound(SoundCue'RBTTInvasionTex.RadarPulseSoundCue');
		RadarPulse = RadarPulse - 1;
	}
	
	//if(InsideCameraEffect != None)
	//{
	//	UTPlayerController(PlayerOwner).ClientSpawnCameraEffect(InsideCameraEffect);
	//	InsideCameraEffect = None;
	//}
	
	if(bEnableLowHealthBlur) // Don't do blur if server dont want blur..
		HandleBlur(DeltaTime);
	
	//DOFEffect(LocalPlayer(PlayerOwner.Player).PlayerPostProcessChains[0].FindPostProcessEffect('DOFBlur')).FocusDistance += 1.00;
	//if(DOFEffect(LocalPlayer(PlayerOwner.Player).PlayerPostProcessChains[0].FindPostProcessEffect('DOFBlur')).FocusDistance > 800.00)
	//	DOFEffect(LocalPlayer(PlayerOwner.Player).PlayerPostProcessChains[0].FindPostProcessEffect('DOFBlur')).FocusDistance = 0.00;
		
	//for (i=0;i < LocalPlayer(PlayerOwner.Player).PlayerPostProcessChains[0].Effects.length; i++)
	//	`log(">>>>> Idx:"@i@" class:"@LocalPlayer(PlayerOwner.Player).PlayerPostProcessChains[0].Effects[i].class@"<<<<<");
	
	//BlurryBlur = UberPostProcessEffect(LocalPlayer(PlayerOwner.Player).PlayerPostProcessChains[0].FindPostProcessEffect('DOFBlur'));

	
}

simulated function HandleBlur(float DeltaTime)
{
	local UberPostProcessEffect BlurryBlur;

	if(!bBlurInitialized) // Set some PostProcessEffects settings so we can use it to add blur
	{
		bBlurInitialized = True;
		
		BlurryBlur = UberPostProcessEffect(LocalPlayer(PlayerOwner.Player).PlayerPostProcessChains[0].Effects[0]);
		
		BlurryBlur.bUseWorldSettings = False;
		BlurryBlur.bShowInGame = True;
		BlurryBlur.FocusDistance = 0.0000;
	}
	
	if(PlayerOwner.Pawn != None && PlayerOwner.Pawn.health < (PlayerOwner.Pawn.HealthMax * BlurBelowHealthRatio)) // If the player has low health, blur his screen
	{
		
		//LocalPlayer(PlayerOwner.Player).RemoveAllPostProcessingChains();
		//LocalPlayer(PlayerOwner.Player).InsertPostProcessingChain(EntryPostProcessChain, -1, FALSE);
		//BlurryBlur = UberPostProcessEffect(LocalPlayer(PlayerOwner.Player).PlayerPostProcessChains[0].FindPostProcessEffect('DOFBlur'));
		
		if(BlurryBlur == None)
			BlurryBlur = UberPostProcessEffect(LocalPlayer(PlayerOwner.Player).PlayerPostProcessChains[0].Effects[0]);
		if(BlurryBlur == None)
			return;
		
		LastBlurTime = WorldInfo.TimeSeconds;
		
		BlurryBlur.FocusInnerRadius = 400.00;
		
		BlurryBlur.MaxFarBlurAmount = abs(sin(LastBlurTime*2));
		//BlurryBlur.MaxNearBlurAmount = abs(sin(WorldInfo.TimeSeconds));
		BlurryBlur.BloomScale = abs(sin(LastBlurTime*4))*10;
		BlurryBlur.SceneDesaturation = abs(sin(LastBlurTime*2))/2;
		
		//MotionBlurEffect(LocalPlayer(PlayerOwner.Player).PlayerPostProcessChains[0].FindPostProcessEffect('MotionBlur')).MotionBlurAmount = 10;
		if(!bScreenBlurred)
		{
			MotionBlurEffect(LocalPlayer(PlayerOwner.Player).PlayerPostProcessChains[0].Effects[1]).MotionBlurAmount = 50;
			//UTPlayerController(PlayerOwner).ClientSpawnCameraEffect(InsideCameraEffect); // Add some ugly effect
			bScreenBlurred = True;
		}
	}
	else if(bScreenBlurred) // Fade the blur out if screen is blurred but player has enough health
	{
		if(BlurryBlur == None)
			BlurryBlur = UberPostProcessEffect(LocalPlayer(PlayerOwner.Player).PlayerPostProcessChains[0].Effects[0]);
		if(BlurryBlur == None)
			return;
			
		if(WorldInfo.TimeSeconds < LastBlurTime+4)
		{
			BlurryBlur.MaxFarBlurAmount += (0.00 - BlurryBlur.MaxFarBlurAmount)*2*DeltaTime;
			//BlurryBlur.MaxNearBlurAmount = 0.00;
			BlurryBlur.BloomScale += (1.00 - BlurryBlur.BloomScale)*2*DeltaTime;
			BlurryBlur.FocusInnerRadius += (2000.00 - BlurryBlur.FocusInnerRadius)*2*DeltaTime;
			//BlurryBlur.FocusDistance = 0.00;
			BlurryBlur.SceneDesaturation += (0.400 - BlurryBlur.SceneDesaturation)*2*DeltaTime;
			MotionBlurEffect(LocalPlayer(PlayerOwner.Player).PlayerPostProcessChains[0].Effects[1]).MotionBlurAmount += (0.125000 - MotionBlurEffect(LocalPlayer(PlayerOwner.Player).PlayerPostProcessChains[0].Effects[1]).MotionBlurAmount)*2*DeltaTime;
		}
		else
		{
			BlurryBlur.MaxFarBlurAmount = 0.00;
			//BlurryBlur.MaxNearBlurAmount = 0.00;
			BlurryBlur.BloomScale = 1.00;
			BlurryBlur.FocusInnerRadius = 2000.00;
			//BlurryBlur.FocusDistance = 0.00;
			BlurryBlur.SceneDesaturation = 0.400;
			MotionBlurEffect(LocalPlayer(PlayerOwner.Player).PlayerPostProcessChains[0].Effects[1]).MotionBlurAmount = 0.125000;
			bScreenBlurred = False;
			//UTPlayerController(PlayerOwner).ClearCameraEffect(); // Remove some ugly effect
		}
	}
}

defaultproperties
{
	bHasLeaderboard=false
	bShowDirectional=false

	//ScoreboardSceneTemplate=UTUIScene_TeamScoreboard'UI_Scenes_Scoreboards.sbTeamDM'
	ScoreboardSceneTemplate=UTUIScene_Scoreboard'RBTTInvasionTex.sbInvasion'
	TeamScaleModifier=0.75

	TeamIconCenterPoints(0)=(x=140.0,y=27.0)
	TeamIconCenterPoints(1)=(x=5,y=13)
	GameName="RBTTInvasion"
	RadarScale=0.200000
    RadarPosX=0.900000
    RadarPosY=0.250000

    BlurBelowHealthRatio=0.3
    bEnableLowHealthBlur=True;
    InsideCameraEffect=class'UTEmitCameraEffect_SlowVolume'
    //EntryPostProcessChain=PostProcessChain'FX_HitEffects.UTPostProcess'
    EntryPostProcessChain=PostProcessChain'RBTTInvasionTex.PostProcessEffect'
}
