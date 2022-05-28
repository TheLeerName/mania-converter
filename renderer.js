// for send datas to main scripts
const { ipcRenderer, BrowserWindow, remote } = require('electron');
var cp = require('child_process');
var file = require('./FileAPI.js');

// creating options.ini
if (!file.exists('options.ini'))
	file.run('mccmd');

setOptions();

ipcRenderer.on('dasender1', function (event, message) {
	ipcRenderer.send('dasender2', getOptions());
});
window.addEventListener('unload', function (event) {
	console.log('unload');
});

function setOptions()
{
	var names = [
		['Sensitivity', ['r5', 'rt5'], 'radio'],
		['Key', ['r6', 'rt6'], 'radio'],
		['Mode', 'md', 'dropdown'],
		['IgnoreNote', 'in', 'text'],
		['player1', 'p1', 'text'],
		['player2', 'p2', 'text'],
		['player3', 'p3', 'text'],
		['stage', 'st', 'text'],
		['speed', ['r0', 'rt0'], 'radio'],
		['LuaSave', 'ls', 'dropdown'],
		['needsVoices', 'nv', 'dropdown'],
		['gfSection', 'gs', 'dropdown'],
		['altAnim', 'aa', 'dropdown'],
		['mustHitSection', 'mhs', 'dropdown'],
		['bpm', ['r1', 'rt1'], 'radio'],
		['Side', 's', 'dropdown'],
		['AudioFileName', 'afn', 'text'],
		['Artist', 'ar', 'text'],
		['Creator', 'cr', 'text'],
		//['Version', 'diff', 'text'],
		['Background', 'bg', 'text'],
		['Source', 'source', 'text'],
		['HPDrainRate', ['r2', 'rt2'], 'radio'],
		['OverallDifficulty', ['r4', 'rt4'], 'radio'],
		['VolumeHitSound', ['r3', 'rt3'], 'radio']
	];
	for (let i = 0; i < names.length; i++)
	{
		if (names[i][2] == 'text')
		{
			document.getElementById(names[i][1]).value = getOptionINI(names[i][0]);
		}
		else if (names[i][2] == 'radio')
		{
			if (names[i][0] == 'Key' && getOptionINI(names[i][0]) == 'none')
			{
				document.getElementById(names[i][1][0]).value = 0;
				document.getElementById(names[i][1][1]).textContent = 'none';
			}
			else
			{
				document.getElementById(names[i][1][0]).value = getOptionINI(names[i][0]);
				document.getElementById(names[i][1][1]).textContent = getOptionINI(names[i][0]);
			}
		}
		else if (names[i][2] == 'dropdown')
		{
			document.getElementById(names[i][1]).selectedIndex = parseInt(getOptionINI(names[i][0]));
		}
	}
	for (let i = 0; i < 7; i++)
		ur(i);
}
function getOptionINI(name)
{
	var map = file.parseTXT('options.ini');

	for (let i = 0; i < map.length; i++)
	{
		if (map[i].toLowerCase().trim().startsWith(name.toLowerCase().trim()))
		{
			map[i] = map[i].substring(map[i].indexOf(':') + 1);
			if (map[i].includes(' |:| '))
				map[i] = map[i].substring(0, map[i].indexOf(' |:| '));
			map[i] = map[i].trim();
			return map[i];
		}
	}
}
function getOptions(option = null)
{
	var names = [
		['Sensitivity', ['r5', 'rt5'], 'radio'],
		['Key', ['r6', 'rt6'], 'radio'],
		['Mode', 'md', 'dropdown'],
		['IgnoreNote', 'in', 'text'],
		['player1', 'p1', 'text'],
		['player2', 'p2', 'text'],
		['player3', 'p3', 'text'],
		['stage', 'st', 'text'],
		['speed', ['r0', 'rt0'], 'radio'],
		['LuaSave', 'ls', 'dropdown'],
		['needsVoices', 'nv', 'dropdown'],
		['gfSection', 'gs', 'dropdown'],
		['altAnim', 'aa', 'dropdown'],
		['mustHitSection', 'mhs', 'dropdown'],
		['bpm', ['r1', 'rt1'], 'radio'],
		['Side', 's', 'dropdown'],
		['AudioFileName', 'afn', 'text'],
		['Artist', 'ar', 'text'],
		['Creator', 'cr', 'text'],
		//['Version', 'diff', 'text'],
		['Background', 'bg', 'text'],
		['Source', 'source', 'text'],
		['HPDrainRate', ['r2', 'rt2'], 'radio'],
		['OverallDifficulty', ['r4', 'rt4'], 'radio'],
		['VolumeHitSound', ['r3', 'rt3'], 'radio']
	];
	if (option == null)
	{
		for (let i = 0; i < names.length; i++)
		{
			//console.log(names);
			if (names[i][2] == 'text')
			{
				names[i][1] = document.getElementById(names[i][1]).value;
			}
			else if (names[i][2] == 'radio')
			{
				if (names[i][0] == 'Key' && document.getElementById(names[i][1][0]).value == '0')
					names[i][1] = 'none';
				else
					names[i][1] = document.getElementById(names[i][1][0]).value;
			}
			else if (names[i][2] == 'dropdown')
			{
				var n = document.getElementById(names[i][1]);
				names[i][1] = n.options[n.selectedIndex].value;
			}
		}
		return names;
	}
	else
	{
		for (let i = 0; i < names.length; i++)
			if (names[i][0] == option)
			{
				if (names[i][2] == 'text')
				{
					return document.getElementById(names[i][1]).value;
				}
				if (names[i][2] == 'radio')
				{
					if (names[i][0] == 'Key' && document.getElementById(names[i][1][0]).value == '0')
						return 'none';
					else
						return document.getElementById(names[i][1][0]).value;
				}
				else if (names[i][2] == 'dropdown')
				{
					var n = document.getElementById(names[i][1]);
					return n.options[n.selectedIndex].value;
				}
			}
	}
}

function rtd()
{
	var result = confirm('Do you want reset default options?');
	if (result)
	{
		//alert('Declined');
		file.deleteFile('options.ini');
		file.run('mccmd');
		setOptions();
	}
}

function parseBool(string)
{
	if (string == '1' || string == 'true' || string == 'y' || string == 'yes' || string == 'on')
		return '1';
	else
		return '0';
}
function makeSongName(string, toreplace, replacer)
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

function getMapOptions(map, name)
{
	for (let i = 0; i < map.length; i++)
		if (map[i].toLowerCase().startsWith(name.toLowerCase() + ':'))
			return map[i].substring(map[i].lastIndexOf(':') + 1).trim(); 

	debug.warn('Map option ' + name + ' not found!');
	return null;
}

function tocmdargs(opt, inputfilename, outputfilename)
{
	if (!file.exists('assets/output'))
		file.createDir('assets/output');

	if (inputfilename.includes('.'))
		inputfilename = inputfilename.substring(0, inputfilename.lastIndexOf('.'));
	if (outputfilename.includes('.'))
		outputfilename = outputfilename.substring(0, outputfilename.lastIndexOf('.'));
	
	if (getOptions('Mode') == '1')
	{
		let damaposu = file.parseTXT(inputfilename + '.osu');
		let songnameosu = getMapOptions(damaposu, 'Title').toLowerCase().replaceAll(' ', '-');
		let diffnameosu = getMapOptions(damaposu, 'Version').toLowerCase().replaceAll(' ', '-');
		outputfilename = songnameosu + '-' + diffnameosu;
		//console.log(outputfilename);
	}

	var stri = '-fileinput:"' + inputfilename + '" -fileoutput:"assets/output/' + outputfilename + '"';
	for (let i = 0; i < opt.length; i++)
		stri += ' -' + opt[i][0].toLowerCase() + ':"' + opt[i][1] + '"';
	
	if (getOptions('Mode') == '2')
	{
		try
		{
			let songname = file.parseJSON(inputfilename + '.json').song.song.toLowerCase().replaceAll(' ', '-');
			let diff = 'Normal';
			if (songname.length != inputfilename.length && inputfilename.includes(songname))
				diff = makeSongName(inputfilename.substring(inputfilename.indexOf(songname) + songname.length + 1), '-', ' ');

			stri += ' -version:"' + diff + '"';
			//console.log(diff);
		}
		catch (e)
		{
			//console.log('error: ' + e);
			stri += ' -version:"Normal"';
		}
	}
	//console.log(stri);
	return stri;
}

document.getElementById('inputfile').addEventListener('change', function()
{
	if (!file.exists('assets/output'))
		file.createDir('assets/output');
	let files = this.files;
	if (files.length == 1)
	{
		let dafile = files[0];
		/*if (dafile.name.endsWith('.zip') || dafile.name.endsWith('.osz')) // i make this later
		{
			if (!file.exists('assets/input'))
				file.createDir('assets/input');
			file.run('mccmd unpack "' + dafile.path + '" "assets/input"');
			let damaps = file.readDir('assets/input');
			for (let i = 0; i < damaps.length; i++)
			{
				if (damaps[i].endsWith('.json'))
				{
					let damap = damaps[i];
					let tosave = damap.substring(0, damap.lastIndexOf('.')) + '-' + getOptions('Key') + 'k.json';
					if (getOptions('Mode') == '2' || getOptions('Mode') == '3')
						tosave = '';
					let argsmc = tocmdargs(getOptions(), 'assets/input/' + damap, 'assets/output/' + tosave);
					file.run('mccmd ' + argsmc);
				}
			}
		}*/
		let tosave = dafile.name.substring(0, dafile.name.lastIndexOf('.')) + '-' + getOptions('Key') + 'k.json';
		if (getOptions('Mode') == '2' || getOptions('Mode') == '3')
			tosave = '';
		let argsmc = tocmdargs(getOptions(), dafile.path, tosave);
		file.run('mccmd ' + argsmc);
		let damaps = file.readDir('assets/output');
		let a = document.createElement('a');
		let blob = new Blob([file.getContent('assets/output/' + damaps[0])], {'type': 'text/plain'});
		a.href = window.URL.createObjectURL(blob);
		a.download = damaps[0];
		a.click();
	}
	else
	{
		for (let i = 0; i < files.length; i++)
		{
			let dafile = files[i];
			//console.log(dafile);
			let tosave = dafile.name.substring(0, dafile.name.lastIndexOf('.')) + '-' + getOptions('Key') + 'k.json';
			if (getOptions('Mode') == '2' || getOptions('Mode') == '3')
				tosave = '';
			let argsmc = tocmdargs(getOptions(), dafile.path, tosave);
			file.run('mccmd ' + argsmc);
		}
		let modes = [
			'FNF',
			'osu!mania to FNF',
			'FNF to osu!mania',
			'osu!mania'
		];
		let packname = 'assets/output/' + getOptions('Source') + ' [' + modes[getOptions('Mode')] + '].zip';
		file.run('mccmd pack "assets/output" "' + packname + '"');
		let a = document.createElement('a');
		let blob = new Blob([file.getContent(packname)], {'type': 'application/zip'});
		a.href = window.URL.createObjectURL(blob);
		a.download = packname.substring(packname.lastIndexOf('/') + 1);
		a.click();
	}
	file.deleteDir('assets/output');
	document.getElementById('inputfile').disabled = true;
	document.getElementById('inputfile').style.opacity = 0;
	ipcRenderer.send('dasender2', getOptions());
	document.location.reload(true);
})

function ur(d)
{
	switch(d)
	{
		case 0:
			document.getElementById('rt0').textContent = document.getElementById('r0').value;
			//console.log(document.getElementById('r0').value);
			break;
		case 1:
			document.getElementById('rt1').textContent = document.getElementById('r1').value;
			break;
		case 2:
			document.getElementById('rt2').textContent = document.getElementById('r2').value;
			break;
		case 3:
			document.getElementById('rt3').textContent = document.getElementById('r3').value + '%';
			break;
		case 4:
			document.getElementById('rt4').textContent = document.getElementById('r4').value;
			break;
		case 5:
			document.getElementById('rt5').textContent = document.getElementById('r5').value + 'ms';
			break;
		case 6:
			if (parseInt(document.getElementById('r6').value) == 0)
				document.getElementById('rt6').textContent = 'none';
			else
				document.getElementById('rt6').textContent = document.getElementById('r6').value;
			break;
	}
}
