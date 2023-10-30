package group;

import flixel.FlxSprite;
import flixel.util.FlxColor;

class ButtonsGroup extends Group {
	public var indicator:FlxSprite;
	public var indicatorColors:Array<FlxColor> = [];
	public var indicatorEnabled(default, set):Bool = false;
	function set_indicatorEnabled(value:Bool):Bool {
		indicator.color = indicatorColors[value ? 1 : 0];
		return indicatorEnabled = value;
	}

	public function new(x:Float, y:Float, ?width:Int, ?height:Int, options:INIParser) {
		super(x, y, width, height);

		for (n in options.indexes)
		{
			var v:Map<String, Dynamic> = options.getCategoryByName(n);
			if (StringTools.startsWith(n, "#")) continue;
			switch(v["displayMode"]) {
				case 0:
					add(ClassShortcuts.makeButton(v["x"], v["y"], v["width"], v["height"], v["labelOffsetX"], v["labelOffsetY"], v["fontSize"], v["color"], n));
				case 1:
					add(ClassShortcuts.makeInput(v["x"], v["y"], v["width"], v["value"], v["fontSize"], n));
			}
			if (n == "Indicator")
			{
				indicator = new FlxSprite(v["x"], v["y"]).makeGraphic(v["width"], v["height"]);
				indicatorColors = [v["colorDisabled"], v["colorEnabled"]];
				indicatorEnabled = false;
				add(indicator);
			}
		}
	}
}