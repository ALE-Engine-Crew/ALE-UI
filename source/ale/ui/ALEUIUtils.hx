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
}