ScriptName dse_sgo_EffectBirthLargest extends ActiveMagicEffect

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

dse_sgo_QuestController_Main Property Main Auto

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Actor Property BirthFrom Auto Hidden
Bool Property HasBirthed = FALSE Auto Hidden

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

Function HandleTimeoutRenew()
{handle kicking the timeout timer down the street.}

	self.UnregisterForUpdate()
	self.RegisterForSingleUpdate(30)

	Return
EndFunction

Function HandleSkipAnimation()
{handle birthing gems without animating.}

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
{handle birthing gems via animating.}

	self.RegisterForModEvent(Main.Body.KeyEvActorSpawnGem,"OnSpawnGem")
	self.RegisterForModEvent(Main.Body.KeyEvActorDone,"OnDone")
	self.HandleTimeoutRenew()

	Main.Body.ActorLockdown(self.BirthFrom)
	Main.Util.ActorArmourRemove(self.BirthFrom)
	Utility.Wait(0.25)
	Main.Body.ActorAnimateSolo(self.BirthFrom,Main.Util.GetBirthingAnimationName(0))

	Return
EndFunction

Function HandleSpawnGem(Bool FromAni)
{handle placing a soulgem in the gameworld.}

	Int TypeVal = Math.Floor(Main.Data.ActorGemRemoveLargest(self.BirthFrom))
	Form Type = Main.Data.GemStageGet(TypeVal)
	Float[] Pos = Main.Util.GetNodePositionAtDistance(self.BirthFrom,"NPC Pelvis [Pelv]",30)
	ObjectReference Gem

	If(FromAni)
		self.HandleTimeoutRenew()
		Gem = self.BirthFrom.PlaceAtMe(Type,1,FALSE,TRUE)
		Gem.MoveToNode(self.BirthFrom,"AnimObjectA")
		Gem.Enable()
	Else
		Gem = self.BirthFrom.PlaceAtMe(Type,1,FALSE,TRUE)
		Gem.SetPosition(Pos[1],Pos[2],Pos[3])
		Gem.Enable()
	EndIf

	Gem.SetActorOwner(Main.Player.GetActorBase())
	Main.Stats.IncInt(self.BirthFrom,Main.Stats.KeyGemsBirthed,1,TRUE)
	Main.Util.ActorLevelEnchanting(self.BirthFrom,TypeVal)
	self.HasBirthed = TRUE

	Return
EndFunction

Function HandleShutdown()
{terminate gracefully.}

	Main.Body.ActorRelease(self.BirthFrom)
	Main.Util.ActorArmourReplace(self.BirthFrom)

	self.UnregisterForUpdate()
	self.Dispel()

	Main.Util.PrintDebug("Birth Largest Complete")

	Return
EndFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Event OnUpdate()
{this should only tick if it got stuck somehow.}

	If(!self.HasBirthed)
		self.HandleSpawnGem(FALSE)
		self.HandleShutdown()
	EndIf

	Main.Util.Print("Birth Largest performed fallback cleanup on " + self.BirthFrom.GetDisplayName())
	Main.Util.PrintDebug("Birth Largest performed fallback cleanup on " + self.BirthFrom.GetDisplayName())
	Return
EndEvent

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

	self.HandleShutdown()
	Return
EndEvent
