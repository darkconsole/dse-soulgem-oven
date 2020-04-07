Scriptname dse_sgo_QuestGemBar_Main extends SKI_WidgetBase

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

dse_sgo_QuestController_Main Property Main Auto

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; the pseudosize of the viewport. hardcoded in the game.

Float Property VW = 1280.0 AutoReadOnly Hidden
Float Property VH = 720.0 AutoReadOnly Hidden

;; the size of our flash object.

Float Property FW = 433.0 AutoReadOnly Hidden
Float Property FH = 60.0 AutoReadOnly Hidden

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; some default values.

String Property Direction = "right" Auto Hidden
Float Property Percent = 100.0 Auto Hidden
String Property Text = "" Auto Hidden
String Property Title = "" Auto Hidden

Int Property ColourLeft = 0xCC66FF Auto Hidden
Int Property ColourRight = 0x711E95 Auto Hidden
Int Property ColourFlash = -1 Auto Hidden
Float Property Scale = 0.75 Auto Hidden
Float Property PosX = 0.0 Auto Hidden
Float Property PosY = 0.0 Auto Hidden
String Property PosH = "left" Auto Hidden
String Property PosV = "bottom" Auto Hidden

;; place for some data we want in their original values before
;; we allow any calculators to fudge them for actual use.

Float Property SetW = 0.0 Auto Hidden
Float Property SetH = 0.0 Auto Hidden

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Event OnWidgetReset()
{override: when a widget is turned on.}

	self.WidgetBaseReset()

	self.SetAlpha(0.0)
	self.SetAnchor(self.PosH,self.PosV,FALSE)
	self.SetScale(self.Scale)
	self.SetPosition(self.PosX,self.PosY)
	self.SetColour(self.ColourLeft,self.ColourRight,self.ColourFlash)
	self.SetDirection(self.Direction)
	self.SetTitle(self.Title)
	self.SetText(self.Text)

	self.WidgetReady("SGO4.GemBar.Ready")
	Return
EndEvent

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

String Function GetWidgetSource()
{override: specificy location of ui element}

	;; assumes basedir interface/exported/widgets

	Return "dse-soulgem-oven/meter.swf"
EndFunction

String function GetWidgetType()
{override: specify the class of the ui element.}

	;; skyui source says this should be the same as the
	;; name of the script.

	;; doing that made skyui flip the fuck out about not
	;; being extended, i find the logic in how they test
	;; this strange. other than that one test it seems to
	;; not matter one damn bit so fuck it, now its random.

	;; i considered setting it to SKI_WidgetBase but could
	;; not find any instances where someone else had done
	;; that.

	return "SGO4GemBar"
EndFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

String Function GetMethod(String Method)
{get fqmn for the ui.}

	Return WidgetRoot + Method
EndFunction

Function WidgetBaseReset()
{this these are things that must be done with a widget starts.}

	self.Scale = Main.Config.GetFloat(".WidgetScale")
	self.PosH = Main.Config.GetString(".WidgetAnchorH")
	self.PosV = Main.Config.GetString(".WidgetAnchorV")

	;; copied from SKI_WidgetBase OnWidgetReset() because i was
	;; having issues with parent resolution when my other bars
	;; extend this script.
	
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

Function WidgetReady(String EvName)
{emit a mod event when we are done.}

	Int Ev = ModEvent.Create(EvName)
	ModEvent.Send(Ev)

	;;Main.Util.PrintDebug(WidgetRoot + " is ready.")

	Return
EndFunction

Float Function CalcX(Float CX)
{calculate a better x position based on how the widget is anchored.}

	If(self.HAnchor == "center")
		Return ((self.VW / 2) - (self.SetW / 2)) + CX
	ElseIf(self.HAnchor == "right")
		Return self.VW - CX
	EndIf

	Return CX
EndFunction

Float Function CalcY(Float CY)
{calculate a better y position based on how the widget is anchored.}

	If(self.VAnchor == "center")
		Return ((self.VH / 2) - (self.SetH / 2)) + CY
	ElseIf(self.VAnchor == "bottom")
		Return self.VH - CY
	EndIf

	Return CY
EndFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Function SetAnchor(String CH, String CV, Bool Pos=TRUE)
{set the anchor point for the widget.}

	self.HAnchor = CH
	self.VAnchor = CV

	If(Pos)
		self.SetPosition(self.PosX,self.PosY)
	EndIf

	Return
EndFunction

Function SetColour(Int CColourLeft, Int CColourRight, Int CColourFlash=-1)
{set the progress bar colours. its a gradient fill.}

	Int[] Colours = new Int[3]
	Colours[0] = CColourRight
	Colours[1] = CColourLeft
	Colours[2] = CColourFlash

	self.ColourLeft = CColourLeft
	self.ColourRight = CColourRight
	self.ColourFlash = CColourFlash

	UI.InvokeIntA(HUD_MENU, GetMethod(".setColors"), Colours)
	Return
EndFunction

Function SetDirection(String Dir)
{set which way the progress bar goes. left, right, both.}

	UI.InvokeString(HUD_MENU, GetMethod(".setFillDirection"), Dir)
	Return
EndFunction

Function SetPosition(Float CX, Float CY, Float Dur=0.0)
{move the widget to the specified location taking into consideration 
how the widget is anchored.}

	self.PosX = CX
	self.PosY = CY

	If(Dur == 0.0)
		self.X = self.CalcX(CX)
		self.Y = self.CalcY(CY)
	Else
		self.TweenTo(self.CalcX(CX),self.CalcY(CY),Dur)
	EndIf

	;;Main.Util.PrintDebug(WidgetRoot + " position " + self.X + " " + self.Y)
	Return
EndFunction

Function SetScale(Float Factor)
{set the scale of the widget also allowing it to update its position
to reflect depending on how it was anchored.}

	self.SetW = self.FW * Factor
	self.SetH = self.FH * Factor
	self.Scale = Factor

	UI.InvokeFloat(HUD_MENU, GetMethod(".setWidth"), self.SetW)
	UI.InvokeFloat(HUD_MENU, GetMethod(".setHeight"), self.SetH)
	self.SetPosition(self.PosX,self.PosY)

	;;Main.Util.PrintDebug(WidgetRoot + " scale " + self.SetW + " " + self.H)
	Return
EndFunction

Function SetAlpha(Float CA)
{set the widget's opacity from 0.0 to 100.0}

	self.Alpha = CA

	;;Main.Util.PrintDebug(WidgetRoot + " alpha " + self.Alpha)
	Return
EndFunction

Function SetPercent(Float Value, Bool Force=FALSE)
{set the meter to a specific percentage. if force is true then it will
be snapped to that percentage rather than animated to it.}

	Float[] Args = new Float[2]
	Args[0] = Value / 100.0
	Args[1] = (Force As Int) As Float

	self.Percent = Value
	UI.InvokeFloatA(HUD_MENU, GetMethod(".setPercent"), Args)

	;;Main.Util.PrintDebug(WidgetRoot + " percent " + Args[0] + " " + Args[1])

	Return
EndFunction

Function SetText(String InputText)
{set the text that appears on top of the progress bar.}

	self.Text = InputText
	UI.InvokeString(HUD_MENU, GetMethod(".setText"), InputText)

	Return
EndFunction

Function SetTitle(String InputText)
{set the title that appears above the progress bar.}

	self.Title = InputText
	UI.InvokeString(HUD_MENU, GetMethod(".setTitle"), InputText)

	Return
EndFunction
