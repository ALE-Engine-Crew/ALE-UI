package ale.ui;

import flixel.group.FlxSpriteGroup;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.text.FlxText;

import flixel.util.FlxColor;
import flixel.util.FlxGradient;

class ALEButton extends FlxSpriteGroup
{
    public var callback:String -> Void;
    public var releaseCallback:String -> Void;

    public var pressed = false;

    private final outline:FlxSprite;
    private final black:FlxSprite;
    private final bg:FlxSprite;
    private final text:FlxText;

    override public function new(string:String, ?x:Float = 0, ?y:Float = 0, ?width:Int = 300, ?height:Int = 100, ?callback:String -> Void, ?releaseCallback:String -> Void, ?color:FlxColor = FlxColor.BLUE, ?font:String)
    {
        super();

        outline = new FlxSprite().makeGraphic(width, height, FlxColor.WHITE);
        outline.alpha = 0.75;
        add(outline);

        black = new FlxSprite(1, 1).makeGraphic(width - 2, height - 2, FlxColor.BLACK);
        add(black);

        bg = FlxGradient.createGradientFlxSprite(width - 2, height - 2, [color, adjustColorBrightness(color, -50)]);
        bg.setPosition(1, 1);
        bg.alpha = 0.25;
        add(bg);

        text = new FlxText(0, 0, width - 2, string, 32);
        text.alignment = CENTER;
        text.font = font;
        text.alpha = 0.75;
        text.setPosition(bg.x + bg.width / 2 - text.width / 2, bg.y + bg.height / 2 - text.height / 2);
        add(text);

        this.callback = callback;
        this.releaseCallback = releaseCallback;

        this.x = x;
        this.y = y;
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        var hovered = FlxG.mouse.overlaps(bg);
        var justPressed = FlxG.mouse.justPressed;
        var justReleased = FlxG.mouse.justReleased;

        if (hovered && justPressed)
        {
            pressed = true;

            if (callback != null) 
                callback(text.text);
        }

        if (pressed && justReleased)
        {
            pressed = false;

            if (releaseCallback != null) 
                releaseCallback(text.text);
        }

        var newOutlineAlpha = hovered ? 1 : 0.6;
        var newBgAlpha = hovered ? (pressed ? 0.75 : 0.5) : 0.3;
        var newTextAlpha = hovered ? 1 : 0.6;

        if (outline.alpha != newOutlineAlpha) 
            outline.alpha = newOutlineAlpha;

        if (bg.alpha != newBgAlpha) 
            bg.alpha = newBgAlpha;

        if (text.alpha != newTextAlpha) 
            text.alpha = newTextAlpha;
    }

    function adjustColorBrightness(color:FlxColor, factor:Float):FlxColor
    {
        factor = factor / 100;
    
        var r = (color >> 16) & 0xFF;
        var g = (color >> 8) & 0xFF;
        var b = color & 0xFF;
    
        if (factor > 0)
        {
            r += Std.int((255 - r) * factor);
            g += Std.int((255 - g) * factor);
            b += Std.int((255 - b) * factor);
        } else {
            r = Std.int(r * (1 + factor));
            g = Std.int(g * (1 + factor));
            b = Std.int(b * (1 + factor));
        }
    
        return FlxColor.fromRGB(r, g, b);
    }
}