package;

//import flixel.FlxG;
import flixel.addons.ui.FlxUIState;
import flixel.addons.transition.FlxTransitionableState;
//import flixel.FlxState;
//import flixel.FlxBasic;

class StateWorker extends FlxUIState
{
	override function create() {
		super.create();
		FlxTransitionableState.skipNextTransOut = true;
		FlxTransitionableState.skipNextTransIn = true;
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
	}
}
