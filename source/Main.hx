package;

import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxState;

import openfl.Lib;
import openfl.display.Sprite;
import openfl.events.Event;

import lime.app.Application;

using StringTools;

class Main extends Sprite
{
	public static var version(get, default):String;
	static function get_version():String {
		var curVersion:String = "2.1 (&CT)"; // &CT will be replaced by formatted compileTime

		var suffix:String = compileTime.substring(0, compileTime.indexOf(" ", compileTime.indexOf(" ") + 1)); // removing utc thing
		suffix = suffix.replace("-", ""); // removing underline
		suffix = suffix.replace(":", ""); // removing double dot
		suffix = suffix.replace(" ", "-"); // replacing space with underline
		if (curVersion.contains("&CT")) curVersion = curVersion.replace("&CT", suffix);
		return curVersion;
	}
	// public static var compileTime:String; exists too with macro hehe

	public static function main() Lib.current.addChild(new FlxGame(0, 0, MenuState, 60, 60, true, false));
}