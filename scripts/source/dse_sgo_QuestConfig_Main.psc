ScriptName dse_sgo_QuestConfig_Main extends Quest

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

dse_sgo_QuestController_Main Property Main Auto
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Bool Property DebugMode = TRUE Auto Hidden

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

String Property FileConfig = "../../../interface/dse-soulgem-oven/config.json" AutoReadOnly Hidden

;; Float UpdateLoopDelay: how long it waits between calculations of tracked actors.
;; Int ActorGemsMax: how many gems can be incubated at one time per actor.
;; Int ActorMilkMax: how many bottes of milk can be carried per actor.
;; Int ActorSemenMax: how many bottles of semen can be carried per actor.
;; Int BirthFilledGems: 1 = filled, 0 = unfilled, -1 = custom birth list (todo)
;; Float MilkPregPercent: how far along pregnancy has to be before milk production starts.
;; Array Sliders.Gems: sliders for bodymorphs
;; Array Sliders.Milk: sliders for bodymorphs

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

	Return
EndFunction

Bool Function GetBool(String Path)
{fetch an integer from the json config.}

	Return JsonUtil.GetPathBoolValue(self.FileConfig,Path)
EndFunction

Int Function GetInt(String Path)
{fetch an integer from the json config.}

	Return JsonUtil.GetPathIntValue(self.FileConfig,Path)
EndFunction

Float Function GetFloat(String Path)
{fetch an float from the json config.}

	Return JsonUtil.GetPathFloatValue(self.FileConfig,Path)
EndFunction

String Function GetString(String Path)
{fetch a string from the json config.}

	Return JsonUtil.GetPathStringValue(self.FileConfig,Path)
EndFunction

Int Function GetCount(String Path)
{fetch how many items are in the specified thing. you should probably only
use this on arrays.}

	Return JsonUtil.PathCount(self.FileConfig,Path)
EndFunction
