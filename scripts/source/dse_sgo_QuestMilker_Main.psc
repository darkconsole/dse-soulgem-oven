ScriptName dse_sgo_QuestMilker_Main extends Quest

dse_sgo_QuestController_Main Property Main Auto

FormList Property EnchantList Auto
Keyword Property EnchantBody Auto
Keyword Property AutoMilker Auto

Event OnInit()
	
	self.RegisterForModEvent("SGO4.Body.ActorUpdate","OnActorUpdate")
	self.MakeEnchantable()

	Return
EndEvent

Event OnActorUpdate(Form What)
{catch when this actor has been updated by the framework so we can inspect
the milk status and milk any bottles that are over the limit.}

	Actor Who = What As Actor
	Form Milk
	Float Current
	Float Max

	;; the ActorMilkInc will cause Body to emit another ActorUpdate
	;; event. which we will then catch here again over and over until
	;; it is finally underneath the treshold for auto milking.

	If(Who == None || !Main.IsRunning())
		Return
	EndIf

	If(!Who.WornHasKeyword(self.AutoMilker))
		Return
	EndIf

	;;;;;;;;

	Current = Main.Data.ActorMilkAmount(Who,FALSE)
	Max = Main.Data.ActorMilkMax(Who)

	If(Current >= Max)
		Milk = Main.Data.ActorGetMilk(Who)
		Main.Data.ActorMilkInc(Who,-1.0)
		Who.AddItem(Milk,1)
		Main.Stats.IncInt(Who,Main.Stats.KeyMilksMilked,1,TRUE)
		
		If(Main.Config.GetBool(".MilkLeveling"))
			Int MilkedCount = Main.Stats.GetInt(Who,Main.Stats.KeyMilksMilked)

			Float MilkLevelingCapacityMult = Main.Config.GetFloat(".MilkLevelingCapacityMult")*MilkedCount
			Float MilkLevelingCapacityMultCap = Main.Config.GetFloat(".MilkLevelingCapacityMultCap")
			If MilkLevelingCapacityMult > MilkLevelingCapacityMultCap
				MilkLevelingCapacityMult = MilkLevelingCapacityMultCap
			EndIf

			Float MilkLevelingGainMult = Main.Config.GetFloat(".MilkLevelingGainMult")*MilkedCount
			Float MilkLevelingGainMultCap = Main.Config.GetFloat(".MilkLevelingGainMultCap")
			If MilkLevelingGainMult > MilkLevelingGainMultCap
				MilkLevelingGainMult = MilkLevelingGainMultCap
			EndIf
			
			Float MilkLevelingSpeechMult = Main.Config.GetFloat(".MilkLevelingSpeechMult")*MilkedCount
			Float MilkLevelingSpeechMultCap = Main.Config.GetFloat(".MilkLevelingSpeechMultCap")
			If MilkLevelingSpeechMult > MilkLevelingSpeechMultCap
				MilkLevelingSpeechMult = MilkLevelingSpeechMultCap
			EndIf
			
			Main.Data.ActorModSetValue(Who,Main.Data.KeyActorModMilkMaxMult,".MilkLevelCapacityMult",MilkLevelingCapacityMult)
			Main.Data.ActorModSetValue(Who,Main.Data.KeyActorModMilkRateMult,".MilkLevelRateMult",MilkLevelingGainMult)
			Main.Data.ActorModSetValue(Who,Main.Data.KeyActorModInfluenceMilkSpeechMult,".MilkLevelSpeechMult",MilkLevelingSpeechMult)
			Main.Data.ActorModSetValue(Who,Main.Data.KeyActorModInfluenceMilkSpeechExposedMult,".MilkLevelSpeechExposedMult",MilkLevelingSpeechMult)			
		Else
			Main.Data.ActorModSetValue(Who,Main.Data.KeyActorModMilkMaxMult,".MilkLevelCapacityMult")
			Main.Data.ActorModSetValue(Who,Main.Data.KeyActorModMilkRateMult,".MilkLevelRateMult")
			Main.Data.ActorModSetValue(Who,Main.Data.KeyActorModInfluenceMilkSpeechMult,".MilkLevelSpeechMult")
			Main.Data.ActorModSetValue(Who,Main.Data.KeyActorModInfluenceMilkSpeechExposedMult,".MilkLevelSpeechExposedMult")	
		EndIf			
		
	EndIf

	Return
EndEvent

Function MakeEnchantable()

	Int Count = EnchantList.GetSize()
	FormList Current = None
	Bool Added = FALSE

	While(Count > 0)
		Count -= 1
		Current = EnchantList.GetAt(Count) as FormList

		If(Current && !Current.HasForm(EnchantBody))
			Current.AddForm(EnchantBody)
			Added = TRUE
		EndIf
	EndWhile

	If(Added)
		Debug.Notification("Milkers should be enchantable now.")
	EndIf

	Return
EndFunction

