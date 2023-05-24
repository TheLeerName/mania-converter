package sprite;

import flixel.FlxG;
import flixel.FlxBasic;
import flixel.math.FlxMath;
import flixel.#if (flixel >= "5.3.0") sound #else system #end.FlxSound;
import flixel.input.keyboard.FlxKey;

class SecretWordType extends FlxBasic {

	var wordKeyArray:Array<FlxKey> = [];
	public var word(default, set):String;
	function set_word(value:String):String {
		wordKeyArray = [];
		for (th in value.split("")) wordKeyArray.push(FlxKey.fromString(th.toUpperCase()));
		return word = value;
	}

	public var curIndex:Int;
	public var onComplete:Void->Void;

	public var sound:FlxSound;
	public var soundNamePress(default, set):String;
	function set_soundNamePress(value:String):String {
		if (FlxG.sound.list.members.contains(sound)) FlxG.sound.list.remove(sound, true);

		sound = new FlxSound();
		if (value != null) sound.loadEmbedded(Paths.sound(value));
		sound.volume = 0.25;
		FlxG.sound.list.add(sound);

		return soundNamePress = value;
	}

	public function new(word:String, ?soundNamePress:String, ?onComplete:Void->Void) {
		super();

		this.word = word;
		this.onComplete = onComplete;
		this.soundNamePress = soundNamePress;
	}

	public override function update(elapsed:Float) {
		super.update(elapsed);

		if (FlxG.keys.justPressed.ANY) {
			if (FlxG.keys.anyJustPressed([wordKeyArray[curIndex]])) {
				sound.pitch = FlxMath.lerp(0.75, 1.25, (1 / word.length) * curIndex);
				sound.play(true);

				curIndex++;
				if (curIndex > word.length - 1) {
					curIndex = 0;
					if (onComplete != null) onComplete();
				}
			}
			else
				curIndex = 0;
		}
	}
	
	public override function destroy()
	{
		if (sound != null) sound.destroy();
		super.destroy();
	}
}