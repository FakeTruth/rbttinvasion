# Introduction #

This is the monster that looks like the Mining Robot mainly seen spawning from monster portals, dont let too many of these spawn as they can become very deadly in large numbers

<a href='http://rbttinvasion.googlecode.com/svn/trunk/Screenshots/RBTTMiningRobot.jpg'>
<img src='http://rbttinvasion.googlecode.com/svn/trunk/Screenshots/RBTTMiningRobot.jpg' width='400></a'>

<h1>Class Tree</h1>

Core.Object<br>
|<br>
+-- Engine.Actor<br>
<blockquote>|<br>
+-- Engine.Pawn<br>
<blockquote>|<br>
+-- GameFramework.GamePawn<br>
<blockquote>|<br>
+-- UTGame.UTPawn<br>
<blockquote>|<br>
+-- RBTTMonsters.RBTTMonster<br>
<blockquote>|<br>
+-- RBTTMonsters.RBTTMiningRobot</blockquote></blockquote></blockquote></blockquote></blockquote>

<h1>Bone Names</h1>

<pre><code>  0: b_Root<br>
  1:  b_RootOffset (ParentBoneID: 0)<br>
  2:   b_RootAnimated (ParentBoneID: 1)<br>
  3:    b_SawArm (ParentBoneID: 2)<br>
  4:     b_SawBlade (ParentBoneID: 3)<br>
  5:     b_SawShield (ParentBoneID: 3)<br>
  6:    b_LightArm (ParentBoneID: 2)<br>
  7:     b_Light (ParentBoneID: 6)<br>
</code></pre>