ScriptName dse_sgo_EffectInfluenceRenew extends ReferenceAlias

dse_sgo_QuestController_Main Property SGO Auto

Event OnObjectEquipped(Form ItemBase, ObjectReference ItemRef)
	self.UpdateTrackingStatus()
	Return
EndEvent

Event OnObjectUnequipped(Form ItemBase, ObjectReference ItemRef)
	self.UpdateTrackingStatus()
	Return
EndEvent

Function UpdateTrackingStatus()

	Actor Me = self.GetActorReference()
	Form Worn = Me.GetWornForm(Armor.GetMaskForSlot(32))

	SGO.Util.PrintDebug("[InfluenceRenew] " + Me.GetDisplayName() + " " + Worn)

	If(Worn == NONE)
		Me.AddToFaction(SGO.FactionExposed)
	Else
		Me.RemoveFromFaction(SGO.FactionExposed)
	EndIf

	Return
EndFunction

