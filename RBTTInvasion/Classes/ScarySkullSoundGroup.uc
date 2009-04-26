/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */
class ScarySkullSoundGroup extends UTPawnSoundGroup;

defaultproperties
{
   DodgeSound=SoundCue'RBTTScarySkull.Sounds.TortureLoop2Cue'
   DoubleJumpSound=SoundCue'RBTTScarySkull.Sounds.TortureLoop2Cue'
   DefaultJumpingSound=SoundCue'RBTTScarySkull.Sounds.TortureLoop2Cue'
   LandSound=SoundCue'RBTTScarySkull.Sounds.TortureLoop2Cue'
   FallingDamageLandSound=SoundCue'RBTTScarySkull.Sounds.TortureLoop1Cue'
   DyingSound=SoundCue'RBTTScarySkull.Sounds.TortureLoop1Cue'
   HitSounds(0)=SoundCue'RBTTScarySkull.Sounds.TortureLoop1Cue'
   HitSounds(1)=SoundCue'RBTTScarySkull.Sounds.TortureLoop1Cue'
   HitSounds(2)=SoundCue'RBTTScarySkull.Sounds.TortureLoop1Cue'
   GibSound=SoundCue'A_Character_IGMale_Cue.Efforts.A_Effort_IGMale_DeathInstant_Cue'
   DrownSound=SoundCue'A_Character_IGMale_Cue.Efforts.A_Effort_IGMale_MaleDrowning_Cue'
   GaspSound=SoundCue'A_Character_IGMale_Cue.Efforts.A_Effort_IGMale_MGasp_Cue'
   FootstepSounds(0)=(MaterialType="Stone",Sound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_StoneCue')
   FootstepSounds(1)=(MaterialType="Dirt",Sound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_DirtCue')
   FootstepSounds(2)=(MaterialType="Energy",Sound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_EnergyCue')
   FootstepSounds(3)=(MaterialType="Flesh_Human",Sound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_FleshCue')
   FootstepSounds(4)=(MaterialType="Foliage",Sound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_FoliageCue')
   FootstepSounds(5)=(MaterialType="Glass",Sound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_GlassPlateCue')
   FootstepSounds(6)=(MaterialType="Water",Sound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_WaterDeepCue')
   FootstepSounds(7)=(MaterialType="ShallowWater",Sound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_WaterShallowCue')
   FootstepSounds(8)=(MaterialType="Metal",Sound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_MetalCue')
   FootstepSounds(9)=(MaterialType="Snow",Sound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_SnowCue')
   FootstepSounds(10)=(MaterialType="Wood",Sound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_WoodCue')
   DefaultFootstepSound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_DefaultCue'
   JumpingSounds(0)=(MaterialType="Stone",Sound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_StoneJumpCue')
   JumpingSounds(1)=(MaterialType="Dirt",Sound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_DirtJumpCue')
   JumpingSounds(2)=(MaterialType="Energy",Sound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_EnergyJumpCue')
   JumpingSounds(3)=(MaterialType="Flesh_Human",Sound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_FleshJumpCue')
   JumpingSounds(4)=(MaterialType="Foliage",Sound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_FoliageJumpCue')
   JumpingSounds(5)=(MaterialType="Glass",Sound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_GlassPlateJumpCue')
   JumpingSounds(6)=(MaterialType="GlassBroken",Sound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_GlassBrokenJumpCue')
   JumpingSounds(7)=(MaterialType="Grass",Sound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_GrassJumpCue')
   JumpingSounds(8)=(MaterialType="Metal",Sound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_MetalJumpCue')
   JumpingSounds(9)=(MaterialType="Mud",Sound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_MudJumpCue')
   JumpingSounds(10)=(MaterialType="Metal",Sound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_MetalJumpCue')
   JumpingSounds(11)=(MaterialType="Snow",Sound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_SnowJumpCue')
   JumpingSounds(12)=(MaterialType="Tile",Sound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_TileJumpCue')
   JumpingSounds(13)=(MaterialType="Water",Sound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_WaterDeepJumpCue')
   JumpingSounds(14)=(MaterialType="ShallowWater",Sound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_WaterShallowJumpCue')
   JumpingSounds(15)=(MaterialType="Wood",Sound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_WoodJumpCue')
   LandingSounds(0)=(MaterialType="Stone",Sound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_StoneLandCue')
   LandingSounds(1)=(MaterialType="Dirt",Sound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_DirtLandCue')
   LandingSounds(2)=(MaterialType="Energy",Sound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_EnergyLandCue')
   LandingSounds(3)=(MaterialType="Flesh_Human",Sound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_FleshLandCue')
   LandingSounds(4)=(MaterialType="Foliage",Sound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_FoliageLandCue')
   LandingSounds(5)=(MaterialType="Glass",Sound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_GlassPlateLandCue')
   LandingSounds(6)=(MaterialType="GlassBroken",Sound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_GlassBrokenLandCue')
   LandingSounds(7)=(MaterialType="Grass",Sound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_GrassLandCue')
   LandingSounds(8)=(MaterialType="Metal",Sound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_MetalLandCue')
   LandingSounds(9)=(MaterialType="Mud",Sound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_MudLandCue')
   LandingSounds(10)=(MaterialType="Metal",Sound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_MetalLandCue')
   LandingSounds(11)=(MaterialType="Snow",Sound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_SnowLandCue')
   LandingSounds(12)=(MaterialType="Tile",Sound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_TileLandCue')
   LandingSounds(13)=(MaterialType="Water",Sound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_WaterDeepLandCue')
   LandingSounds(14)=(MaterialType="ShallowWater",Sound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_WaterShallowLandCue')
   LandingSounds(15)=(MaterialType="Wood",Sound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_WoodLandCue')
   DefaultLandingSound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_DirtLandCue'
   BulletImpactSound=SoundCue'A_Character_BodyImpacts.BodyImpacts.A_Character_BodyImpact_Bullet_Cue'
   CrushedSound=SoundCue'A_Character_BodyImpacts.BodyImpacts.A_Character_BodyImpact_Crush_Cue'
   BodyExplosionSound=SoundCue'A_Character_BodyImpacts.BodyImpacts.A_Character_BodyImpact_Explosion_Cue'
   InstagibSound=SoundCue'A_Character_BodyImpacts.BodyImpacts.A_Character_BodyImpact_InstaGib_Cue'
   Name="Default__ScarySkullSoundGroup"
   ObjectArchetype=Object'Core.Default__Object'
}
