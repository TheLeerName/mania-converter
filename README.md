# Mania Converter 1.4
Converter of FNF or osu!mania maps/charts, example from 4 key to 6 key. It can remove damage notes, zip packs, combine audio files, convert to osu!mania and more. Supports [Extra Keys For Psych Engine](https://gamebanana.com/mods/333373), [Extra Keys With Lua For Psych Engine](https://gamebanana.com/mods/352021), [Psych Engine](https://gamebanana.com/mods/309789), [Yoshi Engine](https://gamebanana.com/mods/352532) and [Leather Engine](https://gamebanana.com/mods/334945) (leather not fully). Works with 1-512 keys. (yeah its possible)

# [VERY POG WEB VERSION](https://theleername.github.io/mania-converter/)
- wow! its support mobile devices!!!
- the ugliest design included!

## [Examples for using](https://github.com/TheLeerName/mania-converter/blob/main/docs/examples.md)

## [Creating Algorithms Guide](https://github.com/TheLeerName/mania-converter/blob/main/docs/algorithms.md)

## [How to build it *(click)*](https://github.com/TheLeerName/mania-converter/blob/main/docs/building.md)

## 1.4.1 - Fix of overlapping notes
- New option `Sensitivity`, for sensitivity of removing duplicate notes, leave 0 for removing notes ONLY with same timing and direction. (in milliseconds)
- Support of [Extra Keys with Lua For Psych Engine](https://gamebanana.com/mods/352021): option `LuaSave`, 1 or true or y or yes = chart/map saves in this format. (request from [60 lapie](https://gamebanana.com/members/1633383))
- Support of [Yoshi Engine](https://gamebanana.com/mods/352532): added keyNumber thing (request from [CEMEHzzz](https://gamebanana.com/members/1776409))
- Fixed unexpected crash when folder is not exist
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
