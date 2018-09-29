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
	
	Float Delay
	Int ActorCount
	Int ActorIter
	Bool ActorCull
	Actor Who
	Int Ev

	;;;;;;;;
	;;;;;;;;

	Delay = Main.Config.GetFloat("UpdateLoopDelay")
	ActorCount = Main.Data.ActorTrackingCount()
	ActorIter = 0
	ActorCull = FALSE

	While(ActorIter < ActorCount)
		Who = Main.Data.ActorTrackingGet(ActorIter)

		If(Who != None)
			;;If(Who.Is3dLoaded())
				Main.Util.PrintDebug("Update " + Who.GetDisplayName())
				Main.Data.ActorUpdate(Who)
				Main.Body.ActorUpdate(Who)
			;;Else
			;;	Main.Util.PrintDebug("Update "  + Who.GetDisplayName() + " Skipped (Not Loaded)")
			;;EndIf
		Else
			ActorCull = TRUE
		EndIf

		ActorIter += 1
		Utility.Wait(Delay)
	EndWhile

	If(ActorCull)
		Main.Util.PrintDebug("Update detected lost references, cleaning tracking list.")
		Main.Data.ActorTrackingCull()
	EndIf

	;;;;;;;;
	;;;;;;;;

	Ev = ModEvent.Create("SGO4.UpdateLoop.Done")
	ModEvent.Send(Ev)

	If(self.IsRunning())
		Main.Util.PrintDebug("Update Loop Renewed")
		self.RegisterForSingleUpdate(Main.Config.GetFloat("UpdateLoopFreq"))
	Else
		Main.Util.PrintDebug("Update Loop Terminated")
	EndIf

	Return
EndEvent

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
