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

	parent.OnGameReload()

	Main.Config.LoadFiles()

	Main.Data.RaceLoadFiles()
	;; do a dependency check every launch.
	;;Main.ResetMod_Prepare()

	Main.Util.PrintDebug("JSON ERRORS (blank is good):")
	Main.Util.PrintDebug("FileConfig: " + JsonUtil.GetErrors(Main.Config.FileConfig))
	Main.Util.PrintDebug("FileCustom: " + JsonUtil.GetErrors(Main.Config.FileCustom))

	Main.UnregisterForMenu("Sleep/Wait Menu")
	Main.RegisterForMenu("Sleep/Wait Menu")

	self.OnGameReload_CopySliderData()

	Return
EndEvent

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

	self.Pages = new String[8]

	self.Pages[0] = "$SGO4_Menu_Databank"
	;; sgo actor tracking data.
	
	self.Pages[1] = "$SGO4_Menu_General"
	;; info, enable/disable, uninstall.

	self.Pages[2] = "$SGO4_Menu_Gameplay"
	;; gameplay settings

	self.Pages[3] = "$SGO4_Menu_GemSliders"
	;; pregnancy sliders

	self.Pages[4] = "$SGO4_Menu_MilkSliders"
	;; milking sliders

	self.Pages[5] = "$SGO4_Menu_Widgets"
	;; widget settings utilities

	self.Pages[6] = "$SGO4_Menu_Debug"
	;; testing utilities

	self.Pages[7] = "$SGO4_Menu_Splash"
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
		Main.Data.ActorGemClear(Who)
		Main.Util.PrintDebug(Who.GetDisplayName() + " has been emptied of their gems.")

	;;;;;;;;

	ElseIf(Item == ItemDebugPlayerGemsMin)
		Val = TRUE
		Main.Data.ActorGemClear(Who)
		While(Main.Data.ActorGemAdd(Who,0.0))
		EndWhile
		Main.Util.PrintDebug(Who.GetDisplayName() + " has been filled with min level gems.")

	;;;;;;;;

	ElseIf(Item == ItemDebugPlayerGemsHalf)
		Val = TRUE
		Main.Data.ActorGemClear(Who)
		While(Main.Data.ActorGemAdd(Who,(Main.Data.GemStageCount(Who)/2)))
		EndWhile
		Main.Util.PrintDebug(Who.GetDisplayName() + " has been filled with half level gems.")

	;;;;;;;;

	ElseIf(Item == ItemDebugPlayerGemsMax)
		Val = TRUE
		Main.Data.ActorGemClear(Who)
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

	ElseIf(Item == ItemSexLabStrip)
		Val = !Main.Config.GetBool(".SexLabStrip")
		Main.Config.SetBool(".SexLabStrip",Val)

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

		If(PageCurrentKey == "$SGO4_Menu_Databank")
			OnPageReset(PageCurrentKey)
		EndIf

	ElseIf(Item == ItemDatabankLoadedOnly)
		Val = !Main.Config.GetBool(".DatabankLoadedOnly")
		Main.Config.SetBool(".DatabankLoadedOnly",Val)

		If(PageCurrentKey == "$SGO4_Menu_Databank")
			OnPageReset(PageCurrentKey)
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
		Min = 0.0
		Max = 50.0
		Interval = 1.0
	ElseIf(Item == ItemInfluenceMilkSpeechExposed)
		Val = Main.Config.GetFloat(".InfluenceMilkSpeechExposed")
		Min = 0.0
		Max = 20.0
		Interval = 1.0
	ElseIf(Item == ItemInfluenceGemsHealth)
		Val = Main.Config.GetFloat(".InfluenceGemsHealth")
		Min = 0.0
		Max = 150.0
		Interval = 1.0
	ElseIf(Item == ItemInfluenceGemsMagicka)
		Val = Main.Config.GetFloat(".InfluenceGemsMagicka")
		Min = 0.0
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
	ElseIf(Item == ItemSexLabStrip)
		Txt = "$SGO4_MenuTip_SexLabStrip"
	ElseIf(Item == ItemGemsPerDay)
		Txt = "$SGO4_MenuTip_GemsPerDay"
	ElseIf(Item == ItemMilksPerDay)
		Txt = "$SGO4_MenuTip_MilksPerDay"
	ElseIf(Item == ItemUpdateLoopFreq)
		Txt = "$SGO4_MenuTip_UpdateLoopFreq"
	ElseIf(Item == ItemUpdateLoopDelay)
		Txt = "$SGO4_MenuTip_UpdateLoopDelay"
	ElseIf(Item == ItemUpdateGameHours)
		Txt = "$SGO4_MenuTip_UpdateGameHours"
	ElseIf(Item == ItemMilksPregPercent)
		Txt = "$SGO4_MenuTip_MilksPregPercent"
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
Int ItemSexLabStrip
Int ItemUpdateLoopFreq
Int ItemUpdateLoopDelay
Int ItemUpdateGameHours
Int ItemUpdateAfterWait
Int ItemDatabankShowAll
Int itemDatabankLoadedOnly

Function ShowPageGeneral()

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
	ItemDatabankLoadedOnly = AddToggleOption("$SGO4_MenuOpt_DatabankLoadedOnly",Main.Config.GetBool(".DatabankLoadedOnly"))
	AddEmptyOption()
	AddEmptyOption()

	AddHeaderOption("$SGO4_MenuOpt_Misc")
	AddHeaderOption("")

	ItemSexLabStrip = AddToggleOption("$SGO4_MenuOpt_SexLabStrip",Main.Config.GetBool(".SexLabStrip"))

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

			Info1 = ActorList[Iter].GetDisplayName()

			Info2 = ActorList[Iter].GetRace().GetName()
			Info2 += " - "
			Info2 += Main.Util.DecToHex(ActorList[Iter].GetFormID())

			Info3 = ""
			Info4 = ""

			If(ActorList[Iter].IsInFaction(Main.FactionProduceGems))
				Info3 += "[G=" + Main.Util.FloatToString((Main.Data.ActorGemTotalPercent(ActorList[Iter],TRUE) * 100),1) + "%]"
			EndIf

			If(ActorList[Iter].IsInFaction(Main.FactionProduceMilk))
				Info3 += "[M=" + Main.Util.FloatToString((Main.Data.ActorMilkTotalPercent(ActorList[Iter]) * 100),1) + "%]"
			EndIf

			If(ActorList[Iter].IsInFaction(Main.FactionProduceSemen))
				Info3 += "[S=" + Main.Util.FloatToString((Main.Data.ActorSemenTotalPercent(ActorList[Iter]) * 100),1) + "%]"
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
Int ItemMilkerProduce
Int ItemMilkerRate

Function ShowPageGameplay()

	self.SetTitleText("$SGO4_MenuTitle_Gameplay")
	self.SetCursorFillMode(LEFT_TO_RIGHT)
	self.SetCursorPosition(0)

	AddHeaderOption("$SGO4_MenuOpt_ProductionOptions")
	AddHeaderOption("")

	ItemGemsPerDay = AddSliderOption("$SGO4_MenuOpt_GemsPerDay",Main.Config.GetFloat(".GemsPerDay"),"{2}")
	ItemMilksPregPercent = AddSliderOption("$SGO4_MenuOpt_MilksPregPercent",Main.Config.GetFloat(".MilksPregPercent"),"{0}%")
	ItemMilksPerDay = AddSliderOption("$SGO4_MenuOpt_MilksPerDay",Main.Config.GetFloat(".MilksPerDay"),"{2}")
	ItemMilkerProduce = AddToggleOption("$SGO4_MenuOpt_MilkerProduce",Main.Config.GetBool(".MilkerProduce"))
	AddEmptyOption()
	ItemMilkerRate = AddSliderOption("$SGO4_MenuOpt_MilkerRate",(Main.Config.GetFloat(".MilkerRate") * 100),"{0}%")
	AddEmptyOption()
	AddEmptyOption()

	AddHeaderOption("$SGO4_MenuOpt_ActorOptions")
	AddHeaderOption("")

	ItemActorGemsMax = AddSliderOption("$SGO4_MenuOpt_ActorGemsMax",Main.Config.GetInt(".ActorGemsMax"),"{0}")
	ItemActorMilkMax = AddSliderOption("$SGO4_MenuOpt_ActorMilkMax",Main.Config.GetInt(".ActorMilkMax"),"{0}")
	ItemActorSemenMax = AddSliderOption("$SGO4_MenuOpt_ActorSemenMax",Main.Config.GetInt(".ActorSemenMax"),"{0}")
	AddEmptyOption()
	AddEmptyOption()
	AddEmptyOption()

	AddHeaderOption("$SGO4_MenuOpt_BioInfluences")
	AddHeaderOption("")

	ItemInfluenceGemsHealth = AddSliderOption("$SGO4_MenuOpt_InfluenceGemsHealth",Main.Config.GetFloat(".InfluenceGemsHealth"),"{0}")
	ItemInfluenceMilkSpeech = AddSliderOption("$SGO4_MenuOpt_InfluenceMilkSpeech",Main.Config.GetFloat(".InfluenceMilkSpeech"),"{0}")
	ItemInfluenceGemsMagicka = AddSliderOption("$SGO4_MenuOpt_InfluenceGemsMagicka",Main.Config.GetFloat(".InfluenceGemsMagicka"),"{0}")
	ItemInfluenceMilkSpeechExposed = AddSliderOption("$SGO4_MenuOpt_InfluenceMilkSpeechExposed",Main.Config.GetFloat(".InfluenceMilkSpeechExposed"),"{0}")

	Return
EndFunction

;/*****************************************************************************
*****************************************************************************/;

String ItemSliderType
Int ItemSliderAdd
Int ItemSliderDel
Int[] ItemSliderVal

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
	AddTextOption("$SGO4_Word_Semen",(Main.Data.ActorMilkAmount(Who) as String))


	Return
EndFunction

;/*****************************************************************************
*****************************************************************************/;