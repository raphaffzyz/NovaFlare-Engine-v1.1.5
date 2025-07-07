package options;

import sys.FileSystem;
import sys.io.File;

class OptionsHelpers
{
	public static function colorArray(data:String):FlxColor
	{
	    switch(data)
	    {
		    case 'BLACK': return FlxColor.BLACK;
		    case 'WHITE': return FlxColor.WHITE;
		    case 'GRAY': return FlxColor.GRAY;
		    case 'RED': return FlxColor.RED;
		    case 'GREEN': return FlxColor.GREEN;
		    case 'BLUE': return FlxColor.BLUE;
		    case 'YELLOW': return FlxColor.YELLOW;
		    case 'PINK': return FlxColor.PINK;
		    case 'ORANGE': return FlxColor.ORANGE;
		    case 'PURPLE': return FlxColor.PURPLE;
		    case 'BROWN': return FlxColor.BROWN;
		    case 'CYAN': return FlxColor.CYAN;
	    }
	    return FlxColor.WHITE;
	}
}