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
	Int Max = Main.Data.ActorMilkMax(Who)

	If(Amount > (Max + 1))
		Main.Data.ActorMilkSet(Who,((Max + 1) As Float))
	EndIf

	;; then tell soulgem oven this actor should be producing.

	Main.Data.ActorModSetValue(Who,"SGO4.ActorMod.MilkProduce",".SGO4AutoMilker",1.0)
	Main.Data.ActorModSetValue(Who,"SGO4.ActorMod.MilkRate",".SGO4AutoMilker",0.10)
	Main.Data.ActorTrackingAdd(Who)

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
	Main.Data.ActorModUnsetValue(Who,"SGO4.ActorMod.MilkProduce",".SGO4AutoMilker")
	Main.Data.ActorModUnsetValue(Who,"SGO4.ActorMod.MilkRate",".SGO4AutoMilker")

	;; throw in some flavour.

	If(Who == Main.Player)
		Main.Util.PrintLookupRandom("FlavourPlayerMilkerUnequip",Who.GetDisplayName())
	Else
		Main.Util.PrintLookupRandom("FlavourActorMilkerUnequip",Who.GetDisplayName())
	EndIf

	Return
EndEvent
