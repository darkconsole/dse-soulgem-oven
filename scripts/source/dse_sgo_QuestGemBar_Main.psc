Scriptname dse_sgo_QuestGemBar_Main extends SKI_WidgetBase

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

dse_sgo_QuestController_Main Property Main Auto

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; the pseudosize of the viewport. hardcoded in the game.

Float Property VW = 1280.0 Auto Hidden
Float Property VH = 720.0 Auto Hidden

;; the size of our flash object.

Float Property FW = 433.0 Auto Hidden
Float Property FH = 60.0 Auto Hidden

;; store a copy of our size data before passing calcs to the
;; widget's magic properties.

Float Property W = 0.0 Auto Hidden
Float Property H = 0.0 Auto Hidden
Float Property PosX = 0.0 Auto Hidden
Float Property PosY = 0.0 Auto Hidden

;; some default values.

Float Property Percent = 100.0 Auto Hidden
String Property Text = "" Auto Hidden
String Property Title = "" Auto Hidden

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

String function GetWidgetType()
	return "dse_sgo_QuestGemBar_Main"
EndFunction

Function WidgetBaseReset()

	;; copied from SKI_WidgetBase OnWidgetReset()
	
	UpdateWidgetClientInfo()
	UpdateWidgetHAnchor()
	UpdateWidgetVAnchor()
	UpdateWidgetPositionX()
	UpdateWidgetPositionY()
	UpdateWidgetAlpha()

	;; more common code

	UI.Invoke(HUD_MENU, GetMethod(".initCommit"))

	Return
EndFunction

Event OnWidgetReset()
{when a widget is turned on}

	Int[] Colours = new Int[3]
	Int Ev

	self.WidgetBaseReset()	

	Colours[0] = 0x711e95
	Colours[1] = 0xcc66ff
	Colours[2] = -1

	self.HAnchor = "left"
	self.VAnchor = "bottom"
	self.SetAlpha(0.0)
	self.SetScale(0.75)
	self.SetPosition(0.0,0.0)

	UI.InvokeIntA(HUD_MENU, GetMethod(".setColors"), Colours)
	UI.InvokeString(HUD_MENU, GetMethod(".setFillDirection"), "right")
	UI.InvokeString(HUD_MENU, GetMethod(".setTitle"), self.Title)
	UI.InvokeString(HUD_MENU, GetMethod(".setText"), self.Text)

	Ev = ModEvent.Create("SGO4.GemBar.Ready")
	ModEvent.Send(Ev)

	Main.Util.PrintDebug(WidgetRoot + " is ready.")
	Return
EndEvent

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Float Function CalcX(Float CX)

	If(self.HAnchor == "center")
		Return ((self.VW / 2) - (self.W / 2)) + CX
	ElseIf(self.HAnchor == "right")
		Return self.VW - CX
	EndIf

	Return CX
EndFunction

Float Function CalcY(Float CY)

	If(self.VAnchor == "center")
		Return ((self.VH / 2) - (self.H / 2)) + CY
	ElseIf(self.VAnchor == "bottom")
		Return self.VH - CY
	EndIf

	Return CY
EndFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Function SetPosition(Float CX, Float CY)

	self.PosX = CX
	self.PosY = CY

	self.X = self.CalcX(CX)
	self.Y = self.CalcY(CY)

	Main.Util.PrintDebug(WidgetRoot + " position " + self.X + " " + self.Y)
	Return
EndFunction

Function SetScale(Float Factor)

	self.W = self.FW * Factor
	self.H = self.FH * Factor

	self.SetPosition(self.PosX,self.PosY)
	UI.InvokeFloat(HUD_MENU, GetMethod(".setWidth"), self.W)
	UI.InvokeFloat(HUD_MENU, GetMethod(".setHeight"), self.H)

	Main.Util.PrintDebug(WidgetRoot + " scale " + self.W + " " + self.H)
	Return
EndFunction

Function SetAlpha(Float CA)

	self.Alpha = CA

	Main.Util.PrintDebug(WidgetRoot + " alpha " + self.Alpha)
	Return
EndFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Function SetPercent(Float Value, Bool Force=FALSE)
{set the meter to a specific percentage}

	Float[] Args = new Float[2]
	Args[0] = Value / 100.0
	Args[1] = (Force As Int) As Float

	self.Percent = Value
	UI.InvokeFloatA(HUD_MENU, GetMethod(".setPercent"), Args)

	Main.Util.PrintDebug(WidgetRoot + " percent " + Args[0] + " " + Args[1])

	Return
EndFunction

Function SetText(String InputText)

	self.Text = InputText
	UI.InvokeString(HUD_MENU, GetMethod(".setText"), InputText)

	Return
EndFunction

Function SetTitle(String InputText)

	self.Title = InputText
	UI.InvokeString(HUD_MENU, GetMethod(".setTitle"), InputText)

	Return
EndFunction
