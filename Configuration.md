# Table of Contents #


# Introduction #

This page is a brief decription of the [UTRBTTInvasion.ini](UTRBTTInvasionINI.md) file and how to configure it to your pleasing
To the veteran players of ut2004 invasion the config of UT3 Invasion should be pretty straight forward to new players Welcome!

# Adding New Monsters #

To add your own custom monsters first install your new packages, read the ReadMe file that comes with those packages on how to install them

[UTRBTTInvasion.ini](UTRBTTInvasionINI.md) file
```
[RBTTInvasion.RBTTInvasionMutator]
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

Now in the RBTTInvasion.RBTTInvasionMutator section just add your own MonsterTable line, the variables are explained in the table below

|**MonsterTable**| The data for each monster is held on its own monstertable line |
|:---------------|:---------------------------------------------------------------|
|**MonsterName**| The name of the monster (mainly for config integration), monsters will show up in the game with this name |
|**MonsterClassName**| The actual name of the pawns Class, you are required to fill this in |
|**MonsterClass**| As Above, you don't need to fill this in as it won't have any effect |

any pawn can be added to UT3Invasion but if it's not using our AI the the pawn should spawn its own otherwise it'll just stand there.. failure to correctly specify the monsters or missing packages will hang your waves

# Configuring The Waves #

The fist thing to understand is that ureal takes each of the monster table lines and assigns it a number starting at zero, this means in the table above the skullcrab is 0 and the infernal is 9

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
|**WaveConfig**|This variable holds the configuration details for this specific wave an extra WaveConfig line means an extra wave, you have as much waves as you have WaveConfig lines|
|**MonsterNum**|This is where you specify which mosters you want to spawn, the numbers represent the postion of the monster in the MonsterTable the first line in the MonsterTable above will spawn [Slimes](Slime.md) and [ScarySkulls](ScarySkull.md), when invasion is in random spawn mode it picks monsters from the MonsterNum variable like a pool so if you had a line which had, MonsterNum=(9,9,0,0) you would get a 50/50 split of [SkullCrabs](SkullCrab.md) and [Infernals](Infernal.md)|
|**BossMonsters**|This works like the MonsterNum (a pool of monsters) the differenc is they all spawn at once at the end of a wave|
|**WaveLength**|The total amount of time monsters that will be spawned in a wave (the wave will not end till the last monster dies)|
|**WaveCountDown**|How much time the players have between each wave to collect ammo etc. a timer will be displayed during this time |
|**MonstersPerPlayer** |The ratio of monsters vs players|
|**bIgnoreMPP**|Like it says settig this to TRUE will let invasion just keep spawning monsters until MaxMonsters is reached, ignoring the MonstersPerPlayer ratio |
|**bIsQueue** |This is a little piece of invasion magic, by setting this to true the MonsterNum Variable is no longer a pool of monsters that invasion randomly spawns from but an ordered list! this means you can specify in exaclty what order you want your monsters spawn in|
|**MaxMonsters** |This is the maxium number of monsters allowed in the map at one time. Only the Invasion Mutator minds this variable, if something else would be spawning monsters they don't necessarily have to abide this. So you CAN have more monsters in your game then this variable would allow |
|**bAllowPortals** |Setting this variable to true allows portals to be spawned on this wave |

# Configuring the Portals #

this is done in both the MonsterTable and the WaveConfig Sections, Setting the time between each portal spawning is done in the RBTTInvasion.RBTTInvasionGameRules section, try to keep this number resonable as you might find the portals spawn faster than you can find and kill them!

```
[RBTTInvasion.RBTTInvasionGameRules]
PortalSpawnInterval=60
```
Default value: `PortalSpawnInterval=60`

Setting which wave you want your portals to spawn on is done in the CustomWaveConfig section

```
[Default CustomWaveConfig]
WaveConfig=(MonsterNum=(0,5,2,1),WaveLength=20,WaveCountdown=20,MonstersPerPlayer=3.000000,bIgnoreMPP=False,bIsQueue=False,MaxMonsters=16,bAllowPortals=True)
```

You set the bAllowPortals To true and portals will spawn in this wave Simple :)

# Monster Death Messages #

This variable turns on/off the death messages for killed monsters, this also enables/disables multi-kill announces.

```
[RBTTInvasion.RBTTInvasionGameRules]
bShowDeathMessages=True
```
Default Value: `bShowDeathMessages=True`


# Adding Per-Wave Mutators #

These are RBTTInvasion Specific Mutators that are designed to be added or removed during invasion waves. More mutators will be added in time.
To add and remove mutators multiple times during a match simply add another copy of the MutatorConfig line with different BeginWave and EndWave variables see the UTMutator\_LowGrav and UTMutator\_Instagib in the table below for an example.

```
[RBTTInvasion.RBTTInvasionMutator]
MutatorConfig=(MutatorClass="UTGame.UTMutator_FriendlyFire",bSpawned=False,BeginWave=1,EndWave=2)
MutatorConfig=(MutatorClass="UTGame.UTMutator_LowGrav",BeginWave=1,EndWave=2)
MutatorConfig=(MutatorClass="UTGame.UTMutator_Slomo",BeginWave=2,EndWave=3)
MutatorConfig=(MutatorClass="UTGame.UTMutator_LowGrav",BeginWave=7,EndWave=8)
MutatorConfig=(MutatorClass="UTGame.UTMutator_Instagib",BeginWave=4,EndWave=5)
MutatorConfig=(MutatorClass="UTGame.UTMutator_Instagib",BeginWave=11,EndWave=12)
MutatorConfig=(MutatorClass="UTGame.UTMutator_SpeedFreak",bSpawned=False,BeginWave=2,EndWave=3)
```

|**MutatorConfig**|this is the line that holds the data for each session of the mutator|
|:----------------|:-------------------------------------------------------------------|
|**MutatorClass**|the Actual class name of the the mutator|
|**BeginWave**|this is the wave you first want the mutator to appear|
|**EndWave**|this is the wave you want the mutator to be removed|

Unreal counts the WaveConfig the same way it does the MonsterTable assigning the first line as zero and counting on from there.. this means if you want your mutator to spawn on wave 5 then you need to set the BeginWave variable to 4. You should also know that the mutator will be removed at the <u>BEGINNING</u> of the EndWave, so if you set the BeginWave to 1, and the EndWave to 2, the mutator will be on for <u>ONE</u> wave

RBTTInvasion Currently has 5 Per-Wave mutators which will increase with time here's a brief decription of each

|**UTMutator\_FriendlyFire**|A nasty little mutator that lets team mates hurt each other|
|:--------------------------|:----------------------------------------------------------|
|**UTMutator\_LowGrav**|Makes everything floaty like!|
|**UTMutator\_Slomo**|Slows the game speed slightly making everything a little slower|
|**UTMutator\_SpeedFreak**|Need that little boost then this mtators for you!|
|**UTMutator\_Instagib**|Wanna spice things up then give everyone an Instagib Rifle!|




&lt;hr&gt;



# Finally #

We hope this helps you understand the configuration of RBTTInvasion and look forward to playing alot of varied servers out there :)