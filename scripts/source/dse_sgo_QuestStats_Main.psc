ScriptName dse_sgo_QuestStats_Main extends Quest

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

dse_sgo_QuestController_Main Property Main Auto

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

String Property KeyGemsBirthed = "SGO4.Stats.Gem.Birthed" AutoReadOnly Hidden
String Property KeyGemsInserted = "SGO4.Stats.Gem.Inserted" AutoReadOnly Hidden
String Property KeyGemsIncubated = "SGO4.Stats.Gem.Incubated" AutoReadOnly Hidden
String Property KeyGemsInseminated = "SGO4.Stats.Gem.Inseminated" AutoReadOnly Hidden
String Property KeyMilksMilked = "SGO4.Stats.Milk.Milked" AutoReadOnly Hidden
String Property KeyMilksProduced = "SGO4.Stats.Milk.Produced" AutoReadOnly Hidden
String Property KeySemensMilked = "SGO4.Stats.Semen.Milked" AutoReadOnly Hidden
String Property KeySemensProduced = "SGO4.Stats.Semen.Produced" AutoReadOnly Hidden

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Function IncFloat(Actor Who, String Name, Float Bump=1.0, Bool GlobalToo=FALSE)

	StorageUtil.AdjustFloatValue(Who,Name,Bump)

	If(GlobalToo)
		StorageUtil.AdjustFloatValue(None,Name,Bump)
	EndIf

	Return
EndFunction

Function IncInt(Actor Who, String Name, Int Bump=1, Bool GlobalToo=FALSE)

	StorageUtil.AdjustIntValue(Who,Name,Bump)

	If(GlobalToo)
		StorageUtil.AdjustIntValue(None,Name,Bump)
	EndIf

	Return	
EndFunction

;;;;;;;;

Float Function GetFloat(Actor Who, String Name)

	Return StorageUtil.GetFloatValue(Who,Name)
EndFunction

Int Function GetInt(Actor Who, String Name)

	Return StorageUtil.GetIntValue(Who,Name)
EndFunction

;;;;;;;;

Function SetFloat(Actor Who, String Name, Float Val=1.0, Bool GlobalToo=FALSE)

	StorageUtil.SetFloatValue(Who,Name,Val)

	If(GlobalToo)
		StorageUtil.SetFloatValue(None,Name,Val)
	EndIf

	Return
EndFunction

Function SetInt(Actor Who, String Name, Int Val=1, Bool GlobalToo=FALSE)

	StorageUtil.SetIntValue(Who,Name,Val)

	If(GlobalToo)
		StorageUtil.SetIntValue(None,Name,Val)
	EndIf

	Return	
EndFunction
