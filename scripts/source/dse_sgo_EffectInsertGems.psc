ScriptName dse_sgo_EffectInsertGems extends ActiveMagicEffect

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

dse_sgo_QuestController_Main Property Main Auto

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Event OnEffectStart(Actor Who, Actor From)

	ObjectReference Box
	Actor Target

	;; determine if we were targeting someone.
	;; this spell is fire and forget so no need to dispel after.

	If(Who == Main.Player)
		Target = Game.GetCurrentCrosshairRef() as Actor
		If(Target != None)
			Main.SpellInsertGems.Cast(Target,Target)
			Return
		EndIf
	EndIf

	Box = Who.PlaceAtMe(Main.ContainInsertGems,1,FALSE,TRUE)
	StorageUtil.SetFormValue(Box,"SGO4.InsertInto",Who)
	Box.Enable()	

	Return
EndEvent