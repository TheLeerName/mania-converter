var file = require('./FileAPI.js');
var debug = require('./Debug.js');

exports.convertShit = function(map_)
{
	var map = file.parseJSON(map_, false);
	var keyCount = 4;
	if (map.song.playerKeyCount != null)
		keyCount = parseInt(map.song.playerKeyCount);
	if (map.song.keyCount != null)
		keyCount = parseInt(map.song.keyCount);
	if (map.song.keyNumber != null)
		keyCount = parseInt(map.song.keyNumber);
	if (map.song.mania != null)
		keyCount = parseInt(map.song.mania) + 1;
	
	if (keyCount < 1 || keyCount > 9)
	{
		debug.warn('Convert to "Extra Keys with Lua For Psych Engine" format failed, you have ' + key + ' key count, value must be more 0 and less 10');
		return map_;
	}

	// copied from https://github.com/TheZoroForce240/FNF-Extra-Keys-V2/blob/master/source/ChartingState.hx#L2914, and little edited
	var dataConverts = [
		[2,  6],
		[0, 1,  4, 7],
		[0, 2, 3,  4, 6, 7],
		[0, 1, 2, 3,  4, 5, 6, 7],
		[0, 1, 2, 2, 3,  4, 5, 6, 6, 7],
		[0, 2, 3, 0, 1, 3,  4, 6, 7, 4, 5, 7],
		[0, 2, 3, 2, 0, 1, 3,   4, 6, 7, 6, 4, 5, 7],
		[0, 1, 2, 3, 0, 1, 2, 3,  4, 5, 6, 7, 4, 5, 6, 7],
		[0, 1, 2, 3, 2, 0, 1, 2, 3,  4, 5, 6, 7, 6, 4, 5, 6, 7]
	];
	var nTypeConverts = [
		["space",  "space"],
		[null, null,  null, null],
		[null, "space", null,  null, "space", null],
		[null, null, null, null,  null, null, null, null],
		[null, null, "space", null, null,  null, null, "space", null, null],
		[null, null, null, "extras", null, "extras",  null, null, null, "extras", null, "extras"],
		[null, null, null, "space", "extras", null, "extras",  null, null, null, "space", "extras", null, "extras"],
		[null, null, null, null, "extras", "extras", "extras", "extras",  null, null, null, null, "extras", "extras", "extras", "extras"],
		[null, null, null, null, "space", "extras", "extras", "extras", "extras",  null, null, null, null, "space", "extras", "extras", "extras", "extras"]
	];

	for (let i = 0; i < map.song.notes.length; i++)
	{
		for (let i1 = 0; i1 < map.song.notes[i].sectionNotes.length; i1++)
		{
			//debug.trace(dataConverts[keyCount - 1][map.song.notes[i].sectionNotes[i1][1]] + ' | ' + nTypeConverts[keyCount - 1][map.song.notes[i].sectionNotes[i1][1]]);
			map.song.notes[i].sectionNotes[i1][3] = nTypeConverts[keyCount - 1][map.song.notes[i].sectionNotes[i1][1]];
			map.song.notes[i].sectionNotes[i1][1] = dataConverts[keyCount - 1][map.song.notes[i].sectionNotes[i1][1]];
		}
	}

	return file.stringify(map, '\t', false);
}