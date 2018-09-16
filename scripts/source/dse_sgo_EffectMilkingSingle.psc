ScriptName dse_sgo_EffectMilkingSingle extends ActiveMagicEffect

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

dse_sgo_QuestController_Main Property Main Auto

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Actor Property MilkFrom Auto Hidden
Int Property MilkRace Auto Hidden
Form Property Milk Auto Hidden
Bool Property HasMilked=FALSE Auto Hidden

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

	;; determine if the actor is able to milk.

	If(Main.Data.ActorMilkAmount(self.MilkFrom) < 1.0)
		Main.Util.PrintLookup("NotReadyToMilk",self.MilkFrom.GetDisplayName())
		self.Dispel()
		Return
	EndIf


	;; check if any other mods like display model have this actor forced
	;; into submission. if they do we shouldn't animate them because the
	;; packages may break us later.

	If(Main.Util.ActorHasPackageOverrides(self.MilkFrom))
		self.HandleSkipAnimation()
		Return
	EndIf

	;; else trigger the animations.

	self.HandleStartAnimation()

	Return
EndEvent

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Function HandleTimeoutRenew()
{handle kicking the timeout timer down the street.}

	self.UnregisterForUpdate()
	self.RegisterForSingleUpdate(30)

	Return
EndFunction

Function HandleSkipAnimation()
{handle milking without animating.}

	Main.Util.PrintLookup("CannotAnimateOverride",self.MilkFrom.GetDisplayName())
	Main.Body.OnAnimationEvent_ActorMoan(self.MilkFrom,50)
	self.HandleSpawnMilk(FALSE)
	Utility.Wait(2.5)
	Main.Body.OnAnimationEvent_ActorResetFace(self.MilkFrom)
	Utility.Wait(1.5)
	Main.Body.ActorRelease(self.MilkFrom)
	self.Dispel()

	Return
EndFunction

Function HandleStartAnimation()
{handle milking via animating.}

	self.RegisterForModEvent(Main.Body.KeyEvActorSpawnMilk,"OnSpawnMilk")
	self.RegisterForModEvent(Main.Body.KeyEvActorDone,"OnDone")
	self.HandleTimeoutRenew()
	
	Main.Data.ActorMilkLimit(self.MilkFrom)
	Main.Body.ActorLockdown(self.MilkFrom)
	Main.Util.ActorArmourRemove(self.MilkFrom)
	Main.Body.ActorAnimateSolo(self.MilkFrom,Main.Body.AniMilking01)

	Return
EndFunction

Function HandleSpawnMilk(Bool FromAni)

	ObjectReference Bottle

	Main.Data.ActorMilkInc(self.MilkFrom,-1.0)

	If(FromAni)
		self.HandleTimeoutRenew()
		Bottle = self.MilkFrom.PlaceAtMe(self.Milk,1,FALSE,TRUE)
		Bottle.MoveToNode(self.MilkFrom,"AnimObjectA")
		Bottle.Enable()
	Else
		self.MilkFrom.AddItem(self.Milk,1,TRUE)
		Bottle = self.MilkFrom.DropObject(self.Milk,1)
	EndIf

	Bottle.SetActorOwner(Main.Player.GetActorBase())
	Main.Stats.IncInt(self.MilkFrom,Main.Stats.KeyMilksMilked,1,TRUE)
	Main.Util.ActorLevelAlchemy(self.MilkFrom)
	self.HasMilked = TRUE

	Return
EndFunction

Function HandleShutdown()
{terminate gracefully.}

	Main.Body.ActorRelease(self.MilkFrom)
	Main.Util.ActorArmourReplace(self.MilkFrom)

	self.UnregisterForUpdate()
	self.Dispel()

	Main.Util.PrintDebug("Milk Single Complete")

	Return
EndFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Event OnUpdate()
{this should only tick if it got stuck somehow.}

	If(!self.HasMilked)
		self.HandleSpawnMilk(FALSE)
		self.HandleShutdown()
	EndIf

	Main.Util.Print("Milk Single performed fallback cleanup on " + self.MilkFrom.GetDisplayName())
	Main.Util.PrintDebug("Milk Single performed fallback cleanup on " + self.MilkFrom.GetDisplayName())
	Return
EndEvent

Event OnSpawnMilk(Form What)

	If(What != self.MilkFrom)
		Return
	EndIf

	self.HandleSpawnMilk(TRUE)
	Return
EndEvent

Event OnDone(Form What)

	If(What != self.MilkFrom)
		Return
	EndIf

	self.HandleShutdown()
	Return
EndEvent
