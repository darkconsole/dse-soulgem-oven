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
	Main.Data.RaceLoadFiles()
	;; do a dependency check every launch.
	;;Main.ResetMod_Prepare()

	Main.UnregisterForMenu("Sleep/Wait Menu")
	Main.RegisterForMenu("Sleep/Wait Menu")

	Return
EndEvent

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Event OnConfigInit()
{things to do when the menu initalises (is opening)}

	self.Pages = new String[3]
	
	self.Pages[0] = "$SGO4_Menu_General"
	;; info, enable/disable, uninstall.

	self.Pages[1] = "$SGO4_Menu_Debug"
	;; testing utilities

	self.Pages[2] = "$SGO4_Menu_Splash"
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

	Return
EndEvent

Event OnPageReset(string page)
{when a different tab is selected in the menu.}

	self.UnloadCustomContent()

	If(Page == "$SGO4_Menu_General")
		self.ShowPageGeneral()
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

	;;;;;;;;

	If(Item == ItemDebugPlayerGemsEmpty)
		Val = TRUE
		Main.Data.ActorGemClear(Main.Player)
		Main.Util.PrintDebug(Main.Player.GetDisplayName() + " has been emptied of their gems.")

	;;;;;;;;

	ElseIf(Item == ItemDebugPlayerGemsMin)
		Val = TRUE
		Main.Data.ActorGemClear(Main.Player)
		While(Main.Data.ActorGemAdd(Main.Player,0.0))
		EndWhile
		Main.Util.PrintDebug(Main.Player.GetDisplayName() + " has been filled with min level gems.")

	;;;;;;;;

	ElseIf(Item == ItemDebugPlayerGemsHalf)
		Val = TRUE
		Main.Data.ActorGemClear(Main.Player)
		While(Main.Data.ActorGemAdd(Main.Player,(Main.Data.GemStageCount(Main.Player)/2)))
		EndWhile
		Main.Util.PrintDebug(Main.Player.GetDisplayName() + " has been filled with half level gems.")

	;;;;;;;;

	ElseIf(Item == ItemDebugPlayerGemsMax)
		Val = TRUE
		Main.Data.ActorGemClear(Main.Player)
		While(Main.Data.ActorGemAdd(Main.Player,Main.Data.GemStageCount(Main.Player)))
		EndWhile
		Main.Util.PrintDebug(Main.Player.GetDisplayName() + " has been filled with max level gems.")

	;;;;;;;;

	ElseIf(Item == ItemDebugPlayerMilkEmpty)
		Val = TRUE
		Main.Data.ActorMilkClear(Main.Player)
		Main.Util.PrintDebug(Main.Player.GetDisplayName() + " has been emptied of their milk.")

	;;;;;;;;

	ElseIf(Item == ItemDebugPlayerMilkHalf)
		Val = TRUE
		Main.Data.ActorMilkSet(Main.Player,(Main.Data.ActorMilkMax(Main.Player)/2))
		Main.Util.PrintDebug(Main.Player.GetDisplayName() + " has been filled half way with milk.")

	;;;;;;;;

	ElseIf(Item == ItemDebugPlayerMilkMax)
		Val = TRUE
		Main.Data.ActorMilkSet(Main.Player,Main.Data.ActorMilkMax(Main.Player))
		Main.Util.PrintDebug(Main.Player.GetDisplayName() + " has been filled full with milk.")

	;;;;;;;;

	ElseIf(Item == ItemDebugPlayerSemenEmpty)
		Val = TRUE
		Main.Data.ActorSemenClear(Main.Player)
		Main.Util.PrintDebug(Main.Player.GetDisplayName() + " has been emptied of their semen.")

	;;;;;;;;

	ElseIf(Item == ItemDebugPlayerSemenHalf)
		Val = TRUE
		Main.Data.ActorSemenSet(Main.Player,(Main.Data.ActorSemenMax(Main.Player)/2))
		Main.Util.PrintDebug(Main.Player.GetDisplayName() + " has been filled half way with semen.")

	;;;;;;;;

	ElseIf(Item == ItemDebugPlayerSemenMax)
		Val = TRUE
		Main.Data.ActorSemenSet(Main.Player,Main.Data.ActorSemenMax(Main.Player))
		Main.Util.PrintDebug(Main.Player.GetDisplayName() + " has been filled full with semen.")

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

	SetSliderDialogStartValue(Val)
	SetSliderDialogRange(Min,Max)
	SetSliderDialogInterval(Interval)
	Return
EndEvent

;/*****************************************************************************
*****************************************************************************/;

Event OnOptionSliderAccept(Int Item, Float Val)
	String Fmt = "{0}"

	SetSliderOptionValue(Item,Val,Fmt)
	Return
EndEvent

;/*****************************************************************************
*****************************************************************************/;

Event OnOptionHighlight(Int Item)
	
	;;self.SetInfoText("$SGO4_Mod_TitleFull")

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

Function ShowPageGeneral()

	Return
EndFunction

;/*****************************************************************************
*****************************************************************************/;

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

	self.SetTitleText("Debugging")
	self.SetCursorFillMode(TOP_TO_BOTTOM)
	self.SetCursorPosition(0)

	ItemDebugPlayerGemsEmpty = AddToggleOption("Empty Player Of Gems",FALSE)
	ItemDebugPlayerGemsMin = AddToggleOption("Fill Player Gems Min Lvl",FALSE)
	ItemDebugPlayerGemsHalf = AddToggleOption("Fill Player Gems Half Lvl",FALSE)
	ItemDebugPlayerGemsMax = AddToggleOption("Fill Player Gems Max Lvl",FALSE)
	ItemDebugPlayerMilkEmpty = AddToggleOption("Empty Player Milk",FALSE)
	ItemDebugPlayerMilkHalf = AddToggleOption("Fill Player Milk Half",FALSE)
	ItemDebugPlayerMilkMax = AddToggleOption("Fill Player Milk Full",FALSE)
	ItemDebugPlayerSemenEmpty = AddToggleOption("Empty Player Semen",FALSE)
	ItemDebugPlayerSemenHalf = AddToggleOption("Fill Player Semen Half",FALSE)
	ItemDebugPlayerSemenMax = AddToggleOption("Fill Player Semen Full",FALSE)

	self.SetCursorPosition(1)
	AddHeaderOption(Who.GetDisplayName() + " Dataset")

	GemIter = 0
	While(GemIter < GemCount)
		AddTextOption(("Gem " + (GemIter+1)), (Main.Data.ActorGemGet(Who,GemIter) as String))
		GemIter += 1
	EndWhile

	AddTextOption("Milk",(Main.Data.ActorMilkAmount(Who) as String))
	AddTextOption("Semen",(Main.Data.ActorMilkAmount(Who) as String))


	Return
EndFunction

;/*****************************************************************************
*****************************************************************************/;