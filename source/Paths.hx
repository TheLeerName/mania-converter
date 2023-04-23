package;

import haxe.Json;
#if sys
import sys.io.File;
import sys.FileSystem;
#end

using StringTools;

class Paths
{
	public static var get:Paths;
	
	public function font(font:String) {
		return 'assets/fonts/' + font;
	}
	
	public function parseJSON(file:String) {
		#if sys
		if (file.startsWith('{'))
			return Json.parse(file);
		else
			return Json.parse(File.getContent(file));
		#end
	}
	
	public function getContent(path:String) {
		#if sys
		return File.getContent(path);
		#end
	}
	
	// from funkin coolutil.hx
	public function parseTXT(path:String, fromFile:Bool = true):Array<String> {
		var daList:Array<String> = [];
		if (fromFile)
			daList = getContent(path).trim().split('\n');
		else
			daList = path.trim().split('\n');
		// "error: Dynamic should be String have: Array<Dynamic> want : Array<String>", WTF???
		for (i in 0...daList.length)
			daList[i] = daList[i].trim();
		return daList;
	}
	
	public function isJSON(file:String):Bool {
		var y = true;
		try {
			var d = parseJSON(file);
		}
		catch (e) {
			y = false;
		}
		return y;
	}
	
	public function stringify(file:String, format:String = "\t") {
		#if sys
		return haxe.Json.stringify(file, format);
		#end
	}
	
	public function saveFile(to_file:String, from_file:String = '') {
		#if sys
		File.saveContent(to_file, from_file);
		#end
	}
	
	public function exists(file:String) {
		#if sys
		return FileSystem.exists(file);
		#end
	}
}