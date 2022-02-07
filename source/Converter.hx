package;

using StringTools;

class Converter
{
	public static var parser:Converter;

	public function convert(path:String, mode:Int)
	{
		switch (mode)
		{
			case 1:
				return FileAPI.file.stringify(osu_to_fnf(FileAPI.file.parseTXT(path)), "\t", false);
			case 2:
				return toString(fnf_to_osu(FileAPI.file.parseJSON(path)));
			case 3:
				return toString(osu_to_osu(FileAPI.file.parseTXT(path)));
			default:
				return FileAPI.file.stringify(fnf_to_fnf(FileAPI.file.parseJSON(path)), "\t", false);
		}
	}

	function fnf_to_fnf(map:Dynamic, fromkey:Int = 0)
	{
		Debug.log.trace('Getting FNF map data...');
		var value:Float = 0;
		for (i in 0...map.song.notes.length)
			value += map.song.notes[i].sectionNotes.length;
		Debug.log.trace('Found ${value} notes (include event notes)');

		var from_key:Dynamic = 0;
		if (fromkey == 0)
		{
			if (Options.get.fnf_sync == 2)
			{
				var keys:Array<Int> = [0, 0];
				if (map.song.keyCount == null)
					keys[0] = Options.get.key_default[0];
				else
					keys[0] = map.song.keyCount;

				if (map.song.playerKeyCount == null)
					keys[1] = Options.get.key_default[0];
				else
					keys[1] = map.song.playerKeyCount;

				if (keys[0] != keys[1])
				{
					Debug.log.error('Charts/maps with different numbers of keys not supported! (you have ${keys[0]} for opponent and ${keys[1]} for player)');
					return null;
				}
				else
					from_key = keys[0];
			}
			else
			{
				if (map.song.mania == null)
					from_key = Options.get.key_default[0];
				else
					from_key = map.song.mania + (Options.get.fnf_sync == 1 ? 1 : 0);
			}
		}
		else
			from_key = fromkey;

		var to_key:Int = 0;
		if (Options.get.to_key < 1 || Options.get.to_key > Options.func.algLength())
		{
			Debug.log.warn('Key count ${Options.get.to_key < 1 ? 'less than 1' : 'more than ${Options.func.algLength()}'}, returning ${Options.get.key_default[1]}...');
			to_key = Options.get.key_default[1];
		}
		else
			to_key = Options.get.to_key;

		if (from_key == to_key)
		{
			Debug.log.error('Chart/Map already is ${from_key} key!');
			return null;
		}

		Debug.log.trace('Converting notes...');
		for (i in 0...map.song.notes.length)
			for (i1 in 0...map.song.notes[i].sectionNotes.length)
			{
				if (map.song.notes[i].sectionNotes[i1][1] >= 0)
				{
					//var alg_var:Dynamic = alg[from_key][to_key][map.song.notes[i].sectionNotes[i1][1]];
					var alg_var:Dynamic = Options.func.alg(from_key, to_key)[map.song.notes[i].sectionNotes[i1][1]];
					if (alg_var.length > 1)
						map.song.notes[i].sectionNotes[i1][1] = Std.parseInt(alg_var[Std.random(alg_var.length)]);
					else if (alg_var.length == 1)
						map.song.notes[i].sectionNotes[i1][1] = Std.parseInt(alg_var[0]);
					else
						map.song.notes[i].sectionNotes[i1][1] = Std.parseInt(alg_var);
				}
			}

		if (Options.get.fnf_sync == 2)
		{
			map.song.keyCount = to_key;
			map.song.playerKeyCount = to_key;
		}
		else
			map.song.mania = to_key + (Options.get.fnf_sync == 1 ? -1 : 0);

		//FileAPI.file.saveFile(saveto, FileAPI.file.stringify(map, "\t", false));

		Debug.log.trace('Successfully converted FNF map ${map.song.song} from ${from_key} keys to ${to_key} keys!');
		return map;
	}

	function osu_to_fnf(map:Array<String>)
	{
		var json:Song = { // copied from psych engine charting state
			song: {
				song: 'Sus',
				notes: [
					{
						typeOfSection: Options.get.fnf_values.notes.typeOfSection,
						lengthInSteps: Options.get.fnf_values.notes.lengthInSteps,
						sectionNotes: [],
						mustHitSection: Options.get.fnf_values.notes.mustHitSection,
						gfSection: Options.get.fnf_values.notes.gfSection,
						bpm: Options.get.fnf_values.bpm,
						changeBPM: Options.get.fnf_values.notes.changeBPM,
						altAnim: Options.get.fnf_values.notes.altAnim
					}
				],
				events: [],
				bpm: Options.get.fnf_values.bpm,
				needsVoices: Options.get.fnf_values.needsVoices,
				player1: Options.get.fnf_values.player1,
				player2: Options.get.fnf_values.player2,
				gfVersion: Options.get.fnf_values.gfVersion,
				speed: Options.get.fnf_values.speed,
				stage: Options.get.fnf_values.stage,
				mania: 4,
				playerKeyCount: 4,
				keyCount: 4,
				validScore: false
			}
		};

		Debug.log.trace('Getting osu! map data...');
		Debug.log.trace('Found ${map.length - (findLine(map, '[HitObjects]') + 1)} notes...');
		json.song.song = getMapOptions(map, 'Title');
		if (json.song.song == null)
			json.song.song = getMapOptions(map, 'TitleUnicode');
		if (json.song.song == null)
			json.song.song = 'Test';

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
			return null;
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

		if ((findLine(map, '[TimingPoints]') + 1) > 0)
		{
			Debug.log.trace('Calculating BPM...');
			json.song.bpm = 60000 / Std.parseFloat(map[findLine(map, '[TimingPoints]') + 1].split(',')[1]);
			json.song.notes[0].bpm = json.song.bpm;
		}
		else
			Debug.log.warn('Calculating BPM failed');

		Debug.log.trace('Placing notes to FNF map...');
		for (i in 0...toData.length)
			json.song.notes[0].sectionNotes[i] = toData[i];

		if (Options.get.to_key != keyCount)
		{
			Debug.log.warn('Map have ${keyCount} keys, converting to ${Options.get.to_key} key...');
			json = fnf_to_fnf(json, keyCount);
		}

		json.song.keyCount = Options.get.to_key;
		json.song.playerKeyCount = Options.get.to_key;
		json.song.mania = Options.get.to_key + (Options.get.fnf_sync == 1 ? -1 : 0);

		//FileAPI.file.saveFile('${saveto}', FileAPI.file.stringify(json, "\t", false));
		Debug.log.trace('Successfully converted ${getMapOptions(map, 'Artist') != null ? getMapOptions(map, 'Artist') : getMapOptions(map, 'ArtistUnicode')} - ${getMapOptions(map, 'Title') != null ? getMapOptions(map, 'Title') : getMapOptions(map, 'TitleUnicode')} (${getMapOptions(map, 'Creator')}) [${getMapOptions(map, 'Version')}] from osu!mania to FNF!');

		return json;
	}

	function fnf_to_osu(map:Dynamic)
	{
		Debug.log.trace('Getting FNF map data...');

		var value:Float = 0;
		for (i in 0...map.song.notes.length)
			value += map.song.notes[i].sectionNotes.length;
		Debug.log.trace('Found ${value} notes (include event notes)');

		Debug.log.trace('Setting key count of map...');
		var keyCount:Int = 4;
		if (Options.get.fnf_sync == 2 && map.song.keyCount != null)
			keyCount = map.song.keyCount;
		else if (map.song.mania != null)
			keyCount = map.song.mania + (Options.get.fnf_sync == 1 ? -1 : 0);

		Debug.log.trace('Setting values of osu map...');
		var osuformat:Array<String> = [
			'osu file format v14',
			'',
			'[General]',
			'AudioFilename: ${Options.get.osu_values.audioFilename}',
			'Mode: 3',
			'',
			'[Metadata]',
			'Title:${Std.string(map.song.song).replace('-', ' ')}',
			'Artist:${Options.get.osu_values.artist}',
			'Creator:${Options.get.osu_values.creator}',
			'Version:${Options.get.osu_values.version}',
			'',
			'[Difficulty]',
			'HPDrainRate:${Options.get.osu_values.hpDrainRate}',
			'CircleSize:${Options.get.to_key}',
			'',
			'[TimingPoints]',
			'0,${60000 / map.song.bpm},4,0,0,${Options.get.osu_values.volumeHitsound},1,0',
			//'0,0,"bg.jpg",0,0',
			'',
			'[HitObjects]'
		];
		var notes:Array<Dynamic> = [];
		var int:Int = 0;
		var osuformat_length:Int = osuformat.length;
		Debug.log.trace('Converting notes...');
		if (Options.get.to_key != keyCount)
		{
			Debug.log.warn('Map have ${keyCount} keys, converting to ${Options.get.to_key} key...');
			map = fnf_to_fnf(map, keyCount);
		}

		var osu_side = Options.get.osu_side;
		switch (osu_side)
		{
			case 1:
				Debug.log.trace('Current side: BF');
			case 2:
				Debug.log.trace('Current side: Opponent');
			default:
				Debug.log.trace('Current side: All (BF and opponent)');
		}
		for (i in 0...map.song.notes.length)
			for (i1 in 0...map.song.notes[i].sectionNotes.length)
			{
				if (map.song.notes[i].sectionNotes[i1][1] >= 0)
				{
					//var note = convertNote(map.song.notes[i].sectionNotes[i1][1], Options.get.to_key, false);
					var note = 0;
					switch (osu_side)
					{
						case 1:
							if (map.song.notes[i].mustHitSection)
							{
								if (map.song.notes[i].sectionNotes[i1][1] < keyCount)
								{
									note = convertNote(map.song.notes[i].sectionNotes[i1][1], Options.get.to_key, false);
									//Debug.log.trace(map.song.notes[i].sectionNotes[i1][1] + ' -> ' + note);
									var timing = Std.parseInt(map.song.notes[i].sectionNotes[i1][0]);
									var isHold = 1;
									var timing_hold = '0';
									if (map.song.notes[i].sectionNotes[i1][2] > 0)
									{
										isHold = 128;
										timing_hold = '${Std.parseInt(map.song.notes[i].sectionNotes[i1][0]) + Std.parseInt(map.song.notes[i].sectionNotes[i1][2])}:0';
									}
									notes[int] = '${note},192,${timing},${isHold},0,${timing_hold}:0:0:0:';
									int++;
								}
							}
							else
							{
								if (map.song.notes[i].sectionNotes[i1][1] > keyCount)
								{
									note = convertNote(map.song.notes[i].sectionNotes[i1][1] - keyCount, Options.get.to_key, false);
									//Debug.log.trace(map.song.notes[i].sectionNotes[i1][1] + ' -> ' + note);
									var timing = Std.parseInt(map.song.notes[i].sectionNotes[i1][0]);
									var isHold = 1;
									var timing_hold = '0';
									if (map.song.notes[i].sectionNotes[i1][2] > 0)
									{
										isHold = 128;
										timing_hold = '${Std.parseInt(map.song.notes[i].sectionNotes[i1][0]) + Std.parseInt(map.song.notes[i].sectionNotes[i1][2])}:0';
									}
									notes[int] = '${note},192,${timing},${isHold},0,${timing_hold}:0:0:0:';
									int++;
								}
							}
						case 2:
							if (map.song.notes[i].mustHitSection)
							{
								if (map.song.notes[i].sectionNotes[i1][1] > keyCount)
								{
									note = convertNote(map.song.notes[i].sectionNotes[i1][1] - keyCount, Options.get.to_key, false);
									//Debug.log.trace(map.song.notes[i].sectionNotes[i1][1] + ' -> ' + note);
									var timing = Std.parseInt(map.song.notes[i].sectionNotes[i1][0]);
									var isHold = 1;
									var timing_hold = '0';
									if (map.song.notes[i].sectionNotes[i1][2] > 0)
									{
										isHold = 128;
										timing_hold = '${Std.parseInt(map.song.notes[i].sectionNotes[i1][0]) + Std.parseInt(map.song.notes[i].sectionNotes[i1][2])}:0';
									}
									notes[int] = '${note},192,${timing},${isHold},0,${timing_hold}:0:0:0:';
									int++;
								}
							}
							else
							{
								if (map.song.notes[i].sectionNotes[i1][1] < keyCount)
								{
									note = convertNote(map.song.notes[i].sectionNotes[i1][1], Options.get.to_key, false);
									//Debug.log.trace(map.song.notes[i].sectionNotes[i1][1] + ' -> ' + note);
									var timing = Std.parseInt(map.song.notes[i].sectionNotes[i1][0]);
									var isHold = 1;
									var timing_hold = '0';
									if (map.song.notes[i].sectionNotes[i1][2] > 0)
									{
										isHold = 128;
										timing_hold = '${Std.parseInt(map.song.notes[i].sectionNotes[i1][0]) + Std.parseInt(map.song.notes[i].sectionNotes[i1][2])}:0';
									}
									notes[int] = '${note},192,${timing},${isHold},0,${timing_hold}:0:0:0:';
									int++;
								}
							}
						default:
							note = convertNote(map.song.notes[i].sectionNotes[i1][1], Options.get.to_key, false);
							//Debug.log.trace(map.song.notes[i].sectionNotes[i1][1] + ' -> ' + note);
							var timing = Std.parseInt(map.song.notes[i].sectionNotes[i1][0]);
							var isHold = 1;
							var timing_hold = '0';
							if (map.song.notes[i].sectionNotes[i1][2] > 0)
							{
								isHold = 128;
								timing_hold = '${Std.parseInt(map.song.notes[i].sectionNotes[i1][0]) + Std.parseInt(map.song.notes[i].sectionNotes[i1][2])}:0';
							}
							notes[int] = '${note},192,${timing},${isHold},0,${timing_hold}:0:0:0:';
							int++;
					}
				}
			}
		for (i in 0...notes.length)
			osuformat[osuformat_length + i] = notes[i];

		//FileAPI.file.saveFile('${saveto}', string);
		Debug.log.trace('Successfully converted ${getMapOptions(osuformat, 'Artist') != null ? getMapOptions(osuformat, 'Artist') : getMapOptions(osuformat, 'ArtistUnicode')} - ${getMapOptions(osuformat, 'Title') != null ? getMapOptions(osuformat, 'Title') : getMapOptions(osuformat, 'TitleUnicode')} (${getMapOptions(osuformat, 'Creator')}) [${getMapOptions(osuformat, 'Version')}] from FNF to osu!mania!');

		return osuformat;
	}

	function osu_to_osu(map_:Array<Dynamic>)
	{
		Debug.log.trace('Getting osu! map data...');
		Debug.log.trace('Found ${map_.length - (findLine(map_, '[HitObjects]') + 1)} notes...');

		var curMode:Int = Std.parseInt(getMapOptions(map_, 'Mode'));
		if (curMode != 3)
		{
			var osuModes:Array<String> = [
				'standard osu',
				'osu!taiko',
				'osu!catch',
				'osu!mania'
			];
			Debug.log.error('Converter supports only osu!mania mode! You have a ${osuModes[curMode]} beatmap.');
			return null;
		}

		Debug.log.trace('Setting key count...');
		var from_key:Int = Std.parseInt(getMapOptions(map_, 'CircleSize'));
		var to_key:Int = 0;
		if (Options.get.to_key < 1 || Options.get.to_key > Options.func.algLength())
		{
			Debug.log.warn('Key count ${Options.get.to_key < 1 ? 'less than 1' : 'more than ${Options.func.algLength()}'}, returning ${Options.get.key_default[1]}...');
			to_key = Options.get.key_default[1];
		}
		else
			to_key = Options.get.to_key;

		if (from_key == to_key)
		{
			Debug.log.error('Chart/Map already is ${from_key} key!');
			return null;
		}

		Debug.log.trace('Found ${map_.length - (findLine(map_, '[HitObjects]') + 1)} notes...');

		var map:Array<Dynamic> = [];
		for (i in 0...findLine(map_, '[HitObjects]') + 1)
			map[i] = map_[i];
		for (i in findLine(map_, '[HitObjects]') + 1...map_.length)
			map[i] = map_[i].split(',');

		Debug.log.trace('Converting notes...');
		for (i in findLine(map, '[HitObjects]') + 1...map.length)
		{
			//trace(map[i] + ' | ' + map[i].length);
			var alg_var:Dynamic = Options.func.alg(from_key, to_key)[convertNote(map[i][0], from_key, true)];
			if (alg_var.length > 1)
				map[i][0] = convertNote(Std.parseInt(alg_var[Std.random(alg_var.length)]), to_key, false);
			else if (alg_var.length == 1)
				map[i][0] = convertNote(Std.parseInt(alg_var[0]), to_key, false);
			else
				map[i][0] = convertNote(Std.parseInt(alg_var), to_key, false);
			map[i] = toString(map[i], ',');
			map[i] = map[i].substring(0, map[i].lastIndexOf(',')); // removing useless comma in end of line
		}

		map[findLine(map, 'CircleSize')] = 'CircleSize:${to_key}';
		map[findLine(map, 'BeatmapID')] = 'BeatmapID:0';
		map[findLine(map, 'BeatmapSetID')] = 'BeatmapSetID:-1';

		Debug.log.trace('Successfully converted osu!mania beatmap ${getMapOptions(map, 'Artist') != null ? getMapOptions(map, 'Artist') : getMapOptions(map, 'ArtistUnicode')} - ${getMapOptions(map, 'Title') != null ? getMapOptions(map, 'Title') : getMapOptions(map, 'TitleUnicode')} (${getMapOptions(map, 'Creator')}) [${getMapOptions(map, 'Version')}] from ${from_key}k to ${to_key}k!');

		return map;
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

	function convertNote(from_note:Dynamic, keyCount:Int, fromosu:Bool = true):Int
	{
		from_note = Std.parseInt(from_note);
		var note_array:Array<Dynamic> = [
			[
				numberArray(0, 511) // 0 key
			],
			[
				numberArray(0, 511),
				numberArray(0, 511)
			],
			[
				numberArray(0, 256), numberArray(257, 511),
				numberArray(0, 256), numberArray(257, 511)
			],
			[
				numberArray(0, 169), numberArray(170, 340), numberArray(341, 511),
				numberArray(0, 169), numberArray(170, 340), numberArray(341, 511)
			],
			[
				numberArray(0, 127), numberArray(128, 255), numberArray(256, 383), numberArray(384, 511), // 4 key bf
				numberArray(0, 127), numberArray(128, 255), numberArray(256, 383), numberArray(384, 511) // 4 key opponent
			],
			[
				numberArray(0, 101), numberArray(102, 203), numberArray(204, 306), numberArray(307, 408), numberArray(409, 511),
				numberArray(0, 101), numberArray(102, 203), numberArray(204, 306), numberArray(307, 408), numberArray(409, 511)
			],
			[
				numberArray(0, 84), numberArray(85, 169), numberArray(170, 255), numberArray(256, 340), numberArray(341, 425), numberArray(426, 511),
				numberArray(0, 84), numberArray(85, 169), numberArray(170, 255), numberArray(256, 340), numberArray(341, 425), numberArray(426, 511)
			],
			[
				numberArray(0, 72), numberArray(73, 145), numberArray(146, 218), numberArray(219, 291), numberArray(292, 364), numberArray(365, 437), numberArray(438, 511),
				numberArray(0, 72), numberArray(73, 145), numberArray(146, 218), numberArray(219, 291), numberArray(292, 364), numberArray(365, 437), numberArray(438, 511)
			],
			[
				numberArray(0, 63), numberArray(64, 127), numberArray(128, 191), numberArray(192, 255), numberArray(256, 319), numberArray(320, 383), numberArray(384, 447), numberArray(448, 511),
				numberArray(0, 63), numberArray(64, 127), numberArray(128, 191), numberArray(192, 255), numberArray(256, 319), numberArray(320, 383), numberArray(384, 447), numberArray(448, 511)
			],
			[
				numberArray(0, 56), numberArray(57, 113), numberArray(114, 170), numberArray(171, 227), numberArray(228, 284), numberArray(285, 341), numberArray(342, 398), numberArray(399, 455), numberArray(456, 511),
				numberArray(0, 56), numberArray(57, 113), numberArray(114, 170), numberArray(171, 227), numberArray(228, 284), numberArray(285, 341), numberArray(342, 398), numberArray(399, 455), numberArray(456, 511)
			]
		];

		if (fromosu)
		{
			for (i in 0...note_array[keyCount].length)
				for (i2 in 0...note_array[keyCount][i].length)
					if (note_array[keyCount][i][i2] == from_note)
						return i;
		}
		else
		{
			return note_array[keyCount][from_note][Std.int(note_array[keyCount][from_note].length / 2)];
		}

		//var dgdfg = Std.int(512 / keyCount);

		Debug.log.error('Note ${from_note} not found in array!');
		return 0;
	}

	function findLine(array_:Array<Dynamic>, find:String, fromLine:Int = 0, toLine:Int = null):Int
	{
		var array:Array<String> = [];
		for (i in 0...array_.length)
			array[i] = Std.string(array_[i]);

		if (toLine == null)
			toLine = array.length;

		for (i in fromLine...array.length)
			if (array[i].contains(find))
				return i;

		Debug.log.error('String ${find} not found!');
		return -1;
	}

	function osuLine(string:String, int:Int, split:String):Dynamic
	{
		var array:Array<String> = string.split(split);
		return array[int];
	}

	public function getMapOptions(map_:Array<Dynamic>, name:String)
	{
		var map:Array<String> = [];
		for (i in 0...map_.length)
			map[i] = Std.string(map_[i]);

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

	inline public function toString(array_:Array<Dynamic>, split:String = '\n')
	{
		var array:Array<String> = [];
		for (i in 0...array_.length)
			array[i] = Std.string(array_[i]);

		var string:String = '';
		for (i in 0...array.length)
		{
			string += array[i] + split;
		}
		return string;
	}
}

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