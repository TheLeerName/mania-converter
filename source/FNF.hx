package;

using StringTools;

class FNF
{
	public static var parser:FNF;

	public function convert(map:Dynamic, saveto:String)
	{
		Debug.log.trace('Getting FNF map data...');
		var value:Float = 0;
		for (i in 0...map.song.notes.length)
			value += map.song.notes[i].sectionNotes.length;
		Debug.log.trace('Found ${value} notes (include event notes)');

		var from_key:Dynamic = 0;
		if (Options.get.leather_sync)
		{
			var keys:Array<Int> = [0, 0];
			if (map.song.keyCount == null)
				keys[0] = Options.get.from_key_default;
			else
				keys[0] = map.song.keyCount;

			if (map.song.playerKeyCount == null)
				keys[1] = Options.get.from_key_default;
			else
				keys[1] = map.song.playerKeyCount;

			if (keys[0] != keys[1])
			{
				Debug.log.error('Charts/maps with different numbers of keys not supported! (you have ${keys[0]} for opponent and ${keys[1]} for player)');
				return;
			}
			else
				from_key = keys[0];

			Options.get.extra_keys_sync = false;
		}
		else
		{
			if (map.song.mania == null)
				from_key = Options.get.from_key_default;
			else
				from_key = map.song.mania + (Options.get.extra_keys_sync ? 1 : 0);
		}

		var to_key:Int = 0;
		if (Options.get.to_key < 1 || Options.get.to_key > Options.func.algLength())
		{
			Debug.log.warn('Key count ${Options.get.to_key < 1 ? 'less than 1' : 'more than ${Options.func.algLength()}'}, returning ${Options.get.to_key_default}...');
			to_key = Options.get.to_key_default;
		}
		else
			to_key = Options.get.to_key;

		if (from_key == to_key)
		{
			Debug.log.error('Chart/Map already is ${from_key} key!');
			return;
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

		if (Options.get.leather_sync)
		{
			map.song.keyCount = to_key;
			map.song.playerKeyCount = to_key;
		}
		else
			map.song.mania = to_key + (Options.get.extra_keys_sync ? -1 : 0);

		FileAPI.file.saveFile(saveto, FileAPI.file.stringify(map, "\t", false));

		Debug.log.trace('Successfully converted ${map.song.song} from ${from_key} keys to ${to_key} keys!');
	}
}