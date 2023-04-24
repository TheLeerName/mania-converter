package;

import haxe.Json;

import flixel.graphics.FlxGraphic;

import openfl.media.Sound;
import openfl.utils.Assets;
import openfl.utils.AssetType;
import openfl.display.BitmapData;

#if sys
import sys.FileSystem;
import sys.io.File;
#end

using StringTools;

class Paths
{
	public static var get:Paths;
	
	public function font(font:String):String {
		return 'assets/fonts/' + font;
	}
	
	public function parseJSON(file:String):Dynamic {
		#if sys
		if (file.startsWith('{'))
			return Json.parse(file);
		else
			return Json.parse(File.getContent(file));
		#end
	}
	
	public function getContent(path:String):String {
		#if sys
		return File.getContent(path);
		#end
	}
	
	// from funkin coolutil.hx
	public function parseTXT(path:String, fromFile:Bool = true):Array<String> {
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
	
	public function isJSON(file:String):Bool {
		var y = true;
		try {
			var d = parseJSON(file);
		}
		catch (e) {
			y = false;
		}
		return y;
	}
	
	public function stringify(file:String, format:String = "\t"):String {
		#if sys
		return haxe.Json.stringify(file, format);
		#end
	}
	
	public function saveFile(to_file:String, from_file:String = '') {
		#if sys
		File.saveContent(to_file, from_file);
		#end
	}
	
	public function exists(file:String):Bool {
		return #if sys FileSystem.exists(file) || #end Assets.exists(file);
	}

	public function sound(snd:String):Sound {
		snd = "assets/sounds/" + snd + ".ogg";
		if (Assets.exists(snd, AssetType.SOUND)) return Assets.getSound(snd); // gets from embed folders
		if (FileSystem.exists(snd)) return Sound.fromFile(snd);

		Sys.println("[Mania Converter] Sound " + snd + " returning null! Someone (you) fucked up!");
		return null;
	}

	public function image(img:String):FlxGraphic {
		img = "assets/images/" + img + ".png";
		if (Assets.exists(img, AssetType.IMAGE)) return FlxGraphic.fromAssetKey(img); // gets from embed folders
		if (FileSystem.exists(img)) return FlxGraphic.fromBitmapData(BitmapData.fromFile(img));

		Sys.println("[Mania Converter] Image " + img + " returning null! Someone (you) fucked up!");
		return null;
	}
}