package;

import flixel.addons.ui.FlxUIState;
import flixel.addons.transition.FlxTransitionableState;
import lime.app.Application;

using StringTools;

class TitleState extends FlxUIState
{
	/*function checkFolders()
	{
		var folders:Array<String> = [
			"logs"
		];

		for (i in 0...folders.length) if (!FileAPI.file.isDir(folders[i]))
			{
				FileAPI.file.createDir(folders[i]);
				trace('Successfully created /${folders[i]} folder!');
			}
	}*/

	override function create()
	{
		//checkFolders();
		FlxTransitionableState.skipNextTransOut = true;
		FlxTransitionableState.skipNextTransIn = true;

		Debug.log.trace('Starting... (version ${Application.current.meta.get('version')})');

		var options:Options.OptionsJSON = Options.get.options();
		var alg:Array<Dynamic> = options.algorithm;

		if (!FileAPI.file.exists(options.from_file))
		{
			Debug.log.error('Path ${options.from_file} not found!');
			Application.current.window.close();
			return;
		}
		var json:Dynamic = FileAPI.file.parseJSON(options.from_file);

		var from_key:Dynamic = 0;
		if (json.song.mania == null)
			from_key = options.from_key_default;
		else
			from_key = json.song.mania + (options.extra_keys_sync ? 1 : 0);

		var to_key:Int = 0;
		if (options.to_key < 1 || options.to_key > options.algorithm.length - 1)
		{
			Debug.log.warn('Key count ${options.to_key < 1 ? 'less than 1' : 'more than ${options.algorithm.length - 1}'}, returning ${options.to_key_default}...');
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
					var alg_var:Dynamic = alg[from_key][to_key][json.song.notes[i].sectionNotes[i1][1]];
					if (alg_var.length > 1)
						json.song.notes[i].sectionNotes[i1][1] = alg_var[Std.random(alg_var.length)];
					else if (alg_var.length == 1)
						json.song.notes[i].sectionNotes[i1][1] = alg_var[0];
					else
						json.song.notes[i].sectionNotes[i1][1] = alg_var;
				}
			}

		var value:Float = 0;
		for (i in 0...json.song.notes.length)
			value += json.song.notes[i].sectionNotes.length;

		json.song.mania = to_key + (options.extra_keys_sync ? -1 : 0);
		FileAPI.file.saveFile(options.to_file, FileAPI.file.stringify(json, "\t", false));

		Debug.log.trace('Successfully converted ${json.song.song} from ${from_key} keys to ${to_key} keys (${value} notes, include events)!');
		Application.current.window.close();

		super.create();
	}
}