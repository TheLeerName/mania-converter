package group;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;

class DescriptionGroup extends Group {
	public var txt:FlxText;
	public var desc(default, set):String;
	function set_desc(value:String):String {
		if (desc == value) return value;
		if (value == "")
		{
			txt.text = "Hover mouse on label to see desc!";
			return desc = value;
		}
		return txt.text = desc = value;
	}

	public function new(x:Float, y:Float, ?width:Int, ?height:Int) {
		super(x, y, width, height);

		txt = new FlxText(0, 0, width, "");
		txt.setFormat(Paths.font("verdana.ttf"), 12, 0xff000000, LEFT);
		add(txt);
	}
}