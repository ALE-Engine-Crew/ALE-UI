package ale.ui;

import ale.ui.ALEUISpriteGroup;
import ale.ui.ALEUISprite;
import ale.ui.ALEUIUtils;
import ale.ui.ALEButton;

import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.FlxBasic;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;

class ALETab extends ALEUISpriteGroup
{
    public var bg:ALEUISprite;
    public var border:ALEButton;

    var minButton:ALEButton;

    public var staticObjects:Array<ALEUIObject> = [];

    public var minimized(default, set):Bool;
    function set_minimized(value:Bool):Bool
    {
        minimized = value;

        for (obj in members)
            if (obj is ALEUIObject)
            {
                var obj:ALEUIObject = cast obj;

                obj.allowDraw = obj.allowUpdate = !minimized;
            }
        
        return minimized;
    }

    var canMove:Bool = false;

    public var mouseOffset:Dynamic = {
        x: 0,
        y: 0
    };

    public var movable:Bool = true;

    public function new(?x:Float, ?y:Float, ?w:Float, ?h:Float, ?title:String)
    {
        super();

        var intW:Int = Math.floor(w ?? 500);
        var intH:Int = Math.floor(h ?? 500);

        bg = new ALEUISprite();
        bg.makeGraphic(intW, intH, ALEUIUtils.setAlpha(ALEUIUtils.adjustColorBrightness(ALEUIUtils.color, -50), 0.75));
        ALEUIUtils.outlineBitmap(bg.pixels);
        add(bg);

        border = new ALEButton(0, 0, intW, 25, false, ' ' + (title ?? 'ALE Psych'));
        add(border);
        border.text.x = 0;
        border.y = bg.y - border.height + 2;
        border.animated = false;
        border.callback = () -> {
            if (!movable)
                return;

            canMove = true;

            mouseOffset.x = FlxG.mouse.x - this.x;
            mouseOffset.y = FlxG.mouse.y - this.y;
        };
        border.releaseCallback = () -> {
            if (!movable)
                return;
            
            canMove = false;

            if (this.x > FlxG.width || this.y > FlxG.height)
            {
                FlxTween.cancelTweensOf(this);

                if (this.x > FlxG.width)
                    FlxTween.tween(this, {x: FlxG.width - 40}, 0.5, {ease: FlxEase.cubeOut});

                if (this.y - 40 > FlxG.height)
                    FlxTween.tween(this, {y: FlxG.height}, 0.5, {ease: FlxEase.cubeOut});
            }
        };

        minButton = new ALEButton(0, border.y, border.height, border.height, false, '-');
        add(minButton);
        minButton.x = border.x + border.width - border.height;
        minButton.releaseCallback = () -> {
            minimized = !minimized;

            minButton.text.text = minimized ? '+' : '-';
        };

        staticObjects = [border, minButton];

        this.x = x;
        this.y = y ?? 25;
    }

    override function updateUI(elapsed:Float)
    {
        if (canMove)
        {
            x = FlxG.mouse.x - mouseOffset.x;
            y = FlxG.mouse.y - mouseOffset.y;
        }
        
        super.updateUI(elapsed);
    }
}