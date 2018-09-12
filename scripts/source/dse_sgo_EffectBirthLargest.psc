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
		Main.Util.Print(self.BirthFrom.GetDisplayName() + " is not ready to birth.")
		self.Dispel()
		Return
	EndIf

	;; get ready for a show.

	self.RegisterForModEvent(Main.Body.KeyEvActorSpawnGem,"OnSpawnGem")
	self.RegisterForModEvent(Main.Body.KeyEvActorDone,"OnDone")

	Main.Util.ActorArmourRemove(self.BirthFrom)
	Main.Body.ActorAnimateSolo(self.BirthFrom,Main.Body.AniBirth01)

	Return
EndEvent

Event OnSpawnGem(Form What)

	Int TypeVal
	Form Type
	ObjectReference Gem

	If(What != self.BirthFrom)
		Return
	EndIf

	TypeVal = Math.Floor(Main.Data.ActorGemRemoveLargest(self.BirthFrom))
	Type = Main.Data.GemStageGet(TypeVal)
	Gem = self.BirthFrom.PlaceAtMe(Type,1,FALSE,TRUE)

	Gem.MoveToNode(self.BirthFrom,"AnimObjectA")
	Gem.SetActorOwner(Main.Player.GetActorBase())
	Gem.Enable()
	Main.Stats.IncInt((What as Actor),Main.Stats.KeyGemsBirthed,1,TRUE)

	Return
EndEvent

Event OnDone(Form What)

	If(What != self.BirthFrom)
		Return
	EndIf

	Main.Util.ActorArmourReplace(self.BirthFrom)
	self.Dispel()

	Return
EndEvent
