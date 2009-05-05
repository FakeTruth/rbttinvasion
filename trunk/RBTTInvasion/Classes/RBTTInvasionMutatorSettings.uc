class RBTTInvasionMutatorSettings extends Settings implements(IAdvWebAdminSettings) DependsOn(RBTTInvasionMutator) DependsOn(RBTTInvasionGameRules);

var Array<RBTTInvasionMutator.MonsterNames> MonsterTable;
var Array<RBTTInvasionGameRules.WaveTable> WaveConfig;

var int ErrorCode;

var int CurrentEditWave;
var string CurrentEditMap;

var string curSettings;
var WebResponse curResponse;

function initSettings(WorldInfo worldinfo, DataStoreCache dscache)
{
	MonsterTable = class'RBTTInvasionMutator'.default.MonsterTable;
	CurrentEditWave = 1;
	
	LoadWaveConfig(worldinfo.GetURLMap());
}

function LoadWaveConfig(string MapName)
{
	local CustomWaveConfig CWaveConfig;
	
	CurrentEditMap = MapName;
	CWaveConfig = Class'RBTTInvasionGameRules'.static.FindCustomWaveConfig(MapName);

	if (CWaveConfig == None)
		return;       // no custom wave config

	`log(">> Setting WaveConfig.length to 0 <<");
		WaveConfig.Length = 0;

	`log(">> Replacing WaveConfig with CWaveConfig.WaveConfig <<");
	WaveConfig = CWaveConfig.WaveConfig;

	`log(">> Clearing CWaveConfig <<");
	CWaveConfig = None;

	`log("Invasion Custom Wave Config successfully loaded for"@MapName);
}

function cleanup()
{
	MonsterTable.length = 0;
	WaveConfig.length = 0;
	ErrorCode = 0;
	CurrentEditWave = 0;
}

function bool saveSettings(WebRequest request, WebAdminMessages messages)
{
	local int i;
	local string NewMonsterClassName;
	local array<string> AllVars;
	local string VarKey;
	local string configName;
	local CustomWaveConfig CWaveConfig;
	
	local array<int> TempArrayInt;
	local string TempString;

	request.GetVariables(AllVars);
	
	ForEach AllVars(VarKey)
	{
		`log(VarKey@"="@request.GetVariable(VarKey));
	}

	if(request.GetVariable("ChangeWaveNum") ~= "True")
	{
		TempString = request.GetVariable("CurrentEditWave");
		if(TempString != "" && int(TempString) != 0)
		{
			CurrentEditWave = int(TempString);
			return false;
		}
		return false;
	}
	
	if(request.GetVariable("AddNewWave") ~= "True")
	{
		configName = CurrentEditMap;
		CWaveConfig = Class'RBTTInvasionGameRules'.static.FindCustomWaveConfig(configName);
		`log("####### ADDING NEW WAVE #######");
		CWaveConfig.WaveConfig.length = CWaveConfig.WaveConfig.length+1;
		CurrentEditWave = CWaveConfig.WaveConfig.length;
		CWaveConfig.SaveConfig();
		LoadWaveConfig(CurrentEditMap); // Reload everything to render the updated config
		return true;
	}
	
	if(request.GetVariable("InsertWave") ~= "True")
	{
		TempString = request.GetVariable("CurrentEditWave");
		if(TempString != "" && int(TempString) != 0)
		{
			CurrentEditWave = int(TempString);
			
			configName = CurrentEditMap;
			CWaveConfig = Class'RBTTInvasionGameRules'.static.FindCustomWaveConfig(configName);
			`log("####### INSERTING COPY OF WAVE BEFORE WAVE "$CurrentEditWave$" #######");
			CWaveConfig.WaveConfig.InsertItem(CurrentEditWave-1, CWaveConfig.WaveConfig[CurrentEditWave-1]);
			CWaveConfig.SaveConfig();
			LoadWaveConfig(CurrentEditMap); // Reload everything to render the updated config
			return true;
		}
		else
		{	
			ErrorCode = 3;
			return false;
		}
	}

	if(request.GetVariable("DeleteWave") ~= "True")
	{
		TempString = request.GetVariable("CurrentEditWave");
		if(TempString != "" && int(TempString) != 0)
		{
			CurrentEditWave = int(TempString);
			
			configName = CurrentEditMap;
			CWaveConfig = Class'RBTTInvasionGameRules'.static.FindCustomWaveConfig(configName);
			`log("####### DELETING WAVE "$CurrentEditWave$" #######");
			WaveConfig.length = 0;
			for(i = 0; i < CWaveConfig.WaveConfig.length; i++)
			{
				if(i == CurrentEditWave-1)
					continue;
					
				WaveConfig.AddItem(CWaveConfig.WaveConfig[i]);
			}
			if(WaveConfig.length < CurrentEditWave)
				CurrentEditWave = WaveConfig.length;
				
			CWaveConfig.WaveConfig = WaveConfig;
			CWaveConfig.SaveConfig();
			LoadWaveConfig(CurrentEditMap); // Reload everything to render the updated config
			return true;
		}
		else
		{	
			ErrorCode = 3;
			return false;
		}
	}
	
	if(request.GetVariable("SubmitTab2") != "")
	{
		TempString = request.GetVariable("CurrentEditWave");
		if(TempString != "" && int(TempString) != 0)
		{
			CurrentEditWave = int(TempString);
			
			configName = CurrentEditMap;
			CWaveConfig = Class'RBTTInvasionGameRules'.static.FindCustomWaveConfig(configName);
			if (CWaveConfig == None)
			{
				ErrorCode = 2;
				return false;
			}
			
			TempArrayInt.length = 0;
			for(i = 0; request.GetVariable("MonsterNum"$i) != ""; i++)
			{
				TempString = request.GetVariable("MonsterNum"$i);
				
				if(TempString ~= "None")
					continue;
					
				TempArrayInt.AddItem(int(TempString));				
			}
			CWaveConfig.WaveConfig[CurrentEditWave-1].MonsterNum = TempArrayInt;
			
			TempArrayInt.length = 0;
			for(i = 0; request.GetVariable("BossMonsters"$i) != ""; i++)
			{
				TempString = request.GetVariable("BossMonsters"$i);
				
				if(TempString ~= "None")
					continue;
					
				TempArrayInt.AddItem(int(TempString));				
			}
			CWaveConfig.WaveConfig[CurrentEditWave-1].BossMonsters = TempArrayInt;
			
			TempString = request.GetVariable("bIsQueue");
			if(TempString != "")
			{
				CWaveConfig.WaveConfig[CurrentEditWave-1].bIsQueue = Bool(TempString);
			}
			
			TempString = request.GetVariable("bTimedWave");
			if(TempString != "")
			{
				CWaveConfig.WaveConfig[CurrentEditWave-1].bTimedWave = Bool(TempString);
			} 
			
			TempString = request.GetVariable("bAllowPortals");
			if(TempString != "")
			{
				CWaveConfig.WaveConfig[CurrentEditWave-1].bAllowPortals = Bool(TempString);
			}
			
			TempString = request.GetVariable("WaveLength");
			if(TempString != "" && string(int(TempString)) == TempString) // A different check here, because WaveLength may actually be 0
			{
				CWaveConfig.WaveConfig[CurrentEditWave-1].WaveLength = int(TempString);
			}
			
			TempString = request.GetVariable("MonstersPerPlayer");
			if(TempString != "" && float(TempString) != 0)
			{
				CWaveConfig.WaveConfig[CurrentEditWave-1].MonstersPerPlayer = float(TempString);
			}
			
			TempString = request.GetVariable("MonsterHealthMultiplier");
			if(TempString != "" && float(TempString) != 0)
			{
				CWaveConfig.WaveConfig[CurrentEditWave-1].MonsterHealthMultiplier = float(TempString);
			}
			
			TempString = request.GetVariable("MaxMonsters");
			if(TempString != "" && int(TempString) != 0)
			{
				CWaveConfig.WaveConfig[CurrentEditWave-1].MaxMonsters = int(TempString);
			}
			
			TempString = request.GetVariable("WaveCountdown");
			if(TempString != "" && int(TempString) != 0)
			{
				CWaveConfig.WaveConfig[CurrentEditWave-1].WaveCountdown = int(TempString);
			}
			
			
			CWaveConfig.SaveConfig();	// Save settings / Write them out to the ini file
			LoadWaveConfig(CurrentEditMap); // Refresh settings
		}
		else
		{	
			ErrorCode = 3;
			return false;
		}
		
		
		return true;
	}
	
	if(request.GetVariable("RemoveMonster") != "")
	{
		for(i = 0; i < MonsterTable.length && request.GetVariable("RemoveMonster"$i) ~= ""; i++)
		{ }	// Loop through all RemoveMonster, to find the one we need to remove
		
		if(i == MonsterTable.length) // it didn't find the monster that's supposed to be removed
		{
			ErrorCode = 4;
			return false;
		}
		
		TempString = MonsterTable[i].MonsterClassName; // Get the class of the monster
		
		MonsterTable.length = 0;
		for(i = 0; i < class'RBTTInvasionMutator'.default.MonsterTable.length; i++)
		{
			if(class'RBTTInvasionMutator'.default.MonsterTable[i].MonsterClassName ~= TempString)
				continue;
				
			MonsterTable.AddItem(class'RBTTInvasionMutator'.default.MonsterTable[i]);
		}
		
		class'RBTTInvasionMutator'.default.MonsterTable = MonsterTable;
		class'RBTTInvasionMutator'.static.StaticSaveConfig();
		
		return true;
	}
	
	NewMonsterClassName = request.GetVariable("NewMonsterClassName");
	`log(">>NewMonsterClassName: "@NewMonsterClassName);
	if(NewMonsterClassName != "")
	{
		i = class'RBTTInvasionMutator'.default.MonsterTable.length;
		class'RBTTInvasionMutator'.default.MonsterTable.length = i+1;
		class'RBTTInvasionMutator'.default.MonsterTable[i].MonsterClassName = NewMonsterClassName;
		class'RBTTInvasionMutator'.default.MonsterTable[i].MonsterName = NewMonsterClassName;
		class'RBTTInvasionMutator'.static.StaticSaveConfig();
		
		MonsterTable = class'RBTTInvasionMutator'.default.MonsterTable;
		
		return true;
	}
	else
		ErrorCode = 1;
		
	return false;
}

/**
 * Render all properties of the given settings instance
 */
function renderSettings(WebResponse response, SettingsRenderer renderer, optional string substName = "settings")
{
	local string result, entry;

	curSettings = substName;
	curResponse = response;

	
	//for (i = 0; i < 3; i++)
	//{
		//if (groups[i].settings.length == 0) continue;
		curResponse.Subst("group.id", "SettingsGroup0");
		curResponse.Subst("group.title", "Edit MonsterTable");
		curResponse.Subst("group.settings", renderGroup(curResponse, renderer, 0));
		entry = curResponse.LoadParsedUHTM(renderer.getPath() $ "/" $ renderer.getFilePrefix() $ "group.inc");
		result $= entry;
		
		curResponse.Subst("group.id", "SettingsGroup1");
		curResponse.Subst("group.title", "Edit Wave"@CurrentEditWave);
		curResponse.Subst("group.settings", renderGroup(curResponse, renderer, 1));
		entry = curResponse.LoadParsedUHTM(renderer.getPath() $ "/" $ renderer.getFilePrefix() $ "group.inc");
		result $= entry;
	//}
	if(ErrorCode == 1)
		result$="<font color=\"red\"><B>!!MONSTER CLASS COULD NOT BE FOUND!!</B></font>";
	else if(ErrorCode == 2)
		result$="<font color=\"red\"><B>!!WAVE CONFIGURATION COULD NOT BE FOUND!!</B></font>";
	else if(ErrorCode == 3)
		result$="<font color=\"red\"><B>!!NO CURRENTEDITWAVE SENT THROUGH POST!!</B></font>";
	ErrorCode = 0;
	curResponse.Subst("settings", result);
	result = curResponse.LoadParsedUHTM(renderer.getPath() $ "/" $ renderer.getFilePrefix() $ "wrapper_group.inc");
	
	result $= "<br><br><br>";
	result $= "<div style=\"font-size:8pt;text-align:center;\">RBTTInvasion WebAdmin application created by FakeTruth<br>This WebAdmin application is compatible with WebAdmin v1.14.0, IE 7 and Google Chrome. RBTT is not responsible if this WebAdmin application breaks something.. anything.. even if it breaks your grandma, we will not be responsible. Seriously. I'm gonna shut up now.</div>";
	result $= "<hr><form method=\"Post\" action=\""$renderer.getPath()$"\"><b>!!!DONT CLICK THE SAVE SETTINGS BUTTON BELOW!!!</b>";
	curResponse.subst(substName, result);
}

function string renderGroup(WebResponse response, SettingsRenderer renderer, int idx)
{
	local string result;
	local int i, j;

	if(idx == 0)
	{
		result$="</form>";
		result$="<form action=\"#SettingsGroup0\" method=\"post\">";
		result$="<input type=\"hidden\" name=\"action\" value=\"save\">";
		result$="<input type=\"hidden\" name=\"mutator\" value=\"RBTTInvasion.RBTTInvasionMutator\">";
		result$="<input type=\"hidden\" name=\"RemoveMonster\" value=\"True\">";
		result$="<table>";
		for(i = 0; i < MonsterTable.length; i++)
		{
			result$="<tr><td>"$MonsterTable[i].MonsterClassName$"</td><td><button type=\"submit\" name=\"RemoveMonster"$i$"\" value=\"True\" id=\"btnselect\">Remove Monster</button></td></tr>";
		}
		result$="</table><br><br>";
		result$="</form>\n\n";
		
		result$="In here, type the classname of the pawn (monster) you want to add to the MonsterTable. It looks like this: Package.Class, for example: RBTTInvasion.RBTTSkullCrab<br>\n";
		result$="<form action=\"#SettingsGroup0\" method=\"post\">";
		result$="<input type=\"text\" id=\"NewMonsterClassName\" name=\"NewMonsterClassName\" value=\"\" maxlength=\"200\" size=\"60\">";
		result$="<input type=\"hidden\" name=\"action\" value=\"save\">";
		result$="<input type=\"hidden\" name=\"mutator\" value=\"RBTTInvasion.RBTTInvasionMutator\">";
		result$="<button type=\"submit\" name=\"submit\" value=\"True\" id=\"btnselect\">Add Monster</button>";
		result$="</form>";
	}
	else if(idx == 1)
	{
		result$="<table><tr><td>";
		result$="<form action=\"#SettingsGroup1\" method=\"post\" id=\"waveselect\">";
		result$="<select id=\"CurrentEditWave\" name=\"CurrentEditWave\">";
		for(i = 1; i <= WaveConfig.length; i++)
		{
			//result$="<A HREF=\"?action=save&mutator=RBTTInvasion.RBTTInvasionMutator&CurrentEditWave="$i$"#SettingsGroup1\">"@i@"</A>";
			if(i == CurrentEditWave)
				result$="<option value=\""$i$"\" selected=\"selected\">"$i$"</option>\n";
			else
				result$="<option value=\""$i$"\">"$i$"</option>\n";
		}
		result$="</select>";
		result$="<input type=\"hidden\" name=\"ChangeWaveNum\" value=\"True\">";
		result$="<input type=\"hidden\" name=\"action\" value=\"save\">";
		result$="<input type=\"hidden\" name=\"mutator\" value=\"RBTTInvasion.RBTTInvasionMutator\">";
		result$="<button type=\"submit\" name=\"action\" value=\"save\" id=\"btnselect\">Change Wave</button>";
		result$="</form>";
		result$="<script type=\"text/javascript\">\n//<![CDATA[\n $(document).ready(function(){\n $('#CurrentEditWave').change(function(){\n $('#waveselect').submit();\n });\n });\n\n //]]>\n</script>\n";
		result$="</td><td>";
		
		result$="<form action=\"#SettingsGroup1\" method=\"post\">";
		result$="<input type=\"hidden\" name=\"action\" value=\"save\">";
		result$="<input type=\"hidden\" name=\"mutator\" value=\"RBTTInvasion.RBTTInvasionMutator\">";
		result$="<input type=\"hidden\" name=\"CurrentEditWave\" value=\""$CurrentEditWave$"\">";
		result$="<input type=\"hidden\" name=\"AddNewWave\" value=\"True\">";
		result$="<button type=\"submit\" id=\"btnselect\">Add New Wave</button>";
		result$="</form>";
		result$="</td><td>";
		
		result$="<form action=\"#SettingsGroup1\" method=\"post\">";
		result$="<input type=\"hidden\" name=\"action\" value=\"save\">";
		result$="<input type=\"hidden\" name=\"mutator\" value=\"RBTTInvasion.RBTTInvasionMutator\">";
		result$="<input type=\"hidden\" name=\"CurrentEditWave\" value=\""$CurrentEditWave$"\">";
		result$="<input type=\"hidden\" name=\"InsertWave\" value=\"True\">";
		result$="<button type=\"submit\" id=\"btnselect\">Insert Copy Of Current Wave</button>";
		result$="</form>";
		result$="</td><td>";
		
		result$="<form action=\"#SettingsGroup1\" method=\"post\">";
		result$="<input type=\"hidden\" name=\"action\" value=\"save\">";
		result$="<input type=\"hidden\" name=\"mutator\" value=\"RBTTInvasion.RBTTInvasionMutator\">";
		result$="<input type=\"hidden\" name=\"CurrentEditWave\" value=\""$CurrentEditWave$"\">";
		result$="<input type=\"hidden\" name=\"DeleteWave\" value=\"True\">";
		result$="<button type=\"submit\" id=\"btnselect\">Delete Current Wave</button>";
		result$="</form>";
		result$="</td></tr></table>";
		
		result$="<BR>";
		
		result$="<h1> Editing Wave"@CurrentEditWave$"</h1><br><br>";
		
		// ############ TAB 2 FORM  #############
		result$="<form action=\"#SettingsGroup1\" method=\"post\">";
		result$="<input type=\"hidden\" name=\"action\" value=\"save\">";
		result$="<input type=\"hidden\" name=\"mutator\" value=\"RBTTInvasion.RBTTInvasionMutator\">";
		result$="<input type=\"hidden\" name=\"CurrentEditWave\" value=\""$CurrentEditWave$"\">";
		// ######## END FORM DECLARATION ########
		
		//===========================
		// WaveConfig
		
		result$="<b>Monsters:</b><br>";
		result$="<table>";
		for(i = 0; i < WaveConfig[CurrentEditWave-1].MonsterNum.length + 2; i++) // +x for amount of extra empty slots
		{
			result$="<tr><td><b>Monster"@i+1$":</b></td><td><select id=\"MonsterNum"$i$"\" name=\"MonsterNum"$i$"\">\n";
			if(i >= WaveConfig[CurrentEditWave-1].MonsterNum.length)
				result$="<option value=\"None\" selected=\"selected\">----------EMPTY----------</option>\n";
			else
				result$="<option value=\"None\">----------EMPTY----------</option>\n";
				
			for(j = 0; j < MonsterTable.length; j++)
			{
				if(i < WaveConfig[CurrentEditWave-1].MonsterNum.length && WaveConfig[CurrentEditWave-1].MonsterNum[i] == j)
					result$="<option value=\""$j$"\" selected=\"selected\">"$MonsterTable[j].MonsterClassName$"</option>\n";
				else
					result$="<option value=\""$j$"\">"$MonsterTable[j].MonsterClassName$"</option>\n";
			}
			
			result$="</select></td></tr>";
		}
		
		result$="</table>";
		result$="<br><br>";
		
		//===========================
		// BossMonsters
		
		result$="<b>Boss Monsters:</b><br>";
		result$="<table>";
		for(i = 0; i < WaveConfig[CurrentEditWave-1].BossMonsters.length + 2; i++) // +x for amount of extra empty slots
		{
			result$="<tr><td><b>Monster"@i+1$":</b></td><td><select id=\"BossMonsters"$i$"\" name=\"BossMonsters"$i$"\">\n";
			if(i >= WaveConfig[CurrentEditWave-1].BossMonsters.length)
				result$="<option value=\"None\" selected=\"selected\">----------EMPTY----------</option>\n";
			else
				result$="<option value=\"None\">----------EMPTY----------</option>\n";
				
			for(j = 0; j < MonsterTable.length; j++)
			{
				if(i < WaveConfig[CurrentEditWave-1].BossMonsters.length && WaveConfig[CurrentEditWave-1].BossMonsters[i] == j)
					result$="<option value=\""$j$"\" selected=\"selected\">"$MonsterTable[j].MonsterClassName$"</option>\n";
				else
					result$="<option value=\""$j$"\">"$MonsterTable[j].MonsterClassName$"</option>\n";
			}
			
			result$="</select></td></tr>";
		}
		
		result$="</table>";
		result$="<br><br>";
		
		result$="<table>";
		
		//===========================
		// bIsQueue
		
		result$="<tr><td><b>bIsQueue:</b></td><td><select id=\"bIsQueue\" name=\"bIsQueue\">";
		if(WaveConfig[CurrentEditWave-1].bIsQueue)
		{
			result$="<option value=\"True\" selected=\"selected\">True</option>\n";
			result$="<option value=\"False\">False</option>\n";
		}
		else
		{
			result$="<option value=\"True\">True</option>\n";
			result$="<option value=\"False\" selected=\"selected\">False</option>\n";
		}
		result$="</select></td><td>If this is set to true, this wave will behave like it's a queue.</td></tr>";
		
		//===========================
		// bTimedWave
		
		result$="<tr><td><b>bTimedWave:</b></td><td><select id=\"bTimedWave\" name=\"bTimedWave\">";
		if(WaveConfig[CurrentEditWave-1].bTimedWave)
		{
			result$="<option value=\"True\" selected=\"selected\">True</option>\n";
			result$="<option value=\"False\">False</option>\n";
		}
		else
		{
			result$="<option value=\"True\">True</option>\n";
			result$="<option value=\"False\" selected=\"selected\">False</option>\n";
		}
		result$="</select></td><td>If this is set to true, the wave will last a WaveLength of seconds.</td></tr>";
		
		//===========================
		// bAllowPortals
		
		result$="<tr><td><b>bAllowPortals:</b></td><td><select id=\"bAllowPortals\" name=\"bAllowPortals\">";
		if(WaveConfig[CurrentEditWave-1].bAllowPortals)
		{
			result$="<option value=\"True\" selected=\"selected\">True</option>\n";
			result$="<option value=\"False\">False</option>\n";
		}
		else
		{
			result$="<option value=\"True\">True</option>\n";
			result$="<option value=\"False\" selected=\"selected\">False</option>\n";
		}
		result$="</select></td><td>If this is set to true, portals will spawn in this wave.</td></tr>";
		
		//===========================
		// MonstersPerPlayer
		
		result$="<tr><td><b>MonstersPerPlayer:</b></td><td>";
		
		curResponse.Subst("setting.formname", "MonstersPerPlayer");
		curResponse.Subst("setting.value", WaveConfig[CurrentEditWave-1].MonstersPerPlayer);
		curResponse.Subst("setting.minval", "1");
		curResponse.Subst("setting.maxval", "999999");
		curResponse.Subst("setting.increment", "5");
		curResponse.Subst("setting.asint", "5");
		
		result$=curResponse.LoadParsedUHTM(renderer.getPath() $ "/" $ renderer.getFilePrefix() $ "int.inc");
		
		result$="</td><td>The Monsters vs. Players ratio.</td></tr>";
		
		//===========================
		// MaxMonsters
		
		result$="<tr><td><b>MaxMonsters:</b></td><td>";
		
		curResponse.Subst("setting.formname", "MaxMonsters");
		curResponse.Subst("setting.value", WaveConfig[CurrentEditWave-1].MaxMonsters);
		curResponse.Subst("setting.minval", "1");
		curResponse.Subst("setting.maxval", "999999");
		curResponse.Subst("setting.increment", "5");
		curResponse.Subst("setting.asint", "5");
		
		result$=curResponse.LoadParsedUHTM(renderer.getPath() $ "/" $ renderer.getFilePrefix() $ "int.inc");
		
		result$="</td><td>This wave's maximum amount of monsters, this amount of monsters in the game will not exeed this number.</td></tr>";
		
		//===========================
		// WaveLength
		
		result$="<tr><td><b>WaveLength:</b></td><td>";
		
		curResponse.Subst("setting.formname", "WaveLength");
		curResponse.Subst("setting.value", WaveConfig[CurrentEditWave-1].WaveLength);
		curResponse.Subst("setting.minval", "0");
		curResponse.Subst("setting.maxval", "999999");
		curResponse.Subst("setting.increment", "5");
		curResponse.Subst("setting.asint", "5");
		
		result$=curResponse.LoadParsedUHTM(renderer.getPath() $ "/" $ renderer.getFilePrefix() $ "int.inc");
		
		result$="</td><td>During the wave, this amount of monsters will be spawned, or if bTimedWave is set to true the wave will last this time in seconds.</td></tr>";
		
		//===========================
		// MonsterHealthMultiplier
		
		result$="<tr><td><b>MonsterHealthMultiplier:</b></td><td>";
		
		curResponse.Subst("setting.formname", "MonsterHealthMultiplier");
		curResponse.Subst("setting.value", WaveConfig[CurrentEditWave-1].MonsterHealthMultiplier);
		curResponse.Subst("setting.minval", "0");
		curResponse.Subst("setting.maxval", "999999");
		curResponse.Subst("setting.increment", "5");
		curResponse.Subst("setting.asint", "5");
		
		result$=curResponse.LoadParsedUHTM(renderer.getPath() $ "/" $ renderer.getFilePrefix() $ "int.inc");
		
		result$="</td><td>On spawn the monster's health will be multiplied by this number.</td></tr>";

		//===========================
		// WaveCountdown
		
		result$="<tr><td><b>WaveCountdown:</b></td><td>";
		
		curResponse.Subst("setting.formname", "WaveCountdown");
		curResponse.Subst("setting.value", WaveConfig[CurrentEditWave-1].WaveCountdown);
		curResponse.Subst("setting.minval", "0");
		curResponse.Subst("setting.maxval", "999999");
		curResponse.Subst("setting.increment", "5");
		curResponse.Subst("setting.asint", "5");
		
		result$=curResponse.LoadParsedUHTM(renderer.getPath() $ "/" $ renderer.getFilePrefix() $ "int.inc");
		
		result$="</td><td>How many seconds before the monsters spawn.</td></tr>";
		
		
		// Wrap things up ------------
		
		result$="</table><br>";
		
		result$="<button type=\"submit\" name=\"SubmitTab2\" value=\"True\" id=\"btnselect\">Save Wave</button>";
		result$="</form>";
		// ######## END TAB 2 FORM #############
		
	}
	
	return result;
}