var fs = require('fs');
var https = require('https');
var zip = require('zip-local');
var cp = require('child_process');
var debug = require('./Debug.js');


function checkFolders(path)
{
	var ar = [];
	if (path.includes('\\'))
		ar = path.split('\\');
	else if (path.includes('/'))
		ar = path.split('/');
	else
		return true;

	for (let i = 0; i < ar.length - 1; i++)
		if (!exists(ar[i]))
			createDir(ar[i]);
	return true;
}

exports.parseTXT = function(path, fromFile = true)
{
	var daList = [];
	if (fromFile)
	{
		checkFolders(path);
		if (exists(path))
			daList = fs.readFileSync(path).toString().split('\n');
		else
			debug.error('Can\'t parse ' + path + ', file is not exist!');
	}
	else
		daList = path.split('\n');
	for (let i = 0; i < daList.length; i++)
		daList[i] = daList[i].trim();
	return daList;
}

exports.parseJSON = function(path, fromFile = true)
{
	try
	{
		if (!fromFile)
			return JSON.parse(path);
		if (fs.existsSync(path))
			return JSON.parse(fs.readFileSync(path));
		else
			debug.error('Can\'t parse ' + path + ', file is not exist!');
	}
	catch (e)
	{
		debug.warn('Can\'t parse ' + path + ', ' + e);
		return 228;
	}
}

exports.stringify = function(path, string = "\t", fromFile = true)
{
	if (!fromFile)
		return JSON.stringify(path, null, string);
	checkFolders(path);
	if (fs.existsSync(path) && fromFile)
		return JSON.stringify(fs.readFileSync(path), null, string);
	else
		debug.error('Can\'t stringify ' + path + ', file is not exist!');
}	

exports.txt = function(array_, split = '\n')
{
	/*var array = [];
	for (let i = 0; i < array_.length; i++)
		array[i] = array_[i].toString();

	var string = '';
	for (let i = 0; i < array.length; i++)
		string += array[i] + split;
	console.log(array);
	console.log(string);
	return string;*/

	return array_.join('\n');
}

exports.isDir = function(path)
{
	if (!fs.existsSync(path))
		return false;
	return fs.lstatSync(path).isDirectory();
}

exports.readDir = function(path)
{
	checkFolders(path);
	if (fs.lstatSync(path).isDirectory())
	{
		var ara = [];
		fs.readdirSync(path).forEach(file => {ara.push(file);});
		return ara;
	}
	else
		debug.error('Can\'t read directory ' + path + ', directory is not exist!');
}

exports.createDir = function(path) {return createDir(path);}
function createDir(path)
{
	checkFolders(path);
	if (!fs.existsSync(path))
		fs.mkdirSync(path);
	else
		debug.warn('Can\'t create directory ' + path + ', directory already exist!');
}

exports.deleteFile = function(path)
{
	if (fs.existsSync(path))
		cp.execSync('cmd /c "@erase /s /q /f ' + path + '"');
	else
		debug.warn('Can\'t delete file ' + path + ', file is not exist!');
}
exports.deleteDir = function(path)
{
	cp.execSync('@erase /s /q /f "' + path.replaceAll('/', '\\') + '\\"');
	cp.execSync('@rmdir /s /q "' + path.replaceAll('/', '\\') + '"');
}
exports.run = function(command)
{
	cp.execSync('@' + command);
}

exports.exists = function(path) {return exists(path);}
function exists(path)
{
	checkFolders(path);
	return fs.existsSync(path);
}

exports.getContent = function(path)
{
	checkFolders(path);
	if (fs.existsSync(path))
		return fs.readFileSync(path);
	else
		debug.error('Error: Can\'t get content from ' + path + ', file is not exist!');
}

exports.saveFile = function(to_file, data = '')
{
	checkFolders(to_file);
	fs.writeFileSync(to_file, data/*, function (err) {if (err) throw err;}*/);
}

exports.downloadFile = function(url, to_file)
{
	checkFolders(to_file);
	fs.writeFileSync(to_file, cp.execFileSync('curl', ['--silent', '-L', url]));
}

exports.copyFile = function(from_file, to_file)
{
	checkFolders(to_file);
	//fs.copyFileSync(from_file, to_file);
	fs.writeFileSync(to_file, fs.readFileSync(from_file));
}

exports.pack = function (dir, to_file)
{
	checkFolders(to_file);
	zip.sync.zip(dir).compress().save(to_file);
}
exports.unpack = function (from_file, dir)
{
	checkFolders(dir);
	if (!fs.existsSync(dir))
		fs.mkdirSync(dir);
	zip.sync.unzip(from_file).save(dir);
}

/*public function closeWindow()
{
	Application.current.window.close();
}*/