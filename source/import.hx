#if !macro
//Discord API
#if DISCORD_ALLOWED
import backend.Discord;
#end

//Psych
#if ACHIEVEMENTS_ALLOWED
import backend.Achievements;
#end
#if hxvlc
import backend.VideoSprite;
#end

#if android
import android.content.Context;
import android.widget.Toast;
import android.os.Environment;
import android.Permissions;
import lime.app.Application;
import backend.AppData;
#end

//Mobile Controls
import mobile.objects.MobileControls;
import mobile.flixel.FlxHitbox;
import mobile.flixel.FlxVirtualPad;
import mobile.flixel.input.FlxMobileInputID;
import mobile.backend.Data;
import mobile.backend.SUtil;

#if sys
import sys.*;
import sys.io.*;
#elseif js
import js.html.*;
#end

import backend.Paths;
import backend.Controls;
import backend.CoolUtil;
import backend.MusicBeatState;
import backend.MusicBeatSubstate;
import backend.CustomFadeTransition;
import backend.ClientPrefs;
import backend.Conductor;
import backend.BaseStage;
import backend.Difficulty;
import backend.Mods;

import backend.ui.*; //Psych-UI

import objects.Alphabet;
import objects.BGSprite;
import objects.AudioDisplay;
import objects.shape.ShapeEX;

import states.PlayState;
import states.LoadingState;

#if flxanimate
import flxanimate.*;
#end

//Flixel
import flixel.sound.FlxSound;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.util.FlxDestroyUtil;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.group.FlxSpriteGroup;
import flixel.group.FlxGroup.FlxTypedGroup;

using StringTools;
#end
