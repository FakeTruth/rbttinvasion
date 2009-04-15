Class InvasionInteraction extends Interaction config(RBTTInvasion);

var UTPlayerController OwnerController;
var RBTTPRI RBPRI;

/** Radar variables */
var float RadarPulse,RadarScale;
var config float RadarPosX, RadarPosY;
var float LastDrawRadar;
var float MinEnemyDist;
/**-Radar variables-*/

/** Blur user settings */
var config bool bEnableLowHealthBlur;
var config float BlurBelowHealthRatio;

/** Helpful information for blur */
var bool bScreenBlurred;
var bool bBlurInitialized;
var float LastBlurTime;

/** variables before screen blurrss */
var float InSceneDesaturation;
var float InBloomScale;
var float InFocusInnerRadius;
var float InFocusDistance;
var float InMaxFarBlurAmount;
/**-Blur variables-*/



event PostRender(Canvas Canvas)
{
	//local UTHud uth;
	//local float XPos, YPos, lineH;
	

	//`log(">> Rendering <<");
	
	//uth = UTHud(OwnerController.MyHUD);
	//if (uth == None)
	//	return;
	
	//XPos = 20 * uth.ResolutionScale;
	//YPos = 120 * uth.ResolutionScale;

	//lineH represents the onscreen line spacing of our text, in case we need it
	//lineH = 20 * uth.ResolutionScale;
	
	//Canvas.Font = Font'EngineFonts.SmallFont';
	//Canvas.Font = Font'MF_Medium';
	
	//Canvas.SetDrawColor(255,255,255,255);

	//Canvas.SetPos(XPos , YPos);
	//Canvas.DrawText("I'm overlaying correctly! My OwnerController is" @ OwnerController);

	//YPos += lineH;
	//Canvas.SetPos(XPos , YPos);
	//Canvas.DrawText("And now a second line. It's the best day in my life!");
	//YPos += lineH;
	//Canvas.SetPos(XPos , YPos);
	//Canvas.DrawText("RadarPulse: "@RadarPulse);
	
	if(RBPRI == None)
	{
		RBPRI = Class'RBTTInvasionMutator'.static.GetRBTTPRI(UTPlayerReplicationInfo(OwnerController.PlayerReplicationInfo));
		if(RBPRI == None)
			return;
	}
	
	DrawRadar(Canvas);
	DrawWaveInfo(Canvas);
}

function DrawWaveInfo(Canvas Canvas)
{
	local UTHud uth;

	uth = UTHud(OwnerController.MyHUD);
	if (uth == None)
		return;
		
	Canvas.Font = Font'MF_Medium';
	Canvas.DrawColor = uth.WhiteColor;
		
	Canvas.SetPos(0.900000*Canvas.ClipX,0.200000*Canvas.ClipY);
	Canvas.DrawText("Wave: "@RBPRI.CurrentWave+1);
}

function DrawRadar(Canvas Canvas)
{
	local float Dist, MaxDist, OffsetY, Angle, OffsetScale, DotSize, RadarWidth,PulseWidth, PulseBrightness;
	local byte TeamIndex;
	local LinearColor TeamLC;
	local color TextC;
	local rotator Dir;
	local vector Start;
	local Pawn P;	
	local UTPlayerReplicationInfo PRI;
	
	/** HUD variable references */
	local UTHud uth;
	local float HudCanvasScale;
	local color RedColor;
	
	uth = UTHud(OwnerController.MyHUD);
	if (uth == None)
		return;
		
	HudCanvasScale 	= uth.HudCanvasScale;
	RedColor 	= uth.RedColor;
	TeamIndex = OwnerController.GetTeamNum();
	uth.GetTeamColor(TeamIndex, TeamLC, TextC);

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
	
	LastDrawRadar = OwnerController.WorldInfo.TimeSeconds;
	RadarWidth = 0.5 * RadarScale * Canvas.ClipX;
	DotSize = 24*Canvas.ClipX*HudCanvasScale/1600;
	if ( OwnerController.Pawn == None )
		Start = OwnerController.Location;
	else
		Start = OwnerController.Pawn.Location;
	
	MaxDist = 3000 * RadarPulse;
	//C.Style = ERenderStyle.STY_Translucent;
	OffsetY = RadarPosY + RadarWidth/Canvas.ClipY;
	MinEnemyDist = 3000;
	ForEach OwnerController.DynamicActors(class'Pawn',P)
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
				if ( OwnerController.Pawn == None )
					Angle = ((Dir.Yaw - OwnerController.Rotation.Yaw) & 65535) * 6.2832/65536;
				else
					Angle = ((Dir.Yaw - OwnerController.Pawn.Rotation.Yaw) & 65535) * 6.2832/65536;
				Canvas.SetPos(RadarPosX * Canvas.ClipX + OffsetScale * Canvas.ClipX * sin(Angle) - 0.5*DotSize,
						OffsetY * Canvas.ClipY - OffsetScale * Canvas.ClipX * cos(Angle) - 0.5*DotSize);
				Canvas.DrawTile( Texture2D'RBTTInvasionTex.SkinA',DotSize,DotSize,838,238,144,144);
			}
		}
}


event Tick(float DeltaTime)
{
	Super.Tick(DeltaTime);
	if(DeltaTime < 0) // Why I need this check? Have no idea...
		return;
	
	RadarPulse = RadarPulse + 0.5 * DeltaTime;
	if ( RadarPulse >= 1 )
	{
		if (OwnerController.WorldInfo.TimeSeconds - LastDrawRadar < 0.2) 
			OwnerController.ClientPlaySound(SoundCue'RBTTInvasionTex.RadarPulseSoundCue');
		RadarPulse = RadarPulse - 1;
	}
	
	if(bEnableLowHealthBlur) // Don't do blur if player dont want blur..
		HandleBlur(DeltaTime);
}

function HandleBlur(float DeltaTime)
{
	local UberPostProcessEffect BlurryBlur;

	if(!bBlurInitialized) // Set some PostProcessEffects settings so we can use it to add blur
	{
		bBlurInitialized = True;
		
		BlurryBlur = UberPostProcessEffect(LocalPlayer(OwnerController.Player).PlayerPostProcessChains[0].Effects[0]);
		
		//BlurryBlur.bUseWorldSettings = False;
		BlurryBlur.bShowInGame = True;
		//BlurryBlur.FocusDistance = 0.0000;
	}
	
	if(OwnerController.Pawn != None && OwnerController.Pawn.health < (OwnerController.Pawn.HealthMax * BlurBelowHealthRatio)) // If the player has low health, blur his screen
	{
		
		//LocalPlayer(PlayerOwner.Player).RemoveAllPostProcessingChains();
		//LocalPlayer(PlayerOwner.Player).InsertPostProcessingChain(EntryPostProcessChain, -1, FALSE);
		//BlurryBlur = UberPostProcessEffect(LocalPlayer(PlayerOwner.Player).PlayerPostProcessChains[0].FindPostProcessEffect('DOFBlur'));
		
		if(BlurryBlur == None)
			BlurryBlur = UberPostProcessEffect(LocalPlayer(OwnerController.Player).PlayerPostProcessChains[0].Effects[0]);
		if(BlurryBlur == None)
			return;
				
		BlurryBlur.bUseWorldSettings = False;
		
		if(!bScreenBlurred)
		{
			MotionBlurEffect(LocalPlayer(OwnerController.Player).PlayerPostProcessChains[0].Effects[1]).MotionBlurAmount = 50;
			InSceneDesaturation = BlurryBlur.SceneDesaturation;
			InBloomScale = BlurryBlur.BloomScale;
			InFocusInnerRadius = BlurryBlur.FocusInnerRadius;
			InFocusDistance = BlurryBlur.FocusDistance;
			InMaxFarBlurAmount = BlurryBlur.MaxFarBlurAmount;
			//UTPlayerController(PlayerOwner).ClientSpawnCameraEffect(InsideCameraEffect); // Add some ugly effect
			bScreenBlurred = True;
		}
		
		BlurryBlur.FocusDistance = 0.0000;
		
		LastBlurTime = OwnerController.WorldInfo.TimeSeconds;
		
		BlurryBlur.FocusInnerRadius = 400.00;
		
		BlurryBlur.MaxFarBlurAmount = abs(sin(LastBlurTime*2));
		//BlurryBlur.MaxNearBlurAmount = abs(sin(WorldInfo.TimeSeconds));
		BlurryBlur.BloomScale = abs(sin(LastBlurTime*4))*10;
		BlurryBlur.SceneDesaturation = abs(sin(LastBlurTime*2))/2;
		
		//MotionBlurEffect(LocalPlayer(PlayerOwner.Player).PlayerPostProcessChains[0].FindPostProcessEffect('MotionBlur')).MotionBlurAmount = 10;
	}
	else if(bScreenBlurred) // Fade the blur out if screen is blurred but player has enough health
	{
		if(BlurryBlur == None)
			BlurryBlur = UberPostProcessEffect(LocalPlayer(OwnerController.Player).PlayerPostProcessChains[0].Effects[0]);
		if(BlurryBlur == None)
			return;
			
		if(OwnerController.WorldInfo.TimeSeconds < LastBlurTime+2)
		{
			BlurryBlur.MaxFarBlurAmount += (InMaxFarBlurAmount - BlurryBlur.MaxFarBlurAmount)*2*DeltaTime;
			//BlurryBlur.MaxNearBlurAmount = 0.00;
			BlurryBlur.BloomScale += (InBloomScale - BlurryBlur.BloomScale)*2*DeltaTime;
			BlurryBlur.FocusInnerRadius += (InFocusInnerRadius - BlurryBlur.FocusInnerRadius)*2*DeltaTime;
			BlurryBlur.FocusDistance += (InFocusDistance - BlurryBlur.FocusDistance)*2*DeltaTime;
			BlurryBlur.SceneDesaturation += (InSceneDesaturation - BlurryBlur.SceneDesaturation)*2*DeltaTime;
			MotionBlurEffect(LocalPlayer(OwnerController.Player).PlayerPostProcessChains[0].Effects[1]).MotionBlurAmount += (0.125000 - MotionBlurEffect(LocalPlayer(OwnerController.Player).PlayerPostProcessChains[0].Effects[1]).MotionBlurAmount)*2*DeltaTime;
		}
		else
		{
			BlurryBlur.MaxFarBlurAmount = InMaxFarBlurAmount;
			//BlurryBlur.MaxNearBlurAmount = 0.00;
			BlurryBlur.BloomScale = InBloomScale;
			BlurryBlur.FocusInnerRadius = InFocusInnerRadius;
			BlurryBlur.FocusDistance = InFocusDistance;
			BlurryBlur.SceneDesaturation = InSceneDesaturation;
			MotionBlurEffect(LocalPlayer(OwnerController.Player).PlayerPostProcessChains[0].Effects[1]).MotionBlurAmount = 0.125000;
			BlurryBlur.bUseWorldSettings = True;
			bScreenBlurred = False;
			//UTPlayerController(PlayerOwner).ClearCameraEffect(); // Remove some ugly effect
		}
	}
}

defaultproperties
{
	RadarScale=0.200000
	RadarPosX=0.900000
	RadarPosY=0.250000
	
	BlurBelowHealthRatio=0.3
	bEnableLowHealthBlur=True;
}