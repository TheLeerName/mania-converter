package;

import converter.Converter;
import flixel.FlxG;
import flixel.FlxBasic;
import flixel.FlxState;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.input.keyboard.FlxKey;
import flixel.ui.FlxButton;
import flixel.addons.ui.FlxUIState;
import flixel.addons.ui.FlxUINumericStepper;
import flixel.addons.ui.FlxButtonPlus;
import flixel.addons.ui.FlxUIInputText;
import flixel.addons.ui.FlxUIDropDownMenu;
import flixel.addons.ui.FlxUINumericStepper;
import flixel.addons.ui.FlxUICheckBox;

import openfl.events.Event;
import openfl.events.IOErrorEvent;

import lime.system.System;
import lime.ui.FileDialog;
import lime.ui.FileDialogType;
import lime.app.Application;

import group.OptionsGroup;
import group.ButtonsGroup;

#if sys
import sys.FileSystem;
#end

using StringTools;

typedef ThingsMenu = {
	var textOffsets:Array<Int>;
	var text:String;
	var displayMode:String;

	var displayOffsets:Array<Int>;
	// num
	@:optional var step:Float;
	@:optional var value:Dynamic;
	@:optional var min:Float;
	@:optional var max:Float;
	// drop
	@:optional var array:Array<String>;
}

class MenuState extends FlxUIState
{
	var pathfile_input:FlxUIInputText;
	var format:String = 'osu';
	
	var ads:FlxText;
	var title:FlxText;

	var optionsGroup:OptionsGroup;
	var buttonsGroup:ButtonsGroup;

	var defaultOptions:Map<String, Dynamic> = [];
	var options:Map<String, Dynamic> = [];

	override public function create() {
		super.create();
		Application.current.window.onClose.add(onClose);

		FlxG.mouse.useSystemCursor = true;

		//var json = Paths.get.parseJSON('hui.json');

		//var bg:FlxSprite = new FlxSprite().loadGraphic('assets/bg.png');
		//add(bg);
		//generateScrollOptions();

		var options:Map<String, Dynamic> = new INIParser().load("assets/basic.ini").getCategoryByName("#Basic settings#");
		//ini.setCategoryByName("fuck you", ["fuck" => 1, "you" => true]);
		//trace(ini.getValueByName("fuck you", "you"));
		//ini.saveContent("kys.ini");
		//ini.load("menu.ini");

		var bg1:FlxSprite = new FlxSprite(options["headerX"], options["headerY"]).makeGraphic(options["headerWidth"], options["headerHeight"], FlxColor.fromString('0x' + options["headerColor"]));
		add(bg1);
		var bg2:FlxSprite = new FlxSprite(options["thingsX"], options["thingsY"]).makeGraphic(options["thingsWidth"], options["thingsHeight"], FlxColor.fromString('0x' + options["thingsColor"]));
		add(bg2);
		var bg3:FlxSprite = new FlxSprite(options["buttonsX"], options["buttonsY"]).makeGraphic(options["buttonsWidth"], options["buttonsHeight"], FlxColor.fromString('0x' + options["buttonsColor"]));
		add(bg3);

		title = makeText(40, 15, 0, "Mania Converter", 30, 'verdana', 'EDFFC9');
		add(title);

		optionsGroup = new OptionsGroup(bg2.x, bg2.y, Std.int(bg2.width), Std.int(bg2.height), new INIParser().load("assets/options.ini"));
		add(optionsGroup);

		buttonsGroup = new ButtonsGroup(bg3.x, bg3.y, Std.int(bg3.width), Std.int(bg3.height), new INIParser().load("assets/buttons.ini"));
		add(buttonsGroup);
		buttonsGroup.setCallback("Browse...", function () {
			var fd:FileDialog = new FileDialog();
			fd.onSelect.add(function(str:String) {
				buttonsGroup.setInputText("File path", str);
				var converter:Converter = new Converter().load(str);
			});
			fd.browse(FileDialogType.OPEN, null, System.documentsDirectory);
		});

		initializeOptions();
		//generateButtons();
	}

	public override function destroy() {
		super.destroy();
		onClose();
	}

	public function onClose() {
		saveOptions();
	}

	function getOptions():Map<String, Dynamic> {
		var ini:INIParser = new INIParser().load("assets/save.ini");
		if (ini == null) return defaultOptions;
		var options:Map<String, Dynamic> = ini.getCategoryByName("#Basic settings#");
		for (n => v in defaultOptions) if (options.get(n) == null) options.set(n, v);
		return options;
	}
	function saveOptions() {
		var ini:INIParser = new INIParser();
		ini.setCategoryByName("#Basic settings#", []);
		for (n => v in defaultOptions) ini.setValueByName("#Basic settings#", n, options.get(n));
		ini.save("assets/save.ini");
		trace("Options saved!");
	}

	function setOptionsValues() {
		for (th in buttonsGroup)
		{
			if (th is FlxUIInputText)
			{
				var nums:FlxUIInputText = cast th;
				nums.text = options[nums.name];
			}
		}
		for (th in optionsGroup)
		{
			if (th is FlxUICheckBox)
			{
				var nums:FlxUICheckBox = cast th;
				nums.checked = options[nums.name];
			}
			else if (th is FlxUINumericStepper)
			{
				var nums:FlxUINumericStepper = cast th;
				nums.value = options[nums.name];
			}
			else if (th is FlxUIInputText)
			{
				var nums:FlxUIInputText = cast th;
				nums.text = options[nums.name];
			}
			else if (th is FlxUIDropDownMenu)
			{
				var nums:FlxUIDropDownMenu = cast th;
				nums.selectedId = options[nums.name];
			}
		}
	}
	function initializeOptions() {
		for (th in buttonsGroup)
		{
			if (th is FlxUIInputText)
			{
				var nums:FlxUIInputText = cast th;
				defaultOptions[nums.name] = nums.text;
			}
		}
		for (th in optionsGroup)
		{
			if (th is FlxUICheckBox)
			{
				var nums:FlxUICheckBox = cast th;
				defaultOptions[nums.name] = nums.checked;
			}
			else if (th is FlxUINumericStepper)
			{
				var nums:FlxUINumericStepper = cast th;
				defaultOptions[nums.name] = nums.value;
			}
			else if (th is FlxUIInputText)
			{
				var nums:FlxUIInputText = cast th;
				defaultOptions[nums.name] = nums.text;
			}
			else if (th is FlxUIDropDownMenu)
			{
				var nums:FlxUIDropDownMenu = cast th;
				defaultOptions[nums.name] = Std.parseInt(nums.selectedId);
			}
		}
		options = getOptions();
		setOptionsValues();
	}

	override function getEvent(id:String, sender:Dynamic, data:Dynamic, ?params:Array<Dynamic>)
	{
		switch(id)
		{
			case FlxUICheckBox.CLICK_EVENT:
				var nums:FlxUICheckBox = cast sender;
				var wname = nums.name;

				options[wname] = nums.checked;
				//trace(wname + ': ' + nums.checked);
			case FlxUINumericStepper.CHANGE_EVENT:
				var nums:FlxUINumericStepper = cast sender;
				var wname = nums.name;

				options[wname] = nums.value;
				//trace(wname + ': ' + nums.value);
			case FlxUIInputText.CHANGE_EVENT:
				var nums:FlxUIInputText = cast sender;
				var wname = nums.name;

				options[wname] = nums.text;
				//trace(wname + ': ' + nums.text);
			case FlxUIDropDownMenu.CLICK_EVENT:
				var nums:FlxUIDropDownMenu = cast sender;
				var wname = nums.name;

				options[wname] = Std.parseInt(nums.selectedId);
				//trace(wname + ': ' + Std.parseInt(nums.selectedId));
		}
	}

	public function makeText(x:Float = 0, y:Float = 0, width:Float = 0, text:String = '', size:Int = 8, font:String = 'vcr', color:String = 'FFFFFF') {
		return new FlxText(x, y, width, text, size).setFormat(Paths.get.font(font), size, FlxColor.fromString('0xFF' + color));
	}

	var generatedSO:Bool = false;
/*
	function generateButtons()
	{
		

		var pathfile_label:FlxText = Paths.get.text(660, -1, 0, "URL or path to map", 20, 'verdana', 'E5FD5B');
		add(pathfile_label);
		pathfile_input = new FlxUIInputText(650, 30, 350, "", 11);
		pathfile_input.setFormat(Paths.get.font('arial'), 14, FlxColor.BLACK);
		add(pathfile_input);

		var browse_button:FlxButton = new FlxButton(1000, 29, "Browse...", function()
		{
			trace('poop');
		});
		browse_button = buttons(browse_button, 90, 19, 0, -1, 14);
		add(browse_button);
		
		var convert_osu_button:FlxButton = new FlxButton(3, 81, "Convert to osu!mania", function()
		{
			trace('poop');
		});
		convert_osu_button = buttons(convert_osu_button, 110, 55, -2, 9, 18, 'arial', '49F6FF');
		add(convert_osu_button);
		convert_osu_button.color = FlxColor.PURPLE;
		
		//ads = Paths.get.text(10, 450, 0, "", 14, 'verdana', '000000');
		//add(ads);
	}
	function buttons(button:FlxButton, width:Int, height:Int, offset_x:Float, offset_y:Float, size:Int, font:String = 'vendana', color:String = '000000'):FlxButton {
		button.setGraphicSize(width, height);
		button.updateHitbox();
		button.label.setFormat(Paths.get.font(font), size, FlxColor.fromString('0xFF' + color), CENTER);
		setAllLabelsOffset(button, offset_x, offset_y);
		button.label.fieldWidth = width;
		return button;
	}
	function setAllLabelsOffset(button:FlxButton, x:Float, y:Float) {
		for (point in button.labelOffsets)
			point.set(x, y);
	}

	function loadMap(path:String) {
		if (path.startsWith('https://') && path.startsWith('http://'))
		{
			trace('not supported');
		}
		else if (Paths.get.exists(path))
		{
			var f:Array<Dynamic> = defineFormat(path);
			var format = f[0];
			var file = f[1];
			switch(format) {
				case 'json':
					trace('foo');
				case 'osu':
					trace('foo');
				default:
					Application.current.window.alert("Unsupported map format, only fnf json or osu file v14", "Load Map Error");
					return;
			}
		}
		else
		{
			Application.current.window.alert("Map is not exist", "Load Map Error");
			return;
		}
	}
	function defineFormat(path:String):Array<Dynamic>
	{
		if (Paths.get.isJSON(path))
		{
			return ['json', Paths.get.parseJSON(path)];
		}
		else
		{
			var map:Array<String> = Paths.get.parseTXT(path);
			if (map[0].startsWith('osu file format v14'))
			{
				return ['osu', map];
			}
			else
			{
				return ['unsupported', null];
			}
		}
	}*/

	override public function update(elapsed:Float) {
		super.update(elapsed);

		if (FlxG.keys.justPressed.U)
			FlxG.switchState(new MenuState());
		/*if (pathfile_input.hasFocus && FlxG.keys.justPressed.ENTER)
			loadMap(pathfile_input.text);*/

		//ads.text = 'Y: ' + scroll[0].y + ' | H: ' + (scroll[scroll.length - 1].y + scroll[scroll.length - 1].height) + ' | Wheel: ' + FlxG.mouse.wheel;
	}
}