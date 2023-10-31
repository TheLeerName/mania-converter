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
import flixel.sound.FlxSound;
import flixel.addons.ui.FlxUIState;
import flixel.addons.ui.FlxUIInputText;
import flixel.addons.ui.FlxUIDropDownMenu;
import flixel.addons.ui.FlxUISlider;
import flixel.addons.ui.FlxUICheckBox;

import openfl.events.Event;
import openfl.net.FileFilter;
#if sys
import openfl.filesystem.File;
#else
import openfl.net.FileReference as File;
#end

import group.Group;
import group.LogGroup;
import group.OptionsGroup;
import group.ButtonsGroup;
import group.DescriptionGroup;

import utils.INIParser;
import utils.NativeAPI;
import utils.ClassShortcuts;
import utils.converter.Converter;

import sprite.SecretWordType;

using StringTools;

@:access(flixel.addons.ui.FlxUISlider)
class MenuState extends FlxUIState
{
	var facts:Array<String> = [
		"Someone said if you press O W C keys, but idk in which order, smth will appear.",
		"i want to eat.",
		"cyber swag 2077",
		"challenge: convert galaxy collapse to 9 keys and do full combo on it",
		"nerf this",
		"barbecue bacon burger",
		"i want collab of sonic and angry birds",
		"Please take a shower immediately.",
		"mario",
		"lol",
		"you will suffer for your sins.",
		"FNF PLAYER SPOTTED DEPLOYING camellia ghost brand FNF PLAYER MAULING PITBULL",
		"FNF PLAYER SPOTTED DEPLOYING laur sound chimera brand FNF PLAYER MAULING PITBULL",
		"FNF PLAYER SPOTTED DEPLOYING %puthardsonghere% brand FNF PLAYER MAULING PITBULL",
		"FNF PLAYER SPOTTED DEPLOYING null brand FNF PLAYER MAULING PITBULL",
		"OSU PLAYER SPOTTED DEPLOYING fnf bopeebo brand OSU PLAYER MAULING PITBULL",
		"huh?",
		"i use psych engine too *gif with sonic and shadow kissing*",
		"hello my name is big boobs",
		"u going to ohio"
	];

	var bgs:Map<String, FlxSprite> = [];
	var titleText:FlxText;

	public var optionsGroup:OptionsGroup;
	public var buttonsGroup:ButtonsGroup;
	public var logGroup:LogGroup;
	public var descriptionGroup:DescriptionGroup;

	var defaultOptions:Map<String, Dynamic> = [];
	var options:Map<String, Dynamic> = [];

	var converter:Converter;

	var cow:FlxSprite;
	var cowSound:FlxSound;
	var cowCamera:FlxCamera;
	var swt:SecretWordType;

	var doubleClick = new utils.DoubleClickChecker();
	var changeValue:FlxUIInputText;
	var curClicked:FlxUISlider;

	public static var instance:MenuState;

	function addBG(name:String, bg:FlxSprite) {
		bgs.set(name, bg);
		add(bg);
		return bg;
	}

	override public function create() {
		super.create();
		instance = this;
		var basicOptions:Map<String, Dynamic> = new INIParser().load("assets/menu/basic.ini").getCategoryByName("#Basic settings#");
		FlxG.drawFramerate = FlxG.updateFramerate = basicOptions["windowFPS"];
		FlxG.stage.window.onClose.add(destroy);

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
			addBG(name, new FlxSprite(basicOptions['${name}X'], basicOptions['${name}Y']).makeGraphic(basicOptions['${name}Width'], basicOptions['${name}Height'], basicOptions['${name}Color']));

			switch(name) {
				case "description":
					descriptionGroup = new DescriptionGroup(bgs.get("description").x, bgs.get("description").y, Std.int(bgs.get("description").width), Std.int(bgs.get("description").height), basicOptions["descriptionText"]);
					add(descriptionGroup);
				case "title":
					titleText = makeText(bgs.get("title").x, basicOptions["titleTextY"], bgs.get("title").width, basicOptions["titleText"], basicOptions["titleTextSize"], 'verdana', basicOptions["titleTextColor"]);
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
						doBrowseDialog([new FileFilter("Song files", "*.json;*.osu")], fr -> {
							//race(fr.data);
							#if sys
							buttonsGroup.setInputText("File path", fr.nativePath);
							#else
							updateConverter(fr.data.toString(), fr.name);
							#end
						});
					});
					buttonsGroup.setCallback("Export as FNF...", () -> {
						if (converter.fileContent != null && converter.structure != null) {
							converter.options = options;
							var returnConv = converter.getAsJSON();
							doSaveDialog(returnConv.value, returnConv.extraValue[2], name -> {
								if (returnConv.extraValue[0] != options.get("Key count") && options.get("Key count") != 0) logGroup.log("Changed key count from " + returnConv.extraValue[0] + " to " + options.get("Key count") + "!", 0xffffffff);
								if (returnConv.extraValue[1] > 0) logGroup.log("Removed " + returnConv.extraValue[1] + " duplicated notes by " + options.get("Sensitivity") + " ms sensitivity!", 0xffffffff);
			
								logGroup.log("Successfully exported " + name + " as FNF!", 0xff03cc03);
							});
						}
						else
							logGroup.log("Map is not loaded!", 0xffff0000);
					});
					buttonsGroup.setCallback("Export as OSU...", () -> {
						if (converter.fileContent != null && converter.structure != null) {
							converter.options = options;
							var returnConv = converter.getAsOSU();
							doSaveDialog(returnConv.value, returnConv.extraValue[2], name -> {
								if (returnConv.extraValue[0] != options.get("Key count") && options.get("Key count") != 0) logGroup.log("Changed key count from " + returnConv.extraValue[0] + " to " + options.get("Key count") + "!", 0xffffffff);
								if (returnConv.extraValue[1] > 0) logGroup.log("Removed " + returnConv.extraValue[1] + " duplicated notes by " + options.get("Sensitivity") + " ms sensitivity!", 0xffffffff);
			
								logGroup.log("Successfully exported " + name + " as OSU!", 0xff03cc03);
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

		doubleClick.onDoubleClick = () -> {
			for (slider in optionsGroup.sliders) {
				if (slider.overlapsPoint(FlxG.mouse.getPositionInCameraView(slider.cameras[0]), true)) {
					trace('opening change value input text...');
					changeValue.setPosition(slider.valueLabel.x, slider.handle.y);
					changeValue.width = slider.valueLabel.width;
					changeValue.revive();
					changeValue.text = slider.value + '';
					changeValue.caretIndex = 0;
					curClicked = slider;
					changeValue.hasFocus = true;
					break;
				}
			}
		};
		doubleClick.onClick = hideChangeValue;
		add(doubleClick);

		changeValue = ClassShortcuts.makeInput(0, 0, 150, '35', 16, 'idontcare');
		changeValue.setFormat(Paths.font('verdana'), 16, 0xff000000);
		changeValue.filterMode = 2;
		changeValue.cameras = optionsGroup.cameras;
		add(changeValue);
		changeValue.kill();

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

		logGroup.log("Hello! You're running version " + Main.version);
		if (Date.now().getDate() == 15 && Date.now().getMonth() == 2)
			logGroup.log('  you should be hiding it\'s march 15', 0xff59e3e7);
		else
			logGroup.log('  ' + facts[FlxG.random.int(0, facts.length - 1)], 0xff59e3e7);

		#if !sys for (th in buttonsGroup) if (th is FlxUIInputText && cast(th, FlxUIInputText).name == "File path") th.visible = false; #end
		#if sys updateConverter(options["File path"]); #end
	}

	function hideChangeValue() {
		if (changeValue.alive) {
			changeValue.hasFocus = false;
			changeValue.kill();

			var value:Float = Std.parseFloat(changeValue.text);
			if (value < curClicked.minValue || value > curClicked.maxValue)
				value = curClicked.maxValue - curClicked.minValue;

			curClicked.value = value;
			curClicked.updateValue();
		}
	}

	public override function destroy() {
		saveOptions();
		if (cowSound != null) cowSound.destroy();
		super.destroy();
	}

	/**
	 * Flash method of calling save dialog.
	 * @param data Data to save
	 * @param defaultFileName Default file name to save
	 */
	function doSaveDialog(data:Dynamic, ?defaultFileName:String, ?onSelectCallback:String->Void) {
		var fr = new File();
		// idk it dont work on html5
		#if sys
		fr.addEventListener(Event.SELECT, function (e:Event) {
			fr.load();
			onSelectCallback(cast(e.target, File).name);
		});
		#else
		onSelectCallback(defaultFileName);
		#end
		fr.save(data, defaultFileName);
	}

	/**
	 * OpenFL method of calling browse dialog.
	 * @param filter Array with FileFilter class, ex. `new FileFilter("Images", "*.jpg;*.gif;*.png")`
	 * @param onSelectCallback Calls on select file
	 */
	function doBrowseDialog(?filter:Array<FileFilter>, onSelectCallback:File->Void) {
		var fr = new File();
		fr.addEventListener(Event.SELECT, function (e:Event) {
			cast(e.target, File).addEventListener(Event.COMPLETE, e_ -> {
				onSelectCallback(cast(e_.target, File));
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
		#else
		converter.fileName = fileName;
		converter.loadFromContent(text, options);
		#end
		buttonsGroup.indicatorEnabled = converter.fileContent != null && converter.structure != null;
		if(converter.fileContent != null && converter.structure != null) {
			var thing:String = converter.fileName.replace("\\", "/");
			logGroup.log("Successfully loaded " + thing.substring(thing.lastIndexOf("/") + 1) + "!", 0xff03cc03);
		}
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

		if (FlxG.keys.justPressed.ENTER)
			hideChangeValue();

		#if sys if (FlxG.keys.justPressed.F5) FlxG.switchState(new MenuState()); #end
	}
}