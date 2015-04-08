MonsterName a variable from the monster table

# MonsterName #
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


|**MonsterName**| The name of the monster (mainly for config integration), monsters will show up in the game with this name |
|:--------------|:----------------------------------------------------------------------------------------------------------|

the monster name set in the monster table is only the name you choose to give the monster when it finally shows up in our configuration menu. the actual name of the monster is set in the monsters pawn class when the monster was scripted we do eventually aim to make this configurable but until then your stuck with our corny names :P