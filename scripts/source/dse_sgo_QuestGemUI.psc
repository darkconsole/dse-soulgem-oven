ScriptName dse_sgo_QuestGemUI extends dse_sgo_QuestWidgetBase_Main

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Function OnUpdateWidget(Bool Flush=FALSE)

	If(Flush)
		self.DynopulateItemsAsMeters(0)
		self.iWant.Destroy(self.TitleShadow)
		self.iWant.Destroy(self.Title)
		self.TitleShadow = 0
		self.Title = 0
	EndIf

	self.OnRenderWidget()
	Return
EndFunction


Function OnRenderWidget()

	Actor Who = self.Target.GetActorReference()
	Int Needed = 0
	Int Iter = 0
	Int Oter = 0

	;; values for the positioning of the ui

	Int PosX
	Int PosY
	Float Scale
	Int ModW
	Int ModH
	Int Gap
	Int Rot
	Int FontSize

	;; values for the state of the ui

	Float[] Gems
	Int GemsMax
	Float Milk
	Float Semen

	;;;;;;;;

	If(Who == NONE)
		SGO.Util.PrintDebug("[WidgetBase] OnRenderWidget: No Target")
		self.DynopulateItemsAsMeters(0)
		Return
	EndIf

	SGO.Util.PrintDebug("[WidgetBase] OnRenderWidget: " + Who.GetDisplayName())
	PosX = SGO.Config.GetFloat(".WidgetOffsetX") As Int
	PosY = SGO.Config.GetFloat(".WidgetOffsetY") As Int
	Scale = SGO.Config.GetFloat(".WidgetScale")
	Gap = SGO.Config.GetFloat(".WidgetSpacing") As Int
	ModW = (Scale * SGO.Config.GetInt(".WidgetBarW")) As Int
	ModH = (Scale * SGO.Config.GetInt(".WidgetBarH")) As Int
	FontSize = (Scale * SGO.Config.GetInt(".WidgetFontSize")) As Int
	Rot = 90

	;;;;;;;;

	If(Who.IsInFaction(SGO.FactionProduceMilk))
		Milk = SGO.Data.ActorMilkTotalPercent(Who)
		Needed += 1
	EndIf

	If(Who.IsInFaction(SGO.FactionProduceSemen))
		Semen = SGO.Data.ActorSemenTotalPercent(Who)
		Needed += 1
	EndIf

	If(Who.IsInFaction(SGO.FactionProduceGems))
		Gems = SGO.Data.ActorGemGetList(Who)
		GemsMax = SGO.Data.GemStageCount(Who)
		Needed += Gems.Length
	EndIf

	If(self.Items.Length != Needed)
		self.DynopulateItemsAsMeters(Needed)

		;; since we had to rescale this is an acceptable time to force a
		;; potential ugly redraw for positioning. they have to all be set
		;; the same before rotating or they will be positined wrong.

		Iter = 0
		While(Iter < self.Items.Length)
			self.iWant.SetMeterPercent(self.Items[Iter], 0)
			self.iWant.SetZoom(self.Items[Iter], ModW, ModH)
			self.iWant.SetRotation(self.Items[Iter], Rot)
			Utility.Wait(0.1)
			self.iWant.SetPos( \
				self.Items[Iter], \
				((PosX + ((Iter * Gap) * Scale) + (self.iWant.GetXSize(self.Items[Iter]) / 2)) As Int), \
				((PosY - (self.iWant.GetYSize(self.Items[Iter]) / 4)) As Int) \
			)
			Iter += 1
		EndWhile
	EndIf

	;;;;;;;;

	Iter = 0

	If(Who.IsInFaction(SGO.FactionProduceMilk))
		SGO.Util.PrintDebug("[WidgetBase] OnRenderWidget Milk " + Iter)
		self.iWant.SetMeterRGB(self.Items[Iter], 200,200,200, 128,128,128, 255,255,255)
		self.iWant.SetMeterPercent(self.Items[Iter], ((Milk * 100) As Int))
		Iter += 1
	EndIf

	If(Who.IsInFaction(SGO.FactionProduceSemen))
		SGO.Util.PrintDebug("[WidgetBase] OnRenderWidget Semen " + Iter)
		self.iWant.SetMeterRGB(self.Items[Iter], 200,200,180, 128,128,108, 255,255,235)
		self.iWant.SetMeterPercent(self.Items[Iter], ((Semen * 100) As Int))
		Iter += 1
	EndIf

	Oter = Iter
	While(Iter < (Gems.Length + Oter))
		SGO.Util.PrintDebug("[WidgetBase] OnRenderWidget Gem " + Iter + ": " + (((Gems[Iter-Oter] / GemsMax) * 100) As Int))
		self.iWant.SetMeterRGB(self.Items[Iter], 147,32,195, 137,22,185, 120,200,200)
		self.iWant.SetMeterPercent(self.Items[Iter], (((Gems[Iter-Oter] / GemsMax) * 100) As Int))
		Iter += 1
	EndWhile

	;;;;;;;;

	If(self.Title)
		self.iWant.SetText(self.TitleShadow, Who.GetDisplayName())
		self.iWant.SetText(self.Title, Who.GetDisplayName())
	Else
		self.TitleShadow = self.iWant.loadText(Who.GetDisplayName(), size=FontSize)
		self.Title = self.iWant.loadText(Who.GetDisplayName(), size=FontSize)

		self.iWant.SetTransparency(self.TitleShadow, 50)
		self.iWant.SetRGB(self.TitleShadow, 0, 0, 0)
	EndIf

	self.iWant.SetPos(                                        \
		self.TitleShadow,                                   \
		((PosX + 1 + (self.iWant.GetXSize(self.Title) / 2)) As Int),     \
		((PosY + 1 + ((Gap / 2) * Scale) + (self.iWant.GetYSize(self.Title) / 2)) As Int) \
	)

	self.iWant.SetPos(                                        \
		self.Title,                                         \
		((PosX + (self.iWant.GetXSize(self.Title) / 2)) As Int),     \
		((PosY + ((Gap / 2) * Scale) + (self.iWant.GetYSize(self.Title) / 2)) As Int) \
	)

	self.iWant.SetVisible(self.TitleShadow)
	self.iWant.SetVisible(self.Title)

	Return
EndFunction
