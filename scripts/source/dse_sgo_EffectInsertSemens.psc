ScriptName dse_sgo_EffectInsertSemens extends ActiveMagicEffect

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

dse_sgo_QuestController_Main Property Main Auto

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Event OnEffectStart(Actor Who, Actor From)

	ObjectReference Box
	Actor Target

	;; determine if we were targeting someone.

	If(Who == Main.Player)
		Target = Game.GetCurrentCrosshairRef() as Actor
		If(Target != None)
			Main.SpellInsertSemens.Cast(Target,Target)
			;; self.Dispel() ;; spell is fire and forget with 0 duration.
			Return
		EndIf
	EndIf

	Box = Who.PlaceAtMe(Main.ContainInsertSemens,1,FALSE,TRUE)

	;;;;;;;;

	If(Who == Main.Player && Target != None)
		Who = Target
	EndIf

	StorageUtil.SetFormValue(Box,"SGO4.InsertInto",Who)
	Box.Enable()	

	Return
EndEvent