Scriptname dse_sgo_EffectActorDataScan extends ActiveMagicEffect

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

dse_sgo_QuestController_Main Property Main Auto

Actor Property Target Auto Hidden
Int Property Ready Auto Hidden

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Event OnEffectStart(Actor Who, Actor From)

	self.Target = Game.GetCurrentCrosshairRef() As Actor

	If(self.Target == None)
		self.Target = Who
	EndIf

	If(!Main.Util.ActorIsValid(self.Target))
		Main.Util.PrintLookup("ActorNotValid",Who.GetDisplayName())
		self.Dispel()
		Return
	EndIf

	Main.GemUI.Target.ForceRefTo(self.Target)
	Main.GemUI.OnUpdateWidget()

	self.RegisterForSingleUpdate(Main.Config.GetInt(".UpdateLoopFreq"))
	Return
EndEvent

Event OnEffectFinish(Actor Who, Actor From)
	Main.Util.PrintLookup("ScannerDone",self.Target.GetDisplayName())

	Main.GemUI.Target.Clear()
	Main.GemUI.OnUpdateWidget()

	Return
EndEvent

Event OnPlayerLoadGame()

	Return
EndEvent

Event OnUpdate()

	Main.GemUI.OnUpdateWidget()

	self.RegisterForSingleUpdate(Main.Config.GetInt(".UpdateLoopFreq"))
	Return
EndEvent

