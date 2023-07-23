package utils.converter;

import haxe.Json;

/*
       /////  /////  //  /   ///   /////         /////  /////  //  /  /   /  /////  /////  /////  /////  /////         /////         /////
      / / /  /   /  /// /    /    /   /         /      /   /  /// /  /   /  /      /   /    /    /      /   /             /         /   /
     / / /  /////  / / /    /    /////         /      /   /  / / /  /   /  /////  ///      /    /////  ///           /////         /   /
    / / /  /   /  / ///    /    /   /         /      /   /  / ///   / /   /      /  /     /    /      /  /              /         /   /
   / / /  /   /  /  //   ///   /   /         /////  /////  /  //    /    /////  /   /    /    /////  /   /         /////   ///   /////
*/

typedef ReturnString = {
	var value:String;
	var ?extraValue:Dynamic;
}

class Converter {
	public var fileContent(default, set):String;
	function set_fileContent(value:String):String {
		if (fileName == null) fileName = "";
		if (value.length == 0 || value == null) return fileContent = value;
		var versionShit:String = value.replace("\r", "").split("\n")[0];
		if (versionShit.startsWith("osu file format v")) {
			versionShit = versionShit.substring(versionShit.lastIndexOf(" v") + 2, versionShit.length);
			if (versionShit != "14") Paths.log('Osu file format is not v14 (you have v$versionShit), it may do some unexpected things!', 0xffffee00);

			structure = OsuParser.convertFromOsu(value , options);
			if (structure == null) return fileContent = value;

			var ini = new INIParser().loadFromContent(value);
			difficultyName = ini.getValueByName("Metadata", "Version");
			if (difficultyName == null || difficultyName == "") difficultyName = "Normal";

			osuFileName = ini.getValueByName("Metadata", "Artist") + " - " + ini.getValueByName("Metadata", "Title") + " (" + ini.getValueByName("Metadata", "Creator") + ") [" + difficultyName + "].osu";
			jsonFileName = Utils.formatToSongPath(ini.getValueByName("Metadata", "Title") + (difficultyName != "Normal" ? "-" + difficultyName : "")) + ".json";
		} else {
			try {
				structure = Json.parse(value).song;

				difficultyName = Utils.makeSongName(fileName.substring(fileName.lastIndexOf(Utils.formatToSongPath(structure.song)) + Utils.formatToSongPath(structure.song).length, fileName.lastIndexOf("."))).trim();
				if (difficultyName == null || difficultyName == "") difficultyName = "Normal";
				trace(difficultyName);

				osuFileName = options.get("Artist") + " - " + Utils.makeSongName(structure.song) + " (" + options.get("Creator") + ") [" + Utils.makeSongName(difficultyName) + "].osu";
				jsonFileName = Utils.formatToSongPath(structure.song + (difficultyName != "Normal" ? "-" + difficultyName : "")) + ".json";
			}
			catch (e) {
				Paths.log('Error parsing $fileName: ' + e);
			}
		}
		return fileContent = value;
	}
	public var structure:SwagSong = null;

	public var options:Map<String, Dynamic> = [];
	public var difficultyName:String;
	public var osuFileName:String;
	public var jsonFileName:String;
	public var fileName:String;

	public function new() {}

	public function load(file:String, ?options:Map<String, Dynamic>):Converter {
		
		fileContent = fileName = null;
		var content:String = "";
		#if lime if (Assets.exists(file, TEXT)) content = Assets.getText(file); #end
		#if sys if (FileSystem.exists(file) && !FileSystem.isDirectory(file)) content = File.getContent(file); #end
		if (content != "") {
			this.options = options;
			fileName = file;
			fileContent = content;
		}
		return this;
	}
	public function loadFromContent(content:String, ?options:Map<String, Dynamic>):Converter {
		this.options = options;
		fileContent = content;
		return this;
	}

	public function getAsOSU():ReturnString {
		if (structure == null) return {value: ""};
		var returnUtils = Utils.removeDuplicates(structure, options.get("Sensitivity"));
		var removedNotes:Int = returnUtils.extraValue + 0;
		returnUtils = Utils.changeKeyCount(returnUtils.value, options.get("Key count") == 0 ? returnUtils.value.keyCount : options.get("Key count"));
		var oldKeyCount:Int = returnUtils.extraValue + 0;

		return {value: OsuParser.convertToOsu(returnUtils.value, options, difficultyName).toString(), extraValue: [oldKeyCount, removedNotes, osuFileName]};
	}
	public function saveAsOSU(path:String):Array<Dynamic> {
		#if sys
		var poof = getAsOSU();
		File.saveContent(path, poof.value);
		return poof.extraValue;
		#end
		return [];
	}

	public function getAsJSON(space:String = "\t"):ReturnString {
		if (structure == null) return {value: ""};
		var returnUtils = Utils.removeDuplicates(structure, options.get("Sensitivity"));
		var removedNotes:Int = returnUtils.extraValue + 0;
		returnUtils = Utils.changeKeyCount(returnUtils.value, options.get("Key count") == 0 ? returnUtils.value.keyCount : options.get("Key count"));
		var oldKeyCount:Int = returnUtils.extraValue + 0;

		return {value: Json.stringify({song: returnUtils.value}, space), extraValue: [oldKeyCount, removedNotes, jsonFileName]};
	}
	public function saveAsJSON(path:String, space:String = "\t"):Array<Dynamic> {
		#if sys
		var poof = getAsJSON(space);
		File.saveContent(path, poof.value);
		return poof.extraValue;
		#end
		return [];
	}

	@:to public inline function toString():String return Json.stringify(structure);
}