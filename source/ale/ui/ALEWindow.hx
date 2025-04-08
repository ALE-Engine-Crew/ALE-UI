package ale.ui;

import flixel.math.FlxPoint;

class ALEWindow extends FlxSpriteGroup
{
    public var outline:FlxSprite;

    public var title:FlxText;

    public var border:FlxSprite;

    public var minimizeButton:ALEButton;

    public var window:FlxSprite;

    public var minimized:Bool = false;

    public var draggable(default, set):Bool = true;

    function set_draggable(value:Bool):Bool
    {
        draggable = value;

        if (dragging && !draggable)
            dragging = false;

        return draggable;
    }

    public var minimizable(default, set):Bool = true;

    function set_minimizable(value:Bool):Bool
    {
        minimizable = value;

        minimizeButton.visible = minimizable;

        return minimizable;
    }

    public function minimize(?theBool:Null<Bool> = null):Void
    {
        if (!minimizable)
            return;

        minimized = theBool != null ? theBool : !minimized;

        var showObjects:Array<Dynamic> = [border, title, outline, minimizeButton];

        for (object in members)
            if (!showObjects.contains(object))
                object.visible = !minimized;

        minimizeButton.text.text = minimized ? '+' : '-';
        
        outline.scale.y = minimized ? border.height + 2 : border.height + window.height + 4;
        outline.updateHitbox();
    }

    override public function new(string:String, ?x:Float, ?y:Float, ?width:Int = 500, ?height:Int = 300, ?color:FlxColor = FlxColor.BLUE)
    {
        super();

        this.x = x;
        this.y = y;

        border = ALEUIUtils.getUISprite(1, 1, width - 2, 25, color);
        
        minimizeButton = new ALEButton('-', 0, 0, 25, 25, color);
        minimizeButton.x = 1 + border.width - minimizeButton.width;
        minimizeButton.y = 1 + border.height / 2 - minimizeButton.height / 2;
        minimizeButton.callback = function (_)
        {
            minimize();
        };

        title = new FlxText(border.x + 4, 0, width - 8, string, 16);
        title.y = border.y + border.height / 2 - title.height / 2;

        window = new FlxSprite(1, border.y + border.height + 1).makeGraphic(width - 2, height - 2, ALEUIUtils.adjustColorBrightness(color, -75));

        outline = new FlxSprite().makeGraphic(1, 1);
        outline.scale.set(width, border.height + window.height + 4);
        outline.updateHitbox();

        add(outline);
        add(border);
        add(title);
        add(minimizeButton);
        add(window);
    }

    public var dragging:Bool = false;
    private var mouseOffset:FlxPoint = new FlxPoint();

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        if (!visible || !draggable)
            return;

        if (FlxG.mouse.overlaps(border) && !FlxG.mouse.overlaps(minimizeButton) && FlxG.mouse.justPressed)
        {
            dragging = true;

            mouseOffset.x = FlxG.mouse.getWorldPosition(cameras[0]).x - x;
            mouseOffset.y = FlxG.mouse.getWorldPosition(cameras[0]).y - y;
        }

        if (dragging && FlxG.mouse.justReleased)
        {
            dragging = false;

            if (x > FlxG.width - 50)
                x = FlxG.width - 50;
            
            if (x < -border.width + 50)
                x = -border.width + 50;

            if (y > FlxG.height - border.height)
                y = FlxG.height - border.height;

            if (y < 0)
                y = 0;
        }

        if (dragging)
        {
            x = FlxG.mouse.getWorldPosition(cameras[0]).x - mouseOffset.x;
            y = FlxG.mouse.getWorldPosition(cameras[0]).y - mouseOffset.y;
        }
    }
}