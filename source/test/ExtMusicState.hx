package test;

import flixel.util.FlxTimer;
import Song.SwagSong;
import flixel.system.FlxAssets.FlxSoundAsset;
import flixel.system.FlxSound;
import haxe.io.Path;
import sys.FileSystem;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxSprite;
import flixel.FlxG;

class ExtMusicState extends MusicBeatState
{
    var songs:Array<String> = [];
    var songsInstPaths:Array<String> = [];
    var songsVoicesPaths:Array<String> = [];
    var custInstPath:Array<String> = [];
    var custVoicePath:Array<String> = [];
    private var grpSongs:FlxTypedGroup<Alphabet>;
    var curSelected:Int = 0;
    var leText:String;
    var checkText:FlxText;
    var songCheck:Array<String> = [];
    var text:FlxText;
    var inst:FlxSound;
    var vocals:FlxSound;

    override function create()
    {
        var initSongList = CoolUtil.coolTextFile(StorageVariables.CustomSF);
        for(i in 0...initSongList.length)
        {
            PushAndCheck(initSongList, i);
        }

        var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuBGBlue'));
		add(bg);

        grpSongs = new FlxTypedGroup<Alphabet>();
		add(grpSongs);

        for(i in 0...songs.length)
        {
            var songsText:Alphabet = new Alphabet(0, (70 * i) + 30, songs[i], true ,false);
            songsText.isMenuItem = true;
            songsText.targetY = i;
            grpSongs.add(songsText);
        }

        checkText = new FlxText(FlxG.width * 0.7, 5, 0, "waitin", 32);
        checkText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, RIGHT);

        var pathBG:FlxSprite = new FlxSprite(checkText.x - 6, 0).makeGraphic(Std.int(FlxG.width * 0.35), 66, 0xFF000000);
		pathBG.alpha = 0.6;
		add(pathBG);

        add(checkText);

        var textBG:FlxSprite = new FlxSprite(0, FlxG.height - 26).makeGraphic(FlxG.width, 26, 0xFF000000);
		textBG.alpha = 0.6;
		add(textBG);

        text = new FlxText(textBG.x, textBG.y + 4, FlxG.width, leText, 18);
		text.setFormat(Paths.font("vcr.ttf"), 18, FlxColor.WHITE, RIGHT);
		text.scrollFactor.set();
		add(text);

        changeSelection();

        #if android
        addVirtualPad(UP_DOWN, A_B);
        #end

        FlxG.sound.music.stop();

        super.create();
    }

    override function update(elapsed:Float)
    {
        if(controls.BACK){
            FlxG.sound.music.resume();
            FlxG.switchState(new MainMenuState());
        }

        if(controls.UI_UP_P)
            changeSelection(-1);
        if(controls.UI_DOWN_P)
            changeSelection(1);

        if(controls.ACCEPT){
            trace("trying to play");
            FlxG.sound.destroy();
            
            play();

        }

        super.update(elapsed);
    }

    function changeSelection(change:Int = 0)
    {
        FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

        curSelected += change;

        if(curSelected < 0)
            curSelected = songs.length - 1;
        if(curSelected >= songs.length)
            curSelected = 0;

        var bullShit:Int = 0;

        play();

        for (item in grpSongs.members){
            item.targetY = bullShit - curSelected;
            bullShit++;

            item.alpha = 0.6;

            if(item.targetY == 0)
                item.alpha = 1;
        }

        checkText.text = songCheck[curSelected];
    }

    function play(){
        FlxG.sound.destroy();

        if(songCheck[curSelected] == "Voice and Inst"){
            vocals = new FlxSound().loadEmbedded(songsVoicesPaths[curSelected]);
        } else if (songCheck[curSelected] == "Voice and Inst (Custom)"){
            vocals = new FlxSound().loadEmbedded(custVoicePath[curSelected]);
        }
        else
            vocals = new FlxSound();

        FlxG.sound.list.add(vocals);
        var jiji:FlxSound;
        if(songCheck[curSelected] == "Voice and Inst (Custom)"){
            jiji = FlxG.sound.list.add(new FlxSound().loadEmbedded(custInstPath[curSelected]));
        } else {
            jiji = FlxG.sound.list.add(new FlxSound().loadEmbedded(songsInstPaths[curSelected]));
        }
        vocals.play();
        jiji.play();
    }

    function PushAndCheck(initSongList:Array<String>, i:Int)
    {
        songs.push(initSongList[i]);

        var chartName:String = '${initSongList[i]}.json';
        var possibleInstPath:String = Paths.extInst(initSongList[i]);
        var possibleVoicePath:String = Paths.extVoices(initSongList[i]);

        trace("Pushing possible inst path");
        songsInstPaths.push(possibleInstPath);
        trace("Pushing possible voice path");
        songsVoicesPaths.push(possibleVoicePath);

        var possibleCustInst:String = Paths.custSI(initSongList[i]);
        var possibleCustVoice:String = Paths.custSV(initSongList[i]);
        trace("Another possible inst");
        custInstPath.push(possibleCustInst);
        trace("Another possible voice");
        custVoicePath.push(possibleCustVoice);
        
        checkOne(i);

        //tracing data for debugging
        trace(songsInstPaths[i]);
        trace(songsVoicesPaths[i]);
        trace(custInstPath[i]);
        trace(custVoicePath[i]);
    }

    function checkOne(i:Int)
    {
        if(FileSystem.exists(songsInstPaths[i]) && FileSystem.exists(songsVoicesPaths[i])){
            trace("Existing voice and inst");
            songCheck.push("Voice and Inst");
        } else if (FileSystem.exists(songsInstPaths[i]) && !FileSystem.exists(songsVoicesPaths[i])) {
            trace("Existing inst");
            songCheck.push("Only Inst");
        } else {
            trace("gonna do check two lol");
            checkTwo(i); //lil chainin
        }
    }

    function checkTwo(i:Int)
    {
        if(FileSystem.exists(custInstPath[i]) && FileSystem.exists(custVoicePath[i])){
            trace("Existing voice and inst in custom folder");
            songCheck.push("Voice and Inst (Custom)");
        } else if (FileSystem.exists(custInstPath[i]) && !FileSystem.exists(custVoicePath[i])) {
            trace("Existing inst in custom folder");
            songCheck.push("Only Inst (Custom)");
        } else {
            trace("I tried");
            songCheck.push("None");
        }
    }
}