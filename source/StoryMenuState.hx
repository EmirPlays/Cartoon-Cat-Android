package;

import flixel.text.FlxText;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.addons.transition.FlxTransitionableState;
import flixel.util.FlxAxes;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxColor;

using StringTools;

class StoryMenuState extends MusicBeatState
{
    var songs:Array<Array<String>> = [
        ['Trapped-Mouse', 'Reruns'],
        ['???']
    ];
    var difficulties:Array<String> = ['EASY', 'NORMAL', 'HARD'];
    var unlockedWeeks:Array<Bool> = [true];

    var curWeek:Int = 0;
	var curDifficulty:Int = 1;
    var curSelectable:Int = 0;

    var art:FlxSprite;
    var tv:FlxSprite;

    var diff:FlxSprite;
    var lock:FlxSprite;

    var leftArrow:FlxSprite;
    var rightArrow:FlxSprite;

    var tracksText:FlxText;

    override function create() 
    {
        if (!FlxG.sound.music.playing || MusicBeatState.curMusic != 'spookyMenu')
            playMusic('spookyMenu');

        var ui_tex = Paths.getSparrowAtlas('storymenu/cool');

        art = new FlxSprite().loadGraphic(Paths.image('storymenu/artTV'), true, 2048, 1177);
        art.animation.add('0', [0], 0, true);
        art.animation.add('1', [1], 0, true);
        art.antialiasing = true;
        art.setGraphicSize(FlxG.width, FlxG.height);
        art.updateHitbox();
        art.animation.play(Std.string(curWeek));
        add(art);

        var overlay:FlxSprite = new FlxSprite(100);
        overlay.frames = Paths.getSparrowAtlas('storymenu/static');
        overlay.animation.addByPrefix('idle', 'TV static', 24, true);
        overlay.antialiasing = true;
        // hotfix for smol overlay :trol:
        overlay.scale.set(2, 2);
        overlay.updateHitbox();
        overlay.animation.play('idle');
        add(overlay);

        tv = new FlxSprite().loadGraphic(Paths.image('storymenu/storyTV'));
        tv.antialiasing = true;
        tv.setGraphicSize(FlxG.width, FlxG.height);
        tv.updateHitbox();
        add(tv);

        diff = new FlxSprite(0, 100);
        diff.frames = ui_tex;
        diff.animation.addByPrefix('easy', 'EASY', 0, true);
        diff.animation.addByPrefix('normal', 'NORMAL', 0, true);
        diff.animation.addByPrefix('hard', 'HARD', 0, true);
        diff.animation.play(difficulties[curDifficulty].toLowerCase());
        diff.antialiasing = true;
        diff.x = (cfs('X', diff, art)) + 25;
        add(diff);

        lock = new FlxSprite(600, 275);
        lock.frames = ui_tex;
        lock.animation.addByPrefix('soon', 'lock', 0, true);
        lock.animation.play('soon');
        lock.antialiasing = true;
        add(lock);
        
        leftArrow = new FlxSprite();
        leftArrow.frames = ui_tex;
        leftArrow.animation.addByPrefix('idle', 'left arrow', 0, true);
        leftArrow.animation.play('idle');
        leftArrow.antialiasing = true;
        add(leftArrow);

        rightArrow = new FlxSprite();
        rightArrow.frames = ui_tex;
        rightArrow.animation.addByPrefix('idle', 'right arrow', 0, true);
        rightArrow.animation.play('idle');
        rightArrow.antialiasing = true;
        add(rightArrow);

        tracksText = new FlxText(0, 220, 0, "TRACKS\n\n", 25);
        tracksText.setFormat("Karma Suture", 25, FlxColor.WHITE, CENTER);
        add(tracksText);

        changeSelectable();
        changeWeek();
        changeDifficulty();

        addVirtualPad(FULL, A_B);

        super.create();
    }

    var selectedWeek:Bool = false;
    var movedBack:Bool = false;

    override function update(elapsed:Float) 
    {
        if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;

        diff.visible = unlockedWeeks[curWeek];
        lock.visible = !unlockedWeeks[curWeek];

        if (!movedBack && !selectedWeek)
        {
            if (controls.LEFT_P)
                (curSelectable == 0 ? changeWeek(-1) : changeDifficulty(-1));
            if (controls.RIGHT_P)
                (curSelectable == 0 ? changeWeek(1) : changeDifficulty(1));
    
            if (controls.UP_P)
                changeSelectable(-1);
            if (controls.DOWN_P)
                changeSelectable(1);
    
            if (controls.BACK)
            {
                movedBack = true;
                FlxG.sound.play(Paths.sound('cancelMenu'));
                FlxG.switchState(new MainMenuState());
            }
    
            if (controls.ACCEPT && curSelectable == 0)
                selectWeek();  
        }

        super.update(elapsed);
    }

    function changeDifficulty(num:Int = 0)
    {
        if (unlockedWeeks[curWeek])
        {
            FlxG.sound.play(Paths.sound('scrollMenu'));
        
            curDifficulty += num;
    
            if (curDifficulty > difficulties.length - 1)
                curDifficulty = 0;
            if (curDifficulty < 0)
                curDifficulty = difficulties.length - 1;
    
            diff.offset.x = 0;
            diff.animation.play(difficulties[curDifficulty].toLowerCase());

            switch (curDifficulty)
            {
                case 1:
                    diff.offset.x = 55;
                case 2:
                    diff.offset.x = 7;
            }
        }
    }

    function changeWeek(num:Int = 0)
    {
        FlxG.sound.play(Paths.sound('scrollMenu'));

        curWeek += num;

        if (curWeek > songs.length - 1)
            curWeek = 0;
        if (curWeek < 0)
			curWeek = songs.length - 1;

        art.animation.play(Std.string(curWeek));

        tracksText.text = "TRACKS\n\n";

        for (i in 0...songs[curWeek].length)
        {
            tracksText.text += songs[curWeek][i].toUpperCase() + "\n\n";
        }

        tracksText.text = StringTools.replace(tracksText.text, '-', ' ');

        tracksText.screenCenter(X);
		tracksText.x -= FlxG.width * 0.42;
    }

    function changeSelectable(num:Int = 0)
    {
        if (unlockedWeeks[curWeek])
        {
            FlxG.sound.play(Paths.sound('scrollMenu'));

            curSelectable += num;
    
            if (curSelectable > 1)
                curSelectable = 0;
            if (curSelectable < 0)
                curSelectable = 1;
        }

        // ow hell naw hardcoding1!!1!
        switch (curSelectable)
        {
            case 0:
                leftArrow.x = cfs('X', leftArrow, art) - 235;
                leftArrow.y = cfs('Y', leftArrow, art);
    
                rightArrow.x = cfs('X', rightArrow, art) + 425;
                rightArrow.y = cfs('Y', rightArrow, art);

                diff.alpha = 0.6;
            case 1:
                leftArrow.x = diff.width + 235;
                leftArrow.y = diff.y - 5;
        
                rightArrow.x = diff.width + 645;
                rightArrow.y = diff.y - 5;

                diff.alpha = 1;
        }
    }

    function selectWeek()
    {
        if (unlockedWeeks[curWeek] && !selectedWeek)
        {
            FlxG.sound.play(Paths.sound('confirmMenu'));

            selectedWeek = true;

            var stuff:String = "";

            if (curDifficulty != 1)
                stuff = '-' + difficulties[curDifficulty].toLowerCase();

            PlayState.storyPlaylist = songs[curWeek];
            PlayState.isStoryMode = true;
            PlayState.storyDifficulty = curDifficulty;
    
            PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + stuff, PlayState.storyPlaylist[0].toLowerCase());
            PlayState.storyWeek = curWeek;
            PlayState.campaignScore = 0;
    
            FlxG.camera.fade(FlxColor.BLACK, 1.6, false, function()
            {
                FlxTransitionableState.skipNextTransOut = true;
                FlxG.switchState(new LoadingState(new PlayState(), true));
            });
        }
        else
        {
            FlxG.sound.play(Paths.sound('lockedMenu'));
            FlxG.camera.shake(0.005, 0.12);
        }
    }

    // center from sprite (cool stuff)
    function cfs(dir:String, main:FlxSprite, target:FlxSprite):Float
    {
        if (dir != 'X')
            return target.height / 2 - main.height / 2;
        if (dir != 'Y')
            return target.width / 2 - main.width / 2;

        return 0;
    }
}
