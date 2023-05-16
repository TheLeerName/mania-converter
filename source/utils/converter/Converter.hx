package utils.converter;

import haxe.Json;

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

	public function saveAsOSU(path:String):Array<Dynamic>
	{
		if (structure == null) return [];
		var stru:SwagSong = Utils.changeKeyCount(Utils.removeDuplicates(structure, options.get("Sensitivity")), options.get("Key count"));
		var toret:Array<Dynamic> = stru.events;
		stru.events = [];
		OsuParser.convertToOsu(stru, options).save(path);
		return toret;
	}

	public function saveAsJSON(path:String, space:String = "\t"):Array<Dynamic>
	{
		#if sys
		if (structure == null) return [];
		var stru:SwagSong = Utils.changeKeyCount(Utils.removeDuplicates(structure, options.get("Sensitivity")), options.get("Key count"));
		var toret:Array<Dynamic> = stru.events;
		stru.events = [];
		File.saveContent(path, Json.stringify({song: stru}, space));
		return toret;
		#end
	}

	@:to public inline function toString():String return Json.stringify(structure);
}