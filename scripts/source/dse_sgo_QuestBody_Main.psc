ScriptName dse_sgo_QuestBody_Main extends Quest

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

dse_sgo_QuestController_Main Property Main Auto

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Function ActorUpdate(Actor Who)
{force the actor's body into the state described by its current dataset.}

	self.ActorUpdateGems(Who)
	self.ActorUpdateMilk(Who)
	NiOverride.UpdateModelWeight(Who)

	Return
EndFunction

Function ActorUpdateGems(Actor Who)
{handle body updates based on the state of their gems.}

	Float GemPercent = Main.Data.ActorGemTotalPercent(Who)
	;;Main.Util.PrintDebug("ActorUpdateGems(" + Who.GetDisplayName() + ") = " + GemPercent)

	self.ActorSlidersApply(Who,"Gems",GemPercent)

	Return
EndFunction

Function ActorUpdateMilk(Actor Who)
{handle body updates based on the state of their milk.}

	Float MilkPercent = Main.Data.ActorMilkTotalPercent(Who)
	;;Main.Util.PrintDebug("ActorUpdateMilk(" + Who.GetDisplayName() + ") = " + MilkPercent)

	self.ActorSlidersApply(Who,"Milk",MilkPercent)

	Return
EndFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Function ActorSlidersApply(Actor Who, String Prefix, Float Percent)
{apply a specific set of sliders at a percentage of their max value.}

	String MorphKey = "SGO4.Morph." + Prefix
	Int SliderCount = Main.Config.GetCount("Sliders." + Prefix)
	Int SliderIter = 0
	String SliderName
	Float SliderMax

	While(SliderIter < SliderCount)
		SliderName = Main.Config.GetString("Sliders." + Prefix + "[" + SliderIter + "].Name")
		SliderMax = Main.Config.GetFloat("Sliders." + Prefix + "[" + SliderIter + "].Max")

		;;Main.Util.PrintDebug(Who.GetDisplayName() + " Apply " + Prefix + " Slider " + SliderName + " " + (SliderMax*Percent))
		NiOverride.SetBodyMorph(Who,SliderName,MorphKey,(SliderMax * Percent))

		SliderIter += 1
	EndWhile

	Return
EndFunction

Function ActorSlidersClear(Actor Who, String Prefix)
{clear all the morphs for a specific set of sliders.}

	String MorphKey = "SGO4.Morph." + Prefix

	NiOverride.ClearBodyMorphKeys(Who,MorphKey)

	Return
EndFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Event OnAnimationEvent(ObjectReference What, String EvName)
{handle animation events.}

	Main.Util.PrintDebug(EvName)

	If(EvName == "SGO4.ActorMoan")
		self.OnAnimationEvent_ActorMoan(What as Actor)
	ElseIf(EvName == "SGO4.ActorReset")
		self.OnAnimationEvent_ActorReset(What as Actor)
	EndIf

	Return
EndEvent

Function OnAnimationEvent_ActorMoan(Actor Who)
{play an expression on the actor face.}

	sslBaseExpression Face = Main.SexLab.GetExpressionByName("Pained")
	sslBaseVoice Voice = Main.SexLab.PickVoice(Who)

	Face.Apply(Who,60,Who.GetLeveledActorBase().GetSex())
	Voice.GetSound(75).Play(Who)

	Return
EndFunction

Function OnAnimationEvent_ActorReset(Actor Who)
{reset an actor's face.}

	sslBaseExpression.ClearMFG(Who)

	Return
EndFunction
