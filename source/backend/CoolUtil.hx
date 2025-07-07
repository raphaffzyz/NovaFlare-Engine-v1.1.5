package backend;

import flixel.util.FlxSave;
import openfl.utils.Assets;
import flixel.FlxBasic;
import flixel.FlxObject;

class CoolUtil
{
	inline public static function quantize(f:Float, snap:Float){
		// changed so this actually works lol
		var m:Float = Math.fround(f * snap);
		//trace(snap);
		return (m / snap);
	}

	inline public static function capitalize(text:String)
		return text.charAt(0).toUpperCase() + text.substr(1).toLowerCase();

	inline public static function coolTextFile(path:String):Array<String>
	{
		var daList:String = null;
		#if (sys && MODS_ALLOWED)
		var formatted:Array<String> = path.split(':'); //prevent "shared:", "preload:" and other library names on file path
		path = formatted[formatted.length-1];
		if(FileSystem.exists(path)) daList = File.getContent(path);
		#else
		if(Assets.exists(path)) daList = Assets.getText(path);
		#end
		return daList != null ? listFromString(daList) : [];
	}

	inline public static function colorFromString(color:String):FlxColor
	{
		var hideChars = ~/[\t\n\r]/;
		var color:String = hideChars.split(color).join('').trim();
		if(color.startsWith('0x')) color = color.substring(color.length - 6);

		var colorNum:Null<FlxColor> = FlxColor.fromString(color);
		if(colorNum == null) colorNum = FlxColor.fromString('#$color');
		return colorNum != null ? colorNum : FlxColor.WHITE;
	}

	inline public static function listFromString(string:String):Array<String>
	{
		var daList:Array<String> = [];
		daList = string.trim().split('\n');

		for (i in 0...daList.length)
			daList[i] = daList[i].trim();

		return daList;
	}

	public static function floorDecimal(value:Float, decimals:Int):Float
	{
		if(decimals < 1)
			return Math.floor(value);

		var tempMult:Float = 1;
		for (i in 0...decimals)
			tempMult *= 10;

		var newValue:Float = Math.floor(value * tempMult);
		return newValue / tempMult;
	}

	inline public static function dominantColor(sprite:flixel.FlxSprite):Int
	{
		var countByColor:Map<Int, Int> = [];
		for(col in 0...sprite.frameWidth) {
			for(row in 0...sprite.frameHeight) {
				var colorOfThisPixel:Int = sprite.pixels.getPixel32(col, row);
				if(colorOfThisPixel != 0) {
					if(countByColor.exists(colorOfThisPixel))
						countByColor[colorOfThisPixel] = countByColor[colorOfThisPixel] + 1;
					else if(countByColor[colorOfThisPixel] != 13520687 - (2*13520687))
						countByColor[colorOfThisPixel] = 1;
				}
			}
		}

		var maxCount = 0;
		var maxKey:Int = 0; //after the loop this will store the max color
		countByColor[FlxColor.BLACK] = 0;
		for(key in countByColor.keys()) {
			if(countByColor[key] >= maxCount) {
				maxCount = countByColor[key];
				maxKey = key;
			}
		}
		countByColor = [];
		return maxKey;
	}
	
	inline public static function getComboColor(sprite:flixel.FlxSprite):Int
	{
		var countByColor:Map<Int, Int> = [];
		var colorCount:Int= 0;
		for(col in 0...sprite.frameWidth) {
            for(row in 0...sprite.frameHeight) {
                var colorOfThisPixel:Int = sprite.pixels.getPixel32(col, row);
                if(colorOfThisPixel != 0) {
                    if(countByColor.exists(colorOfThisPixel))
                        countByColor[colorOfThisPixel] = countByColor[colorOfThisPixel] + 1;
                    else if(countByColor[colorOfThisPixel] != 13520687 - (2*13520687))
                        countByColor[colorOfThisPixel] = 1;
                        
                    colorCount++;
                }
            }
        }
		var maxCount = 0;
		var maxKey:Int = 0xFFFFFFFF; //after the loop this will store the max color
		for(key in countByColor.keys()) {
			if(countByColor[key] > maxCount && key != FlxColor.BLACK) {
				maxCount = countByColor[key];
				maxKey = key;
			}
		}
		
		if (countByColor[FlxColor.BLACK] >= sprite.frameHeight * sprite.frameWidth * 0.5)
		maxKey = 0xFF000000;  //50%+ is black, so main color is black, it use for fix something
		
		countByColor = [];
		return maxKey;
	}

	inline public static function numberArray(max:Int, ?min = 0):Array<Int>
	{
		var dumbArray:Array<Int> = [];
		for (i in min...max) dumbArray.push(i);

		return dumbArray;
	}

	inline public static function browserLoad(site:String) {
		#if linux
		Sys.command('/usr/bin/xdg-open', [site]);
		#else
		FlxG.openURL(site);
		#end
	}

	inline public static function openFolder(folder:String, absolute:Bool = false) {
		#if sys
			if(!absolute) folder =  Sys.getCwd() + '$folder';

			folder = folder.replace('/', '\\');
			if(folder.endsWith('/')) folder.substr(0, folder.length - 1);

			#if linux
			var command:String = '/usr/bin/xdg-open';
			#else
			var command:String = 'explorer.exe';
			#end
			Sys.command(command, [folder]);
			trace('$command $folder');
		#else
			FlxG.log.error("Platform is not supported for CoolUtil.openFolder");
		#end
	}

	/**
		Helper Function to Fix Save Files for Flixel 5

		-- EDIT: [November 29, 2023] --

		this function is used to get the save path, period.
		since newer flixel versions are being enforced anyways.
		@crowplexus
	**/
	@:access(flixel.util.FlxSave.validate)
	inline public static function getSavePath():String {
		final company:String = FlxG.stage.application.meta.get('company');
		// #if (flixel < "5.0.0") return company; #else
		return '${company}/${flixel.util.FlxSave.validate(FlxG.stage.application.meta.get('file'))}';
		// #end
	}

	public static function setTextBorderFromString(text:FlxText, border:String)
	{
		switch(border.toLowerCase().trim())
		{
			case 'shadow':
				text.borderStyle = SHADOW;
			case 'outline':
				text.borderStyle = OUTLINE;
			case 'outline_fast', 'outlinefast':
				text.borderStyle = OUTLINE_FAST;
			default:
				text.borderStyle = NONE;
		}
	}

		/**
	 * Replacement for `FlxG.mouse.overlaps` because it's currently broken when using a camera with a different position or size.
	 * It will be fixed eventually by HaxeFlixel v5.4.0.
	 * 
	 * @param 	objectOrGroup The object or group being tested.
	 * @param 	camera Specify which game camera you want. If null getScreenPosition() will just grab the first global camera.
	 * @return 	Whether or not the two objects overlap.
	 */
	 @:access(flixel.group.FlxTypedGroup.resolveGroup)
	 inline public static function mouseOverlaps(objectOrGroup:FlxBasic, ?camera:FlxCamera):Bool
	 {
		 var result:Bool = false;
 
		 final group = FlxTypedGroup.resolveGroup(objectOrGroup);
		 if (group != null)
		 {
			 group.forEachExists(function(basic:FlxBasic)
			 {
				 if (mouseOverlaps(basic, camera))
				 {
					 result = true;
					 return;
				 }
			 });
		 }
		 else
		 {
			 final point = FlxG.mouse.getWorldPosition(camera, FlxPoint.weak());
			 final object:FlxObject = cast objectOrGroup;
			 result = object.overlapsPoint(point, true, camera);
		 }
 
		 return result;
	 }
}
