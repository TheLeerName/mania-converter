# Changelogs of Mania Converter

## (Latest) 3.0.3 - Hotfix
- First BPM in TimingPoints uses now, instead of average
- Fix of 0 key count (thx to [CcinoWrath](https://gamebanana.com/posts/10815716) for report)
- Fix of space char in start of diff name
- Fix of sustain length in convert to osu
- Fix of BPM in convert from osu
- Fix of exported message for web version

## 3.0.2 - Hotfix
- Shows things on start app
- If key count setted as 0, then uses current key count on map
- Fixed difficulty name parsing again (thx to [ItzEnderArkail](https://gamebanana.com/posts/10811434) for report)
- Fixed unsupported osu modes

## 3.0.1 - Hotfix
- Fixed difficulty name parsing (thx to [LeoroyX](https://gamebanana.com/posts/10786130) for report)
- Fixed song name parsing
- Time of notes in osu is integer now
- Removed stupid trace in remove duplicates function

## 3.0 - The UI Update 2
- Now on HaxeFlixel
- Supports of 1-512 key
- CMD arguments works too: `ManiaConverter.exe "Camellia - Quaoar (-MysticEyes) [Celestial].osu" "quaoar-celestial.json"`

## 2.0 - The UI Update
- Finally UI of app
- After upload multiply files, app packs them in `.zip` file
- Support of 1-32 key, for more keys use `mccmd.exe` arguments
- Automatically making a difficulty name for all modes

## 1.4.2 - Pre-UI Update
- Renamed app to `mccmd.exe` to unconflict with **future UI Update**
- Replaced ffmpeg to older version for decreasing size of it
- Fix of calculating BPM in osu!mania
- Another fix of crash when folder is not exist
- Fix of setting keys in osu!mania
- Fix of converting notes in osu!mania

## 1.4.1 - Fix of overlapping notes
- New option `Sensitivity`, for sensitivity of removing duplicate notes, leave 0 for removing notes ONLY with same timing and direction. (in milliseconds)
- Support of [Extra Keys with Lua For Psych Engine](https://gamebanana.com/mods/352021): option `LuaSave`, 1 or true or y or yes = chart/map saves in this format, supports from 1 key to 9 key. (request from [60 lapie](https://gamebanana.com/members/1633383))
- Support of [Yoshi Engine](https://gamebanana.com/mods/352532): added keyNumber thing (request from [CEMEHzzz](https://gamebanana.com/members/1776409))
- Fixed unexpected crash when folder is not exist

## 1.4 - Support of 1-512 key and functions
- Pog support of 1-512 key for FNF and osu!mania
- New options for osu!mania: `Source`, `Background`, `OverallDifficulty` (timing of notes)
- Able to block changing key count of song, just type `Key:none`
- Removed BPM changing for fnf to osu!mania converting, too bugged and useless
- Watermark of Mania Converter in maps to let everyone know about this useful modding tool :)
- Zip pack function, cmd command: `ManiaConverter pack "from_folder" "pack.zip"`
- FFmpeg function, cmd command: `ManiaConverter ffmpeg combine "Inst.ogg|Voices.ogg" "audio.mp3"` (combines Voices.ogg and Inst.ogg to audio.mp3, may be used for fnf to osu!mania converting)
- CMD argument `--silent` for no traces and no warns in console
- Optimization of getting algorithm

## 1.3.3 - BPM calculating and fix of convert from osu
- **From osu** converting now **working properly**: no more *"all notes in one section and make die debug menu"*
- **BPM in from osu converting now using a mean value of BPM**
- **Better converting a song name** in **to osu** converting
- **Support of "changeBPM"** line in **to osu** converting
- **Errors closes app immediately** now
- `mc options v4`: lines **typeofsection, changebpm, lengthinsteps deleted**; **corrections** in lines **gfversion, gfsection, altanim, musthitsection, version, bpm**

## 1.3.2 - New option IgnoreNote
- **New line in options** `IgnoreNote`: for list a ignored notetypes split on comma (for example, you want convert chart/map without damage notes)
- Removed **kinds of engines sync**, now **it syncs by default**
- **Fixed issue with bugged sides** in osu convert
- **Fully rewritten a log system**
- `mc options v3`, app will be convert options from v1 or v2 to v3

## 1.3.1 - Fix of sides
- Fix of option `Side`
- Fix of song name in to osu!mania convert

## 1.3 - JavaScript Update
- Fully **rewritten to JavaScript Language** (no more annoying window and `lime.ndll`, and less file size)
- **Options v2:** now options written in a more understandable format than `.json`, like in `.osu` files hehe
- If you have old `options.json`, converter take them there and type them in `options.ini`!
- Converting **FNF to osu!mania** 1-10 key to 1-10 key

## 1.2.2 - Convert to osu!mania and many more fixes
- Converting **from FNF to osu!mania**
- Converting osu!mania 1-9 key to 1-9 key
- Many more cmd arguments
- Rewritten some code

## 1.2.1 - support of CMD arguments
- Support of **command-line arguments**
- **Converting from osu!mania** working now **with not only 4k**
- Recode functions
- Rewrite some debug logs

## 1.2 - support of osu maps
- **Convertation from osu!mania**
- Algorithm of placing notes in own folder now
- **Very much options** of osu default in `options.json`

## 1.1.3 - another hotfix of algorithm
- Fixed converting from 7 key to 8 key

## 1.1.2 - hotfix of algorithm
- Fixed converting from 4 key to 8 key

## 1.1.1 - support of Leather Engine
- Partially **support of Leather Engine** maps/charts

## 1.1
- **Sync with Extra Keys Mod**
- New lines in `options.json`: `from_key_default` and `to_key_default`
- New traces and warns in log file
- **Fix of "upperkeying" convertation**
- **Fix crash with event notes**