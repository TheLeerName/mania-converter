package group;

import flixel.FlxG;
import flixel.FlxObject;

import sprite.ScrollBar;

class OptionsGroup extends Group {

	var mouseCheck:FlxObject;

	var scrollSpeed:Float = 0;

	var actualHeight(get, default):Int;
	function get_actualHeight():Int {
		var theheight:Float = 0;
		for (th in members) theheight += th.height;
		return Std.int(theheight);
	}

	var scrollBar:ScrollBar;

	public var descriptions:Map<String, String> = [];

	public function new(x:Float = 0, y:Float = 0, ?width:Int = null, ?height:Int = null, options:INIParser)
	{
		super(x, y, width, height);

		mouseCheck = new FlxObject(x, y, width, height);

		scrollSpeed = options.getValueByName("#Basic settings#", "scrollSpeed") / 100;
		for (n in options.indexes)
		{
			var v:Map<String, Dynamic> = options.getCategoryByName(n);
			if (StringTools.startsWith(n, "#")) continue;

			add(makeText(v["x"], v["y"], n));
			switch (v["displayMode"]) {
				case 0:
					add(makeSlider(v["displayX"], v["displayY"], v["width"], v["decimals"], v["value"], v["min"], v["max"], n));
				case 1:
					add(makeDrop(v["displayX"], v["displayY"], v["array"], v["value"], n));
				case 2:
					add(makeInput(v["displayX"], v["displayY"], v["width"], v["value"], v["fontSize"], n));
				case 3:
					add(makeCheckbox(v["displayX"], v["displayY"], v["value"], n));
				default:
					// nothing
			}
			descriptions.set(n, v["description"]);
		}

		scrollBar = new ScrollBar(cameraObject.x + cameraObject.width - 10, cameraObject.y, 10, cameraObject.height, Std.int(actualHeight + cameraObject.y));
		FlxG.state.add(scrollBar);
	}

	public override function update(elapsed:Float)
	{
		super.update(elapsed);

		// for some reason it crashes when i trying check it with cameraObject :(
		if (FlxG.mouse.overlaps(mouseCheck, cameras[0]) && FlxG.mouse.wheel != 0)
		{
			hideAllDropDowns();
			scrollBar.value -= (FlxG.mouse.wheel > 0 ? scrollSpeed : -scrollSpeed);
			//y = (cameraObject.height - height)
			//y += ;
			//if (y > 0) y = 0;
			//if ((y + height) < cameraObject.height) y = (cameraObject.height - height);
		}
		//else if (scrollBar.moving)
		y = Std.int((cameraObject.height - height) * scrollBar.value);
	}
}