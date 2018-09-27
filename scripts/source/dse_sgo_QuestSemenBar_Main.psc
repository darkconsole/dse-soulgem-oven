Scriptname dse_sgo_QuestSemenBar_Main extends dse_sgo_QuestGemBar_Main

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Event OnWidgetReset()
{override: when a widget is turned on.}

	self.ColourRight = 0x858560
	self.ColourLeft = 0xf4f4f0
	self.ColourFlash = -1

	self.WidgetBaseReset()

	self.SetAlpha(0.0)
	self.SetAnchor(self.PosH,self.PosV,FALSE)
	self.SetScale(self.Scale)
	self.SetPosition(self.PosX,self.PosY)
	self.SetColour(self.ColourLeft,self.ColourRight,self.ColourFlash)
	self.SetDirection(self.Direction)
	self.SetTitle(self.Title)
	self.SetText(self.Text)

	self.WidgetReady("SGO4.SemenBar.Ready")
	Return
EndEvent

String function GetWidgetType()
{override: specify the class of the ui element.}

	Return "SGO4SemenBar"
EndFunction
