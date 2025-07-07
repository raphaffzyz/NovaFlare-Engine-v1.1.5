package psychlua;

import flixel.FlxBasic;
import objects.Character;
import psychlua.LuaUtils;
import psychlua.CustomSubstate;

#if LUA_ALLOWED
import psychlua.FunkinLua;
#end

#if HSCRIPT_ALLOWED
import hscript.Parser;
import hscript.Interp;
import hscript.Expr;
#end

import haxe.Exception;

#if HSCRIPT_ALLOWED
import tea.SScript;
class HScript extends SScript
{
	public var modFolder:String;

	#if LUA_ALLOWED
	public var parentLua:FunkinLua;
	public static function initHaxeModule(parent:FunkinLua)
	{
		if(parent.hscript == null)
		{
			trace('initializing haxe interp for: ${parent.scriptName}');
			parent.hscript = new HScript(parent);
		}
	}

	public static function initHaxeModuleCode(parent:FunkinLua, code:String, ?varsToBring:Any = null)
	{
		var hs:HScript = try parent.hscript catch (e) null;
		if(hs == null)
		{
			trace('initializing haxe interp for: ${parent.scriptName}');
			parent.hscript = new HScript(parent, code, varsToBring);
		}
		else
		{
			hs.doString(code);
			@:privateAccess
			if(hs.parsingException != null)
			{
				PlayState.instance.addTextToDebug('ERROR ON LOADING (${hs.origin}): ${hs.parsingException.message}', FlxColor.RED);
			}
		}
	}
	#end

	public var origin:String;
	override public function new(?parent:Dynamic, ?file:String, ?varsToBring:Any = null)
	{
		if (file == null)
			file = '';

		this.varsToBring = varsToBring;
	
		super(file, false, false);

		#if LUA_ALLOWED
		parentLua = parent;
		if (parent != null)
		{
			this.origin = parent.scriptName;
			this.modFolder = parent.modFolder;
		}
		#end

		if (scriptFile != null && scriptFile.length > 0)
		{
			this.origin = scriptFile;
			#if MODS_ALLOWED
			var myFolder:Array<String> = scriptFile.split('/');
			if(myFolder[0] + '/' == Paths.mods() && (Mods.currentModDirectory == myFolder[1] || Mods.getGlobalMods().contains(myFolder[1]))) //is inside mods folder
				this.modFolder = myFolder[1];
			#end
		}

		preset();
		execute();
	}

	var varsToBring:Any = null;
	override function preset() {
		super.preset();

		// Some very commonly used classes
		set('FlxG', flixel.FlxG);
		set('FlxMath', flixel.math.FlxMath);
		set('FlxSprite', flixel.FlxSprite);
		set('FlxCamera', flixel.FlxCamera);
		set('PsychCamera', backend.PsychCamera);
		set('FlxTimer', flixel.util.FlxTimer);
		set('FlxTween', flixel.tweens.FlxTween);
		set('FlxEase', flixel.tweens.FlxEase);
		set('FlxColor', CustomFlxColor);
		set('Countdown', backend.BaseStage.Countdown);
		set('PlayState', PlayState);
		set('Paths', Paths);
		set('SUtil', SUtil);
		set('Conductor', Conductor);
		set('ClientPrefs', ClientPrefs);
		#if ACHIEVEMENTS_ALLOWED
		set('Achievements', Achievements);
		#end
		set('Character', Character);
		set('Alphabet', Alphabet);
		set('Note', objects.Note);
		set('CustomSubstate', CustomSubstate);
		#if (!flash && sys)
		set('FlxRuntimeShader', flixel.addons.display.FlxRuntimeShader);
		#end
		set('ShaderFilter', openfl.filters.ShaderFilter);
		set('StringTools', StringTools);
		#if flxanimate
		set('FlxAnimate', FlxAnimate);
		#end

		// Functions & Variables
		set('setVar', function(name:String, value:Dynamic) {
			PlayState.instance.variables.set(name, value);
			return value;
		});
		set('getVar', function(name:String) {
			var result:Dynamic = null;
			if(PlayState.instance.variables.exists(name)) result = PlayState.instance.variables.get(name);
			return result;
		});
		set('removeVar', function(name:String)
		{
			if(PlayState.instance.variables.exists(name))
			{
				PlayState.instance.variables.remove(name);
				return true;
			}
			return false;
		});
		set('debugPrint', function(text:String, ?color:FlxColor = null) {
			if(color == null) color = FlxColor.WHITE;
			PlayState.instance.addTextToDebug(text, color);
		});
		set('getModSetting', function(saveTag:String, ?modName:String = null) {
			if(modName == null)
			{
				if(this.modFolder == null)
				{
					PlayState.instance.addTextToDebug('getModSetting: Argument #2 is null and script is not inside a packed Mod folder!', FlxColor.RED);
					return null;
				}
				modName = this.modFolder;
			}
			return LuaUtils.getModSetting(saveTag, modName);
		});

		// Keyboard & Gamepads
		set('keyboardJustPressed', function(name:String){
		    name = name.toUpperCase();
		    if (MusicBeatState.instance.mobileControls != null){   
				var extraControl = MusicBeatState.instance.mobileControls.current;
				if (name == ClientPrefs.data.extraKeyReturn1.toUpperCase() && extraControl.buttonExtra1 != null && extraControl.buttonExtra1.justPressed) return true;
				        
				if (name == ClientPrefs.data.extraKeyReturn2.toUpperCase() && extraControl.buttonExtra2 != null && extraControl.buttonExtra2.justPressed) return true;
                        
				if (name == ClientPrefs.data.extraKeyReturn3.toUpperCase() && extraControl.buttonExtra3 != null && extraControl.buttonExtra3.justPressed) return true;
                        
				if (name == ClientPrefs.data.extraKeyReturn4.toUpperCase() && extraControl.buttonExtra4 != null && extraControl.buttonExtra4.justPressed) return true;                       					
		    }
		    return Reflect.getProperty(FlxG.keys.justPressed, name);
		});
		set('keyboardPressed', function(name:String){
		    name = name.toUpperCase();
		    if (MusicBeatState.instance.mobileControls != null){		    
				var extraControl = MusicBeatState.instance.mobileControls.current;
				if (name == ClientPrefs.data.extraKeyReturn1.toUpperCase() && extraControl.buttonExtra1 != null && extraControl.buttonExtra1.pressed) return true;
				        
				if (name == ClientPrefs.data.extraKeyReturn2.toUpperCase() && extraControl.buttonExtra2 != null && extraControl.buttonExtra2.pressed) return true;
                        
				if (name == ClientPrefs.data.extraKeyReturn3.toUpperCase() && extraControl.buttonExtra3 != null && extraControl.buttonExtra3.pressed) return true;
                        
				if (name == ClientPrefs.data.extraKeyReturn4.toUpperCase() && extraControl.buttonExtra4 != null && extraControl.buttonExtra4.pressed) return true;                       					
		    }
		    return Reflect.getProperty(FlxG.keys.pressed, name);
	    });
		set('keyboardReleased', function(name:String){
		    name = name.toUpperCase();
		    if (MusicBeatState.instance.mobileControls != null){		    
				var extraControl = MusicBeatState.instance.mobileControls.current;
				if (name == ClientPrefs.data.extraKeyReturn1.toUpperCase() && extraControl.buttonExtra1 != null && extraControl.buttonExtra1.justReleased) return true;
				        
				if (name == ClientPrefs.data.extraKeyReturn2.toUpperCase() && extraControl.buttonExtra2 != null && extraControl.buttonExtra2.justReleased) return true;
                        
				if (name == ClientPrefs.data.extraKeyReturn3.toUpperCase() && extraControl.buttonExtra3 != null && extraControl.buttonExtra3.justReleased) return true;
                        
				if (name == ClientPrefs.data.extraKeyReturn4.toUpperCase() && extraControl.buttonExtra4 != null && extraControl.buttonExtra4.justReleased) return true;                       					
		    }
		    return Reflect.getProperty(FlxG.keys.justReleased, name);
        });
		set('anyGamepadJustPressed', function(name:String) return FlxG.gamepads.anyJustPressed(name));
		set('anyGamepadPressed', function(name:String) FlxG.gamepads.anyPressed(name));
		set('anyGamepadReleased', function(name:String) return FlxG.gamepads.anyJustReleased(name));

		set('gamepadAnalogX', function(id:Int, ?leftStick:Bool = true)
		{
			var controller = FlxG.gamepads.getByID(id);
			if (controller == null) return 0.0;

			return controller.getXAxis(leftStick ? LEFT_ANALOG_STICK : RIGHT_ANALOG_STICK);
		});
		set('gamepadAnalogY', function(id:Int, ?leftStick:Bool = true)
		{
			var controller = FlxG.gamepads.getByID(id);
			if (controller == null) return 0.0;

			return controller.getYAxis(leftStick ? LEFT_ANALOG_STICK : RIGHT_ANALOG_STICK);
		});
		set('gamepadJustPressed', function(id:Int, name:String)
		{
			var controller = FlxG.gamepads.getByID(id);
			if (controller == null) return false;

			return Reflect.getProperty(controller.justPressed, name) == true;
		});
		set('gamepadPressed', function(id:Int, name:String)
		{
			var controller = FlxG.gamepads.getByID(id);
			if (controller == null) return false;

			return Reflect.getProperty(controller.pressed, name) == true;
		});
		set('gamepadReleased', function(id:Int, name:String)
		{
			var controller = FlxG.gamepads.getByID(id);
			if (controller == null) return false;

			return Reflect.getProperty(controller.justReleased, name) == true;
		});

		set('keyJustPressed', function(name:String = '') {
			name = name.toLowerCase();
			switch(name) {
				case 'left': return Controls.instance.NOTE_LEFT_P;
				case 'down': return Controls.instance.NOTE_DOWN_P;
				case 'up': return Controls.instance.NOTE_UP_P;
				case 'right': return Controls.instance.NOTE_RIGHT_P;
				default:
				    if (MusicBeatState.instance.mobileControls != null){    
					    var extraControl = MusicBeatState.instance.mobileControls.current;
					    if (name == ClientPrefs.data.extraKeyReturn1.toLowerCase() && extraControl.buttonExtra1 != null && extraControl.buttonExtra1.justPressed) return true;
					        
					    if (name == ClientPrefs.data.extraKeyReturn2.toLowerCase() && extraControl.buttonExtra2 != null && extraControl.buttonExtra2.justPressed) return true;
                            
					    if (name == ClientPrefs.data.extraKeyReturn3.toLowerCase() && extraControl.buttonExtra3 != null && extraControl.buttonExtra3.justPressed) return true;
                            
					    if (name == ClientPrefs.data.extraKeyReturn4.toLowerCase() && extraControl.buttonExtra4 != null && extraControl.buttonExtra4.justPressed) return true;                       					
			        }
				return Controls.instance.justPressed(name);
			}
			return false;
		});
		set('keyPressed', function(name:String = '') {
			name = name.toLowerCase();
			switch(name) {
				case 'left': return Controls.instance.NOTE_LEFT;
				case 'down': return Controls.instance.NOTE_DOWN;
				case 'up': return Controls.instance.NOTE_UP;
				case 'right': return Controls.instance.NOTE_RIGHT;
				default:
				    if (MusicBeatState.instance.mobileControls != null){    
					    var extraControl = MusicBeatState.instance.mobileControls.current;
					    if (name == ClientPrefs.data.extraKeyReturn1.toLowerCase() && extraControl.buttonExtra1 != null && extraControl.buttonExtra1.pressed) return true;
					        
					    if (name == ClientPrefs.data.extraKeyReturn2.toLowerCase() && extraControl.buttonExtra2 != null && extraControl.buttonExtra2.pressed) return true;
                            
					    if (name == ClientPrefs.data.extraKeyReturn3.toLowerCase() && extraControl.buttonExtra3 != null && extraControl.buttonExtra3.pressed) return true;
                            
					    if (name == ClientPrefs.data.extraKeyReturn4.toLowerCase() && extraControl.buttonExtra4 != null && extraControl.buttonExtra4.pressed) return true;                       					
			        }
				return Controls.instance.pressed(name);
			}
			return false;
		});
		set('keyReleased', function(name:String = '') {
			name = name.toLowerCase();
			switch(name) {
				case 'left': return Controls.instance.NOTE_LEFT_R;
				case 'down': return Controls.instance.NOTE_DOWN_R;
				case 'up': return Controls.instance.NOTE_UP_R;
				case 'right': return Controls.instance.NOTE_RIGHT_R;
				default:
				    if (MusicBeatState.instance.mobileControls != null){    
					    var extraControl = MusicBeatState.instance.mobileControls.current;
					    if (name == ClientPrefs.data.extraKeyReturn1.toLowerCase() && extraControl.buttonExtra1 != null && extraControl.buttonExtra1.justReleased) return true;
					        
					    if (name == ClientPrefs.data.extraKeyReturn2.toLowerCase() && extraControl.buttonExtra2 != null && extraControl.buttonExtra2.justReleased) return true;
                            
					    if (name == ClientPrefs.data.extraKeyReturn3.toLowerCase() && extraControl.buttonExtra3 != null && extraControl.buttonExtra3.justReleased) return true;
                            
					    if (name == ClientPrefs.data.extraKeyReturn4.toLowerCase() && extraControl.buttonExtra4 != null && extraControl.buttonExtra4.justReleased) return true;                       					
			        }
				return Controls.instance.justReleased(name);
			}
			return false;
		});

		// For adding your own callbacks
		// not very tested but should work
		#if LUA_ALLOWED
		set('createGlobalCallback', function(name:String, func:Dynamic)
		{
			for (script in PlayState.instance.luaArray)
				if(script != null && script.lua != null && !script.closed)
					Lua_helper.add_callback(script.lua, name, func);

			FunkinLua.customFunctions.set(name, func);
		});

		// this one was tested
		set('createCallback', function(name:String, func:Dynamic, ?funk:FunkinLua = null)
		{
			if(funk == null) funk = parentLua;
			
			if(parentLua != null) funk.addLocalCallback(name, func);
			else FunkinLua.luaTrace('createCallback ($name): 3rd argument is null', false, false, FlxColor.RED);
		});
		#end

		set('addHaxeLibrary', function(libName:String, ?libPackage:String = '') {
			try {
				var str:String = '';
				if(libPackage.length > 0)
					str = libPackage + '.';

				set(libName, Type.resolveClass(str + libName));
			}
			catch (e:Dynamic) {
				var msg:String = e.message.substr(0, e.message.indexOf('\n'));
				#if LUA_ALLOWED
				if(parentLua != null)
				{
					FunkinLua.lastCalledScript = parentLua;
					FunkinLua.luaTrace('$origin: ${parentLua.lastCalledFunction} - $msg', false, false, FlxColor.RED);
					return;
				}
				#end
				if(PlayState.instance != null) PlayState.instance.addTextToDebug('$origin - $msg', FlxColor.RED);
				else trace('$origin - $msg');
			}
		});
		#if LUA_ALLOWED
		set('parentLua', parentLua);
		#else
		set('parentLua', null);
		#end
		set('this', this);
		set('game', FlxG.state);

		set('buildTarget', LuaUtils.getBuildTarget());
		set('customSubstate', CustomSubstate.instance);
		set('customSubstateName', CustomSubstate.name);

		set('Function_Stop', LuaUtils.Function_Stop);
		set('Function_Continue', LuaUtils.Function_Continue);
		set('Function_StopLua', LuaUtils.Function_StopLua); //doesnt do much cuz HScript has a lower priority than Lua
		set('Function_StopHScript', LuaUtils.Function_StopHScript);
		set('Function_StopAll', LuaUtils.Function_StopAll);

		set('add', FlxG.state.add);
                set('insert', FlxG.state.insert);
                set('remove', FlxG.state.remove);

                if(PlayState.instance == FlxG.state)
                {
                        set('addBehindGF', PlayState.instance.addBehindGF);
                        set('addBehindDad', PlayState.instance.addBehindDad);
                        set('addBehindBF', PlayState.instance.addBehindBF);
                        setSpecialObject(PlayState.instance, false, PlayState.instance.instancesExclude);
                }
                #if LUA_ALLOWED
		set("addVirtualPad", (DPadMode:String, ActionMode:String) -> {
			PlayState.instance.makeLuaVirtualPad(DPadMode, ActionMode);
			PlayState.instance.addLuaVirtualPad();
		  });
  
		set("removeVirtualPad", () -> {
			PlayState.instance.removeLuaVirtualPad();
		});
  
		set("addVirtualPadCamera", () -> {
			if(PlayState.instance.luaVirtualPad == null){
				FunkinLua.luaTrace('addVirtualPadCamera: VPAD does not exist.');
				return;
			}
			PlayState.instance.addLuaVirtualPadCamera();
		});
  
		set("virtualPadJustPressed", function(button:Dynamic):Bool {
			if(PlayState.instance.luaVirtualPad == null){
			  //FunkinLua.luaTrace('virtualPadJustPressed: VPAD does not exist.');
			  return false;
			}
		  return PlayState.instance.luaVirtualPadJustPressed(button);
		});
  
		set("virtualPadPressed", function(button:Dynamic):Bool {
			if(PlayState.instance.luaVirtualPad == null){
				//FunkinLua.luaTrace('virtualPadPressed: VPAD does not exist.');
				return false;
			}
			return PlayState.instance.luaVirtualPadPressed(button);
		});
  
		set("virtualPadJustReleased", function(button:Dynamic):Bool {
			if(PlayState.instance.luaVirtualPad == null){
				//FunkinLua.luaTrace('virtualPadJustReleased: VPAD does not exist.');
				return false;
			}
			return PlayState.instance.luaVirtualPadJustReleased(button);
		});
                #end

		if(varsToBring != null) {
			for (key in Reflect.fields(varsToBring)) {
				key = key.trim();
				var value = Reflect.field(varsToBring, key);
				//trace('Key $key: $value');
				set(key, Reflect.field(varsToBring, key));
			}
			varsToBring = null;
		}
	}

	public function executeCode(?funcToRun:String = null, ?funcArgs:Array<Dynamic> = null):TeaCall {
		if (funcToRun == null) return null;

		if(!exists(funcToRun)) {
			#if LUA_ALLOWED
			FunkinLua.luaTrace(origin + ' - No HScript function named: $funcToRun', false, false, FlxColor.RED);
			#else
			PlayState.instance.addTextToDebug(origin + ' - No HScript function named: $funcToRun', FlxColor.RED);
			#end
			return null;
		}

		final callValue = call(funcToRun, funcArgs);
		if (!callValue.succeeded)
		{
			final e = callValue.exceptions[0];
			if (e != null) {
				var msg:String = e.toString();
				#if LUA_ALLOWED
				if(parentLua != null)
				{
					FunkinLua.luaTrace('$origin: ${parentLua.lastCalledFunction} - $msg', false, false, FlxColor.RED);
					return null;
				}
				#end
				PlayState.instance.addTextToDebug('$origin - $msg', FlxColor.RED);
			}
			return null;
		}
		return callValue;
	}

	public function executeFunction(funcToRun:String = null, funcArgs:Array<Dynamic>):TeaCall {
		if (funcToRun == null) return null;
		return call(funcToRun, funcArgs);
	}

	#if LUA_ALLOWED
	public static function implement(funk:FunkinLua) {
	    if (!ClientPrefs.data.oldHscriptVersion){
    		funk.addLocalCallback("runHaxeCode", function(codeToRun:String, ?varsToBring:Any = null, ?funcToRun:String = null, ?funcArgs:Array<Dynamic> = null):Dynamic {
    			#if SScript
    			initHaxeModuleCode(funk, codeToRun, varsToBring);
    			final retVal:TeaCall = funk.hscript.executeCode(funcToRun, funcArgs);
    			if (retVal != null) {
    				if(retVal.succeeded)
    					return (retVal.returnValue == null || LuaUtils.isOfTypes(retVal.returnValue, [Bool, Int, Float, String, Array])) ? retVal.returnValue : null;
    
    				final e = retVal.exceptions[0];
    				final calledFunc:String = if(funk.hscript.origin == funk.lastCalledFunction) funcToRun else funk.lastCalledFunction;
    				if (e != null)
    					FunkinLua.luaTrace(funk.hscript.origin + ":" + calledFunc + " - " + e, false, false, FlxColor.RED);
    				return null;
    			}
    			else if (funk.hscript.returnValue != null)
    			{
    				return funk.hscript.returnValue;
    			}
    			#else
    			FunkinLua.luaTrace("runHaxeCode: HScript isn't supported on this platform!", false, false, FlxColor.RED);
    			#end
    			return null;
    		});
    		
    		funk.addLocalCallback("runHaxeFunction", function(funcToRun:String, ?funcArgs:Array<Dynamic> = null) {
    			#if SScript
    			var callValue = funk.hscript.executeFunction(funcToRun, funcArgs);
    			if (!callValue.succeeded)
    			{
    				var e = callValue.exceptions[0];
    				if (e != null)
    					FunkinLua.luaTrace('ERROR (${funk.hscript.origin}: ${callValue.calledFunction}) - ' + e.message.substr(0, e.message.indexOf('\n')), false, false, FlxColor.RED);
    				return null;
    			}
    			else
    				return callValue.returnValue;
    			#else
    			FunkinLua.luaTrace("runHaxeFunction: HScript isn't supported on this platform!", false, false, FlxColor.RED);
    			#end
    		});
    		// This function is unnecessary because import already exists in SScript as a native feature
    		funk.addLocalCallback("addHaxeLibrary", function(libName:String, ?libPackage:String = '') {
    			var str:String = '';
    			if(libPackage.length > 0)
    				str = libPackage + '.';
    			else if(libName == null)
    				libName = '';
    
    			var c:Dynamic = Type.resolveClass(str + libName);
    			if (c == null)
    				c = Type.resolveEnum(str + libName);
    
    			#if SScript
    			if (c != null)
    				SScript.globalVariables[libName] = c;
    			#end
    
    			#if SScript
    			if (funk.hscript != null)
    			{
    				try {
    					if (c != null)
    						funk.hscript.set(libName, c);
    				}
    				catch (e:Dynamic) {
    					FunkinLua.luaTrace(funk.hscript.origin + ":" + funk.lastCalledFunction + " - " + e, false, false, FlxColor.RED);
    				}
    			}
    			#else
    			FunkinLua.luaTrace("addHaxeLibrary: HScript isn't supported on this platform!", false, false, FlxColor.RED);
    			#end
    		});		
		}
	}
	#end

	override public function destroy()
	{
		origin = null;
		#if LUA_ALLOWED parentLua = null; #end

		super.destroy();
	}
}

class HScriptBase
{
	public static var parser:Parser = new Parser();
	public var interp:Interp;

	public var variables(get, never):Map<String, Dynamic>;
	public var parentLua:FunkinLua;

	public function get_variables()
	{
		return interp.variables;
	}
	
	public static function initHaxeModule(parent:FunkinLua)
	{
		#if HSCRIPT_ALLOWED
		if(parent.hscriptBase == null)
		{
			//trace('initializing haxe interp for: $scriptName');
			parent.hscriptBase = new HScriptBase(parent); //TO DO: Fix issue with 2 scripts not being able to use the same variable names
		}
		#end
	}

	public function new(parent:FunkinLua)
	{
		interp = new Interp();
		parentLua = parent;
		interp.variables.set('FlxG', flixel.FlxG);
		interp.variables.set('FlxSprite', flixel.FlxSprite);
		interp.variables.set('FlxCamera', flixel.FlxCamera);
		interp.variables.set('FlxTimer', flixel.util.FlxTimer);
		interp.variables.set('FlxTween', flixel.tweens.FlxTween);
		interp.variables.set('FlxEase', flixel.tweens.FlxEase);
		interp.variables.set('PlayState', PlayState);
		interp.variables.set('game', PlayState.instance);
		interp.variables.set('Paths', Paths);
		interp.variables.set('Conductor', Conductor);
		interp.variables.set('ClientPrefs', ClientPrefs);
		interp.variables.set('Character', Character);
		interp.variables.set('Alphabet', Alphabet);
		interp.variables.set('CustomSubstate', psychlua.CustomSubstate);
		#if (!flash && sys)
		interp.variables.set('FlxRuntimeShader', flixel.addons.display.FlxRuntimeShader);
		#end
		interp.variables.set('ShaderFilter', openfl.filters.ShaderFilter);
		interp.variables.set('StringTools', StringTools);

		interp.variables.set('setVar', function(name:String, value:Dynamic)
		{
			PlayState.instance.variables.set(name, value);
		});
		interp.variables.set('getVar', function(name:String)
		{
			var result:Dynamic = null;
			if(PlayState.instance.variables.exists(name)) result = PlayState.instance.variables.get(name);
			return result;
		});
		interp.variables.set('removeVar', function(name:String)
		{
			if(PlayState.instance.variables.exists(name))
			{
				PlayState.instance.variables.remove(name);
				return true;
			}
			return false;
		});
		interp.variables.set('debugPrint', function(text:String, ?color:FlxColor = null) {
			if(color == null) color = FlxColor.WHITE;
			FunkinLua.luaTrace(text, true, false, color);
		});

		// For adding your own callbacks

		// not very tested but should work
		interp.variables.set('createGlobalCallback', function(name:String, func:Dynamic)
		{
			#if LUA_ALLOWED
			for (script in PlayState.instance.luaArray)
				if(script != null && script.lua != null && !script.closed)
					Lua_helper.add_callback(script.lua, name, func);
			#end
			FunkinLua.customFunctions.set(name, func);
		});

		// tested
		interp.variables.set('createCallback', function(name:String, func:Dynamic, ?funk:FunkinLua = null)
		{
			if(funk == null) funk = parentLua;
			funk.addLocalCallback(name, func);
		});

		interp.variables.set('addHaxeLibrary', function(libName:String, ?libPackage:String = '') {
			try {
				var str:String = '';
				if(libPackage.length > 0)
					str = libPackage + '.';

				interp.variables.set(libName, Type.resolveClass(str + libName));
			}
			catch (e:Dynamic) {
				FunkinLua.lastCalledScript = parent;
				FunkinLua.luaTrace(parentLua.scriptName + ":" + parentLua.lastCalledFunction + " - " + e, false, false, FlxColor.RED);
			}
		});
		interp.variables.set('parentLua', parentLua);
	}

	public function execute(codeToRun:String, ?funcToRun:String = null, ?funcArgs:Array<Dynamic>):Dynamic
	{
		@:privateAccess
		HScriptBase.parser.line = 1;
		HScriptBase.parser.allowTypes = true;
		var expr:Expr = HScriptBase.parser.parseString(codeToRun);
		try {
			var value:Dynamic = interp.execute(HScriptBase.parser.parseString(codeToRun));
			return (funcToRun != null) ? executeFunction(funcToRun, funcArgs) : value;
		}
		catch(e:Exception)
		{
			trace(e);
			return null;
		}
	}

	public function executeFunction(funcToRun:String = null, funcArgs:Array<Dynamic>)
	{
		if(funcToRun != null)
		{
			//trace('Executing $funcToRun');
			if(interp.variables.exists(funcToRun))
			{
				//trace('$funcToRun exists, executing...');
				if(funcArgs == null) funcArgs = [];
				return Reflect.callMethod(null, interp.variables.get(funcToRun), funcArgs);
			}
		}
		return null;
	}

	#if LUA_ALLOWED
	public static function implement(funk:FunkinLua)
	{
		var lua:State = funk.lua;
		if (ClientPrefs.data.oldHscriptVersion){
    		Lua_helper.add_callback(lua, "runHaxeCode", function(codeToRun:String, ?varsToBring:Any = null, ?funcToRun:String = null, ?funcArgs:Array<Dynamic> = null) {
    			var retVal:Dynamic = null;
    
    			#if HSCRIPT_ALLOWED
    			HScriptBase.initHaxeModule(funk);
    			try {
    				if(varsToBring != null)
    				{
    					for (key in Reflect.fields(varsToBring))
    					{
    						//trace('Key $key: ' + Reflect.field(varsToBring, key));
    						funk.hscriptBase.interp.variables.set(key, Reflect.field(varsToBring, key));
    					}
    				}
    				retVal = funk.hscriptBase.execute(codeToRun, funcToRun, funcArgs);
    			}
    			catch (e:Dynamic) {
    				FunkinLua.luaTrace(funk.scriptName + ":" + funk.lastCalledFunction + " - " + e, false, false, FlxColor.RED);
    			}
    			#else
    			FunkinLua.luaTrace("runHaxeCode: HScript isn't supported on this platform!", false, false, FlxColor.RED);
    			#end
    
    			if(retVal != null && !LuaUtils.isOfTypes(retVal, [Bool, Int, Float, String, Array])) retVal = null;
    			return retVal;
    		});
    		
    		Lua_helper.add_callback(lua, "runHaxeFunction", function(funcToRun:String, ?funcArgs:Array<Dynamic> = null) {
    			try {
    				return funk.hscriptBase.executeFunction(funcToRun, funcArgs);
    			}
    			catch(e:Exception)
    			{
    				FunkinLua.luaTrace(Std.string(e));
    				return null;
    			}
    		});
    
    		Lua_helper.add_callback(lua, "addHaxeLibrary", function(libName:String, ?libPackage:String = '') {
    			#if HSCRIPT_ALLOWED
    			HScriptBase.initHaxeModule(funk);
    			try {
    				var str:String = '';
    				if(libPackage.length > 0)
    					str = libPackage + '.';
    
    				funk.hscriptBase.variables.set(libName, Type.resolveClass(str + libName));
    			}
    			catch (e:Dynamic) {
    				FunkinLua.luaTrace(funk.scriptName + ":" + funk.lastCalledFunction + " - " + e, false, false, FlxColor.RED);
    			}
    			#end
    		});
    	}
	}
	#end
}

class CustomFlxColor {
	public static var TRANSPARENT(default, null):Int = FlxColor.TRANSPARENT;
	public static var BLACK(default, null):Int = FlxColor.BLACK;
	public static var WHITE(default, null):Int = FlxColor.WHITE;
	public static var GRAY(default, null):Int = FlxColor.GRAY;

	public static var GREEN(default, null):Int = FlxColor.GREEN;
	public static var LIME(default, null):Int = FlxColor.LIME;
	public static var YELLOW(default, null):Int = FlxColor.YELLOW;
	public static var ORANGE(default, null):Int = FlxColor.ORANGE;
	public static var RED(default, null):Int = FlxColor.RED;
	public static var PURPLE(default, null):Int = FlxColor.PURPLE;
	public static var BLUE(default, null):Int = FlxColor.BLUE;
	public static var BROWN(default, null):Int = FlxColor.BROWN;
	public static var PINK(default, null):Int = FlxColor.PINK;
	public static var MAGENTA(default, null):Int = FlxColor.MAGENTA;
	public static var CYAN(default, null):Int = FlxColor.CYAN;

	public static function fromInt(Value:Int):Int 
	{
		return cast FlxColor.fromInt(Value);
	}

	public static function fromRGB(Red:Int, Green:Int, Blue:Int, Alpha:Int = 255):Int
	{
		return cast FlxColor.fromRGB(Red, Green, Blue, Alpha);
	}
	public static function fromRGBFloat(Red:Float, Green:Float, Blue:Float, Alpha:Float = 1):Int
	{	
		return cast FlxColor.fromRGBFloat(Red, Green, Blue, Alpha);
	}

	public static inline function fromCMYK(Cyan:Float, Magenta:Float, Yellow:Float, Black:Float, Alpha:Float = 1):Int
	{
		return cast FlxColor.fromCMYK(Cyan, Magenta, Yellow, Black, Alpha);
	}

	public static function fromHSB(Hue:Float, Sat:Float, Brt:Float, Alpha:Float = 1):Int
	{	
		return cast FlxColor.fromHSB(Hue, Sat, Brt, Alpha);
	}
	public static function fromHSL(Hue:Float, Sat:Float, Light:Float, Alpha:Float = 1):Int
	{	
		return cast FlxColor.fromHSL(Hue, Sat, Light, Alpha);
	}
	public static function fromString(str:String):Int
	{
		return cast FlxColor.fromString(str);
	}
}
#end
