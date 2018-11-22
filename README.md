## Soulgem Oven 4: Special Edition Edition
--------

This is extremely a work in progress do not install this. Your game will probably literally explode. Broken shards of soulgem coming at you at high velocity are sharper than Mehrunes' Razor you have been warned.

### About

If you've used previous Soulgem Oven's you already know what is going on. This version is for Special Edition, uses BodySlide morphs instead of bone scales, and unfortunately for you not backwards compatible with Oldrim.

### Requirements

Version requirements are much stricter this time, due to SSE modding still being a work in progress these minimum version numbers are not suggestions, things will not work if you do dumb.

* Skyrim: Special Edition

* SKSE64 2.0.7+
    * http://skse.silverlock.org/

* SkyUI SE 5.2+
    * https://www.nexusmods.com/skyrimspecialedition/mods/12604

* PapyrusUtil SE 3.4b+
    * https://www.nexusmods.com/skyrimspecialedition/mods/13048

* RaceMenu SE 0.2.4+
    * https://www.nexusmods.com/skyrimspecialedition/mods/19080

* BodySlide 4.6.2+
    * https://www.nexusmods.com/skyrimspecialedition/mods/201

* UI Extensions 1.2.0+
	* https://www.nexusmods.com/skyrimspecialedition/mods/17561

* SexLab Framework SE 1.63 Beta 2+
	* https://www.loverslab.com/topic/91861-sexlab-framework-se-163-beta-2-april-5-2018/

### Features New To SGO4

* Add support for new races without editing SGO4.
* Fully translatable into other languages.
* Uses BodySlide / Racemenu Morphs for better body scaling.
* Settings are saved to an external JSON file so you do not have to set them all every time you start a new save.
* Followers will sync their fertility cycles if they are following you long enough.


### Customize the scalings.

The MCM for this is not yet done, but you can easily edit the JSON file.

* `configs\dse-soulgem-oven\settings\Default.json`
* You can edit the Sliders set in the config file. The value is where the slider should be at maximum. You can add and remove any sliders you want.

Once the MCM is done, all changed settings will be saved to `Custom.json` that way I can update my `Default.json` for any new values added in updates without overriding any changes you have made. This also means you can share your `Custom.json` with other people or back it up.

### Adding New Races - Example, some Succubus thing.

Create a new ESP that contains the milks you want the race to use.

* `succubus-sgo4.esp`

Create a new JSON file that describes the race and points to the milks in your new esp. Use the JSON from `000-VanillaRaces.json` as a template.

* `config\dse-soulgem-oven\races\succubus.json`

(Race files get loaded alphabetically, )

### Adding New Translations

There are two translation files. One is the normal translation file that the menus use.

* `interface\translations\dse-soulgem-oven_ENGLISH.txt`

So if you're doing a German translation copy that file to dse-soulgem-oven_GERMAN.txt and edit it.

The second file is used by the scripting.

* `configs\dse-soulgem-oven\translations\English.json`

Again if you are doing a German translation copy that fle to German.json.

Send your translation files to me and I will package them for others to use and list you on the mod page.
