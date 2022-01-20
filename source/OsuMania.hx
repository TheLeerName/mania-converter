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

class OsuMania
{
	public static var parser:OsuMania;

	public function convert()
	{
		var file:Array<String> = FileAPI.file.getContent('beatmap.osu').trim().split('\n');

		var curMode:Int = Std.parseInt(getMapOptions(file, 'Mode'));
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
		Debug.log.trace('Parsing notes from osu!mania map...');
		for (i in findLine(file, '[HitObjects]') + 1...file.length)
		{
			toData[int] = [Std.parseInt(osuLine(file[i], 2, ',')), convertNote(osuLine(file[i], 0, ',')), (Std.parseInt(osuLine(file[i], 5, ',')) - Std.parseInt(osuLine(file[i], 2, ',')))];
			if (toData[int][2] < 0)
				toData[int][2] = 0;
			// removing negative values of sliders
			int++;
		}
		int = 0;

		var options:Options.OptionsJSON = Options.get.options();
		var json:Song = { // copied from psych engine charting state
			song: {
				song: getMapOptions(file, 'TitleUnicode'),
				notes: [
					{
						typeOfSection: options.osu_defaults.notes.typeOfSection,
						lengthInSteps: options.osu_defaults.notes.lengthInSteps,
						sectionNotes: [],
						mustHitSection: options.osu_defaults.notes.mustHitSection,
						gfSection: options.osu_defaults.notes.gfSection,
						bpm: options.osu_defaults.bpm,
						changeBPM: options.osu_defaults.notes.changeBPM,
						altAnim: options.osu_defaults.notes.altAnim
					}
				],
				events: [],
				bpm: options.osu_defaults.bpm,
				needsVoices: options.osu_defaults.needsVoices,
				player1: options.osu_defaults.player1,
				player2: options.osu_defaults.player2,
				gfVersion: options.osu_defaults.gfVersion,
				speed: options.osu_defaults.speed,
				stage: options.osu_defaults.stage,
				validScore: false
			}
		};

		Debug.log.trace('Placing notes to fnf map...');
		for (i in 0...toData.length)
			json.song.notes[0].sectionNotes[i] = toData[i];

		FileAPI.file.saveFile('${Options.get.options().to_file}.json', FileAPI.file.stringify(json, "\t", false));
	}

	function convertNote(string:String):Int
	{
		var note:Int = Std.parseInt(string);
		switch (note)
		{
			case 64:
				note = 0;
			case 192:
				note = 1;
			case 320:
				note = 2;
			case 448:
				note = 3;
		}
		return note;
	}

	function findLine(array:Array<String>, find:String, fromLine:Int = 0, toLine:Int = null):Int
	{
		if (toLine == null)
			toLine = array.length;

		for (i in fromLine...array.length)
			if (array[i].contains(find))
				return i;

		Debug.log.error('String ${find} not found! Returning 0...');
		return 0;
	}

	function osuLine(string:String, int:Int, split:String):String
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