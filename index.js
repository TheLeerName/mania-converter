const {app, BrowserWindow} = require('electron')
var ipc = require('electron').ipcMain;
const path = require('path')
var file = require('./FileAPI.js');

function createWindow () {
	mainWindow = new BrowserWindow({
		width: 1113,
		height: 502,
		title: 'Mania Converter',
		autoHideMenuBar: true,
		resizable: false,
		fullscreenable: false,
		maximizable: false,
		webPreferences: {
			nodeIntegration: true,
			contextIsolation: false,
			enableRemoteModule: true,
			preload: path.join(__dirname, 'preload.js')
		}
	});
	mainWindow.loadFile('index.html');
	mainWindow.on('close', function ()
	{
		mainWindow.webContents.send('dasender1', 'poop');
		ipc.on('dasender2', function (event, message) {
			var names = message;
			var opt = file.parseTXT('options.ini');
			for (let i = 0; i < names.length; i++)
			{
				opt[findLine(opt, names[i][0])] = names[i][0] + ":" + names[i][1];
				//console.log(names[i][0] + ":" + names[i][1]);
			}
			file.saveFile('options.ini', opt.join('\n'));
		});
	});
}
function findLine(array, find, fromLine = 0, toLine = null)
{
	if (toLine == null)
		toLine = array.length;

	for (let i = fromLine; i < toLine; i++)
		if (array[i].includes(find))
			return i;

	return -1;
}

app.whenReady().then(() => {
	createWindow()
	app.on('activate', function () {
		if (BrowserWindow.getAllWindows().length == 0) createWindow()
	})
})

app.on('window-all-closed', function () {
	if (process.platform !== 'darwin') app.quit();
})
