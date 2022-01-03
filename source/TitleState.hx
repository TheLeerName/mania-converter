package;

import lime.app.Application;

using StringTools;

typedef Options = {
	var from_file:String;
	var to_file:String;
	var to_key:Int;
	var algorithm:Array<Dynamic>;
}

class TitleState extends StateWorker
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

		Debug.log.trace('Starting... (version ${Application.current.meta.get('version')})');

		var options:Options = {
			from_file: "beatmap.json",
			to_file: "beatmap-converted.json",
			to_key: 4,
			algorithm: [
					[],
					[
						[],
						[[0,1],   [2,3]],
						[[0,1,2],   [3,4,5]],
						[[0,1,2,3],   [4,5,6,7]],
						[[0,1,2,3,4],   [5,6,7,8,9]],
						[[0,1,2,3,4,5],   [6,7,8,9,10,11]],
						[[0,1,2,3,4,5,6],   [7,8,9,10,11,12,13]],
						[[0,1,2,3,4,5,6,7],   [8,9,10,11,12,13,14,15]],
						[[0,1,2,3,4,5,6,7,8],   [9,10,11,12,13,14,15,16,17]]
					],
					[
						[],
						[0, 0,   1, 1],
						[[0,1], 2,   [3,4], 5],
						[[0,1], [2,3],   [4,5], [6,7]],
						[[0,1,2], [3,4],   [5,6,7], [8,9]],
						[[0,1,2], [3,4,5],   [6,7,8], [9,10,11]],
						[[0,1,2,3], [4,5,6],  [7,8,9,10], [11,12,13]],
						[[0,1,2,3], [4,5,6,7],    [8,9,10,11], [12,13,14,15]],
						[[0,1,2,3,4], [5,6,7,8],   [9,10,11,12,13], [14,15,16,17]]
					],
					[
						[],
						[0, 0, 0,   1, 1, 1],
						[0, 0, 1,   2, 2, 3],
			
						[[0,1], 2, 3,   [4,5], 6, 7],
						[[0,1], 2, [3,4],   [5,6], 7, [8,9]],
						[[0,1], [2,3], [4,5],   [6,7], [8,9], [10,11]],
						[[0,1], [2,3,4],[5,6],   [7,8], [9,10,11], [12,13]],
						[[0,1,2], [3,4], [5,6,7],    [8,9,10], [11,12], [13,14,15]],
						[[0,1,2], [3,4,5], [6,7,8],   [9,10,11], [12,13,14], [15,16,17]]
					],
					[
						[],
						[0, 0, 0, 0,   1, 1, 1, 1],
						[0, 0, 1, 1,   2, 2, 3, 3],
						[0, 0, 1, 2,   3, 3, 4, 5],
			
						[0, 1, [2,3], 4,   5, 6, [7,8], 9],
						[[0,3], 4, 1, [2,5],   [6,9], 10, 7, [8,11]],
						[[0,4], 5, [1,3], [2,6],   [7,11], 12, 10, [9,13]],
						[[0,4], [1,5], [2,6], [3,7],    [8,12], [9,13], [10,14], [11,15]],
						[[0,5], [1,6], [2,4,7], [3,8],   [9,14], [10,15], [11,13,16], [12,17]]
					],
					[
						[],
						[0, 0, 0, 0, 0,   1, 1, 1, 1, 1],
						[0, 0, 0, 1, 1,   2, 2, 2, 3, 3],
						[0, 0, 1, 2, 2,   3, 3, 4, 5, 5],
						[0, 1, 2, 2, 3,   4, 5, 6, 6, 7],
			
						[3, 4, 1, 0, [2,5],   9, 10, 7, 6, [8,11]],
						[[0,4], 5, 1, 3, [2,6],   [7,11], 12, 8, 10, [9,13]],
						[[0,4], [1,5], 2, 6, [3,7],    [8,12], [9,13], 10, 14, [11,15]],
						[[0,5], [1,6], 4, [2,7], [3,8],   [9,14], [10,15], 13, [11,16], [12,17]]
					],
					[
						[],
						[0, 0, 0, 0, 0, 0,   1, 1, 1, 1, 1, 1],
						[0, 0, 0, 1, 1, 1,   2, 2, 2, 3, 3, 3],
						[0, 0, 1, 1, 2, 2,   3, 3, 4, 4, 5, 5],
						[0, 2, 3, 0, 1, 3,   4, 6, 7, 4, 5, 7],
						[3, 2, 4, 0, 1, 4,   8, 7, 9, 5, 6, 9],
			
						[0, [1,3], 2, 4, 5, 6,   7, [8,10], 9, 11, 12, 13],
						[0, [1,5], 3, 4, [2,6], 7,   8, [9,13], 11, 12, [10,14], 15],
						[0, [1,6], 3, 5, [2,4,7], 8,   9, [10,15], 12, 14, [11,13,16], 17]
					],
					[
						[],
						[0, 0, 0, 0, 0, 0, 0, 0,   1, 1, 1, 1, 1, 1, 1, 1],
						[0, 0, 0, 0, 1, 1, 1, 1,   2, 2, 2, 2, 3, 3, 3, 3],
						[0, 0, 0, 1, 1, 2, 2, 2,   3, 3, 3, 4, 4, 5, 5, 5],
						[0, 1, 2, 3, 0, 1, 2, 3,   4, 5, 6, 7, 4, 5, 6, 7],
						[0, 1, 2, 4, 0, 1, 3, 4,   5, 6, 7, 9, 5, 6, 8, 9],
						[0, 1, 4, 2, 3, 1, 4, 5,   6, 7, 10, 8, 9, 7, 10, 11],
						[0, 1, 4, 2, 3, 1, 5, 6,   7, 8, 11, 9, 10, 8, 12, 13],
			
						[0, [1,5], 3, 4, 2, 1, 7,   8, [9,13], 11, 12, 10, 14, 15],
						[0, [1,6], 3, 4, 5, [2,7], 8,   9, [10,15], 12, 13, 14, [11,16], 17]
					],
					[
						[],
						[0, 0, 0, 0, 0, 0, 0, 0,   1, 1, 1, 1, 1, 1, 1, 1],
						[0, 0, 0, 0, 1, 1, 1, 1,   2, 2, 2, 2, 3, 3, 3, 3],
						[0, 0, 0, 1, 1, 2, 2, 2,   3, 3, 3, 4, 4, 5, 5, 5],
						[0, 1, 2, 3, 0, 1, 2, 3,   4, 5, 6, 7, 4, 5, 6, 7],
						[0, 1, 2, 4, 0, 1, 3, 4,   5, 6, 7, 9, 5, 6, 8, 9],
						[0, 1, 4, 2, 3, 1, 4, 5,   6, 7, 10, 8, 9, 7, 10, 11],
						[0, 1, 4, 2, 3, 1, 5, 6,   7, 8, 11, 9, 10, 8, 12, 13],
			
						[0, 1, [2,4], 3, 5, 6, 7, 8,   9, 10, [11,13], 12, 14, 15, 16, 17]
					],
					[
						[],
						[0, 0, 0, 0, 0, 0, 0, 0, 0,   1, 1, 1, 1, 1, 1, 1, 1, 1],
						[0, 0, 0, 0, 0, 1, 1, 1, 1,   2, 2, 2, 2, 2, 3, 3, 3, 3],
						[0, 0, 0, 1, 1, 1, 2, 2, 2,   3, 3, 3, 4, 4, 4, 5, 5, 5],
						[0, 1, 2, 3, 2, 0, 1, 2, 3,   4, 5, 6, 7, 6, 4, 5, 6, 7],
						[0, 1, 3, 4, 2, 0, 1, 3, 4,   5, 6, 8, 9, 7, 5, 6, 8, 9],
						[0, 1, 4, 2, 4, 3, 1, 4, 5,   6, 7, 10, 8, 10, 9, 7, 10, 11],
						[0, 1, 5, 2, 3, 4, 1, 5, 6,   7, 8, 12, 9, 10, 11, 8, 12, 13],
						[0, 1, 2, 3, 2, 4, 5, 6, 7,   8, 9, 10, 11, 10, 12, 13, 14, 15]
					]
				]
		}

		if (!FileAPI.file.exists('options.json'))
		{
			Debug.log.warn('Path options.json not found! Creating a one...');
			//return;
			FileAPI.file.saveFile('options.json', FileAPI.file.stringify(options, "\t", false));
		}
		var json:Dynamic = FileAPI.file.parseJSON('options.json');
		if (json.to_key == null || json.algorithm == null || json.from_file == null || json.to_file == null)
			FileAPI.file.saveFile('options.json', FileAPI.file.stringify(options, "\t", false));
		options = json;

		var alg:Array<Dynamic> = options.algorithm;
		Debug.log.trace('Randoming notes in algorithm...');
		for (i1 in 0...alg.length)
			for (i2 in 0...alg[i1].length)
				for (i3 in 0...alg[i1][i2].length)
					if (alg[i1][i2][i3].length > 1)
						alg[i1][i2][i3] = alg[i1][i2][i3][Std.random(alg[i1][i2][i3].length)];

		if (!FileAPI.file.exists(options.from_file))
		{
			Debug.log.error('Path ${options.from_file} not found!');
			Application.current.window.close();
			return;
		}
		var json:Dynamic = FileAPI.file.parseJSON(options.from_file);

		var from_key:Int = json.song.mania;

		var to_key:Int = options.to_key;
		if (to_key < 1 || to_key > 9)
			to_key = 4;

		Debug.log.trace('Converting notes...');
		for (i in 0...json.song.notes.length) for (i1 in 0...json.song.notes[i].sectionNotes.length)
			json.song.notes[i].sectionNotes[i1][1] = alg[from_key][to_key][json.song.notes[i].sectionNotes[i1][1]];

		var check:Array<Dynamic> = [[], []];
		for (i in 0...json.song.notes.length) for (i1 in 0...json.song.notes[i].sectionNotes.length)
			{
				check[0].push(json.song.notes[i].sectionNotes[i1][0]);
				check[1].push(json.song.notes[i].sectionNotes[i1][1]);
			}
		var ex:Array<Dynamic> = [[2, 3, 2], [5, 1, 5]];
		for (i in 0...ex[0].length)
			if (ex[0][i])

		json.song.mania = to_key;
		FileAPI.file.saveFile(options.to_file, FileAPI.file.stringify(json, "\t", false));

		Debug.log.trace('Successfully converted notes of ${json.song.song} from ${from_key} keys to ${to_key} keys!');
		Application.current.window.close();

		super.create();
	}
}