# MonsterNum #

```
[RBTTInvasion.RBTTInvasionGameRules]
PortalSpawnInterval=60
MonsterTable=(MonsterName="SkullCrab",MonsterClassName="RBTTInvasion.RBTTSkullCrab",MonsterClass=Class'RBTTInvasion.RBTTSkullCrab')
MonsterTable=(MonsterName="HumanSkeleton",MonsterClassName="RBTTInvasion.RBTTHumanSkeleton",MonsterClass=Class'RBTTInvasion.RBTTHumanSkeleton')
MonsterTable=(MonsterName="KrallSkeleton",MonsterClassName="RBTTInvasion.RBTTKrallSkeleton",MonsterClass=Class'RBTTInvasion.RBTTKrallSkeleton')
MonsterTable=(MonsterName="MiningRobot",MonsterClassName="RBTTInvasion.RBTTMiningRobot",MonsterClass=Class'RBTTInvasion.RBTTMiningRobot')
MonsterTable=(MonsterName="WeldingRobot",MonsterClassName="RBTTInvasion.RBTTWeldingRobot",MonsterClass=Class'RBTTInvasion.RBTTWeldingRobot')
MonsterTable=(MonsterName="Spider",MonsterClassName="RBTTInvasion.RBTTSpider",MonsterClass=Class'RBTTInvasion.RBTTSpider')
MonsterTable=(MonsterName="Slime",MonsterClassName="RBTTInvasion.RBTTSlime",MonsterClass=Class'RBTTInvasion.RBTTSlime')
MonsterTable=(MonsterName="ScarySkull",MonsterClassName="RBTTInvasion.RBTTScarySkull",MonsterClass=Class'RBTTInvasion.RBTTScarySkull')
MonsterTable=(MonsterName="AePhoenix",MonsterClassName="RBTTInvasion.AePhoenix",MonsterClass=Class'RBTTInvasion.AePhoenix')
MonsterTable=(MonsterName="Infernal",MonsterClassName="RBTTInvasion.RBTTInfernal",MonsterClass=Class'RBTTInvasion.RBTTInfernal')
```

<table width='800' border='1'>
<tr><td><b>MonsterNum</b></td><td>this is where you specify which mosters you want to spawn, the numbers represent the postion of the monster in the <b>MonsterTable</b> the first line in the <b>MonsterTable</b> above will spawn all infernals, when invasion is in random spawn mode it picks mosters from the <b>MonsterNum</b> variable like a pool so if you had a line whch had, MonsterNum=(9,9,0,0) you would get a 50/50 split of skullcrab and infernals</td></tr></table>