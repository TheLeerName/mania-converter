# Mania Converter 1.2.2
Converter of FNF or osu!mania maps/charts, example from 4 key to 6 key.

## With this converter you can:
1. Convert from FNF 4k `ballistic.json` BF Side to osu!mania 7k in folder named `osu` in file `NateAnim8 - Ballistic [ManiaConverter] (Normal).osu`
- `options.json` method: `"file_paths":["ballistic", "osu/"], "to_key":7, "converter_mode":2, "osu_side":1, "artist":"NateAnim8"` just type these values
- cmd method: `ManiaConverter.exe "-path:ballistic" "-saveto:osu/" "-mode:2" "-side:1" "-key:7" "artist:NateAnim8"` just type it in `.bat` file and run it
2. Convert from osu!mania 4k `beatmap.osu` to osu!mania 7k
- `options.json` method: `"file_paths":["beatmap", ""], "to_key":7, "converter_mode":3` just type these values
- cmd method: `ManiaConverter.exe "-path:beatmap" "-saveto:" "-mode:3" "-key:7"` just type it in `.bat` file and run it
3. Convert from FNF 4k `beatmap.json` to FNF 7k `beatmap-converted.json` 
- `options.json` method: `"file_paths":["beatmap", "beatmap-converted"], "to_key":7, "converter_mode":0` just type these values
- cmd method: `ManiaConverter.exe "-path:beatmap" "-saveto:beatmap-converted" "-mode:0" "-key:7"` just type it in `.bat` file and run it
4. Convert from osu!mania 4k `NateAnim8 - Ballistic [ManiaConverter] (Normal).osu` to FNF 9k `beatmap-converted.json` 
- `options.json` method: `"file_paths":["NateAnim8 - Ballistic [ManiaConverter] (Normal)", "beatmap-converted"], "to_key":4, "converter_mode":1` just type these values
- cmd method: `ManiaConverter.exe "-path:NateAnim8 - Ballistic [ManiaConverter] (Normal)" "-saveto:beatmap-converted" "-mode:1" "-key:4"` just type it in `.bat` file and run it

## How to use this? (Editing options.json, scroll down to see cmd using)
1. Run a EXE file, it will be crash.
2. Open `options.json` file:
- `file_paths` for name of charts/maps, value 1 = for name of chart/map before converting, value 2 = for name of chart/map after converting. (if you use `converter_mode` 2 or 3: in 2 value of `file_paths` you can choose folder, just type `/` in end of line)
- `to_key` for a **REAL** number of keys you want to convert to.
- `key_default` for default **REAL** number of keys, value 1 = if in chart/map `mania` line is not exist, value 2 = if you type value in `to_key` less than 1 or more than value of
algorithms.
- `fnf_sync` for sync with some FNF engines, 1 = [tposejank's Extra Keys Mod](https://gamebanana.com/mods/333373) (real key count - 1, example 4 keys is mania = 3), 2 = [Leather128's Leather Engine](https://gamebanana.com/mods/334945) (mania = (keyCount && playerKeyCount)), 0 = default.
- `converter_mode` for switch in converter modes, 0 = FNF (converting from N key to N key), 1 = osu!mania to FNF, 2 = FNF to osu!mania, 3 = osu!mania (converting from N key to N key).
- `osu_side` for switch in FNF sides, 0 = player1 (BF) and player2 (Opponent), 1 = player1 (BF), 2 = player2 (Opponent).
- `fnf_defaults` for FNF default values in chart/map. ([see this](https://github.com/TheLeerName/mania-converter/blob/main/docs/fnf_defaults.md))
- `osu_defaults` for osu!mania default values. ([see this](https://github.com/TheLeerName/mania-converter/blob/main/docs/osu_defaults.md))
3. Move your chart/map to the converter folder, and rename it to `beatmap.json` or `beatmap.osu` (you can edit this in `options.json` in line `from_file`).
4. Run a EXE file again.
5. Now you have a converted chart/map!

## Using command-line (windows cmd)
1. Run a EXE file, it will be crash.
2. Create `.cmd` or `.bat` file in folder with `.exe` file.
3. Right-click to it and click `Edit`.
4. Type in it: `ManiaConverter.exe`, now write some these arguments split on space:
- `"-path:ballistic"` for path to converting chart/map. (please not type in it `.json` or `.osu`)
- `"-saveto:ballistic-7k"` for path to converted chart/map. (please not type in it `.json` or `.osu`) **(if you use `converter_mode` 2 or 3: in `saveto:` you can choose folder, just type `/` in end of line)**
- `"-converter_mode:0"` or `"mode:0"` for switch in converter modes, 0 = FNF (converting from N key to N key), 1 = osu!mania to FNF, 2 = FNF to osu!mania, 3 = osu!mania (converting from N key to N key).
- `"osu_side:1"` or `"side:1"` for switch in FNF sides, 0 = player1 (BF) and player2 (Opponent), 1 = player1 (BF), 2 = player2 (Opponent). **(uses only in converter mode 2!)**
- `"fnf_sync:0"` or `"fnf_sync:0"` for sync with some FNF engines, 1 = [tposejank's Extra Keys Mod](https://gamebanana.com/mods/333373) (real key count - 1, example 4 keys is mania = 3), 2 = [Leather128's Leather Engine](https://gamebanana.com/mods/334945) (mania = (keyCount && playerKeyCount)), 0 = default. **(not uses in converter mode 3!)**
- `"key:6"` for a **REAL** number of keys you want to convert to.
- **[see Osu arguments cmd](https://github.com/TheLeerName/mania-converter/blob/main/docs/osu_defaults.md)**
- **[see FNF arguments cmd](https://github.com/TheLeerName/mania-converter/blob/main/docs/fnf_defaults.md)**
5. Move your chart/map to the converter folder with name like in cmd argument `-path:`.
6. Run a EXE file again.
7. Now you have a converted chart/map!

> I dont want do the ui of options in app, please no :(
