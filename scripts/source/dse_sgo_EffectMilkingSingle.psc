ScriptName dse_sgo_EffectMilkingSingle extends ActiveMagicEffect

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

dse_sgo_QuestController_Main Property Main Auto

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Actor Property MilkFrom Auto Hidden
Int Property MilkRace Auto Hidden
Form Property Milk Auto Hidden

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Event OnEffectStart(Actor Who, Actor From)

	Actor Target

	;; determine if we were targeting someone.

	If(Who == Main.Player)
		Target = Game.GetCurrentCrosshairRef() as Actor
		If(Target != None)
			Main.SpellMilkingAction.Cast(Target,Target)
			self.Dispel()
			Return
		EndIf
	EndIf

	self.MilkFrom = Who
	self.MilkRace = Main.Data.RaceFind(Who.GetRace())
	self.Milk = Main.Data.RaceGetMilk(self.MilkRace)

	;; determine if the actor is able to birth.

	If(Main.Data.ActorMilkAmount(self.MilkFrom) < 1.0)
		Main.Util.Print(self.MilkFrom.GetDisplayName() + " is not ready to milk.")
		self.Dispel()
		Return
	EndIf

	;; get ready for a show.

	self.RegisterForModEvent(Main.Body.KeyEvActorSpawnGem,"OnSpawnGem")
	self.RegisterForModEvent(Main.Body.KeyEvActorDone,"OnDone")

	Main.Data.ActorMilkLimit(self.MilkFrom)
	Main.Util.ActorArmourRemove(self.MilkFrom)
	Main.Body.ActorAnimateSolo(self.MilkFrom,Main.Body.AniBirth01)

	Return
EndEvent

Event OnSpawnGem(Form What)

	ObjectReference Bottle = self.MilkFrom.PlaceAtMe(self.Milk,1,FALSE,TRUE)

	Main.Data.ActorMilkInc(self.MilkFrom,-1.0)

	Bottle.MoveToNode(self.MilkFrom,"AnimObjectA")
	Bottle.SetActorOwner(Main.Player.GetActorBase())
	Bottle.Enable()

	Return
EndEvent

Event OnDone(Form What)

	Main.Util.ActorArmourReplace(self.MilkFrom)
	self.Dispel()

	Return
EndEvent
