package;

import haxe.Json;
import haxe.format.JsonParser;
import flixel.FlxG;
import openfl.utils.Assets;
import lime.app.Application;
#if sys
import sys.io.File;
import sys.FileSystem;
#end

using StringTools;

// this functions originally used in FNF Extra https://github.com/TheLeerName/FNF-extra/blob/stable/source/CoolUtil.hx
class FileAPI
{
	public static var file:FileAPI;

	inline public function parseJSON(key:String, fromFile:Bool = true):Dynamic
	{
		#if sys
		if (!fromFile)
			return haxe.Json.parse(key);
		if (exists(key))
			return haxe.Json.parse(File.getContent(key));
		else
		{
			Debug.log.error('Can\'t parse ${key}, file is not exist!');
			return [];
		}
		#else
		Debug.log.error('This function is disabled, when sys is false!');
		return [];
		#end
	}

	inline public function stringify(key:Dynamic, string:String = "\t", fromFile:Bool = true):Dynamic
	{
		#if sys
		if (!fromFile)
			return haxe.Json.stringify(key, string);
		else if (exists(key))
			return haxe.Json.stringify(key, string);
		else
		{
			Debug.log.error('Can\'t stringify ${key}, file is not exist!');
			return [];
		}
		#else
		Debug.log.error('This function is disabled, when sys is false!');
		return [];
		#end
	}

	inline public function isDir(path:String):Bool
	{
		#if sys
		return FileSystem.isDirectory(path);
		#else
		return null;
		#end
	}

	inline public function readDir(path:String)
	{
		#if sys
		if (isDir(path))
			return FileSystem.readDirectory(path);
		else
		{
			Debug.log.error('Can\'t read directory ${path}, directory is not exist!');
			return null;
		}
		#else
		return null;
		#end
	}

	public function createDir(path:String)
	{
		#if sys
		if (!isDir(path))
			FileSystem.createDirectory(path);
		else
			Debug.log.warn('Can\'t create directory ${path}, directory already exist!');
		#end
	}

	public function deleteDir(key:String):Void
	{
		#if sys
		FileSystem.deleteDirectory(key);
		#end
	}

	// function from https://ashes999.github.io/learnhaxe/recursively-delete-a-directory-in-haxe.html
	public function deleteFiles(directory:String):Void
	{
		#if sys
		if (exists(directory) && isDir(directory))
		{
			var entries = readDir(directory);
			for (entry in entries)
			{
				if (isDir(directory + '/' + entry))
				{
					deleteFiles(directory + '/' + entry);
					FileSystem.deleteDirectory(directory + '/' + entry);
				}
				else
				{
					deleteFile(directory + '/' + entry);
				}
			}
		}
		#end
	}

	inline public function exists(path:String):Bool
	{
		#if sys
		return FileSystem.exists(path);
		#else
		return null;
		#end
	}

	inline public function getContent(path:String)
	{
		#if sys
		if (exists(path))
			return File.getContent(path);
		else
		{
			Debug.log.error('Error: Can\'t get content from ${path}, file is not exist!');
			return null;
		}
		#else
		return null;
		#end
	}

	public function deleteFile(path:String)
	{
		#if sys
		if (exists(path))
			FileSystem.deleteFile(path);
		else
			Debug.log.warn('Error: Can\'t delete file ${path}, file is not exist!');
		#end
	}

	public function saveFile(to_file:String, from_file:String = '')
	{
		#if sys
		File.saveContent(to_file, from_file);
		#end
	}

	public function copy(from_file:String, to_file:String)
	{
		#if sys
		File.copy(from_file, to_file);
		#end
	}

	public function closeWindow()
	{
		Application.current.window.close();
	}
	public function projectXML(name:String):String
	{
		return Application.current.meta.get(name);
	}

	// from funkin coolutil.hx
	public function parseTXT(path:String, fromFile:Bool = true):Array<String>
	{
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
}