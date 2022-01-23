ScriptName dse_sgo_QuestGemUI extends dse_sgo_QuestWidgetBase_Main

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

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
	EndIf

	;;;;;;;;

	Iter = 0

	If(Who.IsInFaction(SGO.FactionProduceMilk))
		SGO.Util.PrintDebug("[WidgetBase] OnRenderWidget Milk " + Iter)
		self.iWant.SetMeterRGB(self.Items[Iter], 200,200,200, 128,128,128, 255,255,255)
		self.iWant.SetMeterPercent(self.Items[Iter], 0)
		self.iWant.SetZoom(self.Items[Iter], ModW, ModH)
		self.iWant.SetRotation(self.Items[Iter], Rot)
		self.iWant.SetPos(self.Items[Iter], (PosX + (Iter * Gap)), PosY)
		self.iWant.SetMeterPercent(self.Items[Iter], ((Milk * 100) As Int))
		Iter += 1
	EndIf

	If(Who.IsInFaction(SGO.FactionProduceSemen))
		SGO.Util.PrintDebug("[WidgetBase] OnRenderWidget Semen " + Iter)
		self.iWant.SetMeterRGB(self.Items[Iter], 200,200,180, 128,128,108, 255,255,235)
		self.iWant.SetMeterPercent(self.Items[Iter], 0)
		self.iWant.SetZoom(self.Items[Iter], ModW, ModH)
		self.iWant.SetRotation(self.Items[Iter], Rot)
		self.iWant.SetPos(self.Items[Iter], (PosX + (Iter * Gap)), PosY)
		self.iWant.SetMeterPercent(self.Items[Iter], ((Semen * 100) As Int))
		Iter += 1
	EndIf

	Oter = Iter
	While(Iter < (Gems.Length + Oter))
		SGO.Util.PrintDebug("[WidgetBase] OnRenderWidget Gem " + Iter + ": " + (((Gems[Iter-Oter] / GemsMax) * 100) As Int))
		self.iWant.SetMeterRGB(self.Items[Iter], 147,32,195, 137,22,185, 120,200,200)
		self.iWant.SetMeterPercent(self.Items[Iter], 0)
		self.iWant.SetZoom(self.Items[Iter], ModW, ModH)
		self.iWant.SetRotation(self.Items[Iter], Rot)
		self.iWant.SetPos(self.Items[Iter], (PosX + (Iter * Gap)), PosY)
		self.iWant.SetMeterPercent(self.Items[Iter], (((Gems[Iter-Oter] / GemsMax) * 100) As Int))
		Iter += 1
	EndWhile

	Return
EndFunction
