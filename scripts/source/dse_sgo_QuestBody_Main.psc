ScriptName dse_sgo_QuestBody_Main extends Quest

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

dse_sgo_QuestController_Main Property Main Auto

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

String Property KeyEvActorMoan = "SGO4.ActorMoan" AutoReadOnly Hidden
String Property KeyEvActorMoanLoud = "SGO4.ActorMoanLoud" AutoReadOnly Hidden
String Property KeyEvActorReset = "SGO4.ActorReset" AutoReadOnly Hidden
String Property KeyEvActorResetFace = "SGO4.ActorResetFace" AutoReadOnly Hidden
String Property KeyEvActorDone = "SGO4.ActorDone" AutoReadOnly Hidden
String Property KeyEvActorInsert = "SGO4.ActorInsert" AutoReadOnly Hidden
String Property KeyEvActorSpawnGem = "SGO4.ActorSpawnGem" AutoReadOnly Hidden
String Property KeyEvActorSpawnMilk = "SGO4.ActorSpawnMilk" AutoReadOnly Hidden
String Property KeyEvActorSpawnSemen = "SGO4.ActorSpawnSemen" AutoReadOnly Hidden

String Property AniDefault = "IdleForceDefaultState" AutoReadOnly Hidden
String Property AniInsert01 = "dse-sgo-insert01-01" AutoReadOnly Hidden
String Property AniInseminate01 = "dse-sgo-insert01-01" AutoReadOnly Hidden
String Property AniInsert02 = "dse-sgo-insert02-01" AutoReadOnly Hidden
String Property AniBirth01 = "dse-sgo-birth01-01" AutoReadOnly Hidden
String Property AniMilking01 = "dse-sgo-milking01-01" AutoReadOnly Hidden
String Property AniWanking01 = "dse-sgo-wanking01-01" AutoReadOnly Hidden

String Property KeySliders = ".Sliders" AutoReadOnly Hidden
String Property KeySlidersGems = ".Sliders.Gems" AutoReadOnly Hidden
String Property KeySlidersMilk = ".Sliders.Milk" AutoReadOnly Hidden
String Property KeyMorphGems = "SGO4Gems" AutoReadOnly Hidden
String Property KeyMorphMilk = "SGO4Milk" AutoReadOnly Hidden

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Function ActorUpdate(Actor Who, Bool Force=FALSE)
{force the actor's body into the state described by its current dataset.}

	Int Ev

	If(Force || Who.IsInFaction(Main.FactionProduceGems))
		self.ActorUpdateGems(Who)
	EndIf


	If(Force || Who.IsInFaction(Main.FactionProduceMilk))
		self.ActorUpdateMilk(Who)
	EndIF

	If(Who.Is3dLoaded())
		;; allow our data to have gotten updated, but there is no need to
		;; update an actor that is not loaded.
		NiOverride.UpdateModelWeight(Who)
	EndIf

	Ev = ModEvent.Create("SGO4.Body.ActorUpdate")
	ModEvent.PushForm(Ev,Who)
	ModEvent.Send(Ev)

	Return
EndFunction

Function ActorUpdateGems(Actor Who)
{handle body updates based on the state of their gems.}

	Float GemPercent = Main.Data.ActorGemTotalPercent(Who)

	If(Who == Main.Player)
		self.ActorUpdateGemsInfluence(Who,GemPercent)
	EndIf

	If(Who.IsInFaction(Main.FactionNoBodyScale))
		GemPercent = 0.0
	EndIf

	self.ActorSlidersApply(Who,self.KeySlidersGems,GemPercent)

	Return
EndFunction

Function ActorUpdateMilk(Actor Who)
{handle body updates based on the state of their milk.}

	Float MilkPercent = Main.Data.ActorMilkTotalPercent(Who)

	If(Who == Main.Player)
		self.ActorUpdateMilkInfluence(Who,MilkPercent)
	EndIf
	
	If(Who.IsInFaction(Main.FactionNoBodyScale))
		MilkPercent = 0.0
	EndIf

	self.ActorSlidersApply(Who,self.KeySlidersMilk,MilkPercent)

	Return
EndFunction

Function ActorUpdateGemsInfluence(Actor Who, Float GemPercent)

	Float GemsWhen = Main.Config.GetFloat(".InfluenceGemsWhen")
	Float GemsHealth = Main.Config.GetFloat(".InfluenceGemsHealth")
	Float GemsMagicka = Main.Config.GetFloat(".InfluenceGemsMagicka")

	;; clean off spells.
	Who.RemoveSpell(Main.SpellInfluenceGems)

	;; bail if disabled.
	If(GemsHealth == 0.0 && GemsMagicka == 0.0)
		Return
	EndIf

	;; apply effects when triggered.
	If(GemPercent >= GemsWhen)
		;; effect 0 is the health influence.
		Main.SpellInfluenceGems.SetNthEffectMagnitude(0,(GemsHealth * GemPercent))
		
		;; effect 1 is the mana influence.
		Main.SpellInfluenceGems.SetNthEffectMagnitude(1,(GemsMagicka * GemPercent))

		;; reapply spells.
		Who.AddSpell(Main.SpellInfluenceGems,FALSE)
	EndIf

	Return
EndFunction

Function ActorUpdateMilkInfluence(Actor Who, Float MilkPercent)

	Float MilkWhen = Main.Config.GetFloat(".InfluenceMilkWhen")
	Float MilkSpeech = Main.Config.GetFloat(".InfluenceMilkSpeech")
	Float MilkSpeechExposed = Main.Config.GetFloat(".InfluenceMilkSpeechExposed")

	;; clean off spells.
	Who.RemoveSpell(Main.SpellInfluenceMilk)

	;; bail if disabled.
	If(MilkSpeech == 0.0 && MilkSpeechExposed == 0.0)
		Return
	EndIf

	;; apply effects when triggered.
	If(MilkPercent >= MilkWhen)
		;; effect 0 is the speech influence.
		Main.SpellInfluenceMilk.SetNthEffectMagnitude(0,(MilkSpeech * MilkPercent))

		;; effect 1 is the nude speech influence.
		Main.SpellInfluenceMilk.SetNthEffectMagnitude(1,(MilkSpeechExposed * MilkPercent))

		;; reapply spells.
		Who.AddSpell(Main.SpellInfluenceMilk,FALSE)
	EndIf

	Return
EndFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Function ActorSlidersApply(Actor Who, String Prefix, Float Percent)
{apply a specific set of sliders at a percentage of their max value.}

	String MorphKey = ""
	Int SliderCount = Main.Config.GetCount(Prefix)
	Int SliderIter = 0
	String SliderName
	Float SliderMax

	If(Prefix == self.KeySlidersGems)
		MorphKey = self.KeyMorphGems;
	ElseIf(Prefix == self.KeySlidersMilk)
		MorphKey = self.KeyMorphMilk;
	EndIf

	If(StringUtil.GetLength(MorphKey) == 0)
		Return
	EndIf

	Main.Util.PrintDebug(Who.GetDisplayName() + " Slider Count: " + Prefix + " " + SliderCount)

	While(SliderIter < SliderCount)
		SliderName = Main.Config.GetString(Prefix + "[" + SliderIter + "].Name")
		SliderMax = Main.Config.GetFloat(Prefix + "[" + SliderIter + "].Max")

		Main.Util.PrintDebug(Who.GetDisplayName() + " Apply " + Prefix + " Slider " + SliderName + " " + (SliderMax*Percent))

		If(Percent > 0)
			NiOverride.SetBodyMorph(Who,SliderName,MorphKey,(SliderMax * Percent))
		Else
			NiOverride.ClearBodyMorph(Who,SliderName,MorphKey)
		EndIf

		;; these should be removed after a few versions. just a cleanup.
		;;NiOverride.ClearBodyMorph(Who,SliderName,"SGO4.Morph.Gems")
		;;NiOverride.ClearBodyMorph(Who,SliderName,"SGO4.Morph.Milk")
		;;NiOverride.ClearBodyMorph(Who,SliderName,"SGO4.Morph..Sliders.Gems")
		;;NiOverride.ClearBodyMorph(Who,SliderName,"SGO4.Morph..Sliders.Milk")

		SliderIter += 1
	EndWhile

	Return
EndFunction

Function ActorSlidersClear(Actor Who, String Prefix)
{clear all the morphs for a specific set of sliders.}

	String MorphKey = ""

	If(Prefix == self.KeySlidersGems)
		MorphKey = self.KeyMorphGems;
	ElseIf(Prefix == self.KeySlidersMilk)
		MorphKey = self.KeyMorphMilk;
	EndIf

	If(StringUtil.GetLength(MorphKey) == 0)
		Return
	EndIf

	NiOverride.ClearBodyMorphKeys(Who,MorphKey)

	Return
EndFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Function RegisterForCustomAnimationEvents(Actor Who)
{watch an actor for SGO4 custom animation events.}

	self.UnregisterForCustomAnimationEvents(Who)
	self.RegisterForAnimationEvent(Who,self.KeyEvActorMoan)
	self.RegisterForAnimationEvent(Who,self.KeyEvActorMoanLoud)
	self.RegisterForAnimationEvent(Who,self.KeyEvActorReset)
	self.RegisterForAnimationEvent(Who,self.KeyEvActorResetFace)
	self.RegisterForAnimationEvent(Who,self.KeyEvActorDone)
	self.RegisterForAnimationEvent(Who,self.KeyEvActorInsert)
	self.RegisterForAnimationEvent(Who,self.KeyEvActorSpawnGem)
	self.RegisterForAnimationEvent(Who,self.KeyEvActorSpawnMilk)
	self.RegisterForAnimationEvent(Who,self.KeyEvActorSpawnSemen)

	Return
EndFunction

Function UnregisterForCustomAnimationEvents(Actor Who)
{stop watching an actor for SGO4 custom animation events.}

	self.UnregisterForAnimationEvent(Who,self.KeyEvActorMoan)
	self.UnregisterForAnimationEvent(Who,self.KeyEvActorMoanLoud)
	self.UnregisterForAnimationEvent(Who,self.KeyEvActorReset)
	self.UnregisterForAnimationEvent(Who,self.KeyEvActorResetFace)
	self.UnregisterForAnimationEvent(Who,self.KeyEvActorDone)
	self.UnregisterForAnimationEvent(Who,self.KeyEvActorInsert)
	self.UnregisterForAnimationEvent(Who,self.KeyEvActorSpawnGem)
	self.UnregisterForAnimationEvent(Who,self.KeyEvActorSpawnMilk)
	self.UnregisterForAnimationEvent(Who,self.KeyEvActorSpawnSemen)

	Return
EndFunction

Event OnAnimationEvent(ObjectReference What, String EvName)
{handle animation events.}

	Main.Util.PrintDebug(EvName + " " + What.GetDisplayName())

	If(What as Actor)
		If(EvName == self.KeyEvActorMoan)
			self.OnAnimationEvent_ActorMoan(What as Actor,50)
		ElseIf(EvName == self.KeyEvActorMoanLoud)
			self.OnAnimationEvent_ActorMoan(What as Actor,100)
		ElseIf(EvName == self.KeyEvActorReset)
			self.OnAnimationEvent_ActorReset(What as Actor)
		ElseIf(EvName == self.KeyEvActorResetFace)
			self.OnAnimationEvent_ActorResetFace(What as Actor)
		ElseIf(EvName == self.KeyEvActorDone)
			self.OnAnimationEvent_ActorDone(What as Actor)
		ElseIf(EvName == self.KeyEvActorInsert)
			self.OnAnimationEvent_ActorInsert(What as Actor)
		ElseIf(EvName == self.KeyEvActorSpawnGem)
			self.OnAnimationEvent_ActorSpawnGem(What as Actor)
		ElseIf(EvName == self.KeyEvActorSpawnMilk)
			self.OnAnimationEvent_ActorSpawnMilk(What as Actor)
		ElseIf(EvName == self.KeyEvActorSpawnSemen)
			self.OnAnimationEvent_ActorSpawnSemen(What as Actor)
		EndIf
	EndIf

	Return
EndEvent

Function OnAnimationEvent_ActorMoan(Actor Who, Int Vol)
{play an expression on the actor face.}

	sslBaseExpression Face = Main.SexLab.GetExpressionByName("Pained")
	sslBaseVoice Voice = Main.SexLab.PickVoice(Who)

	Face.Apply(Who,50,Who.GetLeveledActorBase().GetSex())
	Voice.GetSound(Vol).Play(Who)

	Return
EndFunction

Function OnAnimationEvent_ActorReset(Actor Who)
{reset an actor's body and face.}

	sslBaseExpression.ClearMFG(Who)

	;;If(Who == Main.Player)
	;;	Game.SetPlayerAIDriven(FALSE)
	;;EndIf

	Debug.SendAnimationEvent(Who,self.AniDefault)

	Return
EndFunction

Function OnAnimationEvent_ActorResetFace(Actor Who)
{reset an actor's face.}

	sslBaseExpression.ClearMFG(Who)

	Return
EndFunction

Function OnAnimationEvent_ActorDone(Actor Who)
{we are completely done animating.}

	Int Ev

	self.OnAnimationEvent_ActorReset(Who)

	Main.Util.PrintDebug("ModEvent: " + self.KeyEvActorDone)

 	Ev = ModEvent.Create(self.KeyEvActorDone)
	ModEvent.PushForm(Ev,Who)
	ModEvent.Send(Ev)

	Return
EndFunction

Function OnAnimationEvent_ActorInsert(Actor Who)
{an insertion happened in the animation.}

	Int Ev

	Main.Util.PrintDebug("ModEvent: " + self.KeyEvActorInsert)

 	Ev = ModEvent.Create(self.KeyEvActorInsert)
	ModEvent.PushForm(Ev,Who)
	ModEvent.Send(Ev)

	Return
EndFunction

Function OnAnimationEvent_ActorSpawnGem(Actor Who)
{a gem spawn happened in the animation.}

	Int Ev

	Main.Util.PrintDebug("ModEvent: " + self.KeyEvActorSpawnGem)

 	Ev = ModEvent.Create(self.KeyEvActorSpawnGem)
	ModEvent.PushForm(Ev,Who)
	ModEvent.Send(Ev)

	Return
EndFunction

Function OnAnimationEvent_ActorSpawnMilk(Actor Who)
{a milk spawn happened in the animation.}

	Int Ev

	Main.Util.PrintDebug("ModEvent: " + self.KeyEvActorSpawnMilk)

 	Ev = ModEvent.Create(self.KeyEvActorSpawnMilk)
	ModEvent.PushForm(Ev,Who)
	ModEvent.Send(Ev)

	Return
EndFunction

Function OnAnimationEvent_ActorSpawnSemen(Actor Who)
{a semen spawn happened in the animation.}

	Int Ev

	Main.Util.PrintDebug("ModEvent: " + self.KeyEvActorSpawnSemen)

 	Ev = ModEvent.Create(self.KeyEvActorSpawnSemen)
	ModEvent.PushForm(Ev,Who)
	ModEvent.Send(Ev)

	Return
EndFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Function ActorLockdown(Actor Who, Package Pkg=NONE)

	If(Pkg == None)
		Pkg = Main.PackageDoNothing
	EndIf

	If(Who == Main.Player)
		Game.SetPlayerAIDriven(TRUE)
		Game.DisablePlayerControls()
	EndIf
	
	StorageUtil.SetFormValue(Who,"SGO4.Actor.Lockdown",Pkg)

	ActorUtil.AddPackageOverride(Who,Pkg,100)
	Who.EvaluatePackage()

	self.RegisterForCustomAnimationEvents(Who)
	;;Debug.SendAnimationEvent(Who,self.AniDefault)
	Return
EndFunction

Function ActorRelease(Actor Who)
	
	Package Pkg = StorageUtil.GetFormValue(Who,"SGO4.Actor.Lockdown") as Package

	If(Pkg == None)
		Pkg = Main.PackageDoNothing
	EndIf

	ActorUtil.RemovePackageOverride(Who,Pkg)
	Who.EvaluatePackage()

	self.UnregisterForCustomAnimationEvents(Who)

	If(!Main.Util.ActorHasPackageOverrides(Who))
		Debug.SendAnimationEvent(Who,self.AniDefault)
	EndIf

	If(Who == Main.Player)
		Game.SetPlayerAIDriven(FALSE)
		Game.EnablePlayerControls()
	EndIf

	Return
EndFunction

Function ActorAnimateSolo(Actor Who, String AniName)
{force an actor to perform some sort of blocking/busy animation.}

	Debug.SendAnimationEvent(Who,AniName)

	Return
EndFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Int Function SliderFindByName(String SliderKey, String SliderName)
{find a slider in the config. returns the offset of the slider or -1 if not
found.}

	Int SliderCount = Main.Config.GetCount(SliderKey)
	String SliderPath
	
	While(SliderCount > 0)
		SliderCount -= 1
		SliderPath = SliderKey + "[" + SliderCount + "].Name"

		If(Main.Config.GetString(SliderPath) == SliderName)
			Return SliderCount
		EndIf
	EndWhile

	Return -1
EndFunction

Bool Function SliderDeleteByName(String SliderKey, String SliderName)
{delete a slider from the config.}

	Int SliderOffset = self.SliderFindByName(SliderKey,SliderName)
	String SliderPath

	If(SliderOffset == -1)
		Return FALSE
	EndIf

	Return self.SliderDeleteByoffset(SliderKey,SliderOffset)
EndFunction

Bool Function SliderDeleteByOffset(String SliderKey, Int SliderOffset)
{delete a slider from the config.}

	Int SliderCount = Main.Config.GetCount(SliderKey)
	String[] SliderName = Utility.CreateStringArray(SliderCount)
	Float[] SliderVal = Utility.CreateFloatArray(SliderCount)
	Int Iter

	;; create an index.

	Iter = 0
	While(Iter < SliderCount)
		SliderName[Iter] = self.SliderNameByOffset(SliderKey,Iter)
		SliderVal[Iter] = self.SliderMaxByOffset(SliderKey,Iter)
		Iter += 1
	EndWhile

	;; blow the old one away and reinstall sliders.
	
	self.SliderConfigReset()

	Iter = 0
	While(Iter < SliderCount)
		;; skip the one we wanted to delete.
		
		If(Iter != SliderOffset)
			self.SliderAdd(SliderKey,SliderName[Iter],SliderVal[Iter])
		EndIf

		Iter += 1
	EndWhile

	Return TRUE
EndFunction

Function SliderConfigReset()
{empty the dataset from the custom config.}

	JsonUtil.SetRawPathValue(Main.Config.FileCustom,Main.Body.KeySliders,"{\"Gems\":[],\"Milk\":[]}")
	Return
EndFunction

Bool Function SliderAdd(String SliderKey, String SliderName, Float SliderValue=0.0)

	Int SliderOld = self.SliderFindByName(SliderKey,SliderName)
	Int SliderCount = Main.Config.GetCount(SliderKey)
	String SliderPath

	If(SliderOld != -1)
		Return FALSE
	EndIf

	SliderPath = SliderKey + "[" + SliderCount + "].Name"
	Main.Config.SetString(SliderPath,SliderName)

	SliderPath = SliderKey + "[" + SliderCount + "].Max"
	Main.Config.SetFloat(SliderPath,SliderValue)

	Return TRUE
EndFunction

String Function SliderNameByOffset(String SliderKey, Int Offset)

	String SliderPath = SliderKey + "[" + Offset + "].Name"

	Return Main.Config.GetString(SliderPath)
EndFunction

Float Function SliderMaxByOffset(String SliderKey, Int Offset)

	String SliderPath = SliderKey + "[" + Offset + "].Max"

	Return Main.Config.GetFloat(SliderPath)
EndFunction
