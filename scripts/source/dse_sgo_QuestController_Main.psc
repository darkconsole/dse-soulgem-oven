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
Container Property ContainInsertSemens Auto
FormList Property ListGemFilter Auto
FormList property ListSemenFilter Auto
Faction Property FactionProduceGems Auto
Faction Property FactionProduceMilk Auto
Faction Property FactionProduceSemen Auto
Faction Property FactionNoBodyScale Auto
Spell Property SpellActorDataScan Auto
Spell Property SpellActorDataScanToggle Auto
Spell Property SpellInsertGems Auto
Spell Property SpellInsertSemens Auto
Spell Property SpellInfluenceGems Auto
Spell Property SpellInfluenceMilk Auto
Spell Property SpellMenuMainOpen Auto
Spell Property SpellBirthingAction Auto
Spell Property SpellMilkingAction Auto
Spell Property SpellWankingAction Auto
Package Property PackageDoNothing Auto

FormList Property ListPackageBirth Auto
FormList Property ListPackageMilking Auto
FormList Property ListPackageWanking Auto
;;FormList Property ListPackageInserting Auto
;;FormList Property ListPackageInseminating Auto

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

String Property KeyESP = "dse-soulgem-oven.esp" AutoReadOnly Hidden
String Property KeySplashGraphic = "dse-soulgem-oven/splash.dds" AutoReadOnly Hidden
Bool Property OptValidateActor = TRUE Auto Hidden

dse_sgo_QuestController_Main Function Get() Global
{static method for grabbing a quick handle to the api.}

	Return Game.GetFormFromFile(0xD61,"dse-soulgem-oven.esp") As dse_sgo_QuestController_Main
EndFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Event OnInit()
{handle install/reset.}

	Int Wait = 0

	If(self.IsStopped())
		Return
	EndIf

	;; don't allow activation if there is something wrong with the dependencies.

	If(!self.CheckForDeps(TRUE))
		self.Reset()
		self.Stop()
		Return
	EndIf

	;; start the configuration menu.

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

	;; start the background processor.

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

	;; go ahead and ping the player with tracking now to prime their
	;; biological features.

	self.Data.ActorTrackingAdd(self.Player)
	
	;; handle sexlab events.

	self.UnregisterForModEvent("SexLabOrgasm")
	self.RegisterForModEvent("SexLabOrgasm","OnModEvent_SexLabOrgasm")

	;; give the player the menu systems.

	self.Player.AddSpell(self.SpellMenuMainOpen)
	self.Player.AddSpell(self.SpellActorDataScanToggle)

	;;;;;;;;

	self.Util.PrintLookup("SoulgemOvenStart")
	Return
EndEvent

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Function ResetConfig()
{reset the config menu library.}

	self.Config.Reset()
	self.Config.Stop()
	self.Config.Start()

	Return
EndFunction

Function ResetLoop()
{reset the background processor library.}

	self.Loop.Reset()
	self.Loop.Stop()
	self.Loop.Start()

	Return
EndFunction

Function ResetMod()
{reset the entire mod.}

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

	;;;;;;;;

	;; serious things that should brick the game if they aren't correct.

	If(!self.CheckForDeps_SKSE(Popup))
		Output = FALSE
	EndIf

	If(!self.CheckForDeps_SkyUI(Popup))
		Output = FALSE
	EndIf

	If(!self.CheckForDeps_SexLab(Popup))
		Output = FALSE
	EndIf

	If(!self.CheckForDeps_PapyrusUtil(Popup))
		Output = FALSE
	EndIf

	If(!self.CheckForDeps_RaceMenu(Popup))
		Output = FALSE
	EndIf

	If(!self.CheckForDeps_UIExtensions(Popup))
		Output = FALSE
	EndIf

	;; non serious things that should not break the game.

	;;self.CheckForDeps_RaceMenuMorphs(Popup)

	;;;;;;;;

	Return Output
EndFunction

Bool Function CheckForDeps_SKSE(Bool Popup)
{make sure skse is new enough.}

	If(SKSE.GetScriptVersionRelease() < 56)
		If(Popup)
			self.Util.PopupError("You need to update your SKSE to 2.0.7 or newer.")
		EndIf

		Return FALSE
	EndIf

	Return TRUE
EndFunction

Bool Function CheckForDeps_SkyUI(Bool Popup)
{make sure we have ui extensions installed and up to date.}

	If(!Game.IsPluginInstalled("SkyUI_SE.esp"))
		If(Popup)
			self.Util.PopupError("SkyUI SE 5.2 or newer must be installed.")
		EndIf
		Return FALSE
	EndIf

	Return TRUE
EndFunction

Bool Function CheckForDeps_SexLab(Bool Popup)
{make sure we have sexlab installed and minimum version.}

	self.SexLab = Util.GetFormFrom("SexLab.esm",0xd62) As SexLabFramework

	;; check we even have sexlab.

	If(self.SexLab == NONE)
		If(Popup)
			self.Util.PopupError("SexLab SE 1.63 Beta 2 or newer must be installed.")
		EndIf

		Return FALSE
	EndIf

	;; check that the version of sexlab is good enough.

	If(self.SexLab.GetVersion() < 16202)
		If(Popup)
			self.Util.PopupError("Your SexLab needs to be updated. Install 1.63 SE Beta 2 or newer.")
		EndIf

		self.SexLab = NONE
		Return FALSE
	EndIf

	Return TRUE
EndFunction

Bool Function CheckForDeps_PapyrusUtil(Bool Popup)
{make sure papyrus util is new enough. mostly to detect if someone overwrote
the one that comes in sexlab with an old version.}

	If(PapyrusUtil.GetScriptVersion() < 34)
		If(Popup)
			self.Util.PopupError("Your PapyrusUtil is out of date. It is likely some other mod overwrote the version that came in SexLab.")
			Return FALSE
		EndIf
	EndIf

	Return TRUE
EndFunction

Bool Function CheckForDeps_RaceMenu(Bool Popup)
{make sure we have racemenu installed and up to date.}

	Bool Output = TRUE

	;; hard fail if no racemenu.

	;;If(!Game.IsPluginInstalled("RaceMenu.esp"))
	;;	If(Popup)
	;;		self.Util.PopupError("RaceMenu SE 0.2.4 or newer must be installed.")
	;;	EndIf
	;;	Output = FALSE
	;;EndIf

	If(NiOverride.GetScriptVersion() < 6)
		If(Popup)
			self.Util.PopupError("NiOverride is out of date. Install Racemenu SE 0.2.4 newer and make sure nothing has overwritten it with older versions.")
		EndIf
		Output = FALSE
	EndIf

	Return Output
EndFunction

Bool Function CheckForDeps_RaceMenuMorphs(Bool Popup)
{make sure we have race menu morphs installed.}

	Bool Output = FALSE
	Int Iter

	;;;;;;;;

	String[] Plugins = new String[4]
	Plugins[0] = "RaceMenuMorphsCBBE.esp"
	Plugins[1] = "RaceMenuMorphsTBD.esp"
	Plugins[2] = "RaceMenuMorphsUUNP.esp"
	Plugins[3] = "RaceMenuMorphsBHUNP.esp"

	;;;;;;;;

	Iter = 0
	While(Iter < Plugins.Length)
		If(Game.IsPluginInstalled(Plugins[Iter]))
			Output = TRUE
			Iter = Plugins.Length
		EndIf
		Iter += 1
	EndWhile

	If(!Output && Popup)
		self.Util.PopupError("It appears have no BodyMorphs installed. You may not see any body scaling.")
	EndIf

	Return Output
EndFunction

Bool Function CheckForDeps_UIExtensions(Bool Popup)
{make sure we have ui extensions installed and up to date.}

	If(!Game.IsPluginInstalled("UIExtensions.esp"))
		If(Popup)
			self.Util.PopupError("UI Extensions 1.2.0+ must be installed.")
		EndIf
		Return FALSE
	EndIf

	Return TRUE
EndFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Function OnModEvent_SexLabOrgasm(Form Whom, Int Enjoy, Int OCount)
{handler for sexlab orgasm events.}

	Actor Who = Whom as Actor
	Actor Oven
	sslThreadController Thread
	sslBaseAnimation Animation
	Actor[] ActorList
	Int ActorIter
	Float PregRoll = 0.0
	Float PregChance = Config.GetFloat(".FertilityChance")
	Float SemenAmount = 0.0

	;; do nothing if we're powered down.

	If(!self.IsRunning())
		Return
	EndIf

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

	;; determine if we do.

	If(!Who.IsInFaction(FactionProduceSemen))
		;; bail if the cummer is not producing semen.
		Util.PrintDebug("Preg Abort: " + Who.GetDisplayName() + " is not a semen producer.")
		Return
	ElseIf(Data.ActorSemenAmount(Who,FALSE) < 1.0)
		;; if they are low on semen give them a scaling chance.
		SemenAmount = Data.ActorSemenAmount(Who,FALSE)
		If(Utility.RandomInt(0,99) >= (SemenAmount * 100))
			Data.ActorSemenSet(Who,0.0)
			Util.PrintDebug("Preg Abort: " + Who.GetDisplayName() + " failed low semen chance.")
			Return
		EndIf
	EndIf

	;; they blew a load so deduct it.

	Data.ActorSemenLimit(Who)
	Data.ActorSemenInc(Who,-1.0)

	;; determine where we do.

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
		If(Config.GetBool(".UpdateAfterWait"))
			Loop.UnregisterForUpdate()
			Loop.OnUpdate()
		EndIf
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

	If(!self.Util.ActorIsValid(Who))
		self.Util.PrintLookup("ActorNotValid",Who.GetDisplayName())
		Return
	EndIf

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
	If(Result < 0)
		self.Util.PrintDebug("Main Menu Canceled")
		Return
	EndIf

	self.Util.PrintDebug("Selected " + Result + ": " + ItemText[Result])

	If(Result == 0)
		;; insert gems
		self.SpellInsertGems.Cast(Who,Who)
	ElseIf(Result == 1)
		;; xfer gems
		self.MenuTransferGemsOpen(Who)
	ElseIf(Result == 2)
		;; inseminate
		self.SpellInsertSemens.Cast(Who,Who)
	ElseIf(Result == 3)
		;; actor options
		self.MenuActorOptionsOpen(Who)
	ElseIf(Result == 4)
		;; birth
		self.SpellBirthingAction.Cast(Who,Who)
	ElseIf(Result == 5)
		;; milk
		self.SpellMilkingAction.Cast(Who,Who)
	ElseIf(Result == 6)
		;; wank
		self.SpellWankingAction.Cast(Who,Who)
	ElseIf(Result == 7)
		;; stats
		self.MenuActorStatsOpen(Who)
	EndIf

	self.Player.SetVoiceRecoveryTime(0.1)

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
	Bool NoBodyScale

	Who = self.MenuTargetGet(Who)
	self.Data.ActorDetermineFeatures(Who)

	CanGem = Who.IsInFaction(self.FactionProduceGems)
	CanMilk = Who.IsInFaction(self.FactionProduceMilk)
	CanSemen = Who.IsInFaction(self.FactionProduceSemen)
	NoBodyScale = Who.IsInFaction(self.FactionNoBodyScale)

	;;;;;;;;

	;; 0 toggle gems  | 4 no body scale
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

	ItemText[4] = "$SGO4_MenuNoBodyScaleOn"
	ItemDesc[4] = "$SGO4_MenuNoBodyScaleDesc"
	ItemShow[4] = TRUE

	If(CanGem)
		ItemText[0] = "$SGO4_MenuProduceGemsOn"
	EndIf

	If(CanMilk)
		ItemText[1] = "$SGO4_MenuProduceMilkOn"
	EndIf

	If(CanSemen)
		ItemText[2] = "$SGO4_MenuProduceSemenOn"
	EndIf

	If(NoBodyScale)
		ItemText[4] = "$SGO4_MenuNoBodyScaleOff"
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
	ElseIf(Result == 4)
		self.Util.ActorToggleFaction(Who,self.FactionNoBodyScale)
		self.Body.ActorUpdate(Who,TRUE)
	EndIf

	Return
EndFunction

Function MenuTransferGemsOpen(Actor Who=None)
{open the gem transfer menu.}

	Debug.MessageBox("Cumming Soon (tm)")

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
