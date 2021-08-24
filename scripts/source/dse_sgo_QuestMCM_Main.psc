Scriptname dse_sgo_QuestMCM_Main extends SKI_ConfigBase

dse_sgo_QuestController_Main Property Main Auto

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Int Function GetVersion()
	Return 1
EndFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Event OnGameReload()
{things to do when the game is loaded from disk.}

	String ErrorConfig = JsonUtil.GetErrors(Main.Config.FileConfig)
	String ErrorCustom = JsonUtil.GetErrors(Main.Config.FileCustom)

	parent.OnGameReload()
	self.OnGameReload_CacheSettings()

	Main.Config.LoadFiles()

	Main.Data.RaceLoadFiles()
	;; do a dependency check every launch.
	;;Main.ResetMod_Prepare()

	If(ErrorConfig != "" || ErrorCustom != "")
		If(ErrorConfig != "")
			Main.Util.PrintDebug("ERROR FileConfig: " + ErrorConfig)
		EndIf
		If(ErrorCustom != "")
			Main.Util.PrintDebug("ERROR FileCustom: " + ErrorCustom)
		EndIf
	EndIf

	Main.UnregisterForMenu("Sleep/Wait Menu")
	Main.RegisterForMenu("Sleep/Wait Menu")

	self.OnGameReload_CopySliderData()

	;; add books to vendors.
	Main.InstallVendorItems()

	Return
EndEvent

Function OnGameReload_CacheSettings()
{there are a few settings for a few libraries that i want to cache as local
properties as a way to optimise their read time because they are used very
very very frequently. seeeding them on gameload because i elect to support
people editing their json by hand and reloading the game.}

	

	Return
EndFunction

Function OnGameReload_CopySliderData()
{copy the default slider data into the custom user config if they have not yet
defined any configuration.}

	Bool Bootstrap = FALSE

	If(!JsonUtil.IsPathObject(Main.Config.FileCustom,Main.Body.KeySliders))
		Bootstrap = TRUE
	EndIf

	If(!JsonUtil.IsPathArray(Main.Config.FileCustom,Main.Body.KeySlidersGems))
		Bootstrap = TRUE
	EndIf

	If(!JsonUtil.IsPathArray(Main.Config.FileCustom,Main.Body.KeySlidersMilk))
		Bootstrap = TRUE
	EndIf

	;;;;;;;;

	If(Bootstrap)
		Main.Body.SliderConfigDefault()
	EndIf

	Return
EndFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

String PageCurrentKey

Event OnConfigInit()
{things to do when the menu initalises (is opening)}

	self.Pages = new String[9]

	self.Pages[0] = "$SGO4_Menu_Databank"
	;; sgo actor tracking data.
	
	self.Pages[1] = "$SGO4_Menu_General"
	;; info, enable/disable, uninstall.

	self.Pages[2] = "$SGO4_Menu_Gameplay"
	;; gameplay settings

	self.Pages[3] = "$SGO4_Menu_Integration"
	;; Integration settings	

	self.Pages[4] = "$SGO4_Menu_GemSliders"
	;; pregnancy sliders

	self.Pages[5] = "$SGO4_Menu_MilkSliders"
	;; milking sliders

	self.Pages[6] = "$SGO4_Menu_Widgets"
	;; widget settings utilities

	self.Pages[7] = "$SGO4_Menu_Debug"
	;; testing utilities

	self.Pages[8] = "$SGO4_Menu_Splash"
	;; splash screen

	Return
EndEvent

Event OnConfigOpen()
{things to do when the menu actually opens.}

	self.OnConfigInit()
	Return
EndEvent

Event OnConfigClose()
{things to do when the menu closes.}

	Int Ev

	Ev = ModEvent.Create("SGO4.Widget.Scanner.Update")
	ModEvent.Send(Ev)

	Return
EndEvent

Event OnPageReset(String Page)
{when a different tab is selected in the menu.}

	self.UnloadCustomContent()

	PageCurrentKey = Page

	If(Page == "$SGO4_Menu_General")
		self.ShowPageGeneral()
	ElseIf(Page == "$SGO4_Menu_Databank")
		self.ShowPageDatabank()
	ElseIf(Page == "$SGO4_Menu_Gameplay")
		self.ShowPageGameplay()
	ElseIf(Page == "$SGO4_Menu_Integration")
		self.ShowPageIntegration()		
	ElseIf(Page == "$SGO4_Menu_Widgets")
		self.ShowPageWidgets()
	ElseIf(Page == "$SGO4_Menu_GemSliders")
		self.ShowPageSliders("$SGO4_MenuTitle_GemSliders",Main.Body.KeySlidersGems)
	ElseIf(Page == "$SGO4_Menu_MilkSliders")
		self.ShowPageSliders("$SGO4_MenuTitle_MilkSliders",Main.Body.KeySlidersMilk)
	ElseIf(Page == "$SGO4_Menu_Debug")
		self.ShowPageDebug()
	Else
		self.ShowPageIntro()
	EndIf

	Return
EndEvent

;/*****************************************************************************
*****************************************************************************/;

Event OnOptionSelect(Int Item)
	Bool Val = FALSE
	Int Data = -1
	Actor Who = Game.GetCurrentCrosshairRef() as Actor

	If(Who == None)
		Who = Main.Player
	EndIf

	;;;;;;;;

	If(Item == ItemDebugPlayerGemsEmpty)
		Val = TRUE
		Main.Data.ActorWeightSet(Who,0.0)
		Main.Data.ActorGemClear(Who)
		Main.Util.PrintDebug(Who.GetDisplayName() + " has been emptied of their gems.")

	;;;;;;;;

	ElseIf(Item == ItemDebugPlayerGemsMin)
		Val = TRUE
		Main.Data.ActorGemClear(Who)
		Main.Data.ActorWeightSet(Who,0.0)
		While(Main.Data.ActorGemAdd(Who,0.0))
		EndWhile
		Main.Util.PrintDebug(Who.GetDisplayName() + " has been filled with min level gems.")

	;;;;;;;;

	ElseIf(Item == ItemDebugPlayerGemsHalf)
		Val = TRUE
		Main.Data.ActorGemClear(Who)
		Main.Data.ActorWeightSet(Who,0.5)
		While(Main.Data.ActorGemAdd(Who,(Main.Data.GemStageCount(Who)/2)))
		EndWhile
		Main.Util.PrintDebug(Who.GetDisplayName() + " has been filled with half level gems.")

	;;;;;;;;

	ElseIf(Item == ItemDebugPlayerGemsMax)
		Val = TRUE
		Main.Data.ActorGemClear(Who)
		Main.Data.ActorWeightSet(Who,1.0)
		While(Main.Data.ActorGemAdd(Who,Main.Data.GemStageCount(Who)))
		EndWhile
		Main.Util.PrintDebug(Who.GetDisplayName() + " has been filled with max level gems.")

	;;;;;;;;

	ElseIf(Item == ItemDebugPlayerMilkEmpty)
		Val = TRUE
		Main.Data.ActorMilkClear(Who)
		Main.Util.PrintDebug(Who.GetDisplayName() + " has been emptied of their milk.")

	;;;;;;;;

	ElseIf(Item == ItemDebugPlayerMilkHalf)
		Val = TRUE
		Main.Data.ActorMilkSet(Who,(Main.Data.ActorMilkMax(Who)/2))
		Main.Util.PrintDebug(Who.GetDisplayName() + " has been filled half way with milk.")

	;;;;;;;;

	ElseIf(Item == ItemDebugPlayerMilkMax)
		Val = TRUE
		Main.Data.ActorMilkSet(Who,Main.Data.ActorMilkMax(Who))
		Main.Util.PrintDebug(Who.GetDisplayName() + " has been filled full with milk.")

	;;;;;;;;

	ElseIf(Item == ItemDebugPlayerSemenEmpty)
		Val = TRUE
		Main.Data.ActorSemenClear(Who)
		Main.Util.PrintDebug(Who.GetDisplayName() + " has been emptied of their semen.")

	;;;;;;;;

	ElseIf(Item == ItemDebugPlayerSemenHalf)
		Val = TRUE
		Main.Data.ActorSemenSet(Who,(Main.Data.ActorSemenMax(Who)/2))
		Main.Util.PrintDebug(Who.GetDisplayName() + " has been filled half way with semen.")

	;;;;;;;;

	ElseIf(Item == ItemDebugPlayerSemenMax)
		Val = TRUE
		Main.Data.ActorSemenSet(Who,Main.Data.ActorSemenMax(Who))
		Main.Util.PrintDebug(Who.GetDisplayName() + " has been filled full with semen.")

	;;;;;;;;

	ElseIf(Item == ItemStripSexLabNormal)
		Val = TRUE
		self.SetToggleOptionValue(ItemStripSexLabForeplay,FALSE)
		self.SetToggleOptionValue(ItemStripBodyOnly,FALSE)
		self.SetToggleOptionValue(ItemStripNone,FALSE)
		Main.Config.SetBool(".ActorStripMode",Main.Config.StripModeSexLabNormal)

	ElseIf(Item == ItemStripSexLabForeplay)
		Val = TRUE
		self.SetToggleOptionValue(ItemStripSexLabNormal,FALSE)
		self.SetToggleOptionValue(ItemStripBodyOnly,FALSE)
		self.SetToggleOptionValue(ItemStripNone,FALSE)
		Main.Config.SetBool(".ActorStripMode",Main.Config.StripModeSexLabForeplay)

	ElseIf(Item == ItemStripBodyOnly)
		Val = TRUE
		self.SetToggleOptionValue(ItemStripSexLabForeplay,FALSE)
		self.SetToggleOptionValue(ItemStripSexLabNormal,FALSE)
		self.SetToggleOptionValue(ItemStripNone,FALSE)
		Main.Config.SetBool(".ActorStripMode",Main.Config.StripModeBodyOnly)

	ElseIf(Item == ItemStripNone)
		Val = TRUE
		self.SetToggleOptionValue(ItemStripSexLabForeplay,FALSE)
		self.SetToggleOptionValue(ItemStripSexLabNormal,FALSE)
		self.SetToggleOptionValue(ItemStripBodyOnly,FALSE)
		Main.Config.SetBool(".ActorStripMode",Main.Config.StripModeNone)

	;;;;;;;;

	ElseIf(Item == ItemMilkerProduce)
		Val = !Main.Config.GetBool(".MilkerProduce")
		Main.Config.SetBool(".MilkerProduce",Val)

	;;;;;;;;

	ElseIf(Item == ItemUpdateAfterWait)
		Val = !Main.Config.GetBool(".UpdateAfterWait")
		Main.Config.SetBool(".UpdateAfterWait",Val)

	ElseIf(Item == ItemDebug)
		Val = !Main.Config.DebugMode
		Main.Config.DebugMode = Val

	ElseIf(Item == ItemDatabankShowAll)
		Val = !Main.Config.GetBool(".DatabankShowAll")
		Main.Config.SetBool(".DatabankShowAll",Val)

	ElseIf(Item == ItemDatabankLoadedOnly)
		Val = !Main.Config.GetBool(".DatabankLoadedOnly")
		Main.Config.SetBool(".DatabankLoadedOnly",Val)

	ElseIf(Item == ItemFertilitySync)
		Val = !Main.Config.GetBool(".FertilitySync")
		Main.Config.SetBool(".FertilitySync",Val)

	ElseIf(Item == ItemMessagesPlayer)
		Val = !Main.Config.GetBool(".MessagesPlayer")
		Main.Config.SetBool(".MessagesPlayer",Val)

	ElseIf(Item == ItemMessagesNPC)
		Val = !Main.Config.GetBool(".MessagesNPC")
		Main.Config.SetBool(".MessagesNPC",Val)
		
	ElseIf(Item == ItemBirthGemsFilled)
		Val = !Main.Config.GetBool(".BirthGemsFilled")
		Main.Config.SetBool(".BirthGemsFilled",Val)
		Main.Data.GemStagePopulate()


	ElseIf(Item == ItemSoloMissionGivesSemen)
		Val = !Main.Config.GetBool(".SoloMissionGivesSemen")
		Main.Config.SetBool(".SoloMissionGivesSemen",Val)

	ElseIf(Item == ItemEnableExpressions)
		Val = !Main.Config.GetBool(".EnableExpressions")
		Main.Config.SetBool(".EnableExpressions",Val)

	ElseIf(Item == ItemMessagesInsemination)
		Val = !Main.Config.GetBool(".MessagesInsemination")
		Main.Config.SetBool(".MessagesInsemination",Val)

	ElseIf(Item == ItemFixFemaleToMaleImp)
		Val = !Main.Config.GetBool(".FixFemaleToMaleImp")
		Main.Config.SetBool(".FixFemaleToMaleImp",Val)

	ElseIf(Item == ItemMilkLeveling)
		Val = !Main.Config.GetBool(".MilkLeveling")
		Main.Config.SetBool(".MilkLeveling",Val)

	ElseIf(Item == ItemGemLeveling)
		Val = !Main.Config.GetBool(".GemLeveling")
		Main.Config.SetBool(".GemLeveling",Val)

	ElseIf(Item == ItemWeightIncreasesFertility)
		Val = !Main.Config.GetBool(".WeightIncreasesFertility")
		Main.Config.SetBool(".WeightIncreasesFertility",Val)

	ElseIf(Item == ItemOrgasmGrowsMilk)
		Val = !Main.Config.GetBool(".OrgasmGrowsMilk")
		Main.Config.SetBool(".OrgasmGrowsMilk",Val)

	ElseIf(Item == ItemOrgasmGrowsGems)
		Val = !Main.Config.GetBool(".OrgasmGrowsGems")
		Main.Config.SetBool(".OrgasmGrowsGems",Val)

	ElseIf(Item == ItemOrgasmIncreasesWeight)
		Val = !Main.Config.GetBool(".OrgasmIncreasesWeight")
		Main.Config.SetBool(".OrgasmIncreasesWeight",Val)

	ElseIf(Item == ItemEjaculationIncreasesWeight)
		Val = !Main.Config.GetBool(".EjaculationIncreasesWeight")
		Main.Config.SetBool(".EjaculationIncreasesWeight",Val)

	ElseIf(Item == ItemEjaculationGrowsGems)
		Val = !Main.Config.GetBool(".EjaculationGrowsGems")
		Main.Config.SetBool(".EjaculationGrowsGems",Val)

	ElseIf(Item == ItemOrgasmMilksMilk)
		Val = !Main.Config.GetBool(".OrgasmMilksMilk")
		Main.Config.SetBool(".OrgasmMilksMilk",Val)

	ElseIf(Item == ItemOrgasmMilksGivesMilk)
		Val = !Main.Config.GetBool(".OrgasmMilksGivesMilk")
		Main.Config.SetBool(".OrgasmMilksGivesMilk",Val)
		

	ElseIf(Item == ItemActorUpdateName)
		Val = !Main.Config.GetBool(".ActorUpdateName")
		Main.Config.SetBool(".ActorUpdateName",Val)

		If(!Val)
			Debug.MessageBox(Main.Util.StringLookup("OnActorUpdateNameDisabled"))
		Else
			Debug.MessageBox(Main.Util.StringLookup("OnActorUpdateNameEnabled"))
		EndIf

	;;;;;;;;

	ElseIf(Item == ItemModStatus)
		Debug.MessageBox(Main.Util.StringLookup("SoulgemOvenStartCloseMenu"))
		Utility.Wait(0.1)

		If(Main.IsRunning())
			Main.Reset()
			Main.Stop()
			Main.Util.Print("Shutting down.")
		Else
			Main.Start()
		EndIf

		Return

	;;;;;;;;

	EndIf

	self.SetToggleOptionValue(Item,Val)
	Return
EndEvent

;/*****************************************************************************
*****************************************************************************/;

Event OnOptionSliderOpen(Int Item)
	Float Val = 0.0
	Float Min = 0.0
	Float Max = 0.0
	Float Interval = 0.0

	If(Item == ItemWidgetOffsetX)
		Val = Main.Config.GetFloat(".WidgetOffsetX")
		Min = 0.0
		Max = 1280.0
		Interval = 0.1
	ElseIf(Item == ItemWidgetOffsetY)
		Val = Main.Config.GetFloat(".WidgetOffsetY")
		Min = 0.0
		Max = 720.0
		Interval = 0.1
	ElseIf(Item == ItemWidgetScale)
		Val = Main.Config.GetFloat(".WidgetScale")
		Min = 0.1
		Max = 1.0
		Interval = 0.05
	ElseIf(Item == ItemActorGemsMax)
		Val = Main.Config.GetFloat(".ActorGemsMax")
		Min = 1.0
		Max = 12.0
		Interval = 1.0
	ElseIf(Item == ItemActorMilkMax)
		Val = Main.Config.GetFloat(".ActorMilkMax")
		Min = 1.0
		Max = 4.0
		Interval = 1.0
	ElseIf(Item == ItemActorSemenMax)
		Val = Main.Config.GetFloat(".ActorSemenMax")
		Min = 1.0
		Max = 3.0
		Interval = 1.0
	ElseIf(Item == ItemInfluenceMilkSpeech)
		Val = Main.Config.GetFloat(".InfluenceMilkSpeech")
		Min = -50.0
		Max = 50.0
		Interval = 1.0
	ElseIf(Item == ItemInfluenceMilkSpeechExposed)
		Val = Main.Config.GetFloat(".InfluenceMilkSpeechExposed")
		Min = -20.0
		Max = 20.0
		Interval = 1.0
	ElseIf(Item == ItemInfluenceGemsHealth)
		Val = Main.Config.GetFloat(".InfluenceGemsHealth")
		Min = -150.0
		Max = 150.0
		Interval = 1.0
	ElseIf(Item == ItemInfluenceGemsMagicka)
		Val = Main.Config.GetFloat(".InfluenceGemsMagicka")
		Min = -150.0
		Max = 150.0
		Interval = 1.0
	ElseIf(Item == ItemGemsPerDay)
		Val = Main.Config.GetFloat(".GemsPerDay")
		Min = 0.05
		Max = Main.Data.GemStageCount(None)
		Interval = 0.05
	ElseIf(Item == ItemMilksPerDay)
		Val = Main.Config.GetFloat(".MilksPerDay")
		Min = 0.05
		Max = 6.0
		Interval = 0.05
	ElseIf(Item == ItemMilksPregPercent)
		Val = Main.Config.GetFloat(".MilksPregPercent")
		Min = 1.0
		Max = 100.0
		Interval = 1.0
	ElseIf(Item == ItemMilksPassiveLoss)
		Val = (Main.Config.GetFloat(".MilksPassiveLoss") * 100)
		Min = 0.0
		Max = 100.0
		Interval = 1.0
	ElseIf(Item == ItemMilkerRate)
		Val = (Main.Config.GetFloat(".MilkerRate") * 100)
		Min = 0.0
		Max = 100.0
		Interval = 1.0
	ElseIf(Item == ItemUpdateLoopFreq)
		Val = Main.Config.GetFloat(".UpdateLoopFreq")
		Min = 10.0
		Max = 300.0
		Interval = 0.5
	ElseIf(Item == ItemUpdateLoopDelay)
		Val = Main.Config.GetFloat(".UpdateLoopDelay")
		Min = 0.05
		Max = 2.0
		Interval = 0.05
	ElseIf(Item == ItemUpdateGameHours)
		Val = Main.Config.GetFloat(".UpdateGameHours")
		Min = 0.5
		Max = 2.0
		Interval = 0.1
	ElseIf(Item == ItemActorWeightDaysDrain)
		Val = Main.Config.GetFloat(".ActorWeightDaysDrain")
		Min = 0.0
		Max = 10.0
		Interval = 0.05
	ElseIf(Item == ItemInfluenceGemsWhen)
		Val = Main.Config.GetFloat(".InfluenceGemsWhen")
		Min = 0.01
		Max = 1.0
		Interval = 0.01
	ElseIf(Item == ItemInfluenceMilkWhen)
		Val = Main.Config.GetFloat(".InfluenceMilkWhen")
		Min = 0.01
		Max = 1.0
		Interval = 0.01
	ElseIf(Item == ItemFertilityChance)
		Val = Main.Config.GetFloat(".FertilityChance")
		Min = -100.0
		Max = 100.0
		Interval = 1.0
	ElseIf(Item == ItemFertilityDays)
		Val = Main.Config.GetFloat(".FertilityDays")
		Min = 1.0
		Max = 30.0
		Interval = 1.0
	ElseIf(Item == ItemFertilityWindow)
		Val = Main.Config.GetFloat(".FertilityWindow")
		Min = 1.0
		Max = 3.0
		Interval = 0.1
	ElseIf(Item == ItemLevelAlchFactor)
		Val = Main.Config.GetFloat(".LevelAlchFactor")
		Min = 0.0
		Max = 2.0
		Interval = 0.1
	ElseIf(Item == ItemLevelEnchFactor)
		Val = Main.Config.GetFloat(".LevelEnchFactor")
		Min = 0.0
		Max = 2.0
		Interval = 0.1
	ElseIf(Item == ItemLevelValueBase)
		Val = Main.Config.GetFloat(".LevelValueBase")
		Min = 0.0
		Max = 200.0
		Interval = 1.0
	ElseIf(Item == ItemSemensPerDay)
		Val = Main.Config.GetFloat(".SemensPerDay")
		Min = 0.0
		Max = 10.0
		Interval = 1.0		
	ElseIf(Item == ItemActorWeightDaysGain)
		Val = Main.Config.GetFloat(".ActorWeightDaysGain")
		Min = 1
		Max = 30
		Interval = 1
	ElseIf(Item == ItemWeightGainPregPercent)
		Val = Main.Config.GetFloat(".WeightGainPregPercent")
		Min = 1
		Max = 100
		Interval = 1
	ElseIf(Item == ItemSemenBase)
		Val = Main.Config.GetFloat(".SemenBase")
		Min = 0
		Max = 100
		Interval = 1
	ElseIf(Item == ItemMilkOverlayPercentage)
		Val = Main.Config.GetFloat(".MilkOverlayPercentage")
		Min = 1
		Max = 100
		Interval = 1
	ElseIf(Item == ItemMilkLevelingCapacityMult)
		Val = Main.Config.GetFloat(".MilkLevelingCapacityMult")
		Min = 0.0
		Max = 1.0
		Interval = 0.001
	ElseIf(Item == ItemMilkLevelingCapacityMultCap)
		Val = Main.Config.GetFloat(".MilkLevelingCapacityMultCap")
		Min = 0
		Max = 10.0
		Interval = 0.01
	ElseIf(Item == ItemMilkLevelingGainMult)
		Val = Main.Config.GetFloat(".MilkLevelingGainMult")
		Min = 0
		Max = 1.0
		Interval = 0.001
	ElseIf(Item == ItemMilkLevelingGainMultCap)
		Val = Main.Config.GetFloat(".MilkLevelingGainMultCap")
		Min = 0
		Max = 10.0
		Interval = 0.01
	ElseIf(Item == ItemGemLevelingCap)
		Val = Main.Config.GetInt(".GemLevelingCap")
		Min = 1
		Max = 6
		Interval = 1
	ElseIf(Item == ItemGemLevelingThreshold)
		Val = Main.Config.GetInt(".GemLevelingThreshold")
		Min = 1
		Max = 50
		Interval = 1
	ElseIf(Item == ItemGemLevelingRatePenalty)
		Val = Main.Config.GetFloat(".GemLevelingRatePenalty")
		Min = 0.5
		Max = 1.0
		Interval = 0.01
	ElseIf(Item == ItemGemLevelingStatsMult)
		Val = Main.Config.GetFloat(".GemLevelingStatsMult")
		Min = 0.0
		Max = 1.0
		Interval = 0.01
	ElseIf(Item == ItemGemLevelingWeightMult)
		Val = Main.Config.GetFloat(".GemLevelingWeightMult")
		Min = 0.0
		Max = 1.0
		Interval = 0.01
	ElseIf(Item == ItemWeightFertilityBonus)
		Val = Main.Config.GetFloat(".WeightFertilityBonus")
		Min = 0
		Max = 100
		Interval = 1
	ElseIf(Item == ItemOrgasmGrowsMilkAmount)
		Val = Main.Config.GetFloat(".OrgasmGrowsMilkAmount")
		Min = 0.0
		Max = 1.0
		Interval = 0.1
	ElseIf(Item == ItemOrgasmGrowsGemsAmount)
		Val = Main.Config.GetFloat(".OrgasmGrowsGemsAmount")
		Min = 0.0
		Max = 1.0
		Interval = 0.01
	ElseIf(Item == ItemOrgasmIncreasesWeightAmount)
		Val = Main.Config.GetFloat(".OrgasmIncreasesWeightAmount")
		Min = 0.0
		Max = 1.0
		Interval = 0.01
	ElseIf(Item == ItemEjaculationIncreasesWeightAmount)
		Val = Main.Config.GetFloat(".EjaculationIncreasesWeightAmount")
		Min = 0.0
		Max = 1.0
		Interval = 0.01
	ElseIf(Item == ItemEjaculationGrowsGemsAmount)
		Val = Main.Config.GetFloat(".EjaculationGrowsGemsAmount")
		Min = 0.0
		Max = 1.0
		Interval = 0.01
	ElseIf(Item == ItemOrgasmMilksThreshold)
		Val = Main.Config.GetFloat(".OrgasmMilksThreshold")
		Min = 1
		Max = 100.0
		Interval = 1

		
	ElseIf(PageCurrentKey == "$SGO4_Menu_GemSliders" || PageCurrentKey == "$SGO4_Menu_MilkSliders")

		Int ItemCount = ItemSliderVal.Length
		
		While(ItemCount > 0)
			ItemCount -= 1

			If(ItemSliderVal[ItemCount] == Item)
				Val = Main.Body.SliderValueByOffset(ItemSliderType,ItemCount)
				ItemCount = 0
			EndIf

		EndWhile

		Min = -3.0
		Max = 3.0
		Interval = 0.05
	EndIf

	SetSliderDialogStartValue(Val)
	SetSliderDialogRange(Min,Max)
	SetSliderDialogInterval(Interval)
	Return
EndEvent

;/*****************************************************************************
*****************************************************************************/;

Event OnOptionSliderAccept(Int Item, Float Val)
	String Fmt = "{0}"

	If(Item == ItemWidgetOffsetX)
		Fmt = "{1}"
		Main.Config.SetFloat(".WidgetOffsetX",Val)
	ElseIf(Item == ItemWidgetOffsetY)
		Fmt = "{1}"
		Main.Config.SetFloat(".WidgetOffsetY",Val)
	ElseIf(Item == ItemWidgetScale)
		Fmt = "{2}"
		Main.Config.SetFloat(".WidgetScale",Val)
	ElseIf(Item == ItemActorGemsMax)
		Fmt = "{0}"
		Main.Config.SetInt(".ActorGemsMax",(Val as Int))
	ElseIf(Item == ItemActorMilkMax)
		Fmt = "{0}"
		Main.Config.SetInt(".ActorMilkMax",(Val as Int))
	ElseIf(Item == ItemActorSemenMax)
		Fmt = "{0}"
		Main.Config.SetInt(".ActorSemenMax",(Val as Int))
	ElseIf(Item == ItemInfluenceMilkSpeech)
		Fmt = "{0}"
		Main.Config.SetFloat(".InfluenceMilkSpeech",Val)
	ElseIf(Item == ItemInfluenceMilkSpeechExposed)
		Fmt = "{0}"
		Main.Config.SetFloat(".InfluenceMilkSpeechExposed",Val)
	ElseIf(Item == ItemInfluenceGemsHealth)
		Fmt = "{0}"
		Main.Config.SetFloat(".InfluenceGemsHealth",Val)
	ElseIf(Item == ItemInfluenceGemsMagicka)
		Fmt = "{0}"
		Main.Config.SetFloat(".InfluenceGemsMagicka",Val)
	ElseIf(Item == ItemGemsPerDay)
		Fmt = "{2}"
		Main.Config.SetFloat(".GemsPerDay",Val)
	ElseIf(Item == ItemMilksPerDay)
		Fmt = "{2}"
		Main.Config.SetFloat(".MilksPerDay",Val)
	ElseIf(Item == ItemMilksPregPercent)
		Fmt = "{0}%"
		Main.Config.SetFloat(".MilksPregPercent",Val)
	ElseIf(Item == ItemMilksPassiveLoss)
		Fmt = "{0}%"
		Main.Config.SetFloat(".MilksPassiveLoss",(Val / 100.0))
	ElseIf(Item == ItemMilkerRate)
		Fmt = "{0}%"
		Main.Config.SetFloat(".MilkerRate",(Val / 100.0))
	ElseIf(Item == ItemUpdateLoopFreq)
		Fmt = "{2} sec"
		Main.Config.SetFloat(".UpdateLoopFreq",Val)
	ElseIf(Item == ItemUpdateLoopDelay)
		Fmt = "{2} sec"
		Main.Config.SetFloat(".UpdateLoopDelay",Val)
	ElseIf(Item == ItemUpdateGameHours)
		Fmt = "{1} hr"
		Main.Config.SetFloat(".UpdateGameHours",Val)
	ElseIf(Item == ItemActorWeightDaysDrain)
		Fmt = "{2}"
		Main.Config.SetFloat(".ActorWeightDaysDrain",Val)

	ElseIf(Item == ItemInfluenceGemsWhen)
		Fmt = "{0}"
		Main.Config.SetFloat(".InfluenceGemsWhen",Val)
	ElseIf(Item == ItemInfluenceMilkWhen)
		Fmt = "{0}"
		Main.Config.SetFloat(".InfluenceMilkWhen",Val)
	ElseIf(Item == ItemFertilityChance)
		Fmt = "{0}"
		Main.Config.SetFloat(".FertilityChance",Val)
	ElseIf(Item == ItemFertilityDays)
		Fmt = "{0}"
		Main.Config.SetFloat(".FertilityDays",Val)
	ElseIf(Item == ItemFertilityWindow)
		Fmt = "{0}"
		Main.Config.SetFloat(".FertilityWindow",Val)
	ElseIf(Item == ItemLevelAlchFactor)
		Fmt = "{0}"
		Main.Config.SetFloat(".LevelAlchFactor",Val)
	ElseIf(Item == ItemLevelEnchFactor)
		Fmt = "{0}"
		Main.Config.SetFloat(".LevelEnchFactor",Val)
	ElseIf(Item == ItemLevelValueBase)
		Fmt = "{0}"
		Main.Config.SetFloat(".LevelValueBase",Val)
	ElseIf(Item == ItemSemensPerDay)
		Fmt = "{0}"
		Main.Config.SetFloat(".SemensPerDay",Val)		

	ElseIf(Item == ItemActorWeightDaysGain)
		Fmt = "{2}"
		Main.Config.SetFloat(".ActorWeightDaysGain",Val)
	ElseIf(Item == ItemWeightGainPregPercent)
		Fmt = "{0}"
		Main.Config.SetFloat(".WeightGainPregPercent",Val)
	ElseIf(Item == ItemSemenBase)
		Fmt = "{0}%"
		Main.Config.SetFloat(".SemenBase",Val)
	ElseIf(Item == ItemMilkOverlayPercentage)
		Fmt = "{0}%"
		Main.Config.SetFloat(".MilkOverlayPercentage",Val)
	ElseIf(Item == ItemMilkLevelingCapacityMult)
		Fmt = "{3}"
		Main.Config.SetFloat(".MilkLevelingCapacityMult",Val)
	ElseIf(Item == ItemMilkLevelingCapacityMultCap)
		Fmt = "{2}"
		Main.Config.SetFloat(".MilkLevelingCapacityMultCap",Val)
	ElseIf(Item == ItemMilkLevelingGainMult)
		Fmt = "{3}"
		Main.Config.SetFloat(".MilkLevelingGainMult",Val)
	ElseIf(Item == ItemMilkLevelingGainMultCap)
		Fmt = "{2}"
		Main.Config.SetFloat(".MilkLevelingGainMultCap",Val)
	ElseIf(Item == ItemGemLevelingCap)
		Fmt = "{0}"
		Main.Config.SetInt(".GemLevelingCap",Val as Int)
	ElseIf(Item == ItemGemLevelingThreshold)
		Fmt = "{0}"
		Main.Config.SetInt(".GemLevelingThreshold",Val as Int)		
	ElseIf(Item == ItemGemLevelingRatePenalty)
		Fmt = "{2}"
		Main.Config.SetFloat(".GemLevelingRatePenalty",Val)
	ElseIf(Item == ItemGemLevelingStatsMult)
		Fmt = "{2}"
		Main.Config.SetFloat(".GemLevelingStatsMult",Val)
	ElseIf(Item == ItemGemLevelingWeightMult)
		Fmt = "{2}"
		Main.Config.SetFloat(".GemLevelingWeightMult",Val)
	ElseIf(Item == ItemWeightFertilityBonus)
		Fmt = "{2}"
		Main.Config.SetFloat(".WeightFertilityBonus",Val)
	ElseIf(Item == ItemOrgasmGrowsMilkAmount)
		Fmt = "{2}"
		Main.Config.SetFloat(".OrgasmGrowsMilkAmount",Val)
	ElseIf(Item == ItemOrgasmGrowsGemsAmount)
		Fmt = "{2}"
		Main.Config.SetFloat(".OrgasmGrowsGemsAmount",Val)
	ElseIf(Item == ItemOrgasmIncreasesWeightAmount)
		Fmt = "{2}"
		Main.Config.SetFloat(".OrgasmIncreasesWeightAmount",Val)
	ElseIf(Item == ItemEjaculationIncreasesWeightAmount)
		Fmt = "{2}"
		Main.Config.SetFloat(".EjaculationIncreasesWeightAmount",Val)
	ElseIf(Item == ItemEjaculationGrowsGemsAmount)
		Fmt = "{2}"
		Main.Config.SetFloat(".EjaculationGrowsGemsAmount",Val)
	ElseIf(Item == ItemOrgasmMilksThreshold)
		Fmt = "{0}"
		Main.Config.SetFloat(".OrgasmMilksThreshold",Val)


	ElseIf(PageCurrentKey == "$SGO4_Menu_GemSliders" || PageCurrentKey == "$SGO4_Menu_MilkSliders")

		Int ItemCount = ItemSliderVal.Length
		String SliderPath
		
		While(ItemCount > 0)
			ItemCount -= 1

			If(ItemSliderVal[ItemCount] == Item)
				SliderPath = ItemSliderType + "[" + ItemCount + "].Max"
				Main.Config.SetFloat(SliderPath,Val)
				ItemCount = 0
			EndIf

			Fmt = "{2}"
		EndWhile
	EndIf

	SetSliderOptionValue(Item,Val,Fmt)
	Return
EndEvent

;/*****************************************************************************
*****************************************************************************/;

Event OnOptionMenuOpen(Int Item)

	String[] Opts
	Int Select = 0
	Int Iter

	If(Item == ItemWidgetAnchorH)
		Opts = Utility.CreateStringArray(3)
		Opts[0] = "left"
		Opts[1] = "center"
		Opts[2] = "right"

		Iter = Opts.Length
		While(Iter > 0)
			Iter -= 1
			If(Opts[Iter] == Main.Config.GetString(".WidgetAnchorH"))
				Select = Iter
				Iter = 0
			EndIf
		EndWhile

	ElseIf(Item == ItemWidgetAnchorV)
		Opts = Utility.CreateStringArray(3)
		Opts[0] = "top"
		Opts[1] = "center"
		Opts[2] = "bottom"

		Iter = Opts.Length
		While(Iter > 0)
			Iter -= 1
			If(Opts[Iter] == Main.Config.GetString(".WidgetAnchorV"))
				Select = Iter
				Iter = 0
			EndIf
		EndWhile

	ElseIf(Item == ItemSliderDel)
		self.OnOptionMenuOpen_SliderDelete(Item,ItemSliderType)
		Return
	ElseIf(Item == ItemSliderBelly)
		self.OnOptionMenuOpen_SliderBellySelect(Item,ItemSliderType)
		Return
	EndIf

	SetMenuDialogDefaultIndex(0)
	SetMenuDialogStartIndex(Select)
	SetMenuDialogOptions(Opts)
	Return
EndEvent

Function OnOptionMenuOpen_SliderDelete(Int Item, String SliderKey)

	Int SliderCount = Main.Config.GetCount(SliderKey)
	String[] Opts = Utility.CreateStringArray(SliderCount)
	Int Iter = 0

	;;Main.Util.PrintDebug("MenuOpenSliderDelete " + SliderCount + " " + SliderKey)

	Iter = 0
	While(Iter < SliderCount)
		Opts[Iter] = Main.Body.SliderNameByOffset(SliderKey,Iter)
		;;Main.Util.PrintDebug("MenuOpenSliderDeleteSlider " + Opts[Iter])
		Iter += 1
	EndWhile

	SetMenuDialogDefaultIndex(-1)
	SetMenuDialogStartIndex(0)
	SetMenuDialogOptions(Opts)
	Return
EndFunction

Function OnOptionMenuOpen_SliderBellySelect(Int Item, String SliderKey)

	Int SliderCount = Main.Config.GetCount(SliderKey)
	String[] Opts = Utility.CreateStringArray(SliderCount)
	Int Iter = 0

	Iter = 0
	While(Iter < SliderCount)
		Opts[Iter] = Main.Body.SliderNameByOffset(SliderKey,Iter)
		Iter += 1
	EndWhile

	SetMenuDialogDefaultIndex(-1)
	SetMenuDialogStartIndex(0)
	SetMenuDialogOptions(Opts)
	Return
EndFunction

;/*****************************************************************************
*****************************************************************************/;

Event OnOptionMenuAccept(Int Item, Int Selected)

	String Val = ""

	If(Item == ItemWidgetAnchorH)
		If(Selected == 0)
			Val = Main.Config.SetString(".WidgetAnchorH","left")
		ElseIf(Selected == 1)
			Val = Main.Config.SetString(".WidgetAnchorH","center")
		ElseIf(Selected == 2)
			Val = Main.Config.SetString(".WidgetAnchorH","right")
		EndIf

	ElseIf(Item == ItemWidgetAnchorV)
		If(Selected == 0)
			Val = Main.Config.SetString(".WidgetAnchorV","top")
		ElseIf(Selected == 1)
			Val = Main.Config.SetString(".WidgetAnchorV","center")
		ElseIf(Selected == 2)
			Val = Main.Config.SetString(".WidgetAnchorV","bottom")
		EndIf

	ElseIf(Item == ItemSliderDel)
		self.OnOptionMenuAccept_SliderDelete(Item,ItemSliderType,Selected)
		Return
	ElseIf(Item == ItemSliderBelly)
		self.OnOptionMenuAccept_SliderBellySelect(Item,ItemSliderType,Selected)
		Return
	EndIf

	SetMenuOptionValue(Item,Val)
	Return
EndEvent

Function OnOptionMenuAccept_SliderDelete(Int Item, String SliderKey, Int SliderOffset)

	Main.Util.PrintDebug("SliderDelete " + SliderKey + " = " + SliderOffset)
	Main.Body.SliderDeleteByOffset(SliderKey,SliderOffset)
	self.ForcePageReset()

	Return
EndFunction

Function OnOptionMenuAccept_SliderBellySelect(Int Item, String SliderKey, Int SliderOffset)

	Main.Util.PrintDebug("SliderBelly " + SliderKey + " = " + SliderOffset)
	Main.Config.SetString(Main.Body.KeySliderBelly,Main.Body.SliderNameByOffset(SliderKey,SliderOffset))
	self.ForcePageReset()

	Return
EndFunction

;/*****************************************************************************
*****************************************************************************/;

Event OnOptionInputOpen(Int Opt)

	Return
EndEvent

;/*****************************************************************************
*****************************************************************************/;

Event OnOptionInputAccept(Int Opt, String Txt)
	
	If(Opt == ItemSliderAdd)
		If(PageCurrentKey == "$SGO4_Menu_GemSliders")
			Main.Body.SliderAdd(Main.Body.KeySlidersGems,Txt)
			self.ForcePageReset()
		ElseIf(PageCurrentKey == "$SGO4_Menu_MilkSliders")
			Main.Body.SliderAdd(Main.Body.KeySlidersMilk,Txt)
			self.ForcePageReset()
		EndIf
	EndIf

	Return
EndEvent

;/*****************************************************************************
*****************************************************************************/;

Event OnOptionHighlight(Int Item)
	
	String Txt = "$SGO4_Mod_TitleFull"

	If(Item == ItemWidgetOffsetX)
		Txt = "$SGO4_MenuTip_WidgetOffsetX"
	ElseIf(Item == ItemWidgetOffsetY)
		Txt = "$SGO4_MenuTip_WidgetOffsetY"
	ElseIf(Item == ItemWidgetAnchorH)
		Txt = "$SGO4_MenuTip_WidgetAnchorH"
	ElseIf(Item == ItemWidgetAnchorV)
		Txt = "$SGO4_MenuTip_WidgetAnchorV"
	ElseIf(Item == ItemWidgetScale)
		Txt = "$SGO4_MenuTip_WidgetScale"
	ElseIf(Item == ItemModStatus)
		Txt = "$SGO4_MenuTip_IsModActive"
	ElseIf(Item == ItemInfluenceMilkSpeech)
		Txt = "$SGO4_MenuTip_InfluenceMilkSpeech"
	ElseIf(Item == ItemInfluenceMilkSpeechExposed)
		Txt = "$SGO4_MenuTip_InfluenceMilkSpeechExposed"
	ElseIf(Item == ItemInfluenceGemsHealth)
		Txt = "$SGO4_MenuTip_InfluenceGemsHealth"
	ElseIf(Item == ItemInfluenceGemsMagicka)
		Txt = "$SGO4_MenuTip_InfluenceGemsMagicka"
	ElseIf(Item == ItemStripSexLabNormal)
		Txt = "$SGO4_MenuTip_StripMode"
	ElseIf(Item == ItemStripSexLabForeplay)
		Txt = "$SGO4_MenuTip_StripMode"
	ElseIf(Item == ItemStripBodyOnly)
		Txt = "$SGO4_MenuTip_StripMode"
	ElseIf(Item == ItemStripNone)
		Txt = "$SGO4_MenuTip_StripMode"
	ElseIf(Item == ItemGemsPerDay)
		Txt = "$SGO4_MenuTip_GemsPerDay"
	ElseIf(Item == ItemMilksPerDay)
		Txt = "$SGO4_MenuTip_MilksPerDay"
	ElseIf(Item == ItemMilksPassiveLoss)
		Txt = "$SGO4_MenuTip_MilksPassiveLoss"
	ElseIf(Item == ItemUpdateLoopFreq)
		Txt = "$SGO4_MenuTip_UpdateLoopFreq"
	ElseIf(Item == ItemUpdateLoopDelay)
		Txt = "$SGO4_MenuTip_UpdateLoopDelay"
	ElseIf(Item == ItemUpdateGameHours)
		Txt = "$SGO4_MenuTip_UpdateGameHours"
	ElseIf(Item == ItemMilksPregPercent)
		Txt = "$SGO4_MenuTip_MilksPregPercent"
	ElseIf(Item == ItemMilksPassiveLoss)
		Txt = "$SGO4_MenuTip_MilksPassiveLoss"
	ElseIf(Item == ItemMilkerProduce)
		Txt = "$SGO4_MenuTip_MilkerProduce"
	ElseIf(Item == ItemMilkerRate)
		Txt = "$SGO4_MenuTip_MilkerRate"
	ElseIf(Item == ItemUpdateAfterWait)
		Txt = "$SGO4_MenuTip_UpdateAfterWait"
	ElseIf(Item == ItemDebug)
		Txt = "$SGO4_MenuTip_Debug"
	ElseIf(Item == ItemDatabankShowAll)
		Txt = "$SGO4_MenuTip_DatabankShowAll"
	ElseIf(Item == ItemDatabankShowAll)
		Txt = "$SGO4_MenuTip_DatabankLoadedOnly"
	ElseIf(Item == ItemActorUpdateName)
		Txt = "$SGO4_MenuTip_ActorUpdateName"
	ElseIf(Item == ItemActorWeightDaysDrain)
		Txt = "$SGO4_MenuTip_ActorWeightDaysDrain"
	ElseIf(Item == ItemFertilitySync)
		Txt = "$SGO4_MenuTip_FertilitySync"
	ElseIf(Item == ItemDebugIsActorTracked)
		Txt = "$SGO4_MenuOpt_DebugIsActorTracked"
	ElseIf(Item == ItemMessagesPlayer)
		Txt = "$SGO4_MenuTip_MessagesPlayer"
	ElseIf(Item == ItemMessagesNPC)
		Txt = "$SGO4_MenuTip_MessagesNPC"

	ElseIf(Item == ItemBirthGemsFilled)
		Txt = "$SGO4_MenuTip_ItemBirthGemsFilled"
	ElseIf(Item == ItemInfluenceGemsWhen)
		Txt = "$SGO4_MenuTip_ItemInfluenceGemsWhen"
	ElseIf(Item == ItemInfluenceMilkWhen)
		Txt = "$SGO4_MenuTip_ItemInfluenceMilkWhen"
	ElseIf(Item == ItemFertilityChance)
		Txt = "$SGO4_MenuTip_ItemFertilityChance"
	ElseIf(Item == ItemFertilityDays)
		Txt = "$SGO4_MenuTip_ItemFertilityDays"
	ElseIf(Item == ItemFertilityWindow)
		Txt = "$SGO4_MenuTip_ItemFertilityWindow"
	ElseIf(Item == ItemLevelAlchFactor)
		Txt = "$SGO4_MenuTip_ItemLevelAlchFactor"
	ElseIf(Item == ItemLevelEnchFactor)
		Txt = "$SGO4_MenuTip_ItemLevelEnchFactor"
	ElseIf(Item == ItemLevelValueBase)
		Txt = "$SGO4_MenuTip_ItemLevelValueBase"
	ElseIf(Item == ItemMilksPregPercent)
		Txt = "$SGO4_MenuTip_ItemMilksPregPercent"
	ElseIf(Item == ItemSemensPerDay)
		Txt = "$SGO4_MenuTip_ItemSemensPerDay"

	ElseIf(Item == ItemActorWeightDaysGain)
		Txt = "$SGO4_MenuTip_ItemActorWeightDaysGain"
	ElseIf(Item == ItemMessagesInsemination)
		Txt = "$SGO4_MenuTip_ItemMessagesInsemination"
	ElseIf(Item == ItemWeightGainPregPercent)
		Txt = "$SGO4_MenuTip_ItemWeightGainPregPercent"
	ElseIf(Item == ItemSemenBase)
		Txt = "$SGO4_MenuTip_ItemSemenBase"
	ElseIf(Item == ItemFixFemaleToMaleImp)
		Txt = "$SGO4_MenuTip_ItemFixFemaleToMaleImp"
	ElseIf(Item == ItemMilkOverlayPercentage)
		Txt = "$SGO4_MenuTip_ItemMilkOverlayPercentage"
	ElseIf(Item == ItemMilkLeveling)
		Txt = "$SGO4_MenuTip_ItemMilkLeveling"
	ElseIf(Item == ItemMilkLevelingCapacityMult)
		Txt = "$SGO4_MenuTip_ItemMilkLevelingCapacityMult"
	ElseIf(Item == ItemMilkLevelingCapacityMultCap)
		Txt = "$SGO4_MenuTip_ItemMilkLevelingCapacityMultCap"
	ElseIf(Item == ItemMilkLevelingGainMult)
		Txt = "$SGO4_MenuTip_ItemMilkLevelingGainMult"
	ElseIf(Item == ItemMilkLevelingGainMultCap)
		Txt = "$SGO4_MenuTip_ItemMilkLevelingGainMultCap"
	ElseIf(Item == ItemGemLeveling)
		Txt = "$SGO4_MenuTip_ItemGemLeveling"
	ElseIf(Item == ItemGemLevelingCap)
		Txt = "$SGO4_MenuTip_ItemGemLevelingCap"
	ElseIf(Item == ItemGemLevelingThreshold)
		Txt = "$SGO4_MenuTip_ItemGemLevelingThreshold"
	ElseIf(Item == ItemGemLevelingRatePenalty)
		Txt = "$SGO4_MenuTip_ItemGemLevelingRatePenalty"
	ElseIf(Item == ItemGemLevelingStatsMult)
		Txt = "$SGO4_MenuTip_ItemGemLevelingStatsMult"
	ElseIf(Item == ItemGemLevelingWeightMult)
		Txt = "$SGO4_MenuTip_ItemGemLevelingWeightMult"
	ElseIf(Item == ItemWeightIncreasesFertility)
		Txt = "$SGO4_MenuTip_ItemWeightIncreasesFertility"
	ElseIf(Item == ItemWeightFertilityBonus)
		Txt = "$SGO4_MenuTip_ItemWeightFertilityBonus"
	ElseIf(Item == ItemOrgasmGrowsMilk)
		Txt = "$SGO4_MenuTip_ItemOrgasmGrowsMilk"
	ElseIf(Item == ItemOrgasmGrowsMilkAmount)
		Txt = "$SGO4_MenuTip_ItemOrgasmGrowsMilkAmount"
	ElseIf(Item == ItemOrgasmGrowsGems)
		Txt = "$SGO4_MenuTip_ItemOrgasmGrowsGems"
	ElseIf(Item == ItemOrgasmGrowsGemsAmount)
		Txt = "$SGO4_MenuTip_ItemOrgasmGrowsGemsAmount"
	ElseIf(Item == ItemOrgasmIncreasesWeight)
		Txt = "$SGO4_MenuTip_ItemOrgasmIncreasesWeight"
	ElseIf(Item == ItemOrgasmIncreasesWeightAmount)
		Txt = "$SGO4_MenuTip_ItemOrgasmIncreasesWeightAmount"
	ElseIf(Item == ItemEjaculationIncreasesWeight)
		Txt = "$SGO4_MenuTip_ItemEjaculationIncreasesWeight"	
	ElseIf(Item == ItemEjaculationIncreasesWeightAmount)
		Txt = "$SGO4_MenuTip_ItemEjaculationIncreasesWeightAmount"
	ElseIf(Item == ItemEjaculationGrowsGems)
		Txt = "$SGO4_MenuTip_ItemEjaculationGrowsGems"
	ElseIf(Item == ItemEjaculationGrowsGemsAmount)
		Txt = "$SGO4_MenuTip_ItemEjaculationGrowsGemsAmount"
	ElseIf(Item == ItemOrgasmMilksMilk)
		Txt = "$SGO4_MenuTip_ItemOrgasmMilksMilk"
	ElseIf(Item == ItemOrgasmMilksThreshold)
		Txt = "$SGO4_MenuTip_ItemOrgasmMilksThreshold"
	ElseIf(Item == ItemOrgasmMilksGivesMilk)
		Txt = "$SGO4_MenuTip_ItemOrgasmMilksGivesMilk"
	ElseIf(Item == ItemSoloMissionGivesSemen)
		Txt = "$SGO4_MenuTip_ItemSoloMissionGivesSemen"
	ElseIf(Item == ItemEnableExpressions)
		Txt = "$SGO4_MenuTip_ItemEnableExpressions"

		
	EndIf

	self.SetInfoText(Txt)
	Return
EndEvent

;/*****************************************************************************
*****************************************************************************/;

Function ShowPageIntro()
	
	self.LoadCustomContent(Main.KeySplashGraphic)
	Return
EndFunction

;/*****************************************************************************
*****************************************************************************/;

Int ItemModStatus
Int ItemStripSexLabNormal
Int ItemStripSexLabForeplay
Int ItemStripBodyOnly
Int ItemStripNone
Int ItemUpdateLoopFreq
Int ItemUpdateLoopDelay
Int ItemUpdateGameHours
Int ItemUpdateAfterWait
Int ItemDatabankShowAll
Int ItemDatabankLoadedOnly
Int ItemActorUpdateName
Int ItemActorWeightDaysDrain
Int ItemActorWeightDaysGain

Function ShowPageGeneral()

	Int ActorStripMode = Main.Config.GetInt(".ActorStripMode")

	self.SetTitleText("$SGO4_MenuTitle_General")
	self.SetCursorFillMode(LEFT_TO_RIGHT)
	self.SetCursorPosition(0)

	AddHeaderOption("$SGO4_MenuOpt_ModStatus")
	AddHeaderOption("")
	ItemModStatus = AddToggleOption("$SGO4_MenuOpt_IsModActive",Main.IsRunning())
	AddEmptyOption()
	AddEmptyOption()
	AddEmptyOption()

	AddHeaderOption("$SGO4_MenuOpt_Performance")
	AddHeaderOption("")

	ItemUpdateLoopFreq = AddSliderOption("$SGO4_MenuOpt_UpdateLoopFreq",Main.Config.GetFloat(".UpdateLoopFreq"),"{1} sec")
	ItemUpdateLoopDelay = AddSliderOption("$SGO4_MenuOpt_UpdateLoopDelay",Main.Config.GetFloat(".UpdateLoopDelay"),"{2} sec")
	ItemUpdateGameHours = AddSliderOption("$SGO4_MenuOpt_UpdateGameHours",Main.Config.GetFloat(".UpdateGameHours"),"{1} hr")
	ItemUpdateAfterWait = AddToggleOption("$SGO4_MenuOpt_UpdateAfterWait",Main.Config.GetBool(".UpdateAfterWait"))
	ItemDatabankShowAll = AddToggleOption("$SGO4_MenuOpt_DatabankShowAll",Main.Config.GetBool(".DatabankShowAll"))
	ItemActorUpdateName = AddToggleOption("$SGO4_MenuOpt_ActorUpdateName",Main.Config.GetBool(".ActorUpdateName"))
	ItemDatabankLoadedOnly = AddToggleOption("$SGO4_MenuOpt_DatabankLoadedOnly",Main.Config.GetBool(".DatabankLoadedOnly"))
	AddEmptyOption()
	AddEmptyOption()
	AddEmptyOption()

	AddHeaderOption("$SGO4_MenuOpt_StripMode")
	AddHeaderOption("")

	ItemStripSexLabNormal = AddToggleOption("$SGO4_MenuOpt_StripSexLabNormal",(ActorStripMode == 1))
	ItemStripSexLabForeplay = AddToggleOption("$SGO4_MenuOpt_StripSexLabForeplay",(ActorStripMode == 2))
	ItemStripBodyOnly = AddToggleOption("$SGO4_MenuOpt_StripBodyOnly",(ActorStripMode == 3))
	ItemStripNone = AddToggleOption("$SGO4_MenuOpt_StripNone",(ActorStripMode == 0))

	Return
EndFunction

;/*****************************************************************************
*****************************************************************************/;

Function ShowPageDatabank()

	Int Iter
	Actor[] ActorList = Main.Data.ActorTrackingGetList()
	Float[] ActorGemList
	String Info1 = ""
	String Info2 = ""
	String Info3 = ""
	String Info4 = ""
	Bool LoadedOnly = Main.Config.GetBool(".DatabankLoadedOnly")
	Bool ShowAllBio = Main.Config.GetBool(".DatabankShowAll")

	;;;;;;;;

	Main.Util.SortByDisplayName(ActorList)

	;;;;;;;;

	self.SetTitleText("$SGO4_MenuTitle_Databank")
	self.SetCursorFillMode(LEFT_TO_RIGHT)
	self.SetCursorPosition(0)

	AddHeaderOption("Character - Race - Ref ID")
	AddTextOption("[Gems][Milk][Semen]","Gem Data",OPTION_FLAG_DISABLED)
	AddHeaderOption("")
	AddHeaderOption("")

	Iter = 0
	While(Iter < ActorList.Length)
		If((!LoadedOnly || ActorList[Iter].Is3dLoaded()) && (ShowAllBio || ActorList[Iter].IsInFaction(Main.FactionProduceGems)))

			ActorGemList = Main.Data.ActorGemGetList(ActorList[Iter])

			Info1 = Main.Data.ActorGetOriginalname(ActorList[Iter])

			Info2 = ActorList[Iter].GetRace().GetName()
			Info2 += " - "
			Info2 += Main.Util.DecToHex(ActorList[Iter].GetFormID())

			Info3 = ""
			Info4 = ""

			If(ActorList[Iter].IsInFaction(Main.FactionProduceGems))
				Info3 += "[G=" + Main.Util.FloatToString((Main.Data.ActorGemTotalPercent(ActorList[Iter],TRUE) * 100),1) + "%]"
			EndIf

			If(ActorList[Iter].IsInFaction(Main.FactionProduceMilk))
				Info3 += "[M=" + Main.Data.ActorMilkCount(ActorList[Iter]) + "]"
			EndIf

			If(ActorList[Iter].IsInFaction(Main.FactionProduceSemen))
				Info3 += "[S=" + Main.Data.ActorSemenCount(ActorList[Iter]) + "]"
			EndIf

			If(ActorList[Iter].IsInFaction(Main.FactionProduceGems))
				Info4 = "[ " + PapyrusUtil.StringJoin(Main.Util.FloatsToStrings(ActorGemList,1),", ") + " ]"
			Else
				Info4 = "N/A"
			EndIf

			AddHeaderOption((Info1 + " - " + Info2))
			AddTextOption(Info3,Info4,OPTION_FLAG_DISABLED)
		EndIf

		Iter += 1
	EndWhile


	Return
EndFunction

;/*****************************************************************************
*****************************************************************************/;

Int ItemActorGemsMax
Int ItemActorMilkMax
Int ItemActorSemenMax
Int ItemInfluenceMilkSpeech
Int ItemInfluenceMilkSpeechExposed
Int ItemInfluenceGemsHealth
Int ItemInfluenceGemsMagicka
Int ItemGemsPerDay
Int ItemMilksPerDay
Int ItemMilksPregPercent
Int ItemMilkOverlayPercentage
Int ItemMilksPassiveLoss
Int ItemMilkerProduce
Int ItemMilkerRate
Int ItemFertilitySync
Int ItemMessagesPlayer
Int ItemMessagesNPC
Int ItemMessagesInsemination

Int ItemBirthGemsFilled
Int ItemSemensPerDay

Int ItemFertilityChance
Int ItemFertilityDays
Int ItemFertilityWindow
Int ItemLevelAlchFactor
Int ItemLevelEnchFactor
Int ItemLevelValueBase

Int ItemInfluenceGemsWhen
Int ItemInfluenceMilkWhen

Int ItemWeightGainPregPercent
Int ItemSemenBase
Int ItemWeightIncreasesFertility
Int ItemWeightFertilityBonus

Function ShowPageGameplay()

	self.SetTitleText("$SGO4_MenuTitle_Gameplay")
	self.SetCursorFillMode(LEFT_TO_RIGHT)
	self.SetCursorPosition(0)

	AddHeaderOption("$SGO4_MenuOpt_ProductionOptions")
	AddHeaderOption("")

	ItemGemsPerDay = AddSliderOption("$SGO4_MenuOpt_GemsPerDay",Main.Config.GetFloat(".GemsPerDay"),"{2}")
	ItemBirthGemsFilled = AddToggleOption("$SGO4_MenuOpt_BirthGemsFilled",Main.Config.GetBool("BirthGemsFilled"))
	ItemMilksPregPercent = AddSliderOption("$SGO4_MenuOpt_MilksPregPercent",Main.Config.GetFloat(".MilksPregPercent"),"{0}%")
	ItemMilkOverlayPercentage = AddSliderOption("$SGO4_MenuOpt_MilkOverlayPercentage",Main.Config.GetFloat(".MilkOverlayPercentage"),"{0}%")	
	ItemMilksPerDay = AddSliderOption("$SGO4_MenuOpt_MilksPerDay",Main.Config.GetFloat(".MilksPerDay"),"{2}")
	ItemMilksPassiveLoss = AddSliderOption("$SGO4_MenuOpt_MilksPassiveLoss",(Main.Config.GetFloat(".MilksPassiveLoss") * 100),"{0}%")
	ItemMilkerProduce = AddToggleOption("$SGO4_MenuOpt_MilkerProduce",Main.Config.GetBool(".MilkerProduce"))
	ItemMilkerRate = AddSliderOption("$SGO4_MenuOpt_MilkerRate",(Main.Config.GetFloat(".MilkerRate") * 100),"{0}%")
	ItemSemensPerDay = AddSliderOption("$SGO4_MenuOpt_SemensPerDay",Main.Config.GetFloat(".SemensPerDay"))
	ItemSemenBase = AddSliderOption("$SGO4_MenuOpt_SemenBase",Main.Config.GetFloat(".SemenBase"),"{0}%")	
	ItemMessagesPlayer = AddToggleOption("$SGO4_MenuOpt_MessagesPlayer",Main.Config.GetBool(".MessagesPlayer"))
	ItemMessagesNPC = AddToggleOption("$SGO4_MenuOpt_MessagesNPC",Main.Config.GetBool(".MessagesNPC"))
	ItemMessagesInsemination = AddToggleOption("$SGO4_MenuOpt_MessagesInsemination",Main.Config.GetBool(".MessagesInsemination"))
	AddEmptyOption()
	AddEmptyOption()	
	AddEmptyOption()	

	AddHeaderOption("$SGO4_MenuOpt_ActorOptions")
	AddHeaderOption("")

	ItemActorGemsMax = AddSliderOption("$SGO4_MenuOpt_ActorGemsMax",Main.Config.GetInt(".ActorGemsMax"))
	ItemActorMilkMax = AddSliderOption("$SGO4_MenuOpt_ActorMilkMax",Main.Config.GetInt(".ActorMilkMax"))
	ItemActorSemenMax = AddSliderOption("$SGO4_MenuOpt_ActorSemenMax",Main.Config.GetInt(".ActorSemenMax"))
	AddEmptyOption()
	ItemActorWeightDaysDrain = AddSliderOption("$SGO4_MenuOpt_ActorWeightDaysDrain",Main.Config.GetFloat(".ActorWeightDaysDrain"))
	ItemActorWeightDaysGain = AddSliderOption("$SGO4_MenuOpt_ActorWeightDaysGain",Main.Config.GetFloat(".ActorWeightDaysGain"))	
	ItemWeightGainPregPercent = AddSliderOption("$SGO4_MenuOpt_WeightGainPregPercent",Main.Config.GetFloat(".WeightGainPregPercent"),"{0} %")	
	ItemFertilitySync = AddToggleOption("$SGO4_MenuOpt_FertilitySync",Main.Config.GetBool(".FertilitySync"))
	ItemFertilityChance = AddSliderOption("$SGO4_MenuOpt_FertilityChance",Main.Config.GetFloat(".FertilityChance"),"{0}%")
	ItemFertilityDays = AddSliderOption("$SGO4_MenuOpt_FertilityDays",Main.Config.GetFloat(".FertilityDays"))
	ItemFertilityWindow = AddSliderOption("$SGO4_MenuOpt_FertilityWindow",Main.Config.GetFloat(".FertilityWindow"),"{1}")
	ItemWeightIncreasesFertility = AddToggleOption("$SGO4_MenuOpt_WeightIncreasesFertility",Main.Config.GetBool(".WeightIncreasesFertility"))	
	ItemWeightFertilityBonus = AddSliderOption("$SGO4_MenuOpt_WeightFertilityBonus",Main.Config.GetFloat(".WeightFertilityBonus"))
	ItemLevelAlchFactor = AddSliderOption("$SGO4_MenuOpt_LevelAlchFactor",Main.Config.GetFloat(".LevelAlchFactor"),"{2}")
	ItemLevelEnchFactor = AddSliderOption("$SGO4_MenuOpt_LevelEnchFactor",Main.Config.GetFloat(".LevelEnchFactor"),"{2}")
	ItemLevelValueBase	 = AddSliderOption("$SGO4_MenuOpt_LevelValueBase",Main.Config.GetFloat(".LevelValueBase"))	
	AddEmptyOption()
	AddEmptyOption()	

	AddHeaderOption("$SGO4_MenuOpt_BioInfluences")
	AddHeaderOption("")

	ItemInfluenceGemsHealth = AddSliderOption("$SGO4_MenuOpt_InfluenceGemsHealth",Main.Config.GetFloat(".InfluenceGemsHealth"),"{0}")
	ItemInfluenceMilkSpeech = AddSliderOption("$SGO4_MenuOpt_InfluenceMilkSpeech",Main.Config.GetFloat(".InfluenceMilkSpeech"),"{0}")
	ItemInfluenceGemsMagicka = AddSliderOption("$SGO4_MenuOpt_InfluenceGemsMagicka",Main.Config.GetFloat(".InfluenceGemsMagicka"),"{0}")
	ItemInfluenceMilkSpeechExposed = AddSliderOption("$SGO4_MenuOpt_InfluenceMilkSpeechExposed",Main.Config.GetFloat(".InfluenceMilkSpeechExposed"),"{0}")
	ItemInfluenceGemsWhen = AddSliderOption("$SGO4_MenuOpt_InfluenceGemsWhen",Main.Config.GetFloat(".InfluenceGemsWhen"),"{2}")
	ItemInfluenceMilkWhen = AddSliderOption("$SGO4_MenuOpt_InfluenceMilkWhen",Main.Config.GetFloat(".InfluenceMilkWhen"),"{2}")	

	Return
EndFunction


;;Needs int values, for thing, yes.

Int ItemMilkLeveling
Int ItemMilkLevelingCapacityMult
Int ItemMilkLevelingCapacityMultCap
Int ItemMilkLevelingGainMult
Int ItemMilkLevelingGainMultCap

Int ItemGemLeveling
Int ItemGemLevelingCap
Int ItemGemLevelingThreshold
Int ItemGemLevelingRatePenalty
Int ItemGemLevelingStatsMult
Int ItemGemLevelingWeightMult

Int ItemOrgasmGrowsMilk
Int ItemOrgasmGrowsMilkAmount
Int ItemOrgasmMilksMilk
Int ItemOrgasmMilksThreshold
Int ItemOrgasmMilksGivesMilk

Int ItemOrgasmGrowsGems
Int ItemOrgasmGrowsGemsAmount
Int ItemOrgasmIncreasesWeight
Int ItemOrgasmIncreasesWeightAmount

Int ItemEjaculationIncreasesWeight
Int ItemEjaculationIncreasesWeightAmount
Int ItemEjaculationGrowsGems
Int ItemEjaculationGrowsGemsAmount

Int ItemFixFemaleToMaleImp
Int ItemEnableExpressions


Int ItemSoloMissionGivesSemen

Function ShowPageIntegration()	
	self.SetTitleText("$SGO4_MenuTitle_Integration")
	self.SetCursorFillMode(LEFT_TO_RIGHT) ;;Dunforgetthisshit, Lefttoright
	self.SetCursorPosition(0)

	AddHeaderOption("$SGO4_MenuOpt_MilkLeveling")
	AddHeaderOption("")	
	ItemMilkLeveling = AddToggleOption("$SGO4_MenuOpt_MilkLeveling",Main.Config.GetBool(".MilkLeveling"))
	AddEmptyOption()	
	ItemMilkLevelingCapacityMult = AddSliderOption("$SGO4_MenuOpt_MilkLevelingCapacityMult",Main.Config.GetFloat(".MilkLevelingCapacityMult"),"{3}")
	ItemMilkLevelingCapacityMultCap = AddSliderOption("$SGO4_MenuOpt_MilkLevelingCapacityMultCap",Main.Config.GetFloat(".MilkLevelingCapacityMultCap"),"{2}")
	ItemMilkLevelingGainMult = AddSliderOption("$SGO4_MenuOpt_MilkLevelingGainMult",Main.Config.GetFloat(".MilkLevelingGainMult"),"{3}")
	ItemMilkLevelingGainMultCap = AddSliderOption("$SGO4_MenuOpt_MilkLevelingGainMultCap",Main.Config.GetFloat(".MilkLevelingGainMultCap"),"{2}")
	AddEmptyOption()	
	AddEmptyOption()
	
	AddHeaderOption("$SGO4_MenuOpt_GemLeveling")
	AddHeaderOption("")	
	ItemGemLeveling = AddToggleOption("$SGO4_MenuOpt_GemLeveling",Main.Config.GetBool(".GemLeveling"))
	ItemGemLevelingCap = AddSliderOption("$SGO4_MenuOpt_GemLevelingCap",Main.Config.GetInt(".GemLevelingCap"))
	ItemGemLevelingThreshold = AddSliderOption("$SGO4_MenuOpt_GemLevelingThreshold",Main.Config.GetInt(".GemLevelingThreshold"))
	ItemGemLevelingRatePenalty = AddSliderOption("$SGO4_MenuOpt_GemLevelingRatePenalty",Main.Config.GetFloat(".GemLevelingRatePenalty"),"{2}")
	ItemGemLevelingStatsMult = AddSliderOption("$SGO4_MenuOpt_GemLevelingStatsMult",Main.Config.GetFloat(".GemLevelingStatsMult"),"{2}")
	ItemGemLevelingWeightMult = AddSliderOption("$SGO4_MenuOpt_GemLevelingWeightMult",Main.Config.GetFloat(".GemLevelingWeightMult"),"{2}")
	AddEmptyOption()	
	AddEmptyOption()		
	
	AddHeaderOption("$SGO4_MenuOpt_SceneIntegration")
	AddHeaderOption("")	
	ItemOrgasmGrowsMilk = AddToggleOption("$SGO4_MenuOpt_OrgasmGrowsMilk",Main.Config.GetBool(".OrgasmGrowsMilk"))
	ItemOrgasmGrowsMilkAmount = AddSliderOption("$SGO4_MenuOpt_OrgasmGrowsMilkAmount",Main.Config.GetFloat(".OrgasmGrowsMilkAmount"),"{2}")
	ItemOrgasmMilksMilk = AddToggleOption("$SGO4_MenuOpt_OrgasmMilksMilk",Main.Config.GetBool(".OrgasmMilksMilk"))
	ItemOrgasmMilksThreshold = AddSliderOption("$SGO4_MenuOpt_OrgasmMilksThreshold",Main.Config.GetFloat(".OrgasmMilksThreshold"),"{0} %")
	ItemOrgasmMilksGivesMilk = AddToggleOption("$SGO4_MenuOpt_OrgasmMilksGivesMilk",Main.Config.GetBool(".OrgasmMilksGivesMilk"))
	AddEmptyOption()	
	AddEmptyOption()	
	AddEmptyOption()		
	ItemOrgasmGrowsGems = AddToggleOption("$SGO4_MenuOpt_OrgasmGrowsGems",Main.Config.GetBool(".OrgasmGrowsGems"))
	ItemOrgasmGrowsGemsAmount = AddSliderOption("$SGO4_MenuOpt_OrgasmGrowsGemsAmount",Main.Config.GetFloat(".OrgasmGrowsGemsAmount"),"{2}")
	ItemOrgasmIncreasesWeight = AddToggleOption("$SGO4_MenuOpt_OrgasmIncreasesWeight",Main.Config.GetBool(".OrgasmIncreasesWeight"))
	ItemOrgasmIncreasesWeightAmount = AddSliderOption("$SGO4_MenuOpt_OrgasmIncreasesWeightAmount",Main.Config.GetFloat(".OrgasmIncreasesWeightAmount"),"{2}")
	AddEmptyOption()	
	AddEmptyOption()		
	ItemEjaculationIncreasesWeight = AddToggleOption("$SGO4_MenuOpt_EjaculationIncreasesWeight",Main.Config.GetBool(".EjaculationIncreasesWeight"))
	ItemEjaculationIncreasesWeightAmount = AddSliderOption("$SGO4_MenuOpt_EjaculationIncreasesWeightAmount",Main.Config.GetFloat(".EjaculationIncreasesWeightAmount"),"{2}")
	ItemEjaculationGrowsGems = AddToggleOption("$SGO4_MenuOpt_EjaculationGrowsGems",Main.Config.GetBool(".EjaculationGrowsGems"))
	ItemEjaculationGrowsGemsAmount = AddSliderOption("$SGO4_MenuOpt_EjaculationGrowsGemsAmount",Main.Config.GetFloat(".EjaculationGrowsGemsAmount"),"{2}")
	AddEmptyOption()	
	AddEmptyOption()	
	
	AddHeaderOption("$SGO4_MenuOpt_IntegrationExtras")
	AddHeaderOption("")	

	ItemFixFemaleToMaleImp = AddToggleOption("$SGO4_MenuOpt_FixFemaleToMaleImp",Main.Config.GetBool(".FixFemaleToMaleImp"))	
	ItemSoloMissionGivesSemen = AddToggleOption("$SGO4_MenuOpt_SoloMissionGivesSemen",Main.Config.GetBool(".SoloMissionGivesSemen"))
	ItemEnableExpressions = AddToggleOption("$SGO4_MenuOpt_EnableExpressions",Main.Config.GetBool(".EnableExpressions"))	



	Return
EndFunction

;/*****************************************************************************
*****************************************************************************/;

String ItemSliderType
Int ItemSliderAdd
Int ItemSliderDel
Int[] ItemSliderVal
Int ItemSliderBelly

Function ShowPageSliders(String PageTitle, String SliderConfig)

	Int SliderCount = Main.Config.GetCount(SliderConfig)
	Int SliderIter = 0
	String SliderName
	Float SliderValue

	ItemSliderType = SliderConfig
	ItemSliderVal = Utility.CreateIntArray(SliderCount)

	;;;;;;;;

	self.SetTitleText(PageTitle)
	self.SetCursorFillMode(TOP_TO_BOTTOM)

	self.SetCursorPosition(0)
	AddHeaderOption("Current Morphs")
	While(SliderIter < SliderCount)
		SliderName = Main.Config.GetString(SliderConfig + "[" + SliderIter + "].Name")
		SliderValue = Main.Config.GetFloat(SliderConfig + "[" + SliderIter + "].Max")

		ItemSliderVal[SliderIter] = AddSliderOption(SliderName,SliderValue,"{2}")
		
		SliderIter += 1
	EndWhile

	self.SetCursorPosition(1)
	AddHeaderOption("Manage Morphs")
	;;ItemSliderAdd = AddToggleOption("$SGO4_MenuOpt_BodySliderAdd",FALSE)
	ItemSliderAdd = AddInputOption("$SGO4_MenuOpt_BodySliderAdd","")
	;;ItemSliderDel = AddToggleOption("$SGO4_MenuOpt_BodySliderDel",FALSE)
	ItemSliderDel = AddMenuOption("$SGO4_MenuOpt_BodySliderDel","")
	AddEmptyOption()

	If(SliderConfig == Main.Body.KeySlidersGems)
		ItemSliderBelly = AddMenuOption("$SGO4_MenuOpt_BellySliderName",Main.Config.GetString(".Sliders.Belly"))
	EndIf

	Return
EndFunction

;/*****************************************************************************
*****************************************************************************/;

Int ItemWidgetScale
Int ItemWidgetOffsetX
Int ItemWidgetOffsetY
Int ItemWidgetAnchorH
Int ItemWidgetAnchorV

Function ShowPageWidgets()

	self.SetTitleText("$SGO4_MenuTitle_Widgets")
	self.SetCursorFillMode(LEFT_TO_RIGHT)
	self.SetCursorPosition(0)

	AddHeaderOption("$SGO4_MenuOpt_ScannerWidget")
	AddHeaderOption("")
	ItemWidgetOffsetX = AddSliderOption("$SGO4_MenuOpt_WidgetOffsetX",Main.Config.GetFloat(".WidgetOffsetX"),"{1}")
	ItemWidgetAnchorH = AddMenuOption("$SGO4_MenuOpt_WidgetAnchorH",Main.Config.GetString(".WidgetAnchorH"))
	ItemWidgetOffsetY = AddSliderOption("$SGO4_MenuOpt_WidgetOffsetY",Main.Config.GetFloat(".WidgetOffsetY"),"{1}")
	ItemWidgetAnchorV = AddMenuOption("$SGO4_MenuOpt_WidgetAnchorV",Main.Config.GetString(".WidgetAnchorV"))
	ItemWidgetScale = AddSliderOption("$SGO4_MenuOpt_WidgetScale",Main.Config.GetFloat(".WidgetScale"),"{2}")

	Return
EndFunction

;/*****************************************************************************
*****************************************************************************/;

Int ItemDebug
Int ItemDebugPlayerGemsEmpty
Int ItemDebugPlayerGemsMin
Int ItemDebugPlayerGemsHalf
Int ItemDebugPlayerGemsMax
Int ItemDebugPlayerMilkEmpty
Int ItemDebugPlayerMilkHalf
Int ItemDebugPlayerMilkMax
Int ItemDebugPlayerSemenEmpty
Int ItemDebugPlayerSemenHalf
Int ItemDebugPlayerSemenMax
Int ItemDebugIsActorTracked


Function ShowPageDebug()

	Actor Who = Game.GetCurrentCrosshairRef() as Actor
	Int GemCount
	Int GemIter

	If(Who == None)
		Who = Main.Player
	EndIf

	GemCount = Main.Data.ActorGemCount(Who)

	self.SetTitleText("$SGO4_MenuTitle_Debugging")
	self.SetCursorFillMode(TOP_TO_BOTTOM)
	self.SetCursorPosition(0)

	AddHeaderOption(Who.GetDisplayName())
	ItemDebugPlayerGemsEmpty = AddToggleOption("$SGO4_MenuOpt_DebugCmdGemEmpty",FALSE)
	ItemDebugPlayerGemsMin = AddToggleOption("$SGO4_MenuOpt_DebugCmdGemMin",FALSE)
	ItemDebugPlayerGemsHalf = AddToggleOption("$SGO4_MenuOpt_DebugCmdGemMid",FALSE)
	ItemDebugPlayerGemsMax = AddToggleOption("$SGO4_MenuOpt_DebugCmdGemMax",FALSE)
	ItemDebugPlayerMilkEmpty = AddToggleOption("$SGO4_MenuOpt_DebugCmdMilkEmpty",FALSE)
	ItemDebugPlayerMilkHalf = AddToggleOption("$SGO4_MenuOpt_DebugCmdMilkMid",FALSE)
	ItemDebugPlayerMilkMax = AddToggleOption("$SGO4_MenuOpt_DebugCmdMilkMax",FALSE)
	ItemDebugPlayerSemenEmpty = AddToggleOption("$SGO4_MenuOpt_DebugCmdSemenEmpty",FALSE)
	ItemDebugPlayerSemenHalf = AddToggleOption("$SGO4_MenuOpt_DebugCmdSemenMid",FALSE)
	ItemDebugPlayerSemenMax = AddToggleOption("$SGO4_MenuOpt_DebugCmdSemenMax",FALSE)

	self.SetCursorPosition(1)
	ItemDebug = AddToggleOption("$SGO4_MenuOpt_Debug",Main.Config.DebugMode)
	AddEmptyOption()

	AddHeaderOption(Who.GetDisplayName())

	GemIter = 0
	While(GemIter < GemCount)
		AddTextOption("$SGO4_Word_Gem", (Main.Data.ActorGemGet(Who,GemIter) as String))
		GemIter += 1
	EndWhile

	AddTextOption("$SGO4_Word_Milk",(Main.Data.ActorMilkAmount(Who) as String))
	AddTextOption("$SGO4_Word_Semen",(Main.Data.ActorSemenAmount(Who) as String))
	AddTextOption("$SGO4_Word_Weight",(Main.Data.ActorWeightGet(Who) as String))

	If(Main.Data.IsActorTracked(Who))
		ItemDebugIsActorTracked = AddTextOption("$SGO4_MenuOpt_DebugIsActorTracked","$SGO4_Word_Yes")
	Else
		ItemDebugIsActorTracked = AddTextOption("$SGO4_MenuOpt_DebugIsActorTracked","$SGO4_Word_No")
	EndIf

	Return
EndFunction

;/*****************************************************************************
*****************************************************************************/;