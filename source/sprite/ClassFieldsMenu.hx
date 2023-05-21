package sprite;

#if sys
import sys.FileSystem;
#end

using StringTools;

#if !macro
import flixel.group.FlxSpriteGroup;

class ClassFieldsMenu extends FlxSpriteGroup {
	public static var classFields(get, never):Array<String>;
	static function get_classFields():Array<String> return _classFieldsStr.replace('source/', '').replace('/', '.').split(',');

	override function new() {
		super();
	}
}

#else
import haxe.macro.Expr;
import macros.MacroUtils;

class ClassFieldsMacro {
	public static function addClassFieldsVar() {
		MacroUtils.addStringFromCompiler("sprite.ClassFieldsMenu", "_classFieldsStr", getClassFields('source').join(','), 'private static');
	}

	public static function getClassFields(classPath:String):Array<String>
	{
		if (!classPath.endsWith("/") && !classPath.endsWith("\\")) classPath = classPath + "/";
		var arrayToReturn:Array<String> = [];
		#if sys
		if (FileSystem.exists(classPath) && FileSystem.isDirectory(classPath)) for (className in FileSystem.readDirectory(classPath)) {
			if (className.endsWith(".hx") && className != "import.hx")
				arrayToReturn.push(classPath + className.substring(0, className.lastIndexOf('.')));
			else if (FileSystem.exists(classPath + className) && FileSystem.isDirectory(classPath + className)) for (classNameChild in getClassFields(classPath + className)) {
				arrayToReturn.push(classNameChild);
			}
		}
		#end
		return arrayToReturn;
	}
}
#end