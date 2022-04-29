var debug = require('./Debug.js');

// from funkin coolutil.hx
function numberArray(min, max)
{
	var dumbArray = [];
	for (let i = min; i < max + 1; i++)
		dumbArray.push(i);

	return dumbArray;
}

exports.getVersion = function(){return '1.4';}

exports.convertNote = function(from_note, keyCount, fromosu = true)
{
	from_note = parseInt(from_note);
	if (from_note >= keyCount)
		from_note = from_note - keyCount + 1
	//console.log('da ' + from_note)

	var num = 512 / keyCount;
	var ty = from_note * num;
	//console.log(ty + ' | ' + keyCount)

	if (fromosu)
	{
		for (let i = 0; i < keyCount; i++)
		{
			var th = [num * i, (num * (i + 1)) - 1];
			if (th[0] <= ty && th[1] > ty)
			{
				//console.log(th);
				//console.log(keyCount + 'K: ' + from_note + ' -> from ' + th[0] + ' to ' + th[1]);
				return i;
			}
		}
	}
	else
	{
		//console.log(keyCount + 'K: ' + from_note + ' -> ' + (parseInt(((num * from_note) + ((num * (from_note + 1)) - 1)) / 2) + 1));
		return parseInt(((num * from_note) + ((num * (from_note + 1)) - 1)) / 2) + 1;
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