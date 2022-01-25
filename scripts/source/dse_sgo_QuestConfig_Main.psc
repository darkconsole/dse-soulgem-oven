ScriptName dse_sgo_QuestConfig_Main extends Quest

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

dse_sgo_QuestController_Main Property Main Auto
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Bool Property DebugMode = TRUE Auto Hidden

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Int Property StripModeNone = 0 AutoReadOnly Hidden
Int Property StripModeSexLabNormal = 1 AutoReadOnly Hidden
Int Property StripModeSexLabForeplay = 2 AutoReadOnly Hidden
Int Property StripModeBodyOnly = 3 AutoReadOnly Hidden

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

String Property FileConfig = "../../../configs/dse-soulgem-oven/settings/Default.json" AutoReadOnly Hidden
String Property FileCustom = "../../../configs/dse-soulgem-oven/settings/Custom.json" AutoReadOnly Hidden
Int[] Property FileID Auto Hidden

;; Float UpdateLoopFreq (in seconds)
;; how often the update loop runs.

;; Float UpdateLoopDelay (in seconds)
;; how long it waits between calculations of tracked actors.

;; Float UpdateGameHours (in hours)
;; minimum in-game time that must pass before an actor gets recalculated.

;; Int BirthFilledGems
;; 1 = filled, 0 = unfilled, -1 = custom birth list (not impl yet)

;; Int ActorGemsMax
;; how many gems can be incubated at one time per actor.

;; Float ActorMilkMax
;; how many bottes of milk can be carried per actor.

;; Int ActorSemenMax
;; how many bottles of semen can be carried per actor.

;; Float GemsPerDay
;; how many stages per day a gem matures. soulgems have six stages, so 1.0 means
;; it will take 1 in-game day to go from petty to lesser, 6 days to go from
;; petty to black.

;; Float MilksPerDay
;; how many bottles are generated over 24hr game time.

;; Float MilksPregPercent (0.0 to 100.0)
;; how far along pregnancy has to be before milk production starts.

;; Float SemensPerDay
;; how many bottles are generated over 24hr game time.

;; Bool SexLabStrip
;; use sexlab's stripping options, or just remove the chestpiece.

;; Float LevelAlchFactor
;; adjusts how fast alchemy levels.

;; Float LevelEnchFactor
;; adjusts how fast enchanting levels.

;; Float LevelValueBase
;; adjusts the maximum level used in the math for curving leveled values.

;; Int FertilityDays
;; how many days a fertility cycle lasts. within this amount of days the
;; character will experience point of being barely fertile and a point of being
;; extremely fertile.

;; Float FertilityWindow
;; multiplier of fertility chance. if the baseline chance is 50%, a window of
;; 2.0 will half 50% in the low time and double it in the high time.

;; Bool FertilitySync
;; followers will slowly sync their fertility cycles to match the players...

;; Array Sliders.Gems [ { "Name":"Breasts", "Max":2.0 }, ... ]
;; sliders for bodymorphs. this example means at 100% preg the breasts will be
;; augmented by 2.0 as if you moved the slider in racemenu yourself. you can
;; add as many or as few sliders as you want.

;; Array Sliders.Milk
;; sliders for bodymorphs. same format as Sliders.Gems.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Event OnInit()
{handle resetting the mod configuration during initization and reset.}

	If(Main.IsStopped())
		Main.Util.PrintDebug("Aborting Config Init: Controller is not running.")
		Return
	EndIf
	
	self.ReloadConfigFile()
	Main.Data.GemStagePopulate()

	Main.Util.PrintDebug("Config File Loaded")
	Return
EndEvent

Function ReloadConfigFile()
{force a refresh of the json config without saving any changes.}

	JsonUtil.Unload(self.FileConfig,FALSE,FALSE)
	JsonUtil.Load(self.FileConfig)

	JsonUtil.Unload(self.FileCustom,FALSE,FALSE)
	JsonUtil.Load(self.FileCustom)

	Return
EndFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Function LoadFiles()

	Return
EndFunction

Bool Function GetBool(String Path, Bool Default=FALSE)
{fetch an boolean from the json config.}

	If(!Default)
		If(JsonUtil.IsPathNumber(self.FileCustom,Path) || JsonUtil.IsPathBool(self.FileCustom,Path))
			Return JsonUtil.GetPathBoolValue(self.FileCustom,Path)
		EndIf
	EndIf

	Return JsonUtil.GetPathBoolValue(self.FileConfig,Path)
EndFunction

Int Function GetInt(String Path, Bool Default=FALSE)
{fetch an integer from the json config.}

	If(!Default)
		If(JsonUtil.IsPathNumber(self.FileCustom,Path))
			Return JsonUtil.GetPathIntValue(self.FileCustom,Path)
		EndIf
	EndIf

	Return JsonUtil.GetPathIntValue(self.FileConfig,Path)
EndFunction

Float Function GetFloat(String Path, Bool Default=FALSE)
{fetch an float from the json config.}

	If(!Default)
		If(JsonUtil.IsPathNumber(self.FileCustom,Path))
			Return JsonUtil.GetPathFloatValue(self.FileCustom,Path)
		EndIf
	EndIf

	Return JsonUtil.GetPathFloatValue(self.FileConfig,Path)
EndFunction

String Function GetString(String Path, Bool Default=FALSE)
{fetch a string from the json config.}

	If(!Default)
		If(JsonUtil.IsPathString(self.FileCustom,Path))
			Return JsonUtil.GetPathStringValue(self.FileCustom,Path)
		EndIf
	EndIf

	Return JsonUtil.GetPathStringValue(self.FileConfig,Path)
EndFunction

Int Function GetCount(String Path, Bool Default=FALSE)
{fetch how many items are in the specified thing. you should probably only
use this on arrays.}

	If(!Default)
		If(JsonUtil.CanResolvePath(self.FileCustom,Path))
			Return JsonUtil.PathCount(self.FileCustom,Path)
		EndIf
	EndIf

	Return JsonUtil.PathCount(self.FileConfig,Path)
EndFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; JContainers version of JSON reading.

;/*
Function LoadFiles()

	Int FP = JValue.ReadFromFile("Data/configs/dse-soulgem-oven/settings/Default.json")
	JDB.setObj("SGO4Config",FP)
	Main.Util.PrintDebug("JC Config File: " + FP)

	Return
EndFunction

Bool Function GetBool(String Path)
{fetch an boolean from the json config.}

	Bool Val = JDB.solveInt(".SGO4Config" + Path) AS Bool

	Main.Util.PrintDebug("Config.GetBoolJC Default " + Path + " " + Val)

	Return Val
EndFunction

Int Function GetInt(String Path)
{fetch an integer from the json config.}

	Int Val = JDB.solveInt(".SGO4Config" + Path)

	Main.Util.PrintDebug("Config.GetIntJC Default " + Path + " " + Val)

	Return Val
EndFunction

Float Function GetFloat(String Path)
{fetch an float from the json config.}

	Float Val = JDB.solveFlt(".SGO4Config" + Path)

	Main.Util.PrintDebug("Config.GetFloatJC Default " + Path + " " + Val)

	Return Val
EndFunction

String Function GetString(String Path)
{fetch a string from the json config.}

	String Val = JDB.solveStr(".SGO4Config" + Path)

	Main.Util.PrintDebug("Config.GetStringJC Default " + Path + " " + Val)

	Return Val
EndFunction

Int Function GetCount(String Path)
{fetch how many items are in the specified thing. you should probably only
use this on arrays.}

	Int DP = JDB.solveObj(".SGO4Config" + Path)
	Int Val = JValue.Count(DP)

	Main.Util.PrintDebug("Config.GetCountJC Default " + Path + " " + Val)

	Return Val
EndFunction
*/;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Bool Function SetBool(String Path, Bool Value)

	JsonUtil.SetPathIntValue(self.FileCustom,Path,(Value as Int))
	JsonUtil.Save(self.FileCustom)
	
	Return Value
EndFunction

Int Function SetInt(String Path, Int Value)

	JsonUtil.SetPathIntValue(self.FileCustom,Path,Value)
	JsonUtil.Save(self.FileCustom)
	
	Return Value
EndFunction

Float Function SetFloat(String Path, Float Value)

	JsonUtil.SetPathFloatValue(self.FileCustom,Path,Value)
	JsonUtil.Save(self.FileCustom)
	
	Return Value
EndFunction

String Function SetString(String Path, String Value)

	JsonUtil.SetPathStringValue(self.FileCustom,Path,Value)
	JsonUtil.Save(self.FileCustom)
	
	Return Value
EndFunction

Function DeletePath(String Path)

	Main.Util.PrintDebug("Config.DeletePath " + Path)

	;; can resolve doesn't seem to return true unless it resolves into
	;; a datatype papyrus can digest.

	If(JsonUtil.CanResolvePath(self.FileCustom,Path) || JsonUtil.IsPathObject(self.FileCustom,Path))
		Main.Util.PrintDebug("JsonUtil.ClearPath " + Path)
		JsonUtil.ClearPath(self.FileCustom,Path)
	EndIf

	Return
EndFunction
