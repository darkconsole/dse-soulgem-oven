ScriptName dse_sgo_QuestUtil_Main extends Quest

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

dse_sgo_QuestController_Main Property Main Auto

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; mostly debugging

Function Print(String Msg)

	Debug.Notification("[SGO] " + Msg)
	Return
EndFunction

Function PrintDebug(String Msg)

	If(Main.Config.DebugMode)
		MiscUtil.PrintConsole("[SGO] " + Msg)
	EndIf

	Return
EndFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; mostly game data related.

Form Function GetForm(Int FormID)
{get a specific form from the soulgem oven esp.}

	Return Game.GetFormFromFile(FormID,Main.KeyESP)
EndFunction

Form Function GetFormFrom(String ModName, Int FormID)
{gets a form from a specific mod.}

	If(Game.GetModByName(ModName) == 255)
		Return NONE
	EndIf

	Return Game.GetFormFromFile(FormID,ModName)
EndFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; maths

Int Function RoundToInt(Float Val)
{round a float to an integer.}

	Return Math.Floor(Val + 0.5)
EndFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Function ActorArmourRemove(Actor Who)
{remove an actor's chestpiece.}

	Form[] Items

	If(Main.Config.GetBool("SexLabStrip"))
		Items = Main.SexLab.StripActor(Who,None,FALSE,FALSE)
	Else
		If(Who.GetWornForm(0x00000004) != None)
			Items = new Form[1]
			Items[0] = Who.GetWornForm(0x00000004)
			Who.UnequipItemSlot(32)
			Who.QueueNiNodeUpdate()
		EndIf
	EndIf

	If((Items != None) && (Items.Length > 0))
		StorageUtil.FormListCopy(Who,"SGO4.Actor.Armor",Items)
	EndIf

	Return
EndFunction

Function ActorArmourReplace(Actor Who)
{replace an actor's chestpiece.}

	Form[] Items = StorageUtil.FormListToArray(Who,"SGO4.Actor.Armor")

	;;If(Main.Config.GetBool("SexLabStrip"))
	If((Items != None) && (Items.Length > 0))
		Main.SexLab.UnstripActor(Who,Items,FALSE)
	EndIf
	;;Else
	;;	If(StorageUtil.GetFormValue(Who,"SGO.Actor.Armor.Chest"))
	;;		Who.EquipItem(Storageutil.GetFormValue(Who,"SGO.Actor.Armor.Chest"),FALSE,TRUE)
	;;		StorageUtil.SetFormValue(who,"SGO.Actor.Armor.Chest",None)
	;;	EndIf
	;;EndIf

	StorageUtil.FormListClear(Who,"SGO4.Actor.Armor")
	Return
EndFunction
