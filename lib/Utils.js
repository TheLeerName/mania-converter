var debug = require('./Debug.js');

// from funkin coolutil.hx
function numberArray(min, max)
{
	var dumbArray = [];
	for (let i = min; i < max + 1; i++)
		dumbArray.push(i);

	return dumbArray;
}

exports.getVersion = function(){return '2.0';}

exports.convertNote = function(from_note, keyCount, fromosu = true)
{
	from_note = parseInt(from_note);
	//console.log('da ' + from_note)

	var num = 512 / keyCount;
	var ty = from_note * num;
	//console.log(ty + ' | ' + keyCount)

	if (fromosu)
	{
		for (let i = 0; i < keyCount; i++)
		{
			var th = [num * i, (num * (i + 1)) - 1];
			if (from_note >= th[0] && from_note <= th[1])
			{
				//console.log(th);
				//console.log(keyCount + 'K: ' + from_note + ' -> from ' + th[0] + ' to ' + th[1]);
				return i;
			}
		}
	}
	else
	{
		if (from_note >= keyCount)
		from_note = from_note - keyCount + 1;
		//console.log(keyCount + 'K: ' + from_note + ' -> ' + (parseInt(((num * from_note) + ((num * (from_note + 1)) - 1)) / 2) + 1));
		return parseInt(((num * from_note) + ((num * (from_note + 1)) - 1)) / 2) + 1;
	}

	debug.error('Note ' + from_note + ' not found in array!');
	return 0;
}

// https://ajahne.github.io/blog/javascript/2020/02/04/how-to-remove-duplicates-from-an-array-in-javascript.html
// and was edited
exports.removeDuplicates = function(array, sensitivity, osu = false, from = 0)
{
	if (osu)
	{
		var things = 0;
		const result = [];
		for (let i = 0; i < from; i++)
			result.push(array[i]);
		for (let i = from; i < array.length; i++)
		{
			array[i][0] = parseInt(array[i][0]);
			array[i][2] = parseInt(array[i][2]);
		}
		for (let i = from; i < array.length; i++)
		{
			let exists = false;
			for (j = from; j < result.length; j++)
			{
				if (array[i][2] >= (result[j][2] - (sensitivity / 2)) && array[i][2] < (result[j][2] + (sensitivity / 2)) && array[i][0] == result[j][0])
				{
					exists = true;
					break;
				}
			}
			if (!exists)
				result.push(array[i]);
			else
				things++;
		}
		return [result, things];
	}
	else
	{
		var things = 0;
		const result = [];
		for (let i = 0; i < array.length; i++)
		{
			let exists = false;
			for (j = 0; j < result.length; j++)
			{
				if (array[i][0] >= (result[j][0] - sensitivity) && array[i][0] < (result[j][0] + sensitivity) && array[i][1] == result[j][1])
				{
					exists = true;
					break;
				}
			}
			if (!exists)
				result.push(array[i]);
			else
				things++;
		}
		return [result, things];
	}
}

exports.findLine = function(array, find, fromLine = 0, toLine = null, silent = true)
{
	if (toLine == null)
		toLine = array.length;

	for (let i = fromLine; i < toLine; i++)
		if (array[i].includes(find))
			return i;

	 if (!silent) debug.warn('String ' + find + ' not found!');
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