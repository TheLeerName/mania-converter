var file = require('./FileAPI.js');
var debug = require('./Debug.js');
var alg = require('./Algorithm.js');
var utils = require('./Utils.js');
var options = require('./Options.js');

exports.convert = function (path, mode)
{
	switch (parseInt(mode))
	{
		case 1:
			return file.stringify(osu_to_fnf(file.parseTXT(path)), '\t', false);
		case 2:
			var ha = fnf_to_osu(file.parseJSON(path));
			return [ha[0].join('\n'), ha[1]];
		case 3:
			var ha = osu_to_osu(file.parseTXT(path));
			return [ha[0].join('\n'), ha[1]];
		default:
			return file.stringify(fnf_to_fnf(file.parseJSON(path)), '\t', false);
	}
}

function random(max)
{
	return Math.floor(Math.random() * max);
}

function fnf_to_fnf(map, fromkey = 0)
{
	debug.trace('Getting FNF map data...');
	var value = 0;
	for (i = 0; i < map.song.notes.length; i++)
		value += map.song.notes[i].sectionNotes.length;
	debug.trace('Found ' + value + ' notes (include event notes)');

	var from_key = 0;
	if (fromkey == 0)
	{
		if (options.getOption('EngineSync') == 2)
		{
			var keys = [0, 0];
			if (map.song.keyCount == null)
				keys[0] = options.getOption('FromKeyDefault');
			else
				keys[0] = map.song.keyCount;

			if (map.song.playerKeyCount == null)
				keys[1] = options.getOption('FromKeyDefault');
			else
				keys[1] = map.song.playerKeyCount;

			if (keys[0] != keys[1])
				debug.error('Charts/maps with different numbers of keys not supported! (you have ${keys[0]} for opponent and ${keys[1]} for player)');
			else
				from_key = keys[0];
		}
		else
		{
			if (map.song.mania == null)
				from_key = options.getOption('FromKeyDefault');
			else
				from_key = map.song.mania + (options.getOption('EngineSync') == 1 ? 1 : 0);
		}
	}
	else
		from_key = fromkey;

	var to_key = 0;
	if (parseInt(options.getOption('Key')) < 1 || parseInt(options.getOption('Key')) > alg.algLength())
	{
		debug.warn('Key count ' + (parseInt(options.getOption('Key')) < 1 ? 'less than 1' : ('more than ' + alg.algLength())) + ', returning ' + options.getOption('ToKeyDefault') + '...');
		to_key = options.getOption('ToKeyDefault');
	}
	else
		to_key = parseInt(options.getOption('Key'));

	if (from_key == to_key)
		debug.error('Chart/Map already is ${from_key} key!');

	debug.trace('Converting notes...');
	for (let i = 0; i < map.song.notes.length; i++)
		for (let i1 = 0; i1 < map.song.notes[i].sectionNotes.length; i1++)
		{
			if (map.song.notes[i].sectionNotes[i1][1] >= 0)
			{
				var alg_var = alg.alg(from_key, to_key)[map.song.notes[i].sectionNotes[i1][1]];
				if (alg_var.length > 1)
					map.song.notes[i].sectionNotes[i1][1] = parseInt(alg_var[random(alg_var.length)]);
				else if (alg_var.length == 1)
					map.song.notes[i].sectionNotes[i1][1] = parseInt(alg_var[0]);
				else
					map.song.notes[i].sectionNotes[i1][1] = parseInt(alg_var);
			}
		}

	if (options.getOption('EngineSync') == 2)
	{
		map.song.keyCount = parseInt(to_key);
		map.song.playerKeyCount = parseInt(to_key);
	}
	else if (options.getOption('EngineSync') == 1)
		map.song.mania = parseInt(to_key - 1);
	else
		map.song.mania = parseInt(to_key);

	debug.trace('Successfully converted FNF map ' + map.song.song + ' from ' + from_key + ' keys to ' + to_key + ' keys!');
	return map;
}

function osu_to_fnf(map)
{
	var val = [false, false, false, false, false];
	if (options.getOption('mustHitSection') == '1' || options.getOption('mustHitSection') == 'true')
		val[0] = true;
	if (options.getOption('gfSection') == '1' || options.getOption('gfSection') == 'true')
		val[1] = true;
	if (options.getOption('changeBPM') == '1' || options.getOption('changeBPM') == 'true')
		val[2] = true;
	if (options.getOption('altAnim') == '1' || options.getOption('altAnim') == 'true')
		val[3] = true;
	if (options.getOption('needsVoices') == '1' || options.getOption('needsVoices') == 'true')
		val[4] = true;

	var json = { // copied from psych engine charting state
		song: {
			song: 'Sus',
			notes: [
				{
					typeOfSection: parseInt(options.getOption('typeOfSection')),
					lengthInSteps: parseInt(options.getOption('lengthInSteps')),
					sectionNotes: [],
					mustHitSection: val[0],
					gfSection: val[1],
					bpm: parseFloat(options.getOption('bpm')),
					changeBPM: val[2],
					altAnim: val[3]
				}
			],
			events: [],
			bpm: parseInt(options.getOption('bpm')),
			needsVoices: val[4],
			player1: options.getOption('player1'),
			player2: options.getOption('player2'),
			gfVersion: options.getOption('gfVersion'),
			speed: parseFloat(options.getOption('speed')),
			stage: options.getOption('stage'),
			mania: 4,
			playerKeyCount: 4,
			keyCount: 4,
			validScore: false
		}
	};

	debug.trace('Getting osu! map data...');
	debug.trace('Found ' + (map.length - utils.findLine(map, '[HitObjects]') + 1) + ' notes...');
	json.song.song = utils.getMapOptions(map, 'Title');
	if (json.song.song == null)
		json.song.song = utils.getMapOptions(map, 'TitleUnicode');
	if (json.song.song == null)
		json.song.song = 'Test';

	var curMode = parseInt(utils.getMapOptions(map, 'Mode'));
	if (curMode != 3)
	{
		var osuModes = [
			'standard osu',
			'osu!taiko',
			'osu!catch',
			'osu!mania'
		];
		debug.error('Converter supports only osu!mania mode! You have a ' + osuModes[curMode] + ' beatmap.');
	}

	var toData = [];
	var int = 0;
	var keyCount = parseInt(utils.getMapOptions(map, 'CircleSize'));
	if (keyCount > 10)
		debug.error('Converter from FNF supports not more 10 key! You have a ' + keyCount + ' key beatmap.');

	debug.trace('Parsing notes from osu!mania map...');
	for (let i = utils.findLine(map, '[HitObjects]') + 1; i < map.length - 1; i++)
	{
		toData[int] = [
			parseInt(utils.osuLine(map[i], 2, ',')),
			utils.convertNote(utils.osuLine(map[i], 0, ','), keyCount),
			parseFloat(utils.osuLine(map[i], 5, ',')) - parseFloat(utils.osuLine(map[i], 2, ','))
		];
		if (toData[int][2] < 0)
			toData[int][2] = 0; // removing negative values of hold notes
		int++;
	}
	int = 0;

	if ((utils.findLine(map, '[TimingPoints]') + 1) != null)
	{
		debug.trace('Calculating BPM...');
		json.song.bpm = parseInt(60000 / parseFloat(map[utils.findLine(map, '[TimingPoints]') + 1].split(',')[1]));
		json.song.notes[0].bpm = json.song.bpm;
	}
	else
		debug.warn('Calculating BPM failed');

	debug.trace('Placing notes to FNF map...');
	for (let i = 0; i < toData.length; i++)
		json.song.notes[0].sectionNotes[i] = toData[i];

	if (parseInt(options.getOption('Key')) != keyCount)
	{
		debug.warn('Map have ' + keyCount + ' keys, converting to ' + parseInt(options.getOption('Key')) + ' key...');
		json = fnf_to_fnf(json, keyCount);
	}

	json.song.keyCount = parseInt(options.getOption('Key'));
	json.song.playerKeyCount = parseInt(options.getOption('Key'));
	if (options.getOption('EngineSync') == 1)
		json.song.mania = parseInt(options.getOption('Key')) - 1;
	else
		json.song.mania = parseInt(options.getOption('Key'));

	var pathto = (utils.getMapOptions(map, 'Artist') != null ? utils.getMapOptions(map, 'Artist') : utils.getMapOptions(map, 'ArtistUnicode')) + ' - ' + (utils.getMapOptions(map, 'Title') != null ? utils.getMapOptions(map, 'Title') : utils.getMapOptions(map, 'TitleUnicode')) + ' (' + utils.getMapOptions(map, 'Creator') + ') [' + utils.getMapOptions(map, 'Version') + ']';
	debug.trace('Successfully converted ' + pathto + ' from osu!mania to FNF!');

	return json;
}

function fnf_to_osu(map)
{
	debug.trace('Getting FNF map data...');

	var value = 0;
	for (let i = 0; i < map.song.notes.length; i++)
		value += map.song.notes[i].sectionNotes.length;
	debug.trace('Found ' + value + ' notes (include event notes)');

	debug.trace('Setting key count of map...');
	var keyCount = 4;
	if (options.getOption('EngineSync') == 2 && map.song.keyCount != null)
		keyCount = map.song.keyCount;
	else if (map.song.mania != null)
	{
		if (options.getOption('EngineSync') == 1)
			keyCount = map.song.mania - 1;
		else
			keyCount = map.song.mania;
	}

	debug.trace('Setting values of osu map...');
	var osuformat = [
		'osu file format v14',
		'',
		'[General]',
		'AudioFilename: ' + options.getOption('AudioFileName'),
		'Mode: 3',
		'',
		'[Metadata]',
		'Title:' + map.song.song.toString().replace('-', ' '),
		'Artist:' + options.getOption('Artist'),
		'Creator:' + options.getOption('Creator'),
		'Version:' + options.getOption('Version'),
		'',
		'[Difficulty]',
		'HPDrainRate:' + options.getOption('HPDrainRate'),
		'CircleSize:' + parseInt(options.getOption('Key')),
		'',
		'[TimingPoints]',
		'0,' + (60000 / map.song.bpm) + ',4,0,0,' + options.getOption('VolumeHitSound') + ',1,0',
		//'0,0,"bg.jpg",0,0',
		'',
		'[HitObjects]'
	];
	var notes = [];
	var int = 0;
	var osuformat_length = osuformat.length;
	debug.trace('Converting notes...');
	if (parseInt(options.getOption('Key')) != keyCount)
	{
		debug.warn('Map have ' + keyCount + ' keys, converting to ' + parseInt(options.getOption('Key')) + ' key...');
		map = fnf_to_fnf(map, keyCount);
	}

	var osu_side = options.getOption('Side');
	switch (osu_side)
	{
		case 1:
			debug.trace('Current side: BF');
		case 2:
			debug.trace('Current side: Opponent');
		default:
			debug.trace('Current side: All (BF and opponent)');
	}
	for (let i = 0; i < map.song.notes.length; i++)
		for (let i1 = 0; i1 < map.song.notes[i].sectionNotes.length; i1++)
		{
			if (map.song.notes[i].sectionNotes[i1][1] >= 0)
			{
				var note = 0;
				switch (osu_side)
				{
					case 1:
						if (map.song.notes[i].mustHitSection)
						{
							if (map.song.notes[i].sectionNotes[i1][1] < keyCount)
							{
								note = utils.convertNote(map.song.notes[i].sectionNotes[i1][1], parseInt(options.getOption('Key')), false);
								var timing = parseInt(map.song.notes[i].sectionNotes[i1][0]);
								var isHold = 1;
								var timing_hold = '0';
								if (map.song.notes[i].sectionNotes[i1][2] > 0)
								{
									isHold = 128;
									timing_hold = (parseInt(map.song.notes[i].sectionNotes[i1][0]) + parseInt(map.song.notes[i].sectionNotes[i1][2])) + ':0';
								}
								notes[int] = note + ',192,' + timing + ',' + isHold + ',0,' + timing_hold + ':0:0:0:';
								int++;
							}
						}
						else
						{
							if (map.song.notes[i].sectionNotes[i1][1] > keyCount)
							{
								note = utils.convertNote(map.song.notes[i].sectionNotes[i1][1] - keyCount, parseInt(options.getOption('Key')), false);
								var timing = parseInt(map.song.notes[i].sectionNotes[i1][0]);
								var isHold = 1;
								var timing_hold = '0';
								if (map.song.notes[i].sectionNotes[i1][2] > 0)
								{
									isHold = 128;
									timing_hold = (parseInt(map.song.notes[i].sectionNotes[i1][0]) + parseInt(map.song.notes[i].sectionNotes[i1][2])) + ':0';
								}
								notes[int] = note + ',192,' + timing + ',' + isHold + ',0,' + timing_hold + ':0:0:0:';
								int++;
							}
						}
					case 2:
						if (map.song.notes[i].mustHitSection)
						{
							if (map.song.notes[i].sectionNotes[i1][1] > keyCount)
							{
								note = utils.convertNote(map.song.notes[i].sectionNotes[i1][1] - keyCount, parseInt(options.getOption('Key')), false);
								var timing = parseInt(map.song.notes[i].sectionNotes[i1][0]);
								var isHold = 1;
								var timing_hold = '0';
								if (map.song.notes[i].sectionNotes[i1][2] > 0)
								{
									isHold = 128;
									timing_hold = (parseInt(map.song.notes[i].sectionNotes[i1][0]) + parseInt(map.song.notes[i].sectionNotes[i1][2])) + ':0';
								}
								notes[int] = note + ',192,' + timing + ',' + isHold + ',0,' + timing_hold + ':0:0:0:';
								int++;
							}
						}
						else
						{
							if (map.song.notes[i].sectionNotes[i1][1] < keyCount)
							{
								note = utils.convertNote(map.song.notes[i].sectionNotes[i1][1], parseInt(options.getOption('Key')), false);
								var timing = parseInt(map.song.notes[i].sectionNotes[i1][0]);
								var isHold = 1;
								var timing_hold = '0';
								if (map.song.notes[i].sectionNotes[i1][2] > 0)
								{
									isHold = 128;
									timing_hold = (parseInt(map.song.notes[i].sectionNotes[i1][0]) + parseInt(map.song.notes[i].sectionNotes[i1][2])) + ':0';
								}
								notes[int] = note + ',192,' + timing + ',' + isHold + ',0,' + timing_hold + ':0:0:0:';
								int++;
							}
						}
					default:
						note = utils.convertNote(map.song.notes[i].sectionNotes[i1][1], parseInt(options.getOption('Key')), false);
						var timing = parseInt(map.song.notes[i].sectionNotes[i1][0]);
						var isHold = 1;
						var timing_hold = '0';
						if (map.song.notes[i].sectionNotes[i1][2] > 0)
						{
							isHold = 128;
							timing_hold = (parseInt(map.song.notes[i].sectionNotes[i1][0]) + parseInt(map.song.notes[i].sectionNotes[i1][2])) + ':0';
						}
						notes[int] = note + ',192,' + timing + ',' + isHold + ',0,' + timing_hold + ':0:0:0:';
						int++;
				}
			}
		}
	for (let i = 0; i < notes.length; i++)
		osuformat[osuformat_length + i] = notes[i];

	var pathto = (utils.getMapOptions(osuformat, 'Artist') != null ? utils.getMapOptions(osuformat, 'Artist') : utils.getMapOptions(osuformat, 'ArtistUnicode')) + ' - ' + (utils.getMapOptions(osuformat, 'Title') != null ? utils.getMapOptions(osuformat, 'Title') : utils.getMapOptions(osuformat, 'TitleUnicode')) + ' (' + utils.getMapOptions(osuformat, 'Creator') + ') [' + utils.getMapOptions(osuformat, 'Version') + ']';
	debug.trace('Successfully converted ' + pathto + ' from FNF to osu!mania!');

	return [osuformat, pathto];
}

function osu_to_osu(map_)
{
	debug.trace('Getting osu! map data...');
	debug.trace('Found ' + (map_.length - utils.findLine(map_, '[HitObjects]') + 1) + ' notes...');

	var curMode = parseInt(utils.getMapOptions(map_, 'Mode'));
	if (curMode != 3)
	{
		var osuModes = [
			'standard osu',
			'osu!taiko',
			'osu!catch',
			'osu!mania'
		];
		debug.error('Converter supports only osu!mania mode! You have a ' + osuModes[curMode] + ' beatmap.');
	}

	debug.trace('Setting key count...');
	var from_key = parseInt(utils.getMapOptions(map_, 'CircleSize'));
	if (from_key > 10)
		debug.error('Converter supports not more 10 key! You have a ' + keyCount + ' key beatmap.');
	var to_key = 0;
	if (parseInt(options.getOption('Key')) < 1 || parseInt(options.getOption('Key')) > alg.algLength())
	{
		debug.warn('Key count ' + (parseInt(options.getOption('Key')) < 1 ? 'less than 1' : ('more than ' + alg.algLength())) + ', returning ' + options.getOption('ToKeyDefault') + '...');
		to_key = options.getOption('ToKeyDefault');
	}
	else
		to_key = parseInt(options.getOption('Key'));

	if (from_key == to_key)
		debug.error('Chart/Map already is ' + from_key + ' key!');

	var map = [];
	for (let i = 0; i < utils.findLine(map_, '[HitObjects]') + 1; i++)
		map[i] = map_[i];
	for (let i = utils.findLine(map_, '[HitObjects]') + 1; i < map_.length; i++)
		map[i] = map_[i].split(',');

	debug.trace('Converting notes...');
	for (let i = utils.findLine(map, '[HitObjects]') + 1; i < map.length - 1; i++)
	{
		var alg_var = alg.alg(from_key, to_key)[utils.convertNote(map[i][0], from_key, true)];
		if (alg_var.length > 1)
			map[i][0] = utils.convertNote(parseInt(alg_var[random(alg_var.length)]), to_key, false);
		else if (alg_var.length == 1)
			map[i][0] = utils.convertNote(parseInt(alg_var[0]), to_key, false);
		else
			map[i][0] = utils.convertNote(parseInt(alg_var), to_key, false);
		map[i] = map[i].join(',');
	}

	map[utils.findLine(map, 'CircleSize')] = 'CircleSize:' + to_key;
	if (utils.findLine(map, 'BeatmapID') != -1)
		map[utils.findLine(map, 'BeatmapID')] = 'BeatmapID:0';
	else
		map[utils.findLine(map, 'Version') + 1] = 'BeatmapID:0';
	
	if (utils.findLine(map, 'BeatmapSetID') != -1)
		map[utils.findLine(map, 'BeatmapSetID')] = 'BeatmapSetID:-1';
	else
		map[utils.findLine(map, 'BeatmapID') + 1] = 'BeatmapSetID:-1';

	var pathto = (utils.getMapOptions(map, 'Artist') != null ? utils.getMapOptions(map, 'Artist') : utils.getMapOptions(map, 'ArtistUnicode')) + ' - ' + (utils.getMapOptions(map, 'Title') != null ? utils.getMapOptions(map, 'Title') : utils.getMapOptions(map, 'TitleUnicode')) + ' (' + utils.getMapOptions(map, 'Creator') + ') [' + utils.getMapOptions(map, 'Version') + ']';
	debug.trace('Successfully converted osu!mania beatmap ' + pathto + ' from ' + from_key + 'k to ' + to_key + 'k!');

	return [map, pathto];
}