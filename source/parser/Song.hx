package parser;

class Song {} // doing nothing

typedef SwagSection = {
	var sectionNotes:Array<Dynamic>;
	var sectionBeats:Float;
	var typeOfSection:Int;
	var mustHitSection:Bool;
	var gfSection:Bool;
	var bpm:Float;
	var changeBPM:Bool;
	var altAnim:Bool;
}

// coding lesson number idk: var ?keyCount:Int; and var keyCount:Null<Int>; the same thing
typedef SwagSong = {
	var song:String;
	var notes:Array<SwagSection>;
	var events:Array<Dynamic>;
	var bpm:Float;
	var needsVoices:Bool;
	var speed:Float;
	var ?keyCount:Int;

	var player1:String;
	var player2:String;
	var gfVersion:String;
	var stage:String;

	var ?generatedBy:String;
}