package states.substates;

import data.Progression;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import gameObjects.Alphabet;
import openfl.Lib;
import openfl.sensors.Accelerometer;
import states.substates.MusicBeatSubstate;
#if mobileC
import flixel.FlxCamera;
import ui.FlxVirtualPad;
#end

using StringTools;

class ResetScoreSubState extends MusicBeatSubstate
{
	var bg:FlxSprite;
	var alphabetArray:Array<Alphabet> = [];
	var onYes:Bool = false;
	var yesText:Alphabet;
	var noText:Alphabet;
	var text:Alphabet;
	var text2:Alphabet; // IM SO LAZY
	var selectedsomething:Bool = false;
	var virtualpad:FlxVirtualPad;

	public var finishedCallback:Void->Void;

	public var accepted:Void->Void;

	public function new(?finished:Void->Void, ?yes:Void->Void)
	{
		super();

		if (finished != null)
			finishedCallback = finished;

		if (yes != null)
			accepted = yes;

		bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0;
		bg.scrollFactor.set();
		add(bg);

		text = new Alphabet(0, 180, "Reset Story Progress?", true);
		text.screenCenter(X);
		alphabetArray.push(text);
		text.alpha = 0;
		add(text);

		text2 = new Alphabet(0, text.y + 120, "This will close your game", true);
		text2.screenCenter(X);
		alphabetArray.push(text2);
		text2.alpha = 0;
		add(text2);

		yesText = new Alphabet(0, text2.y + 150, 'Yes', true);
		yesText.screenCenter(X);
		yesText.x -= 200;
		add(yesText);
		noText = new Alphabet(0, text2.y + 150, 'No', true);
		noText.screenCenter(X);
		noText.x += 200;
		add(noText);
		updateOptions();
		
		virtualpad = new FlxVirtualPad(LEFT_RIGHT, A_B);
		virtualpad.alpha = 0.75;
		var pcam = new FlxCamera();
		FlxG.cameras.add(pcam);
		pcam.bgColor.alpha = 0;
		virtualpad.cameras = [pcam];
		add(virtualpad);
	}

	override function update(elapsed:Float)
	{
		bg.alpha += elapsed * 1.5;
		if (bg.alpha > 0.6)
			bg.alpha = 0.6;

		for (i in 0...alphabetArray.length)
		{
			var spr = alphabetArray[i];
			spr.alpha += elapsed * 2.5;
		}

		if (!selectedsomething)
		{
			if (virtualpad.buttonLeft.justPressed || virtualpad.buttonRight.justPressed)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'), 1);
				onYes = !onYes;
				updateOptions();
			}
			if (virtualpad.buttonB.justPressed)
			{
				selectedsomething = true;
				FlxG.sound.play(Paths.sound('cancelMenu'), 1);
				fadeOut();
			}
			else if (virtualpad.buttonA.justPressed)
			{
				selectedsomething = true;
				if (onYes)
				{
					// Wow thats alot of data

					FlxG.save.data.weekCompleted = null;

					// WIPE OUT ALL HIGH SCORES

					FlxG.save.data.weekScores = null;
					FlxG.save.data.songScores = null;
					FlxG.save.data.songRating = null;

					Progression.reset();

					FlxG.save.flush();

					fadeOut(accepted);
				}
				else
				{
					FlxG.sound.play(Paths.sound('cancelMenu'), 1);
					fadeOut();
				}
			}
		}

		super.update(elapsed);
	}

	function fadeOut(?callback:Void->Void)
	{
		if (callback == null)
		{
			callback = function()
			{
				if (finishedCallback != null)
				{
					finishedCallback();
				}
			};
		}

		var objs:Array<Dynamic> = [text, text2, yesText, noText, bg];
		for (obj in objs)
		{
			FlxTween.tween(obj, {alpha: 0}, 0.5, {
				onComplete: function(twn:FlxTween)
				{
				}
			});
		}

		(new FlxTimer()).start(0.5, function(tmr:FlxTimer)
		{
			close();
			callback();
		});
	}

	function updateOptions()
	{
		var scales:Array<Float> = [0.75, 1];
		var alphas:Array<Float> = [0.6, 1.25];
		var confirmInt:Int = onYes ? 1 : 0;

		yesText.alpha = alphas[confirmInt];
		yesText.scale.set(scales[confirmInt], scales[confirmInt]);
		noText.alpha = alphas[1 - confirmInt];
		noText.scale.set(scales[1 - confirmInt], scales[1 - confirmInt]);
	}
}
