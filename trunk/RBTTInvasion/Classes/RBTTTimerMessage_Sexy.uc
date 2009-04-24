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
   Announcements(0)=
   Announcements(1)=
   Announcements(2)=
   Announcements(3)=
   Announcements(4)=
   Announcements(5)=
   Announcements(6)=
   Announcements(7)=
   Announcements(8)=
   Announcements(9)=
   Announcements(10)=
   Announcements(11)=
   Announcements(12)=
   Announcements(13)=
   Announcements(14)=
   Announcements(15)=
   Announcements(16)=
   bIsUnique=True
   Lifetime=1.000000
   DrawColor=(B=64,G=255,R=255,A=255)
   FontSize=3
   Name="Default__RBTTTimerMessage_Sexy"
   ObjectArchetype=UTLocalMessage'UTGame.Default__UTLocalMessage'
}
