ScriptName dse_sgo_EffectBirthLargest extends ActiveMagicEffect

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

dse_sgo_QuestController_Main Property Main Auto

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Actor Property BirthFrom Auto Hidden

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Event OnEffectStart(Actor Who, Actor From)

	Actor Target

	;; determine if we were targeting someone.

	If(Who == Main.Player)
		Target = Game.GetCurrentCrosshairRef() as Actor
		If(Target != None)
			Main.SpellBirthLargest.Cast(Target,Target)
			self.Dispel()
			Return
		EndIf
	EndIf

	self.BirthFrom = Who

	;; determine if the actor is able to birth.

	If(!Main.Data.ActorGemReady(self.BirthFrom))
		Main.Util.PrintLookup("NotReadyToBirth",self.BirthFrom.GetDisplayName())
		self.Dispel()
		Return
	EndIf

	;; check if any other mods like display model have this actor forced
	;; into submission. if they do we shouldn't animate them because the
	;; packages may break us later.

	If(Main.Util.ActorHasPackageOverrides(self.BirthFrom))
		self.HandleSkipAnimation()
		Return
	EndIf

	;; else trigger the animations.

	self.HandleStartAnimation()

	Return
EndEvent

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Function HandleSkipAnimation()

	Main.Util.PrintLookup("CannotAnimateOverride",self.BirthFrom.GetDisplayName())
	Main.Body.OnAnimationEvent_ActorMoan(self.BirthFrom,100)
	self.HandleSpawnGem(FALSE)
	Utility.Wait(2.5)
	Main.Body.OnAnimationEvent_ActorResetFace(self.BirthFrom)
	Utility.Wait(1.5)
	Main.Body.ActorRelease(self.BirthFrom)
	self.Dispel()

	Return
EndFunction

Function HandleStartAnimation()

	self.RegisterForModEvent(Main.Body.KeyEvActorSpawnGem,"OnSpawnGem")
	self.RegisterForModEvent(Main.Body.KeyEvActorDone,"OnDone")

	Main.Body.ActorLockdown(self.BirthFrom)
	Main.Util.ActorArmourRemove(self.BirthFrom)
	Main.Body.ActorAnimateSolo(self.BirthFrom,Main.Body.AniBirth01)

	Return
EndFunction

Function HandleSpawnGem(Bool FromAni)
	Int TypeVal = Math.Floor(Main.Data.ActorGemRemoveLargest(self.BirthFrom))
	Form Type = Main.Data.GemStageGet(TypeVal)
	ObjectReference Gem

	If(FromAni)
		Gem = self.BirthFrom.PlaceAtMe(Type,1,FALSE,TRUE)
		Gem.MoveToNode(self.BirthFrom,"AnimObjectA")
		Gem.Enable()
	Else
		self.BirthFrom.AddItem(Type,1,TRUE)
		Gem = self.BirthFrom.DropObject(Type,1)
	EndIf

	Gem.SetActorOwner(Main.Player.GetActorBase())
	Main.Stats.IncInt(self.BirthFrom,Main.Stats.KeyGemsBirthed,1,TRUE)
	Return
EndFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Event OnSpawnGem(Form What)

	If(What != self.BirthFrom)
		Return
	EndIf

	self.HandleSpawnGem(TRUE)
	Return
EndEvent

Event OnDone(Form What)

	If(What != self.BirthFrom)
		Return
	EndIf

	Main.Util.ActorArmourReplace(self.BirthFrom)
	Main.Body.ActorRelease(self.BirthFrom)
	self.Dispel()

	Return
EndEvent
