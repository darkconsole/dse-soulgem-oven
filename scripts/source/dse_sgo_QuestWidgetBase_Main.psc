Scriptname dse_sgo_QuestWidgetBase_Main extends Quest

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

dse_sgo_QuestController_Main Property SGO Auto
ReferenceAlias Property Target Auto

iWant_Widgets Property iWant Auto Hidden
Int[] Property Items Auto Hidden

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Event OnInit()

	SGO.Util.PrintDebug("[WidgetBase] OnInit")

	self.DynopulateItemsAsMeters(0)

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

Function DynopulateItemsAsMeters(Int Needed)

	Int[] ItemsNew
	Int Iter

	;; we need more than we have so add additional meters.

	If(Needed > self.Items.Length)
		SGO.Util.PrintDebug("[WidgetBase] DynopulateItemsAsMeters Expand To " + Needed)
		ItemsNew = Utility.CreateIntArray(Needed)
		Iter = 0

		;; retain existing meters.

		While(Iter < self.Items.Length)
			ItemsNew[Iter] = self.Items[Iter]
			Iter += 1
		EndWhile

		;; initialize addtional meters.

		While(Iter < ItemsNew.Length)
			ItemsNew[Iter] = self.iWant.loadMeter()
			self.iWant.SetVisible(ItemsNew[Iter])
			Iter += 1
		EndWhile

		self.Items = ItemsNew
		Return
	EndIf

	;; we do not need as many meters as we used to.

	If(Needed < self.Items.Length)
		SGO.Util.PrintDebug("[WidgetBase] DynopulateItemsAsMeters Shrink To " + Needed)
		ItemsNew = Utility.CreateIntArray(Needed)
		Iter = 0

		;; retain only as many as we need.

		While(Iter < ItemsNew.Length)
			ItemsNew[Iter] = self.Items[Iter]
			Iter += 1
		EndWhile

		;; then destroy the remainders.

		While(Iter < self.Items.Length)
			self.iWant.Destroy(self.Items[Iter])
			Iter += 1
		EndWhile

		self.Items = ItemsNew
		Return
	EndIf

	Return
EndFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; below are things that should be moved to scripts extending ;;
;; this one with generic prototypes added here for templates. ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Function OnRenderWidget()

	Return
EndFunction
