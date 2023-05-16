package utils;

#if windows
import utils.native.Windows;
#end

/**
 * Class used for native functions of Windows
 */
class NativeAPI {
	/**
	 * Changes wallpaper to image in `path`. Returns `true` if wallpaper was successfully changed.
	 * @param path Path to image
	 */
	public static function changeWallpaper(path:String):Bool {
		#if (sys && windows)
		path = getPathAbsolute(path);
		if (path != null) return Windows.changeWallpaper(path);
		#end
		return false;
	}

	/**
	 * Sets dark mode of window. Works only in Windows 11 Build 22000 and higher!
	 * @param value If false, disables dark mode
	 */
	public static function setDarkMode(value:Bool) {
		#if (sys && windows)
		Windows.setDarkMode(value);
		#end
	}

	public static function showWindow() {
		#if (sys && windows)
		Windows.showWindow(1);
		#end
	}
	public static function hideWindow() {
		#if (sys && windows)
		Windows.showWindow(0);
		#end
	}

	public static function clearConsole() {
		#if (sys && windows)
		Windows.clearScreen();
		#end
	}

	/**
	 * Returns absolute path to file. If file is not exists then returns `null`.
	 * @param path Path to file
	 */
	public static function getPathAbsolute(?path:String):Null<String> {
		#if sys
		if (path == null) return null;
		if (path.charAt(1) != ":") path = Sys.programPath().substring(0, Sys.programPath().lastIndexOf("\\") + 1) + path.replace("/", "\\");
		if (FileSystem.exists(path)) return path;
		#end
		return null;
	}
}