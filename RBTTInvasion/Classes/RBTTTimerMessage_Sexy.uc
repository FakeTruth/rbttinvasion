/** this plays the "X minutes/seconds remaining" announcements */
class RBTTTimerMessage_Sexy extends UTLocalMessage
	abstract;

var array<ObjectiveAnnouncementInfo> Announcements;

static simulated function ClientReceive( PlayerController P, optional int Switch, optional PlayerReplicationInfo RelatedPRI_1,
					optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject )
{
	local AudioComponent CurrentAnnouncementComponent;
	local UTHUD HUD;
	
	Super.ClientReceive(P, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject);

	if (Switch < default.Announcements.length && default.Announcements[Switch].AnnouncementSound != None )
	{
		HUD = UTHUD(P.myHUD);
		if ( (HUD != None) && HUD.bIsSplitScreen && !HUD.bIsFirstPlayer )
		{
			return;
		}
		
		if(Switch < 11)
		{
			// Play it, play it NAO!!!
			CurrentAnnouncementComponent = P.CreateAudioComponent(SoundCue'A_Announcer_Reward_Cue.SoundCues.AnnouncerCue', True, false);

			// CurrentAnnouncementComponent will be none if -nosound option used
			if ( CurrentAnnouncementComponent != None )
			{
				CurrentAnnouncementComponent.SetWaveParameter('Announcement', default.Announcements[Switch].AnnouncementSound);
				//AnnouncerSoundCue.Duration = default.Announcements[Switch].AnnouncementSound.Duration;
				CurrentAnnouncementComponent.bAutoDestroy = true;
				CurrentAnnouncementComponent.bShouldRemainActiveIfDropped = true;
				CurrentAnnouncementComponent.bAllowSpatialization = false;
				CurrentAnnouncementComponent.bAlwaysPlay = TRUE;
				CurrentAnnouncementComponent.Play();
			}
		}
	}
}

static function string GetString( optional int Switch, optional bool bPRI1HUD, optional PlayerReplicationInfo RelatedPRI_1,
					optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject )
{
	if(Switch < default.Announcements.length && default.Announcements[Switch].AnnouncementText != "")
		return default.Announcements[Switch].AnnouncementText;
		
	return String(Switch)$"...";
}

static function SoundNodeWave AnnouncementSound(int MessageIndex, Object OptionalObject, PlayerController PC)
{
	return default.Announcements[MessageIndex].AnnouncementSound;
}

static function int GetFontSize( int Switch, PlayerReplicationInfo RelatedPRI1, PlayerReplicationInfo RelatedPRI2, PlayerReplicationInfo LocalPlayer )
{
	if ( Switch == 17 )
	{
		return 4;
	}
	if ( Switch > 10 )
	{
		return default.FontSize;
	}
	return 2;
}

defaultproperties
{
	FontSize=3
	Lifetime=1
	//MessageArea=2
	bIsConsoleMessage=False
	bIsUnique=true
	//bBeep=false
	DrawColor=(R=255,G=255,B=64,A=255)

	Announcements[1]=(AnnouncementSound=SoundNodeWave'InvasionSounds.SEXY.one') //,AnnouncementText="Yo mama...")
	Announcements[2]=(AnnouncementSound=SoundNodeWave'InvasionSounds.SEXY.two')
	Announcements[3]=(AnnouncementSound=SoundNodeWave'InvasionSounds.SEXY.three')
	Announcements[4]=(AnnouncementSound=SoundNodeWave'InvasionSounds.SEXY.four')
	Announcements[5]=(AnnouncementSound=SoundNodeWave'InvasionSounds.SEXY.five')
	Announcements[6]=(AnnouncementSound=SoundNodeWave'InvasionSounds.SEXY.six')
	Announcements[7]=(AnnouncementSound=SoundNodeWave'InvasionSounds.SEXY.seven')
	Announcements[8]=(AnnouncementSound=SoundNodeWave'InvasionSounds.SEXY.eight')
	Announcements[9]=(AnnouncementSound=SoundNodeWave'InvasionSounds.SEXY.nine')
	Announcements[10]=(AnnouncementSound=SoundNodeWave'InvasionSounds.SEXY.ten')
	Announcements[12]=(AnnouncementSound=SoundNodeWave'InvasionSounds.SEXY.30_seconds_remain')
	Announcements[13]=(AnnouncementSound=SoundNodeWave'InvasionSounds.SEXY.1_minute_remains')
	Announcements[14]=(AnnouncementSound=SoundNodeWave'InvasionSounds.SEXY.2_minutes_remain')
	Announcements[15]=(AnnouncementSound=SoundNodeWave'InvasionSounds.SEXY.3_minutes_remain')
	Announcements[16]=(AnnouncementSound=SoundNodeWave'InvasionSounds.SEXY.5_minute_warning')
	//Announcements[17]=(AnnouncementSound=SoundNodeWave'InvasionSounds.SEXY.A_SEXYAnnouncer_overtime')
}
