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
			trace('Error: Can\'t parse ${key}, file is not exist!');
			return [];
		}
		#else
		trace('This function is disabled, when sys is false!');
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
			trace('Error: Can\'t stringify ${key}, file is not exist!');
			return [];
		}
		#else
		trace('This function is disabled, when sys is false!');
		return [];
		#end
	}

	inline public function isDir(path:String):Bool
	{
		#if sys
		return sys.FileSystem.isDirectory(path);
		#else
		return null;
		#end
	}
	inline public function readDir(path:String)
	{
		#if sys
		if (isDir(path))
			return sys.FileSystem.readDirectory(path);
		else
		{
			trace('Error: Can\'t read directory ${path}, directory is not exist!');
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
			sys.FileSystem.createDirectory(path);
		else
			trace('Error: Can\'t create directory ${path}, directory already exist!');
		#end
	}
	// function from https://ashes999.github.io/learnhaxe/recursively-delete-a-directory-in-haxe.html
	public function deleteDir(key:String, recursively:Bool = true):Void
	{
		#if sys
		if (exists(key) && isDir(key) && recursively)
		{
			var entries = readDir(key);
			for (entry in entries)
			{
				if (isDir(key + '/' + entry))
				{
					deleteDir(key + '/' + entry);
					sys.FileSystem.deleteDirectory(key + '/' + entry);
				}
				else
				{
					deleteFile(key + '/' + entry);
				}
			}
		}
		else if (!recursively)
			sys.FileSystem.deleteDirectory(key);
		#end
	}

	inline public function exists(path:String):Bool
	{
		#if sys
		return sys.FileSystem.exists(path);
		#else
		return null;
		#end
	}
	inline public function getContent(path:String)
	{
		#if sys
		if (exists(path))
			return sys.io.File.getContent(path);
		else
		{
			trace('Error: Can\'t get content from ${path}, file is not exist!');
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
			sys.FileSystem.deleteFile(path);
		else
			trace('Error: Can\'t delete file ${path}, file is not exist!');
		#end
	}
	public function saveFile(to_file:String, from_file:String = '')
	{
		#if sys
		sys.io.File.saveContent(to_file, from_file);
		#end
	}
}