package converter;

import lime.utils.Assets;
#if sys
import sys.FileSystem;
import sys.io.File;
#end
import haxe.Json;

using StringTools;

class Converter {
	public var fileContent(default, set):String;
	function set_fileContent(value:String):String {
		if (value.replace("\r", "").split("\n")[0] == "osu file format v14")
		{
			//trace(value);
		}
		else
		{
			try {
				structure = Json.parse(value);
				trace(structure);
			}
			catch (e) {
				trace("idiot! die! " + e);
			}
		}
		return fileContent = value;
	}

	public var structure:SwagSong = null;

	public function new() {}

	public function load(file:String):Converter {
		#if sys
		if (Assets.exists(file, TEXT)) file = Assets.getText(file);
		else if (FileSystem.exists(file)) file = File.getContent(file);
		if (!file.contains("[")) return null;
		fileContent = file;
		#end
		return this;
	}
}
