Holds The Information for installed monsters

# MonsterTable #

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

|**MonsterTable**| The data for each monster is held on its own monstertable line |
|:---------------|:---------------------------------------------------------------|
|**MonsterName**| The name of the monster (mainly for config integration), monsters will show up in the game with this name |
|**MonsterClassName**| The actual name of the pawns Class, you are required to fill this in |
|**MonsterClass**| As Above, you don't need to fill this in as it won't have any effect |

More information about the MonsterTable and how to use it can be found on the [Configuration](Configuration.md) page