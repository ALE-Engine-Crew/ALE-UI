package ale.ui;

class ALEUIUtils
{
    public static function adjustColorBrightness(color:FlxColor, factor:Float):FlxColor
    {
        factor = factor / 100;
    
        var r = (color >> 16) & 0xFF;
        var g = (color >> 8) & 0xFF;
        var b = color & 0xFF;
    
        if (factor > 0)
        {
            r += Std.int((255 - r) * factor);
            g += Std.int((255 - g) * factor);
            b += Std.int((255 - b) * factor);
        } else {
            r = Std.int(r * (1 + factor));
            g = Std.int(g * (1 + factor));
            b = Std.int(b * (1 + factor));
        }
    
        return FlxColor.fromRGB(r, g, b);
    }

    public static function getUISprite(x:Float, y:Float, width:Float, height:Float, color:FlxColor, ?showBorder:Bool = true):FlxSprite
    {
        var theWidth:Int = Math.floor(width);
        var theHeight:Int = Math.floor(height);

        var sprite:FlxSprite = new FlxSprite(x, y);
        sprite.makeGraphic(theWidth, theHeight, FlxColor.TRANSPARENT);

        for (y in 0...theHeight)
        {
            var theColor = adjustColorBrightness(color, y < theHeight / 2 ? 0 : -25);

            for (x in 0...theWidth)
                sprite.pixels.setPixel32(x, y, (x == 0 || x == theWidth - 1 || y == 0 || y == theHeight - 1) && showBorder ? FlxColor.WHITE : theColor);
        }

        sprite.dirty = true;

        return sprite;
    }
}