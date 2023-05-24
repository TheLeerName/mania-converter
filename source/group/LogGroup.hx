package group;

import flixel.text.FlxText;
import flixel.util.FlxColor;

class LogGroup extends Group {
	public function new(x:Float, y:Float, ?width:Int, ?height:Int) {
		super(x, y, width, height);
	}

	public function log(text:String, color:FlxColor = 0xffffffff) {
		var txt:FlxText = new FlxText(0, 0, Std.int(cameraObject.width), text);
		txt.setFormat(Paths.font("verdana.ttf"), 10, color, LEFT);
		txt.y = cameraObject.width - txt.height;
		for (th in members) if (th is FlxText) th.y -= txt.height;
		add(txt);
		Paths.log("[Mania Converter] " + text);
	}
}