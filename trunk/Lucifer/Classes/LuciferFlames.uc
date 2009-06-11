//=============================================================================
// flame effect for luciferboss
//=============================================================================
class LuciferFlames extends xEmitter;

function PreBeginPlay()
{
	Super.PreBeginPlay();
	RemoteRole=ROLE_SimulatedProxy;
}

defaultproperties
{
     mSpawningType=ST_ExplodeRing
     mRegenOnTime(0)=-20.000000
     mRegenOnTime(1)=-10.000000
     mStartParticles=0
     mMaxParticles=20
     mLifeRange(0)=2.500000
     mLifeRange(1)=2.000000
     mRegenRange(0)=300.000000
     mRegenRange(1)=300.000000
     mRegenDist=-200.000000
     mDirDev=(X=1.000000,Y=1.000000)
     mPosDev=(X=8.000000,Y=8.000000)
     mSpeedRange(1)=60.000000
     mMassRange(0)=-0.200000
     mMassRange(1)=-0.500000
     mSpinRange(0)=10.000000
     mSpinRange(1)=20.000000
     mSizeRange(0)=175.000000
     mSizeRange(1)=200.000000
     mGrowthRate=0.500000
     mColorRange(0)=(B=48,G=112,R=61)
     mColorRange(1)=(B=79,G=43,R=79)
     mAttenKa=0.300000
     mNumTileColumns=4
     mNumTileRows=4
     RemoteRole=ROLE_SimulatedProxy
     AmbientSound=Sound'GeneralAmbience.firefx11'
     LifeSpan=1.500000
     Skins(0)=Texture'EmitterTextures.MultiFrame.LargeFlames'
     Style=STY_Additive
     SoundVolume=190
     SoundRadius=32.000000
}
