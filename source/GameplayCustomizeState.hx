import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import flixel.math.FlxMath;
import flixel.FlxCamera;
import flixel.math.FlxPoint;
import flixel.FlxObject;
#if windows
import Discord.DiscordClient;
import sys.thread.Thread;
#end

import flixel.group.FlxGroup.FlxTypedGroup;
import openfl.ui.Keyboard;
import flixel.FlxSprite;
import flixel.FlxG;

class GameplayCustomizeState extends MusicBeatState
{
    var defaultX:Float = FlxG.width * 0.55 - 135;
    var defaultY:Float = FlxG.height / 2 - 50;

    var sick:FlxSprite;

    var text:FlxText;

    var strumLine:FlxSprite;

    var strumLineNotes:FlxTypedGroup<FlxSprite>;
    var playerStrums:FlxTypedGroup<FlxSprite>;
    var cpuStrums:FlxTypedGroup<FlxSprite>;
    
    public override function create() 
    {
        #if windows
		// Updating Discord Rich Presence
		DiscordClient.changePresence("Customizing Gameplay", null);
		#end

        bgColor = FlxColor.WHITE;

        sick = new FlxSprite().loadGraphic(Paths.image('sick', 'shared'));
        sick.setGraphicSize(Std.int(sick.width * 0.7));
        sick.antialiasing = true;
        sick.scrollFactor.set();
        add(sick);

		Conductor.changeBPM(102);
		persistentUpdate = true;

        super.create();

		strumLine = new FlxSprite(0, 50).makeGraphic(FlxG.width, 10);
		strumLine.scrollFactor.set();

        if (FlxG.save.data.downscroll)
			strumLine.y = FlxG.height - 165;

		strumLineNotes = new FlxTypedGroup<FlxSprite>();
		add(strumLineNotes);

		playerStrums = new FlxTypedGroup<FlxSprite>();
        cpuStrums = new FlxTypedGroup<FlxSprite>();
        
		generateStaticArrows(0);
		generateStaticArrows(1);

        text = new FlxText(20, FlxG.height - 120, 0, "", 28);
        text.text = "R - Reset\n"
        + "ESC - Back\n"
        + "Arrow Keys - Move\n"
        + "Enter - Confirm\n";
		text.scrollFactor.set();
        text.antialiasing = true;
		text.setFormat("VCR OSD Mono", 28, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(text);

        if (!FlxG.save.data.changedHit)
        {
            FlxG.save.data.changedHitX = defaultX;
            FlxG.save.data.changedHitY = defaultY;
        }

        sick.x = FlxG.save.data.changedHitX;
        sick.y = FlxG.save.data.changedHitY;

        FlxG.mouse.visible = true;

        addVirtualPad(FULL, A_B_X_Y);
    }

    override function update(elapsed:Float) {
	if (FlxG.sound.music != null)
		Conductor.songPosition = FlxG.sound.music.time;

        super.update(elapsed);

        for (i in playerStrums)
            i.y = strumLine.y;
        for (i in cpuStrums)
            i.y = strumLine.y;

        var multiplier:Float = 1;

        if (FlxG.keys.pressed.SHIFT #if android || _virtualpad.buttonX.pressed #end)
            multiplier = 5;
        if (controls.UP)
            sick.y -= 1 * multiplier;
        if (controls.DOWN)
            sick.y += 1 * multiplier;
        if (controls.LEFT)
            sick.x -= 1 * multiplier;
        if (controls.RIGHT)
            sick.x += 1 * multiplier;

        if (controls.ACCEPT && (FlxG.save.data.changedHitX != sick.x || FlxG.save.data.changeHitY != sick.y))
        {
            FlxG.sound.play(Paths.sound('confirmMenu'));
            FlxG.save.data.changedHitX = sick.x;
            FlxG.save.data.changedHitY = sick.y;
            FlxG.save.data.changedHit = true;            
        }

        if (controls.RESET #if android || _virtualpad.buttonY.pressed #end)
        {
            sick.x = defaultX;
            sick.y = defaultY;
            FlxG.save.data.changedHitX = sick.x;
            FlxG.save.data.changedHitY = sick.y;
            FlxG.save.data.changedHit = false;
        }

        if (controls.BACK)
        {
            FlxG.mouse.visible = false;
            FlxG.sound.play(Paths.sound('cancelMenu'));
	    FlxG.switchState(new OptionsMenu());
        }

    }

    override function beatHit() 
    {
        super.beatHit();

        FlxTween.tween(FlxG.camera, {zoom: 1.03}, 0.3, {ease: FlxEase.quadOut, type: BACKWARD});
    }
    
	private function generateStaticArrows(player:Int):Void
        {
            for (i in 0...4)
            {
                // FlxG.log.add(i);
                var babyArrow:FlxSprite = new FlxSprite(0, strumLine.y);
                babyArrow.frames = Paths.getSparrowAtlas('noteStuff/NOTE_assets' + (FlxG.save.data.noteColor ? '-gray' : ''));
                babyArrow.animation.addByPrefix('green', 'arrowUP');
                babyArrow.animation.addByPrefix('blue', 'arrowDOWN');
                babyArrow.animation.addByPrefix('purple', 'arrowLEFT');
                babyArrow.animation.addByPrefix('red', 'arrowRIGHT');
                babyArrow.antialiasing = true;
                babyArrow.setGraphicSize(Std.int(babyArrow.width * 0.7));
                switch (Math.abs(i))
                {
                    case 0:
                        babyArrow.x += Note.swagWidth * 0;
                        babyArrow.animation.addByPrefix('static', 'arrowLEFT');
                        babyArrow.animation.addByPrefix('pressed', 'left press', 24, false);
                        babyArrow.animation.addByPrefix('confirm', 'left confirm', 24, false);
                    case 1:
                        babyArrow.x += Note.swagWidth * 1;
                        babyArrow.animation.addByPrefix('static', 'arrowDOWN');
                        babyArrow.animation.addByPrefix('pressed', 'down press', 24, false);
                        babyArrow.animation.addByPrefix('confirm', 'down confirm', 24, false);
                    case 2:
                        babyArrow.x += Note.swagWidth * 2;
                        babyArrow.animation.addByPrefix('static', 'arrowUP');
                        babyArrow.animation.addByPrefix('pressed', 'up press', 24, false);
                        babyArrow.animation.addByPrefix('confirm', 'up confirm', 24, false);
                    case 3:
                        babyArrow.x += Note.swagWidth * 3;
                        babyArrow.animation.addByPrefix('static', 'arrowRIGHT');
                        babyArrow.animation.addByPrefix('pressed', 'right press', 24, false);
                        babyArrow.animation.addByPrefix('confirm', 'right confirm', 24, false);
                }
                babyArrow.updateHitbox();
                babyArrow.scrollFactor.set();
    
                babyArrow.ID = i;
    
                switch (player)
                {
                    case 0:
                        babyArrow.visible = !FlxG.save.data.middlescroll;
                        cpuStrums.add(babyArrow);
                    case 1:
                        playerStrums.add(babyArrow);
                }
    
                babyArrow.animation.play('static');
                babyArrow.x += 50;
                babyArrow.x += ((FlxG.width / 2) * player);

                if (FlxG.save.data.middlescroll)
                    babyArrow.x -= 278;

                cpuStrums.forEach(function(spr:FlxSprite)
                {					
                    spr.centerOffsets(); //CPU arrows start out slightly off-center
                });
    
                strumLineNotes.add(babyArrow);
            }
        }
}
