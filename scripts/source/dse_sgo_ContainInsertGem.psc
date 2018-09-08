ScriptName dse_sgo_ContainInsertGem extends ObjectReference

dse_sgo_QuestController_Main Property Main Auto

Int Property MaxCount Auto Hidden
Int Property CurrentCount Auto Hidden

Float[] Property GemData Auto Hidden
Int Property GemLoop Auto Hidden

Event OnLoad()
{when this container is placed in the game world.}

	;; build a list of acceptable items.
	;; this may need to be tweaked if the custom item system ever
	;; comes to fruitition.

	Main.ListGemFilter.Revert()
	Main.ListGemFilter.AddForms(Main.Data.GetGemStagesEmpty())
	Main.ListGemFilter.AddForms(Main.Data.GetGemStagesFilled())

	;; determine how many gems we can add.

	self.MaxCount = (Main.Data.ActorGemMax(Main.Player) - Main.Data.ActorGemCount(Main.Player))
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
			RemoveItem(What,Count,TRUE,Source)
		Else
			RemoveItem(Type,Count,TRUE,Source)
		EndIf

		Return
	EndIf

	;; make sure we can even fit what they wanted.

	If(self.CurrentCount >= self.MaxCount)
		Main.Util.Print("$SGO4_CannotInsertMore")

		If(What != None)
			RemoveItem(What,Count,TRUE,Source)
		Else
			RemoveItem(Type,Count,TRUE,Source)
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

	Main.Util.PrintDebug(Main.Player.GetDisplayName() + " can insert " + self.MaxCount + " gem(s).")
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

	Main.Util.PrintDebug(What.GetDisplayName() + " inserted " + CountItem + " gems.")
	self.GemData = Utility.CreateFloatArray(CountItem,0.0)
	Main.Util.PrintDebug("CreateFloatArray Done")
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
			Main.Util.PrintDebug(What.GetDisplayName() + " " + Type.GetName() + ": " + self.GemData[Iter])

			Iter += 1
			IterItem +=1
		EndWhile

		IterType += 1
	EndWhile

	;; trigger the insertions.

	self.GemLoop = 0

	If(self.GemData.Length > 0)
		self.InsertGem(Main.Player)
	Else
		self.Disable()
		self.Delete()
	EndIf

	Return
EndEvent

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

	Main.Body.ActorAnimateSolo(Who,AniName)

	Return
EndFunction

Event OnAnimateInsert(Form What)

	Actor Who = What as Actor
	Main.Util.PrintDebug("ContainerInsertGem OnAnimateInsert")

	Main.Data.ActorGemAdd(Who,self.GemData[self.GemLoop])

	Return
EndEvent

Event OnAnimateDone(Form What)

	Actor Who = What as Actor
	Main.Util.PrintDebug("ContainerInsertGem OnAnimateDone")

	self.GemLoop += 1

	If(self.GemLoop < self.GemData.Length)
		self.InsertGem(Who)
		Return
	EndIf

	self.UnregisterForModEvent(Main.Body.KeyEvActorDone)
	self.Disable()
	self.Delete()
	Return
EndEvent

