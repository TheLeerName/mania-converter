var file = require('./lib/FileAPI.js');
var converter = require('./lib/Converter.js');
var alg = require('./lib/Algorithm.js');
var options = require('./lib/Options.js');
var debug = require('./lib/Debug.js');

debug.start();
debug.trace('Starting version ' + require('./lib/Utils.js').getVersion() + '...');
options.checkOptionsINI();
alg.createAlgorithm();


var args = process.argv.slice(2);
switch (args[0])
{
	case 'pack':
		if (!args[2].substring(args[2].lastIndexOf('/') + 1).includes('.'))
			args[2] = args[3] + '.zip';

		if (!file.isDir(args[1]) && !file.exists(args[1]))
			debug.error('Directory ' + args[1] + ' not found');
		file.pack(args[1], args[2]);

		debug.trace('Successfully packed ' + args[2]);
		debug.exitApp();
		break;
	case 'unpack':
		if (!args[1].substring(args[1].lastIndexOf('/') + 1).includes('.'))
			args[1] = args[1] + '.zip';

		if (!file.exists(args[1]))
			debug.error('Pack ' + args[1] + ' not found');

		if (!file.exists(args[2]))
			file.createDir(args[2]);
		file.unpack(args[1], args[2]);

		debug.trace('Successfully unpacked ' + args[1]);
		debug.exitApp();
		break;
	case 'ffmpeg':

		if (!file.exists('ffmpeg.exe'))
		{
			debug.warn('FFmpeg not found! Bruh! Starting download...');
			if (!file.isDir('temp') && !file.exists('temp'))
			file.createDir('temp');
			file.downloadFile('https://github.com/BtbN/FFmpeg-Builds/releases/download/latest/ffmpeg-master-latest-win64-lgpl.zip', 'temp/ffmpeg.zip');
			file.unpack('temp/ffmpeg.zip', 'temp');
			file.copyFile('temp/ffmpeg-master-latest-win64-lgpl/bin/ffmpeg.exe', 'ffmpeg.exe');
			file.deleteDir('temp');
		}
		//debug.trace('Successfully packed ' + args[3]);
		switch(args[1])
		{
			case 'combine':
				var uf = 'trash.mp3';
				var ar = args[2].split('|');
				debug.trace('Combining ' + ar.join(' and ') + ' to ' + args[3]);
				for (let i = 0; i < ar.length; i++)
					ar[i] = '-i "' + ar[i].trim() + '"';

				if (file.exists(uf))
					file.deleteFile(uf);
				file.run('ffmpeg -y -loglevel 0 ' + ar.join(' ') + ' -filter_complex amix=inputs=' + ar.length + ':duration=first:dropout_transition=0 "' + uf + '"');
				file.run('ffmpeg -y -loglevel 0 -i "' + uf + '" -filter:a volume=2.25 "' + args[3] + '"');
				file.deleteFile(uf);
				break;
			default:
				debug.trace('Converting ' + args[2] + ' to ' + args[3]);
				file.run('ffmpeg -y -loglevel 0 -i "' + args[2] + '" "' + args[3] + '"');
		}
		debug.trace('Saved ' + args[3]);
		debug.exitApp();
		break;
}

var modes = [
	'FNF',
	'osu!mania to FNF',
	'FNF to osu!mania',
	'osu!mania'
];
debug.trace('Current mode: ' + modes[parseInt(options.getOption('Mode'))]);
switch (parseInt(options.getOption('Mode')))
{
	case 1: // to fnf
		var fileinput = options.getOption('FileInput') + '.osu';
		if (file.exists(fileinput))
			file.saveFile(options.getOption('FileOutput') + '.json', converter.convert(fileinput, parseInt(options.getOption('Mode'))));
		else
			debug.error('Couldn\'t find ' + options.getOption('FileInput') + '.osu');
		break;
	case 2: // to osu
		var fileinput = options.getOption('FileInput') + '.json';
		if (file.exists(fileinput))
		{
			var map = converter.convert(fileinput, parseInt(options.getOption('Mode')));
			file.saveFile(options.getOption('FileOutput') + map[1] + '.osu', map[0]);
		}
		else
			debug.error('Couldn\'t find ' + fileinput);
		break;
	case 3: // osu
		var fileinput = options.getOption('FileInput') + '.osu';
		if (file.exists(fileinput))
		{
			var map = converter.convert(fileinput, parseInt(options.getOption('Mode')));
			file.saveFile(options.getOption('FileOutput') + map[1] + '.osu', map[0]);
		}
		else
			debug.error('Couldn\'t find ' + fileinput);
		break;
	default: // fnf
		var fileinput = options.getOption('FileInput') + '.json';
		if (file.exists(fileinput))
			file.saveFile(options.getOption('FileOutput') + '.json', converter.convert(fileinput, parseInt(options.getOption('Mode'))));
		else
			debug.error('Couldn\'t find ' + fileinput);
}

debug.exitApp();

/*

when the imposter is sus (green version)
⠀⡯⡯⡾⠝⠘⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢊⠘⡮⣣⠪⠢⡑⡌ ㅤ  
⠀⠀⠀⠟⠝⠈⠀⠀⠀⠡⠀⠠⢈⠠⢐⢠⢂⢔⣐⢄⡂⢔⠀⡁⢉⠸⢨⢑⠕⡌ 
⠀⠀⡀⠁⠀⠀⠀⡀⢂⠡⠈⡔⣕⢮⣳⢯⣿⣻⣟⣯⣯⢷⣫⣆⡂⠀⠀⢐⠑⡌ 
⢀⠠⠐⠈⠀⢀⢂⠢⡂⠕⡁⣝⢮⣳⢽⡽⣾⣻⣿⣯⡯⣟⣞⢾⢜⢆⠀⡀⠀⠪
⣬⠂⠀⠀⢀⢂⢪⠨⢂⠥⣺⡪⣗⢗⣽⢽⡯⣿⣽⣷⢿⡽⡾⡽⣝⢎⠀⠀⠀⢡
⣿⠀⠀⠀⢂⠢⢂⢥⢱⡹⣪⢞⡵⣻⡪⡯⡯⣟⡾⣿⣻⡽⣯⡻⣪⠧⠑⠀⠁⢐
⣿⠀⠀⠀⠢⢑⠠⠑⠕⡝⡎⡗⡝⡎⣞⢽⡹⣕⢯⢻⠹⡹⢚⠝⡷⡽⡨⠀⠀⢔
⣿⡯⠀⢈⠈⢄⠂⠂⠐⠀⠌⠠⢑⠱⡱⡱⡑⢔⠁⠀⡀⠐⠐⠐⡡⡹⣪⠀⠀⢘
⣿⣽⠀⡀⡊⠀⠐⠨⠈⡁⠂⢈⠠⡱⡽⣷⡑⠁⠠⠑⠀⢉⢇⣤⢘⣪⢽⠀⢌⢎
⣿⢾⠀⢌⠌⠀⡁⠢⠂⠐⡀⠀⢀⢳⢽⣽⡺⣨⢄⣑⢉⢃⢭⡲⣕⡭⣹⠠⢐⢗
⣿⡗⠀⠢⠡⡱⡸⣔⢵⢱⢸⠈⠀⡪⣳⣳⢹⢜⡵⣱⢱⡱⣳⡹⣵⣻⢔⢅⢬⡷
⣷⡇⡂⠡⡑⢕⢕⠕⡑⠡⢂⢊⢐⢕⡝⡮⡧⡳⣝⢴⡐⣁⠃⡫⡒⣕⢏⡮⣷⡟
⣷⣻⣅⠑⢌⠢⠁⢐⠠⠑⡐⠐⠌⡪⠮⡫⠪⡪⡪⣺⢸⠰⠡⠠⠐⢱⠨⡪⡪⡰
⣯⢷⣟⣇⡂⡂⡌⡀⠀⠁⡂⠅⠂⠀⡑⡄⢇⠇⢝⡨⡠⡁⢐⠠⢀⢪⡐⡜⡪⡊
⣿⢽⡾⢹⡄⠕⡅⢇⠂⠑⣴⡬⣬⣬⣆⢮⣦⣷⣵⣷⡗⢃⢮⠱⡸⢰⢱⢸⢨⢌
⣯⢯⣟⠸⣳⡅⠜⠔⡌⡐⠈⠻⠟⣿⢿⣿⣿⠿⡻⣃⠢⣱⡳⡱⡩⢢⠣⡃⠢⠁
⡯⣟⣞⡇⡿⣽⡪⡘⡰⠨⢐⢀⠢⢢⢄⢤⣰⠼⡾⢕⢕⡵⣝⠎⢌⢪⠪⡘⡌⠀
⡯⣳⠯⠚⢊⠡⡂⢂⠨⠊⠔⡑⠬⡸⣘⢬⢪⣪⡺⡼⣕⢯⢞⢕⢝⠎⢻⢼⣀⠀
⠁⡂⠔⡁⡢⠣⢀⠢⠀⠅⠱⡐⡱⡘⡔⡕⡕⣲⡹⣎⡮⡏⡑⢜⢼⡱⢩⣗⣯⣟
⢀⢂⢑⠀⡂⡃⠅⠊⢄⢑⠠⠑⢕⢕⢝⢮⢺⢕⢟⢮⢊⢢⢱⢄⠃⣇⣞⢞⣞⢾
⢀⠢⡑⡀⢂⢊⠠⠁⡂⡐⠀⠅⡈⠪⠪⠪⠣⠫⠑⡁⢔⠕⣜⣜⢦⡰⡎⡯⡾⡽

*/