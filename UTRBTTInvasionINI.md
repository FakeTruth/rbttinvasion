# Introduction #

Here's a sample of the UTRBTTInvasion.ini file, to witness one in it's full glory.


# UTRBTTInvasion.ini #

```
[RBTTInvasionMutator UTUIDataProvider_Mutator]
ClassName=RBTTInvasion.RBTTInvasionMutator
FriendlyName=RBTTInvasion Rev 229
Description=UT3 Invasion mutator created by the minds of RoseBums Think Tank
GroupNames=INVASION
UIConfigScene=
bStandaloneOnly=False
BitValue=0
bRemoveOn360=False
bRemoveOnPC=False
bRemoveOnPS3=False

[RBTTInvasion.RBTTInvasionMutator]
;Mutatorconfig=(MutatorClass="JR.JRMutator_Raptor",BeginWave=0,EndWave=8)
MutatorConfig=(MutatorClass="UTGame.UTMutator_LowGrav",bSpawned=False,BeginWave=0,EndWave=1)
MutatorConfig=(MutatorClass="UTGame.UTMutator_LowGrav",bSpawned=False,BeginWave=3,EndWave=4)
MutatorConfig=(MutatorClass="UTGame.UTMutator_LowGrav",bSpawned=False,BeginWave=6,EndWave=7)
MutatorConfig=(MutatorClass="UTGame.UTMutator_LowGrav",bSpawned=False,BeginWave=9,EndWave=10)
MutatorConfig=(MutatorClass="UTGame.UTMutator_Instagib",bSpawned=False,BeginWave=4,EndWave=5)
MutatorConfig=(MutatorClass="UTGame.UTMutator_Instagib",bSpawned=False,BeginWave=8,EndWave=9)
;MutatorConfig=(MutatorClass="UTGame.UTMutator_SpeedFreak",bSpawned=False,BeginWave=2,EndWave=3)
MonsterTable=(MonsterName="SkullCrab",MonsterClassName="RBTTInvasion.RBTTSkullCrab")
MonsterTable=(MonsterName="HumanSkeleton",MonsterClassName="RBTTInvasion.RBTTHumanSkeleton")
MonsterTable=(MonsterName="KrallSkeleton",MonsterClassName="RBTTInvasion.RBTTKrallSkeleton")
MonsterTable=(MonsterName="MiningRobot",MonsterClassName="RBTTInvasion.RBTTMiningRobot")
MonsterTable=(MonsterName="WeldingRobot",MonsterClassName="RBTTInvasion.RBTTWeldingRobot")
MonsterTable=(MonsterName="Spider",MonsterClassName="RBTTInvasion.RBTTSpider")
MonsterTable=(MonsterName="Slime",MonsterClassName="RBTTInvasion.RBTTSlime")
MonsterTable=(MonsterName="ScarySkull",MonsterClassName="RBTTInvasion.RBTTScarySkull")
MonsterTable=(MonsterName="AePhoenix",MonsterClassName="RBTTInvasion.AePhoenix")
MonsterTable=(MonsterName="Infernal",MonsterClassName="RBTTInvasion.RBTTInfernal")
MonsterTable=(MonsterName="ScarySkullGhost",MonsterClassName="RBTTInvasion.RBTTScarySkullGhost")
MonsterTable=(MonsterName="Jurassic Rage - TRex",MonsterClassName="JR.JRRex")
MonsterTable=(MonsterName="Jurassic Rage - Raptor",MonsterClassName="JR.JRRaptor")

[RBTTInvasion.RBTTInvasionGameRules]
bShowDeathMessages=True
PortalSpawnInterval=60


[Default CustomWaveConfig]
WaveConfig=(MonsterNum=(6,6,7,10,7,6,6,7,10,7,6),BossMonsters=(9),WaveLength=10,WaveCountdown=10,MonstersPerPlayer=2.000000,bIgnoreMPP=False,bIsQueue=True,MaxMonsters=16,bAllowPortals=False)
WaveConfig=(MonsterNum=(7,7,7,0,0,0,6,10),WaveLength=15,WaveCountdown=15,MonstersPerPlayer=3.000000,bIgnoreMPP=False,bIsQueue=False,MaxMonsters=16,bAllowPortals=False)
WaveConfig=(MonsterNum=(0,5,2,1),WaveLength=20,WaveCountdown=20,MonstersPerPlayer=3.000000,bIgnoreMPP=False,bIsQueue=False,MaxMonsters=16,bAllowPortals=True)
WaveConfig=(MonsterNum=(12),BossMonsters=(11,11),WaveLength=20,WaveCountdown=20,MonstersPerPlayer=4.000000,bIgnoreMPP=False,bIsQueue=False,MaxMonsters=16,bAllowPortals=True)
WaveConfig=(MonsterNum=(1,2,4),WaveLength=30,WaveCountdown=10,MonstersPerPlayer=3.000000,bIgnoreMPP=False,bIsQueue=False,MaxMonsters=16,bAllowPortals=False)
WaveConfig=(MonsterNum=(6,7,10),WaveLength=40,WaveCountdown=15,MonstersPerPlayer=6.000000,bIgnoreMPP=False,bIsQueue=False,MaxMonsters=16,bAllowPortals=True)
WaveConfig=(MonsterNum=(0,7,10),WaveLength=50,WaveCountdown=10,MonstersPerPlayer=4.000000,bIgnoreMPP=False,bIsQueue=False,MaxMonsters=16,bAllowPortals=True)
WaveConfig=(MonsterNum=(5),WaveLength=60,WaveCountdown=10,MonstersPerPlayer=4.000000,bIgnoreMPP=False,bIsQueue=False,MaxMonsters=16,bAllowPortals=True)
WaveConfig=(MonsterNum=(0,1,2,3,4,5,6,7,8,10),BossMonsters=(9,9,9,9),WaveLength=70,WaveCountdown=60,MonstersPerPlayer=20.000000,bIgnoreMPP=False,bIsQueue=False,MaxMonsters=16,bAllowPortals=True)
WaveConfig=(MonsterNum=(0,1,2,3,4,5,6,7,8,10),WaveLength=80,WaveCountdown=10,MonstersPerPlayer=3.000000,bIgnoreMPP=False,bIsQueue=False,MaxMonsters=16,bAllowPortals=True)
WaveConfig=(MonsterNum=(1,2,4),WaveLength=90,WaveCountdown=10,MonstersPerPlayer=3.000000,bIgnoreMPP=False,bIsQueue=False,MaxMonsters=16,bAllowPortals=True)
WaveConfig=(MonsterNum=(5),BossMonsters=(2,2,2,2,2,2,2),WaveLength=100,WaveCountdown=20,MonstersPerPlayer=50.000000,bIgnoreMPP=False,bIsQueue=False,MaxMonsters=50,bAllowPortals=False)
WaveConfig=(MonsterNum=(0,1,2,3,4,5,6,7,8,10),BossMonsters=(9,9,9,9,9,9,9,9),WaveLength=120,WaveCountdown=60,MonstersPerPlayer=20.000000,bIgnoreMPP=False,bIsQueue=False,MaxMonsters=50,bAllowPortals=True)
WaveConfig=(MonsterNum=(0,1,2,3,4,5,6,7,8,9,10),BossMonsters=(9,2,9,2,9,2,9,2,9,2,9,2),WaveLength=150,WaveCountdown=30,MonstersPerPlayer=20.000000,bIgnoreMPP=False,bIsQueue=False,MaxMonsters=16,bAllowPortals=True)

[DM-fktrth-Box CustomWaveConfig]
WaveConfig=(MonsterNum=(6,6,7,10,7,6,6,7,10,7,6),WaveLength=10,WaveCountdown=10,MonstersPerPlayer=2.000000,bIgnoreMPP=False,bIsQueue=True,MaxMonsters=16,bAllowPortals=False)
WaveConfig=(MonsterNum=(7,7,7,0,0,0,6,10),BossMonsters=(6,6,6,6,6),WaveLength=15,WaveCountdown=15,MonstersPerPlayer=3.000000,bIgnoreMPP=False,bIsQueue=False,MaxMonsters=16,bAllowPortals=False)
WaveConfig=(MonsterNum=(0,5,2,1),WaveLength=20,WaveCountdown=20,MonstersPerPlayer=3.000000,bIgnoreMPP=False,bIsQueue=False,MaxMonsters=16,bAllowPortals=True)
WaveConfig=(MonsterNum=(12),BossMonsters=(11,11),WaveLength=20,WaveCountdown=20,MonstersPerPlayer=4.000000,bIgnoreMPP=False,bIsQueue=False,MaxMonsters=16,bAllowPortals=True)
WaveConfig=(MonsterNum=(1,2,4),WaveLength=30,WaveCountdown=10,MonstersPerPlayer=3.000000,bIgnoreMPP=False,bIsQueue=False,MaxMonsters=16,bAllowPortals=False)
WaveConfig=(MonsterNum=(6,7,10),WaveLength=40,WaveCountdown=15,MonstersPerPlayer=6.000000,bIgnoreMPP=False,bIsQueue=False,MaxMonsters=20,bAllowPortals=True)
WaveConfig=(MonsterNum=(0,7,10),WaveLength=50,WaveCountdown=10,MonstersPerPlayer=4.000000,bIgnoreMPP=False,bIsQueue=False,MaxMonsters=20,bAllowPortals=True)
WaveConfig=(MonsterNum=(5),WaveLength=60,WaveCountdown=10,MonstersPerPlayer=4.000000,bIgnoreMPP=False,bIsQueue=False,MaxMonsters=20,bAllowPortals=True)
WaveConfig=(MonsterNum=(0,1,2,3,4,5,6,7,8,10),BossMonsters=(9,6,9,6),WaveLength=70,WaveCountdown=60,MonstersPerPlayer=20.000000,bIgnoreMPP=False,bIsQueue=False,MaxMonsters=20,bAllowPortals=True)
WaveConfig=(MonsterNum=(0,1,2,3,4,5,6,7,8,10),BossMonsters=(7,7,7,7,7,7,7,7,7),WaveLength=80,WaveCountdown=10,MonstersPerPlayer=3.000000,bIgnoreMPP=False,bIsQueue=False,MaxMonsters=20,bAllowPortals=True)
WaveConfig=(MonsterNum=(1,2,4),BossMonsters=(3,3,3,3,3,3),WaveLength=90,WaveCountdown=10,MonstersPerPlayer=3.000000,bIgnoreMPP=False,bIsQueue=False,MaxMonsters=25,bAllowPortals=True)
WaveConfig=(MonsterNum=(5),BossMonsters=(2,2,2,2,2,2,2),WaveLength=100,WaveCountdown=20,MonstersPerPlayer=50.000000,bIgnoreMPP=False,bIsQueue=False,MaxMonsters=25,bAllowPortals=False)
WaveConfig=(MonsterNum=(0,1,2,3,4,5,6,7,8,10),BossMonsters=(9,9,9),WaveLength=120,WaveCountdown=60,MonstersPerPlayer=20.000000,bIgnoreMPP=False,bIsQueue=False,MaxMonsters=25,bAllowPortals=True)
WaveConfig=(MonsterNum=(0,1,2,3,4,5,6,7,8,10),BossMonsters=(9,2,9,2,9,2,9),WaveLength=150,WaveCountdown=30,MonstersPerPlayer=20.000000,bIgnoreMPP=False,bIsQueue=False,MaxMonsters=30,bAllowPortals=True)

[RBTTInvasion.RBTTInfernal]
PlasmaDamage=100.000000
PoundDamage=100.000000
MonsterHealth=2000.000000
bCanMantle=False
bCanSwatTurn=False

[UTGame.UTPawn]
bWeaponBob=True
Bob=0.010000

[Engine.Pawn]
bDisplayPathErrors=False
```