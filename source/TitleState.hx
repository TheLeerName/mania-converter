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
		checkFolders();
		FlxTransitionableState.skipNextTransOut = true;
		FlxTransitionableState.skipNextTransIn = true;

		Debug.log.trace('Starting version ${FileAPI.file.projectXML('version')}...');

		Options.func.createAlgorithm();
		#if desktop
		initializeCMD();
		#end

		if (!Options.get.osu_convert)
		{
			Options.get.from_file += '.json';
			Options.get.to_file += '.json';
		}
		else
		{
			Options.get.from_file += '.osu';
			Options.get.to_file += '.json';
		}

		if (Options.get.osu_convert)
			Osu.parser.convert(FileAPI.file.parseTXT(Options.get.from_file), Options.get.to_file);
		else
			FNF.parser.convert(FileAPI.file.parseJSON(Options.get.from_file), Options.get.to_file);
		FileAPI.file.closeWindow();
		return;

		super.create();
	}

	#if desktop
	var sysargs:Array<String> = Sys.args();
	inline function args_bool(string:String, int:Int):Bool
	{
		return sysargs[int].startsWith(string);
	}
	inline function args_get(what_remove:String, int:Int):String
	{
		return sysargs[int].replace(what_remove, '').trim();
	}

	function initializeCMD()
	{
		var damn_bulls:Array<Bool> = [false, false, false, false, false];
		for (i in 0...sysargs.length)
		{
			if (args_bool('-path:', i) && !damn_bulls[0])
			{
				Options.get.from_file = args_get('-path:', i);
				damn_bulls[0] = true;
			}

			if (args_bool('-saveto:', i) && !damn_bulls[1])
			{
				Options.get.to_file = args_get('-saveto:', i);
				damn_bulls[1] = true;
			}

			if (args_bool('-fromosu:', i) && !damn_bulls[2])
			{
				switch (args_get('-fromosu:', i))
				{
					case '1' | 'true' | 'y' | 'yes':
						Options.get.osu_convert = true;
					default:
						Options.get.osu_convert = false;
				}
				damn_bulls[2] = true;
			}
			if (!args_bool('-fromosu:', i) && !damn_bulls[2])
				Options.get.osu_convert = false;

			if (args_bool('-sync', i) && !damn_bulls[3])
			{
				switch (args_get('-sync:', i))
				{
					case 'extrakeys' | 'extra_keys' | 'tposejank' | '0':
						Options.get.extra_keys_sync = true;
						Options.get.leather_sync = false;
					case 'leather' | 'leather_engine' | 'leatherengine' | '1':
						Options.get.extra_keys_sync = false;
						Options.get.leather_sync = true;
					default:
						Options.get.extra_keys_sync = false;
						Options.get.leather_sync = false;
				}
				damn_bulls[3] = true;
			}
			if (!args_bool('-sync:', i) && !damn_bulls[3])
			{
				Options.get.extra_keys_sync = false;
				Options.get.leather_sync = false;
			}

			if (args_bool('-key:', i) && !damn_bulls[4])
			{
				Options.get.to_key = Std.parseInt(args_get('-key:', i));
				damn_bulls[4] = true;
			}
		}
		var int:Int = 0;
		for (i in 0...damn_bulls.length) if (damn_bulls[i]) int++;
		if (int != 0) Debug.log.trace('Found ${int} command-line arguments');
	}
	#end
}