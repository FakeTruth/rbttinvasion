# Table of Contents #


# Introduction #

This Tutorial assumes you have UT3 and it's fully updated and at least a basic knowledge of UT3

first off your gonna need a svn client to download the source from our repository. you can get tortoise svn free from

http://kent.dl.sourceforge.net/sourceforge/tortoisesvn/TortoiseSVN-1.6.1.16129-win32-svn-1.6.1.msi


# Installing TortoiseSVN #

Ok first off you need to install the svn client

![http://rbttinvasion.googlecode.com/svn/trunk/Images/SVNSetup.jpg](http://rbttinvasion.googlecode.com/svn/trunk/Images/SVNSetup.jpg)

Just follow the prompts and klik next (pretty simple)

# Installing The Classes #

now you've finnished installing tortoise open an explorer window and browse to

C:\Documents and Settings\User Name\My Documents\My Games\Unreal Tournament 3\UTGame\Src

![http://rbttinvasion.googlecode.com/svn/trunk/Images/TreeSrc.jpg](http://rbttinvasion.googlecode.com/svn/trunk/Images/TreeSrc.jpg)

Here you'll need to create a folder for your project called RBTTInvasion

![http://rbttinvasion.googlecode.com/svn/trunk/Images/TreeRBTTInvasion.jpg](http://rbttinvasion.googlecode.com/svn/trunk/Images/TreeRBTTInvasion.jpg)



Ok now to get some classes from the repository. Right klik in the rbbtinvasion folder and Select TortoiseSVN > Repo Browser

![http://rbttinvasion.googlecode.com/svn/trunk/Images/ContextRepo.jpg](http://rbttinvasion.googlecode.com/svn/trunk/Images/ContextRepo.jpg)

a window will popup asking for the url of your repository just enter<br>
<code>svn checkout http://rbttinvasion.googlecode.com/svn/trunk/ rbttinvasion-read-only</code>

<img src='http://rbttinvasion.googlecode.com/svn/trunk/Images/URLWindow.jpg' />

the repository browser window will now appear. Extend the RBTTInvasion folder by kliking the little cross next to it<br>
<br>
<img src='http://rbttinvasion.googlecode.com/svn/trunk/Images/RepoBrowser.jpg' />

Now Right Klik the the classes folder and select checkout<br>
<br>
<img src='http://rbttinvasion.googlecode.com/svn/trunk/Images/RepoCheckout.jpg' />

when the checkout window appears you'll notice the URL of Repository field is already filled in for you,add a forward slash at the end of the line so it reads<br>
<br>
<blockquote><a href='http://rbttinvasion.googlecode.com/svn/trunk/RBTTInvasion/Classes/'>http://rbttinvasion.googlecode.com/svn/trunk/RBTTInvasion/Classes/</a></blockquote>

It is very important you add a forward slash or the files wil write out to the wrong place it should look like<br>
<br>
<img src='http://rbttinvasion.googlecode.com/svn/trunk/Images/Checkout.jpg' />

if you did everythig right this window will appear and you'll see the classes being downloaded to your machine :)<br>
<br>
<img src='http://rbttinvasion.googlecode.com/svn/trunk/Images/CheckoutFinished.jpg' />

your directory should now look like this<br>
<br>
<img src='http://rbttinvasion.googlecode.com/svn/trunk/Images/TreeClasses.jpg' />

<h1>Installing The packages</h1>

Ok now its time to go get some packages open up an eplorer window again and browse to<br>
<br>
C:\Documents and Settings\User Name\My Documents\My Games\Unreal Tournament 3\UTGame\Unpublished\CookedPC<br>
<br>
<img src='http://rbttinvasion.googlecode.com/svn/trunk/Images/TreeCookedPC.jpg' />

again right klik in the folder select tortoiseSVN > Repo browser<br>
<br>
<img src='http://rbttinvasion.googlecode.com/svn/trunk/Images/ContextRepo.jpg' />

the url window will appear again already filled in this time just klik ok<br>
<br>
<img src='http://rbttinvasion.googlecode.com/svn/trunk/Images/URLWindow.jpg' />

this time when the repo browser appears you'll need to double klik on the RBTTInvasion folder to refresh the view. Then just right klik the packages folder and select checkout<br>
<br>
<img src='http://rbttinvasion.googlecode.com/svn/trunk/Images/RepoPackCheckout.jpg' />

again when the checkout window appears make sure you add a forward slash to the end of the URL of Repository field so it reads<br>
<br>
<a href='http://rbttinvasion.googlecode.com/svn/trunk/RBTTInvasion/Packages/'>http://rbttinvasion.googlecode.com/svn/trunk/RBTTInvasion/Packages/</a>

<img src='http://rbttinvasion.googlecode.com/svn/trunk/Images/CheckoutPack.jpg' />

the packages take a little longer than the classes to download<br>
<br>
<img src='http://rbttinvasion.googlecode.com/svn/trunk/Images/CheckoutFinished.jpg' />

finally your directory should look like this<br>
<br>
<img src='http://rbttinvasion.googlecode.com/svn/trunk/Images/TreeMyGames.jpg' />

<h1>Installing WebAdmin</h1>

Our Mod now has a web interface for server admins to configure their server online. This means you have to install WebAdmin.u, This file is available from<br>
<br>
<a href='http://ut3webadmin.elmuerte.com/download.php?t=2008-09-21'>http://ut3webadmin.elmuerte.com/download.php?t=2008-09-21</a>

Once you've downloaded webadmin.u you need to copy it to<br>
<br>
<img src='http://images.allprog.nl/img/3016_1245442894.jpg' />

just drop the file in there, Now open up an explorer window and browse to<br>
<br>
<img src='http://rbttinvasion.googlecode.com/svn/trunk/Images/TreeConfig.jpg' />

locate and open your UTEngine.ini file with notepad now hit CRTL + F to bring up a search window in the field type "EditPackages"<br>
<br>
<img src='http://images.allprog.nl/img/7396_1245445805.jpg' />

now edit the section <a href='EditPackages.md'>EditPackages</a> and add "EditPackages=WebAdmin"<br>
<br>
<img src='http://images.allprog.nl/img/670_1245446022.jpg' />

now Save and close the file..<br>
<br>
<h1>Compiling The Project</h1>

first we need to setup the ini file so unreal knows what is to be compiled<br>
once again open up an explorer window and browse to<br>
<br>
<img src='http://rbttinvasion.googlecode.com/svn/trunk/Images/TreeConfig.jpg' />

locate and open your UTEditor.ini file with notepad now hit CRTL + F to bring up a search window in the field type "ModPackages"<br>
<br>
<img src='http://rbttinvasion.googlecode.com/svn/trunk/Images/Find.jpg' />

now edit the section [ModPackages} From this<br>
<br>
<img src='http://rbttinvasion.googlecode.com/svn/trunk/Images/ModPackBefore.jpg' />

I personally like to change the ModOutputDir to the published folder but you can leave it as is if you like you just have to move the script to the published folder to play it. you also need to add a modpackages line it should look like this<br>
<br>
<img src='http://rbttinvasion.googlecode.com/svn/trunk/Images/ModPackAfter.jpg' />

Now save your changes and close notepad!<br>
<br>
thankfully for this part epic have given us a very handy little tool called UT3FrontEnd you can find it by browsing to C:\Program Files\Unreal Tournament 3\Binaries (OR where ever you have your game installed)<br>
<br>
<img src='http://rbttinvasion.googlecode.com/svn/trunk/Images/TreeBinaries.jpg' />

just create a shortcut and place it on your desktop<br>
<br>
<img src='http://rbttinvasion.googlecode.com/svn/trunk/Images/Shortcut.jpg' />


Startup UT3FrontEnd locate the script tab and set the Script compile config to debug and then hit the make button at the top (it may look like it's hanging if your pc is old like mine but just give a couple of seconds to get going)<br>
<br>
if everything went ok it should look like this<br>
<br>
<img src='http://rbttinvasion.googlecode.com/svn/trunk/Images/Frontend.jpg' />

the version compiled here has 2 warnings but dont worry We're updating all the time so from time to time the odd warning may creep in but we usally fix pretty quick<br>
<br>
Finally all you need to do is to copy the packages folder from the unpublished folder to the published folder and you good to play<br>
<br>
have fun !!!<br>
<br>
<br>
