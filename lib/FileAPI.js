var fs = require('fs');
var debug = require('./Debug.js');

exports.parseTXT = function(path, fromFile = true)
{
	var daList = [];
	if (fromFile)
		daList = fs.readFileSync(path).toString().split('\n');
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
	else if (fs.existsSync(path))
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
	return fs.lstatSync(path).isDirectory();
}

exports.readDir = function(path)
{
	if (fs.lstatSync(path).isDirectory())
	{
		var ara = [];
		fs.readdirSync(path).forEach(file => {ara.push(file);});
		return ara;
	}
	else
		debug.error('Can\'t read directory ' + path + ', directory is not exist!');
}

exports.createDir = function(path)
{
	if (!fs.existsSync(path))
		fs.mkdirSync(path);
	else
		debug.warn('Can\'t create directory ' + path + ', directory already exist!');
}

exports.deleteFile = function(path)
{
	if (fs.existsSync(path))
	{
		//fs.rmSync(path, { recursive: true, force: true }); // i use x86-6.0.0 for less exe size via nexe compile
		fs.writeFileSync('scrpt.bat', '@echo off\n@erase ' + path + '\n@erase scrpt.bat');
		require('child_process').exec('cmd /c scrpt.bat');
	}
	else
		debug.warn('Can\'t delete file ' + path + ', file is not exist!');
}

exports.exists = function(path)
{
	return fs.existsSync(path);
}

exports.getContent = function(path)
{
	if (fs.existsSync(path))
		return fs.readFileSync(path);
	else
		debug.error('Error: Can\'t get content from ' + path + ', file is not exist!');
}

exports.saveFile = function(to_file, data = '')
{
	fs.writeFileSync(to_file, data/*, function (err) {if (err) throw err;}*/);
}

exports.copyFile = function(from_file, to_file)
{
	fs.copyFileSync(from_file, to_file, (err) => {if (err) throw err;});
}

/*public function closeWindow()
{
	Application.current.window.close();
}*/