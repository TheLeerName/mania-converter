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
	public static function main():Void
	{
		Lib.current.addChild(new FlxGame(0, 0, MenuState, 60, 60, true, false));
	}
}