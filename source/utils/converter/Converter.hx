package utils.converter;

import haxe.Json;

typedef ReturnString = {
	var value:String;
	var ?extraValue:Dynamic;
}

class Converter {
	public var fileContent(default, set):String;
	function set_fileContent(value:String):String {
		if (value.length == 0 || value == null) return fileContent = value;
		if (value.replace("\r", "").split("\n")[0] == "osu file format v14")
		{
			structure = OsuParser.convertFromOsu(value, options);
			//trace(value);
		}
		else
		{
			try {
				structure = Json.parse(value).song;
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
		if (Assets.exists(file, TEXT)) content = Assets.getText(file);
		else if (FileSystem.exists(file) && !FileSystem.isDirectory(file)) content = File.getContent(file);
		if (content != "") {
			this.options = options;
			fileContent = content;
			fileName = file;
		}
		#end
		return this;
	}

	public function getAsOSU():ReturnString {
		if (structure == null) return {value: ""};
		var returnUtils = Utils.removeDuplicates(structure, options.get("Sensitivity"));
		var removedNotes:Int = returnUtils.extraValue + 0;
		returnUtils = Utils.changeKeyCount(returnUtils.value, options.get("Key count"));
		var oldKeyCount:Int = returnUtils.extraValue + 0;

		return {value: OsuParser.convertToOsu(returnUtils.value, options).toString(), extraValue: [oldKeyCount, removedNotes]};
	}
	public function saveAsOSU(path:String):Array<Dynamic> {
		#if sys
		var poof = getAsOSU();
		File.saveContent(path, poof.value);
		return poof.extraValue;
		#end
	}

	public function getAsJSON(space:String = "\t"):ReturnString {
		if (structure == null) return {value: ""};
		var returnUtils = Utils.removeDuplicates(structure, options.get("Sensitivity"));
		var removedNotes:Int = returnUtils.extraValue + 0;
		returnUtils = Utils.changeKeyCount(returnUtils.value, options.get("Key count"));
		var oldKeyCount:Int = returnUtils.extraValue + 0;

		return {value: Json.stringify({song: returnUtils.value}, space), extraValue: [oldKeyCount, removedNotes]};
	}
	public function saveAsJSON(path:String, space:String = "\t"):Array<Dynamic> {
		#if sys
		var poof = getAsJSON(space);
		File.saveContent(path, poof.value);
		return poof.extraValue;
		#end
	}

	@:to public inline function toString():String return Json.stringify(structure);
}