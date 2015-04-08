# BeginWave #

Unreal counts the WaveConfig the same way it does the MonsterTable assigning the first line as zero and counting on from there.. this means if you want your mutator to spawn on wave 5 then you need to set the BeginWave variable to 4

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

|**BeginWave**|this is the wave you first want the mutator to appear|
|:------------|:----------------------------------------------------|