package sprite;

import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;

class DescriptionPrompt extends FlxSpriteGroup {
	var bg:FlxSprite;
	public function new() {
		super();
		bg = new FlxSprite(0, 0).makeGraphic(200, 50, 0xff000000);
		bg.visible = false;
		add(bg);
	}

	override function update(elapsed:Float) {
		super.update(elapsed);
	}
}