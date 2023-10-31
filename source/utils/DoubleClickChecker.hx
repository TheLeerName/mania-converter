package utils;

import flixel.FlxG;
import flixel.FlxBasic;

class DoubleClickChecker extends FlxBasic {

	public var onClick:Void->Void = () -> {};
	public var onDoubleClick:Void->Void = () -> {};
	public var maxDoubleClickTime:Float = 0.5; // in seconds

	public function new() { super(); }

	var mouseTime:Float = 0;
	var mouseClicked:Bool = false;

	override function update(elapsed:Float) {
		super.update(elapsed);

		if (mouseClicked) {
			mouseTime -= elapsed;
			if (mouseTime <= 0)
				mouseClicked = false;
		}

		if (FlxG.mouse.justPressed) {
			if (mouseClicked) {
				onClick();
				onDoubleClick();
				mouseTime = 0;
				mouseClicked = false;
			}
			else {
				onClick();
				mouseTime = maxDoubleClickTime;
				mouseClicked = true;
			}
		}
	}
}