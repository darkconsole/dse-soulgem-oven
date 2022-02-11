ScriptName dse_sgo_EffectActorDataScanToggle extends ActiveMagicEffect

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

dse_sgo_QuestController_Main Property Main Auto

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Event OnEffectStart(Actor Who, Actor From)

	Actor Target = Game.GetCurrentCrosshairRef() as Actor

	;;;;;;;;

	If(Main.GemUI.Busy)
		Main.Util.Print("Widget is busy, try again in a moment.")
		Return
	EndIf

	;;;;;;;;

	If(Main.Player.HasSpell(Main.SpellActorDataScan))
		Main.Util.Print("Scanner Shutting Down.")
		Main.Player.RemoveSpell(Main.SpellActorDataScan)

		StorageUtil.UnsetFormValue(NONE, "SGO4.ActorDataScan")
		Main.GemUI.Target.Clear()
		Main.GemUI.OnUpdateWidget()
		Return
	EndIf

	;;;;;;;;

	If(Target == None)
		Target = Main.Player
	EndIf

	StorageUtil.SetFormValue(NONE, "SGO4.ActorDataScan", Target)
	Main.Player.AddSpell(Main.SpellActorDataScan,FALSE)
	Main.Util.Print("Scanning " + Target.GetDisplayName() + "...")

	Return
EndEvent
