package group;

import flixel.util.FlxColor;
import flixel.FlxSprite;

class ButtonsGroup extends Group {
	public var indicator:FlxSprite;

	public function new(x:Float, y:Float, ?width:Int, ?height:Int, options:INIParser) {
		super(x, y, width, height);

		for (n in options.indexes)
		{
			var v:Map<String, Dynamic> = options.getCategoryByName(n);
			if (StringTools.startsWith(n, "#")) continue;
			switch(v["displayMode"]) {
				case 0:
					add(makeButton(v["x"], v["y"], v["width"], v["height"], v["labelOffsetX"], v["labelOffsetY"], v["fontSize"], v["color"], n));
				case 1:
					add(makeInput(v["x"], v["y"], v["width"], v["value"], v["fontSize"], n));
			}
			if (n == "Indicator")
			{
				indicator = new FlxSprite(v["x"], v["y"]).makeGraphic(v["width"], v["height"], FlxColor.fromString("0x" + v["color"]));
				add(indicator);
			}
		}
	}
}