package macros;

#if macro

using StringTools;

class MacroUtils {
	public static function addStringFromCompiler(Class:String, variableName:String, value:String, access:String = '')
		Compiler.addGlobalMetadata(Class, "@:build(macros.MacroUtils.addString('" + variableName + "', '" + value + "', '" + access + "'))");

	/**
	 * Adds string variable `variableName` with value `value`
	 * @param callbackName Name of variable
	 * @param value Value of variable
	 */
	public static function addString(variableName:String, value:String, access:String = ''):Array<Field> {
		#if macro
		var acc:Array<Access> = [];

		if (access.toLowerCase().contains('public')) acc.push(APublic);
		if (access.toLowerCase().contains('private')) acc.push(APrivate);
		if (access.toLowerCase().contains('static')) acc.push(AStatic);
		if (access.toLowerCase().contains('override')) acc.push(AOverride);
		if (access.toLowerCase().contains('dynamic')) acc.push(ADynamic);
		if (access.toLowerCase().contains('inline')) acc.push(AInline);
		if (access.toLowerCase().contains('macro')) acc.push(AMacro);
		if (access.toLowerCase().contains('final')) acc.push(AFinal);
		if (access.toLowerCase().contains('extern')) acc.push(AExtern);
		if (access.toLowerCase().contains('abstract')) acc.push(AAbstract);
		if (access.toLowerCase().contains('overload')) acc.push(AOverload);

		var fields:Array<Field> = [];
		fields = Context.getBuildFields();

		fields.push({
			pos: Context.currentPos(),
			name: variableName,
			kind: FVar(macro:String, MacroStringTools.formatString(value, Context.currentPos())),
			access: acc
		});
		return fields;
		#end
	}
}
#end