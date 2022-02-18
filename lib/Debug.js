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

exports.trace = function (string)
{
	if (!file.exists('log.txt'))
		file.saveFile('log.txt', '');

	var log = file.getContent('log.txt').toString();
	log += '[' + date() + '] [TRACE] ' + string + '\n';

	file.saveFile('log.txt', log);
	console.log('[' + date() + '] [TRACE] ' + string);
}

exports.warn = function (string)
{
	if (!file.exists('log.txt'))
		file.saveFile('log.txt', '');

	var log = file.getContent('log.txt').toString();
	log += '[' + date() + '] [WARN] ' + string + '\n';

	file.saveFile('log.txt', log);
	console.log('[' + date() + '] [WARN] ' + string);
}

exports.error = function (string)
{
	if (!file.exists('log.txt'))
		file.saveFile('log.txt', '');

	var log = file.getContent('log.txt').toString();
	log += '[' + date() + '] [ERROR] ' + string + '\n';

	file.saveFile('log.txt', log);
	console.log('[' + date() + '] [ERROR] ' + string);
	throw 'Closing...';
}