package ale.ui;

import flixel.FlxSprite;
import flixel.FlxBasic;
import flixel.math.FlxPoint;

class ALEUISprite extends FlxSprite implements ALEUIObject
{
    public var allowUpdate:Bool = true;
    public var allowDraw:Bool = true;

    public var mousePosition:FlxPoint = FlxPoint.get();

    public function mouseOverlaps(obj:FlxBasic):Bool
        return FlxG.mouse.overlaps(obj, cameras[0]);

    override function update(elapsed:Float)
    {
        if (!allowUpdate)
            return;

        super.update(elapsed);

        updateUI(elapsed);
        
        mousePosition = FlxG.mouse.getScreenPosition(cameras[0]);
    }

    public function updateUI(elapsed:Float) {}

    override function draw()
    {
        if (!allowDraw)
            return;

        super.draw();

        drawUI();
    }

    public function drawUI() {}
}