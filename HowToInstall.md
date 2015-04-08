# Download the RBTT UT3 Invasion Mutator #

Download the RBTT UT3 Invasion Mutator from the [Downloads Wiki Page](Downloads.md) or from the [Downloads Tab](http://code.google.com/p/rbttinvasion/downloads/list)

If you really want to stay up to date with the latest updates on UT3 Invasion, you can download the sourcecode and compile it yourself by following this tutorial:
[SettingUpSVN](SettingUpSVN.md)


---

<br><br>
<h1>Installing UT3 Invasion for Offline use</h1>

Extract the contents of the package, overwriting existing files, into <br>
<table><thead><th> <b>Windows VISTA</b></th><th><code>C:\Users\[UserName]\Documents\My Games\Unreal Tournament 3\</code></th></thead><tbody>
<tr><td> <b>Windows XP</b></td><td><code>C:\Documents and Settings\[UserName]\My Documents\My Games\Unreal Tournament 3\</code></td></tr></tbody></table>

Now follow these steps:<br>
<ol><li>Start Unreal Tournament 3<br>
</li><li>Click on <b>Instant Action</b>
</li><li>Select <b>Team Deathmatch</b> for the GameType<br>
</li><li>Select the map you like to play Invasion on, and click Next<br>
</li><li>On the bottom of the screen, click on Mutators<br>
</li><li>Find the <b>RBTT Invasion</b> mutator in the left list, and put it in the right list by double clicking it<br>
</li><li>Now you're ready to <b>Start</b> the <b>Game</b></li></ol>

If you want to configure your own waves, you should read the <a href='Configuration.md'>Configuration</a> page<br>
<br>
<h1>Installing UT3 Invasion on a Server</h1>

Put the .u and .upk files in:<br>
<code>C:\Unreal Tournament 3 (Dedicated)\UTGame\CookedPC\RBTTInvasion</code><br>

Put the config file <code>UTRBTTInvasion.ini</code> in:<br>
<code>C:\Unreal Tournament 3 (Dedicated)\UTGame\Config\</code><br>

When starting the server use <code>?Mutator=RBTTInvasion.RBTTInvasionMutator</code> to your commandline, or add it to your existing Mutator list in the commandline.<br>
<br>
Some valid commandlines to start a server with UT3 Invasion would be:<br>
<code>ut3.com server DM-HeatRay?Mutator=RBTTInvasion.RBTTInvasionMutator</code><br>
<code>ut3.com server DM-ShangriLa?NumPlayers=6?Mutator=RBTTInvasion.RBTTInvasionMutator,UTGame.UTMutator_Hero</code><br>
<code>ut3.com server DM-ShangriLa?NumPlayers=6?Mutator=RBTTInvasion.RBTTInvasionMutator,BattleRPG.BattleRPG</code><br>

<h1>Making your own Wave Configuration</h1>

Read the <a href='Configuration.md'>Configuration</a> page to find out how to set up your own wave