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

	public static function changeKeyCount(structure:SwagSong, ?toKey:Int):UtilsReturn
	{
		if (structure.keyCount == null) structure.keyCount = 4;
		if (toKey == null) toKey = 4;
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

	public static function makeSongName(string:String, toreplace:String = "-", replacer:String = " "):String {
		string = string.replace(toreplace, replacer);
		var array:Array<String> = [string];
		if (string.contains(replacer)) array = string.split(replacer);

		for (i in 0...array.length)
			array[i] = array[i].substring(0, 1).toUpperCase() + array[i].substring(1);
		return array.join(' ');
	}

	static public function formatToSongPath(path:String) {
		var invalidChars = ~/[~&\\;:<>#]/;
		var hideChars = ~/[.,'"%?!]/;

		var path = invalidChars.split(path.replace(' ', '-')).join("-");
		return hideChars.split(path).join("").toLowerCase();
	}

	/**
	 * Returns algorithm to set keys from `input` key count to `output` key count
	 * @param input Key count from
	 * @param output Key count to
	 */
	public static function getAlg(input:Int, output:Int):Array<Array<Int>>
	{
		var noteArray:Array<Array<Int>> = [];
		for (i in 0...(input * 2))
			noteArray[i] = [];

		// bro i dont remember what i did like year ago
		if (input > output)
		{
			var keyRatio:Int = Std.int(input / output);

			// bf
			var num = 0;
			var num1 = 0;
			var num2 = 0;
			for (i in 0...input)
			{
				if (num > keyRatio - 1)
				{
					num = 0;
					num1 = i;
					if (num2 < output - 1)
						num2++;
				}
				noteArray[num + num1] = [num2];
				num++;
			}

			// opponent
			num = 0;
			num1 = 0;
			num2 = output;
			for (i in 0...input)
			{
				if (num > keyRatio - 1)
				{
					num = 0;
					num1 = i;
					if (num2 < output * 2 - 1)
						num2++;
				}
				
				noteArray[input + num + num1] = [num2];
				num++;
			}
		}
		else
		{
			// bf
			var num = 0;
			for (i in 0...output)
			{
				if (num > input - 1)
					num = 0;
				noteArray[num].push(i);
				num++;
			}

			// opponent
			num = 0;
			for (i in 0...output)
			{
				if (num > input - 1)
					num = 0;
				noteArray[input + num].push(output + i);
				num++;
			}
		}
		return noteArray;
	}
}