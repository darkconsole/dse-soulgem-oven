ScriptName RaceMenuMorphsCBBE Extends RaceMenuBase

; Version data
Int Property SKEE_VERSION = 1 AutoReadOnly
Int Property PAPYRUSUTIL_VERSION = 39 AutoReadOnly
Int Property NIOVERRIDE_SCRIPT_VERSION = 6 AutoReadOnly
Int Property RM_CBBE_VERSION = 2 AutoReadOnly
Int Property Version = 0 Auto

String Property CALLBACK_PART = "ChangeMorphCBBE" AutoReadOnly

String Property CATEGORY_KEY = "rsm_bodymorph_cbbe" AutoReadOnly
String Property MORPH_KEY = "RaceMenuMorphsCBBE.esp" AutoReadOnly

String[] morphs
String[] displayNames

Event OnInit()
	Parent.OnInit()
	Version = RM_CBBE_VERSION
EndEvent

Bool Function CheckNiOverride()
	Return SKSE.GetPluginVersion("skee") >= SKEE_VERSION && NiOverride.GetScriptVersion() >= NIOVERRIDE_SCRIPT_VERSION
EndFunction

Bool Function CheckPapyrusUtil()
	Return PapyrusUtil.GetVersion() >= PAPYRUSUTIL_VERSION && PapyrusUtil.GetScriptVersion() >= PAPYRUSUTIL_VERSION
EndFunction

Bool Function CheckUIExtensions()
	Return Game.IsPluginInstalled("UIExtensions.esp")
EndFunction

Function InitMorphNames()
	morphs     = new String[98]
	morphs[0]  = "7B Lower"
	morphs[1]  = "7B Upper"
	morphs[2]  = "VanillaSSEHi"
	morphs[3]  = "VanillaSSELo"
	morphs[4]  = "OldBaseShape"
	morphs[5]  = "Breasts"
	morphs[6]  = "BreastsSmall"
	morphs[7]  = "BreastsSmall2"
	morphs[8]  = "DoubleMelon"
	morphs[9]  = "BreastCleavage"
	morphs[10] = "BreastsTogether"
	morphs[11] = "PushUp"
	morphs[12] = "BreastGravity2"
	morphs[13] = "BreastHeight"
	morphs[14] = "BreastPerkiness"
	morphs[15] = "BreastWidth"
	morphs[16] = "BreastTopSlope"
	morphs[17] = "BreastCenter"
	morphs[18] = "BreastCenterBig"
	morphs[19] = "BreastFlatness"
	morphs[20] = "BreastFlatness2"
	morphs[21] = "BreastsFantasy"
	morphs[22] = "BreastsNewSH"
	morphs[23] = "BreastsNewSHSymmetry"
	morphs[24] = "BreastsGone"
	morphs[25] = "BreastSideShape"
	morphs[26] = "BreastUnderDepth"
	morphs[27] = "NippleSize"
	morphs[28] = "AreolaSize"
	morphs[29] = "NippleLength"
	morphs[30] = "NippleManga"
	morphs[31] = "NipplePerkiness"
	morphs[32] = "NipplePerkManga"
	morphs[33] = "NippleDistance"
	morphs[34] = "NippleTip"
	morphs[35] = "NippleTipManga"
	morphs[36] = "NippleDown"
	morphs[37] = "NippleUp"
	morphs[38] = "NippleDip"
	morphs[39] = "NipBGone"
	morphs[40] = "BigTorso"
	morphs[41] = "ChestDepth"
	morphs[42] = "ChestWidth"
	morphs[43] = "SternumDepth"
	morphs[44] = "SternumHeight"
	morphs[45] = "RibsProminance"
	morphs[46] = "NavelEven"
	morphs[47] = "Waist"
	morphs[48] = "WaistHeight"
	morphs[49] = "WideWaistLine"
	morphs[50] = "ChubbyWaist"
	morphs[51] = "Back"
	morphs[52] = "BackArch"
	morphs[53] = "Butt"
	morphs[54] = "BigButt"
	morphs[55] = "ButtSmall"
	morphs[56] = "ChubbyButt"
	morphs[57] = "AppleCheeks"
	morphs[58] = "ButtDimples"
	morphs[59] = "ButtUnderFold"
	morphs[60] = "RoundAss"
	morphs[61] = "ButtClassic"
	morphs[62] = "ButtShape2"
	morphs[63] = "ButtCrack"
	morphs[64] = "Groin"
	morphs[65] = "CrotchBack"
	morphs[66] = "Thighs"
	morphs[67] = "SlimThighs"
	morphs[68] = "LegsThin"
	morphs[69] = "ChubbyLegs"
	morphs[70] = "LegShapeClassic"
	morphs[71] = "KneeHeight"
	morphs[72] = "KneeShape"
	morphs[73] = "CalfSize"
	morphs[74] = "CalfSmooth"
	morphs[75] = "FeetFeminine"
	morphs[76] = "AnkleSize"
	morphs[77] = "MuscleAbs"
	morphs[78] = "MuscleArms"
	morphs[79] = "MuscleButt"
	morphs[80] = "MuscleLegs"
	morphs[81] = "MusclePecs"
	morphs[82] = "Hips"
	morphs[83] = "HipBone"
	morphs[84] = "HipUpperWidth"
	morphs[85] = "HipCarved"
	morphs[86] = "HipForward"
	morphs[87] = "Arms"
	morphs[88] = "ChubbyArms"
	morphs[89] = "ForearmSize"
	morphs[90] = "WristSize"
	morphs[91] = "ShoulderWidth"
	morphs[92] = "ShoulderSmooth"
	morphs[93] = "ShoulderTweak"
	morphs[94] = "Belly"
	morphs[95] = "BigBelly"
	morphs[96] = "TummyTuck"
	morphs[97] = "PregnancyBelly"

	displayNames     = new String[98]
	displayNames[0]  = "Full - 7B Lower"
	displayNames[1]  = "Full - 7B Upper"
	displayNames[2]  = "Full - Vanilla High"
	displayNames[3]  = "Full - Vanilla Low"
	displayNames[4]  = "Full - Old Shape"
	displayNames[5]  = "Breasts - Size"
	displayNames[6]  = "Breasts - Smaller 1"
	displayNames[7]  = "Breasts - Smaller 2"
	displayNames[8]  = "Breasts - Melons"
	displayNames[9]  = "Breasts - Cleavage"
	displayNames[10] = "Breasts - Push Together"
	displayNames[11] = "Breasts - Push Up"
	displayNames[12] = "Breasts - Gravity"
	displayNames[13] = "Breasts - Height"
	displayNames[14] = "Breasts - Perkiness"
	displayNames[15] = "Breasts - Width"
	displayNames[16] = "Breasts - Top Slope"
	displayNames[17] = "Breasts - Center"
	displayNames[18] = "Breasts - Center Big"
	displayNames[19] = "Breasts - Flatness 1"
	displayNames[20] = "Breasts - Flatness 2"
	displayNames[21] = "Breasts - Fantasy"
	displayNames[22] = "Breasts - Silly Huge"
	displayNames[23] = "Breasts - Silly Huge Symmetry"
	displayNames[24] = "Breasts - Gone"
	displayNames[25] = "Breasts - Side Shape"
	displayNames[26] = "Breasts - Under Depth"
	displayNames[27] = "Nipples - Size"
	displayNames[28] = "Nipples - Areola Size"
	displayNames[29] = "Nipples - Length"
	displayNames[30] = "Nipples - Defined"
	displayNames[31] = "Nipples - Perky"
	displayNames[32] = "Nipples - Puffy"
	displayNames[33] = "Nipples - Distance"
	displayNames[34] = "Nipples - Tip"
	displayNames[35] = "Nipples - Twist"
	displayNames[36] = "Nipples - Point Down"
	displayNames[37] = "Nipples - Point Up"
	displayNames[38] = "Nipples - Dip"
	displayNames[39] = "Nipples - Gone"
	displayNames[40] = "Torso - Size"
	displayNames[41] = "Torso - Chest Depth"
	displayNames[42] = "Torso - Chest Width"
	displayNames[43] = "Torso - Sternum Depth"
	displayNames[44] = "Torso - Sternum Height"
	displayNames[45] = "Torso - Ribs"
	displayNames[46] = "Torso - Navel Even"
	displayNames[47] = "Waist - Size"
	displayNames[48] = "Waist - Height"
	displayNames[49] = "Waist - Wide"
	displayNames[50] = "Waist - Chubby"
	displayNames[51] = "Back - Size"
	displayNames[52] = "Back - Arch"
	displayNames[53] = "Butt - Size"
	displayNames[54] = "Butt - Bigger"
	displayNames[55] = "Butt - Smaller"
	displayNames[56] = "Butt - Chubby"
	displayNames[57] = "Butt - Apple"
	displayNames[58] = "Butt - Dimples"
	displayNames[59] = "Butt - Under Fold"
	displayNames[60] = "Butt - Round"
	displayNames[61] = "Butt - Shape Classic"
	displayNames[62] = "Butt - Shape Lower"
	displayNames[63] = "Butt - Crack"
	displayNames[64] = "Butt - Groin"
	displayNames[65] = "Butt - Move Crotch"
	displayNames[66] = "Legs - Thighs"
	displayNames[67] = "Legs - Slim Thighs"
	displayNames[68] = "Legs - Thin"
	displayNames[69] = "Legs - Chubby"
	displayNames[70] = "Legs - Shape Classic"
	displayNames[71] = "Knee - Height"
	displayNames[72] = "Knee - Shape"
	displayNames[73] = "Calves - Size"
	displayNames[74] = "Calves - Smooth"
	displayNames[75] = "Feet - Feminine"
	displayNames[76] = "Feet - Ankle Size"
	displayNames[77] = "Muscles - Abs"
	displayNames[78] = "Muscles - Arms"
	displayNames[79] = "Muscles - Butt"
	displayNames[80] = "Muscles - Legs"
	displayNames[81] = "Muscles - Pecs"
	displayNames[82] = "Hips - Size"
	displayNames[83] = "Hips - Bone"
	displayNames[84] = "Hips - Upper Width"
	displayNames[85] = "Hips - Carved"
	displayNames[86] = "Hips - Forward"
	displayNames[87] = "Arms - Size"
	displayNames[88] = "Arms - Chubby"
	displayNames[89] = "Arms - Forearm Size"
	displayNames[90] = "Hands - Wrist Size"
	displayNames[91] = "Shoulders - Width"
	displayNames[92] = "Shoulders - Smooth"
	displayNames[93] = "Shoulders - Tweak"
	displayNames[94] = "Belly - Size"
	displayNames[95] = "Belly - Bigger"
	displayNames[96] = "Belly - Tummy Tuck"
	displayNames[97] = "Belly - Pregnant"

	displayNames = morphs
EndFunction

Event OnCategoryRequest()
	AddCategory(CATEGORY_KEY, "CBBE MORPHS", -948)
	InitMorphNames()
EndEvent

;Add custom sliders here
Event OnSliderRequest(Actor player, ActorBase playerBase, Race actorRace, Bool isFemale)
	If isFemale && CheckNiOverride()
		AddSliderEx("Reset", CATEGORY_KEY, CALLBACK_PART + "Reset", 0.0, 2.0, 1.0, 0.0)

		If CheckPapyrusUtil() && CheckUIExtensions()
			addPresetSliders()
		EndIf

		Int m
		While m < morphs.Length
			AddSliderEx(displayNames[m], CATEGORY_KEY, CALLBACK_PART + morphs[m], -1.0, 1.0, 0.01, getBodyMorph(morphs[m]))
			m += 1
		EndWhile

		Version = RM_CBBE_VERSION
	Endif
EndEvent

Event OnSliderChanged(String callback, Float value)
	If CheckNiOverride()
		If callback == (CALLBACK_PART + "Reset")
			If value == 2.0
				clearBodyMorphs()
			EndIf
		ElseIf callback == (CALLBACK_PART + "LoadPreset")
			If value == 2.0
				choosePreset()
			EndIf
		ElseIf callback == (CALLBACK_PART + "SavePreset")
			If value == 2.0
				savePreset()
			EndIf
		Else
			Int m
			While m < morphs.Length
				If callback == (CALLBACK_PART + morphs[m])
					addBodyMorph(morphs[m], value)
				EndIf
				m += 1
			EndWhile
		EndIf
	Endif
EndEvent

Function updateModel()
	NiOverride.UpdateModelWeight(_targetActor)
EndFunction

Function addBodyMorph(String morphName, Float value, Bool update = true)
	NiOverride.SetBodyMorph(_targetActor, morphName, MORPH_KEY, value)

	If update
		updateModel()
	EndIf
EndFunction

Float Function getBodyMorph(String morphName)
	Return NiOverride.GetBodyMorph(_targetActor, morphName, MORPH_KEY)
EndFunction

Function clearBodyMorphs()
	NiOverride.ClearBodyMorphKeys(_targetActor, MORPH_KEY)
	updateModel()

	Int sliderPosFlag = 1 + 2 + 4 + 8 ; don't request update (flag 1)
	;Int sliderUpdateFlag = 2 + 4 + 8 ; request update
	String[] sliderNames = Utility.CreateStringArray(morphs.Length + 1)
	Float[] sliderValues = Utility.CreateFloatArray(morphs.Length + 1)
	Int[] sliderFlags = Utility.CreateIntArray(morphs.Length + 1, sliderPosFlag)

	Int m
	While m < morphs.Length
		sliderNames[m] = CALLBACK_PART + morphs[m]
		m += 1
	EndWhile

	SetSliderParametersEx(sliderNames, sliderValues, sliderValues, sliderValues, sliderValues, sliderFlags)

	; Reset the 'Reset' slider to 0 and request update
	SetSliderParameters(CALLBACK_PART + "Reset", 0.0, 2.0, 1.0, 0.0)
EndFunction

Function addPresetSliders()
	String[] presetFiles = JsonUtil.JsonInFolder("RaceMenuMorphsCBBE/Presets")
	If presetFiles.Length > 0
		; Add Load Preset slider if any preset files were found
		AddSliderEx("Load Preset", CATEGORY_KEY, CALLBACK_PART + "LoadPreset", 0.0, 2.0, 1.0, 0.0)
	EndIf

	; Add Save Preset slider
	AddSliderEx("Save Preset", CATEGORY_KEY, CALLBACK_PART + "SavePreset", 0.0, 2.0, 1.0, 0.0)
EndFunction

Function choosePreset()
	String[] presetFiles = JsonUtil.JsonInFolder("RaceMenuMorphsCBBE/Presets")
	If presetFiles.Length > 0
		RaceMenuMorphsCBBEUIListMenu listMenu = RaceMenuMorphsCBBEUIExtensions.GetMenu("RaceMenuMorphsCBBEUIListMenu") as RaceMenuMorphsCBBEUIListMenu
		If listMenu != None
			Int f
			While f < presetFiles.Length
				listMenu.AddEntryItem(presetFiles[f])
				f += 1
			EndWhile

			listMenu.OpenMenu()

			String presetName = listMenu.GetResultString()
			If presetName != ""
				loadPreset(presetName)
			EndIf
		EndIf
	EndIf

	; Reset the 'Load Preset' slider to 0 and request update
	SetSliderParameters(CALLBACK_PART + "LoadPreset", 0.0, 2.0, 1.0, 0.0)
EndFunction

Function loadPreset(String presetName)
	String fileName = "RaceMenuMorphsCBBE/Presets/" + presetName
	JsonUtil.Load(fileName)

	If JsonUtil.IsGood(fileName)
		Int sliderPosFlag = 1 + 2 + 4 + 8 ; don't request update (flag 1)
		String[] sliderNames = Utility.CreateStringArray(morphs.Length)
		Float[] sliderValues = Utility.CreateFloatArray(morphs.Length)
		Int[] sliderFlags = Utility.CreateIntArray(morphs.Length, sliderPosFlag)

		Int m
		While m < morphs.Length
			String morphName = morphs[m]

			; Find matching morph value
			Float morphValue = JsonUtil.GetPathFloatValue(fileName, ".morphs." + morphName + ".value")

			sliderNames[m] = CALLBACK_PART + morphName
			sliderValues[m] = morphValue

			; Set morph to new value
			addBodyMorph(morphName, morphValue, false)

			m += 1
		EndWhile

		; Apply changes to model
		updateModel()

		; Set sliders to new morph values
		SetSliderParametersEx(sliderNames, sliderValues, sliderValues, sliderValues, sliderValues, sliderFlags)

		; Unload so that external changes can be fetched on next slider request
		JsonUtil.Unload(fileName, false)
	EndIf
EndFunction

Function savePreset()
	RaceMenuMorphsCBBEUIExtensions.InitMenu("RaceMenuMorphsCBBEUITextEntryMenu")
	;RaceMenuMorphsCBBEUIExtensions.SetMenuPropertyString("RaceMenuMorphsCBBEUITextEntryMenu", "text", "Test Text")
	RaceMenuMorphsCBBEUIExtensions.OpenMenu("RaceMenuMorphsCBBEUITextEntryMenu")

	String presetName = RaceMenuMorphsCBBEUIExtensions.GetMenuResultString("RaceMenuMorphsCBBEUITextEntryMenu")
	If presetName != ""
		String fileName = "RaceMenuMorphsCBBE/Presets/" + presetName
		JsonUtil.Load(fileName)
		JsonUtil.ClearPath(fileName, ".morphs")

		; Store data for all morphs
		Int m
		While m < morphs.Length
			String morphName = morphs[m]
			Float morphValue = getBodyMorph(morphName)
			JsonUtil.SetPathFloatValue(fileName, ".morphs." + morphName + ".value", morphValue)
			m += 1
		EndWhile

		JsonUtil.Save(fileName)

		; Unload so that external changes can be fetched on next slider request
		JsonUtil.Unload(fileName, false)
	EndIf

	; Reset the 'Save Preset' slider to 0 and request update
	SetSliderParameters(CALLBACK_PART + "SavePreset", 0.0, 2.0, 1.0, 0.0)
EndFunction
