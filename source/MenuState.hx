package;

import group.Group;
import flixel.FlxG;
import flixel.FlxCamera;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.#if (flixel >= "5.3.0") sound #else system #end.FlxSound;
import flixel.addons.ui.FlxUIState;
import flixel.addons.ui.FlxUIInputText;
import flixel.addons.ui.FlxUIDropDownMenu;
import flixel.addons.ui.FlxUISlider;
import flixel.addons.ui.FlxUICheckBox;

import lime.app.Application;
import lime.ui.FileDialog;
import lime.ui.FileDialogType;
import lime.system.System;

import openfl.events.Event;
import openfl.net.FileFilter;
import openfl.net.FileReference;

import group.OptionsGroup;
import group.ButtonsGroup;
import group.LogGroup;
import group.DescriptionGroup;

import utils.INIParser;
import utils.NativeAPI;
import utils.converter.Converter;

import sprite.SecretWordType;

using StringTools;

class MenuState extends FlxUIState
{
	var title:FlxText;

	var optionsGroup:OptionsGroup;
	var buttonsGroup:ButtonsGroup;
	var logGroup:LogGroup;
	var descriptionGroup:DescriptionGroup;

	var defaultOptions:Map<String, Dynamic> = [];
	var options:Map<String, Dynamic> = [];

	var converter:Converter;

	var cow:FlxSprite;
	var cowSound:FlxSound;
	var cowCamera:FlxCamera;
	var swt:SecretWordType;

	override public function create() {
		super.create();
		Application.current.window.onClose.add(destroy);

		NativeAPI.setDarkMode(true);

		FlxG.mouse.useSystemCursor = true;
		FlxG.sound.muted = false; // it muted by default idk

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

		var bg1:FlxSprite = new FlxSprite(basicOptions["headerX"], basicOptions["headerY"]).makeGraphic(basicOptions["headerWidth"], basicOptions["headerHeight"], Std.parseInt("0x" + basicOptions["headerColor"]));
		add(bg1);
		var bg2:FlxSprite = new FlxSprite(basicOptions["thingsX"], basicOptions["thingsY"]).makeGraphic(basicOptions["thingsWidth"], basicOptions["thingsHeight"], Std.parseInt("0x" + basicOptions["thingsColor"]));
		add(bg2);
		var bg3:FlxSprite = new FlxSprite(basicOptions["buttonsX"], basicOptions["buttonsY"]).makeGraphic(basicOptions["buttonsWidth"], basicOptions["buttonsHeight"], Std.parseInt("0x" + basicOptions["buttonsColor"]));
		add(bg3);

		title = makeText(260, 15, 0, "Mania Converter", 30, 'verdana', 'EDFFC9');
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

		descriptionGroup = new DescriptionGroup(basicOptions["headerX"], basicOptions["headerY"], basicOptions["thingsWidth"], basicOptions["headerHeight"]);
		add(descriptionGroup);

		initializeOptions();

		buttonsGroup.setCallback("Export as FNF...", () -> {
			if (converter.fileContent != null) {
				converter.options = options;
				var returnConv = converter.getAsJSON();
				doSaveDialog(returnConv.value, returnConv.extraValue[2], fr -> {
					if (returnConv.extraValue[0] != options.get("Key count")) logGroup.log("Changed key count from " + returnConv.extraValue[0] + " to " + options.get("Key count") + "!", 0xffffffff);
					if (returnConv.extraValue[1] > 0) logGroup.log("Removed " + returnConv.extraValue[1] + " duplicated notes by " + options.get("Sensitivity") + " ms sensitivity!", 0xffffffff);

					logGroup.log("Successfully exported " + fr.name + " as FNF!", 0xff03cc03);
				});
			}
			else
				logGroup.log("Map is not loaded!", 0xffff0000);
		});
		buttonsGroup.setCallback("Export as OSU...", () -> {
			if (converter.fileContent != null) {
				converter.options = options;
				var returnConv = converter.getAsOSU();
				doSaveDialog(returnConv.value, returnConv.extraValue[2], fr -> {
					if (returnConv.extraValue[0] != options.get("Key count")) logGroup.log("Changed key count from " + returnConv.extraValue[0] + " to " + options.get("Key count") + "!", 0xffffffff);
					if (returnConv.extraValue[1] > 0) logGroup.log("Removed " + returnConv.extraValue[1] + " duplicated notes by " + options.get("Sensitivity") + " ms sensitivity!", 0xffffffff);

					logGroup.log("Successfully exported " + fr.name + " as OSU!", 0xff03cc03);
				});
			}
			else
				logGroup.log("Map is not loaded!", 0xffff0000);
		});

		cowCamera = new FlxCamera();
		cowCamera.bgColor.alpha = 0;
		FlxG.cameras.add(cowCamera, false);

		cow = new FlxSprite(0, 0).loadGraphic(Paths.get.image("cow"));
		cow.screenCenter();
		cow.cameras = [cowCamera];
		cow.alpha = 0;
		add(cow);

		cowSound = new FlxSound().loadEmbedded(Paths.get.sound("mooboom"));
		cowSound.onComplete = function () {
			FlxTween.tween(cow, {alpha: 0}, 0.25);
		};
		cowSound.volume = 0.25;
		FlxG.sound.list.add(cowSound);

		swt = new SecretWordType("cow", "Metronome_Tick", function () {
			if (cowSound != null && cowSound.playing) return;
			FlxTween.tween(cow, {alpha: 1}, 0.5);
			cowSound.play(true);
		});
		add(swt);
		for (th in optionsGroup) if (th is FlxUIInputText) {
			var obj:FlxUIInputText = cast th;
			optionsGroup.setFocusCallback(obj.name, function () {
				swt.active = !obj.hasFocus;
			});
		}

		logGroup.log("Hello! You're running version " + Main.version, 0xffffffff);

		updateConverter(options["File path"]);
	}

	public override function destroy() {
		saveOptions();
		if (cowSound != null) cowSound.destroy();
		super.destroy();
	}

	/**
	 * Lime method of calling browse/save dialog. Not supports setting default file name on save type!
	 * @param type FileDialogType enum value
	 * @param filter Filter of file extensions
	 * @param onSelectCallback Calls on select file
	 */
	function doFileDialog(type:FileDialogType = OPEN, filter:String = "", onSelectCallback:String->Void) {
		var fd:FileDialog = new FileDialog();
		fd.onSelect.add(onSelectCallback);
		if (filter.startsWith("*.")) filter = filter.substring(2);
		fd.browse(type, "" + filter, System.documentsDirectory);
	}

	/**
	 * Flash method of calling save dialog.
	 * @param data Data to save
	 * @param defaultFileName Default file name to save
	 */
	function doSaveDialog(data:Dynamic, ?defaultFileName:String, ?onSelectCallback:FileReference->Void) {
		var fr = new FileReference();
		fr.addEventListener(Event.SELECT, function (_) {
			fr.load();
			onSelectCallback(fr);
		});
		fr.save(data, defaultFileName);
	}

	/**
	 * Flash method of calling browse dialog.
	 * @param filter Array with FileFilter class, ex. `new FileFilter("Images", "*.jpg;*.gif;*.png")`
	 * @param onSelectCallback Calls on select file
	 */
	// lol idk works it or no, i not checked it
	function doBrowseDialog(?filter:Array<FileFilter>, onSelectCallback:FileReference->Void) {
		var fr = new FileReference();
		fr.addEventListener(Event.SELECT, function (_) {
			fr.load();
			onSelectCallback(fr);
		});
		fr.browse(filter);
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

	function setValuesToGroup(group:Group, ?optionsMap:Map<String, Dynamic>) {
		if (optionsMap == null) optionsMap = options;
		for (th in group) {
			if (th is FlxUICheckBox) cast(th, FlxUICheckBox).checked = optionsMap[cast(th, FlxUICheckBox).name];
			else if (th is FlxUISlider) cast(th, FlxUISlider).value = optionsMap[cast(th, FlxUISlider).name];
			else if (th is FlxUIInputText) cast(th, FlxUIInputText).text = optionsMap[cast(th, FlxUIInputText).name];
			else if (th is FlxUIDropDownMenu) cast(th, FlxUIDropDownMenu).selectedId = optionsMap[cast(th, FlxUIDropDownMenu).name];
		}
	}
	function setValuesFromGroup(group:Group, ?optionsMap:Map<String, Dynamic>) {
		if (optionsMap == null) optionsMap = options;
		for (th in group) {
			if (th is FlxUICheckBox) optionsMap[cast(th, FlxUICheckBox).name] = cast(th, FlxUICheckBox).checked;
			else if (th is FlxUISlider) optionsMap[cast(th, FlxUISlider).name] = cast(th, FlxUISlider).value;
			else if (th is FlxUIInputText) optionsMap[cast(th, FlxUIInputText).name] = cast(th, FlxUIInputText).text;
			else if (th is FlxUIDropDownMenu) optionsMap[cast(th, FlxUIDropDownMenu).name] = Std.parseInt(cast(th, FlxUIDropDownMenu).selectedId);
		}
	}

	function setOptionsValues() {
		setValuesToGroup(buttonsGroup, options);
		setValuesToGroup(optionsGroup, options);
	}
	function initializeOptions() {
		setValuesFromGroup(buttonsGroup, defaultOptions);
		setValuesFromGroup(optionsGroup, defaultOptions);

		options = getOptions();
		setOptionsValues();
	}

	override function getEvent(id:String, sender:Dynamic, data:Dynamic, ?params:Array<Dynamic>) {
		switch(id) {
			case FlxUICheckBox.CLICK_EVENT:
				options[cast(sender, FlxUICheckBox).name] = cast(sender, FlxUICheckBox).checked;
			case FlxUISlider.CHANGE_EVENT:
				options[cast(sender, FlxUISlider).name] = cast(sender, FlxUISlider).value;
			case FlxUIInputText.CHANGE_EVENT:
				var nums:FlxUIInputText = cast sender;
				options[nums.name] = nums.text;
				if (nums.name == "File path") updateConverter(nums.text);
			case FlxUIDropDownMenu.CLICK_EVENT:
				options[cast(sender, FlxUIDropDownMenu).name] = Std.parseInt(cast(sender, FlxUIDropDownMenu).selectedId);
		}
	}

	function updateConverter(text:String) {
		converter.load(text, options);
		//trace(converter.fileName, converter.fileContent.substring(0, 10), sys.FileSystem.exists(converter.fileName));
		buttonsGroup.indicator.visible = converter.fileContent != null;
		if(converter.fileContent != null)
		{
			var thing:String = converter.fileName.replace("\\", "/");
			//Sys.println("[Mania Converter] Successfully loaded " + thing.substring(thing.lastIndexOf("/") + 1) + "!");
			logGroup.log("Successfully loaded " + thing.substring(thing.lastIndexOf("/") + 1) + "!", 0xffffffff);
		}
	}

	inline function makeText(x:Float = 0, y:Float = 0, width:Float = 0, text:String = '', size:Int = 8, font:String = 'vcr', color:String = 'FFFFFF') {
		return new FlxText(x, y, width, text, size).setFormat(Paths.get.font(font), size, Std.parseInt('0xFF' + color));
	}

	function getDesc():String
	{
		for (th in optionsGroup) if (th is Text) {
			var obj:Text = cast th;
			if (obj.mouseOverlaps) return obj.description;
		}
		return "";
	}

	override public function update(elapsed:Float) {
		super.update(elapsed);

		descriptionGroup.desc = getDesc();

		if (FlxG.keys.justPressed.F5)
			FlxG.switchState(new MenuState());
	}
}