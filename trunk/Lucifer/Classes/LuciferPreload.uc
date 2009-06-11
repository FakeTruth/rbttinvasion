class LuciferPreload extends Mutator;

#EXEC OBJ LOAD FILE=Lucifer.ukx

#EXEC OBJ LOAD FILE=GeneralAmbience.uax

#EXEC OBJ LOAD FILE=Lucifertex.utx

function PreBeginPlay() 
{
local Skeletalmesh SomeMesh;
local material sometex;
local class someclass;
local sound somesound;
local MeshAnimation someAnim;

	Super.PreBeginPlay();
Log("******LuciferBOSS PRELOAD INITIALIZED******");

someclass=class(DynamicLoadObject("LuciferBOSS.LuciferBOSS",class'class',True));

somesound=sound(DynamicLoadObject("LuciferBOSS.LuciferHit1",class'sound',True));
somesound=sound(DynamicLoadObject("GeneralAmbience.firefx11",class'sound',True));
somesound=sound(DynamicLoadObject("LuciferBOSS.LuciferHit2",class'sound',True));
somesound=sound(DynamicLoadObject("LuciferBOSS.LuciferHit3",class'sound',True));
somesound=sound(DynamicLoadObject("LuciferBOSS.LuciferLaugh",class'sound',True));
somesound=sound(DynamicLoadObject("LuciferBOSS.LuciferStep",class'sound',True));
somesound=sound(DynamicLoadObject("LuciferBOSS.LuciferStomp",class'sound',True));
somesound=sound(DynamicLoadObject("LuciferBOSS.LuciferAmbient",class'sound',True));
somesound=sound(DynamicLoadObject("LuciferBOSS.LuciferDeath",class'sound',True));

sometex=material(DynamicLoadObject("EmitterTextures.MultiFrame.LargeFlames",class'material',True));
sometex=material(DynamicLoadObject("Lucifertex.Map",class'material',True));

someAnim=MeshAnimation(DynamicLoadObject("Lucifer.LuciferANI",class'MeshAnimation',True));

SomeMesh=Skeletalmesh(DynamicLoadObject("Lucifer.Lucifer",class'Skeletalmesh',True));

}

defaultproperties
{
     bAddToServerPackages=True
     GroupName="LuciferPreload"
     FriendlyName="Lucifer Preload"
     Description="preloads resources for LuciferBOSS"
     bAlwaysRelevant=True
     RemoteRole=ROLE_SimulatedProxy
}
