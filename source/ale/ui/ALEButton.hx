package ale.ui;

class ALEButton extends FlxSpriteGroup
{
    public var callback:String -> Void;
    public var releaseCallback:String -> Void;

    public var pressed = false;

    public var outline:FlxSprite;
    public var black:FlxSprite;
    public var bg:FlxSprite;
    public var text:FlxText;

    override public function new(string:String, ?x:Float = 0, ?y:Float = 0, ?width:Int = 150, ?height:Int = 25, ?callback:String -> Void, ?releaseCallback:String -> Void, ?color:FlxColor = FlxColor.BLUE, ?font:String)
    {
        super();

        outline = new FlxSprite().makeGraphic(width, height, FlxColor.WHITE);
        outline.alpha = 0.75;
        add(outline);

        black = new FlxSprite(1, 1).makeGraphic(width - 2, height - 2, FlxColor.BLACK);
        add(black);

        bg = FlxGradient.createGradientFlxSprite(width - 2, height - 2, [color, ALEUIUtils.adjustColorBrightness(color, -50)]);
        bg.setPosition(1, 1);
        bg.alpha = 0.25;
        add(bg);

        text = new FlxText(0, 0, width - 2, string, 16);
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
}