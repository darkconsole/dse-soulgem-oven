ScriptName dse_sgo_QuestUtil_Main extends Quest

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

dse_sgo_QuestController_Main Property Main Auto

String Property FileStrings = "../../../configs/dse-soulgem-oven/translations/English.json" AutoReadOnly Hidden

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; mostly debugging

Function Print(String Msg)

	Debug.Notification("[SGO] " + Msg)
	Return
EndFunction

Function PrintDebug(String Msg)

	If(Main.Config.DebugMode)
		MiscUtil.PrintConsole("[SGO] " + Msg)
		Debug.Trace("[SGO] " + Msg)
	EndIf

	Return
EndFunction

Function PopupError(String Msg)
{display an error message that the user must address.}

	String Output = ""

	Output += "Soulgem Oven Error:\n"
	Output += Msg

	Debug.MessageBox(Output)
	Return
EndFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; mostly game data related.

Form Function GetForm(Int FormID)
{get a specific form from the soulgem oven esp.}

	Return Game.GetFormFromFile(FormID,Main.KeyESP)
EndFunction

Form Function GetFormFrom(String ModName, Int FormID)
{gets a form from a specific mod.}

	If(!Game.IsPluginInstalled(ModName))
		Return NONE
	EndIf

	Return Game.GetFormFromFile(FormID,ModName)
EndFunction

Form Function GetMarkerForm()

	Return self.GetFormFrom("Skyrim.esm",0x3B)
EndFunction

Function SortByDisplayName(Actor[] ItemList)
{sort a list of actors by their name.}

	Actor TmpForm
	Int Iter
	Bool Changed = TRUE

	While(Changed)
		Iter = 0
		Changed = FALSE

		While(Iter < (ItemList.Length - 1))

			If(ItemList[Iter].GetDisplayName() > ItemList[(Iter+1)].GetDisplayName())
				TmpForm = ItemList[Iter]
				ItemList[Iter] = ItemList[(Iter+1)]
				ItemList[(Iter+1)] = TmpForm
				Changed = TRUE
			EndIf

			Iter += 1
		EndWhile
	EndWhile

	Return
EndFunction

Bool Function LeveledListHas(LeveledItem List, Form SomeShit)
{because nobody thought a HasForm for LeveledItem was worth adding appartently.}

	Int Len = List.GetNumForms()

	While(Len > 0)
		Len -= 1

		If(List.GetNthForm(Len) == SomeShit)
			Return TRUE
		EndIf
	EndWhile

	Return FALSE
EndFunction

Actor[] Function FindNearbyActors(Float Delay=0.75)
{runs an aoe spell, waits, and returns the results.}

	;; MiscUtil.ScanCellNPCs
	;; the problem with that function from PapyrusUtil is that it does
	;; exactly what it says to the letter. it finds all the actors that
	;; are in the current cell. and -only- in that current cell. you can
	;; be standing on the border of two cells and it wont find someone who
	;; is literally 3ft away from you because they are on the other side
	;; of the cell boundary. like the city of solitude how it is split in
	;; half by the archway, that is also a cell boundary and it wont find
	;; actors on the other side of that arch. outdoors people will likely
	;; run into this a *lot* so we are going to not use it.

	Main.SpellFindActors.Cast(Main.Player,Main.Player)
	Utility.Wait(Delay)

	Return self.GetFindActorList()
EndFunction

Actor[] Function GetFindActorList()
{fetch the data that was populated by the find actors spell.}

	Form[] Dataset = StorageUtil.FormListToArray(NONE,Main.Data.KeyFindActorList)
	Actor[] Output = PapyrusUtil.ActorArray(Dataset.Length)
	Int Iter = 0

	While(Iter < Output.Length)
		Output[Iter] = Dataset[Iter] AS Actor
		Iter += 1
	EndWhile

	Return Output
EndFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; maths

Int Function RoundToInt(Float Val)
{round a float to an integer.}

	Return Math.Floor(Val + 0.5)
EndFunction

Float Function RoundTo(Float Val, Int Dec=0)
{round a float to a specified number of decimal places.}

	Float Bump = Math.Pow(10,Dec) As Float

	Return (Math.Floor((Val * Bump) + 0.5) As Float) / Bump
EndFunction

Float Function FloorTo(Float Val, Int Dec=0)
{floor a float to a specified number of decimal places.}

	Float Bump = Math.Pow(10,Dec) As Float

	Return (Math.Floor(Val * Bump) As Float) / Bump
EndFunction

String Function FloatToString(Float Val, Int Dec=0)
{"convert" a float into a string - e.g. get a printable float
that cuts off all the ending zeroes the game adds when casting
a float into a string directly.}

	Int Last = Math.Floor(Val)
	String Output = Last As String

	If(Dec > 0 && Val != Last)
		Output += "."

		While(Dec > 0)
			Val = (Val - Last) * 10
			Last = Math.Floor(Val)
			Output += Last As String

			Dec -= 1
		EndWhile
	EndIf

	Return Output
EndFunction

String[] Function FloatsToStrings(Float[] Vals, Int Dec=0)
{convert a list of floats into strings using FloatToString.}

	String[] Output = Utility.CreateStringArray(Vals.Length)
	Int Iter = Vals.Length

	While(Iter > 0)
		Iter -= 1
		Output[Iter] = self.FloatToString(Vals[Iter],Dec)
	EndWhile

	Return Output
EndFunction

String Function DecToHex(Int Number)

	String Output = ""
	String[] HexChar = new String[16]
	Int HexKey = 0

	If(Number == 0)
		Output = "0"
	Else
		HexChar[0] = "0"
		HexChar[1] = "1"
		HexChar[2] = "2"
		HexChar[3] = "3"
		HexChar[4] = "4"
		HexChar[5] = "5"
		HexChar[6] = "6"
		HexChar[7] = "7"
		HexChar[8] = "8"
		HexChar[9] = "9"
		HexChar[10] = "A"
		HexChar[11] = "B"
		HexChar[12] = "C"
		HexChar[13] = "D"
		HexChar[14] = "E"
		HexChar[15] = "F"

		While(Number != 0)
			HexKey = Math.LogicalAnd(Number,0xF)
			Number = Math.RightShift(Number,4)
			Output = HexChar[HexKey] + Output
		EndWhile
	EndIf

	Return Output
EndFunction

Float Function GetLeveledValue(Float Level, Float Value, Float Factor = 1.0)
{modify a value based on a level 100 system. this means at level 100 the input
value will be doubled.}

	;; input 1 at level 0
	;; ((0 / 100) * 1) + 1 = 1

	;; input 1 at level 1
	;; ((1 / 100) * 1) + 1 = 1.01

	;; input 1 at level 50
	;; ((50 / 100) * 1) + 1 = 1.5

	;; input 1 at level 100
	;; ((100 / 100) * 1) + 1 = 2.0

	Float Base = Main.Config.GetFloat(".LevelValueBase")

	Return (((Level / Base) * (Value * Factor)) + Value) as Float
EndFunction

Float[] Function GetNodePositionData(ObjectReference What, String Node)
{get an object's positional data.}

	Float[] Output = new Float[4]
	Float[] NodeMat = new Float[9]
	Float[] NodePos = new Float[3]
	Float[] NodeRot = new Float[2]

	;; get me the node position.

	NetImmerse.GetNodeWorldPosition(What,Node,NodePos,FALSE)

	;; get me the node rotation.
	;; GetNodeWorldRotationEuler currently is bugged in SKSE and is returning the
	;; local values instead of world values. if they fix that we can get rid of this
	;; matrix stupidness.

	NetImmerse.GetNodeWorldRotationMatrix(What,Node,NodeMat,FALSE)
	NodeRot = MatrixToEuler(NodeMat)

	;;;;;;;;

	Main.Util.PrintDebug("[GetNodePositionData] " + What.GetDisplayName() + " " + What.GetAngleZ() + " " + Node + " " + NodeRot[0] + "," + NodeRot[1] + "," + NodeRot[2])

	Output[0] = NodeRot[2]
	Output[1] = NodePos[0]
	Output[2] = NodePos[1]
	Output[3] = NodePos[2]

	Return Output
EndFunction

Float[] Function GetNodePositionAtDistance(ObjectReference What, String Node, Float Dist)
{get an objects positional data if it was to be pushed away the specified
distance from itself.}

	Float[] Data = self.GetNodePositionData(What,Node)

	Data[1] = Data[1] + (Math.Sin(Data[0]) * Dist)
	Data[2] = Data[2] + (Math.Cos(Data[0]) * Dist)

	Return Data
EndFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; strings

String Function StringInsert(String Format, String InputList="")
{a cheeky af implementation of like an sprintf type thing but not.}

	Int Iter = 0
	Int Pos = -1
	String ToFind
	String[] Inputs

	;; short short circuit if we can.

	If(StringUtil.GetLength(InputList) == 0)
		Return Format
	EndIf

	;; rebuild a full string.

	Inputs = PapyrusUtil.StringSplit(InputList,"|")

	While(Iter < Inputs.Length)
		ToFind = "%" + (Iter+1)
		Pos = StringUtil.Find(Format,ToFind)

		;; substring with a length of 0 means full string so we had to test
		;; the position in case the token was the first thing in the string.

		If(Pos > -1)
			If(Pos > 0)
				Format = StringUtil.Substring(Format,0,Pos) + Inputs[Iter] + StringUtil.Substring(Format,(Pos+2))
			Else
				Format = Inputs[Iter] + StringUtil.Substring(Format,(Pos+2))
			EndIf
		EndIf

		Iter += 1
	EndWhile

	Return Format
EndFunction

String Function StringLookup(String Path, String InputList="")
{get a string from the translation file and run it through StringInsert.}

	String Format = JsonUtil.GetPathStringValue(self.FileStrings,Path,("MISSING STRING LOL: " + Path))

	Return self.StringInsert(Format,InputList)
EndFunction

String Function StringLookupRandom(String Path, String InputList="")
{get a random string from the translation file and run it through StringInsert.}

	Int Count = JsonUtil.PathCount(self.FileStrings,Path)
	Int Selected = Utility.RandomInt(0,(Count - 1))
	String Format = JsonUtil.GetPathStringValue(self.FileStrings,(Path + "[" + Selected + "]"))

	Return self.StringInsert(Format,InputList)
EndFunction

Function PrintLookup(String KeyName, String InputList="")
{print a notification string from the translation file.}

	self.Print(self.StringLookup(KeyName,InputList))
EndFunction

Function PrintLookupRandom(String KeyName, String InputList="")
{print a random string from the translation file.}

	self.Print(self.StringLookupRandom(KeyName,InputList))
EndFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; game utility

Function ActorArmourRemove(Actor Who)
{remove an actor's chestpiece.}

	Form[] Items
	Int StripMode = Main.Config.GetInt(".ActorStripMode")

	If(StripMode == Main.Config.StripModeNone)
		Return
	EndIf

	If(StripMode == Main.Config.StripModeSexLabNormal)
		Items = Main.SexLab.StripActor(Who,None,FALSE,FALSE)
		Main.Util.PrintDebug("Stripping " + Who.GetDisplayName() + " via SexLab Normal (" + Items.Length + ")")
	ElseIf(StripMode == Main.Config.StripModeSexLabForeplay)
		Items = Main.SexLab.StripActor(Who,None,FALSE,TRUE)
		Main.Util.PrintDebug("Stripping " + Who.GetDisplayName() + " via SexLab Foreplay (" + Items.Length + ")")
	ElseIf(StripMode == Main.Config.StripModeBodyOnly)
		Main.Util.PrintDebug("Stripping " + Who.GetDisplayName() + " manually")
		If(Who.GetWornForm(0x00000004) != None)
			Items = new Form[1]
			Items[0] = Who.GetWornForm(0x00000004)
			Who.UnequipItemSlot(32)
			Who.QueueNiNodeUpdate()
		EndIf
	EndIf

	If(Items.Length > 0)
		StorageUtil.FormListCopy(Who,"SGO4.Actor.Armor",Items)
	EndIf

	Return
EndFunction

Function ActorArmourReplace(Actor Who)
{replace an actor's chestpiece.}

	Form[] Items
	Int StripMode = Main.Config.GetInt(".ActorStripMode")

	If(StorageUtil.FormListCount(Who,"SGO4.Actor.Armor") > 0)
		Items = StorageUtil.FormListToArray(Who,"SGO4.Actor.Armor")
	EndIf

	If(Items.Length > 0)
		Main.SexLab.UnstripActor(Who,Items,FALSE)
	EndIf

	StorageUtil.FormListClear(Who,"SGO4.Actor.Armor")
	Return
EndFunction

Function ActorLevelAlchemy(Actor Who, Float ItemValue=1.0)
{progress the alchemy skill for the specified actor. for most things we will
leave ItemValue at the default of 1.0.}

	Float Factor
	Float Level
	Float Value
	Float MilksPerDay

	If(Who != Main.Player)
		;; not possible to level npcs at this time.
		Return
	EndIf

	Factor = Main.Config.GetFloat(".LevelAlchFactor")
	MilksPerday = Main.Config.GetFloat(".MilksPerDay")

	If(Factor == 0.0)
		;; do not process when disabled.
		Return
	EndIf

	;; http://www.uesp.net/wiki/Skyrim:Leveling#Skill_XP

	;; xp/btl gained at x btl/day at level 0.
	;; double this at level 100 with 1.0 progress factor.
	;; 1 = 100xp
	;; 2 = 50xp
	;; 3 = 33xp (default)

	Level = Who.GetLevel()
	Value = (100 / MilksPerDay) * ItemValue

	Main.Util.PrintDebug("[ActorLevelAlchemy] Level: " + Level + ", Factor: " + Factor + ", MilksPerDay: " + MilksPerDay)
	Main.Util.PrintDebug("[ActorLevelAlchemy] Value: " + Value + ", Leveled: " + self.GetLeveledValue(Level,Value,Factor))

	Game.AdvanceSkill("Alchemy",self.GetLeveledValue(Level,Value,Factor))
	Return
EndFunction

Function ActorLevelEnchanting(Actor Who, Float ItemValue=-1.0)
{progress the enchanting skill for the specified actor. item value will default
to an item value equal to the gem stages as we are using this for gem birthing
mostly.}

	Float Factor
	Float Level
	Float Value
	Float Base

	If(Who != Main.Player)
		;; not possible to level npcs at this time.
		Return
	EndIf

	Factor = Main.Config.GetFloat(".LevelEnchFactor")

	If(Factor == 0.0)
		;; do not process when disabled.
		Return
	EndIf

	;; http://www.uesp.net/wiki/Skyrim:Leveling#Skill_XP
	;; normal enchanting works as 1xp per item enchanted and it seems enchanting levels fast
	;; so we will use small numbers here.

	Base = Main.Data.GemStageCount(Who)
	Level = Who.GetLevel()

	If(ItemValue == -1.0)
		ItemValue = Base
	EndIf

	Value = ((ItemValue / Base) / 2.0)

	;; if enchanting levels too slow manipulate the /2.0 smaller.
	;; if too fast, manipulate the /2.0 larger.
	;; once this calc feels good to me at default, users can tweak it via the factor.

	Game.AdvanceSkill("Enchanting",self.GetLeveledValue(Level,Value,Factor))
	Return
EndFunction

Int Function ActorGetGender(Actor Who)
{return 0 for male, 1 for female, 2 for ftm, 3 for mtf. if you mod the value
of this by 2 it will narrow the results to 0 or 1, which you can typically
trust as "this actor flat out wishes to be treated as" male or female if you
just need a snap judgement.}

	Int GameSays = Who.GetLeveledActorBase().GetSex()
	Int SexLabSays = Main.SexLab.GetGender(Who) % 2

	;; if sexlab and the game agree then we will just take what it says
	;; at face value.

	If(GameSays == SexLabSays)
		Return SexLabSays
	EndIf

	;; else the code asking the question will need to make some decisions
	;; about what to do next.

	If(GameSays == 1 && SexLabSays == 0)
		Return 2 ;; ftm
	EndIf

	If(GameSays == 0 && SexLabSays == 1)
		Return 3 ;; mtf
	EndIf

	Return 0
EndFunction

Bool Function ActorHasPackageOverrides(Actor Who)
{return if there are any package overrides on this actor and the current
package is not one of ours. designed for detecting if other mods like
display model are currently forcing the actor to do more important thigngs.}

	Package Pkg = StorageUtil.GetFormValue(Who,"SGO4.Actor.Lockdown") as Package

	If(ActorUtil.CountPackageOverride(Who) > 0)
		If(Pkg != None)
			Return (Who.GetCurrentPackage() != Pkg)
		Else
			Return (Who.GetCurrentPackage() != Main.PackageDoNothing)
		EndIf
	EndIf

	Return FALSE
EndFunction

Function ActorToggleFaction(Actor Who, Faction What)
{add the actor to a faction if not in it, remove them from it if they are.}

	If(Who.IsInFaction(What))
		Who.RemoveFromFaction(What)
	Else
		Who.AddToFaction(What)
	EndIf

	Main.Data.ActorTrackingAdd(Who)
	Return
EndFunction

Bool Function ActorIsValid(Actor Who)
{check if the actor is valid for use.}

	Int SexLabSays

	If(Main.OptValidateActor)
		SexLabSays = Main.SexLab.ValidateActor(Who)

		If(SexLabSays < 0)
			self.PrintDebug(Who.GetDisplayName() + " did not pass sexlab's test: " + SexLabSays)
			Return FALSE
		EndIf
	EndIf

	Return TRUE
EndFunction

String Function GetBirthingAnimationName(Int Offset)
{0 = random, 1 and higher specific animation.}

	String[] AniList = new String[1]
	AniList[0] = Main.Body.AniBirth01
	Offset = PapyrusUtil.ClampInt(Offset,0,AniList.Length) - 1

	If(Offset == -1)
		Offset = Utility.RandomInt(0,(AniList.Length - 1))
	EndIf

	Return AniList[Offset]
EndFunction

String Function GetInsertingAnimationName(Int Offset)
{0 = random, 1 and higher specific animation.}

	String[] AniList = new String[2]
	AniList[0] = Main.Body.AniInsert01
	AniList[1] = Main.Body.AniInsert02
	Offset = PapyrusUtil.ClampInt(Offset,0,AniList.Length) - 1

	If(Offset == -1)
		Offset = Utility.RandomInt(0,(AniList.Length - 1))
	EndIf

	Return AniList[Offset]
EndFunction

String Function GetMilkingAnimationName(Int Offset)
{0 = random, 1 and higher specific animation.}

	String[] AniList = new String[1]
	AniList[0] = Main.Body.AniMilking01
	Offset = PapyrusUtil.ClampInt(Offset,0,AniList.Length) - 1

	If(Offset == -1)
		Offset = Utility.RandomInt(0,(AniList.Length - 1))
	EndIf

	Return AniList[Offset]
EndFunction

String Function GetWankingAnimationName(Int Offset)
{0 = random, 1 and higher specific animation.}

	String[] AniList = new String[1]
	AniList[0] = Main.Body.AniWanking01
	Offset = PapyrusUtil.ClampInt(Offset,0,AniList.Length) - 1

	If(Offset == -1)
		Offset = Utility.RandomInt(0,(AniList.Length - 1))
	EndIf

	Return AniList[Offset]
EndFunction

String Function ActorOverlayGetSlot(Actor Who, String OverlayName, Bool OursOnly=FALSE)
{find the next available overlay slot, or the slot we were already using.}

	String NodeName

	;; prefix the overlay name.

	OverlayName = "SGO4.Actor.Overlay." + OverlayName

	;; see if we already selected a node.

	NodeName = StorageUtil.GetStringValue(Who,OverlayName)
	If(NodeName != "" || OursOnly)
		Return NodeName
	EndIf

	;; alright lets find an empty slot and gank it.

	Int NodeCount = NiOverride.GetNumBodyOverlays()
	Int NodeIter = 0
	Bool NodeSex = (Who.GetLeveledActorBase().GetSex() == 1)
	String NodeTexture

	While(NodeIter < NodeCount)
		NodeName = "Body [Ovl" + NodeIter + "]"
		NodeTexture = NiOverride.GetNodeOverrideString(Who,NodeSex,NodeName,9,0)

		If(NodeTexture == "" || NodeTexture == "textures\\Actors\\character\\overlays\\default.dds")
			;; mine now.
			StorageUtil.SetStringValue(Who,OverlayName,NodeName)
			Return NodeName
		EndIf

		NodeIter += 1
	EndWhile

	Return ""
EndFunction

Function ActorOverlayApply(Actor Who, String OverlayName, String Texture, Int Colour, Float Opacity)
{apply an overlay to an actor.}

	String NodeName = self.ActorOverlayGetSlot(Who,OverlayName,FALSE)
	Bool NodeSex = (Who.GetLeveledActorBase().GetSex() == 1)

	If(NodeName == "")
		;; we were unable to find a slot, or slots were disabled.
		Return
	EndIf

	;; setting the texture.
	NiOverride.AddNodeOverrideString(Who,NodeSex,NodeName,9, 0,Texture,TRUE)
	NiOverride.AddNodeOverrideFloat( Who,NodeSex,NodeName,8,-1,Opacity,TRUE)
	NiOverride.AddNodeOverrideInt(   Who,NodeSex,NodeName,7,-1,Colour, TRUE)
	;; NiOverride.AddNodeOverrideInt(Who,NodeSex,NodeName,0,-1,0,TRUE)
	;; NiOverride.AddNodeOverrideFloat(Who,NodeSex,NodeName,0,-1,1.0,TRUE)
	NiOverride.ApplyNodeOverrides(Who)


	Return
EndFunction

Function ActorOverlayClear(Actor Who, String OverlayName)
{remove our overlay and free the slot up.}

	String NodeName = self.ActorOverlayGetSlot(Who,OverlayName,TRUE)
	Bool NodeSex = (Who.GetLeveledActorBase().GetSex() == 1)

	If(NodeName == "")
		;; we were unable to find a slot we set.
		Return
	EndIF

	;;NiOverride.RemoveNodeOverride(Who,NodeSex,NodeName,9,0)
	;;NiOverride.RemoveNodeOverride(Who,NodeSex,NodeName,8,-1)
	;;NiOverride.RemoveNodeOverride(Who,NodeSex,NodeName,7,-1)
	NiOverride.RemoveAllNodeNameOverrides(Who,NodeSex,NodeName)
	NiOverride.AddNodeOverrideString(Who,NodeSex,NodeName,9,0,"textures\\Actors\\character\\overlays\\default.dds",TRUE)
	StorageUtil.UnsetStringValue(Who,("SGO4.Actor.Overlay." + OverlayName))
	NiOverride.ApplyNodeOverrides(Who)

	Return
EndFunction

Function ActorCleanAll(Bool Force=FALSE)
{loop through all tracked actors and remove all the data we've made for them.}

	Int ActorCount = 0
	Int ActorIter = 0
	Int ActorDone = 0
	Actor Who = NONE

	;; first consider if it is currently background processing actors.
	;; its best to let that finish first.

	If(!Main.Loop.WaitForUnlock() && !Force)
		Debug.MessageBox("SGO4: The background loop is somehow still busy, this attempt to clean had to bail.")
		Return
	EndIf

	ActorCount = Main.Data.ActorTrackingCount()

	While(ActorIter < ActorCount)
		Who = Main.Data.ActorTrackingGet(ActorIter)

		If(Who != NONE)
			self.PrintDebug("Cleanup " + Who.GetDisplayName())
			self.ActorClean(Who)
			ActorDone += 1
		EndIf

		ActorIter += 1
	EndWhile

	Main.Data.ActorTrackingCull()
	Debug.MessageBox("SGO4: All mod data has been purged from NPCs.")
	self.PrintDebug("Total Cleanup: " + ActorDone + " NPCs")
	Return
EndFunction

Function ActorClean(Actor Who)
{remove the data for a specific actor.}

	;; pull them out of the tracking system.

	Main.Data.ActorTrackingRemove(Who)

	;; tell storage util to flush all the things.

	StorageUtil.ClearAllObjPrefix(Who,"SGO4.")

	;; remove from our factions

	Who.RemoveFromFaction(Main.FactionProduceGems)
	Who.RemoveFromFaction(Main.FactionProduceMilk)
	Who.RemoveFromFaction(Main.FactionProduceSemen)

	;; tell nio to reset their bodies.

	Main.Body.ActorSlidersClear(Who,Main.Body.KeySlidersGems)
	Main.Body.ActorSlidersClear(Who,Main.Body.KeySlidersMilk)

	Return
EndFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; THIRD PARTY CODE. HOPEFULLY TEMPORARY.

Float[] Function MatrixToEuler(Float[] afMatrix) Global
{Converts a rotation matrix to Euler angles. Tailored for Skyrim (extrinsic left-handed ZYX Euler).}

	;; From DavidJCobb's Rotation Library
	;; https://www.creationkit.com/index.php?title=User:DavidJCobb/Rotation_Library

   ;
   ; Source for the math: https://web.archive.org/web/20051124013711/http://skal.planet-d.net/demo/matrixfaq.htm#Q37
   ;
   ; The math there is righthanded, but it's easy to tailor it to
   ; lefthanded if you have a handy-dandy reference like the one
   ; at <http://www.vectoralgebra.info/eulermatrix.html>.
   ;
   Float[] fEuler = new Float[3]
   ;
   ; We can immediately solve for Y, but we must round it to account
   ; for imprecision that is sometimes introduced when we have
   ; converted through other forms (e.g. axis-angle). fCYTest exists
   ; solely as part of that accounting.
   ;
   Float fY = Math.asin( (((-afMatrix[2] * 1000000) as int) as float) / 1000000 )
   Float fCY = Math.cos(fY)
   Float fCYTest = (((fCY * 100) as int) as float) / 100
   Float fTX
   Float fTY
   If fCY && fCY >= 0.00000011920929 && fCYTest
      ;Debug.Trace("MatrixToEuler: Y == " + fY + "; cos(Y) == " + fCY)
      fTX = afMatrix[8] / fCY
      fTY = afMatrix[5] / fCY
      fEuler[0] = atan2(fTY, fTX)   ; = atan(sinXcosY / cosXcosY) = atan(sin X / cos X)
      fTX = afMatrix[0] / fCY
      fTY = afMatrix[1] / fCY
      fEuler[2] = atan2(fTY, fTX)   ; = atan(cosYcosZ / cosYsinZ) = atan(sin Z / cos Z)
   Else
      ;Debug.Trace("MatrixToEuler: cos(Y) == 0. Taking another path...")
      ;
      ; We can't compute X and Z by using Y, because cos(Y) is zero. Therefore,
      ; we have to compromise.
      ;
      ; We'll assume X to be zero, and dump the rest into Z.
      ;
      fEuler[0] = 0
      fTX = afMatrix[4]             ; Setting X to zero simplifies this element to: 0*sinY*sinZ + 1*cosZ
      fTY = afMatrix[3]             ; Setting X to zero simplifies this element to: 0*sinY*cosZ - 1*sinZ
      ;
      ; NOTE: Negating the result APPEARS to be necessary to account for our use of a
      ; left-handed system versus the source's use of a right-handed system. However,
      ; I arrived at that conclusion deductively, and I am not 100% certain of it.
      ;
      fEuler[2] = -atan2(fTY, fTX)   ; = atan(sin Z / cos Z)
   EndIf
   fEuler[1] = fY
   Return fEuler
EndFunction

Float Function atan2(float y, float x) Global

	;; From DavidJCobb's Rotation Library
	;; https://www.creationkit.com/index.php?title=User:DavidJCobb/Rotation_Library

	Float out = 0
	If y != 0
		out = Math.sqrt(x * x + y * y) - x
		out /= y
		out = Math.atan(out) * 2
	Else
		If x == 0
			return 0
		EndIf

		out = Math.atan(y / x)
		If x < 0
			out += 180
		EndIf
	EndIf

	return out
EndFunction


