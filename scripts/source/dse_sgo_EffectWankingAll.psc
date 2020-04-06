ScriptName dse_sgo_EffectWankingAll extends ActiveMagicEffect

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

dse_sgo_QuestController_Main Property Main Auto

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Actor Property SemenFrom Auto Hidden
Int[] Property SemenRace Auto Hidden
Form Property Semen Auto Hidden
Bool Property HasWanked=FALSE Auto Hidden

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Event OnEffectStart(Actor Who, Actor From)

	Actor Target

	;; determine if we were targeting someone.

	If(Who == Main.Player)
		Target = Game.GetCurrentCrosshairRef() as Actor
		If(Target != None)
			Main.SpellWankingAction.Cast(Target,Target)
			self.Dispel()
			Return
		EndIf
	EndIf

	self.SemenFrom = Who
	self.SemenRace = Main.Data.RaceFind(Who.GetRace())
	self.Semen = Main.Data.RaceGetSemen(self.SemenRace[0],self.SemenRace[1])

	;; determine if the actor is able to Semen.

	If(Main.Data.ActorSemenAmount(self.SemenFrom) < 1.0)
		Main.Util.PrintLookup("NotReadyToWank",self.SemenFrom.GetDisplayName())
		self.Dispel()
		Return
	EndIf

	;; check if any other mods like display model have this actor forced
	;; into submission. if they do we shouldn't animate them because the
	;; packages may break us later.

	If(Main.Util.ActorHasPackageOverrides(self.SemenFrom))
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
	self.RegisterForSingleUpdate(15)

	Return
EndFunction

Function HandleSkipAnimation()
{handle Semening without animating.}

	Main.Data.ActorSemenLimit(self.SemenFrom)
	Main.Util.PrintLookup("CannotAnimateOverride",self.SemenFrom.GetDisplayName())

	While(Main.Data.ActorSemenAmount(self.SemenFrom) >= 1.0)
		Main.Body.OnAnimationEvent_ActorMoan(self.SemenFrom,50)
		self.HandleSpawnSemen(FALSE)
		Utility.Wait(2.5)
		Main.Body.OnAnimationEvent_ActorResetFace(self.SemenFrom)
		Utility.Wait(1.5)
	EndWhile

	Main.Body.ActorRelease(self.SemenFrom)
	self.Dispel()

	Return
EndFunction

Function HandleStartAnimation()
{handle Semening via animating.}

	self.RegisterForModEvent(Main.Body.KeyEvActorSpawnSemen,"OnSpawnSemen")
	self.RegisterForModEvent(Main.Body.KeyEvActorDone,"OnDone")
	self.HandleTimeoutRenew()
	
	Main.Data.ActorSemenLimit(self.SemenFrom)
	Main.Util.ActorArmourRemove(self.SemenFrom)
	Main.Body.ActorLockdown(self.SemenFrom)
	Utility.Wait(0.25)
	Debug.SendAnimationEvent(self.SemenFrom,"SOSFastErect")
	Utility.Wait(0.25)
	Main.Body.ActorAnimateSolo(self.SemenFrom,Main.Util.GetWankingAnimationName(0))

	Return
EndFunction

Function HandleSpawnSemen(Bool FromAni)

	ObjectReference Bottle
	Float[] Pos = Main.Util.GetNodePositionAtDistance(self.SemenFrom,"NPC Pelvis [Pelv]",Main.Config.GetFloat(".ActorDropDistance"))

	Main.Data.ActorSemenInc(self.SemenFrom,-1.0)

	If(FromAni)
		self.HandleTimeoutRenew()
		Bottle = self.SemenFrom.PlaceAtMe(self.Semen,1,FALSE,TRUE)
		Bottle.MoveToNode(self.SemenFrom,"AnimObjectA")
		Bottle.Enable()
	Else
		Bottle = self.SemenFrom.PlaceAtMe(self.Semen,1,FALSE,TRUE)
		Bottle.SetPosition(Pos[1],Pos[2],Pos[3])
		Bottle.Enable()
	EndIf

	Bottle.SetActorOwner(Main.Player.GetActorBase())
	Main.Stats.IncInt(self.SemenFrom,Main.Stats.KeySemensWanked,1,TRUE)
	Main.Util.ActorLevelAlchemy(self.SemenFrom)
	self.HasWanked = TRUE

	Return
EndFunction

Function HandleShutdown()
{terminate gracefully.}

	Main.Body.ActorRelease(self.SemenFrom)
	Main.Util.ActorArmourReplace(self.SemenFrom)
	Debug.SendAnimationEvent(self.SemenFrom,"SOSFlaccid")

	self.UnregisterForUpdate()
	self.Dispel()

	Main.Util.PrintDebug("Semen Single Complete")

	Return
EndFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Event OnUpdate()
{this should only tick if it got stuck somehow.}

	If(!self.HasWanked)
		self.HandleSpawnSemen(FALSE)
	EndIf

	self.HandleShutdown()
	Main.Util.Print("Semen Single performed fallback cleanup on " + self.SemenFrom.GetDisplayName())
	Main.Util.PrintDebug("Semen Single performed fallback cleanup on " + self.SemenFrom.GetDisplayName())
	Return
EndEvent

Event OnSpawnSemen(Form What)
	
	If(What != self.SemenFrom)
		Return
	EndIf

	self.HandleSpawnSemen(TRUE)
	Return
EndEvent

Event OnDone(Form What)

	If(What != self.SemenFrom)
		Return
	EndIf

	If(Main.Data.ActorSemenAmount(self.SemenFrom) >= 1.0)
		self.HandleTimeoutRenew()
		Main.Body.ActorAnimateSolo(self.SemenFrom,Main.Util.GetWankingAnimationName(0))
		Return
	EndIf

	self.HandleShutdown()
	Return
EndEvent
