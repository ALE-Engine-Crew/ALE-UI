package ale.ui;

import ale.ui.ALEUIUtils;
import ale.ui.ALEUISpriteGroup;

import flixel.FlxSprite;
import flixel.input.keyboard.FlxKey;
import flixel.text.FlxText;
import flixel.math.FlxRect;

import funkin.visuals.shaders.ALERuntimeShader;

import openfl.events.KeyboardEvent;
import openfl.ui.Keyboard;

import lime.system.Clipboard;

import haxe.ds.StringMap;

using StringTools;
    
enum abstract Filter(String)
{
    var NO_FILTER = 'no_filter';
    var ONLY_ALPHA = 'only_alpha';
    var ONLY_NUMERIC = 'only_numeric';
    var ONLY_ALPHANUMERIC = 'only_alphanumeric';
}

enum abstract Case(String)
{
    var UPPER_CASE = 'upper_case';
    var LOWER_CASE = 'lower_case';
    var NO_CASE = 'no_case';
}

class ALEInputText extends ALEUISpriteGroup
{
    public var bg:ALEUISprite;
    public var searchText:FlxText;
    public var text:FlxText;
    public var line:FlxSprite;

    public var intW:Int = 0;
    public var intH:Int = 0;

    public var openCallback:Void -> Void;
    public var closeCallback:Void -> Void;

    public var canWrite(default, set):Bool = false;
    function set_canWrite(val:Bool):Bool
    {
        if (canWrite != val)
            ALEUIUtils.usedInputs = ALEUIUtils.usedInputs + (val ? 1 : -1);

        canWrite = val;

        if (line != null)
            line.visible = canWrite;

        return canWrite;
    }

    public var value(default, set):String = '';
    function set_value(val:String):String
    {
        value = val;

        if (text != null)
        {
            text.text = value;

            setLinePos();
        }

        return value;
    }

    public var curIndex(default, set):Int = 0;
    function set_curIndex(val:Int):Int
    {
        curIndex = Math.floor(FlxMath.bound(val, 0, value.length));

        return curIndex;
    }

    public var searchList:Array<String> = [];

    public function new(?x:Float, ?y:Float, ?w:Float, ?h:Float, ?searchList:Array<String>)
    {
        super(x, y);

        intW = Math.floor(w ?? 150);
        intH = Math.floor(h ?? 25);

        bg = new ALEUISprite();
        bg.makeGraphic(intW, intH, ALEUIUtils.adjustColorBrightness(ALEUIUtils.color, -50));
        ALEUIUtils.outlineBitmap(bg.pixels);
        add(bg);

        searchText = new FlxText(0, 0, 0, '', Math.floor(Math.min(intW, intH) / 1.5));
        searchText.font = ALEUIUtils.font;
        searchText.x = searchText.size / 2;
        searchText.y = bg.height / 2 - searchText.height / 2;
        searchText.alpha = 0.5;
        add(searchText);

        text = new FlxText(0, 0, 0, '', Math.floor(Math.min(intW, intH) / 1.5));
        text.font = ALEUIUtils.font;
        text.x = text.size / 2;
        text.y = bg.height / 2 - text.height / 2;
        add(text);

        line = new FlxSprite().makeGraphic(2, Math.floor(intH * 0.6), ALEUIUtils.outlineColor);
        add(line);
        line.y = this.y + bg.height / 2 - line.height / 2;

        value = '';

        curIndex = value.length;

        setLinePos();

        FlxG.stage.addEventListener('keyDown', onKeyDown, false, 1);

        canWrite = false;

        this.searchList = searchList ?? [];
    }

    var curTime:Float = 0;

    override function updateUI(elapsed:Float)
    {
        if (FlxG.mouse.justPressed)
            if (mouseOverlaps(bg) && !canWrite)
            {
                canWrite = true;

                if (openCallback != null)
                    openCallback();
            } else if (!mouseOverlaps(bg) && canWrite) {
                canWrite = false;

                if (closeCallback != null)
                    closeCallback();
            }

        if (canWrite)
        {
            curTime += elapsed;

            if (curTime >= 0.5)
            {
                curTime = 0;

                line.visible = !line.visible;
            }
        }
        
        super.updateUI(elapsed);
    }

    override function destroy()
    {
        FlxG.stage.removeEventListener('keyDown', onKeyDown, false);

        canWrite = false;

        super.destroy();
    }

    function onKeyDown(e:KeyboardEvent):Void
    {
        if (!allowUpdate || !allowDraw || !canWrite)
            return;

        final key:FlxKey = e.keyCode;

        var addString:Null<String> = null;

        switch (key)
        {
            case FlxKey.SHIFT, FlxKey.CONTROL, FlxKey.BACKSLASH, FlxKey.ALT:
            
            case FlxKey.ENTER, FlxKey.ESCAPE:
                canWrite = false;

                if (closeCallback != null)
                    closeCallback();

                return;

            case FlxKey.TAB:
                if (searchText.text.length >= 1)
                {
                    value = searchText.text;

                    curIndex = value.length;

                    setLinePos();
                }

            case FlxKey.HOME:
                curIndex = 0;

                setLinePos();

            case FlxKey.END:
                curIndex = value.length;

                setLinePos();

            case FlxKey.LEFT:
                if (e.ctrlKey)
                {
                    while (curIndex > 0 && value.charAt(curIndex - 1) == ' ')
                        curIndex--;

                    while (curIndex > 0 && value.charAt(curIndex - 1) != ' ')
                        curIndex--;
                } else {
                    curIndex--;
                }

                setLinePos();

            case FlxKey.RIGHT:
                if (e.ctrlKey)
                {
                    while (curIndex < value.length && value.charAt(curIndex) == ' ')
                        curIndex++;

                    while (curIndex < value.length && value.charAt(curIndex) != ' ')
                        curIndex++;
                } else {
                    curIndex++;
                }
                
                setLinePos();

            case FlxKey.BACKSPACE:
                if (e.ctrlKey)
                    eraseWord();
                else
                    eraseString();

            case FlxKey.DELETE:
                if (e.ctrlKey)
                    suprWord();
                else
                    suprString();

            case FlxKey.SPACE:
                addString = ' ';

            default:
                if (e.ctrlKey && key == FlxKey.V)
                {
                    addString = Clipboard.text;
                } else {
                    addString = String.fromCharCode(e.charCode);
                }
        }
        
        if (addString != null && addString.length >= 1)
            setString(filter(addString));
    }

    function eraseString()
    {
        if (curIndex <= 0)
            return;

        value = value.substring(0, curIndex - 1) + value.substring(curIndex);

        setLinePos(-1);
    }

    function suprString()
    {
        if (curIndex >= value.length)
            return;

        value = value.substring(0, curIndex) + value.substring(curIndex + 1);

        setLinePos();
    }

    function eraseWord()
    {
        if (curIndex <= 0)
            return;

        var start = curIndex;
        
        var skipChars:Bool = value.charAt(start - 1) == ' ' && value.charAt(start - 2) != ' ';

        while (start > 0 && value.charAt(start - 1) == ' ')
            start--;

        while (!skipChars && start > 0 && value.charAt(start - 1) != ' ')
            start--;

        value = value.substring(0, start) + value.substring(curIndex);

        curIndex = start;

        setLinePos();
    }

    function suprWord()
    {
        if (curIndex >= value.length)
            return;

        var start = curIndex;
        
        var skipChars = value.charAt(start) == ' ' && value.charAt(start + 1) == ' ';

        while (start < value.length && value.charAt(start) == ' ')
            start++;

        while (!skipChars && start < value.length && value.charAt(start) != ' ')
            start++;

        value = value.substring(0, curIndex) + value.substring(start);
    }

    function setString(str:String)
    {
        if (curIndex < value.length)
            value = value.substring(0, curIndex) + str + value.substring(curIndex);
        else
            value += str;

        setLinePos(1);
    }

    public var forceCase:Case = NO_CASE;

    public var filterMode:Filter = NO_FILTER;

    function filter(text:String):String
    {
        if (forceCase == UPPER_CASE)
            text = text.toUpperCase();
        else if (forceCase == LOWER_CASE)
            text = text.toLowerCase();

        if (filterMode != NO_FILTER)
        {
            var pattern:EReg = null;

            switch (filterMode)
            {
                case ONLY_ALPHA:
                    pattern = ~/[^a-zA-Z]*/g;
                case ONLY_NUMERIC:
                    pattern = ~/[^0-9]*/g;
                case ONLY_ALPHANUMERIC:
                    pattern = ~/[^a-zA-Z0-9]*/g;
                default:
            }

            if (pattern != null)
                text = pattern.replace(text, '');
        }

        return text;
    }

    var shouldSearch:String = '';

    var searchObj:String = '';

    public function setLinePos(?change:Int)
    {
        if (change != null)
            curIndex += change;

        if (canWrite)
            line.visible = true;

        var bounds = text.textField.getCharBoundaries(curIndex - 1);

        if (bounds != null)
            line.x = text.x + bounds.x + bounds.width;
        else
            line.x = text.x;
        
        var padding:Float = text.size / 2;

        var leftLimit = bg.x + padding;

        var rightLimit = bg.x + bg.width - padding;

        if (line.x > rightLimit)
        {
            var diff = line.x - rightLimit;

            searchText.x = text.x -= diff;

            line.x -= diff;
        }

        if (line.x < leftLimit)
        {
            var diff = leftLimit - line.x;

            searchText.x = text.x += diff;

            line.x += diff;
        }

        searchText.clipRect = text.clipRect = FlxRect.get(x + padding - text.x, 0, bg.width - padding * 2, text.height);

        if (shouldSearch != value)
        {
            shouldSearch = value;
            
            searchText.text = '';

            if (value.length >= 1)
                for (obj in searchList)
                    if (obj.toLowerCase().startsWith(value.toLowerCase()))
                    {
                        searchText.text = obj;

                        break;
                    }
        }
    }
}