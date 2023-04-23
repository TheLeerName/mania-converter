package parser;

class OsuParser {
	public static function convertFromOsu(content:String, options:Map<String, Dynamic>):SwagSong {
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

		var timingPoints:Map<String, Dynamic> = ini.getCategoryByName("TimingPoints");
		if (timingPoints != null) {
			var bpmthing:Array<Float> = [0, 1];
			for (n => v in timingPoints) if (n.split(",")[6] == '1')
				bpmthing = [bpmthing[0] + Std.parseFloat(n.split(",")[1]), bpmthing[1]++];
			json.bpm = Math.floor(bpmthing[0] / bpmthing[1]);
		}
		trace(json.bpm);

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
		json.generatedBy = "Mania Converter " + Main.version;

		return json;
	}

	public static function convertToOsu(json:SwagSong, options:Map<String, Dynamic>):INIParser
	{
		var ini:INIParser = new INIParser();
		ini.fileContent = "osu file format v14\n";
		ini.setCategoryArrayByName("General", [
			"AudioFilename:" + options.get("Audio name"),
			"Mode:3"
		]);
		ini.setCategoryArrayByName("Metadata", [
			"Title:" + makeSongName(json.song, "-", " "),
			"Artist:" + options.get("Artist"),
			"Creator:" + options.get("Creator"),
			"Version:poopy",
			"Source:" + options.get("Source"),
			"GeneratedBy:Mania Converter " + Main.version
		]);
		ini.setCategoryArrayByName("Difficulty", [
			"HPDrainRate:" + options.get("HP Drain"),
			"CircleSize:4",
		]);
		ini.setCategoryArrayByName("TimingPoints", [
			"0," + (60000 / options.get("BPM")) + ",4,0,0," + options.get("Hitsound Vol") + ",1,0",
		]);

		var notes:Array<String> = [];
		for (section in json.notes)
			for (songNotes in section.sectionNotes)
				switch (options.get("Side"))
				{
					case 1:
						if ((section.mustHitSection && songNotes[1] < 4) || (!section.mustHitSection && songNotes[1] >= 4))
							notes.push(convertNote(Std.int(songNotes[1] - (songNotes[1] >= 4 ? 4 : 0)), 4, false) + ",192," + songNotes[0] + (songNotes[2] > 0 ? ",128,0," + songNotes[2] + ":0:0:0:0:" : ",1,0,0:0:0:0:"));
					case 2:
						if ((section.mustHitSection && songNotes[1] >= 4) || (!section.mustHitSection && songNotes[1] < 4))
							notes.push(convertNote(Std.int(songNotes[1] - (songNotes[1] >= 4 ? 4 : 0)), 4, false) + ",192," + songNotes[0] + (songNotes[2] > 0 ? ",128,0," + songNotes[2] + ":0:0:0:0:" : ",1,0,0:0:0:0:"));
					default:
						notes.push(convertNote(Std.int(songNotes[1] - (songNotes[1] >= 4 ? 4 : 0)), 4, false) + ",192," + songNotes[0] + (songNotes[2] > 0 ? ",128,0," + songNotes[2] + ":0:0:0:0:" : ",1,0,0:0:0:0:"));
	
				}
		ini.setCategoryArrayByName("HitObjects", notes);

		return ini;
	}

	public static function convertNote(from_note:Int, keyCount:Int, fromosu:Bool = true):Int
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

	public static function makeSongName(string:String, toreplace:String, replacer:String):String
	{
		var array:Array<String> = string.replace(toreplace, replacer).split(replacer);
		for (i in 0...array.length)
			array[i] = array[i].substring(0, 1).toUpperCase() + array[i].substring(1);
		return array.join(' ');
	}
}