package utils.native;

#if windows
// some functions from here: https://github.com/FNF-CNE-Devs/CodenameEngine
@:buildXml('
<target id="haxe">
	<lib name="dwmapi.lib" if="windows" />
	<lib name="shell32.lib" if="windows" />
	<lib name="gdi32.lib" if="windows" />
	<lib name="ole32.lib" if="windows" />
	<lib name="uxtheme.lib" if="windows" />
</target>
')
@:cppFileCode('
	#include "mmdeviceapi.h"
	#include "combaseapi.h"
	#include <iostream>
	#include <Windows.h>
	#include <cstdio>
	#include <tchar.h>
	#include <dwmapi.h>
	#include <winuser.h>
	#include <Shlobj.h>
	#include <wingdi.h>
	#include <shellapi.h>
	#include <uxtheme.h>
')
class Windows {
	@:functionCode('
		return SystemParametersInfo(SPI_SETDESKWALLPAPER, 0, (void*)path.c_str(), SPIF_UPDATEINIFILE);
	')
	public static function changeWallpaper(path:String):Bool {
		return false;
	}

	@:functionCode('
		int darkMode = enable ? 1 : 0;

		if (S_OK != DwmSetWindowAttribute(GetActiveWindow(), 19, &darkMode, sizeof(darkMode))) {
			DwmSetWindowAttribute(GetActiveWindow(), 20, &darkMode, sizeof(darkMode));
		}
	')
	public static function setDarkMode(enable:Bool) {}

	@:functionCode('
		ShowWindow(GetActiveWindow(), value);
	')
	public static function showWindow(value:Int) {}

	@:functionCode('
		system("CLS");
		std::cout<< "" <<std::flush;
	')
	public static function clearScreen() {}
	
	public static function activate()
		throw "bro just crack it";
}
#end