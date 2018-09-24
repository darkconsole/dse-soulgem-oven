Scriptname dse_sgo_EffectActorDataScan extends ActiveMagicEffect

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

dse_sgo_QuestController_Main Property Main Auto

Actor Property Target Auto Hidden

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Event OnEffectStart(Actor Who, Actor From)

	self.Target = Game.GetCurrentCrosshairRef() As Actor

	If(self.Target == None)
		self.Target = Who
	EndIf

	;;;;;;;;

	self.RegisterForModEvent("SGO4.UpdateLoop.Done","OnUpdate")
	self.RegisterForModEvent("SGO4.GemBar.Ready","OnUpdate")

	;;;;;;;;

	Main.Util.Print("Scanning " + self.Target.GetDisplayName())

	self.ActorScan()
	Return
EndEvent

Event OnEffectFinish(Actor Who, Actor From)
	Main.Util.Print("Done Scanning " + self.Target.GetDisplayName())
	Main.GemBar.FadeTo(0.0,0.5)
	Return
EndEvent

Event OnPlayerLoadGame()

	Return
EndEvent

Event OnUpdate()

	Main.Util.PrintDebug("Updating Gem Bar For " + self.Target.GetDisplayName())
	self.ActorScan()
	Return
EndEvent

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Function ActorScan()

	Float GemRelPercent = Main.Data.ActorGemTotalPercent(self.Target,TRUE) * 100
	Int GemCount = Math.Floor(Main.Data.ActorGemCount(self.Target))
	Int GemMax = Math.Floor(Main.Data.ActorGemMax(self.Target))
	String DataString

	DataString = self.Target.GetDisplayName()
	DataString += "|" + GemCount 
	DataString += "|" + GemMax

	Main.GemBar.FadeTo(100.0,0.5)
	Main.GemBar.SetPercent(GemRelPercent)
	Main.GemBar.SetText(Main.Util.StringLookup("ActorDataScanGemText",DataString))

	Return
EndFunction


