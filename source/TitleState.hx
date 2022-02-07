package;

import flixel.addons.ui.FlxUIState;
import flixel.addons.transition.FlxTransitionableState;

using StringTools;

class TitleState extends FlxUIState
{
	function checkFolders()
	{
		var folders:Array<String> = [
			"algorithms"
		];

		for (i in 0...folders.length) if (!FileAPI.file.isDir(folders[i]))
			{
				FileAPI.file.createDir(folders[i]);
				Debug.log.trace('Successfully created /${folders[i]} folder!');
			}
	}

	override function create()
	{
		FlxTransitionableState.skipNextTransOut = true;
		FlxTransitionableState.skipNextTransIn = true;
		Debug.log.trace('Starting version ${FileAPI.file.projectXML('version')}...');
		checkFolders();

		Options.func.createAlgorithm();
		#if desktop
		initializeCMD();
		#end

		var modes:Array<String> = [
			'FNF',
			'osu!mania to FNF',
			'FNF to osu!mania',
			'osu!mania'
		];
		Debug.log.trace('Current mode: ${modes[Options.get.converter_mode]}');
		switch (Options.get.converter_mode)
		{
			case 1:
				Options.get.file_paths[0] += '.osu';
				Options.get.file_paths[1] += '.json';
				FileAPI.file.saveFile(Options.get.file_paths[1], Converter.parser.convert(Options.get.file_paths[0], Options.get.converter_mode));
			case 2:
				Options.get.file_paths[0] += '.json';
				Options.get.file_paths[1] += '.osu';
				var map = Converter.parser.convert(Options.get.file_paths[0], Options.get.converter_mode);
				var path = '';
				var from:String = Std.string(Options.get.file_paths[1]).replace('.osu', '');
				if (from.endsWith('/'))
					path = '${from}${osuopt(map, 'Artist')} - ${osuopt(map, 'Title')} (${osuopt(map, 'Creator')}) [${osuopt(map, 'Version')}].osu';
				else
					path = '${osuopt(map, 'Artist')} - ${osuopt(map, 'Title')} (${osuopt(map, 'Creator')}) [${osuopt(map, 'Version')}].osu';
				FileAPI.file.saveFile(path, map);
			case 3:
				Options.get.file_paths[0] += '.osu';
				Options.get.file_paths[1] += '.osu';
				var map = Converter.parser.convert(Options.get.file_paths[0], Options.get.converter_mode);
				var path = '';
				var from:String = Std.string(Options.get.file_paths[1]).replace('.osu', '');
				if (from.endsWith('/'))
					path = '${from}${osuopt(map, 'Artist')} - ${osuopt(map, 'Title')} (${osuopt(map, 'Creator')}) [${osuopt(map, 'Version')}].osu';
				else
					path = '${osuopt(map, 'Artist')} - ${osuopt(map, 'Title')} (${osuopt(map, 'Creator')}) [${osuopt(map, 'Version')}].osu';
				FileAPI.file.saveFile(path, map);
			default:
				Options.get.file_paths[0] += '.json';
				Options.get.file_paths[1] += '.json';
				FileAPI.file.saveFile(Options.get.file_paths[1], Converter.parser.convert(Options.get.file_paths[0], Options.get.converter_mode));
		}
		FileAPI.file.closeWindow();
		return;

		super.create();
	}

	function osuopt(map:String, name:String) // reduction of "saveFile" line
	{
		return Converter.parser.getMapOptions(FileAPI.file.parseTXT(map, false), name);
	}

	#if desktop
	var sysargs:Array<String> = Sys.args();
	inline function args_bool(string:String, int:Int):Bool
	{
		return sysargs[int].startsWith(string.toLowerCase());
	}
	inline function args_get(what_remove:String, int:Int):String
	{
		return sysargs[int].replace(what_remove.toLowerCase(), '').trim();
	}

	function initializeCMD()
	{
		var damn_bulls:Array<Bool> = [];
		for (i in 0...22) damn_bulls[i] = false;

		for (i in 0...sysargs.length)
		{
			if (args_bool('-path:', i) && !damn_bulls[0])
			{
				Options.get.file_paths[0] = args_get('-path:', i);
				damn_bulls[0] = true;
			}


			if (args_bool('-saveto:', i) && !damn_bulls[1])
			{
				Options.get.file_paths[1] = args_get('-saveto:', i);
				damn_bulls[1] = true;
			}


			if (args_bool('-converter_mode:', i) && !damn_bulls[2])
			{
				Options.get.converter_mode = Std.parseInt(args_get('-converter_mode:', i));
				damn_bulls[2] = true;
			}
			if (!args_bool('-converter_mode:', i) && !damn_bulls[2])
				Options.get.converter_mode = 0;
			if (args_bool('-mode:', i) && !damn_bulls[2])
			{
				Options.get.converter_mode = Std.parseInt(args_get('-mode:', i));
				damn_bulls[2] = true;
			}
			if (!args_bool('-mode:', i) && !damn_bulls[2])
				Options.get.converter_mode = 0;


			if (args_bool('-osu_side:', i) && !damn_bulls[3])
			{
				Options.get.osu_side = Std.parseInt(args_get('-osu_side:', i));
				damn_bulls[3] = true;
			}
			if (!args_bool('-osu_side:', i) && !damn_bulls[3])
				Options.get.osu_side = 0;
			if (args_bool('-side:', i) && !damn_bulls[3])
			{
				Options.get.osu_side = Std.parseInt(args_get('-side:', i));
				damn_bulls[3] = true;
			}
			if (!args_bool('-side:', i) && !damn_bulls[3])
				Options.get.osu_side = 0;


			if (args_bool('-fnf_sync:', i) && !damn_bulls[4])
			{
				switch (args_get('-fnf_sync:', i))
				{
					default:
						Options.get.fnf_sync = 0;
					case 'extrakeys' | 'extra_keys' | 'tposejank' | '1':
						Options.get.fnf_sync = 1;
					case 'leather' | 'leather_engine' | 'leatherengine' | '2':
						Options.get.fnf_sync = 2;
				}
				damn_bulls[4] = true;
			}
			if (!args_bool('-fnf_sync:', i) && !damn_bulls[4])
				Options.get.fnf_sync = 0;
			if (args_bool('-sync:', i) && !damn_bulls[4])
			{
				switch (args_get('-sync:', i))
				{
					default:
						Options.get.fnf_sync = 0;
					case 'extrakeys' | 'extra_keys' | 'tposejank' | '1':
						Options.get.fnf_sync = 1;
					case 'leather' | 'leather_engine' | 'leatherengine' | '2':
						Options.get.fnf_sync = 2;
				}
				damn_bulls[4] = true;
			}
			if (!args_bool('-sync:', i) && !damn_bulls[4])
				Options.get.fnf_sync = 0;


			if (args_bool('-key:', i) && !damn_bulls[5])
			{
				Options.get.to_key = Std.parseInt(args_get('-key:', i));
				damn_bulls[5] = true;
			}


			if (args_bool('-audio:', i) && !damn_bulls[6])
			{
				Options.get.osu_values.audioFilename = args_get('-audio:', i);
				damn_bulls[6] = true;
			}
			if (args_bool('-audiofilename:', i) && !damn_bulls[6])
			{
				Options.get.osu_values.audioFilename = args_get('-audiofilename:', i);
				damn_bulls[6] = true;
			}


			if (args_bool('-artist:', i) && !damn_bulls[7])
			{
				Options.get.osu_values.artist = args_get('-artist:', i);
				damn_bulls[7] = true;
			}


			if (args_bool('-creator:', i) && !damn_bulls[8])
			{
				Options.get.osu_values.artist = args_get('-creator:', i);
				damn_bulls[8] = true;
			}


			if (args_bool('-version:', i) && !damn_bulls[9])
			{
				Options.get.osu_values.version = args_get('-version:', i);
				damn_bulls[9] = true;
			}
			if (args_bool('-difficulty:', i) && !damn_bulls[9])
			{
				Options.get.osu_values.version = args_get('-difficulty:', i);
				damn_bulls[9] = true;
			}


			if (args_bool('-hpdrainrate:', i) && !damn_bulls[10])
			{
				Options.get.osu_values.hpDrainRate = Std.parseFloat(args_get('-hpdrainrate:', i));
				damn_bulls[10] = true;
			}
			if (args_bool('-hpdrain:', i) && !damn_bulls[10])
			{
				Options.get.osu_values.hpDrainRate = Std.parseFloat(args_get('-hpdrain:', i));
				damn_bulls[10] = true;
			}
			if (args_bool('-hp:', i) && !damn_bulls[10])
			{
				Options.get.osu_values.hpDrainRate = Std.parseFloat(args_get('-hp:', i));
				damn_bulls[10] = true;
			}


			if (args_bool('-volumehitsound:', i) && !damn_bulls[11])
			{
				Options.get.osu_values.hpDrainRate = Std.parseInt(args_get('-volumehitsound:', i));
				damn_bulls[11] = true;
			}
			if (args_bool('-volumehit:', i) && !damn_bulls[11])
			{
				Options.get.osu_values.hpDrainRate = Std.parseInt(args_get('-volumehit:', i));
				damn_bulls[11] = true;
			}


			if (args_bool('-player1:', i) && !damn_bulls[12])
			{
				Options.get.fnf_values.player1 = args_get('-player1:', i);
				damn_bulls[12] = true;
			}


			if (args_bool('-player2:', i) && !damn_bulls[13])
			{
				Options.get.fnf_values.player2 = args_get('-player2:', i);
				damn_bulls[13] = true;
			}


			if (args_bool('-gfversion:', i) && !damn_bulls[14])
			{
				Options.get.fnf_values.gfVersion = args_get('-gfversion:', i);
				damn_bulls[14] = true;
			}
			if (args_bool('-gf:', i) && !damn_bulls[14])
			{
				Options.get.fnf_values.gfVersion = args_get('-gf:', i);
				damn_bulls[14] = true;
			}


			if (args_bool('-speed:', i) && !damn_bulls[15])
			{
				Options.get.fnf_values.speed = Std.parseFloat(args_get('-speed:', i));
				damn_bulls[15] = true;
			}


			if (args_bool('-musthitsection:', i) && !damn_bulls[16])
			{
				switch (args_get('-musthitsection:', i))
				{
					default:
						Options.get.fnf_values.notes.mustHitSection = false;
					case 'true' | 'y' | 'yes' | '1':
						Options.get.fnf_values.notes.mustHitSection = true;
				}
				damn_bulls[16] = true;
			}


			if (args_bool('-gfsection:', i) && !damn_bulls[17])
			{
				switch (args_get('-gfsection:', i))
				{
					default:
						Options.get.fnf_values.notes.gfSection = false;
					case 'true' | 'y' | 'yes' | '1':
						Options.get.fnf_values.notes.gfSection = true;
				}
				damn_bulls[17] = true;
			}


			if (args_bool('-changebpm:', i) && !damn_bulls[18])
			{
				switch (args_get('-changebpm:', i))
				{
					default:
						Options.get.fnf_values.notes.changeBPM = false;
					case 'true' | 'y' | 'yes' | '1':
						Options.get.fnf_values.notes.changeBPM = true;
				}
				damn_bulls[18] = true;
			}


			if (args_bool('-altanim:', i) && !damn_bulls[19])
			{
				switch (args_get('-altanim:', i))
				{
					default:
						Options.get.fnf_values.notes.altAnim = false;
					case 'true' | 'y' | 'yes' | '1':
						Options.get.fnf_values.notes.altAnim = true;
				}
				damn_bulls[19] = true;
			}


			if (args_bool('-bpm:', i) && !damn_bulls[20])
			{
				Options.get.fnf_values.bpm = Std.parseFloat(args_get('-bpm:', i));
				damn_bulls[20] = true;
			}


			if (args_bool('-needsvoices:', i) && !damn_bulls[21])
			{
				switch (args_get('-needsvoices:', i))
				{
					default:
						Options.get.fnf_values.needsVoices = false;
					case 'true' | 'y' | 'yes' | '1':
						Options.get.fnf_values.needsVoices = true;
				}
				damn_bulls[21] = true;
			}
			if (args_bool('-voices:', i) && !damn_bulls[21])
			{
				switch (args_get('-voices:', i))
				{
					default:
						Options.get.fnf_values.needsVoices = false;
					case 'true' | 'y' | 'yes' | '1':
						Options.get.fnf_values.needsVoices = true;
				}
				damn_bulls[21] = true;
			}


			if (args_bool('-stage:', i) && !damn_bulls[22])
			{
				Options.get.fnf_values.stage = args_get('-stage:', i);
				damn_bulls[22] = true;
			}
		}
		var int:Int = 0;
		for (i in 0...damn_bulls.length) if (damn_bulls[i]) int++;
		if (int != 0) Debug.log.trace('Found ${int} command-line arguments');
	}
	#end
}