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

	;;;;;;;;

	self.RegisterForModEvent("SGO4.Body.ActorUpdate","OnActorUpdate")
	;;self.RegisterForModEvent("SGO4.UpdateLoop.Done","OnUpdateLoop")
	self.RegisterForModEvent("SGO4.GemBar.Ready","OnBarReady")
	self.RegisterForModEvent("SGO4.MilkBar.Ready","OnBarReady")
	self.RegisterForModEvent("SGO4.SemenBar.Ready","OnBarReady")
	self.RegisterForModEvent("SGO4.Widget.Scanner.Update","OnForceUpdate")

	;;;;;;;;

	Main.Data.ActorDetermineFeatures(self.Target)
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
	Main.SemenBar.SetTitle("")
	Main.SemenBar.SetText("")

	Main.GemBar.FadeTo(0.0,0.25)
	Main.MilkBar.FadeTo(0.0,0.25)
	Main.SemenBar.FadeTo(0.0,0.25)
	Return
EndEvent

Event OnPlayerLoadGame()

	self.Ready = 0
	Return
EndEvent

Event OnBarReady()

	self.Ready += 1

	If(self.Ready < 3)
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

Event OnActorUpdate(Form What)

	If(What != self.Target)
		Return
	EndIf

	Main.Util.PrintDebug("Bars Update Event For " + self.Target.GetDisplayName())
	self.ActorScan()	
	Return
EndEvent

Event OnForceUpdate()

	Main.Util.PrintDebug("Bars Force Update Event For " + self.Target.GetDisplayName())
	self.ActorScan()	
	Return
EndEvent

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Function ActorScan()

	Bool ShowMilk = self.Target.IsInFaction(Main.FactionProduceMilk)
	Bool ShowGems = self.Target.IsInFaction(Main.FactionProduceGems)
	Bool ShowSemen = self.Target.IsInFaction(Main.FactionProduceSemen)

	Float GemPercent
	Int GemCount
	Int GemMax
	String GemString
	Float GemOffset

	Float MilkPercent
	Float MilkCount
	Int MilkMax
	String MilkString
	Float MilkOffset

	Float SemenPercent
	Float SemenCount
	Int SemenMax
	String SemenString
	Float SemenOffset

	Float Scale = Main.Config.GetFloat("WidgetScale")
	Float PosX = Main.Config.GetFloat("WidgetOffsetX")
	Float Offset = Main.Config.GetFloat("WidgetOffsetY")
	Float OffsetFactor = 0.5
	String PosH = Main.Config.GetString("WidgetAnchorH")
	String PosV = Main.Config.GetString("WidgetAnchorV")

	;; fetch and calculate some data for positioning.

	If(ShowMilk)
		Main.MilkBar.SetScale(Scale)
		
		MilkOffset = Offset
		Offset += Main.MilkBar.SetH * OffsetFactor

		MilkPercent = Main.Data.ActorMilkTotalPercent(self.Target) * 100
		MilkCount = Main.Util.FloorTo(Main.Data.ActorMilkAmount(self.Target,TRUE),1)
		MilkMax = Main.Data.ActorMilkMax(self.Target)

		MilkString = self.Target.GetDisplayName()
		MilkString += "|" + Main.Util.FloatToString(MilkCount,1)
		MilkString += "|" + MilkMax
	EndIf

	If(ShowGems)
		Main.GemBar.SetScale(Scale)

		GemOffset = Offset
		Offset += Main.GemBar.SetH * OffsetFactor

		GemPercent = Main.Data.ActorGemTotalPercent(self.Target,TRUE) * 100
		GemCount = Math.Floor(Main.Data.ActorGemCount(self.Target))
		GemMax = Math.Floor(Main.Data.ActorGemMax(self.Target))

		GemString = self.Target.GetDisplayName()
		GemString += "|" + GemCount 
		GemString += "|" + GemMax
	EndIf

	If(ShowSemen)
		Main.SemenBar.SetScale(Scale)

		SemenOffset = Offset
		Offset += Main.SemenBar.SetH * OffsetFactor

		SemenPercent = Main.Data.ActorSemenTotalPercent(self.Target) * 100
		SemenCount = Main.Util.FloorTo(Main.Data.ActorSemenAmount(self.Target,TRUE),1)
		SemenMax = Main.Data.ActorSemenMax(self.Target)

		SemenString = self.Target.GetDisplayName()
		SemenString += "|" + Main.Util.FloatToString(SemenCount,1)
		SemenString += "|" + SemenMax
	EndIf

	;; figure out how to reorder them based on their anchor points.

	If(Main.GemBar.VAnchor == "bottom")
		If(ShowMilk)
			Offset -= Main.MilkBar.SetH * OffsetFactor
			MilkOffset = Offset
		EndIf
		If(ShowGems)
			Offset -= Main.GemBar.SetH * OffsetFactor
			GemOffset = Offset
		EndIf
		If(ShowSemen)
			Offset -= Main.SemenBar.SetH * OffsetFactor
			SemenOffset = Offset
		EndIf
	ElseIf(Main.GemBar.VAnchor == "center")
		;; todo
	EndIf

	;; figure out which bar should get the nameplate.

	If(ShowMilk)
		Main.MilkBar.SetTitle(self.Target.GetDisplayName())
	ElseIf(ShowGems)
		Main.GemBar.SetTitle(self.Target.GetDisplayName())
	ElseIf(ShowSemen)
		Main.SemenBar.SetTitle(self.Target.GetDisplayName())
	EndIf

	;; now i want to show them.

	If(ShowMilk)
		Main.MilkBar.SetText(Main.Util.StringLookup("ActorDataScanMilkText",MilkString))
		Main.MilkBar.SetAnchor(PosH,PosV)
		Main.MilkBar.SetPosition(PosX,MilkOffset,0.25)
		Main.MilkBar.FadeTo(100.0,0.25)
		Main.MilkBar.SetPercent(MilkPercent)
	EndIf

	If(ShowGems)
		Main.GemBar.SetText(Main.Util.StringLookup("ActorDataScanGemText",GemString))
		Main.GemBar.SetAnchor(PosH,PosV)
		Main.GemBar.SetPosition(PosX,GemOffset,0.25)
		Main.GemBar.FadeTo(100.0,0.25)
		Main.GemBar.SetPercent(GemPercent)
	EndIf

	If(ShowSemen)
		Main.SemenBar.SetText(Main.Util.StringLookup("ActorDataScanSemenText",SemenString))
		Main.SemenBar.SetAnchor(PosH,PosV)
		Main.SemenBar.SetPosition(PosX,SemenOffset,0.25)
		Main.SemenBar.FadeTo(100.0,0.25)
		Main.SemenBar.SetPercent(SemenPercent)
	EndIf

	Return
EndFunction

Function ResetAllBars()

	Main.MilkBar.SetTitle("")
	Main.MilkBar.SetText("")
	Main.MilkBar.SetAlpha(0.0)
	Main.MilkBar.SetPercent(0.0)
	Main.GemBar.SetTitle("")
	Main.GemBar.SetText("")
	Main.GemBar.SetAlpha(0.0)
	Main.GemBar.SetPercent(0.0)
	Main.SemenBar.SetTitle("")
	Main.SemenBar.SetText("")
	Main.SemenBar.SetAlpha(0.0)
	Main.SemenBar.SetPercent(0.0)

	Return
EndFunction

