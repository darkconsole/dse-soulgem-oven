;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 1
Scriptname dse_sgo_PkgFragAnimateOnBegin Extends Package Hidden

String Property AnimationEnd = "dse-sgo-try-to-unfuck" Auto

;BEGIN FRAGMENT Fragment_0
Function Fragment_0(Actor akActor)
;BEGIN CODE
dse_sgo_QuestController_Main SGO = dse_sgo_QuestController_Main.Get() As dse_sgo_QuestController_Main
SGO.Util.PrintDebug("[PkgFragAnimateOnBegin] " + akActor.GetDisplayName() + " Ending: " + self.AnimationEnd)
StorageUtil.SetStringValue(akActor,"SGO4.Package.AnimationEnd",self.AnimationEnd)
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment
