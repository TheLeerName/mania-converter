package;

import flixel.FlxGame;

import openfl.Lib;
import openfl.display.Sprite;

import lime.app.Application;

import utils.INIParser;
import utils.converter.Converter;

using StringTools;

class Main extends Sprite
{
	public static var version(get, default):String;
	static function get_version():String {
		var curVersion:String = "3.0 (&CT)"; // &CT will be replaced by formatted compileTime

		var suffix:String = compileTime.substring(0, compileTime.indexOf(" ", compileTime.indexOf(" ") + 1)); // removing utc thing
		suffix = suffix.replace("-", ""); // removing underline
		suffix = suffix.replace(":", ""); // removing double dot
		suffix = suffix.replace(" ", "-"); // replacing space with underline
		if (curVersion.contains("&CT")) curVersion = curVersion.replace("&CT", suffix);
		return curVersion;
	}
	// public static var compileTime:String; exists too with macro hehe

	public static function main() {
		Lib.current.addChild(new FlxGame(0, 0, MenuState, 10, 10, true, false));
		if (Sys.args().length >= 2) {
			var converter = new Converter();
			converter.load(Sys.args()[0], new INIParser().load("assets/menu/save.ini").getCategoryByName("#Basic settings#"));
			if (converter.structure == null) Application.current.window.close();
			if (Sys.args()[1].endsWith(".osu"))
				converter.saveAsOSU(Sys.args()[1]);
			else
				converter.saveAsJSON(Sys.args()[1]);
			Application.current.window.close();
		}
	}


}