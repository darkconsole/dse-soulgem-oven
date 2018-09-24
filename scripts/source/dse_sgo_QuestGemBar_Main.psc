Scriptname dse_sgo_QuestGemBar_Main extends SKI_WidgetBase

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

dse_sgo_QuestController_Main Property Main Auto

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Float Property VW = 1280.0 Auto Hidden
Float Property VH = 720.0 Auto Hidden

Float Property W = 0.0 Auto Hidden
Float Property H = 0.0 Auto Hidden
Float Property Percent = 100.0 Auto Hidden
String Property Text = "" Auto Hidden

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

String Function GetMethod(String Method)
{get fqmn for the ui.}

	Return WidgetRoot + Method
EndFunction

String Function GetWidgetSource()
{specificy location of ui element}

	Return "dse-soulgem-oven/meter.swf"
EndFunction

;;String Function GetWidgetType()
;;{not actually sure doesnt seem documented}

;;	Return "SGO4GemBar"
;;EndFunction

Event OnWidgetReset()
{when a widget is turned on}

	Int[] Colours = new Int[3]
	Int Ev

	parent.OnWidgetReset()
	UI.Invoke(HUD_MENU, GetMethod(".initCommit"))

	Colours[0] = 0x711e95
	Colours[1] = 0xcc66ff
	Colours[2] = -1

	self.HAnchor = "left"
	self.VAnchor = "bottom"
	self.Alpha = 0.0
	self.X = self.CalcX(0.0)
	self.Y = self.CalcY(0.0)
	self.W = 290.0
	self.H = 24.0

	UI.InvokeFloat(HUD_MENU, GetMethod(".setWidth"), self.W)
	UI.InvokeFloat(HUD_MENU, GetMethod(".setHeight"), self.H)
	UI.InvokeString(HUD_MENU, GetMethod(".setFillDirection"), "right")
	UI.InvokeString(HUD_MENU, GetMethod(".setText"), "")
	UI.InvokeIntA(HUD_MENU, GetMethod(".setColors"), Colours)

	Ev = ModEvent.Create("SGO4.GemBar.Ready")
	ModEvent.Send(Ev)

	Main.Util.PrintDebug(WidgetRoot + " has loaded")

	Return
EndEvent

Float Function CalcX(Float X)

	If(self.HAnchor == "center")
		Return ((self.VW / 2) - (self.W / 2)) + X
	ElseIf(self.HAnchor == "right")
		Return (self.VW - self.W) - X
	EndIf

	Return X
EndFunction

Float Function CalcY(Float Y)

	If(self.VAnchor == "center")
		Return ((self.VH / 2) - (self.H / 2)) + X
	ElseIf(self.VAnchor == "bottom")
		Return (self.VH - self.H) - X
	EndIf

	Return Y
EndFunction

Function SetPercent(Float Value)
{set the meter to a specific percentage}

	Float[] Args = new Float[2]
	Args[0] = Value / 100
	Args[1] = 0.0

	self.Percent = Value
	UI.InvokeFloatA(HUD_MENU, GetMethod(".setPercent"), Args)

	Return
EndFunction

Function SetText(String InputText)

	self.Text = InputText
	UI.InvokeString(HUD_MENU, GetMethod(".setText"), InputText)

	Return
EndFunction
