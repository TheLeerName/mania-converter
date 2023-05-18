package utils.converter;

import flixel.math.FlxRandom;

typedef UtilsReturn = {
	var value:SwagSong;
	var ?extraValue:Dynamic;
}

class Utils {
    public static var currentSeed:Int = 91169;

	public static function removeDuplicates(structure:SwagSong, sensitivity:Int = 0):UtilsReturn
	{
		var lastSongNotes:Array<Float> = [];
		var removedNotes:Int = 0;
		for (section in structure.notes) {
			var newArray:Array<Dynamic> = [];
			for (songNotes in section.sectionNotes) {
				if (lastSongNotes.length == 0) {
					lastSongNotes = songNotes;
					continue;
				}
				if (lastSongNotes[0] >= (songNotes[0] - sensitivity) && songNotes[1] == lastSongNotes[1]) trace(songNotes, lastSongNotes);
				if (lastSongNotes[0] >= (songNotes[0] - sensitivity) && songNotes[1] == lastSongNotes[1])
					removedNotes++;
				else
					newArray.push(songNotes);
				lastSongNotes = songNotes;
			}
			section.sectionNotes = newArray;
		}
		return {value: structure, extraValue: removedNotes};
	}

	public static function changeKeyCount(structure:SwagSong, toKey:Int):UtilsReturn
	{
		if (structure.keyCount == null) structure.keyCount = 4;
		if (structure.keyCount == toKey) return {value: structure, extraValue: structure.keyCount};

		var alg:Array<Array<Int>> = getAlg(structure.keyCount, toKey);
		var random:FlxRandom = new FlxRandom(currentSeed);

		for (section in structure.notes)
			for (songNotes in section.sectionNotes)
				songNotes[1] = alg[songNotes[1]][random.int(1, alg[songNotes[1]].length) - 1];

		var wasKC:Int = structure.keyCount;
		structure.keyCount = toKey;
		return {value: structure, extraValue: wasKC};
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