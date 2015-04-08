# EndWave #

Unreal counts the WaveConfig the same way it does the MonsterTable assigning the first line as zero and counting on from there.. this means if you want your mutator to End on wave 6 then you need to set the EndWave variable to 5

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

|**EndWave**|this is the wave you want the mutator to be removed|
|:----------|:--------------------------------------------------|