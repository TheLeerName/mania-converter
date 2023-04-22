package converter;

#if lime
import lime.utils.Assets;
#end
#if sys
import sys.FileSystem;
import sys.io.File;
#end
import haxe.Json;

using StringTools;

class Converter {
	public var fileContent(default, set):String;
	function set_fileContent(value:String):String {
		if (value.length == 0 || value == null) return fileContent = value;
		if (value.replace("\r", "").split("\n")[0] == "osu file format v14")
		{
			structure = convertFromOsu(value);
			//trace(value);
		}
		else
		{
			try {
				structure = Json.parse(value);
				//trace(structure);
			}
			catch (e) {
				//trace("idiot! die! " + e);
			}
		}
		return fileContent = value;
	}
	public var fileName:String;

	public var structure:SwagSong = null;

	public var options:Map<String, Dynamic> = [];

	public function new() {}

	public function load(file:String, ?options:Map<String, Dynamic>):Converter {
		#if sys
		fileContent = fileName = null;
		var content:String = "";
		#if lime
		if (Assets.exists(file, TEXT)) content = Assets.getText(file);
		else #end if (FileSystem.exists(file) && !FileSystem.isDirectory(file)) content = File.getContent(file);
		if (content != "") {
			fileContent = content;
			fileName = file;
			this.options = options;
		}
		#end
		return this;
	}

	public function saveAsJSON(path:String, space:String = "\t")
	{
		#if sys
		if (structure == null) return;
		File.saveContent(path, Json.stringify({song: structure}, space));
		#end
	}

	public function convertFromOsu(content:String):SwagSong {
		//Sys.println("[Mania Converter] Getting osu! map data...");
		var ini:INIParser = new INIParser();
		ini.fileContent = content;

		var keyCount:Int = ini.getValueByName("Difficulty", "CircleSize");
		var json:SwagSong = { // copied from psych engine charting state
			song: 'Sus',
			notes: [],
			events: [],
			bpm: options.get("BPM"),
			needsVoices: options.get("Needs voices"),
			speed: options.get("Scroll speed"),
			player1: options.get("Player 1"),
			player2: options.get("Player 2"),
			gfVersion: options.get("Player 3 (GF)"),
			stage: options.get("Stage"),
			keyCount: options.get("Key count"),
			generatedBy: "",
		};
		//if (content.replace("\r", "").split("\n")[0] != "osu file format v14") return null;

		//Sys.println("[Mania Converter] Found " + Lambda.count(ini.getCategoryByName("HitObjects")) + " notes...");

		json.song = ini.getValueByName("Metadata", "Title");
		if (json.song == null) json.song = ini.getValueByName("Metadata", "TitleUnicode");
		if (json.song == null) json.song = "Test";

		var curMode:Int = ini.getValueByName("General", "Mode");
		if (curMode != 3)
		{
			var osuModes = [
				'standard osu',
				'osu!taiko',
				'osu!catch',
				'osu!mania'
			];
			Sys.println('[Mania Converter] Converter supports only osu!mania mode! You have a ' + osuModes[curMode] + ' beatmap.');
			return null;
		}

		var toData:Array<Dynamic> = [];
		//Sys.println("Parsing notes from osu!mania map...");
		for (n => v in ini.getCategoryByName("HitObjects"))
		{
			toData.push([
				Std.parseInt(n.split(",")[2]),
				convertNote(Std.parseInt(n.split(",")[0]), keyCount),
				Std.parseFloat(n.split(",")[5]) - Std.parseFloat(n.split(",")[2])
			]);
			if (toData[toData.length - 1][2] < 0) toData[toData.length - 1][2] = 0; // removing negative values of hold notes
		}
		toData.sort((a, b) -> a[0] - b[0]); // map is stupid fuck, why it sorts by alphabet or smth
		//trace(toData.length);

		// skipping bpm calculating for now...

		//Sys.println("Placing notes to FNF map...");

		/*for (i in 0...toData.length)
		{
			json.notes[0].sectionNotes[i] = toData[i]; // placing all notes in one section (very bad for charting state)
		}*/

		while(true)
		{
			json.notes.push({
				sectionBeats: 4,
				bpm: json.bpm,
				changeBPM: false,
				mustHitSection: true,
				gfSection: false,
				sectionNotes: [],
				typeOfSection: 0,
				altAnim: false
			});

			for (sectionNotes in toData)
				if (sectionNotes[0] <= ((json.notes.length) * (4 * (1000 * 60 / json.bpm))) && sectionNotes[0] > ((json.notes.length - 1) * (4 * (1000 * 60 / json.bpm))))
					json.notes[Std.int(json.notes.length - 1)].sectionNotes.push(sectionNotes);

			if (toData[toData.length - 1] == json.notes[Std.int(json.notes.length - 1)].sectionNotes[Std.int(json.notes[Std.int(json.notes.length - 1)].sectionNotes.length - 1)])
				break;
		}

		// skipping remove duplicate notes for now...

		json.keyCount = 4; // for now ofc
		json.generatedBy = "Mania Converter " + Reflect.getProperty(Type.resolveClass("Main"), "version"); // fuck you Defined in this class

		return json;
	}

	public function findLine(array:Array<String>, find:String, fromLine:Int = 0, ?toLine:Int):Int
	{
		if (toLine == null)
			toLine = array.length;
	
		for (i in fromLine...toLine)
			if (array[i].contains(find))
				return i;
	
			//if (!silent) debug.warn('String ' + find + ' not found!');
		return -1;
	}

	public function getMapOption(map:Array<String>, name:String)
	{
		for (th in map)
			if (th.toLowerCase().startsWith(name.toLowerCase() + ':'))
				return th.substring(th.lastIndexOf(':') + 1).trim(); 

		//debug.warn('Map option ' + name + ' not found!');
		return null;
	}

	public function convertNote(from_note:Int, keyCount:Int, fromosu:Bool = true):Int
	{
		//console.log('da ' + from_note)

		var num:Float = 512 / keyCount;
		//console.log(ty + ' | ' + keyCount)

		if (fromosu)
		{
			for (i in 0...keyCount)
			{
				var th:Array<Float> = [num * i, (num * (i + 1)) - 1];
				if (from_note >= th[0] && from_note <= th[1])
				{
					//console.log(th);
					//console.log(keyCount + 'K: ' + from_note + ' -> from ' + th[0] + ' to ' + th[1]);
					return i;
				}
			}
		}
		else
		{
			if (from_note >= keyCount)
			from_note = from_note - keyCount + 1;
			//console.log(keyCount + 'K: ' + from_note + ' -> ' + (parseInt(((num * from_note) + ((num * (from_note + 1)) - 1)) / 2) + 1));
			return Std.int(((num * from_note) + ((num * (from_note + 1)) - 1)) / 2) + 1;
		}

		Sys.println('[Mania Converter] Note ' + from_note + ' not found in array!');
		return 0;
	}
}

typedef SwagSection =
{
	var sectionNotes:Array<Dynamic>;
	var sectionBeats:Float;
	var typeOfSection:Int;
	var mustHitSection:Bool;
	var gfSection:Bool;
	var bpm:Float;
	var changeBPM:Bool;
	var altAnim:Bool;
}

typedef SwagSong =
{
	var song:String;
	var notes:Array<SwagSection>;
	var events:Array<Dynamic>;
	var bpm:Float;
	var needsVoices:Bool;
	var speed:Float;
	var keyCount:Int;

	var player1:String;
	var player2:String;
	var gfVersion:String;
	var stage:String;

	var generatedBy:String;
}