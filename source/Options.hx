package;

using StringTools;

typedef OptionsJSON = {
	var from_file:String;
	var to_file:String;
	var to_key:Int;
	var from_key_default:Int;
	var to_key_default:Int;
	var extra_keys_sync:Bool;
	var leather_sync:Bool;
	var osu_convert:Bool;
	var osu_defaults:ODefaults;
}

typedef ODefaults = {
	var player1:String;
	var player2:String;
	var gfVersion:String;
	var speed:Float;
	var notes:Notes;
	var bpm:Float;
	var needsVoices:Bool;
	var stage:String;
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
	public static var get:Options;

	public function options()
	{
		var optionsJSON:OptionsJSON = {
			from_file: 'beatmap', // path to map/file before convert
			to_file: 'beatmap-converted', // path to map/file after convert
			to_key: 6, // value for key count after converting
			from_key_default: 4, // default value for key count before converting (crash preventing)
			to_key_default: 4, // default value for key count after converting (crash preventing)
			extra_keys_sync: true, // sync with mania from extra keys mod (real key count - 1, example 4 keys is mania = 3)
			leather_sync: false, // sync with keyCount from leather engine (mania = (keyCount && playerKeyCount)), if its true extra_keys_sync = false

			osu_convert: false, // switch to osu!mania to fnf converter
			osu_defaults: {
				player1: 'bf',
				player2: 'pico',
				gfVersion: 'gf',
				speed: 3,
				notes: {
					lengthInSteps: 160000,
					typeOfSection: 0,
					mustHitSection: true,
					gfSection: false,
					changeBPM: false,
					altAnim: false
				},
				bpm: 150,
				needsVoices: false,
				stage: 'stage'
			}
		}

		if (!FileAPI.file.exists('options.json'))
		{
			Debug.log.warn('Path options.json not found! Creating a one...');
			FileAPI.file.saveFile('options.json', FileAPI.file.stringify(optionsJSON, "\t", false));
		}
		var json:Dynamic = FileAPI.file.parseJSON('options.json');
		if
		(
			json.to_key == null ||
			json.from_key_default == null ||
			json.extra_keys_sync == null ||
			json.leather_sync == null ||
			json.osu_convert == null ||
			json.osu_defaults == null ||
			json.osu_defaults.player1 == null ||
			json.osu_defaults.player2 == null ||
			json.osu_defaults.gfVersion == null ||
			json.osu_defaults.speed == null ||
			json.osu_defaults.notes == null ||
			json.osu_defaults.notes.gfSection == null ||
			json.osu_defaults.notes.lengthInSteps == null ||
			json.osu_defaults.notes.altAnim == null ||
			json.osu_defaults.notes.typeOfSection == null ||
			json.osu_defaults.notes.changeBPM == null ||
			json.osu_defaults.notes.mustHitSection == null ||
			json.osu_defaults.bpm == null ||
			json.osu_defaults.needsVoices == null ||
			json.osu_defaults.stage == null ||
			json.from_file == null ||
			json.to_file == null
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