package ale.ui;

import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.text.FlxText.FlxTextAlign;
import flixel.addons.display.shapes.FlxShapeCircle;

import ale.ui.ALEUISpriteGroup;
import ale.ui.ALEUIUtils;

class ALECircleButton extends ALEUISpriteGroup
{
    public var bg:FlxShapeCircle;
    public var circle:FlxShapeCircle;
    public var text:FlxText;
    public var mask:FlxSprite;

    public var value(default, set):Bool = false;
    function set_value(val:Bool):Bool
    {
        value = val;

        if (circle != null)
            circle.visible = value;

        return value;
    }

    public var animated:Bool = true;

    public var canPress(default, set):Bool = true;
    function set_canPress(value:Bool):Bool
    {
        canPress = value;

        if (bg != null) // REMOVE THIS
        {
            if (pressed)
            {
                if (animated)
                    bg.scale.x = bg.scale.y = circle.scale.x = circle.scale.y = 1;

                pressed = false;
            }

            mask.color = canPress ? FlxColor.WHITE : FlxColor.BLACK;
        }

        return canPress;
    }

    public function new(?x:Float, ?y:Float, ?label:String, ?size:Float, ?initial:Bool)
    {
        super(x, y);
        
        size ??= 11.5;

        bg = new FlxShapeCircle(0, 0, size, {thickness: size / 10, color: ALEUIUtils.outlineColor}, ALEUIUtils.color);
        add(bg);
        bg.x = this.x + 0.75;
        bg.y = this.y + 0.75;

        circle = new FlxShapeCircle(0, 0, size / 2, {thickness: 0, color: ALEUIUtils.outlineColor}, ALEUIUtils.outlineColor);
        add(circle);
        circle.x = bg.x + bg.width / 2 - circle.width / 2;
        circle.y = bg.y + bg.height / 2 - circle .height / 2;

        mask = new FlxShapeCircle(0, 0, size, {thickness: size / 10, color: FlxColor.WHITE}, FlxColor.WHITE);
        add(mask);
        mask.x = this.x + size / 20;
        mask.y = this.y + size / 20;

        text = new FlxText(0, 0, 0, label ?? 'CircleButton', Math.floor(size * 1.75));
        text.font = ALEUIUtils.font;
        add(text);
        text.x = this.x + bg.width + size / 2;
        text.y = this.y + bg.height / 2 - text.height / 2;

        value = initial ?? false;
    }

    public var pressed:Bool = false;

    public var callback:Void -> Void;
    public var releaseCallback:Void -> Void;

    override function updateUI(elapsed:Float)
    {
        super.updateUI(elapsed);

        if (FlxG.mouse.overlaps(bg))
        {
            if (FlxG.mouse.justPressed)
            {
                if (canPress)
                {
                    if (callback != null)
                        callback();

                    if (animated)
                        bg.scale.x = bg.scale.y = circle.scale.x = circle.scale.y = 0.975;

                    pressed = true;
                }
            }
        }

        if (FlxG.mouse.justReleased && pressed)
        {
            value = !value;

            if (releaseCallback != null)
                releaseCallback();

            if (animated)
                bg.scale.x = bg.scale.y = circle.scale.x = circle.scale.y = 1;

            pressed = false;
        }

        if (!animated)
            return;

        var maskAlpha:Float = canPress ? (alpha * (pressed ? 0.25 : FlxG.mouse.overlaps(bg) ? 0.1 : 0)) : 0.25;

        if (mask.alpha != maskAlpha)
            mask.alpha = maskAlpha;
    }
}