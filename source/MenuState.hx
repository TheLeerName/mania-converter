package;

/*
   |||||  |||||  ||  |   |||   |||||         |||||  |||||  ||  |  |   |  |||||  |||||  |||||  |||||  |||||         |||||         |||||
   | | |  |   |  ||| |    |    |   |         |      |   |  ||| |  |   |  |      |   |    |    |      |   |             |         |   |
   | | |  |||||  | | |    |    |||||         |      |   |  | | |  |   |  |||||  |||      |    |||||  |||           |||||         |   |
   | | |  |   |  | |||    |    |   |         |      |   |  | |||   | |   |      |  |     |    |      |  |              |         |   |
   | | |  |   |  |  ||   |||   |   |         |||||  |||||  |  ||    |    |||||  |   |    |    |||||  |   |         |||||   |||   |||||
*/

import flixel.FlxG;
import flixel.FlxCamera;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
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

import group.Group;
import group.LogGroup;
import group.OptionsGroup;
import group.ButtonsGroup;
import group.DescriptionGroup;

import utils.INIParser;
import utils.NativeAPI;
import utils.converter.Converter;

import sprite.SecretWordType;

using StringTools;

class MenuState extends FlxUIState
{
	var bgs:Map<String, FlxSprite> = [];
	var titleText:FlxText;

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

	function addBG(name:String, bg:FlxSprite) {
		bgs.set(name, bg);
		add(bg);
		return bg;
	}

	override public function create() {
		super.create();
		var basicOptions:Map<String, Dynamic> = new INIParser().load("assets/menu/basic.ini").getCategoryByName("#Basic settings#");
		FlxG.drawFramerate = FlxG.updateFramerate = basicOptions["windowFPS"];
		Application.current.window.onClose.add(destroy);

		NativeAPI.setDarkMode(true);

		FlxG.mouse.useSystemCursor = true;
		FlxG.sound.muted = false; // it muted by default idk

		//var json = Paths.parseJSON('hui.json');

		//var bg:FlxSprite = new FlxSprite().loadGraphic('assets/menu/bg.png');
		//add(bg);
		//generateScrollOptions();

		//ini.setCategoryByName("fuck you", ["fuck" => 1, "you" => true]);
		//trace(ini.getValueByName("fuck you", "you"));
		//ini.saveContent("kys.ini");
		//ini.load("menu.ini");
		converter = new Converter();

		for (name in ["description", "title", "options", "log", "buttons"])
		{
			addBG(name, new FlxSprite(basicOptions['${name}X'], basicOptions['${name}Y']).makeGraphic(basicOptions['${name}Width'], basicOptions['${name}Height'], Std.parseInt("0x" + basicOptions['${name}Color'])));

			switch(name) {
				case "description":
					descriptionGroup = new DescriptionGroup(bgs.get("description").x, bgs.get("description").y, Std.int(bgs.get("description").width), Std.int(bgs.get("description").height));
					add(descriptionGroup);
				case "title":
					titleText = makeText(bgs.get("title").x, basicOptions["titleTextY"], bgs.get("title").width, basicOptions["titleText"], basicOptions["titleTextSize"], 'verdana', Std.parseInt("0x" + basicOptions["titleTextColor"]));
					add(titleText);
				case "options":
					optionsGroup = new OptionsGroup(bgs.get("options").x, bgs.get("options").y, Std.int(bgs.get("options").width), Std.int(bgs.get("options").height), new INIParser().load("assets/menu/options.ini"));
					add(optionsGroup);
				case "log":
					logGroup = new LogGroup(bgs.get("log").x, bgs.get("log").y, Std.int(bgs.get("log").width), Std.int(bgs.get("log").height));
					add(logGroup);
				case "buttons":
					buttonsGroup = new ButtonsGroup(bgs.get("buttons").x, bgs.get("buttons").y, Std.int(bgs.get("buttons").width), Std.int(bgs.get("buttons").height), new INIParser().load("assets/menu/buttons.ini"));
					add(buttonsGroup);

					buttonsGroup.setCallback("Browse...", function () {
						#if sys
						doFileDialog(OPEN, "*.json; *.osu", function(str:String) {
							buttonsGroup.setInputText("File path", str);
						});
						#else
						doBrowseDialog([new FileFilter("Song files", "*.json;*.osu")], fr -> {
							//race(fr.data);
							updateConverter(fr.data.toString(), fr.name);
						});
						#end
					});
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
			}
		}

		initializeOptions();

		cowCamera = new FlxCamera();
		cowCamera.bgColor.alpha = 0;
		FlxG.cameras.add(cowCamera, false);

		cow = new FlxSprite(0, 0).loadGraphic(Paths.image("cow"));
		cow.screenCenter();
		cow.cameras = [cowCamera];
		cow.alpha = 0;
		add(cow);

		cowSound = new FlxSound().loadEmbedded(Paths.sound("mooboom"));
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

		#if !sys for (th in buttonsGroup) if (th is FlxUIInputText && cast(th, FlxUIInputText).name == "File path") th.visible = false; #end
		#if sys updateConverter(options["File path"]); #end
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
		#if sys
		var fd:FileDialog = new FileDialog();
		fd.onSelect.add(onSelectCallback);
		if (filter.startsWith("*.")) filter = filter.substring(2);
		fd.browse(type, "" + filter, System.documentsDirectory);
		#end
	}

	/**
	 * Flash method of calling save dialog.
	 * @param data Data to save
	 * @param defaultFileName Default file name to save
	 */
	function doSaveDialog(data:Dynamic, ?defaultFileName:String, ?onSelectCallback:FileReference->Void) {
		var fr = new FileReference();
		fr.addEventListener(Event.SELECT, function (e:Event) {
			fr.load();
			onSelectCallback(cast(e.target, FileReference));
		});
		fr.save(data, defaultFileName);
	}

	/**
	 * Flash method of calling browse dialog.
	 * @param filter Array with FileFilter class, ex. `new FileFilter("Images", "*.jpg;*.gif;*.png")`
	 * @param onSelectCallback Calls on select file
	 */
	// thx to flixel tutorial
	function doBrowseDialog(?filter:Array<FileFilter>, onSelectCallback:FileReference->Void) {
		var fr = new FileReference();
		fr.addEventListener(Event.SELECT, function (e:Event) {
			cast(e.target, FileReference).addEventListener(Event.COMPLETE, e_ -> {
				onSelectCallback(cast(e_.target, FileReference));
			}, false, 0, true);
			fr.load();
		}, false, 0, true);
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
				#if sys if (nums.name == "File path") updateConverter(nums.text); #end
			case FlxUIDropDownMenu.CLICK_EVENT:
				options[cast(sender, FlxUIDropDownMenu).name] = Std.parseInt(cast(sender, FlxUIDropDownMenu).selectedId);
		}
	}

	function updateConverter(text:String, ?fileName:String) {
		#if sys
		converter.load(text, options);
		buttonsGroup.indicatorEnabled = converter.fileContent != null;
		if(converter.fileContent != null) {
			var thing:String = converter.fileName.replace("\\", "/");
			logGroup.log("Successfully loaded " + thing.substring(thing.lastIndexOf("/") + 1) + "!", 0xff03cc03);
		}
		#else
		converter.loadFromContent(text, options);
		converter.fileName = fileName;
		buttonsGroup.indicatorEnabled = converter.fileContent != null;
		if(converter.fileContent != null) {
			var thing:String = converter.fileName.replace("\\", "/");
			logGroup.log("Successfully loaded " + thing.substring(thing.lastIndexOf("/") + 1) + "!", 0xff03cc03);
		}
		#end
	}

	inline function makeText(x:Float = 0, y:Float = 0, width:Float = 0, text:String = '', size:Int = 8, font:String = 'vcr', color:FlxColor = 0xff000000) {
		return new FlxText(x, y, width, text, size).setFormat(Paths.font(font), size, color, CENTER);
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

		#if sys if (FlxG.keys.justPressed.F5) FlxG.switchState(new MenuState()); #end
	}
}