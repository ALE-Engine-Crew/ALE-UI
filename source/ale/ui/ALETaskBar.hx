package ale.ui;

enum abstract Orientation(String)
{
    var UP = 'up';
    var DOWN = 'down';
}

class ALETaskBar extends FlxSpriteGroup
{
    public var barHeight:Int = 25;
    
    public var outline:FlxSprite;
    public var bg:FlxSprite;

    public var buttonX:Float = 0;

    public var font:String = '';
    public var barColor:FlxColor;

    override public function new(?color:FlxColor = FlxColor.BLUE, ?font:String, ?orientation:Orientation = DOWN)
    {
        super();

        this.font = font;
        this.barColor = color;

        outline = new FlxSprite().makeGraphic(FlxG.width, barHeight + 1);
        add(outline);

        bg = new FlxSprite(0, orientation == UP ? 0 : 1).makeGraphic(FlxG.width, barHeight, ALEUIUtils.adjustColorBrightness(barColor, -75));
        add(bg);

        y = orientation == UP ? 0 : FlxG.height - outline.height;
    }

    public function addWindow(string:String, window:ALEWindow)
    {
        var button:ALEButton = new ALEButton(string, buttonX, 1, 150, barHeight, null, function(_)
            {
                window.minimize(false);
                
                window.visible = !window.visible;
            },
        barColor, font);
        add(button);

        buttonX += button.outline.width;
    }
}