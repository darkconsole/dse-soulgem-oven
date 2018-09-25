ScriptName dse_sgo_EffectActorDataScanToggle extends ActiveMagicEffect

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

dse_sgo_QuestController_Main Property Main Auto

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Event OnEffectStart(Actor Who, Actor From)

	Actor Target = Game.GetCurrentCrosshairRef() as Actor

	If(Target == None)
		If(Main.Player.HasSpell(Main.SpellActorDataScan))
			Main.Player.RemoveSpell(Main.SpellActorDataScan)
		Else
			Main.Player.AddSpell(Main.SpellActorDataScan,FALSE)
		EndIf
	Else
		Main.Player.RemoveSpell(Main.SpellActorDataScan)
		Main.Player.AddSpell(Main.SpellActorDataScan,FALSE)
	EndIf

	Return
EndEvent
