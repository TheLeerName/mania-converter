package group;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;

class DescriptionGroup extends Group {
	public var txt:FlxText;
	public var desc(default, set):String;
	function set_desc(value:String):String {
		if (desc == value) return value;
		if (value == "")
		{
			txt.text = defaultDescriptions[0] /*+ "\n" + defaultDescriptions[FlxG.random.int(1, defaultDescriptions.length - 1)]*/;
			return desc = value;
		}
		return txt.text = desc = value;
	}

	var defaultDescriptions:Array<String> = [
		"Hover mouse on label to see desc!",
		"Someone said if you press O W C keys, but idk in which order, smth will appear.",
		"i want to eat.",
		"cyber swag 2077",
		"challenge: convert galaxy collapse to 9 keys and do full combo on it",
		"nerf this",
		"barbecue bacon burger",
		"i want collab of sonic and angry birds",
		"Please take a shower immediately.",
		"mario",
		"lol",
		"fun fact: you will suffer for your sins.",
		"FNF PLAYER SPOTTED DEPLOYING camellia ghost brand FNF PLAYER MAULING PITBULL",
		"FNF PLAYER SPOTTED DEPLOYING laur sound chimera brand FNF PLAYER MAULING PITBULL",
		"FNF PLAYER SPOTTED DEPLOYING %puthardsonghere% brand FNF PLAYER MAULING PITBULL",
		"FNF PLAYER SPOTTED DEPLOYING null brand FNF PLAYER MAULING PITBULL",
		"OSU PLAYER SPOTTED DEPLOYING fnf bopeebo brand OSU PLAYER MAULING PITBULL",
		"you should be hiding it's march 15",
		"huh?",
		"i use psych engine too *gif with sonic and shadow kissing*",
		"hello my name is big boobs",
		"u going to ohio"
	];

	public function new(x:Float, y:Float, ?width:Int, ?height:Int) {
		super(x, y, width, height);

		txt = new FlxText(0, 0, width, "");
		txt.setFormat(Paths.get.font("verdana.ttf"), 12, 0xff000000, LEFT);
		add(txt);
	}
}