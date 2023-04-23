package macros;

#if sys
import sys.io.Process;
#end

using StringTools;

/**
 * This class used for move assets to `export` folder
 */
class MoveAssets {
	/**
	 * Moves `folder` to export without creating `manifest` folder. Works on Windows target only
	 *
	 * To properly use this, add this line to Project.xml: `<haxeflag name="--macro" value="macros.MoveAssets.moveFolder('assets')" />`
	 * @param folder Moves this folder to export
	 */
	public static function moveFolder(folder:String = "assets")
	{
		#if (macro && windows)
		var d:Process = new Process("echo %cd%");
		var programPath:String = d.stdout.readLine();
		d.close();
		var assetsPath:String = programPath + "\\" + folder.replace("/", "\\");
		var exportPath:String = programPath + "\\" + Compiler.getOutput().substring(0, Compiler.getOutput().lastIndexOf("/")).replace("/", "\\") + "\\bin\\" + folder.replace("/", "\\");
		Sys.command("mkdir \"" + exportPath + "\" >nul 2>&1");
		Sys.command("xcopy \"" + assetsPath + "\" \"" + exportPath + "\" /s/h/e/k/c/y >nul 2>&1");
		#end
	}
}