ScriptName dse_sgo_ContainInsertGem extends ObjectReference

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

dse_sgo_QuestController_Main Property Main Auto

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Int Property MaxCount Auto Hidden

Actor Property InsertInto Auto Hidden
Form[] Property GemForm Auto Hidden
Float[] Property GemData Auto Hidden
Int Property GemLoop Auto Hidden
Int Property GemStageLen Auto Hidden
Int Property GemActorMax Auto Hidden

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Event OnLoad()
{when this container is placed in the game world.}

	;; figure out who we wanted to shove this into.

	self.InsertInto = StorageUtil.GetFormValue(self,"SGO4.InsertInto") as Actor
	StorageUtil.UnsetFormValue(self,"SGO4.InsertInto")

	If(self.InsertInto == NONE)
		Main.Util.PrintLookup("ErrorNoTarget")
		self.Disable()
		self.Delete()
		Return
	EndIf

	;; figure out if we even can.

	Main.Data.ActorDetermineFeatures(self.InsertInto)

	If(!self.InsertInto.IsInFaction(Main.FactionProduceGems))
		Main.Util.PrintLookup("CannotProduceGems",self.InsertInto.GetDisplayName())
		self.HandleShutdown()
		Return
	EndIf

	self.GemActorMax = Main.Data.ActorGemMax(self.InsertInto)

	If(Main.Data.ActorGemCount(self.InsertInto) >= self.GemActorMax)
		Main.Util.PrintLookup("CannotFitMoreGems",self.InsertInto.GetDisplayName())
		self.HandleShutdown()
		Return
	EndIf

	self.GemStageLen = Main.Data.ListGemFilterPrepare()

	;; determine how many gems we can add.

	self.MaxCount = (self.GemActorMax - Main.Data.ActorGemCount(self.InsertInto))

	;; tell the player to open us.

	self.RegisterForModEvent(Main.Body.KeyEvActorDone,"OnDone")
	self.RegisterForModEvent(Main.Body.KeyEvActorInsert,"OnInsertGem")
	self.SetActorOwner(Main.Player.GetActorBase())
	self.Activate(Main.Player)

	Return
EndEvent

Event OnItemAdded(Form Type, Int Count, ObjectReference What, ObjectReference Source)
{when an item is added to this container.}

	;; if its not a valid soulgem we don't want it in here.

	If(!Main.ListGemFilter.HasForm(Type))
		Main.Util.PrintLookup("CannotInsertThat",self.InsertInto.GetDisplayName())

		If(What != None)
			self.RemoveItem(What,Count,TRUE,Source)
		Else
			self.RemoveItem(Type,Count,TRUE,Source)
		EndIf

		Return
	EndIf

	Return
EndEvent

Event OnItemRemoved(Form Type, int Count, ObjectReference What, ObjectReference Dest)
{when an item is removed from this container.}

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

	;; clamp if they exceeded the insertion count.

	Main.Util.PrintDebug(Main.Player.GetDisplayName() + " added " + CountItem + " gems.")

	If(CountItem > self.MaxCount)
		CountItem = self.MaxCount
	EndIf

	;;;;;;;;

	;; populate the data arrays with the values we want to add to the actor.

	self.GemData = Utility.CreateFloatArray(CountItem,0.0)
	self.GemForm = Utility.CreateFormArray(CountItem)

	Iter = 0
	IterType = 0

	While(Iter < self.GemForm.Length && IterType < CountType)
		Type = self.GetNthForm(IterType)
		TypeVal = (Main.ListGemFilter.Find(Type) % self.GemStageLen) + 1
		CountItem = self.GetItemCount(Type)
		IterItem = 0

		While(Iter < self.GemForm.Length && IterItem < CountItem)
			self.GemForm[Iter] = Type
			self.GemData[Iter] = TypeVal as Float
			Main.Util.PrintDebug(self.InsertInto.GetDisplayName() + " " + Type.GetName() + ": " + self.GemData[Iter])

			Iter += 1
			IterItem +=1
		EndWhile

		IterType += 1
	EndWhile

	self.ReturnUnusedItems()

	;; should we do anything?

	If(self.GemData.Length <= 0)
		self.HandleShutdown()
		Return
	EndIf

	;; check if any other mods like display model have this actor forced
	;; into submission. if they do we shouldn't animate them because the
	;; packages may break us later.

	If(Main.Util.ActorHasPackageOverrides(self.InsertInto))
		self.HandleSkipAnimation()
		Return
	EndIf

	;; else trigger the animations.

	self.HandleStartAnimation()

	Return
EndEvent

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Function ReturnUnusedItems()
{return any objects in this box back to the player.}

	Int Iter
	Form Type

	;; first remove the items we are going to use from this container.

	Iter = self.GemForm.Length

	While(Iter > 0)
		Iter -= 1

		If(self.GemForm[Iter] != None)
			self.RemoveItem(self.GemForm[Iter],1)
		EndIf
	EndWhile

	;; then return everything that remains in this container.

	Iter = self.GetNumItems()

	If(Iter > 0)
		Main.Util.Print("Returning unused items to your inventory...")
	EndIf

	While(Iter > 0)
		Iter -= 1
		Type = self.GetNthForm(Iter)

		Main.Player.AddItem(Type,self.GetItemCount(Type))
	EndWhile

	Return
EndFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Function HandleTimeoutRenew()
{handle kicking the timeout timer down the street.}

	self.UnregisterForUpdate()
	self.RegisterForSingleUpdate(30)

	Return
EndFunction

Function HandleSkipAnimation()
{handle inserting gems without animating.}

	Main.Util.PrintLookup("CannotAnimateOverride",self.InsertInto.GetDisplayName())
	self.GemLoop = 0
	While(self.GemLoop < self.GemData.Length)
		Main.Body.OnAnimationEvent_ActorMoan(self.InsertInto,50)
		self.HandleInsertGem()
		Utility.Wait(2.5)
		Main.Body.OnAnimationEvent_ActorResetFace(self.InsertInto)
		Utility.Wait(1.5)

		self.GemLoop += 1
	EndWhile
	self.HandleShutdown()

	Return
EndFunction

Function HandleStartAnimation()
{handle inserting gems via animating.}

	self.GemLoop = 0
	self.InsertInto.SetAnimationVariableBool("bForceIdleStop",TRUE)
	Main.Util.ActorArmourRemove(self.InsertInto)
	Main.Body.ActorLockdown(self.InsertInto)
	Utility.Wait(0.25)
	Main.Body.ActorAnimateSolo(self.InsertInto,Main.Util.GetInsertingAnimationName(0))

	Return
EndFunction

Function HandleInsertGem()
{handle inserting gem data into the actor.}

	Main.Data.ActorGemAdd(self.InsertInto,self.GemData[self.GemLoop])
	Main.Stats.IncInt(self.InsertInto,Main.Stats.KeyGemsInserted,1,TRUE)

	Return
EndFunction

Function HandleShutdown()
{terminate gracefully.}

	Main.Body.ActorRelease(self.InsertInto)
	Main.Util.ActorArmourReplace(self.InsertInto)
	self.InsertInto.SetAnimationVariableBool("bForceIdleStop",FALSE)

	self.RemoveAllItems(None)
	self.UnregisterForUpdate()
	self.UnregisterForModEvent(Main.Body.KeyEvActorDone)
	self.UnregisterForModEvent(Main.Body.KeyEvActorInsert)
	self.Disable()
	self.Delete()

	Main.Util.PrintDebug("Insertion Container Deleted")

	Return
EndFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Event OnUpdate()
{this should only tick if it got stuck somehow.}

	While(self.GemLoop < self.GemData.Length)
		self.HandleInsertGem()
		self.GemLoop += 1
	EndWhile

	self.HandleShutdown()

	Main.Util.Print("Container Insert Gem performed fallback cleanup on " + self.InsertInto.GetDisplayName())
	Main.Util.PrintDebug("Container Insert Gem performed fallback cleanup on " + self.InsertInto.GetDisplayName())
	Return
EndEvent

Event OnInsertGem(Form What)
{watch for insertion events to trigger adding the gem.}

	If(What != self.InsertInto)
		Return
	EndIf

	self.HandleTimeoutRenew()
	self.HandleInsertGem()
	Return
EndEvent

Event OnDone(Form What)
{watch for finish events to find out if we need to insert more or to stop.}

	If(What != self.InsertInto)
		Return
	EndIf

	;; should we go for another round?

	self.GemLoop += 1
	If(self.GemLoop < self.GemData.Length)
		self.HandleTimeoutRenew()
		Main.Body.ActorAnimateSolo(self.InsertInto,Main.Body.AniInsert01)
		Return
	EndIf

	self.HandleShutdown()
	Return
EndEvent
