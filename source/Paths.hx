package;

import haxe.Json;

import flixel.util.FlxColor;
import flixel.graphics.FlxGraphic;

import openfl.media.Sound;
import openfl.utils.Assets;
import openfl.utils.AssetType;
import openfl.display.BitmapData;

#if sys
import sys.FileSystem;
import sys.io.File;
#end
#if html5
import js.html.Console;
#end

using StringTools;

class Paths {
	inline public static function font(font:String):String {
		return 'assets/fonts/' + font;
	}
	
	inline public static function parseJSON(file:String):Dynamic {
		return Json.parse(isJSON(file) ? file : #if sys File.getContent(file) #else file #end);
	}
	
	inline public static function getContent(path:String):String {
		#if sys
		return File.getContent(path);
		#else
		return Assets.getText(path);
		#end
	}
	
	// from funkin coolutil.hx
	public static function parseTXT(path:String, fromFile:Bool = true):Array<String> {
		var daList:Array<String> = [];
		if (fromFile)
			daList = getContent(path).trim().split('\n');
		else
			daList = path.trim().split('\n');
		// "error: Dynamic should be String have: Array<Dynamic> want : Array<String>", WTF???
		for (i in 0...daList.length)
			daList[i] = daList[i].trim();
		return daList;
	}
	
	inline public static function isJSON(file:String):Bool {
		var y = true;
		try { parseJSON(file); }
		catch (e) { y = false; }
		return y;
	}
	
	inline public static function stringify(file:String, format:String = "\t"):String {
		return Json.stringify(file, format);
	}
	
	inline public static function saveFile(to_file:String, from_file:String = '') {
		#if sys
		File.saveContent(to_file, from_file);
		#end
	}
	
	inline public static function exists(file:String):Bool {
		return #if sys FileSystem.exists(file) || #end Assets.exists(file);
	}

	public static function sound(snd:String):Sound {
		snd = "assets/sounds/" + snd + ".ogg";
		if (Assets.exists(snd, AssetType.SOUND)) return Assets.getSound(snd); // gets from embed folders
		#if sys if (FileSystem.exists(snd)) return Sound.fromFile(snd); #end

		log("[Mania Converter] Sound " + snd + " returning null! Someone (you) fucked up!");
		return null;
	}

	public static function image(img:String):FlxGraphic {
		img = "assets/images/" + img + ".png";
		if (Assets.exists(img, AssetType.IMAGE)) return FlxGraphic.fromAssetKey(img); // gets from embed folders
		#if sys  if (FileSystem.exists(img)) return FlxGraphic.fromBitmapData(BitmapData.fromFile(img)); #end

		log("[Mania Converter] Image " + img + " returning null! Someone (you) fucked up!");
		return null;
	}

	public static function log(text:String, color:FlxColor = 0xffffffff) {
		if (MenuState.instance.logGroup != null && MenuState.instance.logGroup.active) MenuState.instance.logGroup.log(text, color);
		#if sys Sys.println(text); #end
		#if html5 Console.log(text); #end
	}
}