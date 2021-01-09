
ScriptName dse_sgo_EffectTransferResource Extends ActiveMagicEffect

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; defined properties.

dse_sgo_QuestController_Main Property Main Auto
Int Property ResourceType Auto
Message Property ExtractModeDialog Auto

;; determined properties.

Actor Property Source Auto Hidden
Actor Property Dest Auto Hidden
Form Property ResourceForm Auto Hidden
Int Property ResourceCount Auto Hidden
Int Property DepositSpace Auto Hidden
Int[] Property RaceMap Auto Hidden
Int Property ExtractMode Auto Hidden
Bool Property Animate Auto Hidden
Float Property DropDistance Auto Hidden
String Property Animation1 Auto Hidden
String Property Animation2 Auto Hidden

;; resource enums.

Int Property ResourceGem = 1 AutoReadOnly Hidden
Int Property ResourceMilk = 2 AutoReadOnly Hidden
Int Property ResourceSemen = 3 AutoReadOnly Hidden

;; these line up with the message box choices.

Int Property ExtractModeSingle = 0 AutoReadOnly Hidden
Int Property ExtractModeAll = 1 AutoReadOnly Hidden
Int Property ExtractModeCancel = 2 AutoReadOnly Hidden

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Event OnEffectStart(Actor Who, Actor From)

	Bool IsValidMode
	Bool HasTarget
	Bool HasResources
	Bool HasSpace

	;; determine who and what we are working with.

	self.Source = Who
	self.Dest = From
	self.RaceMap = Main.Data.RaceFind(self.Source.GetRace())
	self.Animate = !Main.Util.ActorHasPackageOverrides(self.Source) && !Main.Util.ActorHasPackageOverrides(self.Dest)
	self.DropDistance = Main.Config.GetFloat(".ActorDropDistance")

	;; determine how many we want to extract.

	self.ExtractMode = self.ExtractModeDialog.Show()
	self.ResourceCount = 1
	self.DepositSpace = self.GetDepositSpace()

	If(self.ExtractMode == self.ExtractModeAll)
		self.ResourceCount = self.GetResourceCount()
	EndIf

	;; determine if we can proceed.

	IsValidMode = (self.ExtractMode >= self.ExtractModeSingle) && (self.ExtractMode <= self.ExtractModeAll)
	HasTarget = (self.Source != None) && (self.Dest != None)
	HasResources = (self.ResourceCount > 0)
	HasSpace = (self.DepositSpace > 0)
	
	;; proceed.

	Main.Util.PrintDebug("[EffectTransferResource.OnEffectStart] " + self.Source.GetDisplayName() + " & " + self.Dest.GetDisplayname() + " Animate: " + (self.Animate As Int))

	If(IsValidMode && HasTarget && HasResources && HasSpace)
		Main.Util.PrintDebug("[EffectTransferResource.OnEffectStart] " + self.Source.GetDisplayName() + " Resource Count: " + self.ResourceCount)
		Main.Util.PrintDebug("[EffectTransferResource.OnEffectStart] " + self.Dest.GetDisplayName() + " Depsoit Space: " + self.DepositSpace)
		self.RegisterForSingleUpdate(0.25)
	Else
		Main.Util.PrintDebug("[EffectTransferResource.OnEffectStart] " + self.Source.GetDisplayName() + " Canceled")
		Main.Util.PrintDebug("[EffectTransferResource.OnEffectStart] " + self.Dest.GetDisplayName() + " Canceled")
		self.Dispel()
	EndIf

	Return
EndEvent

Event OnEffectFinish(Actor Who, Actor From)

	Main.Util.PrintDebug("[EffectTransferResource.OnEffectFinish] " + self.Source.GetDisplayName())
	Return
EndEvent

Event OnUpdate()
{state template.}

	Return
EndEvent

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Function StartExtracting()
{kick off the extraction process.}

	If(self.Animate)
		self.StartExtractingAnimated()
	Else
		self.StartExtractingStatic()
	EndIf

	Return
EndFunction

Function StartExtractingStatic()
{handle unanimated extractions.}

	While(self.ResourceCount > 0)
		self.DropResource(self.ExtractResource())
	EndWhile

	self.Dispel()
	Return
EndFunction

Function StartExtractingAnimated()
{handle animated extractions.}

	self.Animation1 = self.GetAnimation1()
	self.Animation2 = self.GetAnimation2()

	If(self.Animation1 == "" && self.Animation2 == "")
		Main.Util.PrintDebug("[EffectTransferResource.StartExtractingAnimated] No animation found, falling back to static.")
		self.StartExtractingStatic()
		Return
	EndIf

	self.RegisterForModEvent(Main.Body.KeyEvActorSpawnGem,"OnAnimatedSpawnItem")
	self.RegisterForModEvent(Main.Body.KeyEvActorSpawnMilk,"OnAnimatedSpawnItem")
	self.RegisterForModEvent(Main.Body.KeyEvActorSpawnSemen,"OnAnimatedSpawnItem")
	self.RegisterForModEvent(Main.Body.KeyEvActorDone,"OnAnimatedDone")

	;; lock the source
	Main.Util.ActorArmourRemove(self.Source)
	Main.Util.ActorArmourRemove(self.Dest)
	Utility.Wait(0.1)

	Main.Body.ActorLockdown(self.Source)
	Main.Body.ActorLockdown(self.Dest)
	Utility.Wait(0.1)

	self.Dest.MoveTo(self.Source,0,0,0,TRUE)

	self.GotoState("Animating")
	self.OnUpdate()

	;; now we sit and wait for animation events.

	Return
EndFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Event OnAnimatedSpawnItem(Form Who)
{handle spawn item events from animations.}

	If(Who != self.Source)
		Return
	EndIf

	self.DropResource(self.ExtractResource())

	;; if we are out of resources then kick the animation into its final
	;; stage so we can exit.

	If(self.ResourceCount <= 0)
		Main.Util.PrintDebug("[EffectTransferResource:OnAnimatedSpawnItem] " + self.Source.GetDisplayName() + " resources depleted.")
		self.OnAnimatedDone(self.Dest)
		self.OnAnimatedDone(self.Source)
	EndIf

	If(self.DepositSpace <= 0)
		Main.Util.PrintDebug("[EffectTransferResource:OnAnimatedSpawnItem] " + self.Dest.GetDisplayName() + " out of space.")
		self.OnAnimatedDone(self.Dest)
		self.OnAnimatedDone(self.Source)
	EndIf

	Return
EndEvent

Event OnAnimatedDone(Form Whom)
{handle done event from animations.}

	Actor Who = Whom as Actor

	If(Who != self.Source && Who != self.Dest)
		Return
	EndIf

	Main.Body.ActorRelease(Who)
	Main.Util.ActorArmourReplace(Who)
	Main.Util.PrintDebug("[EffectTransferResource:OnAnimatedDone] " + Who.GetDisplayName())
	self.Dispel()

	Return
EndEvent

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Int Function GetResourceCount()
{determine how much resource our source can give.}

	Int Output = 0

	If(self.ResourceType == self.ResourceGem)
		Output = Main.Data.ActorGemCount(self.Source)
	ElseIf(self.ResourceType == self.ResourceMilk)
		Output = Main.Data.ActorMilkCount(self.Source)
	ElseIf(self.ResourceType == self.ResourceSemen)
		Output = Main.Data.ActorSemenCount(self.Source)
	EndIf

	Return Output
EndFunction

Int Function GetDepositSpace()
{determine how much resource our source can give.}

	Int Output = 0

	Main.Data.ActorDetermineFeatures(self.Dest)

	If(!self.Dest.IsInFaction(Main.FactionProduceGems))
		Main.Util.PrintDebug("[EffectTransferResource:GetDepositSpace] " + self.Dest.GetDisplayName() + " is not an oven")
		Return Output
	EndIf

	If(self.ResourceType == self.ResourceGem)
		Output = Main.Data.ActorGemMax(self.Dest) - Main.Data.ActorGemCount(self.Dest)
	ElseIf(self.ResourceType == self.ResourceMilk)
		Output = Math.floor(Main.Data.ActorMilkMax(self.Dest) - Main.Data.ActorMilkCount(self.Dest))
	ElseIf(self.ResourceType == self.ResourceSemen)
		Output = Main.Data.ActorSemenMax(self.Dest) - Main.Data.ActorSemenCount(self.Dest)
	EndIf

	Return PapyrusUtil.ClampInt(Output,0,99)
EndFunction

String Function GetAnimation1()
{determine which animation to use.}

	String Output = ""

	If(self.ResourceType == self.ResourceGem)
		Output = "dse-sgo-transfergem01a-01"
	EndIf

	Return Output
EndFunction

String Function GetAnimation2()
{determine which animation to use.}

	String Output = ""

	If(self.ResourceType == self.ResourceGem)
		Output = "dse-sgo-transfergem01b-01"
	EndIf

	Return Output
EndFunction

Form Function ExtractResource()
{extract the resource from the source and credit them for the method.}

	Form Output = NONE

	If(self.ResourceCount <= 0)
		Return Output
	EndIf

	If(self.ResourceType == self.ResourceGem)
		Output = Main.Data.GemStageGet(Math.Floor(Main.Data.ActorGemRemoveLargest(self.Source)))
		Main.Stats.IncInt(self.Source,Main.Stats.KeyGemsBirthed,1,TRUE)
	EndIf

	If(self.ResourceType == self.ResourceMilk)
		Output = Main.Data.RaceGetMilk(self.RaceMap[0],self.RaceMap[1])
		Main.Data.ActorMilkLimit(self.Source)
		Main.Data.ActorMilkInc(self.Source,-1.0)
		Main.Stats.IncInt(self.Source,Main.Stats.KeyMilksMilked,1,TRUE)
	EndIf

	If(self.ResourceType == self.ResourceSemen)
		Output = Main.Data.RaceGetSemen(self.RaceMap[0],self.RaceMap[1])
		Main.Data.ActorSemenLimit(self.Source)
		Main.Data.ActorSemenInc(self.Source,-1.0)
		Main.Stats.IncInt(self.Source,Main.Stats.KeySemensWanked,1,TRUE)
	EndIf

	self.ResourceCount -= 1

	Return Output
EndFunction

Function DropResource(Form ItemForm)
{drop the specified resource on the ground.}

	If(ItemForm == NONE)
		Main.Util.PrintDebug("[EffectTransferResource.DropResource] " + self.Source.GetDisplayName() + " No Item Found")
		Return
	EndIf

	If(self.ResourceType == self.ResourceGem)
		If(Main.Data.ActorGemAddForm(self.Dest,ItemForm))
			Main.Stats.IncInt(self.Dest,Main.Stats.KeyGemsInserted,1,TRUE)
		EndIf
	EndIf

	Return
EndFunction

Auto State Initial
	Event OnUpdate()
		self.StartExtracting()
		Return
	EndEvent
EndState

State Animating
	Event OnUpdate()

		;; the thing here is that constantly triggering an animation already
		;; playing does not cause it to restart. so we can just keep forcing
		;; the event over and over and over in case it got interupted.

		;;Main.Body.ActorAnimateSolo(self.Source,self.Animation1)
		;;Main.Body.ActorAnimateSolo(self.Dest,self.Animation2)
		Main.Body.ActorAnimateDuo(self.Source,self.Animation1,self.Dest,self.Animation2)
		self.RegisterForSingleUpdate(5.0)
		Return
	EndEvent
EndState
