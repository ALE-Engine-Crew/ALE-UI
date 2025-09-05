package ale.ui;

import flixel.addons.display.FlxRuntimeShader;

import lime.graphics.opengl.GLProgram;
import lime.app.Application;

import ale.ui.ALEUIUtils;

class ALERuntimeShader extends FlxRuntimeShader
{
    public var shaderName:String = '';

    public function new (?shaderName:String, ?fragmentSource:String, ?vertexSource:String)
    {
        this.shaderName = shaderName;
        
        super(fragmentSource, vertexSource);
    }

	override function __createGLProgram(vertexSource:String, fragmentSource:String):GLProgram
	{
		try
		{
			final res = super.__createGLProgram(vertexSource, fragmentSource);

			return res;
		} catch (error) {
			ALEUIUtils.debugTrace('Error when Starting Shader "' + shaderName + '":\n' + error, ERROR);

			return null;
		}
	}
}