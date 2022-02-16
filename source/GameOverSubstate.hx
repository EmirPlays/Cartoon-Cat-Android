package;

import flixel.system.FlxSound;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSubState;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

class GameOverSubstate extends MusicBeatSubstate
{
	var char:GameOverCharacter;
	var camFollow:FlxObject;

	private var reason:String;

	var spoopyCC:FlxSprite;
	var ccGroup:FlxTypedGroup<FlxSprite>;

	var deathMusic:FlxSound;

	public function new(x:Float, y:Float, reason:String)
	{
		super();

		this.reason = reason;

		FlxG.camera.zoom = 0.7;

		Conductor.songPosition = 0;
		
		if (reason == 'cc')
		{
			ccGroup = new FlxTypedGroup<FlxSprite>();
			add(ccGroup);

			for (i in 0...6)
			{
				spoopyCC = new FlxSprite(x + 365);
				spoopyCC.x += (i >= 3 ? -(i * 250) : (i * 250));
				spoopyCC.frames = Paths.getSparrowAtlas('spookyCC', 'shared', true);
				spoopyCC.animation.addByPrefix('idle', 'dancing furry', 24, true, (i >= 3 ? true : false));
				spoopyCC.animation.play('idle');
				spoopyCC.visible = false;
				ccGroup.add(spoopyCC);
			}
		}

		char = new GameOverCharacter(x, y, reason);
		add(char);

		camFollow = new FlxObject(char.getGraphicMidpoint().x, char.getGraphicMidpoint().y, 1, 1);
		add(camFollow);

		deathMusic = FlxG.sound.load(Paths.music('gameOver' + (reason == 'meat' ? 'Meat' : ''), 'shared'));
		deathMusic.play();

		deathMusic.onComplete = function () { endBullshit(); };

		Conductor.changeBPM(100);

		FlxG.camera.scroll.set();
		FlxG.camera.target = null;

		FlxG.camera.flash(FlxColor.RED, 1.2);

		char.playAnim('firstDeath', true);

                addVirtualPad(NONE, A_B);
                addPadCamera();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (controls.ACCEPT)
			endBullshit();

		if (controls.BACK && reason != 'meat')
		{
			deathMusic.stop();
			FlxG.switchState(PlayState.isStoryMode ? new StoryMenuState() : new FreeplayState());
		}

		if (char.animation.curAnim.name == 'firstDeath' && char.animation.curAnim.curFrame == 12)
			FlxG.camera.follow(camFollow, LOCKON, 0.01);

		if (FlxG.sound.music != null)
            Conductor.songPosition = FlxG.sound.music.time;
	}

	var isEnding:Bool = false;

	function endBullshit():Void
	{
		if (!isEnding)
		{
			isEnding = true;
			
			switch (reason)
			{
				case 'meat':
					Sys.exit(0);
				default:
					if (reason == 'cc')
					{
						for (cc in ccGroup)
						{
							cc.visible = true;
						}
					}

					if (char.animOffsets.exists('deathConfirm'))
						char.playAnim('deathConfirm', true);

					deathMusic.stop();
					FlxG.sound.play(Paths.music('gameOverEnd'));
		
					new FlxTimer().start(5.5, function(tmr:FlxTimer)
					{
						FlxG.camera.fade(FlxColor.BLACK, 2, false, function()
						{
							FlxG.resetState();
						});
					});
			}
		}
	}
}
