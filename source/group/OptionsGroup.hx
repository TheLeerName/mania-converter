package group;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.text.FlxText;
import flixel.addons.ui.FlxUISlider;

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

	public var sliders:Array<FlxUISlider> = [];

	public function new(x:Float = 0, y:Float = 0, ?width:Int = null, ?height:Int = null, options:INIParser)
	{
		super(x, y, width, height);

		mouseCheck = new FlxObject(x, y, width, height);

		scrollSpeed = options.getValueByName("#Basic settings#", "scrollSpeed") / 100;
		for (n in options.indexes)
		{
			var v:Map<String, Dynamic> = options.getCategoryByName(n);
			if (StringTools.startsWith(n, "#")) continue;

			add(new Text(v["x"], this.height + v["y"], n, v["description"]));
			switch (v["displayMode"]) {
				case 0:
					var obj = ClassShortcuts.makeSlider(v["displayX"], this.height + v["displayY"], v["width"], v["decimals"], v["value"], v["min"], v["max"], n);
					add(obj);
					sliders.push(obj);
				case 1:
					add(ClassShortcuts.makeDrop(v["displayX"], this.height + v["displayY"], Std.string(v["array"]).split(","), v["value"], n));
				case 2:
					add(ClassShortcuts.makeInput(v["displayX"], this.height + v["displayY"], v["width"], v["value"], v["fontSize"], n));
				case 3:
					add(ClassShortcuts.makeCheckbox(v["displayX"], this.height + v["displayY"], v["value"], n));
				default:
					// nothing
			}
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

class Text extends FlxText {
	public var description:String;
	public var mouseOverlaps(get, null):Bool;
	function get_mouseOverlaps():Bool
		return overlapsPoint(FlxG.mouse.getPositionInCameraView(cameras[0]), true, cameras[0]);

	public function new(x:Float, y:Float, text:String, description:String) {
		super(x, y, 0, text);
		this.description = description;
		setFormat(Paths.font("verdana.ttf"), 20, 0xff000000, LEFT);
	}
}