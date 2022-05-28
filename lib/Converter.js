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

function random(min, max)
{
	return Math.floor(Math.random() * max) + min;
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
		var keys = [parseInt(options.getOption('FromKeyDefault')), parseInt(options.getOption('FromKeyDefault'))];
		if (map.song.playerKeyCount != null)
			keys[0] = parseInt(map.song.playerKeyCount);
		if (map.song.keyCount != null)
			keys[1] = parseInt(map.song.keyCount);
		if (map.song.mania != null)
			keys = [parseInt(map.song.mania) + 1, parseInt(map.song.mania) + 1];

		if (keys[0] != keys[1])
			debug.error('Charts/maps with different numbers of keys not supported! (you have ' + keys[0] + ' for opponent and ' + keys[1] + ' for player)');
		else
			from_key = keys[0];
	}
	else
		from_key = fromkey;

	var to_key = 0;
	if (options.getOption('Key') != 'none')
	{
		if (parseInt(options.getOption('Key')) < 1 || parseInt(options.getOption('Key')) > alg.algLength())
		{
			debug.warn('Key count ' + (parseInt(options.getOption('Key')) < 1 ? 'less than 1' : ('more than ' + alg.algLength())) + ', returning ' + options.getOption('ToKeyDefault') + '...');
			to_key = parseInt(options.getOption('ToKeyDefault'));
		}
		else
			to_key = parseInt(options.getOption('Key'));
	}
	else
		to_key = from_key;

	/*if (from_key == to_key)
		debug.error('Chart/Map already is ' + from_key + ' key!');*/

	debug.trace('Converting notes...');

	var dNotes = 0;
	for (let i = 0; i < map.song.notes.length; i++)
	{
		map.song.notes[i].sectionNotes.sort(function(a, b) {
			return a[0] - b[0];
		});
		var l = utils.removeDuplicates(map.song.notes[i].sectionNotes, parseFloat(options.getOption('Sensitivity')));
		map.song.notes[i].sectionNotes = l[0];
		dNotes = dNotes + l[1];
	}
	if (dNotes > 0) debug.trace('Deleted ' + dNotes + ' duplicate notes!');
	
	var inarray = options.getOption('IgnoreNote').split(',');
	if (inarray.length > 0)
	{
		debug.trace('Ignoring some notes...');
		for (let sr = 0; sr < inarray.length; sr++)
		{
			inarray[sr] = inarray[sr].trim();
			for (let i = 0; i < map.song.notes.length; i++)
			{
				var int = 0;
				var goodnotes = [];
				for (let i1 = 0; i1 < map.song.notes[i].sectionNotes.length; i1++)
					if (map.song.notes[i].sectionNotes[int][3] != inarray[sr])
					{
						goodnotes.push(map.song.notes[i].sectionNotes[int]);
						int++;
					}
				map.song.notes[i].sectionNotes = goodnotes;
			}
		}
	}

	if (from_key != to_key)
	{
		var alg_ = alg.alg(from_key, to_key);
		for (let i = 0; i < map.song.notes.length; i++)
			for (let i1 = 0; i1 < map.song.notes[i].sectionNotes.length; i1++)
			{
				if (map.song.notes[i].sectionNotes[i1][1] >= 0 && map.song.notes[i].sectionNotes[i1][1] < from_key * 2) // no extra notes in chart!!! (otherwise crash)
				{
					//console.log(alg_);
					var alg_v = alg_[map.song.notes[i].sectionNotes[i1][1]];
					try {
						if (alg_v.length > 1)
							map.song.notes[i].sectionNotes[i1][1] = parseInt(alg_v[random(0, alg_v.length)]);
						else if (alg_v.length == 1)
							map.song.notes[i].sectionNotes[i1][1] = parseInt(alg_v[0]);
						else
							map.song.notes[i].sectionNotes[i1][1] = parseInt(alg_v);
					}
					catch(e){
						debug.error('A problem occurred in parsing algorithm (try check a keyCount or mania count in chart): ' + e);
					}
				}
			}
	}
	
	/*var cooltimecheck = 0;
	for (let i = 0; i < map.song.notes.length; i++)
		if (map.song.notes[i] != null)
			cooltimecheck = cooltimecheck + (4 * (1000 * 60 / (map.song.notes[i].changeBPM ? map.song.notes[i].bpm : map.song.bpm)));
	debug.trace('Sections:' + map.song.notes.length + ' | Time:' + cooltimecheck);
	map.song.time = cooltimecheck;*/

	map.song.keyCount = parseInt(to_key);
	map.song.playerKeyCount = parseInt(to_key);
	map.song.mania = parseInt(to_key) - 1;
	map.song.keyNumber = parseInt(to_key);

	map.song.generated_by = 'Mania Converter ' + utils.getVersion(); // hehe

	debug.trace('Successfully converted FNF map ' + map.song.song + ' from ' + from_key + ' keys to ' + to_key + ' keys!');
	return map;
}

function osu_to_fnf(map)
{
	var json = { // copied from psych engine charting state
		song: {
			song: 'Sus',
			notes: [],
			events: [],
			bpm: parseInt(options.getOption('bpm')),
			needsVoices: utils.parseBool(options.getOption('needsVoices')),
			player1: options.getOption('player1'),
			player2: options.getOption('player2'),
			gfVersion: options.getOption('player3'),
			speed: parseFloat(options.getOption('speed')),
			stage: options.getOption('stage'),
			mania: 3,
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
	//if (keyCount > 10)
		//debug.error('Converter from FNF supports not more 10 key! You have a ' + keyCount + ' key beatmap.');

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
		var bpm = 0;
		var bpmcount = 1;
		for (let i = utils.findLine(map, '[TimingPoints]'); i < utils.findLine(map, '[HitObjects]') - 1; i++)
			if (map[i].split(',')[6] == '1')
			{
				bpm = bpm + parseFloat(map[i].split(',')[1]);
				bpmcount++;
			}
		json.song.bpm = parseInt(bpm / bpmcount);
	}
	else
		debug.warn('Calculating BPM failed');

	debug.trace('Placing notes to FNF map...');
	/*for (let i = 0; i < toData.length; i++)
	{
		json.song.notes[0].sectionNotes[i] = toData[i]; // placing all notes in one section (very bad for charting state)
	}*/

	var sectnote = 0;
	for (let sect = 0;; sect++) // infinite loop xd
	{
		json.song.notes[sect] = {
			typeOfSection: 0,
			lengthInSteps: 16,
			sectionNotes: [],
			mustHitSection: utils.parseBool(options.getOption('mustHitSection')),
			gfSection: utils.parseBool(options.getOption('gfSection')),
			altAnim: utils.parseBool(options.getOption('altAnim'))
		};

		for (let note = 0; note < toData.length; note++)
		{
			if
			(
				toData[note][0] <= ((sect + 1) * (4 * (1000 * 60 / json.song.bpm))) &&
				toData[note][0] > ((sect) * (4 * (1000 * 60 / json.song.bpm)))
			)
			{
				json.song.notes[sect].sectionNotes[sectnote] = toData[note];
				sectnote++;
			}
		}
		sectnote = 0;

		if (toData[toData.length - 1] == json.song.notes[sect].sectionNotes[json.song.notes[sect].sectionNotes.length - 1])
			break; // or not? (check start of loop)
	}
	
	var dNotes = 0;
	for (let i = 0; i < json.song.notes.length; i++)
	{
		json.song.notes[i].sectionNotes.sort(function(a, b) {
			return a[0] - b[0];
		});
		var l = utils.removeDuplicates(json.song.notes[i].sectionNotes, parseFloat(options.getOption('Sensitivity')));
		json.song.notes[i].sectionNotes = l[0];
		dNotes = dNotes + l[1];
	}
	if (dNotes > 0) debug.trace('Deleted ' + dNotes + ' duplicate notes!');

	if (parseInt(options.getOption('Key')) != keyCount && !options.getOption('Key').startsWith('none'))
	{
		debug.warn('Map have ' + keyCount + ' keys, converting to ' + parseInt(options.getOption('Key')) + ' key...');
		json = fnf_to_fnf(json, keyCount);
		keyCount = parseInt(options.getOption('Key'));
	}

	json.song.keyCount = keyCount;
	json.song.playerKeyCount = keyCount;
	json.song.mania = keyCount - 1;
	json.song.keyNumber = keyCount;

	json.song.generated_by = 'Mania Converter ' + utils.getVersion(); // hehe

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
	if (map.song.playerKeyCount != null)
		keyCount = parseInt(map.song.playerKeyCount);
	if (map.song.keyCount != null)
		keyCount = parseInt(map.song.keyCount);
	if (map.song.keyNumber != null)
		keyCount = parseInt(map.song.keyNumber);
	if (map.song.mania != null)
		keyCount = parseInt(map.song.mania) + 1;
	
	var tokey = 4;
	if (options.getOption('Key').startsWith('none'))
		tokey = keyCount;
	else
		tokey = parseInt(options.getOption('Key'));
	
	if (tokey != keyCount)
	{
		debug.warn('Map have ' + keyCount + ' keys, converting to ' + parseInt(options.getOption('Key')) + ' key...');
		map = fnf_to_fnf(map, keyCount);
	}
	
	if (map.song.playerKeyCount != null)
		keyCount = parseInt(map.song.playerKeyCount);
	if (map.song.keyCount != null)
		keyCount = parseInt(map.song.keyCount);
	if (map.song.keyNumber != null)
		keyCount = parseInt(map.song.keyNumber);
	if (map.song.mania != null)
		keyCount = parseInt(map.song.mania) + 1;

	debug.trace('Setting values of osu map...');
	var osuformat = [
		'osu file format v14',
		'',
		'[General]',
		'AudioFilename: ' + options.getOption('AudioFileName'),
		'Mode: 3',
		'',
		'[Metadata]',
		'Title:' + utils.makeSongName(map.song.song.toString(), '-', ' '),
		'Artist:' + options.getOption('Artist'),
		'Creator:' + options.getOption('Creator'),
		'Version:' + options.getOption('Version'),
		'Source:' + options.getOption('Source'),
		'',
		'[Difficulty]',
		'HPDrainRate:' + options.getOption('HPDrainRate'),
		'OverallDifficulty:' + options.getOption('OverallDifficulty'),
		'CircleSize:' + tokey,
		'',
		'[TimingPoints]',
		'0,' + (60000 / parseFloat(map.song.bpm)) + ',4,0,0,' + options.getOption('VolumeHitSound') + ',1,0',
		'',
		'[HitObjects]'
	];

	// idk too buggy
	/*debug.trace('Calculating BPM...');
	var bpms = [];
	for (let sect = 0; sect < map.song.notes.length; sect++)
	{
		if
		(
			(map.song.notes[sect].changeBPM && map.song.notes[sect].bpm != null) ||
			(sect != 0 && map.song.notes[sect].bpm != null && map.song.notes[sect - 1].bpm != null && map.song.notes[sect - 1].bpm != map.song.notes[sect].bpm) ||
			(sect == 0 && map.song.notes[sect].bpm != null && map.song.bpm != map.song.notes[sect].bpm)
		)
			bpms.push([(sect + 1) * (4 * (1000 * 60 / (map.song.notes[sect].bpm))), map.song.notes[sect].bpm]);
	}

	if (bpms.length < 1)
		debug.warn('No BPM changes found');
	else
	{
		bpms.sort(function(a, b) {
			return a[0] - b[0];
		});
		var vhs = options.getOption('VolumeHitSound');
		for (let i = 0; i < bpms.length; i++)
			osuformat.splice((utils.findLine(osuformat, '[TimingPoints]') + i + 2), 0, (bpms[i][0] + ',' + (60000 / parseFloat(bpms[i][1])) + ',4,0,0,' + vhs + ',1,0'));
	}*/

	osuformat.splice(utils.findLine(osuformat, '[TimingPoints]') - 1, 0, '[Events]');
	osuformat.splice(utils.findLine(osuformat, '[Events]') + 1, 0, '0,0,"' + options.getOption('Background') + '",0,0');
	osuformat.splice(utils.findLine(osuformat, '[Events]'), 0, '');
	if (options.getOption('Background') == 'none' || !options.getOption('Background').includes('.'))
		osuformat.splice(utils.findLine(osuformat, '[Events]'), 3);

	// hehe its watermark!
	osuformat.splice(utils.findLine(osuformat, 'Source') + 1, 0, 'GeneratedBy:Mania Converter ' + utils.getVersion());

	debug.trace('Converting notes...');

	var inarray = options.getOption('IgnoreNote').split(',');
	if (inarray.length > 0)
	{
		debug.trace('Ignoring some notes...');
		for (let sr = 0; sr < inarray.length; sr++)
		{
			inarray[sr] = inarray[sr].trim();
			for (let i = 0; i < map.song.notes.length; i++)
			{
				var int1 = 0;
				var goodnotes = [];
				for (let i1 = 0; i1 < map.song.notes[i].sectionNotes.length; i1++)
					if (map.song.notes[i].sectionNotes[int1][3] != inarray[sr])
					{
						goodnotes.push(map.song.notes[i].sectionNotes[int1]);
						int1++;
					}
				map.song.notes[i].sectionNotes = goodnotes;
			}
		}
	}

	var dNotes = 0;
	for (let i = 0; i < map.song.notes.length; i++)
	{
		map.song.notes[i].sectionNotes.sort(function(a, b) {
			return a[0] - b[0];
		});
		var l = utils.removeDuplicates(map.song.notes[i].sectionNotes, parseFloat(options.getOption('Sensitivity')));
		map.song.notes[i].sectionNotes = l[0];
		dNotes = dNotes + l[1];
	}
	if (dNotes > 0) debug.trace('Deleted ' + dNotes + ' duplicate notes!');

	var notes = [];
	for (let i = 0; i < map.song.notes.length; i++)
		for (let i1 = 0; i1 < map.song.notes[i].sectionNotes.length; i1++)
			notes.push({
				time: parseInt(map.song.notes[i].sectionNotes[i1][0]),
				type: parseInt(map.song.notes[i].sectionNotes[i1][1]),
				sliderTime: parseInt(map.song.notes[i].sectionNotes[i1][2]),
				mustHitSection: map.song.notes[i].mustHitSection
			});
	notes.sort(function(a, b) {
		return a.time - b.time;
	});

	var osu_side = parseInt(options.getOption('Side'));
	switch (osu_side)
	{
		case 1:
			debug.trace('Current side: BF');
			break;
		case 2:
			debug.trace('Current side: Opponent');
			break;
		default:
			debug.trace('Current side: All (BF and opponent)');
	}
	
	var notes_om = [];
	for (let i = 0; i < notes.length; i++)
		if (notes[i].type >= 0 && notes[i].type < keyCount * 2)
		{
			//console.log(i + ' -> ' + notes[i]);
			switch (osu_side)
			{
				case 1:
					if (notes[i].mustHitSection)
					{
						if (notes[i].type < keyCount)
							notes_om.push(ok(notes[i], keyCount, false));
					}
					else
					{
						if (notes[i].type >= keyCount)
							notes_om.push(ok(notes[i], keyCount, true));
					}
					break;
				case 2:
					if (notes[i].mustHitSection)
					{
						if (notes[i].type >= keyCount)
							notes_om.push(ok(notes[i], keyCount, true));
					}
					else
					{
						if (notes[i].type < keyCount)
							notes_om.push(ok(notes[i], keyCount, false));
					}
					break;
				default:
					notes_om.push(ok(notes[i], keyCount, false));
			}
		}
	var osuformat_length = osuformat.length;
	for (let i = 0; i < notes_om.length; i++)
		osuformat[osuformat_length + i] = notes_om[i];

	var pathto = (utils.getMapOptions(osuformat, 'Artist') != null ? utils.getMapOptions(osuformat, 'Artist') : utils.getMapOptions(osuformat, 'ArtistUnicode')) + ' - ' + (utils.getMapOptions(osuformat, 'Title') != null ? utils.getMapOptions(osuformat, 'Title') : utils.getMapOptions(osuformat, 'TitleUnicode')) + ' (' + utils.getMapOptions(osuformat, 'Creator') + ') [' + utils.getMapOptions(osuformat, 'Version') + ']';
	debug.trace('Successfully converted ' + pathto + ' from FNF to osu!mania!');

	return [osuformat, pathto];
}

function ok(note, keyCount, minusKeyCount)
{
	var mkc = note.type;
	if (minusKeyCount)
		mkc = mkc - keyCount;
	var type = utils.convertNote(mkc, keyCount, false);
	var isHold = 1;
	var timing_hold = '0';
	if (note.sliderTime > 0)
	{
		isHold = 128;
		timing_hold = (note.time + note.sliderTime) + ':0';
	}
	return type + ',192,' + note.time + ',' + isHold + ',0,' + timing_hold + ':0:0:0:';
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
	//if (from_key > 10)
		//debug.error('Converter supports not more 10 key! You have a ' + keyCount + ' key beatmap.');
	var to_key = 0;
	if (options.getOption('Key') != 'none')
	{
		if (parseInt(options.getOption('Key')) < 1 || parseInt(options.getOption('Key')) > alg.algLength())
		{
			debug.warn('Key count ' + (parseInt(options.getOption('Key')) < 1 ? 'less than 1' : ('more than ' + alg.algLength())) + ', returning ' + options.getOption('ToKeyDefault') + '...');
			to_key = options.getOption('ToKeyDefault');
		}
		else
			to_key = parseInt(options.getOption('Key'));
	}
	else
		to_key = from_key;

	/*if (from_key == to_key)
		debug.error('Chart/Map already is ' + from_key + ' key!');*/

	var map = [];
	for (let i = 0; i < utils.findLine(map_, '[HitObjects]') + 1; i++)
		map[i] = map_[i];
	for (let i = utils.findLine(map_, '[HitObjects]') + 1; i < map_.length; i++)
		map[i] = map_[i].split(',');

	debug.trace('Converting notes...');

	var dNotes = 0;
	var l = utils.removeDuplicates(map, parseFloat(options.getOption('Sensitivity')), true, utils.findLine(map_, '[HitObjects]') + 1);
	map = l[0];
	dNotes = dNotes + l[1];
	if (dNotes > 0) debug.trace('Deleted ' + dNotes + ' duplicate notes!');

	if (from_key != to_key)
	{
		var alg_ = alg.alg(from_key, to_key);
		for (let i = utils.findLine(map, '[HitObjects]') + 1; i < map.length - 1; i++)
		{
			var alg_var = alg_[utils.convertNote(map[i][0], from_key, true)];
			if (alg_var.length > 1)
				map[i][0] = utils.convertNote(parseInt(alg_var[random(0, alg_var.length)]), to_key, false);
			else if (alg_var.length == 1)
				map[i][0] = utils.convertNote(parseInt(alg_var[0]), to_key, false);
			else
				map[i][0] = utils.convertNote(parseInt(alg_var), to_key, false);
			map[i] = map[i].join(',');
		}
	}

	map[utils.findLine(map, 'CircleSize')] = 'CircleSize:' + to_key;
	if (utils.findLine(map, 'BeatmapID') != -1)
		map[utils.findLine(map, 'BeatmapID')] = 'BeatmapID:0';
	else
		map[utils.findLine(map, 'Version') + 1] = 'BeatmapID:0';

	if (utils.findLine(map, 'BeatmapSetID') != -1)
		map[utils.findLine(map, 'BeatmapSetID')] = 'BeatmapSetID:-1';
	else if (utils.findLine(map, 'BeatmapID') != -1)
		map[utils.findLine(map, 'BeatmapID') + 1] = 'BeatmapSetID:-1';

	// hehe its watermark!
	if (utils.findLine(map, 'GeneratedBy') != -1)
		map[utils.findLine(map, 'GeneratedBy')] = 'GeneratedBy:Mania Converter ' + utils.getVersion();
	else if (utils.findLine(map, 'Source') != -1)
		map.splice(utils.findLine(map, 'Source') + 1, 0, 'GeneratedBy:Mania Converter ' + utils.getVersion());
	else if (utils.findLine(map, 'Version') != -1)
		map.splice(utils.findLine(map, 'Version') + 1, 0, 'GeneratedBy:Mania Converter ' + utils.getVersion());

	var pathto = (utils.getMapOptions(map, 'Artist') != null ? utils.getMapOptions(map, 'Artist') : utils.getMapOptions(map, 'ArtistUnicode')) + ' - ' + (utils.getMapOptions(map, 'Title') != null ? utils.getMapOptions(map, 'Title') : utils.getMapOptions(map, 'TitleUnicode')) + ' (' + utils.getMapOptions(map, 'Creator') + ') [' + utils.getMapOptions(map, 'Version') + ']';
	debug.trace('Successfully converted osu!mania beatmap ' + pathto + ' from ' + from_key + 'k to ' + to_key + 'k!');

	return [map, pathto];
}