ScriptName dse_sgo_QuestDatabase_Main Extends Quest

dse_sgo_QuestController_Main Property Main Auto

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

String Property FileRaces = "../../../configs/dse-soulgem-oven/Races.json" AutoReadOnly Hidden

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

String Property KeyActorTimeUpdated = "SGO4.Actor.UpdateTime" AutoReadOnly Hidden
{Actor.FloatValue}

String Property KeyActorFertilityData = "SGO4.Actor.Fertility" AutoReadOnly Hidden
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

Form Function GemStageGet(Int Val)
{get the type of item for the selected stage.}

	If(Val < 1)
		Return None
	EndIf

	Return StorageUtil.FormListGet(None,KeyGemStageData,(Val - 1))
EndFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Function ActorTrackingAdd(Actor Who)
{it does not matter why we want to track the actor. for any reason they get
added to this list.}

	If(self.IsActorTracked(Who))
		;; if we are already tracking this actor give up now.
		Return
	EndIf

	StorageUtil.FormListAdd(None,KeyActorTracking,Who,FALSE)

	;; persist hack.
	Who.UnregisterForUpdate()
	Who.RegisterForUpdate(600)

	Main.Util.PrintDebug(Who.GetDisplayName() + " is now being tracked.")
	Return
EndFunction

Function ActorTrackingRemove(Actor Who)
{it does not matter why we want to track the actor. for any reason they get
added to this list.}

	StorageUtil.FormListRemove(None,KeyActorTracking,Who,TRUE)

	;; unpersist hack. (left for other mods.)
	;; Who.UnregisterForUpdate()

	;; untrack animations.
	Main.Body.UnregisterForCustomAnimationEvents(Who)

	Main.Util.PrintDebug(Who.GetDisplayName() + " is no longer being tracked.")
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

Function ActorUpdate(Actor Who)
{update the progression of actor's bio data.}

	Float TimeSince = self.ActorGetHoursSinceUpdate(Who)
	Bool Gems
	Bool Milk
	Bool Semen
	Bool Fertility

	If(TimeSince < Main.Config.GetFloat("UpdateGameHours"))
		Main.Util.PrintDebug(Who.GetDisplayName() + " not ready for calc.")
		Return
	EndIf
	
	Gems = self.ActorGemUpdateData(Who,TimeSince)
	Milk = self.ActorMilkUpdateData(Who,TimeSince)
	Semen = self.ActorSemenUpdateData(Who,TimeSince)
	Fertility = self.ActorFertilityUpdateData(Who,TimeSince)

	If(!Gems && !Milk && !Semen)
		;; if we bailed all three updates then there is no point to be
		;; tracking this actor.
		self.ActorTrackingRemove(Who)
		self.ActorSetTimeUpdated(Who,0.0)
		Return
	EndIf

	self.ActorSetTimeUpdated(Who)
	Return
EndFunction

Float Function ActorGetHoursSinceUpdate(Actor Who)
{return how many game hours have passed since this actor was last updated.}

	Float Current = Utility.GetCurrentGameTime()
	Float Last = StorageUtil.GetFloatValue(Who,self.KeyActorTimeUpdated,0.0)

	If(Last == 0.0)
		self.ActorSetTimeUpdated(Who)
		Last = Current
	EndIf

	Return (Current - Last) * 24
EndFunction

Function ActorSetTimeUpdated(Actor Who, Float When=0.0)
{set this actor as having just been updated.}

	If(When == 0.0)
		When = Utility.GetCurrentGameTime()
	EndIf

	StorageUtil.SetFloatValue(Who,self.KeyActorTimeUpdated,When)
	Return
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

	self.ActorTrackingAdd(Who)
	Main.Body.ActorUpdate(Who)

	Return TRUE
EndFunction

Function ActorGemClear(Actor Who)
{drop all gem data for this actor.}

	StorageUtil.FloatListClear(Who,self.KeyActorGemData)
	Main.Body.ActorUpdate(Who)

	Return
EndFunction

Float Function ActorGemGet(Actor Who, Int Index, Bool Limit=TRUE)
{get the value of a specific gem in an actor.}

	Int Max = self.GemStageCount()
	Float Gem = StorageUtil.FloatListGet(Who,KeyActorGemData,Index)

	If(Limit && Gem > Max)
		Gem = Max as Float
	EndIf

	Return Gem
EndFunction

Function ActorGemInc(Actor Who, Int Index, Float Inc)
{get the value of a specific gem in an actor.}

	StorageUtil.FloatListAdjust(Who,KeyActorGemData,Index,Inc)
	self.ActorTrackingAdd(Who)
	Main.Body.ActorUpdate(Who)

	Return
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

		Value += Current
		GemIter += 1
	EndWhile

	If(Value > ValueMax)
		Value = ValueMax as Float
	EndIf

	;;Main.Util.PrintDebug(GemStages + ", " + GemCount + ", " + ValueMax + ", " + Value)

	Return (Value / (ValueMax as Float))
EndFunction

Float Function ActorGemRemoveLargest(Actor Who)
{pull the largest gem out of the dataset.}

	Int Len = StorageUtil.FloatListCount(Who,self.KeyActorGemData)
	Float Out

	StorageUtil.FloatListSort(Who,self.KeyActorGemData)
	Out = self.ActorGemGet(Who,(Len - 1))

	StorageUtil.FloatListRemoveAt(Who,self.KeyActorGemData,(Len - 1))

	Main.Body.ActorUpdate(Who)
	Return Out
EndFunction

Bool Function ActorGemReady(Actor Who)
{return if this actor has any gems that have progressed far enough to birth.}

	Int GemCount = self.ActorGemCount(Who)
	Int GemIter = 0

	While(GemIter < GemCount)
		If(self.ActorGemGet(Who,GemIter) >= 1.0)
			Return TRUE
		EndIf
		GemIter += 1
	EndWhile

	Return FALSE
EndFunction

Bool Function ActorGemUpdateData(Actor Who, Float TimeSince)
{update the actors gem data given the time progression. returns false if this
actor is physically not capable of producing this item.}

	Float PerDay = Main.Config.GetFloat("GemsPerDay")
	Float Inc = ((TimeSince * PerDay) / 24.0)
	Int GemCount = self.ActorGemCount(Who)
	Int GemIter = 0

	;; todo - if not in gem faction, bail.

	If(GemCount == 0)
		Main.Util.PrintDebug(Who.GetDisplayName() + " is not incubating gems.")
		Return TRUE
	EndIf

	While(GemIter < GemCount)
		self.ActorGemInc(Who,GemIter,Inc)
		GemIter += 1
	EndWhile

	Main.Util.PrintDebug(Who.GetDisplayName() + " " + GemCount + " gems have progressed " + Inc)
	Return TRUE
EndFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Function ActorMilkSet(Actor Who, Float Value)
{set how much milk the actor should have.}

	StorageUtil.SetFloatValue(Who,self.KeyActorMilkData,Value)
	self.ActorTrackingAdd(Who)
	Main.Body.ActorUpdate(Who)

	Return
EndFunction

Function ActorMilkInc(Actor Who, Float Value)
{add/sub how much milk this actor has.}

	Float Milk = StorageUtil.AdjustFloatValue(Who,self.KeyActorMilkData,Value)
	Main.Util.PrintDebug(Who.GetDisplayName() + " now has " + Milk + " milk.")

	self.ActorTrackingAdd(Who)
	Main.Body.ActorUpdate(Who)

	Return
EndFunction

Function ActorMilkLimit(Actor Who)
{if this actor is over the limit on maximum milk, limit it.}

	Float Amount = self.ActorMilkAmount(Who,FALSE)
	Int Max = self.ActorMilkMax(Who)

	If(Amount > Max)
		self.ActorMilkSet(Who,Max as Float)
	EndIf

	Return
EndFunction

Float Function ActorMilkAmount(Actor Who, Bool Limit=TRUE)
{return how much milk an actor has.}

	Int MilkMax = self.ActorMilkMax(Who)
	Float MilkVal = StorageUtil.GetFloatValue(Who,self.KeyActorMilkData)

	If(Limit && MilkVal > MilkMax)
		MilkVal = MilkMax as Float
	EndIf

	Return MilkVal
EndFunction

Function ActorMilkClear(Actor Who)
{drop milk data for this actor.}

	StorageUtil.SetFloatValue(Who,self.KeyActorMilkData,0.0)
	Main.Body.ActorUpdate(Who)

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

Bool Function ActorMilkUpdateData(Actor Who, Float TimeSince)
{update the actors gem data given the time progression. returns false if this
actor is physically not capable of producing this item.}

	Float PregPercent = self.ActorGemTotalPercent(Who)
	Float PregNeeded = Main.Config.GetFloat("MilksPregPercent") / 100.0
	Float PerDay = Main.Config.GetFloat("MilksPerDay")
	Float Inc = ((TimeSince * PerDay) / 24.0)

	;; todo if not in milk faction, bail.

	If(PregPercent < PregNeeded)
		Main.Util.PrintDebug(Who.GetDisplayName() + " is not producing milk yet.")
		Return TRUE
	EndIf

	Inc *= PregPercent
	self.ActorMilkInc(Who,Inc)

	Main.Util.PrintDebug(Who.GetDisplayName() + " milk has progressed " + Inc)
	Return TRUE
EndFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Float Function ActorSemenAmount(Actor Who, Bool Limit=TRUE)
{return how much semen an actor has.}

	Int SemenMax = self.ActorSemenMax(Who)
	Float SemenVal = StorageUtil.GetFloatValue(Who,self.KeyActorSemenData)

	If(Limit && SemenVal > SemenMax)
		SemenVal = SemenMax as Float
	EndIf

	Return SemenVal
EndFunction

Function ActorSemenSet(Actor Who, Float Value)
{add/sub how much semen this actor has.}

	StorageUtil.SetFloatValue(Who,self.KeyActorSemenData,Value)
	self.ActorTrackingAdd(Who)

	Return
EndFunction

Function ActorSemenInc(Actor Who, Float Value)
{add/sub how much semen this actor has.}

	StorageUtil.AdjustFloatValue(Who,self.KeyActorSemenData,Value)
	self.ActorTrackingAdd(Who)
	
	Return
EndFunction

Function ActorSemenLimit(Actor Who)
{if this actor is over the limit on maximum semen, limit it.}

	Float Amount = self.ActorSemenAmount(Who,FALSE)
	Int Max = self.ActorSemenMax(Who)

	If(Amount > Max)
		self.ActorSemenSet(Who,Max as Float)
	EndIf

	Return
EndFunction

Int Function ActorSemenMax(Actor Who)
{return how many bottles of semen an actor can have at once.}

	Int Base = Main.Config.GetInt("ActorSemenMax")
	Float Val = self.ActorModGetFinal(Who,"SemenMax",Base)

	Return Main.Util.RoundToInt(Val)
EndFunction

Bool Function ActorSemenUpdateData(Actor Who, Float TimeSince)
{update the actors gem data given the time progression. returns false if this
actor is physically not capable of producing this item.}

	Float PerDay = Main.Config.GetFloat("SemensPerDay")
	Float Inc = ((TimeSince * PerDay) / 24.0)

	;; todo - if not in semen faction, bail.

	self.ActorSemenInc(Who,Inc)

	Main.Util.PrintDebug(Who.GetDisplayName() + " semen has progressed " + Inc)
	Return TRUE
EndFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Float Function ActorFertilityValue(Actor Who)
{get the current fertility value.}

	Float Value = StorageUtil.GetFloatValue(Who,self.KeyActorFertilityData,-1.0)

	If(Value == -1.0)
		Value = Utility.RandomFloat(0.0,Main.Config.GetInt("FertilityDays"))
		StorageUtil.SetFloatValue(Who,self.KeyActorFertilityData,Value)
	EndIf

	Return Value
EndFunction

Float Function ActorFertilityFactor(Actor Who, float Vmod=0.0)
{fetch the current multiplier for the fertility value using science and shit.}

	Int FertilityDays = Main.Config.GetInt("FertilityDays")
	Float FertilityWindow = Main.Config.GetFloat("FertilityWindow")
	Float Fval
	Float Poff
	Int Plen

	If(FertilityDays == 0.0)
		Return 1.0
	EndIf

	;; the x value of the wave.

	Fval = self.ActorFertilityValue(Who)
	Fval += Vmod


	;; the period offset is used to crank the amplitude and vertical offset of
	;; the wave.
	
	Poff = (FertilityWindow - 1) / 2

	;; the period length.
	
	Plen = FertilityDays

	;;  /     /          \      \
	;; |     | 2[pi]      |      |
	;; | sin | ----- fval | poff | + poff
	;; |     | plen       |      |
	;;  \     \          /      /
	;;           period    amp    y-offset

	;; SINEWAVESMOTHERFUCKER.

	Return ((Math.Sin(Math.RadiansToDegrees(((2*3.14159) / Plen) * Fval)) * Poff) + Poff) + 1
EndFunction

Bool Function ActorFertilityUpdateData(Actor Who, Float TimeSince)
{this function will keep a running loop of time from 0 to 28. returns false if
the actor is not biologically able to produce gems.}

	;; 1 2 3... 27 28 0 1 2 3...

	Int FertilityDays = Main.Config.GetInt("FertilityDays")
	Bool FertilitySync = Main.Config.GetBool("FertilitySync")
	Float FertilityWindow = Main.Config.GetFloat("FertilityWindow")
	Float SyncDist

	;; todo - if not in gem faction, bail.

	If(FertilityDays == 0)
		;; no need to process if disabled.
		Return TRUE
	EndIf

	If(TimeSince < 1.0)
		;; no need to process if too soon.
		Return TRUE
	EndIf

	;; get our current values. if this actor has not yet ever been calculated
	;; then we set them at a random point in the cycle to try and avoid having
	;; all the females in skyrim synced up.

	Float Fval = self.ActorFertilityValue(Who)
	Float Nval = Fval + (TimeSince / 24.0)

	;; attempt to sync up cycles with any followers currently following lololol.
	;; for starters we will try just making followers run hotter until they
	;; are synced up.

	If(FertilitySync && Who != Main.Player)
		;; todo follower faction check not distance check.
		If(Main.Player.GetDistance(Who) <= 750)
			SyncDist = self.ActorFertilityFactor(Who) - self.ActorFertilityFactor(Main.Player)
			Main.Util.PrintDebug(Who.GetDisplayName() + " fertility out of sync by " + SyncDist)

			;; trying to bring followers to be in sync within 1.5 days of eachother.
			;; i think if someone was almost sycned, and then you fast wait multiple
			;; days, it might be possible they overshoot and then have to compinsate
			;; again. i am leaning towards that actually intentionally being a game
			;; mecahnic as punishment for cheating. while actually playing they will
			;; eventually sync.

			If( Math.Abs(SyncDist) > (FertilityWindow * (1.5 / FertilityDays)) )
				If(SyncDist > 0.0)
					Nval += ((TimeSince / 24.0) * 3.0)
				Else
					Nval -= ((TimeSince / 24.0) * 4.0)
				EndIf
			EndIf

		EndIf
	EndIf

	Nval = PapyrusUtil.WrapFloat(Nval,FertilityDays,1.0)

	;; update our fertile value.

	StorageUtil.SetFloatValue(Who,self.KeyActorFertilityData,Nval)
	Main.Util.PrintDebug(Who.GetDisplayName() + " fertility data " + Nval + " " + self.ActorFertilityFactor(Who))

	;; todo: immersive messages comparing fval and nval.

	Return TRUE
EndFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Int Function RaceCount()
{fetch how many items are in the specified thing. you should probably only
use this on arrays.}

	Return JsonUtil.PathCount(self.FileRaces,"Races")
EndFunction

Int Function RaceFind(Race What)
{find the json index of the race. return 0, the default race, if not found.}

	Int Count = JsonUtil.PathCount(self.FileRaces,"Races")
	Int Index = 1
	String Path
	Race Current

	While(Index < Count)
		Path = "Races[" + Index + "].Race"
		Current = JsonUtil.GetPathFormValue(self.FileRaces,Path) as Race

		If(Current == What)
			Return Index
		EndIf

		Index += 1
	EndWhile

	Return 0
EndFunction

Form Function RaceGetMilk(Int Index)
{get the milk for the specified race.}

	String Path = "Races[" + Index + "].Milk"

	Return JsonUtil.GetPathFormValue(self.FileRaces,Path)
EndFunction

Form Function RaceGetSemen(Int Index)
{get the semen for the specified race.}

	String Path = "Races[" + Index + "].Semen"

	Return JsonUtil.GetPathFormValue(self.FileRaces,Path)
EndFunction
