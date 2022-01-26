package;

using StringTools;

typedef Song = {
	var song:SwagSong;
}

typedef SwagSong =
{
	var song:String;
	var notes:Array<SwagSection>;
	var events:Array<Dynamic>;
	var bpm:Float;
	var needsVoices:Bool;
	var speed:Float;
	var mania:Int;
	var playerKeyCount:Int;
	var keyCount:Int;

	var player1:String;
	var player2:String;
	var gfVersion:String;
	var stage:String;

	var validScore:Bool;
}

typedef SwagSection =
{
	var sectionNotes:Array<Dynamic>;
	var lengthInSteps:Int;
	var typeOfSection:Int;
	var mustHitSection:Bool;
	var gfSection:Bool;
	var bpm:Float;
	var changeBPM:Bool;
	var altAnim:Bool;
}

class Osu
{
	public static var parser:Osu;

	public function convert(map:Array<String>, saveto:String)
	{
		var json:Song = { // copied from psych engine charting state
			song: {
				song: 'Sus',
				notes: [
					{
						typeOfSection: Options.get.osu_defaults.notes.typeOfSection,
						lengthInSteps: Options.get.osu_defaults.notes.lengthInSteps,
						sectionNotes: [],
						mustHitSection: Options.get.osu_defaults.notes.mustHitSection,
						gfSection: Options.get.osu_defaults.notes.gfSection,
						bpm: Options.get.osu_defaults.bpm,
						changeBPM: Options.get.osu_defaults.notes.changeBPM,
						altAnim: Options.get.osu_defaults.notes.altAnim
					}
				],
				events: [],
				bpm: Options.get.osu_defaults.bpm,
				needsVoices: Options.get.osu_defaults.needsVoices,
				player1: Options.get.osu_defaults.player1,
				player2: Options.get.osu_defaults.player2,
				gfVersion: Options.get.osu_defaults.gfVersion,
				speed: Options.get.osu_defaults.speed,
				stage: Options.get.osu_defaults.stage,
				mania: 4,
				playerKeyCount: 4,
				keyCount: 4,
				validScore: false
			}
		};

		Debug.log.trace('Getting osu! map data...');
		Debug.log.trace('Found ${map.length - (findLine(map, '[HitObjects]') + 1)} notes...');
		json.song.song = getMapOptions(map, 'TitleUnicode');

		var curMode:Int = Std.parseInt(getMapOptions(map, 'Mode'));
		if (curMode != 3)
		{
			var osuModes:Array<String> = [
				'standard osu',
				'osu!taiko',
				'osu!catch',
				'osu!mania'
			];
			Debug.log.error('Converter supports only osu!mania mode! You have a ${osuModes[curMode]} beatmap.');
			return;
		}

		var toData:Array<Dynamic> = [];
		var int:Int = 0;
		var keyCount:Int = Std.parseInt(getMapOptions(map, 'CircleSize'));
		Debug.log.trace('Parsing notes from osu!mania map...');
		for (i in findLine(map, '[HitObjects]') + 1...map.length)
		{
			toData[int] = [
				Std.parseInt(osuLine(map[i], 2, ',')),
				convertNote(osuLine(map[i], 0, ','), keyCount),
				Std.parseFloat(osuLine(map[i], 5, ',')) - Std.parseFloat(osuLine(map[i], 2, ','))
			];
			if (toData[int][2] < 0)
				toData[int][2] = 0; // removing negative values of hold notes
			int++;
		}
		int = 0;

		Debug.log.trace('Placing notes to fnf map...');
		for (i in 0...toData.length)
			json.song.notes[0].sectionNotes[i] = toData[i];

		if (Options.get.to_key != keyCount)
		{
			Debug.log.warn('Map have ${keyCount} keys, converting to ${Options.get.to_key} key...');
			FNF.parser.convert(json, Options.get.to_file);
		}

		json.song.keyCount = Options.get.to_key;
		json.song.playerKeyCount = Options.get.to_key;
		json.song.mania = Options.get.to_key + (Options.get.extra_keys_sync ? -1 : 0);

		FileAPI.file.saveFile('${saveto}', FileAPI.file.stringify(json, "\t", false));
		Debug.log.trace('Successfully converted ${json.song.song} from osu!mania to fnf!');
	}

	// from funkin coolutil.hx
	function numberArray(min:Int, max:Int):Array<Int>
	{
		var dumbArray:Array<Int> = [];
		for (i in min...max)
		{
			dumbArray.push(i);
		}
		return dumbArray;
	}

	function convertNote(from_note:Dynamic, keyCount:Int):Int
	{
		from_note = Std.parseInt(from_note);
		var note_array:Array<Dynamic> = [
			[numberArray(0, 511)], // 0 key
			[numberArray(0, 511)],
			[numberArray(0, 256), numberArray(257, 511)],
			[numberArray(0, 169), numberArray(170, 340), numberArray(341, 511)],
			[numberArray(0, 127), numberArray(128, 255), numberArray(256, 383), numberArray(384, 511)], // 4 key
			[numberArray(0, 101), numberArray(102, 203), numberArray(204, 306), numberArray(307, 408), numberArray(409, 511)],
			[numberArray(0, 84), numberArray(85, 169), numberArray(170, 255), numberArray(256, 340), numberArray(341, 425), numberArray(426, 511)],
			[numberArray(0, 72), numberArray(73, 145), numberArray(146, 218), numberArray(219, 291), numberArray(292, 364), numberArray(365, 437), numberArray(438, 511)],
			[numberArray(0, 63), numberArray(64, 127), numberArray(128, 191), numberArray(192, 255), numberArray(256, 319), numberArray(320, 383), numberArray(384, 447), numberArray(448, 511)],
			[numberArray(0, 56), numberArray(57, 113), numberArray(114, 170), numberArray(171, 227), numberArray(228, 284), numberArray(285, 341), numberArray(342, 398), numberArray(399, 455), numberArray(456, 511)]
		];

		for (i in 0...note_array[keyCount].length)
			for (i2 in 0...note_array[keyCount][i].length)
				if (note_array[keyCount][i][i2] == from_note)
					return i;

		//var dgdfg = Std.int(512 / keyCount);

		Debug.log.error('Note ${from_note} not found in array!');
		return 0;
	}

	function findLine(array:Array<String>, find:String, fromLine:Int = 0, toLine:Int = null):Int
	{
		if (toLine == null)
			toLine = array.length;

		for (i in fromLine...array.length)
			if (array[i].contains(find))
				return i;

		Debug.log.error('String ${find} not found!');
		return 0;
	}

	function osuLine(string:String, int:Int, split:String):Dynamic
	{
		var array:Array<String> = string.split(split);
		return array[int];
	}

	function getMapOptions(map:Array<String>, name:String)
	{
		for (i in 0...map.length)
			if (map[i].startsWith('${name}:'))
			{
				map[i] = map[i].replace('${name}:', '');
				map[i] = map[i].trim();
				return map[i];
			}

		Debug.log.error('Option ${name} not found!');
		return null;
	}
}