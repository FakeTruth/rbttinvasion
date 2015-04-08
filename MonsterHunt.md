# <font color='red'>ONLY APPLIES TO <a href='https://code.google.com/p/rbttinvasion/source/detail?r=318'>REVISION 318</a> AND LATER</font> #

# How to create a MonsterHunt map #

The first thing you do, is load your RBTTInvasion.u file into the editor.
Open the Generic Browser
File > Open > RBTTInvasion.u

Next you need to place a ThisIsMonsterHunt actor in your map, the Invasion mutator will look for this actor in your map, and when it's found it won't initiate any waves.
So open your Generic Browser again if you closed it, and open the tab Actor Classes. Look for ThisIsMonsterHunt, once you found it place it somewhere in your map, it doesn't matter where as long as it's in your map.

Now you just have to create your map, and once you've reached a point where you want players to encounter monsters:
Place some kind of trigger or triggervolume in your map, and get it into Kismet.
Open up Kismet. Now right click somewhere in the grey viewport New Action > RBTTInvasion > RBTTMonster Factory
You'll see a node with 4 signal inputs, 2 signal outputs, 2 variable inputs and 1 variable output


|Spawn monster |Initiates the spawning of monsters|
|:-------------|:---------------------------------|
|Pause		|Pauses spawning monsters|
|Continue	|Continues from where you paused|
|Abort		|Aborts spawning of monsters|

|Finished 	|Will send a signal for each monster that has been spawned|
|:---------|:--------------------------------------------------------|
|Aborted	|Sends a signal when it's done spawning, or is aborted|

|Spawn Point	|Link actors here to specify the location where you want monsters to spawn|
|:-----------|:------------------------------------------------------------------------|
|Spawn Count	|The total amount of monsters you want spawned|

|Spawned	|Outputs the monster that has just been spawned|
|:-------|:---------------------------------------------|

Here's an example on how to see whether you have killed all the monsters:<br>
<a href='http://images.allprog.nl/img/4024_1246478780.gif'><img src='http://images.allprog.nl/thumb/4024_1246478780.jpg' /></a>

This example spawns a total of 100 RBTTSkullCrab in 12 different locations, while not allowing more than 10 monsters alive at the same time:<br>
<a href='http://images.allprog.nl/img/8395_1246223082.gif'><img src='http://images.allprog.nl/thumb/8395_1246223082.jpg' /></a><br>


This article is not finished yet!