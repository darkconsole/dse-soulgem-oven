ScriptName dse_sgo_ArmorMilker extends ObjectReference

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

dse_sgo_QuestController_Main Property Main Auto

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Event OnEquipped(Actor Who)

	;; this appears to help with crashes caused by mods like eff
	;; that auto re-equip all items on your followers every time
	;; zone in. may be related to the modevent foolery i debugged
	;; when saving.

	Main.Util.PrintDebug(Who.GetDisplayName() + " equipped the milker")
	Utility.Wait(0.01)

	;; first crop off excess milks from before we were wearing this

	Float Amount = Main.Data.ActorMilkAmount(Who)
	Float Max = Main.Data.ActorMilkMax(Who)
	Bool Produce = Main.Config.GetBool(".MilkerProduce")
	Float Rate = Main.Config.GetFloat(".MilkerRate")

	If(Amount > (Max + 1))
		Main.Data.ActorMilkSet(Who,((Max + 1) As Float))
	EndIf

	;; then tell soulgem oven this actor should be producing.

	If(Produce)
		Main.Data.ActorModSetValue(Who,Main.Data.KeyActorModMilkProduce,".SGO4AutoMilker",1.0)
	EndIf

	If(Rate > 0.0)
		Main.Data.ActorModSetValue(Who,Main.Data.KeyActorModMilkRateMult,".SGO4AutoMilker",Rate)
	EndIf

	If(Produce && Rate > 0.0)
		Main.Data.ActorTrackingAdd(Who)
	EndIf

	;; throw in some flavour.

	If(Who == Main.Player)
		Main.Util.PrintLookupRandom("FlavourPlayerMilkerEquip",Who.GetDisplayName())
	Else
		Main.Util.PrintLookupRandom("FlavourActorMilkerEquip",Who.GetDisplayName())
	EndIf

	Return
EndEvent

Event OnUnequipped(Actor Who)

	;; tell soulgem oven we no longer wish to produce.

	Main.Util.PrintDebug(Who.GetDisplayName() + " removed the milker")
	Main.Data.ActorModUnsetValue(Who,Main.Data.KeyActorModMilkProduce,".SGO4AutoMilker")
	Main.Data.ActorModUnsetValue(Who,Main.Data.KeyActorModMilkRateMult,".SGO4AutoMilker")

	;; throw in some flavour.

	If(Who == Main.Player)
		Main.Util.PrintLookupRandom("FlavourPlayerMilkerUnequip",Who.GetDisplayName())
	Else
		Main.Util.PrintLookupRandom("FlavourActorMilkerUnequip",Who.GetDisplayName())
	EndIf

	Return
EndEvent
