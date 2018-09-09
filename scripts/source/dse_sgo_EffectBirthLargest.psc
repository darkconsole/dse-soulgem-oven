ScriptName dse_sgo_EffectBirthLargest extends ActiveMagicEffect

dse_sgo_QuestController_Main Property Main Auto

Event OnEffectStart(Actor Who, Actor From)

	If(!Main.Data.ActorGemReady(Who))
		Main.Util.Print(Who.GetDisplayName() + " is not ready to birth.")
		self.Dispel()
		Return
	EndIf

	self.RegisterForModEvent(Main.Body.KeyEvActorSpawnGem,"OnSpawnGem")
	self.RegisterForModEvent(Main.Body.KeyEvActorDone,"OnDone")
	Main.Body.ActorAnimateSolo(Who,Main.Body.AniBirth01)

	Return
EndEvent

Event OnSpawnGem(Form What)

	Actor Who = What as Actor
	Int TypeVal = Math.Floor(Main.Data.ActorGemRemoveLargest(Who))
	Form Type = Main.Data.GemStageGet(TypeVal)
	ObjectReference Gem = Who.PlaceAtMe(Type,1,FALSE,TRUE)

	Main.Util.PrintDebug("OnSpawnGem: " + TypeVal + " " + Type.GetName())

	Gem.MoveToNode(Who,"AnimObjectA")
	Gem.SetActorOwner(Who.GetActorBase())
	Gem.Enable()
	;;Gem.ApplyHavokImpulse(0,0,0,0.1)

	Return
EndEvent

Event OnDone()

	Main.Util.PrintDebug("OnDone")

	self.Dispel()
	Return
EndEvent
