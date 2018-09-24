ScriptName dse_sgo_EffectActorDataScanToggle extends ActiveMagicEffect

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

dse_sgo_QuestController_Main Property Main Auto

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Event OnEffectStart(Actor Who, Actor From)

	Spell Scanner = Main.Util.GetForm(0x73e0) as Spell
	Actor Target = Game.GetCurrentCrosshairRef() as Actor

	If(Target == None)
		If(Main.Player.HasSpell(Scanner))
			Main.Player.RemoveSpell(Scanner)
		Else
			Main.Player.AddSpell(Scanner,FALSE)
		EndIf
	Else
		Main.Player.RemoveSpell(Scanner)
		Main.Player.AddSpell(Scanner,FALSE)
	EndIf

	Return
EndEvent
