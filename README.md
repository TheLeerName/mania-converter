# Mania Converter
Converter of FNF maps/charts, example from 4 key to 6 key.

## How to use this?
1. Run a EXE file, it will be crash.
2. Open `options.json` file:
- `to_key` for a **REAL** number of keys you want to convert to.
- `from_key_default` for default **REAL** number of keys, if in chart/map `mania` line is not exist.
- `to_key_default` for default **REAL** number of keys, if you type value in `to_key` less than 1 or more than length of array in algorithm.
- `algorithm` for placing a notes.
- `extra_keys_sync` for sync with [tposejank's Extra Keys Mod](https://gamebanana.com/mods/333373).
- `from_file` for name of chart/map before converting.
- `to_file` for name of chart/map after converting.
3. Move your chart/map to the converter folder.
4. Run a EXE file again.
5. Now you have a converted chart/map!
> I dont want do the ui of options in app, please no :(

## Explain of `extra_keys_sync`
It working as `"mania": 3,` its **4 keys**, and without sync be `"mania": 3,` its **3 keys**. You must type a **REAL** number of keys in `to_key`.
