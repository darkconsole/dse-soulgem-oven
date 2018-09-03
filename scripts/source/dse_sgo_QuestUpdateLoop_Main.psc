ScriptName dse_sgo_QuestUpdateLoop_Main extends Quest

dse_sgo_QuestController_Main Property Main Auto

Event OnInit()
{kick off the processor loop. this will handle the passive progression of
the gems and such.}

	If(Main.IsStopped())
		Main.Util.PrintDebug("Aborting UpdateLoop Init: Controller is not running.")
		Return
	EndIf

	Main.Util.PrintDebug("Update Loop Enabled")
	self.RegisterForSingleUpdate(1.0)
	Return
EndEvent

Event OnUpdate()
{tick tock.}
	
	Int ActorCount
	Int ActorIter
	Bool ActorCull
	Actor Who

	;;;;;;;;
	;;;;;;;;

	Main.Util.PrintDebug("Update Begin")

	;;;;;;;;
	;;;;;;;;

	ActorCount = Main.Data.ActorTrackingCount()
	ActorIter = 0
	ActorCull = FALSE

	While(ActorIter < ActorCount)
		Who = Main.Data.ActorTrackingGet(ActorIter)

		If(Who != None)
			Main.Util.PrintDebug("Update Loop: Actor(" + Who.GetDisplayName() + ")")
			Main.Body.ActorUpdate(Who)
		Else
			ActorCull = TRUE
		EndIf

		ActorIter += 1
		Utility.Wait(0.25)
	EndWhile

	If(ActorCull)
		Main.Data.ActorTrackingCull()
	EndIf

	;;;;;;;;
	;;;;;;;;

	Main.Util.PrintDebug("Update Finished")

	;;;;;;;;
	;;;;;;;;

	If(self.IsRunning())
		Main.Util.PrintDebug("Update Loop Renewed")
		self.RegisterForSingleUpdate(Main.Config.GetFloat("UpdateLoopDelay"))
	Else
		Main.Util.PrintDebug("Update Loop Terminated")
	EndIf

	Return
EndEvent

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
