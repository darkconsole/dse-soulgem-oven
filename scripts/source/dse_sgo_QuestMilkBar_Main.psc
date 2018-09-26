Scriptname dse_sgo_QuestMilkBar_Main extends dse_sgo_QuestGemBar_Main

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

String function GetWidgetType()
	return "dse_sgo_QuestMilkBar_Main"
EndFunction

Event OnWidgetReset()
{when a widget is turned on}

	Int[] Colours = new Int[3]
	Int Ev

	self.WidgetBaseReset()

	Colours[0] = 0xF2F2F2
	Colours[1] = 0xD9D9D9
	Colours[2] = -1

	self.HAnchor = "left"
	self.VAnchor = "bottom"
	self.SetAlpha(100.0)
	self.SetScale(0.75)
	self.SetPosition(0.0,0.0)

	UI.InvokeIntA(HUD_MENU, GetMethod(".setColors"), Colours)
	UI.InvokeString(HUD_MENU, GetMethod(".setFillDirection"), "right")
	UI.InvokeString(HUD_MENU, GetMethod(".setTitle"), self.Title)
	UI.InvokeString(HUD_MENU, GetMethod(".setText"), self.Text)

	Ev = ModEvent.Create("SGO4.MilkBar.Ready")
	ModEvent.Send(Ev)

	Main.Util.PrintDebug(WidgetRoot + " is ready.")
	Return
EndEvent
