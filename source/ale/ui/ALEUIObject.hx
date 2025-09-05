package ale.ui;

import flixel.math.FlxPoint;
import flixel.FlxBasic;

interface ALEUIObject
{
    public var allowUpdate:Bool;
    public var allowDraw:Bool;

    public var mousePosition:FlxPoint;

    public function mouseOverlaps(spr:FlxBasic):Bool;
    public function updateUI(elapsed:Float):Void;
    public function drawUI():Void;
}