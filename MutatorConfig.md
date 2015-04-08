# MutatorConfig #

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

These are RBTTInvasion Specific Mutators that are designed to be added a removed during invasion waves more mutators will be added in time, To add and remove mutators multiple times during a match simply add another copy of the MutatorConfig line with different BeginWave and EndWave variables see the UTMutator\_LowGrav and UTMutator\_Instagib in the table above for and example

|**MutatorConfig**|this is the line that holds the data for each session of the mutator|
|:----------------|:-------------------------------------------------------------------|
|**MutatorClass**|the Actual class name of the the mutator|
|**BeginWave**|this is the wave you first want the mutator to appear|
|**EndWave**|this is the wave you want the mutator to be removed|