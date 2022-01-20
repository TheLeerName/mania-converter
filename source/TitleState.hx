package;

import flixel.addons.ui.FlxUIState;
import flixel.addons.transition.FlxTransitionableState;
import lime.app.Application;

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

		Debug.log.trace('Starting version ${Application.current.meta.get('version')}...');

		Options.get.createAlgorithm();

		var options:Options.OptionsJSON = Options.get.options();
		if (!options.osu_convert)
		{
			options.from_file += '.json';
			options.to_file += '.json';
		}
		else
			options.from_file += '.osu';

		if (options.osu_convert)
		{
			OsuMania.parser.convert();
			Debug.log.trace('Successfully converted beatmap from osu!mania to fnf!');
			Application.current.window.close();
			return;
		}

		if (!FileAPI.file.exists(options.from_file))
		{
			Debug.log.error('Path ${options.from_file} not found!');
			Application.current.window.close();
			return;
		}
		var json:Dynamic = FileAPI.file.parseJSON(options.from_file);

		var from_key:Dynamic = 0;
		if (options.leather_sync)
		{
			var keys:Array<Int> = [0, 0];
			if (json.song.keyCount == null)
				keys[0] = options.from_key_default;
			else
				keys[0] = json.song.keyCount;

			if (json.song.playerKeyCount == null)
				keys[1] = options.from_key_default;
			else
				keys[1] = json.song.playerKeyCount;

			if (keys[0] != keys[1])
			{
				Debug.log.error('Charts/maps with different numbers of keys not supported! (you have ${keys[0]} for opponent and ${keys[1]} for player)');
				Application.current.window.close();
				return;
			}
			else
				from_key = keys[0];

			options.extra_keys_sync = false;
		}
		else
		{
			if (json.song.mania == null)
				from_key = options.from_key_default;
			else
				from_key = json.song.mania + (options.extra_keys_sync ? 1 : 0);
		}

		var to_key:Int = 0;
		if (options.to_key < 1 || options.to_key > Options.get.algLength())
		{
			Debug.log.warn('Key count ${options.to_key < 1 ? 'less than 1' : 'more than ${Options.get.algLength()}'}, returning ${options.to_key_default}...');
			to_key = options.to_key_default;
		}
		else
			to_key = options.to_key;

		if (from_key == to_key)
		{
			Debug.log.error('Chart/Map already is ${from_key} key!');
			Application.current.window.close();
			return;
		}

		Debug.log.trace('Converting notes...');
		for (i in 0...json.song.notes.length)
			for (i1 in 0...json.song.notes[i].sectionNotes.length)
			{
				if (json.song.notes[i].sectionNotes[i1][1] >= 0)
				{
					//var alg_var:Dynamic = alg[from_key][to_key][json.song.notes[i].sectionNotes[i1][1]];
					var alg_var:Dynamic = Options.get.alg(from_key, to_key)[json.song.notes[i].sectionNotes[i1][1]];
					if (alg_var.length > 1)
						json.song.notes[i].sectionNotes[i1][1] = Std.parseInt(alg_var[Std.random(alg_var.length)]);
					else if (alg_var.length == 1)
						json.song.notes[i].sectionNotes[i1][1] = Std.parseInt(alg_var[0]);
					else
						json.song.notes[i].sectionNotes[i1][1] = Std.parseInt(alg_var);
				}
			}

		var value:Float = 0;
		for (i in 0...json.song.notes.length)
			value += json.song.notes[i].sectionNotes.length;

		if (options.leather_sync)
		{
			json.song.keyCount = to_key;
			json.song.playerKeyCount = to_key;
		}
		else
			json.song.mania = to_key + (options.extra_keys_sync ? -1 : 0);

		FileAPI.file.saveFile(options.to_file, FileAPI.file.stringify(json, "\t", false));

		Debug.log.trace('Successfully converted ${json.song.song} from ${from_key} keys to ${to_key} keys (${value} notes, include events)!');
		Application.current.window.close();

		super.create();
	}
}