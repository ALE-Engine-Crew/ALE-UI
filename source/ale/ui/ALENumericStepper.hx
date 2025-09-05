package ale.ui;

import ale.ui.ALEUISpriteGroup;
import ale.ui.ALEUISprite;
import ale.ui.ALEUIUtils;
import ale.ui.ALEButton;

import flixel.text.FlxText;
import flixel.FlxBasic;

import haxe.ds.StringMap;

using StringTools;

class ALENumericStepper extends ALEUISpriteGroup
{
    public var bg:ALEUISprite;
    public var text:FlxText;
    public var plusButton:ALEButton;
    public var minusButton:ALEButton;

    public var callback:Void -> Void;

    public var value(default, set):Float = 0;
    function set_value(val:Float):Float
    {
        value = val;

        text.text = Std.string(value);

        return value;
    }

    public function new(?x:Float, ?y:Float, ?w:Float, ?h:Float, ?min:Float, ?max:Float, ?step:Float, ?initial:Float)
    {
        super(x, y);

        var intW:Int = Math.floor(w ?? 100);
        var intH:Int = Math.floor(h ?? 25);

        bg = new ALEUISprite();
        bg.makeGraphic(intW - intH * 2, intH, ALEUIUtils.adjustColorBrightness(ALEUIUtils.color, -50));
        ALEUIUtils.outlineBitmap(bg.pixels);
        add(bg);

        text = new FlxText(width * 0.1, 0, 0, '0', Math.floor(Math.min(intW - intH * 2, intH) / 1.5));
        text.font = ALEUIUtils.font;
        text.y = bg.height / 2 - text.height / 2;
        add(text);

        step ??= 1;
        min ??= 0;
        max ??= 999;
        
        plusButton = new ALEButton(bg.width + intH, 0, intH, intH, true, '+');
        add(plusButton);
        plusButton.releaseCallback = () -> {
            value += step;

            if (value < min)
                value = max;

            if (value > max)
                value = min;

            value = formatValue(value, step);

            if (callback != null)
                callback();
        };

        minusButton = new ALEButton(bg.width, 0, intH, intH, true, '-');
        add(minusButton);
        minusButton.releaseCallback = () -> {
            value -= step;

            if (value < min)
                value = max;

            if (value > max)
                value = min;

            value = formatValue(value, step);

            if (callback != null)
                callback();
        };

        value = initial ?? 0;
    }

    function formatValue(v:Float, step:Float):Float
    {
        var decimals:String = Std.string(step).split('.')[1] ?? '';

        var pow = Math.pow(10, decimals.length);   

        return Math.round(v * pow) / pow;
    }
}