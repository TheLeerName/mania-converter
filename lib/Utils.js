var debug = require('./Debug.js');

// from funkin coolutil.hx
function numberArray(min, max)
{
	var dumbArray = [];
	for (let i = min; i < max + 1; i++)
		dumbArray.push(i);

	return dumbArray;
}

exports.getVersion = function(){return '1.3.3';}

exports.convertNote = function(from_note, keyCount, fromosu = true)
{
	from_note = parseInt(from_note);
	var note_array = [
		[
			numberArray(0, 511) // 0 key
		],
		[
			numberArray(0, 511),
			numberArray(0, 511)
		],
		[
			numberArray(0, 256), numberArray(257, 511),
			numberArray(0, 256), numberArray(257, 511)
		],
		[
			numberArray(0, 169), numberArray(170, 340), numberArray(341, 511),
			numberArray(0, 169), numberArray(170, 340), numberArray(341, 511)
		],
		[
			numberArray(0, 127), numberArray(128, 255), numberArray(256, 383), numberArray(384, 511), // 4 key bf
			numberArray(0, 127), numberArray(128, 255), numberArray(256, 383), numberArray(384, 511) // 4 key opponent
		],
		[
			numberArray(0, 101), numberArray(102, 203), numberArray(204, 306), numberArray(307, 408), numberArray(409, 511),
			numberArray(0, 101), numberArray(102, 203), numberArray(204, 306), numberArray(307, 408), numberArray(409, 511)
		],
		[
			numberArray(0, 84), numberArray(85, 169), numberArray(170, 255), numberArray(256, 340), numberArray(341, 425), numberArray(426, 511),
			numberArray(0, 84), numberArray(85, 169), numberArray(170, 255), numberArray(256, 340), numberArray(341, 425), numberArray(426, 511)
		],
		[
			numberArray(0, 72), numberArray(73, 145), numberArray(146, 218), numberArray(219, 291), numberArray(292, 364), numberArray(365, 437), numberArray(438, 511),
			numberArray(0, 72), numberArray(73, 145), numberArray(146, 218), numberArray(219, 291), numberArray(292, 364), numberArray(365, 437), numberArray(438, 511)
		],
		[
			numberArray(0, 63), numberArray(64, 127), numberArray(128, 191), numberArray(192, 255), numberArray(256, 319), numberArray(320, 383), numberArray(384, 447), numberArray(448, 511),
			numberArray(0, 63), numberArray(64, 127), numberArray(128, 191), numberArray(192, 255), numberArray(256, 319), numberArray(320, 383), numberArray(384, 447), numberArray(448, 511)
		],
		[
			numberArray(0, 56), numberArray(57, 113), numberArray(114, 170), numberArray(171, 227), numberArray(228, 284), numberArray(285, 341), numberArray(342, 398), numberArray(399, 455), numberArray(456, 511),
			numberArray(0, 56), numberArray(57, 113), numberArray(114, 170), numberArray(171, 227), numberArray(228, 284), numberArray(285, 341), numberArray(342, 398), numberArray(399, 455), numberArray(456, 511)
		],
		[
			numberArray(0, 50), numberArray(51, 101), numberArray(102, 152), numberArray(153, 203), numberArray(204, 254), numberArray(255, 305), numberArray(306, 356), numberArray(357, 407), numberArray(408, 458), numberArray(459, 511),
			numberArray(0, 50), numberArray(51, 101), numberArray(102, 152), numberArray(153, 203), numberArray(204, 254), numberArray(255, 305), numberArray(306, 356), numberArray(357, 407), numberArray(408, 458), numberArray(459, 511)
		]
	];

	if (fromosu)
	{
		for (let i = 0; i < note_array[keyCount].length; i++)
			for (let i2 = 0; i2 < note_array[keyCount][i].length; i2++)
				if (note_array[keyCount][i][i2] == from_note)
					return i;
	}
	else
	{
		return note_array[keyCount][from_note][parseInt(note_array[keyCount][from_note].length / 2)];
	}

	debug.error('Note ' + from_note + ' not found in array!');
	return 0;
}

exports.findLine = function(array, find, fromLine = 0, toLine = null)
{
	if (toLine == null)
		toLine = array.length;

	for (let i = fromLine; i < toLine; i++)
		if (array[i].includes(find))
			return i;

	debug.warn('String ' + find + ' not found!');
	return -1;
}

exports.osuLine = function(string, int, split)
{
	var array = string.split(split);
	return array[int];
}

exports.getMapOptions = function(map, name)
{
	for (let i = 0; i < map.length; i++)
		if (map[i].toLowerCase().startsWith(name.toLowerCase() + ':'))
			return map[i].substring(map[i].lastIndexOf(':') + 1).trim(); 

	debug.warn('Map option ' + name + ' not found!');
	return null;
}

exports.makeSongName = function(string, toreplace, replacer)
{
	var string2 = [];
	for (let i = 0; i < string.length; i++)
		string2[i] = string[i].replace(toreplace, replacer);

	for (let i = 0; i < string2.length; i++)
	{
		if (i == 0)
		{
			string2[i] = string2[i].toUpperCase();
		}
		else
		{
			if (string2[i] == replacer && i != string2.length - 1)
				string2[i + 1] = string2[i + 1].toUpperCase();
			else
			string2[i] = string2[i];
		}
	}
	return string2.join('');
}

exports.parseBool = function(string)
{
	if (string == '1' || string == 'true' || string == 'y' || string == 'yes')
		return true;
	else
		return false;
}