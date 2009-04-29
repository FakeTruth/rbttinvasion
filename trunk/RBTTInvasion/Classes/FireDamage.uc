class FireDamage extends UTDamageType;

defaultproperties
{
	//RewardCount=15
	//RewardEvent=REWARD_JACKHAMMER
	//RewardAnnouncementSwitch=5
	//bAlwaysGibs=true
	GibPerterbation=0.f
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
	
	DeathString = "`o was turned into charcoal by a `k"
	// `o was killed by `k.
	FemaleSuicide = "`o was turned into charcoal by a `k"
	MaleSuicide = "`o was turned into charcoal by a `k"
}
