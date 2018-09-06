ScriptName dse_sgo_ContainSoulgemOven extends ObjectReference

dse_sgo_QuestController_Main Property Main Auto

Event OnLoad()

	;; build a list of acceptable items.
	;; this may need to be tweaked if the custom item system ever
	;; comes to fruitition.

	Main.ListGemFilter.Revert()
	Main.ListGemFilter.AddForms(Main.Data.GetGemStagesEmpty())
	Main.ListGemFilter.AddForms(Main.Data.GetGemStagesFilled())

	;; tell the player to open us.

	self.Activate(Main.Player)

	Return
EndEvent

Event OnItemAdded(Form Type, Int Count, ObjectReference What, ObjectReference Source)

	;; only the player should be inserting things here.

	If(Source != Main.Player)
		Return
	EndIf

	;; if its not a valid soulgem we don't want it in here.

	If(!Main.ListGemFilter.HasForm(Type))
		If(What != None)
			RemoveItem(What,Count,TRUE,Source)
		Else
			RemoveItem(Type,Count,TRUE,Source)
		EndIf
	EndIf

	Return
EndEvent

Event OnActivate(ObjectReference What)

	;; trick to lock up this processing until we close the menu.
	Utility.Wait(0.10)

	;; todo process the contents.

	Return
EndEvent
