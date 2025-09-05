package ale.ui;

import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import flixel.text.FlxText.FlxTextAlign;
import flixel.addons.display.shapes.FlxShapeCircle;

import ale.ui.ALEUISpriteGroup;
import ale.ui.ALENumericStepper;
import ale.ui.ALEUIUtils;
import ale.ui.ALERuntimeShader;

class ALEColorPicker extends ALEUISpriteGroup
{
    public var shaderHSB:String = '
        #pragma header

        vec3 hsv2rgb(vec3 c)
        {
            vec4 k = vec4(1.0, 2.0/3.0, 1.0/3.0, 3.0);
            
            vec3 p = abs(fract(c.xxx + k.xyz) * 6.0 - k.www);
            
            return c.z * mix(k.xxx, clamp(p - k.xxx, 0.0, 1.0), c.y);
        }

        uniform float hue;

        void main()
        {
            vec2 uv = openfl_TextureCoordv.xy;
            
            vec4 tex = texture2D(bitmap, uv);

            if(tex.a > 0.0)
                tex.rgb += hsv2rgb(vec3(hue / 360, uv.x, 1.0 - uv.y));

            gl_FragColor = tex;
        }
    ';

    public var shaderHUE:String = '
        #pragma header

        vec3 hsv2rgb(vec3 c)
        {
            vec4 k = vec4(1.0, 2.0/3.0, 1.0/3.0, 3.0);
            
            vec3 p = abs(fract(c.xxx + k.xyz) * 6.0 - k.www);
            
            return c.z * mix(k.xxx, clamp(p - k.xxx, 0.0, 1.0), c.y);
        }

        void main()
        {
            vec2 uv = openfl_TextureCoordv.xy;
            
            vec4 tex = texture2D(bitmap, uv);

            if(tex.a > 0.0)
                tex.rgb += hsv2rgb(vec3(uv.x, 1, 1));

            gl_FragColor = tex;
        }
    ';

    public var spriteHSB:FlxSprite;
    public var selHSB:FlxSprite;

    public var spriteHUE:FlxSprite;
    public var selHUE:FlxSprite;

    public var curColor(default, set):FlxColor = FlxColor.WHITE;
    function set_curColor(value:FlxColor):FlxColor
    {
        curColor = value;

        if (spriteHUE != null && selHUE != null) // REMOVE
        {
            cast(spriteHSB.shader, ALERuntimeShader).setFloat('hue', hue);

            selHUE.x = x + intW * (hue / 360);
            
            setColorOffset(selHUE, FlxColor.fromHSB(hue, 1, 1));
        }

        if (spriteHSB != null && selHSB != null) // REMOVE
        {
            selHSB.y = y + spriteHSB.height - spriteHSB.height * brigthness;

            selHSB.x = x + intW * saturation;
            
            setColorOffset(selHSB, curColor);
        }

        return curColor;
    }

    public var hue:Float = 1;

    public var brigthness:Float = 1;

    public var saturation:Float = 1;

    public var intW:Int = 0;
    public var intH:Int = 0;

    public var rStepper:ALENumericStepper;
    public var gStepper:ALENumericStepper;
    public var bStepper:ALENumericStepper;

    public function new(?x:Float, ?y:Float, ?w:Float, ?h:Float)
    {
        super(x, y);

        intW = Math.floor(w ?? 150);
        intH = Math.floor(h ?? 150);

        spriteHSB = new FlxSprite().makeGraphic(intW, intH, FlxColor.BLACK);
        add(spriteHSB);
        ALEUIUtils.outlineBitmap(spriteHSB.pixels);
        spriteHSB.shader = new ALERuntimeShader('shader', shaderHSB);

        selHSB = new FlxSprite().makeGraphic(Math.floor(intH / 10), Math.floor(intH / 10), FlxColor.BLACK);
        ALEUIUtils.outlineBitmap(selHSB.pixels);
        add(selHSB);
        selHSB.offset.x = selHSB.offset.y = intH / 20;

        spriteHUE = new FlxSprite(0, intH * 1.1).makeGraphic(intW, Math.floor(intH / 10), FlxColor.BLACK);
        add(spriteHUE);
        ALEUIUtils.outlineBitmap(spriteHUE.pixels);
        spriteHUE.shader = new ALERuntimeShader('shader', shaderHUE);

        selHUE = new FlxSprite().makeGraphic(Math.floor(intW / 15), Math.floor(intH / 8), FlxColor.BLACK);
        ALEUIUtils.outlineBitmap(selHUE.pixels);
        add(selHUE);
        selHUE.offset.x = intH / 30;
        selHUE.y = spriteHUE.y + spriteHUE.height / 2 - selHUE.height / 2;

        hue = 0;
        saturation = 1;
        brigthness = 1;
        
        curColor = FlxColor.fromHSB(hue, saturation, brigthness);

        rStepper = new ALENumericStepper(intW * 1.2, null, null, null, 0, 255);
        add(rStepper);

        gStepper = new ALENumericStepper(intW * 1.2, null, null, null, 0, 255);
        add(gStepper);

        bStepper = new ALENumericStepper(intW * 1.2, null, null, null, 0, 255);
        add(bStepper);

        for (index => obj in [rStepper, gStepper, bStepper])
        {
            obj.y = this.y + intH / 2 + (index + 1) * 55 - intH / 2 - 22.5;

            var text:FlxText = new FlxText(0, 0, 0, ['Red', 'Green', 'Blue'][index], 17);
            text.font = ALEUIUtils.font;
            add(text);
            text.x = obj.x;
            text.y = obj.y - text.height - 2;
        }

        rStepper.value = curColor >> 16 & 0xFF;
        rStepper.callback = rgbColor;

        gStepper.value = curColor >> 8 & 0xFF;
        gStepper.callback = rgbColor;

        bStepper.value = curColor & 0xFF;
        bStepper.callback = rgbColor;
    }

    var changingHUE:Bool = false;
    var changingHSB:Bool = false;

    override function updateUI(elapsed:Float)
    {
        super.updateUI(elapsed);

        if (FlxG.mouse.justPressed)
        {
            if (FlxG.mouse.overlaps(spriteHUE))
                changingHUE = true;
            else if (FlxG.mouse.overlaps(spriteHSB))
                changingHSB = true;
        }

        if (FlxG.mouse.justReleased)
        {
            if (changingHUE)
                changingHUE = false;

            if (changingHSB)
                changingHSB = false;
        }

        if (changingHSB)
        {
            saturation = FlxMath.bound((FlxG.mouse.x - spriteHSB.x) / intW, 0, 1);

            brigthness = FlxMath.bound(1 - (FlxG.mouse.y - spriteHSB.y) / intH, 0, 1);
        }

        if (changingHUE)
            hue = FlxMath.bound((FlxG.mouse.x - spriteHUE.x) / intW * 360, 0, 360);

        if (changingHSB || changingHUE)
        {
            curColor = FlxColor.fromHSB(hue, saturation, brigthness);

            rStepper.value = curColor >> 16 & 0xFF;
            gStepper.value = curColor >> 8 & 0xFF;
            bStepper.value = curColor & 0xFF;
        }
    }

    function setColorOffset(spr:FlxSprite, color:FlxColor)
    {
        spr.colorTransform.redOffset = color >> 16 & 0xFF;
        spr.colorTransform.greenOffset = color >> 8 & 0xFF;
        spr.colorTransform.blueOffset = color & 0xFF;
    }

    function rgbToHSB(r:Int, g:Int, b:Int):{h:Float, s:Float, b:Float}
    {
        var rf:Float = r / 255;
        var gf:Float = g / 255;
        var bf:Float = b / 255;

        var max:Float = Math.max(rf, Math.max(gf, bf));

        var delta:Float = max - Math.min(rf, Math.min(gf, bf));

        var h:Float = 0;
        var s:Float = max == 0 ? 0 : delta / max;
        var b:Float = max;

        if (delta != 0)
        {
            if (max == rf)
                h = (gf - bf) / delta % 6;
            else if (max == gf)
                h = (bf - rf) / delta + 2;
            else
                h = (rf - gf) / delta + 4;

            h *= 60;

            if (h < 0)
                h += 360;
        }

        return {
            h: h,
            s: s,
            b: b
        };
    }

    inline function rgbColor()
    {
        var data:Dynamic = {
            r: rStepper.value,
            g: gStepper.value,
            b: bStepper.value
        };

        var hsb = rgbToHSB(data.r, data.g, data.b);

        hue = hsb.h;
        saturation = hsb.s;
        brigthness = hsb.b;

        curColor = FlxColor.fromRGB(data.r, data.g, data.b);
    }
}