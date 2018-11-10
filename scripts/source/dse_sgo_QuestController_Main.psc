ScriptName dse_sgo_QuestController_Main extends Quest

;/*;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

              _________            .__                          
             /   _____/ ____  __ __|  |    ____   ____   _____  
             \_____  \ /  _ \|  |  \  |   / ___\_/ __ \ /     \ 
             /        (  <_> )  |  /  |__/ /_/  >  ___/|  Y Y  \
            /_______  /\____/|____/|____/\___  / \___  >__|_|  /
                    \/                  /_____/      \/      \/ 
                 ________                          _____        
                 \_____  \___  __ ____   ____     /  |  |       
                  /   |   \  \/ // __ \ /    \   /   |  |_      
                 /    |    \   /\  ___/|   |  \ /    ^   /      
                 \_______  /\_/  \___  >___|  / \____   |       
                         \/          \/     \/       |__|       

                          SPECIAL EDITION EDITION

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;*/;

;; >
;; THERE ARE ONLY 6 SOULGEM
;; MODELS.

Int Function GetVersion() Global
{report a version number.}

	Return 400
EndFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; local mod libraries.

dse_sgo_QuestConfig_Main Property Config Auto
dse_sgo_QuestDatabase_Main Property Data Auto
dse_sgo_QuestUpdateLoop_Main Property Loop Auto
dse_sgo_QuestUtil_Main Property Util Auto
dse_sgo_QuestBody_Main Property Body Auto
dse_sgo_QuestStats_Main Property Stats Auto

;; ui api

dse_sgo_QuestGemBar_Main Property GemBar Auto
dse_sgo_QuestMilkBar_Main Property MilkBar Auto
dse_sgo_QuestSemenBar_Main Property SemenBar Auto

;; third party libraries.

SexLabFramework Property SexLab Auto Hidden

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Actor Property Player Auto

Container Property ContainInsertGems Auto
FormList Property ListGemFilter Auto
FormList property ListSemenFilter Auto
Faction Property FactionProduceGems Auto
Faction Property FactionProduceMilk Auto
Faction Property FactionProduceSemen Auto
Spell Property SpellActorDataScan Auto
Spell Property SpellActorDataScanToggle Auto
Spell Property SpellBirthLargest Auto
Spell Property SpellInsertGems Auto
Spell Property SpellMenuMainOpen Auto
Spell Property SpellMilkingAction Auto
Spell Property SpellWankingAction Auto
Package Property PackageDoNothing Auto

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

String Property KeyESP = "dse-soulgem-oven.esp" AutoReadOnly Hidden
String Property KeySplashGraphic = "dse-soulgem-oven/splash.dds" AutoReadOnly Hidden

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Event OnInit()
{handle install/reset.}

	Int Wait = 0

	If(self.IsStopped())
		Return
	EndIf

	If(!self.CheckForDeps(TRUE))
		self.Reset()
		self.Stop()
		Return
	EndIf

	;;;;;;;;

	self.ResetConfig()

	Wait = 0
	While(!Config.IsRunning() && Wait < 10)
		Wait += 1
		self.Util.PrintDebug("Waiting for dse_sgo_QuestConfig to start (" + Wait + ")...")
		Utility.Wait(1.0)
	EndWhile

	If(!self.Config.IsRunning())
		self.Util.PrintDebug("Startup Aborted: Config did not reset.")
		Return
	EndIf

	;;;;;;;;

	self.ResetLoop()

	Wait = 0
	While(!Loop.IsRunning() && Wait < 10)
		Wait += 1
		self.Util.PrintDebug("Waiting for dse_sgo_QuestUpdateLoop to start (" + Wait + ")...")
		Utility.Wait(1.0)
	EndWhile

	if(!self.Loop.IsRunning())
		self.Util.PrintDebug("Startup Aborted: Loop did not reset.")
		Return
	EndIf

	;;;;;;;;

	;; not for real things just hack testing.

	self.Data.ActorTrackingAdd(self.Player)
	
	;;;;;;;;

	self.UnregisterForModEvent("SexLabOrgasm")
	self.RegisterForModEvent("SexLabOrgasm","OnModEvent_SexLabOrgasm")

	self.Player.AddSpell(self.SpellMenuMainOpen)
	self.Util.Print("Soulgem Oven 4 has started.")
	Return
EndEvent

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Function ResetConfig()

	self.Config.Reset()
	self.Config.Stop()
	self.Config.Start()
	Return
EndFunction

Function ResetLoop()

	self.Loop.Reset()
	self.Loop.Stop()
	self.Loop.Start()
EndFunction

Function ResetMod()

	self.Reset()
	self.Stop()
	self.Start()
	Return
EndFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Bool Function CheckForDeps(Bool Popup)
{make sure we have everything we need installed.}

	Bool Output = TRUE

	If(!self.CheckForDeps_SexLab(Popup))
		self.SexLab = NONE
		Output = FALSE
	EndIf

	Return Output
EndFunction

Bool Function CheckForDeps_SexLab(Bool Popup)
{make sure we have sexlab installed and minimum version.}

	self.SexLab = Util.GetFormFrom("SexLab.esm",0xd62) As SexLabFramework

	;; check we even have sexlab.

	If(self.SexLab == NONE)
		If(Popup)
			self.Util.PopupError("SexLab is not installed.")
		EndIf

		Return FALSE
	EndIf

	;; check that the version of sexlab is good enough.

	If(self.SexLab.GetVersion() < 16203)
		If(Popup)
			self.Util.PopupError("Your SexLab needs to be updated. Install 1.63 SE dev 3 or newer.")
		EndIf

		self.SexLab = NONE
		Return FALSE
	EndIf

	Return TRUE
EndFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Function OnModEvent_SexLabOrgasm(Form Whom, Int Enjoy, Int OCount)

	Actor Who = Whom as Actor
	Actor Oven
	sslThreadController Thread
	sslBaseAnimation Animation
	Actor[] ActorList
	Int ActorIter
	Float PregRoll = 0.0
	Float PregChance = Config.GetFloat("FertilityChance")

	;;;;;;;;

	;; grab info from sexlab.

	Thread = SexLab.GetActorController(Who)

	If(Thread == None)
		Util.PrintDebug("Failed to get SexLab thread controller.")
	EndIf

	Animation = Thread.Animation
	ActorList = Thread.Positions

	;;;;;;;;

	;; prime the actor biological abilities.

	ActorIter = 0

	While(ActorIter < ActorList.Length)
		Data.ActorDetermineFeatures(ActorList[ActorIter])
		ActorIter += 1
	EndWhile

	;;;;;;;;

	;; determine what to do.

	If(!Who.IsInFaction(FactionProduceSemen))
		;; bail if the cummer is not producing semen.
		Util.PrintDebug("Preg Abort: " + Who.GetDisplayName() + " is not a semen producer.")
		Return
	EndIf

	If(ActorList.Length == 1)
		;; bail if it was a solo mission.
		;; todo - drop semen bottle.
		Util.PrintDebug("Preg Abort: " + Who.GetDisplayName() + " is fapping.")
		Return
	EndIf

	If(!Animation.IsVaginal && !Animation.IsAnal)
		;; bail if it was not an insertion animation.
		Util.PrintDebug("Preg Abort: Animation was not an insertion.")
		Return
	EndIf

	;; pick someone to greginate

	Oven = None
	ActorIter = 0

	While(ActorIter < ActorList.Length)
		If(ActorList[ActorIter] != Who && ActorList[ActorIter].IsInFaction(FactionProduceGems))
			Oven = ActorList[ActorIter]
			ActorIter = ActorList.Length
		EndIf
		ActorIter += 1
	EndWhile

	If(Oven == None)
		;; bail because no ovens were found.
		Util.PrintDebug("Preg Abort: No valid ovens found.")
		Return
	EndIf

	;;;;;;;;

	PregRoll = Utility.RandomFloat(0.0,100.0) * Data.ActorFertilityFactor(Oven)
	Util.PrintDebug("Preg Chance For " + Oven.GetDisplayName() + " If(" + PregRoll + " >= " + PregChance + "%)")

	If(PregRoll >= (100.0 - PregChance))
		If(Data.ActorGemAdd(Oven,0.0))
			If(Oven == self.Player)
				Util.PrintLookupRandom("FlavourPlayerGemGain",Oven.GetDisplayName())
			Else
				Util.PrintLookupRandom("FlavourActorGemGain",Oven.GetDisplayName())
			EndIf
			Util.PrintDebug(Oven.GetDisplayName() + " is now incubating another gem.")
		Else
			Util.PrintLookup("CannotFitMoreGems",Oven.GetDisplayName())
			Util.PrintDebug(Oven.GetDisplayName() + " cannot fit any more gems.")
		EndIf
	EndIf

	;;;;;;;;

	Return
EndFunction

Event OnMenuOpen(String Name)
{handler for our menu hack}

	If(Name == "Sleep/Wait Menu")

	EndIf

	Return
EndEvent

Event OnMenuClose(String Name)
{handler for our menu hack}

	If(Name == "Sleep/Wait Menu")
		Loop.UnregisterForUpdate()
		Loop.OnUpdate()
	EndIf

	Return
EndEvent

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Actor Function MenuTargetGet(Actor Who=None)
{determine if we should target someone.}

	If(Who == None)
		Who = Game.GetCurrentCrosshairRef() as Actor
	EndIf

	If(Who == None)
		Who = self.Player
	EndIf

	Return Who
EndFunction

Function MenuWheelSetItem(Int Num, String Label, String Text, Bool Enabled=True)
{assign an item to the uiextensions wheel menu.}

	UIExtensions.SetMenuPropertyIndexString("UIWheelMenu","optionLabelText",Num,Label)
	UIExtensions.SetMenuPropertyIndexString("UIWheelMenu","optionText",Num,Text)
	UIExtensions.SetMenuPropertyIndexBool("UIWheelMenu","optionEnabled",Num,Enabled)

	If(!Enabled)
		UIExtensions.SetMenuPropertyIndexInt("UIWheelMenu","optionTextColor",Num,0x555555)
	EndIf

	Return
EndFunction

Function MenuWheelPopulate(String[] ItemText, String[] ItemDesc, Bool[] ItemShow)
{populate the wheel menu from some data arrays.}
	
	Int Iter

	;;;;;;;;

	UIExtensions.InitMenu("UIWheelMenu")

	Iter = 0
	While(Iter < ItemShow.Length)
		self.MenuWheelSetItem(Iter,ItemText[Iter],ItemDesc[Iter],ItemShow[Iter])
		Iter += 1
	EndWhile

	Return
EndFunction

Int Function MenuWheelPopulateOpen(Actor Who, String[] ItemText, String[] ItemDesc, Bool[] ItemShow)
{populate and open the wheel menu.}

	self.MenuWheelPopulate(ItemText,ItemDesc,ItemShow)

	Return UIExtensions.OpenMenu("UIWheelMenu",Who)
EndFunction

Function MenuMainOpen(Actor Who=None)
{open up the primary sgo menu.}

	String[] ItemText = new String[8]
	String[] ItemDesc = new String[8]
	Bool[] ItemShow = new Bool[8]
	Int Iter
	Int Result

	Int GemCount
	Int GemMax
	Int MilkCount
	Int SemenCount

	Who = self.MenuTargetGet(Who)
	self.Data.ActorDetermineFeatures(Who)

	;;;;;;;;

	;; 0 insert gems | 4 gem status
	;; 1 xfer gems   | 5 milk status
	;; 2 insert sem  | 6 semen status
	;; 3 actor opts  | 7 actor stats

	ItemText[0] = "$SGO4_MenuInsertGemsText"
	ItemDesc[0] = "$SGO4_MenuInsertGemsDesc"
	ItemShow[0] = Who.IsInFaction(self.FactionProduceGems)

	ItemText[1] = "$SGO4_MenuTransferGemsText"
	ItemDesc[1] = "$SGO4_MenuTransferGemsDesc"
	ItemShow[1] = Who.IsInFaction(self.FactionProduceGems)

	ItemText[2] = "$SGO4_MenuInsertSemenText"
	ItemDesc[2] = "$SGO4_MenuInsertSemenDesc"
	ItemShow[2] = Who.IsInFaction(self.FactionProduceGems)

	ItemText[3] = "$SGO4_MenuActorOptionsText"
	ItemDesc[3] = "$SGO4_MenuActorOptionsDesc"
	ItemShow[3] = TRUE

	ItemText[4] = "$SGO4_MenuActorGemsEmptyText"
	ItemDesc[4] = "$SGO4_MenuActorGemsEmptyDesc"
	ItemShow[4] = FALSE

	ItemText[5] = "$SGO4_MenuActorMilkEmptyText"
	ItemDesc[5] = "$SGO4_MenuActorMilkEmptyDesc"
	ItemShow[5] = FALSE

	ItemText[6] = "$SGO4_MenuActorSemenEmptyText"
	ItemDesc[6] = "$SGO4_MenuActorSemenEmptyDesc"
	ItemShow[6] = FALSE

	ItemText[7] = "$SGO4_MenuActorStatsText"
	ItemDesc[7] = "$SGO4_MenuActorStatsDesc"
	ItemShow[7] = TRUE

	GemCount = self.Data.ActorGemCount(Who)
	GemMax = self.Data.ActorGemMax(Who)
	MilkCount = self.Data.ActorMilkCount(Who)
	SemenCount = self.Data.ActorSemenCount(Who)

	If(Who.IsInFaction(self.FactionProduceGems) && GemCount > 0)
		ItemText[4] = self.Util.StringLookup("MenuGemCount",GemCount)
		ItemDesc[4] = "$SGO4_MenuActorGemsSelectDesc"
		ItemShow[4] = TRUE

		If(GemCount >= GemMax)
			ItemShow[0] = FALSE
			ItemShow[2] = FALSE
		EndIf
	EndIf

	If(Who.IsInFaction(self.FactionProduceMilk) && MilkCount > 0)
		ItemText[5] = self.Util.StringLookup("MenuMilkCount",MilkCount)
		ItemDesc[5] = "$SGO4_MenuActorMilkSelectDesc"
		ItemShow[5] = TRUE
	EndIf

	If(Who.IsInFaction(self.FactionProduceSemen) && SemenCount > 0)
		ItemText[6] = self.Util.StringLookup("MenuSemenCount",SemenCount)
		ItemDesc[6] = "$SGO4_MenuActorSemenSelectDesc"
		ItemShow[6] = TRUE
	EndIf

	;;;;;;;;

	Result = self.MenuWheelPopulateOpen(Who,ItemText,ItemDesc,ItemShow)
	self.Util.PrintDebug("Selected " + Result + ": " + ItemText[Result])

	If(Result == 0)
		;; insert gems
		self.SpellInsertGems.Cast(self.Player,self.Player)
	ElseIf(Result == 1)
		;; xfer gems
		Debug.MessageBox("Cumming Soon (tm)")
	ElseIf(Result == 2)
		;; inseminate
		Debug.MessageBox("TODO")
	ElseIf(Result == 3)
		;; actor options
		self.MenuActorOptionsOpen(Who)
	ElseIf(Result == 4)
		;; birth
		self.SpellBirthLargest.Cast(self.Player,self.Player)
	ElseIf(Result == 5)
		;; milk
		self.SpellMilkingAction.Cast(self.Player,self.Player)
	ElseIf(Result == 6)
		;; wank
		self.SpellWankingAction.Cast(self.Player,self.Player)
	ElseIf(Result == 7)
		;; stats
		self.MenuActorStatsOpen(Who)
	EndIf

	Return
EndFunction

Function MenuActorOptionsOpen(Actor Who=None)
{open up the primary sgo menu.}

	String[] ItemText = new String[8]
	String[] ItemDesc = new String[8]
	Bool[] ItemShow = new Bool[8]
	Int Result
	Bool CanGem
	Bool CanMilk
	Bool CanSemen

	Who = self.MenuTargetGet(Who)
	self.Data.ActorDetermineFeatures(Who)

	CanGem = Who.IsInFaction(self.FactionProduceGems)
	CanMilk = Who.IsInFaction(self.FactionProduceMilk)
	CanSemen = Who.IsInFaction(self.FactionProduceSemen)

	;;;;;;;;

	;; 0 toggle gems  | 4
	;; 1 toggle milk  | 5
	;; 2 toggle semen | 6
	;; 3              | 7

	ItemText[0] = "$SGO4_MenuProduceGemsOff"
	ItemDesc[0] = "$SGO4_MenuProduceGemsDesc"
	ItemShow[0] = TRUE

	ItemText[1] = "$SGO4_MenuProduceMilkOff"
	ItemDesc[1] = "$SGO4_MenuProduceMilkDesc"
	ItemShow[1] = TRUE

	ItemText[2] = "$SGO4_MenuProduceSemenOff"
	ItemDesc[2] = "$SGO4_MenuProduceSemenDesc"
	ItemShow[2] = TRUE

	If(CanGem)
		ItemText[0] = "$SGO4_MenuProduceGemsOn"
	EndIf

	If(CanMilk)
		ItemText[0] = "$SGO4_MenuProduceMilkOn"
	EndIf

	If(CanSemen)
		ItemText[0] = "$SGO4_MenuProduceSemenOn"
	EndIf

	;;;;;;;;

	Result = self.MenuWheelPopulateOpen(Who,ItemText,ItemDesc,ItemShow)
	self.Util.PrintDebug("Selected " + Result + ": " + ItemText[Result])

	If(Result == 0)
		self.Util.ActorToggleFaction(Who,self.FactionProduceGems)
	ElseIf(Result == 1)
		self.Util.ActorToggleFaction(Who,self.FactionProduceMilk)
	ElseIf(Result == 2)
		self.Util.ActorToggleFaction(Who,self.FactionProduceSemen)
	EndIf

	Return
EndFunction

Function MenuTransferGemsOpen(Actor Who=None)
{open the gem transfer menu.}

	Return
EndFunction

Function MenuActorStatsOpen(Actor Who=None)
{open the actor stats menu.}

	UIListMenu Menu = UIExtensions.GetMenu("UIListMenu",TRUE) as UIListMenu
	Int NoParent = -1

	;;;;;;;;

	Who = self.MenuTargetGet(Who)
	self.Data.ActorDetermineFeatures(Who)

	;;;;;;;;

	Menu.AddEntryItem("$SGO4_MenuStatGemsIncubated",NoParent)
	Menu.AddEntryItem(Stats.GetInt(Who,Stats.KeyGemsIncubated),NoParent)
	Menu.AddEntryItem(" ",NoParent)

	Menu.AddEntryItem("$SGO4_MenuStatGemsBirthed",NoParent)
	Menu.AddEntryItem(Stats.GetInt(Who,Stats.KeyGemsBirthed),NoParent)
	Menu.AddEntryItem(" ",NoParent)

	Menu.AddEntryItem("$SGO4_MenuStatGemsInseminated",NoParent)
	Menu.AddEntryItem(Stats.GetInt(Who,Stats.KeyGemsInseminated),NoParent)
	Menu.AddEntryItem(" ",NoParent)

	Menu.AddEntryItem("$SGO4_MenuStatGemsInserted",NoParent)
	Menu.AddEntryItem(Stats.GetInt(Who,Stats.KeyGemsInserted),NoParent)
	Menu.AddEntryItem(" ",NoParent)

	Menu.AddEntryItem("$SGO4_MenuStatMilksProduced",NoParent)
	Menu.AddEntryItem(Stats.GetInt(Who,Stats.KeyMilksProduced),NoParent)
	Menu.AddEntryItem(" ",NoParent)

	Menu.AddEntryItem("$SGO4_MenuStatMilksMilked",NoParent)
	Menu.AddEntryItem(Stats.GetInt(Who,Stats.KeyMilksMilked),NoParent)
	Menu.AddEntryItem(" ",NoParent)

	Menu.AddEntryItem("$SGO4_MenuStatSemensProduced",NoParent)
	Menu.AddEntryItem(Stats.GetInt(Who,Stats.KeySemensProduced),NoParent)
	Menu.AddEntryItem(" ",NoParent)

	Menu.AddEntryItem("$SGO4_MenuStatSemensWanked",NoParent)
	Menu.AddEntryItem(Stats.GetInt(Who,Stats.KeySemensWanked),NoParent)
	Menu.AddEntryItem(" ",NoParent)

	UIExtensions.OpenMenu("UIListMenu",Who)
	Return
EndFunction

