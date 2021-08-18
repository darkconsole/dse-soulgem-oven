
ScriptName dse_sgo_EffectExtractResource Extends ActiveMagicEffect

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; defined properties.

dse_sgo_QuestController_Main Property Main Auto
Int Property ResourceType Auto
Message Property ExtractModeDialog Auto

;; determined properties.

Actor Property Source Auto Hidden
Form Property ResourceForm Auto Hidden
Int Property ResourceCount Auto Hidden
Int[] Property RaceMap Auto Hidden
Int Property ExtractMode Auto Hidden
Bool Property Animate Auto Hidden
Float Property DropDistance Auto Hidden
String Property Animation Auto Hidden

;; resource enums.

Int Property ResourceGem = 1 AutoReadOnly Hidden
Int Property ResourceMilk = 2 AutoReadOnly Hidden
Int Property ResourceSemen = 3 AutoReadOnly Hidden

;; these line up with the message box choices.

Int Property ExtractModeSingle = 0 AutoReadOnly Hidden
Int Property ExtractModeAll = 1 AutoReadOnly Hidden
Int Property ExtractModeCancel = 2 AutoReadOnly Hidden

;; bones for dropping items.

String Property DropNodeAnimated = "AnimObjectA" AutoReadOnly Hidden
String Property DropNodeStatic = "NPC Pelvis [Pelv]" AutoReadOnly Hidden

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Event OnEffectStart(Actor Who, Actor From)

	Bool IsValidMode
	Bool HasTarget
	Bool HasResources

	;; determine who and what we are working with.

	self.Source = Who
	self.RaceMap = Main.Data.RaceFind(Who.GetRace())
	self.Animate = !Main.Util.ActorHasPackageOverrides(Who)
	self.DropDistance = Main.Config.GetFloat(".ActorDropDistance")

	;; determine how many we want to extract.

	self.ExtractMode = self.ExtractModeDialog.Show()
	self.ResourceCount = 1

	If(self.ExtractMode == self.ExtractModeAll)
		self.ResourceCount = self.GetResourceCount()
	EndIf

	;; determine if we can proceed.

	IsValidMode = (self.ExtractMode >= self.ExtractModeSingle) && (self.ExtractMode <= self.ExtractModeAll)
	HasTarget = (self.Source != None)
	HasResources = (self.ResourceCount > 0)
	
	;; proceed.

	Main.Util.PrintDebug("[EffectExtractResource.OnEffectStart] " + self.Source.GetDisplayName() + " Animate: " + (self.Animate As Int))

	If(IsValidMode && HasTarget && HasResources)
		Main.Util.PrintDebug("[EffectExtractResource.OnEffectStart] " + self.Source.GetDisplayName() + " Resource Count: " + self.ResourceCount)
		self.RegisterForSingleUpdate(0.25)
	Else
		Main.Util.PrintDebug("[EffectExtractResource.OnEffectStart] " + self.Source.GetDisplayName() + " Canceled")
		self.Dispel()
	EndIf

	Return
EndEvent

Event OnEffectFinish(Actor Who, Actor From)

	Main.Util.PrintDebug("[EffectExtractResource.OnEffectFinish] " + self.Source.GetDisplayName())
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

	;;Package Ani = self.GetAnimationPackage()
	self.Animation = self.GetAnimation()

	If(self.Animation == "")
		Main.Util.PrintDebug("[EffectExtractResource.StartExtractingAnimated] No animation found, falling back to static.")
		self.StartExtractingStatic()
		Return
	EndIf

	self.RegisterForModEvent(Main.Body.KeyEvActorSpawnGem,"OnAnimatedSpawnItem")
	self.RegisterForModEvent(Main.Body.KeyEvActorSpawnMilk,"OnAnimatedSpawnItem")
	self.RegisterForModEvent(Main.Body.KeyEvActorSpawnSemen,"OnAnimatedSpawnItem")
	self.RegisterForModEvent(Main.Body.KeyEvActorDone,"OnAnimatedDone")

	Main.Util.ActorArmourRemove(self.Source)
	Main.Body.ActorLockdown(self.Source)

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
	
	;; Check to prevent all resources being spawned near instantly
	If(self.ResourceCount > 0)
		self.DropResource(self.ExtractResource())
	EndIf
	;; if we are out of resources then kick the animation into its final
	;; stage so we can exit.

	If(self.ResourceCount <= 0)
		Main.Util.PrintDebug("[EffectExtractResource:OnAnimatedSpawnItem] " + self.Source.GetDisplayName() + " resources depleted.")
		;;Debug.SendAnimationEvent(self.Source,self.GetAnimationExit())
		self.OnAnimatedDone(Who)
	EndIf

	Return
EndEvent

Event OnAnimatedDone(Form Who)
{handle done event from animations.}

	If(Who != self.Source)
		Return
	EndIf

	;;Main.Body.ActorLockdown(self.Source)
	Main.Body.ActorRelease(self.Source)
	Main.Util.ActorArmourReplace(self.Source)
	StorageUtil.UnsetStringValue(self.Source,"SGO4.Package.AnimationEnd")
	Main.Util.PrintDebug("[EffectExtractResource:OnAnimatedSpawnItem] " + self.Source.GetDisplayName() + " done animating.")
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

Package Function GetAnimationPackage()
{determine which animation to use.}

	Package Output = NONE

	If(self.ResourceType == self.ResourceGem)
		Output = Main.ListPackageBirth.GetAt(0) As Package
	ElseIf(self.ResourceType == self.ResourceMilk)
		Output = Main.ListPackageMilking.GetAt(0) As Package
	ElseIf(self.ResourceType == self.ResourceSemen)
		Output = Main.ListPackageWanking.GetAt(0) As Package
	EndIf

	Return Output
EndFunction

String Function GetAnimation()
{determine which animation to use.}

	String Output = ""

	If(self.ResourceType == self.ResourceGem)
		Output = "dse-sgo-birth01-02"
	ElseIf(self.ResourceType == self.ResourceMilk)
		Output = "dse-sgo-milking01-02"
	ElseIf(self.ResourceType == self.ResourceSemen)
		Output = "dse-sgo-wanking01-02"
	EndIf

	Return Output
EndFunction

String Function GetAnimationExit()
{determine the animation to trigger the end of a package.}

	Return StorageUtil.GetStringValue(self.Source,"SGO4.Package.AnimationEnd","dse-sgo-try-to-unfuck")
EndFunction

Form Function ExtractResource()
{extract the resource from the source and credit them for the method.}

	Form Output = NONE

	If(self.ResourceCount <= 0)
		Return Output
	EndIf

	If(self.ResourceType == self.ResourceGem)
		If(Main.Config.GetBool(".GemLeveling"))
			StorageUtil.FloatListSort(self.Source,Main.Data.KeyActorGemData)
			If(StorageUtil.FloatListGet(self.Source,Main.Data.KeyActorGemData,0)<6)
				Main.Util.PrintDebug("The gems are not done yet.")
				Main.Util.Print("The gems refuse to budge.")
				self.ResourceCount = 0
				Return Output
			EndIf		
			
			Int GemsBirthed = Main.Stats.GetInt(self.Source,Main.Stats.KeyGemsBirthed)
			Float GemLevel = Math.floor((GemsBirthed/Main.Config.GetFloat(".GemLevelingThreshold"))+1)
			Float GemLevelCap = Main.Config.GetFloat(".GemLevelCap")
	
			If Gemlevel > GemLevelCap
				Gemlevel = GemLevelCap
			EndIf		
			
			Float GemLevelingStatsMult = Main.Config.GetFloat(".GemLevelingStatsMult")*Gemlevel
			
			Main.Data.ActorModSetValue(self.Source,Main.Data.KeyActorModGemsRateMult,".GemLevelingRatePenalty",Math.Pow(Main.Config.GetFloat(".GemLevelingRatePenalty"),GemLevel))			
			Main.Data.ActorModSetValue(self.Source,Main.Data.KeyActorModInfluenceGemsHealthMult,".GemLevelingHealthMult",GemLevelingStatsMult)
			Main.Data.ActorModSetValue(self.Source,Main.Data.KeyActorModInfluenceGemsMagickaMult,".GemLevelingMagickaMult",GemLevelingStatsMult)

		Else
			Output = Main.Data.GemStageGet(Math.Floor(Main.Data.ActorGemRemoveLargest(self.Source)))
			Main.Stats.IncInt(self.Source,Main.Stats.KeyGemsBirthed,1,TRUE)
			
			Main.Data.ActorModUnsetValue(self.Source,Main.Data.KeyActorModGemsRateMult,".GemLevelingRatePenalty")
			Main.Data.ActorModUnsetValue(self.Source,Main.Data.KeyActorModInfluenceGemsMagickaMult,".GemLevelingMagickaMult")
			Main.Data.ActorModUnsetValue(self.Source,Main.Data.KeyActorModInfluenceGemsHealthMult,".GemLevelingHealthMult")
			
			
		EndIf
	EndIf	

	If(self.ResourceType == self.ResourceMilk)
		Output = Main.Data.RaceGetMilk(self.RaceMap[0],self.RaceMap[1])
		Main.Data.ActorMilkLimit(self.Source)
		Main.Data.ActorMilkInc(self.Source,-1.0)
		Main.Stats.IncInt(self.Source,Main.Stats.KeyMilksMilked,1,TRUE)
		If(Main.Config.GetBool(".MilkLeveling"))
			Int MilkedCount = Main.Stats.GetInt(self.Source,Main.Stats.KeyMilksMilked)

			Float MilkLevelingCapacityMult = Main.Config.GetFloat(".MilkLevelingCapacityMult")*MilkedCount
			Float MilkLevelingCapacityMultCap = Main.Config.GetFloat(".MilkLevelingCapacityMultCap")
			
			Float MilkLevelingGainMult = Main.Config.GetFloat(".MilkLevelingGainMult")*MilkedCount
			Float MilkLevelingGainMultCap = Main.Config.GetFloat(".MilkLevelingGainMultCap")
			
			If MilkLevelingCapacityMult > MilkLevelingCapacityMultCap
				MilkLevelingCapacityMult = MilkLevelingCapacityMultCap
			EndIf
			
			If MilkLevelingGainMult > MilkLevelingGainMultCap
				MilkLevelingGainMult = MilkLevelingGainMultCap
			EndIf
			
			Main.Data.ActorModSetValue(self.Source,Main.Data.KeyActorModMilkMaxMult,".MilkLevelCapacityMult",MilkLevelingCapacityMult)
			Main.Data.ActorModSetValue(self.Source,Main.Data.KeyActorModMilkRateMult,".MilkLevelRateMult",MilkLevelingGainMult)
			Main.Data.ActorModSetValue(self.Source,Main.Data.KeyActorModInfluenceMilkSpeechMult,".MilkLevelSpeechMult",MilkLevelingCapacityMult)
			Main.Data.ActorModSetValue(self.Source,Main.Data.KeyActorModInfluenceMilkSpeechExposedMult,".MilkLevelSpeechExposedMult",MilkLevelingCapacityMult)			
		Else
			Main.Data.ActorModSetValue(self.Source,Main.Data.KeyActorModMilkMaxMult,".MilkLevelCapacityMult")
			Main.Data.ActorModSetValue(self.Source,Main.Data.KeyActorModMilkRateMult,".MilkLevelRateMult")
			Main.Data.ActorModSetValue(self.Source,Main.Data.KeyActorModInfluenceMilkSpeechMult,".MilkLevelSpeechMult")
			Main.Data.ActorModSetValue(self.Source,Main.Data.KeyActorModInfluenceMilkSpeechExposedMult,".MilkLevelSpeechExposedMult")	
		EndIf			
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

	ObjectReference Obj
	String NodeName
	Float[] Pos
	Float Distance

	If(ItemForm == NONE)
		Main.Util.PrintDebug("[EffectExtractResource.DropResource] " + self.Source.GetDisplayName() + " No Item Found")
		Return
	EndIf

	;; figure out where to drop it. if we're static then we want to position it
	;; in front of the cator. if we're animated we will drop it on the animated node.

	If(!self.Animate)
		NodeName = self.DropNodeStatic
		Distance = self.DropDistance	
	Else
		NodeName = self.DropNodeAnimated
		Distance = 0.0
	EndIf

	Pos = Main.Util.GetNodePositionAtDistance(self.Source,NodeName,Distance)
	Main.Util.PrintDebug("[EffectExtractResource.DropResource] " + self.Source.GetDisplayName() + " Node: " + NodeName + " " + Distance)

	;; drop it.

	Obj = self.Source.PlaceAtMe(ItemForm,1,FALSE,TRUE)
	Obj.SetPosition(Pos[1],Pos[2],Pos[3])
	Obj.Enable()

	;; let the player have it.

	Obj.SetActorOwner(Main.Player.GetActorBase())

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

		Main.Body.ActorAnimateSolo(self.Source,self.Animation)
		self.RegisterForSingleUpdate(5.0)
		Return
	EndEvent
EndState
