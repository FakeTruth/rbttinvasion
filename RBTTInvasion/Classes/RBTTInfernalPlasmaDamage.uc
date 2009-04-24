class RBTTInfernalPlasmaDamage extends UTDamageType;

defaultproperties
{
	//RewardCount=15
	//RewardEvent=REWARD_JACKHAMMER
	//RewardAnnouncementSwitch=5
	bAlwaysGibs=true
	GibPerterbation=+0.5
	//KillStatsName=KILLS_IMPACTHAMMER
	//DeathStatsName=DEATHS_IMPACTHAMMER
	//SuicideStatsName=SUICIDES_IMPACTHAMMER
	DamageWeaponClass=class'RBTTInvasion.DummyWeapon'
	DamageWeaponFireMode=1.0
	VehicleDamageScaling=1.0
	VehicleMomentumScaling=+1.0
	KDamageImpulse=10000
	//CustomTauntIndex=5

	//DamageCameraAnim=CameraAnim'Camera_FX.ImpactHammer.C_WP_ImpactHammer_Primary_Fire_GetHit_Shake'
	//DeathCameraEffectInstigator=class'UTEmitCameraEffect_BloodSplatter'
	
	DeathString = "`o ate some of an `k's plasma"
	// `o was killed by `k.
	FemaleSuicide = "`o ate some of an `k's plasma"
	MaleSuicide = "`o ate some of an `k's plasma"
}
