ScriptName dse_sgo_QuestController_Main extends Quest

;/*;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

              _________            .__                          
             /   _____/ ____  __ __|  |    ____   ____   _____  
             \_____  \ /  _ \|  |  \  |   / ___\_/ __ \ /     \ 
             /        (  <_> )  |  /  |__/ /_/  >  ___/|  Y Y  \
            /_______  /\____/|____/|____/\___  / \___  >__|_|  /
                    \/                  /_____/      \/      \/ 
                 ________                          _____        
                 \_____  \___  __ ____   ____     /  |  |       
                  /   |   \  \/ // __ \ /    \   /   |  |_      
                 /    |    \   /\  ___/|   |  \ /    ^   /      
                 \_______  /\_/  \___  >___|  / \____   |       
                         \/          \/     \/       |__|       

                          SPECIAL EDITION EDITION

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;*/;

;; >
;; THERE ARE ONLY 6 SOULGEM
;; MODELS.

Int Function GetVersion() Global
{report a version number.}

	Return 400
EndFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; local mod libraries.

dse_sgo_QuestConfig_Main Property Config Auto
dse_sgo_QuestDatabase_Main Property Data Auto
dse_sgo_QuestUpdateLoop_Main Property Loop Auto
dse_sgo_QuestUtil_Main Property Util Auto
dse_sgo_QuestBody_Main Property Body Auto
dse_sgo_QuestStats_Main Property Stats Auto

;; ui api

dse_sgo_QuestGemBar_Main Property GemBar Auto

;; third party libraries.

SexLabFramework Property SexLab Auto Hidden

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Actor Property Player Auto

Container Property ContainInsertGems Auto
FormList Property ListGemFilter Auto
Faction Property FactionProduceGems Auto
Faction Property FactionProduceMilk Auto
Faction Property FactionProduceSemen Auto
Spell Property SpellBirthLargest Auto
Spell Property SpellInsertGems Auto
Spell Property SpellMilkingAction Auto
Package Property PackageDoNothing Auto

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

String Property KeyESP = "dse-soulgem-oven.esp" AutoReadOnly Hidden
String Property KeySplashGraphic = "dse-soulgem-oven/splash.dds" AutoReadOnly Hidden

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Event OnInit()
{handle install/reset.}

	Int Wait = 0

	If(self.IsStopped())
		Return
	EndIf

	If(!self.CheckForDeps())
		self.Reset()
		self.Stop()
		Return
	EndIf

	;;;;;;;;

	self.ResetConfig()

	Wait = 0
	While(!Config.IsRunning() && Wait < 10)
		Wait += 1
		self.Util.PrintDebug("Waiting for dse_sgo_QuestConfig to start (" + Wait + ")...")
		Utility.Wait(1.0)
	EndWhile

	If(!self.Config.IsRunning())
		self.Util.PrintDebug("Startup Aborted: Config did not reset.")
		Return
	EndIf

	;;;;;;;;

	self.ResetLoop()

	Wait = 0
	While(!Loop.IsRunning() && Wait < 10)
		Wait += 1
		self.Util.PrintDebug("Waiting for dse_sgo_QuestUpdateLoop to start (" + Wait + ")...")
		Utility.Wait(1.0)
	EndWhile

	if(!self.Loop.IsRunning())
		self.Util.PrintDebug("Startup Aborted: Loop did not reset.")
		Return
	EndIf

	;;;;;;;;

	;; not for real things just hack testing.

	SexLab = Util.GetFormFrom("SexLab.esm",0xd62) As SexLabFramework
	self.Data.ActorTrackingAdd(self.Player)
	
	;;;;;;;;

	self.UnregisterForModEvent("SexLabOrgasm")
	self.RegisterForModEvent("SexLabOrgasm","OnModEvent_SexLabOrgasm")

	self.Util.Print("Soulgem Oven 4 has started.")
	Return
EndEvent

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Function ResetConfig()

	self.Config.Reset()
	self.Config.Stop()
	self.Config.Start()
	Return
EndFunction

Function ResetLoop()

	self.Loop.Reset()
	self.Loop.Stop()
	self.Loop.Start()
EndFunction

Function ResetMod()

	self.Reset()
	self.Stop()
	self.Start()
	Return
EndFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Bool Function CheckForDeps()
{make sure we have everything we need installed.}

	Bool Output = TRUE

	;; todo

	Return Output
EndFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Function OnModEvent_SexLabOrgasm(Form Whom, Int Enjoy, Int OCount)

	Actor Who = Whom as Actor
	Actor Oven
	sslThreadController Thread
	sslBaseAnimation Animation
	Actor[] ActorList
	Int ActorIter
	Float PregRoll = 0.0
	Float PregChance = Config.GetFloat("FertilityChance")

	;;;;;;;;

	;; grab info from sexlab.

	Thread = SexLab.GetActorController(Who)

	If(Thread == None)
		Util.PrintDebug("Failed to get SexLab thread controller.")
	EndIf

	Animation = Thread.Animation
	ActorList = Thread.Positions

	;;;;;;;;

	;; prime the actor biological abilities.

	ActorIter = 0

	While(ActorIter < ActorList.Length)
		Data.ActorDetermineFeatures(ActorList[ActorIter])
		ActorIter += 1
	EndWhile

	;;;;;;;;

	;; determine what to do.

	If(!Who.IsInFaction(FactionProduceSemen))
		;; bail if the cummer is not producing semen.
		Util.PrintDebug("Preg Abort: " + Who.GetDisplayName() + " is not a semen producer.")
		Return
	EndIf

	If(ActorList.Length == 1)
		;; bail if it was a solo mission.
		;; todo - drop semen bottle.
		Util.PrintDebug("Preg Abort: " + Who.GetDisplayName() + " is fapping.")
		Return
	EndIf

	If(!Animation.IsVaginal && !Animation.IsAnal)
		;; bail if it was not an insertion animation.
		Util.PrintDebug("Preg Abort: Animation was not an insertion.")
		Return
	EndIf

	;; pick someone to greginate

	Oven = None
	ActorIter = 0

	While(ActorIter < ActorList.Length)
		If(ActorList[ActorIter] != Who && ActorList[ActorIter].IsInFaction(FactionProduceGems))
			Oven = ActorList[ActorIter]
			ActorIter = ActorList.Length
		EndIf
		ActorIter += 1
	EndWhile

	If(Oven == None)
		;; bail because no ovens were found.
		Util.PrintDebug("Preg Abort: No valid ovens found.")
		Return
	EndIf

	;;;;;;;;

	PregRoll = Utility.RandomFloat(0.0,100.0) * Data.ActorFertilityFactor(Oven)
	Util.PrintDebug("Preg Chance For " + Oven.GetDisplayName() + " If(" + PregRoll + " >= " + PregChance + "%)")

	If(PregRoll >= (100.0 - PregChance))
		If(Data.ActorGemAdd(Oven,0.0))
			If(Oven == self.Player)
				Util.PrintLookupRandom("FlavourPlayerGemGain",Oven.GetDisplayName())
			Else
				Util.PrintLookupRandom("FlavourActorGemGain",Oven.GetDisplayName())
			EndIf
			Util.PrintDebug(Oven.GetDisplayName() + " is now incubating another gem.")
		Else
			Util.PrintLookup("CannotFitMoreGems",Oven.GetDisplayName())
			Util.PrintDebug(Oven.GetDisplayName() + " cannot fit any more gems.")
		EndIf
	EndIf

	;;;;;;;;

	Return
EndFunction
