var file = require('./lib/FileAPI.js');
var converter = require('./lib/Converter.js');
var alg = require('./lib/Algorithm.js');
var options = require('./lib/Options.js');
var debug = require('./lib/Debug.js');
var version = '1.3';

debug.trace('Starting version ' + version + '...');

alg.createAlgorithm();
options.checkOptionsINI();

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
		file.saveFile(options.getOption('FileOutput') + '.json', converter.convert(options.getOption('FileInput') + '.osu', parseInt(options.getOption('Mode'))));
		break;
	case 2: // to osu
		var map = converter.convert(options.getOption('FileInput') + '.json', parseInt(options.getOption('Mode')));
		file.saveFile(options.getOption('FileOutput') + map[1] + '.osu', map[0]);
		break;
	case 3: // osu
		var map = converter.convert(options.getOption('FileInput') + '.osu', parseInt(options.getOption('Mode')));
		file.saveFile(options.getOption('FileOutput') + map[1] + '.osu', map[0]);
		break;
	default: // fnf
		file.saveFile(options.getOption('FileOutput') + '.json', converter.convert(options.getOption('FileInput') + '.json', parseInt(options.getOption('Mode'))));
}

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