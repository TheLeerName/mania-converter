var file = require('./FileAPI.js');
var debug = require('./Debug.js');
var utils = require('./Utils.js');

exports.getOption = function(name/*, category = null*/) {return getOption(name);}
function getOption(name/*, category = null*/)
{
	var arg = cmd(name);
	if (arg != 228)
		return arg;

	var map = file.parseTXT('options.ini');
	//var cat = 0;
	//if (category != null)
		//cat = findLine(map_, '[' + category +']');

	for (let i = /*cat*/0; i < map.length; i++)
	{
		if (map[i].toLowerCase().trim().startsWith(name.toLowerCase().trim()))
		{
			map[i] = map[i].substring(map[i].indexOf(':') + 1);
			if (map[i].includes(' |:| '))
				map[i] = map[i].substring(0, map[i].indexOf(' |:| '));
			map[i] = map[i].trim();
			return map[i];
		}
	}

	debug.error('Option ' + name + ' not found!');
}

function cmd(name)
{
	var args = process.argv;
	for (let i = 0; i < args.length; i++)
		if (args[i].toLowerCase().trim().startsWith('-' + name.toLowerCase().trim() + ':'))
			return args[i].substring(args[i].indexOf(':') + 1).trim();
	return 228;
}
exports.checkFirstCMD = function()
{
	var appname = 'mccmd'; // PLEASE NOT RENAME IT
	var arg = process.argv;
	for (let i = 0; i < arg.length; i++)
		if (arg[i].toLowerCase().includes(appname))
			return i + 1;
	return 0;
}

var latestFormatVersion = 6;
exports.checkOptionsINI = function() {return checkOptionsINI();}
function checkOptionsINI()
{
	var optfile = [
		'mc options v2',
		'',
		'[General]',
		'FileInput:beatmap',
		'FileOutput:beatmap-converted',
		'Mode:0',
		'Key:6',
		'EngineSync:0',
		'Side:1',
		'',
		'[Friday Night Funkin\' Values]',
		'player1:bf',
		'player2:pico',
		'gfVersion:gf',
		'stage:stage',
		'speed:3',
		'bpm:150',
		'needsVoices:0',
		'gfSection:0',
		'lengthInSteps:160000',
		'altAnim:0',
		'typeOfSection:0',
		'changeBPM:0',
		'mustHitSection:1',
		'',
		'[osu!mania values]',
		'AudioFileName:audio.mp3',
		'Artist:ManiaConverter',
		'Creator:ManiaConverter',
		'Version:ManiaConverter',
		'HPDrainRate:8',
		'VolumeHitSound:20',
		'',
		'[Misc]',
		'FromKeyDefault:4',
		'ToKeyDefault:6',
		'',
		'',
		'/*			OPTIONS GUIDE (with default values)		*/',
		'FileInput:beatmap |:| for name of chart/map before converting.',
		'FileOutput:beatmap-converted |:| for name of chart/map after converting, in mode 2 or 3 you can choose folder, just type / in end of line.',
		'Mode:0 |:| for switch in converter modes, 0 or fnf = FNF (converting from N key to N key), 1 or tofnf or to_fnf = osu!mania to FNF, 2 or toosu or to_osu = FNF to osu!mania, 3 or osu = osu!mania (converting from N key to N key).',
		'Key:6 |:| for a REAL number of keys you want to convert to.',
		'EngineSync:0 |:| for sync with some FNF engines, 1 or tposejank or extrakeys or extra_keys = tposejank\'s Extra Keys Mod (real key count - 1, example 4 keys is mania = 3), 2 or leather or leatherengine or leather_engine = Leather128\'s Leather Engine (mania = (keyCount && playerKeyCount)), 0 = default.',
		'Side:1 |:| for switch in FNF sides, 0 = player1 (BF) and player2 (Opponent), 1 or player1 or bf = player1 (BF), 2 or player2 or opponent = player2 (Opponent).',

		'player1:bf |:| for name of player1 (BF).',
		'player2:pico |:| for name of player2 (Opponent, Dad).',
		'gfVersion:gf |:| for name of GF.',
		'stage:stage |:| for name of stage.',
		'speed:3 |:| for scroll speed of notes.',
		'bpm:150 |:| for BPM of song.',
		'needsVoices:0 |:| 1 or true or y or yes = song uses Voices.ogg file.',
		'gfSection:0 |:| 1 or true = GF sings instead player2.',
		'lengthInSteps:160000 |:| not touch this if you not want crash osu!mania to fnf converting.',
		'altAnim:0 |:| 1 or true = characters uses alt anims.',
		'typeOfSection:0 |:| idk.',
		'changeBPM:0 |:| idk.',
		'mustHitSection:1 |:| 1 or true = cam follow to player1, any other values = cam follow to player2.',

		'AudioFileName:audio.mp3 |:| for name of audio file of song.',
		'Artist:ManiaConverter |:| for name of artist of song.',
		'Creator:ManiaConverter |:| for name of creator of chart/map.',
		'Version:Normal |:| for name of difficulty of map.',
		'HPDrainRate:8 |:| for rate of hp drain of map.',
		'VolumeHitSound:20 |:| for volume of hitsounds (20 = 20%).',

		'FromKeyDefault:4 |:| for default REAL number of keys, if you type value in ToKey less than 1 or more than value of algorithms.',
		'ToKeyDefault:6 |:| for default REAL number of keys, if in chart/map mania line is not exist.'
	];

	if (file.exists('options.json')) // mc options v1 (.json)
	{
		if (file.parseJSON('options.json') != 228)
		{
			var json = file.parseJSON('options.json');
			optfile[3] = fuck(optfile[3], json.file_paths[0]);
			optfile[4] = fuck(optfile[4], json.file_paths[1]);
			optfile[5] = fuck(optfile[5], json.converter_mode);
			optfile[6] = fuck(optfile[6], json.to_key);
			optfile[7] = fuck(optfile[7], json.fnf_sync);
			optfile[8] = fuck(optfile[8], json.osu_side);
			optfile[11] = fuck(optfile[11], json.fnf_values.player1);
			optfile[12] = fuck(optfile[12], json.fnf_values.player2);
			optfile[13] = fuck(optfile[13], json.fnf_values.gfVersion);
			optfile[14] = fuck(optfile[14], json.fnf_values.stage);
			optfile[15] = fuck(optfile[15], json.fnf_values.speed);
			optfile[16] = fuck(optfile[16], json.fnf_values.bpm);
			optfile[17] = fuck(optfile[17], json.fnf_values.needsVoices);
			optfile[18] = fuck(optfile[18], json.fnf_values.notes.gfSection);
			optfile[19] = fuck(optfile[19], json.fnf_values.notes.lengthInSteps);
			optfile[20] = fuck(optfile[20], json.fnf_values.notes.altAnim);
			optfile[21] = fuck(optfile[21], json.fnf_values.notes.typeOfSection);
			optfile[22] = fuck(optfile[22], json.fnf_values.notes.changeBPM);
			optfile[23] = fuck(optfile[23], json.fnf_values.notes.mustHitSection);
			optfile[26] = fuck(optfile[26], json.osu_values.audioFilename);
			optfile[27] = fuck(optfile[27], json.osu_values.artist);
			optfile[28] = fuck(optfile[28], json.osu_values.creator);
			optfile[29] = fuck(optfile[29], json.osu_values.version);
			optfile[30] = fuck(optfile[30], json.osu_values.hpDrainRate);
			//optfile[31] = fuck(optfile[31], json.osu_values.volumeHitSound); // i edited from 50 to 20
			optfile[34] = fuck(optfile[34], json.key_default[0]);
			optfile[35] = fuck(optfile[35], json.key_default[1]);

			file.deleteFile('options.json');
			debug.trace('Converting options from .json file to .ini completed!');
		}
		else
		{
			file.deleteFile('options.json');
			debug.warn('Converting options from .json file to .ini failed! (not valid json)');
		}
	}

	if (file.exists('options.ini'))
	{
		var optia = file.parseTXT('options.ini');
		var ver = parseInt(optia[0].replace('mc options v', ''));
		if (ver < latestFormatVersion)
		{
			optia[0] = 'mc options v' + latestFormatVersion;
			for (let i = 3; i < latestFormatVersion + 1; i++) if (ver < i) optia = changeVER(optia, i);
			debug.trace('Updating options.ini file to v' + latestFormatVersion + '...');
			file.saveFile('options.ini', optia.join('\n'));
		}
		return optia;
	}

	optfile[0] = 'mc options v' + latestFormatVersion;
	for (let i = 3; i < latestFormatVersion + 1; i++) optfile = changeVER(optfile, i);
	debug.trace('Creating options.ini file...');
	file.saveFile('options.ini', optfile.join('\n'));
	return optfile; // idk
}

function changeVER(optia, ver)
{
	switch(parseInt(ver))
	{
		case 3:
			addThing(optia, 'Mode', 'IgnoreNote:Hurt Note |:| for list a ignored notetypes split on comma. (for example, you want convert chart without damage notes)');
			break;
		case 4:
			deleteThing(optia, 'EngineSync');
			deleteThing(optia, 'typeOfSection');
			deleteThing(optia, 'changeBPM');
			deleteThing(optia, 'lengthInSteps');

			replaceThing(optia, 'gfVersion', 'player3:' + (file.exists('options.ini') ? getOption('gfVersion') : 'gf'), 1);
			replaceThing(optia, 'gfVersion', 'player3:gf |:| for name of GF.', 2);

			replaceThing(optia, 'gfSection', 'gfSection:0 |:| 1 or true or y or yes = GF sings instead player2.');
			replaceThing(optia, 'altAnim', 'altAnim:0 |:| 1 or true or y or yes = characters uses alt anims.');
			replaceThing(optia, 'mustHitSection', 'mustHitSection:1 |:| 1 or true or y or yes = cam follow to player1, any other values = cam follow to player2.');
			replaceThing(optia, 'Version', 'Version:Normal |:| for name of difficulty of map.'); // i dumb
			replaceThing(optia, 'bpm', 'bpm:150 |:| for BPM of song, now uses like a default value when bpm calculation error.'); // i dumb
			break;
		case 5:
			addThing(optia, 'Version', 'Source:Friday Night Funkin |:| for source of song.');
			addThing(optia, 'Source', 'Background:none |:| for background of song, leave "none" to disable it.');
			replaceThing(optia, 'HPDrainRate', 'HPDrainRate:8.5 |:| for rate of hp drain of map.');
			addThing(optia, 'HPDrainRate', 'OverallDifficulty:7 |:| for overall difficulty of map. (timing of notes)');
			replaceThing(optia, 'Key', 'Key:6 |:| for a REAL number of keys you want to convert to, leave "none" to disable change key count of map.');
			break;
		case 6:
			addThing(optia, 'IgnoreNote', 'Sensitivity:60 |:| for sensitivity of removing duplicate notes, leave 0 for removing notes ONLY with same timing and direction. (in milliseconds)');
			addThing(optia, 'Mode', 'LuaSave:0 |:| 1 or true or y or yes = chart/map saves for mod "Extra Keys with Lua For Psych Engine", supports from 1 key to 9 key.');
			break;
	}
	return optia;
}

function replaceThing(optia, option, optionname, mode = 0)
{
	if (mode == 1)
		optia.splice(utils.findLine(optia, option), 1, (optionname.includes(' |:| ') ? optionname.substring(0, optionname.lastIndexOf(' |:| ')) : optionname));
	else if (mode == 2)
		optia.splice(utils.findLine(optia, option, utils.findLine(optia, 'OPTIONS GUIDE (with default values)')), 1, optionname);
	else
	{
		optia.splice(utils.findLine(optia, option), 1, (optionname.includes(' |:| ') ? optionname.substring(0, optionname.lastIndexOf(' |:| ')) : optionname));
		optia.splice(utils.findLine(optia, option, utils.findLine(optia, 'OPTIONS GUIDE (with default values)')), 1, optionname);
	}
}
function addThing(optia, fromoption, optionname, mode = 0)
{
	if (mode == 1)
		optia.splice(utils.findLine(optia, fromoption) + 1, 0, (optionname.includes(' |:| ') ? optionname.substring(0, optionname.lastIndexOf(' |:| ')) : optionname));
	else if (mode == 2)
		optia.splice(utils.findLine(optia, fromoption, utils.findLine(optia, 'OPTIONS GUIDE (with default values)')) + 1, 0, optionname);
	else
	{
		optia.splice(utils.findLine(optia, fromoption) + 1, 0, (optionname.includes(' |:| ') ? optionname.substring(0, optionname.lastIndexOf(' |:| ')) : optionname));
		optia.splice(utils.findLine(optia, fromoption, utils.findLine(optia, 'OPTIONS GUIDE (with default values)')) + 1, 0, optionname);
	}
}
function deleteThing(optia, option, mode = 0)
{
	if (mode == 1)
		optia.splice(utils.findLine(optia, option), 1);
	else if (mode == 2)
		optia.splice(utils.findLine(optia, option, utils.findLine(optia, 'OPTIONS GUIDE (with default values)')), 1);
	else
	{
		optia.splice(utils.findLine(optia, option), 1);
		optia.splice(utils.findLine(optia, option, utils.findLine(optia, 'OPTIONS GUIDE (with default values)')), 1);
	}
}

function fuck(string, thing)
{
	if (thing == null)
		return string;
	else
		return string.substring(0, string.indexOf(':') + 1) + thing;
}