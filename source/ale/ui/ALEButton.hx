package ale.ui;

import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.text.FlxText.FlxTextAlign;

import ale.ui.ALEUISpriteGroup;
import ale.ui.ALEUIUtils;

class ALEButton extends ALEUISpriteGroup
{
    public var bg:FlxSprite;
    public var text:FlxText;
    public var mask:FlxSprite;

    public var animated:Bool = true;

    public var canPress(default, set):Bool = true;
    function set_canPress(value:Bool):Bool
    {
        canPress = value;

        if (pressed)
        {
            if (animated)
                scale.x = scale.y = 1;

            pressed = false;
        }

        mask.color = canPress ? FlxColor.WHITE : FlxColor.BLACK;

        return canPress;
    }

    public function new(?x:Float, ?y:Float, ?w:Float, ?h:Float, ?shadowed:Bool, ?string:String, ?brightness:Float)
    {
        super(x, y);

        var intW:Int = Math.floor(w ?? 125);
        var intH:Int = Math.floor(h ?? 25);

        bg = new FlxSprite().makeGraphic(intW, intH, FlxColor.TRANSPARENT);
        bg.pixels = ALEUIUtils.uiBitmap(intW, intH, shadowed, brightness);
        add(bg);

        text = new FlxText(0, 0, 0, string ?? 'Button', Math.floor(Math.min(intW, intH) / 1.5));
        text.font = ALEUIUtils.font;
        text.x = bg.width / 2 - text.width / 2;
        text.y = bg.height / 2 - text.height / 2;
        add(text);

        mask = new FlxSprite().makeGraphic(intW, intH);
        add(mask);
        mask.alpha = 0;
    }

    public var pressed:Bool = false;

    public var callback:Void -> Void;
    public var releaseCallback:Void -> Void;

    override function updateUI(elapsed:Float)
    {
        super.updateUI(elapsed);

        if (mouseOverlaps(this))
        {
            if (FlxG.mouse.justPressed)
            {
                if (canPress)
                {
                    if (callback != null)
                        callback();

                    if (animated)
                        scale.x = scale.y = 0.975;

                    pressed = true;
                }
            }
        }

        if (FlxG.mouse.justReleased && pressed)
        {
            if (releaseCallback != null)
                releaseCallback();

            if (animated)
                scale.x = scale.y = 1;

            pressed = false;
        }

        if (!animated)
            return;

        var maskAlpha:Float = canPress ? (alpha * (pressed ? 0.25 : mouseOverlaps(this) ? 0.1 : 0)) : 0.25;

        if (mask.alpha != maskAlpha)
            mask.alpha = maskAlpha;
    }
}