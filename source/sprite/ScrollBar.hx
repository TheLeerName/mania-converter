package sprite;

/*
   |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
   ||     ||     ||  || |||   |||     |||||||||     ||     ||  || || ||| ||     ||     ||     ||     ||     |||||||||     |||||||||     ||
   || | | || ||| ||   | |||| |||| ||| ||||||||| |||||| ||| ||   | || ||| || |||||| ||| |||| |||| |||||| ||| ||||||||||||| ||||||||| ||| ||
   || | | || ||| || | | |||| |||| ||| ||||||||| |||||| ||| || | | || ||| ||     ||   |||||| ||||     ||   |||||||||||     ||||||||| ||| ||
   || | | ||     || |   |||| ||||     ||||||||| |||||| ||| || |   ||| | ||| |||||| || ||||| |||| |||||| ||  ||||||||||||| ||||||||| ||| ||
   || | | || ||| || ||  |||   ||| ||| |||||||||     ||     || ||  |||| ||||     || ||| |||| ||||     || ||| |||||||||     |||   |||     ||
   |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
*/

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxCamera;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.group.FlxSpriteGroup;

/**
 * Class for making vertical scroll bar, like in Windows explorer
 * @author TheLeerName
 */
class ScrollBar extends FlxSpriteGroup {
	/**
	 * A `FlxSprite` object of moving thing of scroll bar
	 */
	public var movingThing:FlxSprite;
	/**
	 * A `FlxSprite` object of static (bg) thing of scroll bar
	 */
	public var staticThing:FlxSprite;

	/**
	 * Is scroll bar moving by cursor?
	 */
	public var moving:Bool = false;

	/**
	 * Current value. Like current position of moving thing in scroll bar, but in percent value
	 */
	public var value(get, set):Float;
	private function get_value():Float return _value;
	private function set_value(v:Float):Float {
		if (v < 0) v = 0;
		if (v > 1) v = 1;
		//trace(movingThing.y - staticThing.y * (1 - v), v);
		movingThing.y = staticThing.y + ((staticThing.height - movingThing.height) * v);
		return _value = v;
	}
	private var _value:Float = 0;

	/**
	 * Height for calculating `value`. Automatically changes height of moving thing. Can't be less than `height`!
	 */
	public var scrollHeight(default, set):Int = 0;
	function set_scrollHeight(value:Int):Int {
		if (staticThing == null || movingThing == null) return scrollHeight = value;
		if (scrollHeight < Std.int(staticThing.height)) value = Std.int(staticThing.height);
		movingThing.height = staticThing.height - (value % staticThing.height);
		return scrollHeight = value;
	}

	/**
	 * Some options for scroll bar
	 */
	public var options(default, set):MTOptions = {
		colorStatic: 0xffffffff,
		colorMoving: 0xff000000,
		alphaStatic: 0.25,
		alphaPlace: 0.5,
		alphaMoving: 0.75
	};
	function set_options(value:MTOptions):MTOptions {
		staticThing.color = value.colorStatic;
		movingThing.color = value.colorMoving;
		movingThing.alpha = moving ? options.alphaMoving : (mouseOverlaps(movingThing, cameras[0]) ? options.alphaPlace : options.alphaStatic);
		return options = value;
	}

	/**
	 * Creates a new `ScrollBar` object
	 * @param x X coordinate of scroll bar
	 * @param y Y coordinate of scroll bar
	 * @param width Width of scroll bar
	 * @param height Height of scroll bar
	 * @param scrollHeight Height for calculating `value`. Can't be less than `height`!
	 */
	public function new(x:Float = 0, y:Float = 0, ?width:Int, ?height:Int, ?scrollHeight:Int) {
		super();
		if (width == null) width = FlxG.width;
		if (height == null) height = FlxG.height;

		if (scrollHeight == null || scrollHeight < height) this.scrollHeight = scrollHeight = height;

		staticThing = new FlxSprite(x, y).makeGraphic(width, height, options.colorStatic);
		add(staticThing);

		movingThing = new FlxSprite(x, y).makeGraphic(width, height - (scrollHeight % height), options.colorMoving);
		add(movingThing);
	}

	var mouseOffsetY:Float = 0;
	public override function update(elapsed:Float) {
		super.update(elapsed);

		if (FlxG.mouse.justPressed && mouseOverlaps(movingThing, cameras[0]))
		{
			mouseOffsetY = FlxG.mouse.y - movingThing.y;
			moving = true;
		}
		if (FlxG.mouse.justReleased) moving = false;
		if (moving)
		{
			movingThing.y = FlxG.mouse.y - mouseOffsetY;
			if (movingThing.y < staticThing.y) movingThing.y = staticThing.y;
			if ((movingThing.y + movingThing.height) > (staticThing.y + staticThing.height)) movingThing.y = staticThing.y + staticThing.height - movingThing.height;
			_value = (movingThing.y - staticThing.y) / (staticThing.height - movingThing.height);
		}

		movingThing.alpha = moving ? options.alphaMoving : (mouseOverlaps(movingThing, cameras[0]) ? options.alphaPlace : options.alphaStatic);
	}

	private function mouseOverlaps(obj:FlxObject, ?camera:FlxCamera)
		return obj.overlapsPoint(FlxG.mouse.getPositionInCameraView(camera != null ? camera : FlxG.camera), true, camera != null ? camera : FlxG.camera);
}

/**
 * Some options of scroll bar
 * @param colorMoving Color of moving thing
 * @param colorStatic Color of static thing
 * @param alphaStatic Alpha value of moving thing, when cursor is not on scroll bar
 * @param alphaPlace Alpha value of moving thing, when cursor is not on scroll bar, but not moving
 * @param alphaMoving Alpha value of moving thing, when cursor moves scroll bar
 */
 typedef MTOptions = {
	var colorMoving:FlxColor;
	var colorStatic:FlxColor;
	var alphaStatic:Float;
	var alphaPlace:Float;
	var alphaMoving:Float;
}