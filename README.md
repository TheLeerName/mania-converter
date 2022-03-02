# Mania Converter 1.3.2
Converter of FNF or osu!mania maps/charts, example from 4 key to 6 key. It can remove damage notes, convert to osu!mania and more. Supports Psych Engine, Kade Engine and Leather Engine (leather not fully).

## [Examples for using](https://github.com/TheLeerName/mania-converter/blob/main/docs/examples.md)

## [How to build it *(click)*](https://github.com/TheLeerName/mania-converter/blob/main/docs/building.md)

## 1.3.2 - New option IgnoreNote
- **New line in options** `IgnoreNote`: for list a ignored notetypes split on comma (for example, you want convert chart/map without damage notes)
- Removed **kinds of engines sync**, now **it syncs by default**
- **Fixed issue with bugged sides** in osu convert
- **Fully rewritten a log system**
- `mc options v3`, app will be convert options from v1 or v2 to v3
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
