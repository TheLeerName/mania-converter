package;

import lime.utils.Assets;
#if sys
import sys.FileSystem;
import sys.io.File;
#end

using StringTools;

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

	public function load(file:String):INIParser {
		#if sys
		if (Assets.exists(file, TEXT)) file = Assets.getText(file);
		else if (FileSystem.exists(file)) file = File.getContent(file);
		if (!file.contains("[")) return null;
		fileContent = file;
		#end
		return this;
	}
	public function save(path:String) {
		#if sys
		File.saveContent(path, fileContent);
		#end
	}

	function generateStructure() {
		if (structure != []) structure = [];
		if (indexes != []) indexes = [];
		//switch (version)
		//{
			//case 1:
				for (cat in fileContent.split("["))
				{
					if (!cat.contains("]")) continue;
					var stru:Map<String, Dynamic> = [];
					for (line in cat.split("\n"))
					{
						if (line.contains("\r")) line = line.replace("\r", "");
						if (line.contains("\n")) line = line.replace("\n", "");

						if (line.length == 0) break;
						if (line.startsWith("//")) continue;
						if (!line.contains(":")) continue;

						if (line.contains(":"))
						{
							var value:Any = resolveValueFromString(line.substring(line.lastIndexOf(":") + 1));
							stru.set(line.substring(0, line.lastIndexOf(":")), value);
						}
						else
							stru.set(line, null);
					}
					structure.set(cat.substring(0, cat.indexOf("]")), stru);
					indexes.push(cat.substring(0, cat.indexOf("]")));
					//trace(struc.length);
				}
			//default:
				// nothing
		//}
	}

	function resolveValueFromString(value:String):Any {
		if (Std.string(Std.parseFloat(value)) != "nan") return Std.parseFloat(value);
		if (Std.string(value) == "true") return true;
		if (Std.string(value) == "false") return false;
		if (Std.string(value).contains(",")) return value.split(",");
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
		for (i in 0...lines.length) if (lines[i] == "[" + categoryName + "]") {
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
		for (i in 0...lines.length) if (lines[i] == "[" + categoryName + "]") {
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

	public function setCategoryByName(categoryName:String, fields:Map<String, Dynamic>) {
		if (fileContent == null || structure == null) return;
		initializeCategory(categoryName, true);
		for (n => v in fields) fileContent += n + ":" + v + "\n";
	}
	public function setValueByName(categoryName:String, name:String, value:Dynamic) {
		if (fileContent == null || structure == null) return;
		initializeCategory(categoryName);
		fileContent += name + ":" + value + "\n";
	}

	public function getCategoryByName(categoryName:String):Map<String, Dynamic> {
		if (fileContent == null || structure == null) return [];
		return structure.get(categoryName);
	}
	public function getValueByName(categoryName:String, name:String):Dynamic {
		if (fileContent == null || structure == null || !existsCategoryByName(categoryName)) return null;
		return structure.get(categoryName).get(name);
	}
}