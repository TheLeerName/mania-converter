package utils;

#if flixel
import flixel.util.FlxColor;
#end

class INIParser {
	public var fileContent(default, set):String;
	private function set_fileContent(value:String):String {
		fileContent = value;
		generateStructure();
		return value;
	}

	public var structure:Map<String, Map<String, Dynamic>> = [];
	public var indexes:Array<String> = [];

	public static var defaultVersion:Int = 1;
	/*public var version(get, default):Int;
	private function get_version():Int {
		if (fileContent == null) return 0;
		var str:String = fileContent.split("\n")[0];
		return Std.parseInt(str.substring(str.lastIndexOf(" v") + 2, str.length));
	}*/

	public function new(name:String = "ini format") {
		fileContent = name + " v" + defaultVersion + "\n";
	}

	public function loadFromContent(content:String):INIParser {
		fileContent = null;
		if (content != "") fileContent = content;
		return this;
	}
	public function load(file:String):INIParser {
		fileContent = null;
		var content:String = "";
		#if lime if (Assets.exists(file, TEXT)) content = Assets.getText(file); #end
		#if sys if (FileSystem.exists(file) && !FileSystem.isDirectory(file)) content = File.getContent(file); #end
		if (content != "") fileContent = content;
		return this;
	}
	inline public function save(path:String) {
		#if sys
		File.saveContent(path, fileContent.replace("<", "[").replace(">", "]"));
		#end
	}

	function generateStructure() {
		if (structure != []) structure = [];
		if (indexes != []) indexes = [];
		if (fileContent == null) return;
		var fc_:Array<String> = fileContent.split("\n");
		for (i in 0...fc_.length)
		{
			fc_[i] = fc_[i].replace("\r", "");
			if (fc_[i].startsWith("["))
				fc_[i] = "<" + fc_[i].substring(1, fc_[i].length - 1) + ">";
			else
				fc_[i] = fc_[i].replace("<", "").replace(">", "");
		}
		var fc:String = fc_.join("\n");
		//switch (version)
		//{
			//case 1:
				for (cat in fc.split("<"))
				{
					if (!cat.contains(">")) continue;
					var stru:Map<String, Dynamic> = [];
					for (line in cat.split("\n"))
					{
						if (line.contains("\r")) line = line.replace("\r", "");
						if (line.contains("\n")) line = line.replace("\n", "");

						if (line.length == 0) break;
						if (line.startsWith("//") || line.endsWith(">")) continue;

						if (line.contains(":"))
						{
							var value:Any = resolveValueFromString(line.substring(line.indexOf(":") + 1));
							stru.set(line.substring(0, line.indexOf(":")), value);
						}
						else
							stru.set(line, null);
					}
					structure.set(cat.substring(0, cat.indexOf(">")), stru);
					indexes.push(cat.substring(0, cat.indexOf(">")));
					//trace(struc.length);
				}
			//default:
				// nothing
		//}
	}

	function resolveValueFromString(value:String):Any {
		if (!Math.isNaN(parseFloat(value))) return parseFloat(value);
		#if flixel
		if (FlxColor.fromString(value) != null) return FlxColor.fromString(value);
		#end
		if (value == "true") return true;
		if (value == "false") return false;
		return value;
	}

	function initializeCategory(categoryName:String, replace:Bool = false)
	{
		if (fileContent == null || structure == null) return;
		if (existsCategoryByName(categoryName)) {
			if (replace)
				removeCategoryByName(categoryName);
			else
				return;
		}
		fileContent += "\n[" + categoryName + "]\n";
	}

	public function existsCategoryByName(categoryName:String):Bool {
		if (fileContent == null || structure == null) return false;
		return structure.exists(categoryName);
	}
	public function existsValueByName(categoryName:String, name:String):Bool {
		if (fileContent == null || structure == null || !existsCategoryByName(categoryName)) return false;
		return structure.get(categoryName).exists(name);
	}

	public function removeCategoryByName(categoryName:String):Bool {
		if (fileContent == null || structure == null) return false;
		var lines:Array<String> = fileContent.split("\n");
		for (i in 0...lines.length) if (lines[i] == "<" + categoryName + ">") {
			while(lines[i] != "") lines.splice(i, 1);
			lines.splice(i, 1);
			fileContent = lines.join("\n");
			return true;
		}
		return false;
	}
	public function removeValueByName(categoryName:String, name:String):Bool {
		if (fileContent == null || structure == null) return false;
		var lines:Array<String> = fileContent.split("\n");
		for (i in 0...lines.length) if (lines[i] == "<" + categoryName + ">") {
			if (lines[i] == "") break;
			if (lines[i].startsWith(name))
			{
				lines.splice(i, 1);
				fileContent = lines.join("\n");
				return true;
			}
		}
		return false;
	}

	public function setCategoryMapByName(categoryName:String, fields:Map<String, Dynamic>) {
		if (fileContent == null || structure == null) return;
		initializeCategory(categoryName, true);
		var str:String = "";
		for (n => v in fields) str += n + (v == null ? "" : ":" + v) + "\n";
		fileContent += str;
	}
	public function setCategoryArrayByName(categoryName:String, fields:Array<String>) {
		if (fileContent == null || structure == null) return;
		initializeCategory(categoryName, true);
		var str:String = "";
		for (th in fields) str += th + "\n";
		fileContent += str;
	}
	public function setCategoryStringByName(categoryName:String, fields:String) {
		if (fileContent == null || structure == null) return;
		initializeCategory(categoryName, true);
		fileContent += fields + "\n";
	}

	public function setValueByName(categoryName:String, name:String, value:Dynamic) {
		if (fileContent == null || structure == null) return;
		initializeCategory(categoryName);
		fileContent += name + (value == null ? "" : ":" + value) + "\n";
	}

	public function getCategoryByName(categoryName:String):Map<String, Dynamic> {
		if (fileContent == null || structure == null) return [];
		return structure.get(categoryName);
	}
	public function getValueByName(categoryName:String, name:String):Dynamic {
		if (fileContent == null || structure == null || !existsCategoryByName(categoryName)) return null;
		return structure.get(categoryName).get(name);
	}


	@:to public inline function toString():String {
		return fileContent.replace("<", "[").replace(">", "]");
	}

	// not supports numbers like 0x01020304
	public static function parseFloat(str:String):Float {
		for (th in str.replace("-", "").replace(".", "").split('')) if (Math.isNaN(Std.parseFloat(th))) return Math.NaN;
		return Std.parseFloat(str);
	}
}