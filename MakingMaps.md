# <font color='red'>ONLY APPLIES TO <a href='https://code.google.com/p/rbttinvasion/source/detail?r=318'>REVISION 318</a> AND LATER</font> #

# Define where monsters spawn #

From [revision 318](https://code.google.com/p/rbttinvasion/source/detail?r=318) and later, mapmakers can specify where monsters should spawn in their map by adding a couple of lines to their map's INI file.

Add these two lines to `<MapName>`.ini:
```
[<MapName> UTUIDataProvider_InvasionMapInfo]
MonsterSpawnPoints=<SpawnPoint>
```

In there, replace `<MapName>` with the name of the map, and `<SpawnPoint>` with one of the keywords listed here:

| **MonsterSpawnPoints** | **Description** |
|:-----------------------|:----------------|
|PathNode **default**|Monsters only spawn on pathnodes, those are the little apple icons you place in your map|
|NavigationPoint|Monsters spawn on all NavigationPoints, these go from WeaponFactories to PathNodes|
|PlayerStart|Monsters only spawn on PlayerStarts, where players also spawn|
|RedPlayerStart|Isolate monsters from players by spawning them in specific locations|
|BluePlayerStart|Same as above but for the blue team|

If you don't add this to your ini file, monsters will by default spawn on pathnodes

Here is an example ini file for [DM-fktrth-TrainingGround] where monsters will spawn on pathnodes:
`DM-fktrth-TrainingGround.ini`
```
[DM-fktrth-TrainingGround UTUIDataProvider_MapInfo]
MapName=DM-fktrth-TrainingGround
FriendlyName=fktrth-TrainingGround
PreviewImageMarkup=<Images:UI_FrontEnd_Art.GameTypes.DeathMatch>
Description=None

[DM-fktrth-TrainingGround UTUIDataProvider_InvasionMapInfo]
MonsterSpawnPoints=Pathnode
```