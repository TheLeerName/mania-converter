package utils;

import flixel.FlxG;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.ui.FlxButton;
import flixel.addons.ui.FlxUI;
import flixel.addons.ui.FlxUICheckBox;
import flixel.addons.ui.FlxUIInputText;
import flixel.addons.ui.FlxUIDropDownMenu;
import flixel.addons.ui.FlxUISlider;

class ClassShortcuts {
    public static function makeSlider(x:Float, y:Float, width:Int, decimals:Int, value:Float, min:Float, max:Float, text:String):FlxUISlider
	{
		var d:FlxUISlider = new FlxUISlider(FlxG.state, null, x, y, min, max, width, null, 5, 0xff979797, 0xff000000);
		d.value = value;
		d.decimals = decimals;
		d.name = text;
		return d;
	}

    public static function makeDrop(x:Float, y:Float, array:Array<String>, value:Int, text:String):FlxUIDropDownMenu
	{
		var d:FlxUIDropDownMenu = new FlxUIDropDownMenu(x, y, FlxUIDropDownMenu.makeStrIdLabelArray(array, true));
		d.selectedLabel = array[0];
		d.dropDirection = Up;
		d.name = text;
		d.selectedId = value + "";
		return d;
	}

    public static function makeInput(x:Float, y:Float, width:Int, value:String, size:Int, text:String):FlxUIInputText
	{
		var d:FlxUIInputText = new FlxUIInputText(x, y, width, "");
		d.setFormat(Paths.font('verdana'), size, FlxColor.BLACK);
		d.text = value;
		d.name = text;
		return d;
	}

    public static function makeCheckbox(x:Float, y:Float, value:Bool, text:String):FlxUICheckBox
	{
		var d:FlxUICheckBox = new FlxUICheckBox(x, y, null, null, "", 100);
		d.box.scale.set(1.5, 1.5);
		d.mark.scale.set(1.5, 1.5);
		d.name = text;
		d.checked = value;
		return d;
	}

    public static function makeButton(x:Float, y:Float, width:Int, height:Int, offset_x:Float, offset_y:Float, size:Int, color:FlxColor, name:String):FlxButton {
		var button:FlxButton = new FlxButton(x, y, name);
		button.setGraphicSize(width, height);
		button.updateHitbox();
		button.color = color;
		button.label.setFormat(Paths.font("vendana"), size, 0xFF000000, CENTER);
		setAllLabelsOffset(button, offset_x, offset_y);
		button.label.fieldWidth = width;
		return button;
	}

    public static function setAllLabelsOffset(button:FlxButton, x:Float, y:Float) {
		for (point in button.labelOffsets)
			point.set(x, y);
	}
}