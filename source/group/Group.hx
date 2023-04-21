package group;

import flixel.addons.ui.FlxUI;
import flixel.FlxG;
import flixel.FlxCamera;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import flixel.group.FlxSpriteGroup;
import flixel.addons.ui.FlxUICheckBox;
import flixel.addons.ui.FlxUIInputText;
import flixel.addons.ui.FlxUIDropDownMenu;
import flixel.addons.ui.FlxUINumericStepper;

using StringTools;

class Group extends FlxSpriteGroup {

	public var cameraObject:FlxCamera;

	public function new(x:Float, y:Float, ?width:Int, ?height:Int, options:INIParser) {
		super();

		if (width == null) width = FlxG.width;
		if (height == null) height = FlxG.height;

		cameraObject = new FlxCamera();
		cameraObject.setPosition(x, y);
		cameraObject.setSize(width, height);
		cameraObject.bgColor.alpha = 0;
		FlxG.cameras.add(cameraObject, false);
		cameras = [cameraObject];
	}

	function makeText(x:Float, y:Float, text:String)
	{
		var txt:FlxText = new FlxText(x, this.height + y, Std.int(width), text);
		txt.setFormat(Paths.get.font("verdana.ttf"), 20, 0xff000000, LEFT);
		return txt;
	}
	function makeNum(x:Float, y:Float, step:Float, value:Float, min:Float, max:Float, text:String)
	{
		var d:FlxUINumericStepper = new FlxUINumericStepper(x, this.height + y, step, value, min, max);
		d.name = text;
		return d;
	}
	function makeDrop(x:Float, y:Float, array:Array<String>, value:String, text:String)
	{
		var d:FlxUIDropDownMenu = new FlxUIDropDownMenu(x, this.height + y, FlxUIDropDownMenu.makeStrIdLabelArray(array, true));
		d.selectedLabel = array[0];
		d.dropDirection = Up;
		d.name = text;
		d.selectedId = value;
		return d;
	}
	function makeInput(x:Float, y:Float, width:Int, value:String, size:Int, text:String)
	{
		var d:FlxUIInputText = new FlxUIInputText(x, this.height + y, width, "");
		d.setFormat(Paths.get.font('verdana'), size, FlxColor.BLACK);
		d.text = value;
		d.name = text;
		return d;
	}
	function makeCheckbox(x:Float, y:Float, value:Bool, text:String)
	{
		var d:FlxUICheckBox = new FlxUICheckBox(x, this.height + y, null, null, "", 100);
		d.box.scale.set(1.5, 1.5);
		d.mark.scale.set(1.5, 1.5);
		d.name = text;
		d.checked = value;
		return d;
	}

	public function makeButton(x:Float, y:Float, width:Int, height:Int, offset_x:Float, offset_y:Float, size:Int, color:String, name:String):FlxButton {
		var button:FlxButton = new FlxButton(x, y, name);
		button.setGraphicSize(width, height);
		button.updateHitbox();
		button.color = FlxColor.fromString("0x" + color);
		button.label.setFormat(Paths.get.font("vendana"), size, FlxColor.fromString('0xFF000000'), CENTER);
		setAllLabelsOffset(button, offset_x, offset_y);
		button.label.fieldWidth = width;
		return button;
	}
	public function setAllLabelsOffset(button:FlxButton, x:Float, y:Float) {
		for (point in button.labelOffsets)
			point.set(x, y);
	}

	public function hideAllDropDowns()
	{
		for (th in members) if (th is FlxUIDropDownMenu)
		{
			var dropdown:FlxUIDropDownMenu = cast th;
			@:privateAccess dropdown.showList(false);
		}
	}
	public function setCallback(name:String, callback:Void->Void) {
		for (th in members) if (th is FlxButton) {
			var raaah:FlxButton = cast th;
			if (raaah.label.text == name) {
				raaah.onUp.callback = callback;
				break;
			}
		}
	}
	public function setInputText(name:String, text:String) {
		for (th in members) if (th is FlxUIInputText) {
			var raaah:FlxUIInputText = cast th;
			if (raaah.name == name) {
				raaah.text = text;
				FlxUI.event(FlxUIInputText.CHANGE_EVENT, raaah, raaah.text, raaah.params);
				break;
			}
		}
	}
}