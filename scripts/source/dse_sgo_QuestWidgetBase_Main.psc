Scriptname dse_sgo_QuestWidgetBase_Main extends Quest

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

dse_sgo_QuestController_Main Property SGO Auto
ReferenceAlias Property Target Auto

iWant_Widgets Property iWant Auto Hidden

Int[] Items

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Event OnInit()

	SGO.Util.PrintDebug("[WidgetBase] OnInit")

	self.DynopulateItems(0)

	UnregisterForModEvent("iWantWidgetsReset")
	RegisterForModEvent("iWantWidgetsReset", "OnLocalEvent")

	UnregisterForModEvent("SGO4.Body.ActorUpdate")
	RegisterForModEvent("SGO4.Body.ActorUpdate","OnDataUpdate")
EndEvent

Event OnUpdate()

	self.OnUpdateWidget()
	Return
EndEvent

Event OnLocalEvent(String EvName, String ArgStr, Float ArgInt, Form From)

	If(EvName == "iWantWidgetsReset")
		SGO.Util.PrintDebug("[WidgetBase] iWantWidgetsReset")
		self.OnLocalReset(ArgStr, ArgInt, From)
	EndIf

	Return
EndEvent

Event OnLocalReset(String ArgStr, Float ArgInt, Form From)

	self.iWant = From as iWant_Widgets
	self.OnUpdateWidget()
	Return
EndEvent

Event OnDataUpdate(Form Whom)

	Actor Who = Whom As Actor

	If(Who != self.Target.GetActorReference())
		Return
	EndIf

	self.OnUpdateWidget()
	Return
EndEvent

Function OnUpdateWidget()

	;;If(self.IsRunning())
		self.OnRenderWidget()
	;;EndIf

	Return
EndFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; below are things that should be moved to scripts extending ;;
;; this one with generic prototypes added here for templates. ;;
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
		self.DynopulateItems(0)
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

	If(Items.Length != Needed)
		self.DynopulateItems(Needed)
	EndIf

	;;;;;;;;

	Iter = 0

	If(Who.IsInFaction(SGO.FactionProduceMilk))
		SGO.Util.PrintDebug("[WidgetBase] OnRenderWidget Milk " + Iter)
		self.iWant.SetMeterRGB(Items[Iter], 200,200,200, 128,128,128, 255,255,255)
		self.iWant.SetMeterPercent(Items[Iter], 0)
		self.iWant.SetZoom(Items[Iter], ModW, ModH)
		self.iWant.SetRotation(Items[Iter], Rot)
		self.iWant.SetPos(Items[Iter], (PosX + (Iter * Gap)), PosY)
		self.iWant.SetMeterPercent(Items[Iter], ((Milk * 100) As Int))
		Iter += 1
	EndIf

	If(Who.IsInFaction(SGO.FactionProduceSemen))
		SGO.Util.PrintDebug("[WidgetBase] OnRenderWidget Semen " + Iter)
		self.iWant.SetMeterRGB(Items[Iter], 200,200,180, 128,128,108, 255,255,235)
		self.iWant.SetMeterPercent(Items[Iter], 0)
		self.iWant.SetZoom(Items[Iter], ModW, ModH)
		self.iWant.SetRotation(Items[Iter], Rot)
		self.iWant.SetPos(Items[Iter], (PosX + (Iter * Gap)), PosY)
		self.iWant.SetMeterPercent(Items[Iter], ((Semen * 100) As Int))
		Iter += 1
	EndIf

	Oter = Iter
	While(Iter < (Gems.Length + Oter))
		SGO.Util.PrintDebug("[WidgetBase] OnRenderWidget Gem " + Iter + ": " + (((Gems[Iter-Oter] / GemsMax) * 100) As Int))
		self.iWant.SetMeterRGB(Items[Iter], 147,32,195, 137,22,185, 120,200,200)
		self.iWant.SetMeterPercent(Items[Iter], 0)
		self.iWant.SetZoom(Items[Iter], ModW, ModH)
		self.iWant.SetRotation(Items[Iter], Rot)
		self.iWant.SetPos(Items[Iter], (PosX + (Iter * Gap)), PosY)
		self.iWant.SetMeterPercent(Items[Iter], (((Gems[Iter-Oter] / GemsMax) * 100) As Int))
		Iter += 1
	EndWhile

	Return
EndFunction

Function DynopulateItems(Int Needed)

	Int[] ItemsNew
	Int Iter

	;; we need more than we have so add additional meters.

	If(Needed > Items.Length)
		SGO.Util.PrintDebug("[WidgetBase] DynopulateItems Expand To " + Needed)
		ItemsNew = Utility.CreateIntArray(Needed)
		Iter = 0

		;; retain existing meters.

		While(Iter < Items.Length)
			ItemsNew[Iter] = Items[Iter]
			Iter += 1
		EndWhile

		;; initialize addtional meters.

		While(Iter < ItemsNew.Length)
			ItemsNew[Iter] = self.iWant.loadMeter()
			self.iWant.SetVisible(ItemsNew[Iter])
			Iter += 1
		EndWhile

		Items = ItemsNew
		Return
	EndIf

	;; we do not need as many meters as we used to.

	If(Needed < Items.Length)
		SGO.Util.PrintDebug("[WidgetBase] DynopulateItems Shrink To " + Needed)
		ItemsNew = Utility.CreateIntArray(Needed)
		Iter = 0

		;; retain only as many as we need.

		While(Iter < ItemsNew.Length)
			ItemsNew[Iter] = Items[Iter]
			Iter += 1
		EndWhile

		;; then destroy the remainders.

		While(Iter < Items.Length)
			self.iWant.Destroy(Items[Iter])
			Iter += 1
		EndWhile

		Items = ItemsNew
		Return
	EndIf

	Return
EndFunction
