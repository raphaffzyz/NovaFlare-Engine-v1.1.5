package states;

import backend.WeekData;
import backend.Achievements;

import flixel.FlxObject;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;

import flixel.addons.display.FlxBackdrop;

import flixel.input.keyboard.FlxKey;

import objects.AchievementPopup;
import states.editors.MasterEditorMenu;

import options.OptionsState;
import openfl.Lib;


class MainMenuState extends MusicBeatState
{
	public static var psychEngineVersion:String = '0.7.3'; //This is also used for Discord RPC
	public static var novaFlareEngineDataVersion:Float = 1.7;
	public static var novaFlareEngineVersion:String = '1.1.5';
	public static var curSelected:Int = 0;
    public static var saveCurSelected:Int = 0;
    
	var menuItems:FlxTypedGroup<FlxSprite>;
	public var camGame:FlxCamera;
	public var camHUD:FlxCamera;
	public var camOther:FlxCamera;
	var optionTween:Array<FlxTween> = [];
	var selectedTween:Array<FlxTween> = [];
	var cameraTween:Array<FlxTween> = [];
	var logoTween:FlxTween;
	
	var optionShit:Array<String> = [
		'story_mode',
		'freeplay',
		#if MODS_ALLOWED 'mods', #end
		#if ACHIEVEMENTS_ALLOWED 'awards', #end
		'credits',
		//#if !switch 'donate', #end
		'options'
	];

	var magenta:FlxSprite;
	var logoBl:FlxSprite;
	
    //var musicDisplay:SpectogramSprite;
	
	//var camFollow:FlxObject;

	var SoundTime:Float = 0;
	var BeatTime:Float = 0;
	
	var ColorArray:Array<Int> = [
		0xFF9400D3,
		0xFF4B0082,
		0xFF0000FF,
		0xFF00FF00,
		0xFFFFFF00,
		0xFFFF7F00,
		0xFFFF0000
	                                
	    ];
	public static var currentColor:Int = 1;    
	public static var currentColorAgain:Int = 0;
			
	public static var Mainbpm:Float = 0;
	public static var bpm:Float = 0;
	

	override function create()
	{
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

		//Lib.application.window.title = "NF Engine - MainMenuState";
		
        Mainbpm = TitleState.bpm;
        bpm = TitleState.bpm;
        
		#if MODS_ALLOWED
		Mods.pushGlobalMods();
		#end
		Mods.loadTopMod();

		#if DISCORD_ALLOWED
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end		

		camGame = initPsychCamera();
		camHUD = new FlxCamera();
		camOther = new FlxCamera();
		camOther.bgColor.alpha = 0;
		camHUD.bgColor.alpha = 0;
				
		FlxG.cameras.add(camHUD, false);
		FlxG.cameras.add(camOther, false);		

		persistentUpdate = persistentDraw = true;

		var yScroll:Float = Math.max(0.25 - (0.05 * (optionShit.length - 4)), 0.1);
		var bg:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('menuBG'));
		bg.scrollFactor.set(0, 0);
		bg.setGraphicSize(Std.int(bg.width));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = ClientPrefs.data.antialiasing;
		add(bg);
		
	    var test:AudioDisplay = new AudioDisplay(FlxG.sound.music, 0, FlxG.height, FlxG.width, Std.int(FlxG.height / 2), 100, 4, FlxColor.WHITE);
		add(test);
		test.alpha = 0.7;

		bg.scrollFactor.set(0, 0);

		magenta = new FlxSprite(-80).loadGraphic(Paths.image('menuDesat'));
		magenta.scrollFactor.set(0, yScroll);
		magenta.setGraphicSize(Std.int(magenta.width * 1.175));
		magenta.updateHitbox();
		magenta.screenCenter();
		magenta.visible = false;
		magenta.antialiasing = ClientPrefs.data.antialiasing;
		magenta.color = 0xFFfd719b;
		add(magenta);
		
		
		logoBl = new FlxSprite(0, 0);
		logoBl.frames = Paths.getSparrowAtlas('logoBumpin');
		logoBl.antialiasing = ClientPrefs.data.antialiasing;
		logoBl.animation.addByPrefix('bump', 'logo bumpin', 24, false);
		logoBl.animation.play('bump');
		logoBl.offset.x = 0;
		logoBl.offset.y = 0;
		logoBl.scale.x = (640 / logoBl.frameWidth);
		logoBl.scale.y = logoBl.scale.x;
		logoBl.updateHitbox();
		add(logoBl);
		logoBl.scrollFactor.set(0, 0);
		logoBl.x = 1280 + 320 - logoBl.width / 2;
		logoBl.y = 360 - logoBl.height / 2;
		logoTween = FlxTween.tween(logoBl, {x: 1280 - 320 - logoBl.width / 2 }, 0.6, {ease: FlxEase.backInOut});
		// magenta.scrollFactor.set();

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		var scale:Float = 0.6;
		if(optionShit.length > 6) {
			scale = 6 / optionShit.length;
		}

		for (i in 0...optionShit.length)
		{
			
			var menuItem:FlxSprite = new FlxSprite(-600, 0);
			menuItem.scale.x = scale;
			menuItem.scale.y = scale;
			menuItem.frames = Paths.getSparrowAtlas('mainmenu/menu_' + optionShit[i]);
			menuItem.animation.addByPrefix('idle', optionShit[i] + " basic", 24);
			menuItem.animation.addByPrefix('selected', optionShit[i] + " white", 24);
			menuItem.animation.play('idle');
			menuItem.ID = i;
			
			menuItems.add(menuItem);
			var scr:Float = (optionShit.length - 4) * 0.135;
			if(optionShit.length < 6) scr = 0;			
			menuItem.antialiasing = ClientPrefs.data.antialiasing;
			//menuItem.setGraphicSize(Std.int(menuItem.width * 0.58));
			menuItem.updateHitbox();
			
			if (menuItem.ID == curSelected){
			menuItem.animation.play('selected');
			menuItem.updateHitbox();
			}
		}
		
		for (i in 0...optionShit.length)
		{
			var option:FlxSprite = menuItems.members[i];
			
			if (optionShit.length % 2 == 0){
			    option.y = 360 + (i - optionShit.length / 2) * 110;
			    //option.y += 20;
			}else{
			    option.y = 360 + (i - (optionShit.length / 2 + 0.5)) * 135;
			}
				optionTween[i] = FlxTween.tween(option, {x: 100}, 0.7 + 0.08 * i , {
					ease: FlxEase.backInOut
			    });
		}

		//FlxG.camera.follow(camFollow, null, 0);

		var versionShit:FlxText = new FlxText(12, FlxG.height - 44, 0, "NovaFlare Engine v" + novaFlareEngineVersion + " - HOTFIX", 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		versionShit.antialiasing = ClientPrefs.data.antialiasing;
		add(versionShit);
		versionShit.cameras = [camHUD];
		var versionShit:FlxText = new FlxText(12, FlxG.height - 24, 0, "Friday Night Funkin' v" + '0.2.8', 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);
		versionShit.antialiasing = ClientPrefs.data.antialiasing;
        versionShit.cameras = [camHUD];
		// NG.core.calls.event.logEvent('swag').send();

		checkChoose();
        
		#if ACHIEVEMENTS_ALLOWED
		// Unlocks "Freaky on a Friday Night" achievement if it's a Friday and between 18:00 PM and 23:59 PM
		var leDate = Date.now();
		if (leDate.getDay() == 5 && leDate.getHours() >= 18)
			Achievements.unlock('friday_night_play');
        
		#if MODS_ALLOWED
		Achievements.reloadList();
		#end
		#end
		
		#if !mobile
		FlxG.mouse.visible = true;
	    #else
	    FlxG.mouse.visible = false;
	    #end
        
		addVirtualPad(MainMenuStateC, A_B_E);
		virtualPad.cameras = [camHUD];
        
		super.create();
	}
	
	var canClick:Bool = true;
	var canBeat:Bool = true;
	var usingMouse:Bool = true;
	
	var endCheck:Bool = false;

	override function update(elapsed:Float)
	{
	
	    #if (debug && android)
	        if (FlxG.android.justReleased.BACK)
		    FlxG.debugger.visible = !FlxG.debugger.visible;
		#end
	
	
		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
			if (!ClientPrefs.data.freeplayOld) {
			    if(FreeplayState.vocals != null) FreeplayState.vocals.volume += 0.5 * elapsed;
		    } else {
		        if(FreeplayStatePsych.vocals != null) FreeplayStatePsych.vocals.volume += 0.5 * elapsed;
		    }
		}

		FlxG.camera.followLerp = FlxMath.bound(elapsed * 9 / (FlxG.updateFramerate / 60), 0, 1);

		if (FlxG.mouse.justPressed) usingMouse = true;
		
        if(!endCheck){
		
		
		if (controls.UI_UP_P)
			{
			    usingMouse = false;
				FlxG.sound.play(Paths.sound('scrollMenu'));				
				curSelected--;
				checkChoose();
			}

			if (controls.UI_DOWN_P)
			{
			    usingMouse = false;
				FlxG.sound.play(Paths.sound('scrollMenu'));
				curSelected++;
				checkChoose();
			}
			
			    
			if (controls.ACCEPT) {
			    usingMouse = false;				    			    
			    
			    menuItems.forEach(function(spr:FlxSprite)
		        {
		            if (curSelected == spr.ID){
        				if (spr.animation.curAnim.name == 'selected') {
        				    canClick = false;
        				    checkChoose();
        				    selectSomething();
            			} else {
            			    FlxG.sound.play(Paths.sound('scrollMenu'));	
            			    spr.animation.play('selected');
            			}
        			}
    			});
		    }
		    
		menuItems.forEach(function(spr:FlxSprite)
		{
			if (usingMouse && canClick)
			{
				if (!FlxG.mouse.overlaps(spr)) {
				    if (FlxG.mouse.pressed
				    #if mobile && !FlxG.mouse.overlaps(virtualPad.buttonA) #end){
        			    spr.animation.play('idle');
    			    }
				    if (FlxG.mouse.justReleased 
				    #if mobile && !FlxG.mouse.overlaps(virtualPad.buttonA) #end){
					    spr.animation.play('idle');			        			        
			        } //work better for use virtual pad
			    }
    			if (FlxG.mouse.overlaps(spr)){
    			    if (FlxG.mouse.justPressed){
    			        if (spr.animation.curAnim.name == 'selected') selectSomething();
    			        else spr.animation.play('idle');
    			    }
					curSelected = spr.ID;
				
					if (spr.animation.curAnim.name == 'idle'){
						FlxG.sound.play(Paths.sound('scrollMenu'));	 
						spr.animation.play('selected');		
					}	
					
					menuItems.forEach(function(spr:FlxSprite){
						if (spr.ID != curSelected)
						{
							spr.animation.play('idle');
							spr.centerOffsets();
						}
					});
    			    			    
			    }			    
			    if(saveCurSelected != curSelected) checkChoose();
			}
		});
		
			if (controls.BACK)
			{
				endCheck = true;
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new TitleState());
			}		
				
			else if (controls.justPressed('debug_1') || virtualPad.buttonE.justPressed)
			{
				endCheck = true;
				MusicBeatState.switchState(new MasterEditorMenu());
			}		
        }
      
        SoundTime = FlxG.sound.music.time / 1000;
        BeatTime = 60 / bpm;
        
        if ( Math.floor(SoundTime/BeatTime) % 4  == 0 && canClick && canBeat) {
        
            canBeat = false;
           
            currentColor++;            
            if (currentColor > 6) currentColor = 1;
            currentColorAgain = currentColor - 1;
            if (currentColorAgain <= 0) currentColorAgain = 6;
            
            logoBl.animation.play('bump');
               
			camGame.zoom = 1 + 0.015;			
			cameraTween[0] = FlxTween.tween(camGame, {zoom: 1}, 0.6, {ease: FlxEase.cubeOut});
		    
			menuItems.forEach(function(spr:FlxSprite)	{
				spr.scale.x = 0.63;
				spr.scale.y = 0.63;
				    FlxTween.tween(spr.scale, {x: 0.6}, 0.6, {ease: FlxEase.cubeOut});
				    FlxTween.tween(spr.scale, {y: 0.6}, 0.6, {ease: FlxEase.cubeOut});
			
				
            });
            
        }
        if ( Math.floor(SoundTime/BeatTime + 0.5) % 4  == 2) canBeat = true;        

		menuItems.forEach(function(spr:FlxSprite)
		{
		    spr.updateHitbox();
		    spr.centerOffsets();
		    spr.centerOrigin();
		});
		
		
		
		super.update(elapsed);
	}    	
    
    function selectSomething()
	{
		endCheck = true;
		FlxG.sound.play(Paths.sound('confirmMenu'));
		canClick = false;				
		
		for (i in 0...optionShit.length)
		{
			var option:FlxSprite = menuItems.members[i];
			if(optionTween[i] != null) optionTween[i].cancel();
			if( i != curSelected)
				optionTween[i] = FlxTween.tween(option, {x: -800}, 0.6 + 0.1 * Math.abs(curSelected - i ), {
					ease: FlxEase.backInOut,
					onComplete: function(twn:FlxTween)
					{
						option.kill();
					}
			    });
		}
		
		if (cameraTween[0] != null) cameraTween[0].cancel();

		menuItems.forEach(function(spr:FlxSprite)
		{
			if (curSelected == spr.ID)
			{				
				
				//spr.animation.play('selected');
			    var scr:Float = (optionShit.length - 4) * 0.135;
			    if(optionShit.length < 6) scr = 0;
			    FlxTween.tween(spr, {y: 360 - spr.height / 2}, 0.6, {
					ease: FlxEase.backInOut
			    });
			
			    FlxTween.tween(spr, {x: 640 - spr.width / 2}, 0.6, {
					ease: FlxEase.backInOut				
				});													
			}
		});
		
		if (logoTween != null) logoTween.cancel();
		logoTween = FlxTween.tween(logoBl, {x: 1280 + 320 - logoBl.width / 2 }, 0.6, {ease: FlxEase.backInOut});
		
		FlxTween.tween(camGame, {zoom: 2}, 1.2, {ease: FlxEase.cubeInOut});
		FlxTween.tween(camHUD, {zoom: 2}, 1.2, {ease: FlxEase.cubeInOut});
		FlxTween.tween(camGame, {angle: 0}, 0.8, { //not use for now
		        ease: FlxEase.cubeInOut,
		        onComplete: function(twn:FlxTween)
				{
			    var daChoice:String = optionShit[curSelected];

				    switch (daChoice)
					{
						case 'story_mode':
								MusicBeatState.switchState(new StoryMenuState());
							case 'freeplay':
							    if (!ClientPrefs.data.freeplayOld) MusicBeatState.switchState(new FreeplayState());
								else MusicBeatState.switchState(new FreeplayStatePsych());
							#if MODS_ALLOWED
							case 'mods':
								MusicBeatState.switchState(new ModsMenuState());
							#end
							case 'awards':
								MusicBeatState.switchState(new AchievementsMenuState());
							case 'credits':
								MusicBeatState.switchState(new CreditsState());
							case 'options':
								MusicBeatState.switchState(new OptionsState());
								//OptionsState.onPlayState = false;
								if (PlayState.SONG != null)
								{
									PlayState.SONG.arrowSkin = null;
									PlayState.SONG.splashSkin = null;
								}
				    }
				}
		});
	}
	
	function checkChoose()
	{
	    if (curSelected >= menuItems.length)
	        curSelected = 0;
		if (curSelected < 0)
		    curSelected = menuItems.length - 1;
		    
		saveCurSelected = curSelected;
		    
	    menuItems.forEach(function(spr:FlxSprite){
	        if (spr.ID != curSelected)
			{
			    spr.animation.play('idle');
			    spr.centerOffsets();
		    }			

            if (spr.ID == curSelected && spr.animation.curAnim.name != 'selected')
			{
			    spr.animation.play('selected');
			    spr.centerOffsets();
		    }
		    
		    spr.updateHitbox();
        });        
	}
	
	
}
