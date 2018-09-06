ScriptName dse_sgo_QuestDatabase_Main Extends Quest

dse_sgo_QuestController_Main Property Main Auto

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

String Property KeyGemStageData = "SGO.Gem.Stages" AutoReadOnly Hidden
{Global.FormList}

String Property KeyActorTracking = "SGO.Actor.Tracking" AutoReadOnly Hidden
{Global.FormList}

String Property KeyActorGemData = "SGO4.Actor.Gems" AutoReadOnly Hidden
{Actor.FloatList}

String Property KeyActorMilkData = "SGO4.Actor.Milk" AutoReadOnly Hidden
{Actor.FloatValue}

String Property KeyActorSemenData = "SGO4.Actor.Semen" AutoReadOnly Hidden
{Actor.FloatValue}

String Property KeyActorModListPrefix = "SGO4.Actor.Mod." AutoReadOnly Hidden
{Generates Actor.StringLists}

String Property KeyActorModValuePrefix = "SGO4.Actor.ModValue." AutoReadOnly Hidden
{Generates Actor.FloatValues}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; idea: passing an actor to these could allow you to install custom birthing
;; lists to each actor so they can birth different things. in the case of
;; get and count if no data exists fallback to the global data.

Function GemStagePopulate()
{populate the gem dataset based on the the configuration.}

	Int Mode = Main.Config.GetInt("BirthGemsFilled")

	StorageUtil.FormListClear(None,self.KeyGemStageData)

	If(Mode == 1)
		StorageUtil.FormListCopy(None,self.KeyGemStageData,self.GetGemStagesFilled())
	ElseIf(Mode == 0)
		StorageUtil.FormListCopy(None,self.KeyGemStageData,self.GetGemStagesEmpty())
	ElseIf(Mode == -1)
		;; i still need to work out how you can generate a custom
		;; list of things to birth.
	EndIf

	Return
EndFunction

Form[] Function GetGemStagesFilled()
{fill the gem dataset with the empty gems.}

	Form[] Gems = new Form[6]
	Gems[0] = Main.Util.GetFormFrom("Skyrim.esm",0x2e4e3)
	Gems[1] = Main.Util.GetFormFrom("Skyrim.esm",0x2e4e5)
	Gems[2] = Main.Util.GetFormFrom("Skyrim.esm",0x2e4f3)
	Gems[3] = Main.Util.GetFormFrom("Skyrim.esm",0x2e4fb)
	Gems[4] = Main.Util.GetFormFrom("Skyrim.esm",0x2e4ff)
	Gems[5] = Main.Util.GetFormFrom("Skyrim.esm",0x2e504)

	Return Gems
EndFunction

Form[] Function GetGemStagesEmpty()
{fill the gem dataset with the empty gems.}

	Form[] Gems = new Form[6]
	Gems[0] = Main.Util.GetFormFrom("Skyrim.esm",0x2e4e2)
	Gems[1] = Main.Util.GetFormFrom("Skyrim.esm",0x2e4e4)
	Gems[2] = Main.Util.GetFormFrom("Skyrim.esm",0x2e4e6)
	Gems[3] = Main.Util.GetFormFrom("Skyrim.esm",0x2e4f4)
	Gems[4] = Main.Util.GetFormFrom("Skyrim.esm",0x2e4fc)
	Gems[5] = Main.Util.GetFormFrom("Skyrim.esm",0x2e500)

	Return Gems
EndFunction

Int Function GemStageCount()
{count how many gems are in the dataset.}

	Return StorageUtil.FormListCount(None,KeyGemStageData)
EndFunction

Form Function GemStageGet(Int Index)
{}

	Return StorageUtil.FormListGet(None,KeyGemStageData,Index)
EndFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Function ActorTrackingAdd(Actor Who)
{it does not matter why we want to track the actor. for any reason they get
added to this list.}

	StorageUtil.FormListAdd(None,KeyActorTracking,Who,FALSE)

	;; persist hack.
	Who.UnregisterForUpdate()
	Who.RegisterForUpdate(600)

	;; track animation events for actors we are watching.
	Main.Body.RegisterForCustomAnimationEvents(Who)

	Main.Util.PrintDebug(Who.GetDisplayName() + " is now being tracked.")
	Return
EndFunction

Actor Function ActorTrackingGet(Int Index)
{get the specified actor at the index.}

	Return StorageUtil.FormListGet(None,KeyActorTracking,Index) As Actor
EndFunction

Int Function ActorTrackingCount()
{count how many actors we are tracking.}

	Return StorageUtil.FormListCount(None,KeyActorTracking)
EndFunction

Function ActorTrackingCull()
{remove any actors that vanished.}

	StorageUtil.FormListRemove(None,KeyActorTracking,None,TRUE)

	Return
EndFunction

Bool function IsActorTracked(Actor Who)
{determine if we are tracking this actor or not.}

	Return StorageUtil.FormListHas(None,KeyActorTracking,Who)
EndFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Float function ActorModGetFinal(Actor Who, String What, Float Base=1.0)
{get the final value which is the base plus/minus the buffs/debuffs.}

	Float Val = Base + self.ActorModGetBonus(Who,What,Base)

	Return Val
EndFunction

Float Function ActorModGetBonus(Actor Who, String What, Float Base=1.0)
{get the total additive bonus based off the base value.}

	Float Val = Base * self.ActorModGetTotal(Who,What)

	Return Val
EndFunction

Float Function ActorModGetTotal(Actor Who, String What)
{get the total bonus value from all the multiplier mods.}

	String ListName = KeyActorModListPrefix + What
	Int ModCount = StorageUtil.StringListCount(Who,ListName)
	Float Val = 0.0
	String ValueName

	While(ModCount > 0)
		ModCount -= 1

		ValueName = StorageUtil.StringListGet(Who,ListName,ModCount)
		Val += StorageUtil.GetFloatValue(Who,ValueName)
	EndWhile

	Return Val
EndFunction

Function ActorModSetValue(Actor Who, String What, String ModKey, Float Val=0.0)
{add/set a buff to the actor.}

	String ListName = KeyActorModListPrefix + What
	String ValueName = KeyActorModValuePrefix + What + "." + ModKey

	StorageUtil.StringListAdd(Who,ListName,ValueName,FALSE)
	StorageUtil.SetFloatValue(Who,ValueName,Val)

	Main.Util.PrintDebug("Mod " + Who.GetDisplayName() + " " + ValueName + "=" + Val + " Added")
	Return
EndFunction

Function ActorModUnsetValue(Actor Who, String What, String ModKey)
{remove a buff from an actor.}

	String ListName = KeyActorModListPrefix + What
	String ValueName = KeyActorModValuePrefix + What + "." + ModKey

	StorageUtil.StringListRemove(Who,ListName,ValueName,TRUE)
	StorageUtil.UnsetFloatValue(Who,ValueName)

	Main.Util.PrintDebug("Mod " + Who.GetDisplayName() + " " + ValueName + " Removed")
	Return
EndFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Bool Function ActorGemAdd(Actor Who, Float Val=0.0)
{insert a new gem into the dataset. returns if successful or not.}

	If(self.ActorGemCount(Who) >= self.ActorGemMax(Who))
		Return FALSE
	EndIf

	StorageUtil.FloatListAdd(Who,self.KeyActorGemData,Val)
	Return TRUE
EndFunction

Function ActorGemClear(Actor Who)
{drop all gem data for this actor.}

	StorageUtil.FloatListClear(Who,self.KeyActorGemData)

	Return
EndFunction

Float Function ActorGemGet(Actor Who, Int Index)
{get the value of a specific gem in an actor.}

	Return StorageUtil.FloatListGet(Who,KeyActorGemData,Index)
EndFunction

Int Function ActorGemCount(Actor Who)
{return how many gems an actor is currently incubating.}

	Return StorageUtil.FloatListCount(Who,self.KeyActorGemData)
EndFunction

Int Function ActorGemMax(Actor Who)
{return how many gems an actor can incubate at one time. it is rounded in the
event with mods its a fraction of a gem.}

	Int Base = Main.Config.GetInt("ActorGemsMax")
	Float Val = self.ActorModGetFinal(Who,"GemsMax",Base)
	
	Return Main.Util.RoundToInt(Val)
EndFunction

Float Function ActorGemTotalPercent(Actor Who)
{get the current state of fullness of the gems.}

	;; if we get values larger than expected gracefully roll them down to
	;; their max. this could happen in the event if like a buff had expired
	;; right before updating.

	Int GemStages = self.GemStageCount()
	Int GemCount = self.ActorGemCount(Who)
	Int ValueMax = (self.ActorGemMax(Who) * GemStages)
	Int GemIter = 0
	Float Value = 0.0
	Float Current = 0.0

	While(GemIter < GemCount)
		Current = self.ActorGemGet(Who,GemIter)

		If(Current > GemStages)
			Current = GemStages as Float
		EndIf

		Value += Current
		GemIter += 1
	EndWhile

	If(Value > ValueMax)
		Value = ValueMax as Float
	EndIf

	;;Main.Util.PrintDebug(GemStages + ", " + GemCount + ", " + ValueMax + ", " + Value)

	Return (Value / (ValueMax as Float))
EndFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Function ActorMilkSet(Actor Who, Float Value)
{set how much milk the actor should have.}

	StorageUtil.SetFloatValue(Who,self.KeyActorMilkData,Value)
	Return
EndFunction

Function ActorMilkAdjust(Actor Who, Float Value)
{add/sub how much milk this actor has.}

	StorageUtil.AdjustFloatValue(Who,self.KeyActorMilkData,Value)
	Return
EndFunction

Float Function ActorMilkAmount(Actor Who)
{return how much milk an actor has.}

	Return StorageUtil.GetFloatValue(Who,self.KeyActorMilkData)
EndFunction

Function ActorMilkClear(Actor Who)
{drop milk data for this actor.}

	StorageUtil.SetFloatValue(Who,self.KeyActorMilkData,0.0)
	Return
EndFunction

Int Function ActorMilkMax(Actor Who)
{return how much milk an actor can have at once.}

	Int Base = Main.Config.GetInt("ActorMilkMax")
	Float Val = self.ActorModGetFinal(Who,"MilkMax",Base)

	Return Main.Util.RoundToInt(Val)
EndFunction

Float Function ActorMilkTotalPercent(Actor Who)
{get the current state of fullness of milk.}

	Float MilkAmount = self.ActorMilkAmount(Who)
	Int ValueMax = self.ActorMilkMax(Who)

	Return (MilkAmount / (ValueMax as Float))
EndFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Float Function ActorSemenAmount(Actor Who)
{return how much semen an actor has.}

	Return StorageUtil.GetFloatValue(Who,self.KeyActorSemenData)
EndFunction

Int Function ActorSemenMax(Actor Who)
{return how many bottles of semen an actor can have at once.}

	Int Base = Main.Config.GetInt("ActorSemenMax")
	Float Val = self.ActorModGetFinal(Who,"SemenMax",Base)

	Return Main.Util.RoundToInt(Val)
EndFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


