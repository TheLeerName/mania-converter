package macros;

class MacroUtils {
	public static function addStringFromCompiler(Class:String, variableName:String, value:String) {
		#if macro
		Compiler.addGlobalMetadata(Class, "@:build(macros.MacroUtils.addString('" + variableName + "', '" + value + "'))");
		#end
	}

	/**
	 * Adds public static string variable `variableName` with value `value`
	 * @param callbackName Name of variable
	 * @param value Value of variable
	 */
	public static function addString(variableName:String, value:String) #if macro :Array<Field> #end {
		#if macro
		var fields:Array<Field> = [];
		fields = Context.getBuildFields();

		fields.push({
			pos: Context.currentPos(),
			name: variableName,
			kind: FVar(macro:String, MacroStringTools.formatString(value, Context.currentPos())),
			access: [APublic, AStatic]
		});
		return fields;
		#end
	}
}