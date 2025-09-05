package ale.ui;

interface ALEUIObject
{
    public var allowUpdate:Bool;
    public var allowDraw:Bool;

    public function updateUI(elapsed:Float):Void;
    public function drawUI():Void;
}