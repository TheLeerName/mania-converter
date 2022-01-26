# Mania Converter
Converter of FNF or osu!mania maps/charts, example from 4 key to 6 key. If you want convert from osu!mania, set `true` in line `osu_convert` in `options.json`.

## How to use this? (Editing options.json, scroll down to see cmd using)
1. Run a EXE file, it will be crash.
2. Open `options.json` file:
- `to_key` for a **REAL** number of keys you want to convert to.
- `from_key_default` for default **REAL** number of keys, if in chart/map `mania` line is not exist.
- `to_key_default` for default **REAL** number of keys, if you type value in `to_key` less than 1 or more than length of array in algorithm.
- `osu_convert` for switch to osu!mania to fnf converter.
- `osu_defaults` for default values of FNF chart.
- `extra_keys_sync` for sync with [tposejank's Extra Keys Mod](https://gamebanana.com/mods/333373). It working as `"mania": 3,` its **4 keys**, and without sync be `"mania": 3,` its **3 keys**. You must type a **REAL** number of keys in `to_key`.
- `leather_sync` for sync with [Leather128's Leather Engine](https://gamebanana.com/mods/334945). It working as `mania` its `keyCount` and `playerKeyCount`. For now charts/maps with different numbers of keys not supported. If its true, `extra_keys_sync` is disabled.
- `from_file` for name of chart/map before converting.
- `to_file` for name of chart/map after converting.
3. Move your chart/map to the converter folder, and rename it to `beatmap.json` or `beatmap.osu` (you can edit this in `options.json` in line `from_file`).
4. Run a EXE file again.
5. Now you have a converted chart/map!

## Using command-line (windows cmd)
1. Run a EXE file, it will be crash.
2. Create `.cmd` or `.bat` file in folder with `.exe` file.
3. Right-click to it and click `Edit`.
4. Type in it: `ManiaConverter.exe -path:ballistic-osu -saveto:ballistic-7k -key:7 -fromosu:true -sync:leather`
- `-path:ballistic` - for path to converting chart/map (please not type in it `.json` or `.osu`)
- `-saveto:ballistic-7k` - for path to converted chart/map (please not type in it `.json` or `.osu`)
- `-key:7` - for key count of chart/map
- `-fromosu:true` - for enable/disable from osu!mania to FNF converting (for enable: `true`/`yes`/`y`/`1`, for disable: any value)
- `-sync:leather` - for sync with some FNF engines ([tposejank's Extra Keys Mod](https://gamebanana.com/mods/333373): `extrakeys`/`extra_keys`/`tposejank`/`0`, for [Leather128's Leather Engine](https://gamebanana.com/mods/334945): `leather`/`leatherengine`/`leather_engine`/`1`, for any other engines: any value)
5. Move your chart/map to the converter folder with name like in cmd argument `-path:`.
6. Run a EXE file again.
7. Now you have a converted chart/map!

### CONVERTING FROM FNF TO OSU!MANIA SOON (wait about week)

> I dont want do the ui of options in app, please no :(
