package ale.ui;

class ALEButton extends FlxSpriteGroup
{
    public var callback:String -> Void;
    public var releaseCallback:String -> Void;

    public var pressed = false;

    public var black:FlxSprite;
    public var bg:FlxSprite;
    public var text:FlxText;

    override public function new(string:String, ?x:Float = 0, ?y:Float = 0, ?width:Int = 150, ?height:Int = 25, ?callback:String -> Void, ?releaseCallback:String -> Void, ?color:FlxColor = FlxColor.BLUE, ?font:String)
    {
        super();

        black = new FlxSprite(0, 0).makeGraphic(width, height, FlxColor.BLACK);
        add(black);

        bg = ALEUIUtils.getUISprite(0, 0, width, height, color);
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

        if (!visible)
            return;

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

        var newbgAlpha = hovered ? 1 : 0.6;
        var newBGAlpha = hovered ? (pressed ? 1 : 0.75) : 0.5;
        var newTextAlpha = hovered ? 1 : 0.6;

        if (bg.alpha != newbgAlpha) 
            bg.alpha = newbgAlpha;

        if (bg.alpha != newBGAlpha) 
            bg.alpha = newBGAlpha;

        if (text.alpha != newTextAlpha) 
            text.alpha = newTextAlpha;
    }
}