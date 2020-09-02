ScriptName dse_sgo_EffectFindActors extends ActiveMagicEffect

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

dse_sgo_QuestController_Main Property Main Auto
Int Property Phase Auto

;;;;;;;;

Actor Property Who Auto Hidden

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Event OnEffectStart(Actor Target, Actor From)

	;;Main.Util.PrintDebug("[EffectFindActors:OnEffectStart] " + self.Phase)

	If(self.Phase == 1)
		self.GotoState("Phase1")
	ElseIf(self.Phase == 2)
		self.GotoState("Phase2")
	EndIf

	self.Who = Target
	self.Execute()
	Return
EndEvent

Event OnEffectFinish(Actor Target, Actor From)

	Return
EndEvent

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Function Execute()

	Return
EndFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


State Phase1

	Function Execute()

		Main.Util.PrintDebug("[EffectFindActors:Phase1:Execute] Dropping The Bomb")
		StorageUtil.FormListClear(NONE,Main.Data.KeyFindActorList)
		Main.SpellFindActorsAOE.Cast(self.Who,self.Who)

		Return
	EndFunction

EndState

State Phase2

	Function Execute()

		Main.Util.PrintDebug("[EffectFindActors:Phase2:Execute] Found " + self.Who.GetDisplayName())
		StorageUtil.FormListAdd(NONE,Main.Data.KeyFindActorList,self.Who)

		Return
	EndFunction

EndState
