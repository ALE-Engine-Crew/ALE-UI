package ale.ui;

import ale.ui.ALEUIUtils;
import ale.ui.ALEButton;
import ale.ui.ALEUISpriteGroup;

import openfl.geom.Rectangle;

import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;

class ALEDropDown extends ALEUISpriteGroup
{
    public var bg:ALEButton;
    public var button:ALEButton;

    public var buttons:ALEUISpriteGroup;
    public var options:Array<String> = [];

    var shouldOpen:Bool = false;
    public var isOpen:Bool = false;

    public var selectedIndex:Int = 0;
    public var selected(default, set):String;
    function set_selected(value:String):String
    {
        if (selected == value)
            return value;

        if (options.contains(value))
            selected = value;

        bg.text.text = selected;

        selectedIndex = options.indexOf(selected);

        if (!isOpen)
            for (index => butt in buttons.members)
                butt.y = bg.y + intH * (index - selectedIndex);
        
        return selected;
    }

    var intW:Int = 125;
    var intH:Int = 25;

    public function new(options:Array<String>, ?x:Float, ?y:Float, ?w:Float, ?h:Float)
    {
        super(x, y);

        intW = Math.floor(w ?? 125);
        intH = Math.floor(h ?? 25);

        bg = new ALEButton(intH, 0, intW - intH, intH, false, options[0], -50);
        bg.text.x = intH + 5;
        bg.animated = false;
        add(bg);

        buttons = new ALEUISpriteGroup();
        buttons.x = -intW * 0.75;
        buttons.alpha = 0;
        add(buttons);

        button = new ALEButton(0, 0, intH, intH, true, '<');
        add(button);

        bg.releaseCallback = () -> { alternateOpen(); };
        button.releaseCallback = () -> { alternateOpen(); };

        for (option in options)
            addOption(option);

        selected = options[0];
    }

    public function alternateOpen(?force:Bool)
    {
        if (force != null)
        {
            shouldOpen = force;
        } else {
            if (shouldOpen != isOpen)
                shouldOpen = !shouldOpen;
            else
                shouldOpen = !isOpen;
        }
        
        button.text.text = shouldOpen ? '>' : '<';

        FlxTween.cancelTweensOf(buttons);

        FlxTween.tween(buttons, {x: this.x - (shouldOpen ? intW : intW * 0.75), alpha: shouldOpen ? 1 : 0}, 0.25, {ease: FlxEase.cubeOut, onComplete: (_) -> { isOpen = shouldOpen; }});
    }

    var scrollAllowed:Bool = false;

    override function updateUI(elapsed:Float)
    {
        super.updateUI(elapsed);

        var overlaped:Bool = FlxG.mouse.overlaps(this);

        if (isOpen)
        {
            if (overlaped)
            {
                if (FlxG.mouse.wheel != 0)
                {
                    if (FlxG.mouse.wheel < 0)
                        if (selectedIndex >= buttons.members.length - 1)
                            selectedIndex = 0;
                        else
                            selectedIndex++;

                    if (FlxG.mouse.wheel > 0)
                        if (selectedIndex <= 0)
                            selectedIndex = buttons.members.length - 1;
                        else
                            selectedIndex--;

                    change();
                }
            }

            for (index => butt in buttons.members)
                butt.y = ALEUIUtils.fpsLerp(butt.y, bg.y + intH * (index - selectedIndex), 0.35);
        }
        
        if (FlxG.mouse.justReleased && shouldOpen && !overlaped)
            alternateOpen(false);
    }

    public function addOption(id:String, ?index:Int)
    {
        index = index ?? buttons.members.length;

        var butt:ALEButton = new ALEButton(0, intH * (index - selectedIndex), intW, intH, false, id);
        butt.bg.pixels.fillRect(new Rectangle(0, 0, intW, intH), ALEUIUtils.adjustColorBrightness(ALEUIUtils.color, -50));
        buttons.add(butt);

        butt.releaseCallback = () -> {
            selectedIndex = index;

            change();
        };

        options.push(id);
    }

    public function change()
    {
        if (!isOpen)
            return;

        selected = cast(buttons.members[selectedIndex], ALEButton).text.text;
    }
}