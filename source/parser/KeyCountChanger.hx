package parser;

import flixel.math.FlxRandom;

class KeyCountChanger {
    public static var currentSeed:Int = 91169;
	public static function changeKeyCount(structure:SwagSong, toKey:Int):SwagSong
	{
		if (structure.keyCount == toKey) return structure;

		var alg:Array<Array<Int>> = getAlg(structure.keyCount, toKey);
		var random:FlxRandom = new FlxRandom(currentSeed);

		for (section in structure.notes)
			for (songNotes in section.sectionNotes)
				songNotes[1] = alg[songNotes[1]][random.int(1, alg[songNotes[1]].length) - 1];

		structure.keyCount = toKey;

		return structure;
	}

	public static function getAlg(from_key:Int, to_key:Int):Array<Array<Int>>
	{
		var res:Array<Array<Int>> = [];
		for (i in 0...(from_key * 2))
			res[i] = [];

		if (from_key > to_key)
		{
			var ha = Std.int(from_key / to_key);

			// bf
			var num = 0;
			var num1 = 0;
			var num2 = 0;
			for (i in 0...from_key)
			{
				if (num > ha - 1)
				{
					num = 0;
					num1 = i;
					if (num2 < to_key - 1)
						num2++;
				}
				res[num + num1] = [num2];
				num++;
			}

			// opponent
			num = 0;
			num1 = 0;
			num2 = to_key;
			for (i in 0...from_key)
			{
				if (num > ha - 1)
				{
					num = 0;
					num1 = i;
					if (num2 < to_key * 2 - 1)
						num2++;
				}
				
				res[from_key + num + num1] = [num2];
				num++;
			}
		}
		else
		{
			// bf
			var num = 0;
			for (i in 0...to_key)
			{
				if (num > from_key - 1)
					num = 0;
				res[num].push(i);
				num++;
			}

			// opponent
			num = 0;
			for (i in 0...to_key)
			{
				if (num > from_key - 1)
					num = 0;
				res[from_key + num].push(to_key + i);
				num++;
			}
		}
		//console.log(res)
		return res;
	}
}