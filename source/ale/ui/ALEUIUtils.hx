package ale.ui;

import openfl.display.BitmapData;
import openfl.geom.Rectangle;

import flixel.util.FlxColor;

enum abstract PrintType(String)
{
    var ERROR = 'error';
    var WARNING = 'warning';
    var DEPRECATED = 'deprecated';
    var TRACE = 'trace';
    var HSCRIPT = 'hscript';
    var LUA = 'lua';
    var MISSING_FILE = 'missing_file';
    var CUSTOM = 'custom';
    var POP_UP = 'pop-up';

    private static var dataMap:Map<PrintType, Array<Dynamic>> = [
        ERROR => ['ERROR', 0xFFFF5555],
        WARNING => ['WARNING', 0xFFFFA500],
        DEPRECATED => ['DEPRECATED', 0xFF8000],
        TRACE => ['TRACE', 0xFFFFFFFF],
        HSCRIPT => ['HSCRIPT', 0xFF88CC44],
        LUA => ['LUA', 0xFF4466DD],
        MISSING_FILE => ['MISSING FILE', 0xFFFF7F00],
        POP_UP => ['POP-UP', 0xFFFF00FF]
    ];

    public static function typeToString(type:PrintType):String
        return dataMap.get(type)[0];

    public static function typeToColor(type:PrintType):FlxColor
        return dataMap.get(type)[1];
}

class ALEUIUtils
{
    public static var color:FlxColor = FlxColor.fromRGB(50, 70, 100);
    public static var outlineColor:FlxColor = FlxColor.WHITE;
    public static var font:String = null;

    public static function adjustColorBrightness(color:FlxColor, factor:Float):FlxColor
    {
        var f = factor / 100;

        inline function adjust(c:Int):Int
            return f > 0 ? Std.int(c + (255 - c) * f) : Std.int(c * (1 + f));

        return FlxColor.fromRGB(adjust(color >> 16 & 0xFF), adjust(color >> 8 & 0xFF), adjust(color & 0xFF));
    }

    public static function uiBitmap(width:Int, height:Int, ?shadowed:Bool, ?brightness:Float):BitmapData
    {
        var bitmap:BitmapData = new BitmapData(width, height, true, FlxColor.TRANSPARENT);

        var midHeight:Int = Math.floor(height / 2);

        var rect:Rectangle = new Rectangle();

        rect.setTo(0, 0, width, midHeight);
        bitmap.fillRect(rect, adjustColorBrightness(color, brightness));

        rect.setTo(0, midHeight, width, midHeight);
        bitmap.fillRect(rect, adjustColorBrightness(color, (shadowed ?? true ? -30 : 0) + brightness));

        outlineBitmap(bitmap);

        return bitmap;
    }

    public static function outlineBitmap(bitmap:BitmapData, ?size:Int)
    {
        var outlineSize:Int = size ?? 2;

        var rect:Rectangle = new Rectangle();

        rect.setTo(0, 0, outlineSize, bitmap.height);
        bitmap.fillRect(rect, outlineColor);

        rect.setTo(bitmap.width - outlineSize, 0, outlineSize, bitmap.height);
        bitmap.fillRect(rect, outlineColor);

        rect.setTo(0, 0, bitmap.width, outlineSize);
        bitmap.fillRect(rect, outlineColor);

        rect.setTo(0, bitmap.height - outlineSize, bitmap.width, outlineSize);
        bitmap.fillRect(rect, outlineColor);

        return bitmap;
    }
    
	public static function setAlpha(color:FlxColor, alpha:Float):FlxColor
	{
		return (Math.floor(FlxMath.bound(Math.floor(alpha * 255), 0, 255)) << 24) | (color & 0x00FFFFFF);
	}
    
	public static function debugTrace(text:Dynamic, ?type:PrintType = TRACE, ?customType:String = '', ?customColor:FlxColor = FlxColor.GRAY, ?pos:haxe.PosInfos)
		Sys.println(ansiColorString(type == CUSTOM ? customType : PrintType.typeToString(type), type == CUSTOM ? customColor : PrintType.typeToColor(type)) + ansiColorString(' | ' + Date.now().toString().split(' ')[1] + ' | ', 0xFF505050) + (pos == null ? '' : ansiColorString(pos.fileName + ': ', 0xFF888888)) + text);
	
	public static function ansiColorString(text:String, color:FlxColor):String
		return '\x1b[38;2;' + color.red + ';' + color.green + ';' + color.blue + 'm' + text + '\x1b[0m';

	public static function fpsLerp(v1:Float, v2:Float, ratio:Float):Float
		return FlxMath.lerp(v1, v2, fpsRatio(ratio));

	public static function fpsRatio(ratio:Float)
		return FlxMath.bound(ratio * FlxG.elapsed * 60, 0, 1);
}