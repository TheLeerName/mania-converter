# Options v5 guide of Mania Converter (with default values)
- `FileInput:beatmap` for name of chart/map before converting.
- `FileOutput:beatmap-converted` for name of chart/map after converting.
- `Mode:0` for switch in converter modes, 0 = FNF (converting from N key to N key), 1 = osu!mania to FNF, 2 = FNF to osu!mania, 3 = osu!mania (converting from N key to N key).
- `IgnoreNote:Hurt Note` for list a ignored notetypes split on comma. (for example, you want convert chart without damage notes)
- `Key:6` for a REAL number of keys you want to convert to.
- `Side:1` for switch in FNF sides, 0 = player1 (BF) and player2 (Opponent), 1 or player1 or bf = player1 (BF), 2 or player2 or opponent = player2 (Opponent).
- `player1:bf` for name of player1 (BF).
- `player2:pico` for name of player2 (Opponent, Dad).
- `player3:gf` for name of GF.
- `stage:stage` for name of stage.
- `speed:3` for scroll speed of notes.
- `bpm:150` for BPM of song, now uses like a default value when bpm calculation error.
- `needsVoices:0` 1 or true or y or yes = song uses Voices.ogg file.
- `gfSection:0` 1 or true or y or yes = GF sings instead player2.
- `altAnim:0` 1 or true or y or yes = characters uses alt anims.
- `mustHitSection:1` 1 or true or y or yes = cam follow to player1, any other values = cam follow to player2.
- `AudioFileName:audio.mp3` for name of audio file of song.
- `Artist:ManiaConverter` for name of artist of song.
- `Creator:ManiaConverter` for name of creator of chart/map.
- `Version:Normal` for name of difficulty of map.
- `Source:Friday Night Funkin` for source of song.
- `Background:none` for background of song, leave "none" to disable it.
- `HPDrainRate:8.5` for rate of hp drain of map.
- `OverallDifficulty:7` for overall difficulty of map. (timing of notes)
- `VolumeHitSound:20` for volume of hitsounds (20 = 20%).
- `FromKeyDefault:4` for default REAL number of keys, if you type value in ToKey less than 1 or more than value of algorithms.
- `ToKeyDefault:6` for default REAL number of keys, if in chart/map mania line is not exist.

## CMD arguments example: `"-creator:ManiaConverter"` will be argument, in options its `Creator:ManiaConverter`