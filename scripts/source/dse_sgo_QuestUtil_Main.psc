ScriptName dse_sgo_QuestUtil_Main extends Quest

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

dse_sgo_QuestController_Main Property Main Auto

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
	EndIf

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

	If(Game.GetModByName(ModName) == 255)
		Return NONE
	EndIf

	Return Game.GetFormFromFile(FormID,ModName)
EndFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; maths

Int Function RoundToInt(Float Val)
{round a float to an integer.}

	Return Math.Floor(Val + 0.5)
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

	Float Base = Main.Config.GetFloat("LevelValueBase")

	Return (((Level / Base) * (Value * Factor)) + Value) as Float
EndFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; game utility

Function ActorArmourRemove(Actor Who)
{remove an actor's chestpiece.}

	Form[] Items

	If(Main.Config.GetBool("SexLabStrip"))
		Items = Main.SexLab.StripActor(Who,None,FALSE,FALSE) as Form[]
		Main.Util.PrintDebug("Stripping " + Who.GetDisplayName() + " via SexLab (" + Items.Length + ")")
	Else
		Main.Util.PrintDebug("Stripping " + Who.GetDisplayName() + " manually.")
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

	If(StorageUtil.FormListCount(Who,"SGO4.Actor.Armor") > 0)
		Items = StorageUtil.FormListToArray(Who,"SGO4.Actor.Armor") as Form[]
	EndIf

	;;If(Main.Config.GetBool("SexLabStrip"))
	If(Items.Length > 0)
		Main.SexLab.UnstripActor(Who,Items,FALSE)
	EndIf
	;;Else
	;;	If(StorageUtil.GetFormValue(Who,"SGO.Actor.Armor.Chest"))
	;;		Who.EquipItem(Storageutil.GetFormValue(Who,"SGO.Actor.Armor.Chest"),FALSE,TRUE)
	;;		StorageUtil.SetFormValue(who,"SGO.Actor.Armor.Chest",None)
	;;	EndIf
	;;EndIf

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

	Factor = Main.Config.GetFloat("LevelAlchFactor")
	MilksPerday = Main.Config.GetFloat("MilksPerDay")

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

	;; if its progressing retarded fast, manipulate the 24 to be smaller.
	;; if too slow manipulate the 24 larger.
	;; once this calc feels good to me at default, users can tweak it via the factor.

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

	Factor = Main.Config.GetFloat("LevelEnchFactor")

	If(Factor == 0.0)
		;; do not process when disabled.
		Return
	EndIf

	;; http://www.uesp.net/wiki/Skyrim:Leveling#Skill_XP
	;; normal enchanting works as 1xp per item enchanted and it seems enchanting levels fast
	;; so we will use small numbers here.

	Base = Main.Data.GemStageCount()
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
