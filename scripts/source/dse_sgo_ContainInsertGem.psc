ScriptName dse_sgo_ContainInsertGem extends ObjectReference

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

dse_sgo_QuestController_Main Property Main Auto

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Int Property MaxCount Auto Hidden
Int Property CurrentCount Auto Hidden

Actor Property InsertInto Auto Hidden
Float[] Property GemData Auto Hidden
Int Property GemLoop Auto Hidden

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Event OnLoad()
{when this container is placed in the game world.}

	;; figure out who we wanted to shove this into.

	self.InsertInto = StorageUtil.GetFormValue(self,"SGO4.InsertInto") as Actor
	StorageUtil.UnsetFormValue(self,"SGO4.InsertInto")

	If(self.InsertInto == None)
		self.InsertInto = Main.Player
	EndIf

	;; figure out if we even can.

	Main.Data.ActorDetermineFeatures(self.InsertInto)

	If(Main.Data.ActorGemCount(self.InsertInto) >= Main.Data.ActorGemMax(self.InsertInto))
		Main.Util.Print(self.InsertInto.GetDisplayName() + " fit any more gems.")
		self.Done()
		Return
	EndIf

	;; build a list of acceptable items.
	;; this may need to be tweaked if the custom item system ever
	;; comes to fruitition.

	Main.ListGemFilter.Revert()
	Main.ListGemFilter.AddForms(Main.Data.GetGemStagesEmpty())
	Main.ListGemFilter.AddForms(Main.Data.GetGemStagesFilled())

	;; determine how many gems we can add.

	self.MaxCount = (Main.Data.ActorGemMax(self.InsertInto) - Main.Data.ActorGemCount(self.InsertInto))
	self.CurrentCount = 0

	;; tell the player to open us.

	self.RegisterForModEvent(Main.Body.KeyEvActorDone,"OnAnimateDone")
	self.RegisterForModEvent(Main.Body.KeyEvActorInsert,"OnAnimateInsert")
	self.Activate(Main.Player)

	Return
EndEvent

Event OnItemAdded(Form Type, Int Count, ObjectReference What, ObjectReference Source)
{when an item is added to this container.}

	;; if its not a valid soulgem we don't want it in here.

	If(!Main.ListGemFilter.HasForm(Type))
		Main.Util.Print("$SGO4_CannotInsertThat")

		If(What != None)
			self.RemoveItem(What,Count,TRUE,Source)
		Else
			self.RemoveItem(Type,Count,TRUE,Source)
		EndIf

		Return
	EndIf

	;; make sure we can even fit what they wanted.

	If(self.CurrentCount >= self.MaxCount)
		Main.Util.Print("$SGO4_CannotInsertMore")

		If(What != None)
			self.RemoveItem(What,Count,TRUE,Source)
		Else
			self.RemoveItem(Type,Count,TRUE,Source)
		EndIf

		Return
	EndIf

	;; consider the following.

	self.CurrentCount += Count

	Return
EndEvent

Event OnItemRemoved(Form Type, int Count, ObjectReference What, ObjectReference Dest)
{when an item is removed from this container.}

	self.CurrentCount -= Count

	Return
EndEvent

Event OnActivate(ObjectReference What)
{when this chest is opened.}

	Int CountType
	Int CountItem
	Int TypeVal

	Int IterType
	Int IterItem

	Form Type
	Int Iter

	;; trick to lock up this processing until we close the menu.

	Main.Util.PrintDebug(self.InsertInto.GetDisplayName() + " can insert " + self.MaxCount + " gem(s).")
	Utility.Wait(0.25)

	;; process the contents.

	CountType = self.GetNumItems()
	CountItem = 0
	IterType = 0

	While(IterType < CountType)
		Type = self.GetNthForm(IterType)
		CountItem += self.GetItemCount(Type)
		IterType += 1
	EndWhile

	;;;;;;;;

	;; todo if CountItem > self.MaxCount 
	;; because the add item event seems flakey at best.

	;;;;;;;;

	Main.Util.PrintDebug(Main.Player.GetDisplayName() + " added " + CountItem + " gems.")
	self.GemData = Utility.CreateFloatArray(CountItem,0.0)
	Iter = 0

	;;;;;;;;

	IterType = 0
	While(IterType < CountType)
		Type = self.GetNthForm(IterType)
		TypeVal = (Main.ListGemFilter.Find(Type) % Main.Data.GemStageCount()) + 1
		CountItem = self.GetItemCount(Type)
		IterItem = 0

		While(IterItem < CountItem)
			self.GemData[Iter] = TypeVal as Float
			Main.Util.PrintDebug(self.InsertInto.GetDisplayName() + " " + Type.GetName() + ": " + self.GemData[Iter])

			Iter += 1
			IterItem +=1
		EndWhile

		IterType += 1
	EndWhile

	;; trigger the insertions.

	self.GemLoop = 0

	If(self.GemData.Length > 0)
		self.InsertGem(self.InsertInto)
		Return
	EndIf

	self.Done()
	Return
EndEvent

Function Done()
{handle cleanup of this container.}

	self.RemoveAllItems(None)
	self.UnregisterForModEvent(Main.Body.KeyEvActorDone)
	self.UnregisterForModEvent(Main.Body.KeyEvActorInsert)
	self.Disable()
	self.Delete()

	Main.Util.PrintDebug("Insertion Container Deleted")

	Return
EndFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Function InsertGem(Actor Who)
{consume gem and kick off animation.}

	String AniName

	If((self.GemLoop % 2) == 0)
		AniName = Main.Body.AniInsert01
	Else
		AniName = Main.Body.AniInsert02
	EndIf

	Main.Util.ActorArmourRemove(Who)
	Main.Body.ActorAnimateSolo(Who,AniName)

	Return
EndFunction

Event OnAnimateInsert(Form What)
{watch for insertion events to trigger adding the gem.}

	If(What != self.InsertInto)
		Return
	EndIf

	Main.Data.ActorGemAdd((What as Actor),self.GemData[self.GemLoop])
	Main.Stats.IncInt((What as Actor),Main.Stats.KeyGemsInserted,1,TRUE)

	Return
EndEvent

Event OnAnimateDone(Form What)
{watch for finish events to find out if we need to insert more or to stop.}

	If(What != self.InsertInto)
		Return
	EndIf

	self.GemLoop += 1

	If(self.GemLoop < self.GemData.Length)
		self.InsertGem(What as Actor)
		Return
	EndIf

	Main.Util.ActorArmourReplace(What as Actor)
	self.Done()
	Return
EndEvent
