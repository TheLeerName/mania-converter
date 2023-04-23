package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.addons.ui.FlxUIState;
import flixel.addons.ui.FlxUIInputText;
import flixel.addons.ui.FlxUIDropDownMenu;
import flixel.addons.ui.FlxUISlider;
import flixel.addons.ui.FlxUICheckBox;

import lime.app.Application;
import lime.ui.FileDialog;
import lime.ui.FileDialogType;
import lime.system.System;

import group.OptionsGroup;
import group.ButtonsGroup;
import group.LogGroup;

import parser.Converter;
import parser.INIParser;

using StringTools;

class MenuState extends FlxUIState
{
	var pathfile_input:FlxUIInputText;
	var format:String = 'osu';
	
	var ads:FlxText;
	var title:FlxText;

	var optionsGroup:OptionsGroup;
	var buttonsGroup:ButtonsGroup;
	var logGroup:LogGroup;

	var defaultOptions:Map<String, Dynamic> = [];
	var options:Map<String, Dynamic> = [];

	var converter:Converter;

	override public function create() {
		super.create();
		Application.current.window.onClose.add(onClose);

		FlxG.mouse.useSystemCursor = true;

		//var json = Paths.get.parseJSON('hui.json');

		//var bg:FlxSprite = new FlxSprite().loadGraphic('assets/menu/bg.png');
		//add(bg);
		//generateScrollOptions();

		var basicOptions:Map<String, Dynamic> = new INIParser().load("assets/menu/basic.ini").getCategoryByName("#Basic settings#");
		//ini.setCategoryByName("fuck you", ["fuck" => 1, "you" => true]);
		//trace(ini.getValueByName("fuck you", "you"));
		//ini.saveContent("kys.ini");
		//ini.load("menu.ini");
		converter = new Converter();

		var bg1:FlxSprite = new FlxSprite(basicOptions["headerX"], basicOptions["headerY"]).makeGraphic(basicOptions["headerWidth"], basicOptions["headerHeight"], FlxColor.fromString('0x' + basicOptions["headerColor"]));
		add(bg1);
		var bg2:FlxSprite = new FlxSprite(basicOptions["thingsX"], basicOptions["thingsY"]).makeGraphic(basicOptions["thingsWidth"], basicOptions["thingsHeight"], FlxColor.fromString('0x' + basicOptions["thingsColor"]));
		add(bg2);
		var bg3:FlxSprite = new FlxSprite(basicOptions["buttonsX"], basicOptions["buttonsY"]).makeGraphic(basicOptions["buttonsWidth"], basicOptions["buttonsHeight"], FlxColor.fromString('0x' + basicOptions["buttonsColor"]));
		add(bg3);

		title = makeText(40, 15, 0, "Mania Converter", 30, 'verdana', 'EDFFC9');
		add(title);

		optionsGroup = new OptionsGroup(bg2.x, bg2.y, Std.int(bg2.width), Std.int(bg2.height), new INIParser().load("assets/menu/options.ini"));
		add(optionsGroup);

		buttonsGroup = new ButtonsGroup(bg3.x, bg3.y, Std.int(bg3.width), Std.int(bg3.height), new INIParser().load("assets/menu/buttons.ini"));
		add(buttonsGroup);
		buttonsGroup.setCallback("Browse...", function () {
			doFileDialog(OPEN, "*.json; *.osu", function(str:String) {
				buttonsGroup.setInputText("File path", str);
			});
		});

		logGroup = new LogGroup(bg2.x + bg2.width, bg1.y + bg1.height, Std.int(bg2.height), Std.int(FlxG.width - bg2.x + bg2.width));
		add(logGroup);

		initializeOptions();

		buttonsGroup.setCallback("Export as FNF...", function () {
			if (converter.fileContent != null)
				doFileDialog(SAVE, "*.json", function(str:String) {
					converter.options = options;
					if (converter.structure.keyCount != options.get("Key count"))
						logGroup.log("Changed key count from " + converter.structure.keyCount + " to " + options.get("Key count") + "!", 0xffffffff);
					converter.saveAsJSON(str);

					logGroup.log("Successfully exported " + str.replace("\\", "/").substring(str.replace("\\", "/").lastIndexOf("/") + 1) + " as FNF!", 0xff03cc03);
				});
			else
				logGroup.log("Map is not loaded!", 0xffff0000);
		});
		buttonsGroup.setCallback("Export as OSU...", function () {
			if (converter.fileContent != null)
				doFileDialog(SAVE, "*.osu", function(str:String) {
					converter.options = options;
					if (converter.structure.keyCount != options.get("Key count"))
						logGroup.log("Changed key count from " + converter.structure.keyCount + " to " + options.get("Key count") + "!", 0xffffffff);
					converter.saveAsOSU(str);

					logGroup.log("Successfully exported " + str.replace("\\", "/").substring(str.replace("\\", "/").lastIndexOf("/") + 1) + " as OSU!", 0xff03cc03);
				});
			else
				logGroup.log("Map is not loaded!", 0xffff0000);
		});

		//generateButtons();
		logGroup.log("Hello! You're running version " + Main.version, 0xffffffff);
	}

	public override function destroy() {
		super.destroy();
		onClose();
	}

	public function onClose() {
		saveOptions();
	}

	public function doFileDialog(type:FileDialogType = OPEN, filter:String = "", onSelectCallback:String->Void) {
		var fd:FileDialog = new FileDialog();
		fd.onSelect.add(onSelectCallback);
		if (filter.startsWith("*.")) filter = filter.substring(2);
		fd.browse(type, "" + filter, System.documentsDirectory);
	}

	function getOptions():Map<String, Dynamic> {
		var ini:INIParser = new INIParser().load("assets/menu/save.ini");
		if (ini == null) return defaultOptions;
		var options:Map<String, Dynamic> = ini.getCategoryByName("#Basic settings#");
		for (n => v in defaultOptions) if (options.get(n) == null) options.set(n, v);
		return options;
	}
	function saveOptions() {
		var ini:INIParser = new INIParser();
		ini.setCategoryMapByName("#Basic settings#", []);
		for (n => v in defaultOptions) ini.setValueByName("#Basic settings#", n, options.get(n));
		ini.save("assets/menu/save.ini");
		logGroup.log("Options saved!");
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
			else if (th is FlxUISlider)
			{
				var nums:FlxUISlider = cast th;
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
			else if (th is FlxUISlider)
			{
				var nums:FlxUISlider = cast th;
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
			case FlxUISlider.CHANGE_EVENT:
				var nums:FlxUISlider = cast sender;
				var wname = nums.name;

				options[wname] = nums.value;
				//trace(wname + ': ' + nums.value);
			case FlxUIInputText.CHANGE_EVENT:
				var nums:FlxUIInputText = cast sender;
				var wname = nums.name;

				options[wname] = nums.text;
				//trace(wname + ': ' + nums.text);
				if (wname == "File path")
				{
					converter.load(nums.text, options);
					//trace(converter.fileName, converter.fileContent.substring(0, 10), sys.FileSystem.exists(converter.fileName));
					buttonsGroup.indicator.visible = converter.fileContent != null;
					if(converter.fileContent != null)
					{
						var thing:String = converter.fileName.replace("\\", "/");
						//Sys.println("[Mania Converter] Successfully loaded " + thing.substring(thing.lastIndexOf("/") + 1) + "!");
						logGroup.log("Successfully loaded " + thing.substring(thing.lastIndexOf("/") + 1) + "!", 0xffffffff);
					}
				}
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

	override public function update(elapsed:Float) {
		super.update(elapsed);

		if (FlxG.keys.justPressed.F5)
			FlxG.switchState(new MenuState());
	}
}