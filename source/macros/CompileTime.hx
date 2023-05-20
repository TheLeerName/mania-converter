package macros;

/**
 * This class used for creating variable with compile time of this build, ex. `2023-04-16 21:17:17 (UTC +7)`. To properly use:
 * 1. Add this line to `Project.xml`: `<haxeflag name="--macro" value="macros.CompileTime.addCompileTime('TitleState', 'compileTime')" />`
 * 2. Fully replace `import.hx` with this line: `#if !macro import Paths; #end`
 * 3. Now class `TitleState` will have `public static var compileTime:String = "2023-04-16 21:17:17 (UTC +7)";` variable (time is example)
 */
class CompileTime {
	/**
	 * Adds `variableName` variable with compile time of this build to `addToClass`, ex. `2023-04-16 21:17:17 (UTC +7)`
	 *
	 * To properly use this, add this line to Project.xml: `<haxeflag name="--macro" value="macros.CompileTime.addCompileTime('TitleState', 'compileTime')" />`
	 * @param Class Variable will be added in this class name
	 * @param variableName Name of variable to add
	 */
	public static function addCompileTime(Class:String, variableName:String)
	{
		#if macro
		// 2023-04-16 21:17:17 (UTC +7)
		var timeStr:String = DateTools.format(Date.now(), "%Y-%m-%d %H:%M:%S") + " (UTC " + Std.string((Date.now().getTimezoneOffset() / 60 * -1) > 0 ? ("+" + (Date.now().getTimezoneOffset() / 60 * -1)) : (Date.now().getTimezoneOffset() / 60 * -1)) + ")";
		MacroUtils.addStringFromCompiler(Class, variableName, timeStr);
		trace("CompileTime: " + timeStr);
		#end
	}
}