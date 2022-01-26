package;

using StringTools;

class Debug
{
	public static var log:Debug;

	public function trace(string:Dynamic)
	{
		if (!FileAPI.file.exists('log.txt'))
			FileAPI.file.saveFile('log.txt');

		var log:Array<Dynamic> = FileAPI.file.getContent('log.txt').trim().split('\n');
		log.push('[${Date.now()}] [TRACE] ${string}');

		FileAPI.file.saveFile('log.txt', toString(log));
		#if sys
		Sys.println('[${Date.now()}] [TRACE] ${string}');
		#else
		trace(string);
		#end
	}

	public function warn(string:Dynamic)
	{
		if (!FileAPI.file.exists('log.txt'))
			FileAPI.file.saveFile('log.txt');

		var log:Array<Dynamic> = FileAPI.file.getContent('log.txt').trim().split('\n');
		log.push('[${Date.now()}] [WARN] ${string}');

		FileAPI.file.saveFile('log.txt', toString(log));
		#if sys
		Sys.println('[${Date.now()}] [WARN] ${string}');
		#else
		trace(string);
		#end
	}

	public function error(string:Dynamic)
	{
		if (!FileAPI.file.exists('log.txt'))
			FileAPI.file.saveFile('log.txt');

		var log:Array<Dynamic> = FileAPI.file.getContent('log.txt').trim().split('\n');
		log.push('[${Date.now()}] [ERROR] ${string}');

		FileAPI.file.saveFile('log.txt', toString(log));
		#if sys
		Sys.println('[${Date.now()}] [ERROR] ${string}');
		#else
		trace(string);
		#end
		FileAPI.file.closeWindow();
	}

	inline function toString(array:Array<Dynamic>)
	{
		var string:String = '';
		for (i in 0...array.length)
		{
			string += array[i] + '\n';
		}
		return string;
	}
}