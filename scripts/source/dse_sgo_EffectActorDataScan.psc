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

	;;;;;;;;

	self.RegisterForModEvent("SGO4.UpdateLoop.Done","OnUpdateLoop")
	self.RegisterForModEvent("SGO4.GemBar.Ready","OnBarReady")
	self.RegisterForModEvent("SGO4.MilkBar.Ready","OnBarReady")

	;;;;;;;;

	Main.Util.Print("Scanning " + self.Target.GetDisplayName())

	self.ActorScan()
	Return
EndEvent

Event OnEffectFinish(Actor Who, Actor From)
	Main.Util.Print("Done Scanning " + self.Target.GetDisplayName())
	
	Main.GemBar.SetTitle("")
	Main.GemBar.SetText("")
	Main.MilkBar.SetTitle("")
	Main.MilkBar.SetText("")

	Main.GemBar.FadeTo(0.0,0.25)
	Main.MilkBar.FadeTo(0.0,0.25)
	Return
EndEvent

Event OnPlayerLoadGame()
	self.Ready = 0
	Return
EndEvent

Event OnBarReady()

	self.Ready += 1

	If(self.Ready < 2)
		Return
	EndIf

	Main.Util.PrintDebug("Bars Ready For " + self.Target.GetDisplayName())
	self.ActorScan()
	Return
EndEvent

Event OnUpdateLoop()

	Main.Util.PrintDebug("Bars Update Event For " + self.Target.GetDisplayName())
	self.ActorScan()
	Return
EndEvent

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Function ActorScan()

	Bool ShowMilk = self.Target.IsInFaction(Main.FactionProduceMilk)
	Bool ShowGems = self.Target.IsInFaction(Main.FactionProduceGems)
	Bool ShowSemen = self.Target.IsInFaction(Main.FactionProduceSemen)

	Float GemRelPercent
	Int GemCount
	Int GemMax

	Float MilkPercent
	Float MilkCount
	Int MilkMax

	String DataString
	Float Offset = 0.0

	;; reset all the bars.

	Main.MilkBar.SetAlpha(0.0)
	Main.MilkBar.SetPercent(0.0)
	Main.GemBar.SetAlpha(0.0)
	Main.GemBar.SetPercent(0.0)
	
	;; position the bars and fetch any data we need for them.

	If(ShowMilk)
		Main.MilkBar.SetPosition(0.0,Offset)
		Offset += Main.MilkBar.H

		MilkPercent = Main.Data.ActorMilkTotalPercent(self.Target) * 100
		MilkCount = Main.Util.FloorTo(Main.Data.ActorMilkAmount(self.Target,TRUE),1)
		MilkMax = Main.Data.ActorMilkMax(self.Target)
	EndIf

	If(ShowGems)
		Main.GemBar.SetPosition(0.0,Offset)
		Offset += Main.GemBar.H

		GemRelPercent = Main.Data.ActorGemTotalPercent(self.Target,TRUE) * 100
		GemCount = Math.Floor(Main.Data.ActorGemCount(self.Target))
		GemMax = Math.Floor(Main.Data.ActorGemMax(self.Target))
	EndIf

	;; now i want to fill their data.

	If(ShowMilk)
		DataString = self.Target.GetDisplayName()
		DataString += "|" + Main.Util.FloatToString(MilkCount,1)
		DataString += "|" + MilkMax

		Main.MilkBar.SetTitle(self.Target.GetDisplayName())
		Main.MilkBar.SetText(Main.Util.StringLookup("ActorDataScanMilkText",DataString))
	EndIf

	If(ShowGems)
		DataString = self.Target.GetDisplayName()
		DataString += "|" + GemCount 
		DataString += "|" + GemMax

		Main.GemBar.SetTitle(self.Target.GetDisplayName())
		Main.GemBar.SetText(Main.Util.StringLookup("ActorDataScanGemText",DataString))
	EndIf

	;; now i want to show them.

	If(ShowMilk)
		Main.MilkBar.FadeTo(100.0,0.25)
		Main.MilkBar.SetPercent(MilkPercent)
	EndIf

	If(ShowGems)
		Main.GemBar.FadeTo(100.0,0.25)
		Main.GemBar.SetPercent(GemRelPercent)
	EndIf

	Return
EndFunction


