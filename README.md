# Mania Converter 1.4
Converter of FNF or osu!mania maps/charts, example from 4 key to 6 key. It can remove damage notes, zip packs, combine audio files, convert to osu!mania and more. Supports Extra Keys Mod, Psych Engine, and Leather Engine (leather not fully). Works with 1-512 keys.

# [VERY POG WEB VERSION](https://theleername.github.io/mania-converter/)
- wow! its support mobile devices!!!
- the ugliest design included!

## [Examples for using](https://github.com/TheLeerName/mania-converter/blob/main/docs/examples.md)

## [Creating Algorithms Guide](https://github.com/TheLeerName/mania-converter/blob/main/docs/algorithms.md)

## [How to build it *(click)*](https://github.com/TheLeerName/mania-converter/blob/main/docs/building.md)

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
### [Check past changelogs here](https://github.com/TheLeerName/mania-converter/blob/main/docs/changelogs.md)

## How to use this? (Editing options.ini, scroll down to see cmd using)
1. Run a EXE file.
2. Open `options.ini` file, and [read this guide](https://github.com/TheLeerName/mania-converter/blob/main/docs/guideoptions.md).
3. Move your chart/map to the converter folder with name like in options line `FileInput:`.
4. Run a EXE file again.
5. Now you have a converted chart/map!

## Using command-line (windows cmd)
1. Run a EXE file.
2. Create `.cmd` or `.bat` file in folder with `.exe` file.
3. Right-click to it and click `Edit`.
4. Type in it: `ManiaConverter.exe`, and [read this guide](https://github.com/TheLeerName/mania-converter/blob/main/docs/guideoptions.md).
5. Move your chart/map to the converter folder with name like in cmd argument `-fileinput:`.
6. Run a EXE file again.
7. Now you have a converted chart/map!

> I dont want do the ui of options in app, please no :(
