package;

using StringTools;

typedef OptionsJSON = {
	var file_paths:Array<String>;
	var to_key:Int;
	var key_default:Array<Int>;
	var fnf_sync:Int;
	var converter_mode:Int;
	var osu_side:Int;
	var fnf_values:FNFValues;
	var osu_values:OsuValues;
}

typedef FNFValues = {
	var player1:String;
	var player2:String;
	var gfVersion:String;
	var speed:Float;
	var notes:Notes;
	var bpm:Float;
	var needsVoices:Bool;
	var stage:String;
}
typedef OsuValues = {
	var audioFilename:String;
	var artist:String;
	var creator:String;
	var version:String;
	var hpDrainRate:Float;
	var volumeHitsound:Int;
}

typedef Notes = {
	var lengthInSteps:Int;
	var typeOfSection:Int;
	var mustHitSection:Bool;
	var gfSection:Bool;
	var changeBPM:Bool;
	var altAnim:Bool;
}

class Options
{
	public static var func:Options;

	public static var get:Dynamic = options_();

	public static function options_()
	{
		var optionsJSON:OptionsJSON = {
			file_paths: ['beatmap', 'beatmap-converted'], // converting from 1 value to 2 value
			to_key: 6, // value for key count after converting
			key_default: [4, 4], // default key count before (1 value) and after (2 value) converting (crash preventing)
			fnf_sync: 0, // 0 = all engines, 1 = extra keys mod (real key count - 1, example 4 keys is mania = 3), 2 = leather engine (mania = (keyCount && playerKeyCount))
			converter_mode: 0, // 0,'fnf' = FNF to FNF; 1,'to_fnf','tofnf' = osu!mania to FNF; 2,'to_osu','toosu' = FNF to osu!mania; 3,'osu' = osu!mania to osu!mania
			osu_side: 1, // 0 = player1 (bf) and player2 (dad), 1 = player1, 2 = player2

			fnf_values: {
				player1: 'bf',
				player2: 'pico',
				gfVersion: 'gf',
				speed: 3, // scroll speed of notes
				notes: {
					lengthInSteps: 160000,
					typeOfSection: 0,
					mustHitSection: true, // true = cam follow to player1, false = cam follow to player2
					gfSection: false, // true = gf sings
					changeBPM: false,
					altAnim: false // alt anims of characters
				},
				bpm: 150, // bpm of song, uses in converter mode 0 and 1
				needsVoices: false, // song uses Voices.ogg file?
				stage: 'stage'
			},

			osu_values: {
				audioFilename: 'audio.mp3', // name of audio file of song
				artist: 'ManiaConverter', // artist of song
				creator: 'ManiaConverter', // creator of beatmap
				version: 'Normal', // name of difficulty
				hpDrainRate: 8, // rate of hp drain in song
				volumeHitsound: 50 // volume of hitsounds: 50 = 50%
			}
		}

		if (!FileAPI.file.exists('options.json'))
		{
			Debug.log.warn('Path options.json not found! Creating a file...');
			FileAPI.file.saveFile('options.json', FileAPI.file.stringify(optionsJSON, "\t", false));
		}
		var json:Dynamic = FileAPI.file.parseJSON('options.json');
		if
		(
			json.file_paths == null ||
			json.to_key == null ||
			json.key_default == null ||
			json.fnf_sync == null ||
			json.converter_mode == null ||
			json.osu_side == null ||

			json.fnf_values == null ||
			json.fnf_values.player1 == null ||
			json.fnf_values.player2 == null ||
			json.fnf_values.gfVersion == null ||
			json.fnf_values.speed == null ||
			json.fnf_values.notes == null ||
			json.fnf_values.notes.lengthInSteps == null ||
			json.fnf_values.notes.typeOfSection == null ||
			json.fnf_values.notes.mustHitSection == null ||
			json.fnf_values.notes.gfSection == null ||
			json.fnf_values.notes.changeBPM == null ||
			json.fnf_values.notes.altAnim == null ||
			json.fnf_values.bpm == null ||
			json.fnf_values.needsVoices == null ||
			json.fnf_values.stage == null ||

			json.osu_values == null ||
			json.osu_values.audioFilename == null ||
			json.osu_values.artist == null ||
			json.osu_values.creator == null ||
			json.osu_values.version == null ||
			json.osu_values.hpDrainRate == null ||
			json.osu_values.volumeHitsound == null
		)
		{
			Debug.log.warn('Some options are null! Recreating a file...');
			FileAPI.file.saveFile('options.json', FileAPI.file.stringify(optionsJSON, "\t", false));
		}
		return FileAPI.file.parseJSON('options.json');
	}

	public function createAlgorithm()
	{
var alg:Array<String> = [
'',
'0,0
0,1
0/1,2/3
0/1/2,3/4/5
0/1/2/3,4/5/6/7
0/1/2/3/4,5/6/7/8/9
0/1/2/3/4/5,6/7/8/9/10/11
0/1/2/3/4/5/6,7/8/9/10/11/12/13
0/1/2/3/4/5/6/7,8/9/10/11/12/13/14/15
0/1/2/3/4/5/6/7/8,9/10/11/12/13/14/15/16/17',
'0,0,0,0
0,0,1,1
0,1,2,3
0/1,2,3/4,5
0/1,2/3,4/5,6/7
0/1/2,3/4,5/6/7,8/9
0/1/2,3/4/5,6/7/8,9/10/11
0/1/2/3,4/5/6,7/8/9/10,11/12/13
0/1/2/3,4/5/6/7,8/9/10/11,12/13/14/15
0/1/2/3/4,5/6/7/8,9/10/11/12/13,14/15/16/17',
'0,0,0,0,0,0
0,0,0,1,1,1
0,0,1,2,2,3
0,1,2,3,4,5
0/1,2,3,4/5,6,7
0/1,2,3/4,5/6,7,8/9
0/1,2/3,4/5,6/7,8/9,10/11
0/1,2/3/4,5/6,7/8,9/10/11,12/13
0/1/2,3/4,5/6/7,8/9/10,11/12,13/14/15
0/1/2,3/4/5,6/7/8,9/10/11,12/13/14,15/16/17',
'0,0,0,0,0,0,0,0
0,0,0,0,1,1,1,1
0,0,1,1,2,2,3,3
0,0,1,2,3,3,4,5
0,1,2,3,4,5,6,7
0,1,2/3,4,5,6,7/8,9
0/3,4,1,2/5,6/9,10,7,8/11
0/4,5,1/3,2/6,7/11,12,8/10,9/13
0/4,1/5,2/6,3/7,8/12,9/13,10/14,11/15
0/5,1/6,2/4/7,3/8,9/14,10/15,11/13/16,12/17',
'0,0,0,0,0,0,0,0,0,0
0,0,0,0,0,1,1,1,1,1
0,0,0,1,1,2,2,2,3,3
0,0,1,2,2,3,3,4,5,5
0,1,2,2,3,4,5,6,6,7
0,1,2,3,4,5,6,7,8,9
3,4,1,0,2/5,9,10,7,6,8/11
0/4,5,1,3,2/6,7/11,12,8,10,9/13
0/4,1/5,2,6,3/7,8/12,9/13,10,14,11/15
0/5,1/6,4,2/7,3/8,9/14,10/15,13,11/16,12/17',
'0,0,0,0,0,0,0,0,0,0,0,0
0,0,0,0,0,0,1,1,1,1,1,1
0,0,0,1,1,1,2,2,2,3,3,3
0,0,1,1,2,2,3,3,4,4,5,5
0,2,3,0,1,3,4,6,7,4,5,7
3,2,4,0,1,4,8,7,9,5,6,9
0,1,2,3,4,5,6,7,8,9,10,11
0,1/3,2,4,5,6,7,8/10,9,11,12,13
0,1/5,3,4,2/6,7,8,9/13,11,12,10/14,15
0,1/6,3,5,2/4/7,8,9,10/15,12,14,11/13/16,17',
'0,0,0,0,0,0,0,0,0,0,0,0,0,0
0,0,0,0,0,0,0,1,1,1,1,1,1,1
0,0,0,0,1,1,1,2,2,2,2,3,3,3
0,0,1,1,1,2,2,3,3,4,4,4,5,5
0,2,3,2,0,1,3,4,6,7,6,4,5,7
0,2,4,3,0,1,4,5,7,9,8,5,6,9
0,1,2,1,3,4,5,6,7,8,7,9,10,11
0,1,2,3,4,5,6,7,8,9,10,11,12,13
0,1/5,3,4,2,6,7,8,9/13,11,12,10,14,15
0,1/6,3,4,5,2/7,8,9,10/15,12,13,14,11/16,17',
'0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1
0,0,0,0,1,1,1,1,2,2,2,2,3,3,3,3
0,0,0,1,1,2,2,2,3,3,3,4,4,5,5,5
0,1,2,3,0,1,2,3,4,5,6,7,4,5,6,7
0,1,2,4,0,1,3,4,5,6,7,9,5,6,8,9
0,1,4,2,3,1,4,5,6,7,10,8,9,7,10,11
0,1,4,2,3,1,5,6,7,8,11,9,10,8,12,13
0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15
0,1,2/4,3,5,6,7,8,9,10,11/13,12,14,15,16,17',
'0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1
0,0,0,0,0,1,1,1,1,2,2,2,2,2,3,3,3,3
0,0,0,1,1,1,2,2,2,3,3,3,4,4,4,5,5,5
0,1,2,3,2,0,1,2,3,4,5,6,7,6,4,5,6,7
0,1,3,4,2,0,1,3,4,5,6,8,9,7,5,6,8,9
0,1,4,2,4,3,1,4,5,6,7,10,8,10,9,7,10,11
0,1,5,2,3,4,1,5,6,7,8,12,9,10,11,8,12,13
0,1,2,3,2,4,5,6,7,8,9,10,11,10,12,13,14,15
0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17'
];
		for (i in 1...alg.length)
			if (!FileAPI.file.exists('algorithms/${i}key.txt'))
			{
				Debug.log.warn('Not found a ${i} key algorithm, creating new...');
				FileAPI.file.saveFile('algorithms/${i}key.txt', alg[i]);
			}
	}

	/*public function loadAlgorithm()
	{
		var dir:Array<String> = FileAPI.file.readDir('assets/algorithms');
		var algs_list:Array<String> = [];
		var int:Int = 0;
		for (i in 0...dir.length) if (dir[i].endsWith('key.txt'))
			{
				algs_list[int] = dir[i];
				int++;
			}
		int = 0;

		createAlgorithm();
	}*/

	public function alg(from_key:Int, to_key:Int)
	{
		var alg:Array<Dynamic> = FileAPI.file.getContent('algorithms/${from_key}key.txt').trim().split('\n');
		var alg2:Array<Dynamic> = alg[to_key].split(',');
		var alg3:Array<Dynamic> = [];
		for (i in 0...alg2.length)
			alg3[i] = alg2[i].split('/');

		return alg3;
	}

	public function algLength():Int
	{
		var dir_primary:Array<String> = FileAPI.file.readDir('algorithms');
		var dir:Array<String> = [];
		var int:Int = 0;

		for (i in 0...dir_primary.length)
			if (dir_primary[i].endsWith('key.txt'))
			{
				dir[int] = dir_primary[i];
				int++;
			}

		return dir.length;
	}
}