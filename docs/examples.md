# Examples for using Mania Converter CMD Version
1. Convert from FNF 4k `ballistic.json` BF Side to osu!mania 7k in folder named `osu` in file `NateAnim8 - Ballistic [ManiaConverter] (Normal).osu`
- `options.ini` method: `FileInput:ballistic, FileOutput:osu/, Key:7, Mode:2, Side:1, Artist:NateAnim8` just type these values
- cmd method: `mccmd "-fileinput:ballistic" "-fileoutput:osu/" "-mode:2" "-side:1" "-key:7" "artist:NateAnim8"` just type it in `.bat` file and run it
2. Convert from osu!mania 4k `beatmap.osu` to osu!mania 7k
- `options.ini` method: `FileInput:beatmap, Key:7, Mode:3` just type these values
- cmd method: `mccmd "-fileinput:beatmap" "-fileoutput:" "-mode:3" "-key:7"` just type it in `.bat` file and run it
3. Convert from FNF 4k `beatmap.json` to FNF 7k `beatmap-converted.json` 
- `options.ini` method: `FileInput:beatmap, FileOutput:beatmap-converted, Key:7, Mode:0` just type these values
- cmd method: `mccmd "-fileinput:beatmap" "-fileoutput:beatmap-converted" "-mode:0" "-key:7"` just type it in `.bat` file and run it
4. Convert from osu!mania 4k `NateAnim8 - Ballistic [ManiaConverter] (Normal).osu` to FNF 9k `beatmap-converted.json` 
- `options.ini` method: `FileInput:NateAnim8 - Ballistic [ManiaConverter] (Normal), FileOutput:beatmap-converted, Key:4, Mode:1` just type these values
- cmd method: `mccmd "-fileinput:NateAnim8 - Ballistic [ManiaConverter] (Normal)" "-fileoutput:beatmap-converted" "-mode:1" "-key:4"` just type it in `.bat` file and run it