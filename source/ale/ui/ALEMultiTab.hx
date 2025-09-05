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

import haxe.ds.StringMap;

class ALEMultiTab extends ALEUISpriteGroup
{
    public var bg:ALEUISprite;

    public var minButton:ALEButton;

    var __groups:ALEUISpriteGroup;

    var __activeGroup:ALEUISpriteGroup = null;

    public var groups:StringMap<ALEUISpriteGroup>;

    public var staticObjects:Array<ALEUIObject> = [];

    public var minimized(default, set):Bool;
    function set_minimized(value:Bool):Bool
    {
        minimized = value;

        for (obj in members)
            if (obj is ALEUISprite)
            {
                var obj:ALEUISprite = cast obj;

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

    public function new(titles:Array<String>, ?x:Float, ?y:Float, ?w:Float, ?h:Float, ?title:String)
    {
        super();

        var intW:Int = Math.floor(w ?? 500);
        var intH:Int = Math.floor(h ?? 500);

        bg = new ALEUISprite();
        bg.makeGraphic(intW, intH, ALEUIUtils.setAlpha(ALEUIUtils.adjustColorBrightness(ALEUIUtils.color, -50), 0.75));
        ALEUIUtils.outlineBitmap(bg.pixels);
        add(bg);

        minButton = new ALEButton(0, 0, 25, 25, false, '-');
        add(minButton);
        minButton.y = -23;
        minButton.x = bg.x + bg.width - 25;
        minButton.releaseCallback = () -> {
            minimized = !minimized;

            minButton.text.text = minimized ? '+' : '-';
        };

        staticObjects = [minButton];

        __groups = new ALEUISpriteGroup();
        add(__groups);

        groups = new StringMap<ALEUISpriteGroup>();

        for (index => title in titles)
        {
            var factor:Float = (intW - 25) / titles.length;

            var butt:ALEButton = new ALEButton(factor * index, -23, factor, 25, false, title);
            add(butt);
            butt.callback = () -> {
                pressFunc();
            }
            butt.releaseCallback = () -> {
                releaseFunc();

                selectGroup(title);
            }

            staticObjects.push(butt);

            var group:ALEUISpriteGroup = new ALEUISpriteGroup();
            __groups.add(group);
            group.allowDraw = group.allowUpdate = false;

            groups.set(title, group);
        }

        selectGroup(titles[0]);

        this.x = x;
        this.y = y ?? 25;
    }

    public function addObject(group:String, obj:FlxSprite):FlxSprite
    {
        if (groups.exists(group))
            groups.get(group).add(obj);

        return obj;
    }

    function selectGroup(id:String)
    {
        if (minimized || !groups.exists(id))
            return;

        if (__activeGroup != null)
            __activeGroup.allowDraw = __activeGroup.allowUpdate = false;

        __activeGroup = groups.get(id);

        __activeGroup.allowDraw = __activeGroup.allowUpdate = true;
    }

    function pressFunc()
    {
        if (!movable)
            return;

        canMove = true;

        mouseOffset.x = FlxG.mouse.x - this.x;
        mouseOffset.y = FlxG.mouse.y - this.y;
    }

    function releaseFunc()
    {
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