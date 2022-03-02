var file = require('./FileAPI.js');

function date()
{
	var date = new Date();
	return date.getFullYear() + '-' +
	(date.getMonth() + 1) + '-' +
	date.getDate() + ' ' +
	date.getHours() + ':' +
	date.getMinutes() + ':' +
	date.getSeconds();
}

var log = [];

exports.start = function () {return start();}
function start()
{
	if (!file.exists('log.txt'))
	{
		file.saveFile('log.txt', '');
		log.push('[' + date() + '] [TRACE] Recreated a log file');
		console.log('[' + date() + '] [TRACE] Recreated a log file');
	}
	else
	{
		log = file.getContent('log.txt').toString().split('\n');
		if (log.length > 1000)
		{
			var datec = new Date();
			file.saveFile('log-' + datec.getFullYear() + '-' + (datec.getMonth() + 1) + '-' + datec.getDate() + '.txt', log.join('\n'));
			file.saveFile('log.txt', '');
			log = [];
			log.push('[' + date() + '] [TRACE] Recreated a log file (length more 1k lines)');
			console.log('[' + date() + '] [TRACE] Recreated a log file (length more 1k lines)');
		}
	}
}
exports.end = function () {return end();}
function end()
{
	file.saveFile('log.txt', log.join('\n'));
}

exports.trace = function (string)
{
	log.push('[' + date() + '] [TRACE] ' + string);
	console.log('[' + date() + '] [TRACE] ' + string);
}

exports.warn = function (string)
{
	log.push('[' + date() + '] [WARN] ' + string);
	console.log('[' + date() + '] [WARN] ' + string);
}

exports.error = function (string)
{
	log.push('[' + date() + '] [ERROR] ' + string);
	console.log('[' + date() + '] [ERROR] ' + string);
	end();
	throw 'Closing...';
}