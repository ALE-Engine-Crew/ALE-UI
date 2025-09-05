package ale.ui;

import flixel.group.FlxSpriteGroup;

class ALEUISpriteGroup extends FlxSpriteGroup implements ALEUIObject
{
    public var allowUpdate:Bool = true;
    public var allowDraw:Bool = true;

    override function update(elapsed:Float)
    {
        if (!allowUpdate)
            return;

        super.update(elapsed);

        updateUI(elapsed);
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