package group;

import flixel.FlxG;
import flixel.FlxCamera;
import flixel.ui.FlxButton;
import flixel.group.FlxSpriteGroup;
import flixel.addons.ui.FlxUI;
import flixel.addons.ui.FlxUIInputText;
import flixel.addons.ui.FlxUIDropDownMenu;

class Group extends FlxSpriteGroup {

	public var cameraObject:FlxCamera;

	public function new(x:Float, y:Float, ?width:Int, ?height:Int) {
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
	public function setFocusCallback(name:String, callback:Void->Void) {
		for (th in members) if (th is FlxUIInputText) {
			var raaah:FlxUIInputText = cast th;
			if (raaah.name == name) {
				raaah.focusGained = callback;
				raaah.focusLost = callback;
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
				trace("bruh! updated!");
				break;
			}
		}
	}
}