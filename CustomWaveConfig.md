# [CustomWaveConfig](CustomWaveConfig.md) #

```
[Default CustomWaveConfig]
WaveConfig=(MonsterNum=(6,6,7,7,6,6,7,7,6),BossMonsters=(9),WaveLength=10,WaveCountdown=10,MonstersPerPlayer=2.000000,bIgnoreMPP=False,bIsQueue=True,MaxMonsters=16,bAllowPortals=False)
WaveConfig=(MonsterNum=(7,7,7,0,0,0,6),WaveLength=15,WaveCountdown=15,MonstersPerPlayer=3.000000,bIgnoreMPP=False,bIsQueue=False,MaxMonsters=16,bAllowPortals=False)
WaveConfig=(MonsterNum=(0,5,2,1),WaveLength=20,WaveCountdown=20,MonstersPerPlayer=3.000000,bIgnoreMPP=False,bIsQueue=False,MaxMonsters=16,bAllowPortals=True)
WaveConfig=(MonsterNum=(1,2,4),WaveLength=30,WaveCountdown=10,MonstersPerPlayer=3.000000,bIgnoreMPP=False,bIsQueue=False,MaxMonsters=16,bAllowPortals=False)
WaveConfig=(MonsterNum=(6,7),WaveLength=40,WaveCountdown=15,MonstersPerPlayer=6.000000,bIgnoreMPP=False,bIsQueue=False,MaxMonsters=16,bAllowPortals=True)
WaveConfig=(MonsterNum=(0,7),WaveLength=50,WaveCountdown=10,MonstersPerPlayer=4.000000,bIgnoreMPP=False,bIsQueue=False,MaxMonsters=16,bAllowPortals=True)
WaveConfig=(MonsterNum=(5),WaveLength=60,WaveCountdown=10,MonstersPerPlayer=4.000000,bIgnoreMPP=False,bIsQueue=False,MaxMonsters=16,bAllowPortals=True)
WaveConfig=(MonsterNum=(0,1,2,3,4,5,6,7,8),BossMonsters=(9,9,9,9),WaveLength=70,WaveCountdown=60,MonstersPerPlayer=20.000000,bIgnoreMPP=False,bIsQueue=False,MaxMonsters=16,bAllowPortals=True)
WaveConfig=(MonsterNum=(0,1,2,3,4,5,6,7,8),WaveLength=80,WaveCountdown=10,MonstersPerPlayer=3.000000,bIgnoreMPP=False,bIsQueue=False,MaxMonsters=16,bAllowPortals=True)
WaveConfig=(MonsterNum=(1,2,4),WaveLength=90,WaveCountdown=10,MonstersPerPlayer=3.000000,bIgnoreMPP=False,bIsQueue=False,MaxMonsters=16,bAllowPortals=True)
WaveConfig=(MonsterNum=(5),BossMonsters=(2,2,2,2,2,2,2),WaveLength=100,WaveCountdown=20,MonstersPerPlayer=50.000000,bIgnoreMPP=False,bIsQueue=False,MaxMonsters=50,bAllowPortals=False)
WaveConfig=(MonsterNum=(0,1,2,3,4,5,6,7,8),BossMonsters=(9,9,9,9,9,9,9,9),WaveLength=120,WaveCountdown=60,MonstersPerPlayer=20.000000,bIgnoreMPP=False,bIsQueue=False,MaxMonsters=50,bAllowPortals=True)
WaveConfig=(MonsterNum=(0,1,2,3,4,5,6,7,8,9),BossMonsters=(9,2,9,2,9,2,9,2,9,2,9,2),WaveLength=150,WaveCountdown=30,MonstersPerPlayer=20.000000,bIgnoreMPP=False,bIsQueue=False,MaxMonsters=16,bAllowPortals=True)
```

|**`[Default CustomWaveConfig]`**| This is the default wave configuration, this will apply to all maps. Creating another CustomWaveConfig, but with DM-HeatRay instead of Default, causes this wave configuration only to work on DM-HeatRay. This way you can have map specific wave configurations.|
|:-------------------------------|:------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|

example

```
[DM-HeatRay CustomWaveConfig]
WaveConfig=(MonsterNum=(6,6,7,7,6,6,7,7,6),BossMonsters=(9),WaveLength=10,WaveCountdown=10,MonstersPerPlayer=2.000000,bIgnoreMPP=False,bIsQueue=True,MaxMonsters=16,bAllowPortals=False)
WaveConfig=(MonsterNum=(7,7,7,0,0,0,6),WaveLength=15,WaveCountdown=15,MonstersPerPlayer=3.000000,bIgnoreMPP=False,bIsQueue=False,MaxMonsters=16,bAllowPortals=False)
WaveConfig=(MonsterNum=(0,5,2,1),WaveLength=20,WaveCountdown=20,MonstersPerPlayer=3.000000,bIgnoreMPP=False,bIsQueue=False,MaxMonsters=16,bAllowPortals=True)
WaveConfig=(MonsterNum=(1,2,4),WaveLength=30,WaveCountdown=10,MonstersPerPlayer=3.000000,bIgnoreMPP=False,bIsQueue=False,MaxMonsters=16,bAllowPortals=False)
WaveConfig=(MonsterNum=(6,7),WaveLength=40,WaveCountdown=15,MonstersPerPlayer=6.000000,bIgnoreMPP=False,bIsQueue=False,MaxMonsters=16,bAllowPortals=True)
WaveConfig=(MonsterNum=(0,7),WaveLength=50,WaveCountdown=10,MonstersPerPlayer=4.000000,bIgnoreMPP=False,bIsQueue=False,MaxMonsters=16,bAllowPortals=True)
WaveConfig=(MonsterNum=(5),WaveLength=60,WaveCountdown=10,MonstersPerPlayer=4.000000,bIgnoreMPP=False,bIsQueue=False,MaxMonsters=16,bAllowPortals=True)
WaveConfig=(MonsterNum=(0,1,2,3,4,5,6,7,8),BossMonsters=(9,9,9,9),WaveLength=70,WaveCountdown=60,MonstersPerPlayer=20.000000,bIgnoreMPP=False,bIsQueue=False,MaxMonsters=16,bAllowPortals=True)
WaveConfig=(MonsterNum=(0,1,2,3,4,5,6,7,8),WaveLength=80,WaveCountdown=10,MonstersPerPlayer=3.000000,bIgnoreMPP=False,bIsQueue=False,MaxMonsters=16,bAllowPortals=True)
WaveConfig=(MonsterNum=(1,2,4),WaveLength=90,WaveCountdown=10,MonstersPerPlayer=3.000000,bIgnoreMPP=False,bIsQueue=False,MaxMonsters=16,bAllowPortals=True)
WaveConfig=(MonsterNum=(5),BossMonsters=(2,2,2,2,2,2,2),WaveLength=100,WaveCountdown=20,MonstersPerPlayer=50.000000,bIgnoreMPP=False,bIsQueue=False,MaxMonsters=50,bAllowPortals=False)
WaveConfig=(MonsterNum=(0,1,2,3,4,5,6,7,8),BossMonsters=(9,9,9,9,9,9,9,9),WaveLength=120,WaveCountdown=60,MonstersPerPlayer=20.000000,bIgnoreMPP=False,bIsQueue=False,MaxMonsters=50,bAllowPortals=True)
WaveConfig=(MonsterNum=(0,1,2,3,4,5,6,7,8,9),BossMonsters=(9,2,9,2,9,2,9,2,9,2,9,2),WaveLength=150,WaveCountdown=30,MonstersPerPlayer=20.000000,bIgnoreMPP=False,bIsQueue=False,MaxMonsters=16,bAllowPortals=True)
```