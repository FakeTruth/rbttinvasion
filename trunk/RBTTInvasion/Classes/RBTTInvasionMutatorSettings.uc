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
	
	if(request.GetVariable("SubmitTab2") ~= "True")
	{
		TempString = request.GetVariable("CurrentEditWave");
		if(TempString != "" && int(TempString) != 0)
		{
			CurrentEditWave = int(TempString);
			
			configName = CurrentEditMap;
			CWaveConfig = Class'RBTTInvasionGameRules'.static.FindCustomWaveConfig(configName);
			if (CWaveConfig == None)
			{
				ErrorCode = 1;
				return false;
			}
			
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
			if(TempString != "" && int(TempString) != 0)
			{
				CWaveConfig.WaveConfig[CurrentEditWave-1].WaveLength = int(TempString);
			}
			
			TempString = request.GetVariable("MonstersPerPlayer");
			if(TempString != "" && float(TempString) != 0)
			{
				CWaveConfig.WaveConfig[CurrentEditWave-1].MonstersPerPlayer = float(TempString);
			}
			
			TempString = request.GetVariable("MaxMonsters");
			if(TempString != "" && int(TempString) != 0)
			{
				CWaveConfig.WaveConfig[CurrentEditWave-1].MaxMonsters = int(TempString);
			}
			
			CWaveConfig.SaveConfig();	// Save settings / Write them out to the ini file
			LoadWaveConfig(CurrentEditMap); // Refresh settings
		}
		else
			return false;
		
		
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
	}
	else
		ErrorCode = 1;
		
	return true;
}

/**
 * Render all properties of the given settings instance
 */
function renderSettings(WebResponse response, SettingsRenderer renderer, optional string substName = "settings")
{
	local string result, entry;

	curSettings = substName;
	curResponse = response;

	//result $= "</form>";
	
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
	{
		result$="WTF YOU HAD AN ERROR, WTF!! WAAAA!!";
		ErrorCode = 0;
	}
	curResponse.Subst("settings", result);
	result = curResponse.LoadParsedUHTM(renderer.getPath() $ "/" $ renderer.getFilePrefix() $ "wrapper_group.inc");
	

	result $= "<br><br><br><hr><form method=\"Post\" action=\""$renderer.getPath()$"\"><b>!!!DONT CLICK THE SAVE SETTINGS BUTTON BELOW!!!</b>";
	curResponse.subst(substName, result);
}

function string renderGroup(WebResponse response, SettingsRenderer renderer, int idx)
{
	local string result;
	local int i;

	if(idx == 0)
	{
		result$="</form>";
		result$="<table>";
		for(i = 0; i < MonsterTable.length; i++)
		{
			result$="<tr><td>"$MonsterTable[i].MonsterClassName$"</td><td><button type=\"submit\" name=\"action\" value=\"save\" id=\"btnselect\">Remove Monster</button></td></tr>";
		}
		result$="</table><br><br>";
		
		response.subst("setting.formname", "NewMonsterClassName");
		response.subst("setting.value", "");
		response.subst("setting.maxlength", "200");
		result $= response.LoadParsedUHTM(renderer.getPath() $ "/" $ renderer.getFilePrefix() $ "string.inc");
	}
	else if(idx == 1)
	{
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
		
		result$="<BR><BR>";
		result$="<b>Monsters in wave"@CurrentEditWave$":</b><br>";
		for(i = 0; i < WaveConfig[CurrentEditWave-1].MonsterNum.length; i++)
		{
			result$=MonsterTable[WaveConfig[CurrentEditWave-1].MonsterNum[i]].MonsterClassName$"<BR>";
		}

		result$="<br><br>";
		
		// ############ TAB 2 FORM  #############
		result$="<form action=\"#SettingsGroup1\" method=\"post\">";
		result$="<input type=\"hidden\" name=\"action\" value=\"save\">";
		result$="<input type=\"hidden\" name=\"mutator\" value=\"RBTTInvasion.RBTTInvasionMutator\">";
		result$="<input type=\"hidden\" name=\"CurrentEditWave\" value=\""$CurrentEditWave$"\">";
		// ######## END FORM DECLARATION ########
		
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
		result$="</select></td></tr>";
		
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
		result$="</select></td></tr>";
		
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
		result$="</select></td></tr>";
		
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
		
		result$="</td></tr>";
		
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
		
		result$="</td></tr>";
		
		//===========================
		// WaveLength
		
		result$="<tr><td><b>WaveLength:</b></td><td>";
		
		curResponse.Subst("setting.formname", "WaveLength");
		curResponse.Subst("setting.value", WaveConfig[CurrentEditWave-1].WaveLength);
		curResponse.Subst("setting.minval", "1");
		curResponse.Subst("setting.maxval", "999999");
		curResponse.Subst("setting.increment", "5");
		curResponse.Subst("setting.asint", "5");
		
		result$=curResponse.LoadParsedUHTM(renderer.getPath() $ "/" $ renderer.getFilePrefix() $ "int.inc");
		
		result$="</td></tr>";
		
		// Wrap things up ------------
		
		result$="</table><br>";
		
		result$="<button type=\"submit\" name=\"SubmitTab2\" value=\"True\" id=\"btnselect\">Save Wave</button>";
		result$="</form>";
		// ######## END TAB 2 FORM #############
		
	}
	
	return result;
}