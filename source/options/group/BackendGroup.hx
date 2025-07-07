package options.group;

class BackendGroup
{
    static public function add(follow:OptionBG) {
        var option:Option = new Option(
            Language.getStr('Backend'),
            TITLE
        );
        follow.addOption(option);

        var reset:ResetRect = new ResetRect(450, 20, follow);
        follow.add(reset);

        ///////////////////////////////

        var option:Option = new Option(
            Language.getStr('Gameplaybackend'),
            TEXT
        );
        follow.addOption(option);

        var option:Option = new Option(
            Language.getStr('fixLNL'),
            'fixLNL',
            INT,
            0,
            2
        );
        follow.addOption(option);

        var PauseMusicArray:Array<String> = ['None', 'Breakfast', 'Tea Time'];

        var option:Option = new Option(
            Language.getStr('pauseMusic'),
            'pauseMusic',
            STRING,
            PauseMusicArray
        );
        follow.addOption(option);

        var hitsoundArray:Array<String> = ['Default'];
        for (folder in Mods.directoriesWithFile(Paths.getSharedPath(), 'sounds/hitsounds/'))
			for (file in FileSystem.readDirectory(folder))
			{				
				if(file.endsWith('.ogg'))
					hitsoundArray.push(file.replace('.ogg', ''));				
			}
        var option:Option = new Option(
            Language.getStr('hitsoundType'),
            'hitsoundType',
            STRING,
            hitsoundArray
        );
        follow.addOption(option);
        option.onChange = onChangeHitsound;

        var option:Option = new Option(
            Language.getStr('hitsoundVolume'),
            'hitsoundVolume',
            FLOAT,
            0,
            1,
            1
        );
        follow.addOption(option);

        var option:Option = new Option(
            Language.getStr('oldHscriptVersion'),
            'oldHscriptVersion',
            BOOL
        );
        follow.addOption(option);

        var option:Option = new Option(
            Language.getStr('pauseButton'),
            'pauseButton',
            BOOL
        );
        follow.addOption(option);

        #if android
        var option:Option = new Option(
            Language.getStr('gameOverVibration'),
            'gameOverVibration',
            BOOL
        );
        follow.addOption(option);
        #end

        var option:Option = new Option(
            Language.getStr('ratingOffset'),
            'ratingOffset',
            INT,
            -500,
            500,
            'MS'
        );
        follow.addOption(option);

        var option:Option = new Option(
            Language.getStr('NoteOffsetState'),
            'NoteOffsetState',
            STATE
        );
        follow.addOption(option);

        var option:Option = new Option(
            Language.getStr('safeFrames'),
            'safeFrames',
            FLOAT,
            0,
            10,
            1
        );
        follow.addOption(option);

        var option:Option = new Option(
            Language.getStr('marvelousWindow'),
            'marvelousWindow',
            INT,
            0,
            166,
            'MS'
        );
        follow.addOption(option);

        var option:Option = new Option(
            Language.getStr('sickWindow'),
            'sickWindow',
            INT,
            0,
            166,
            'MS'
        );
        follow.addOption(option);

        var option:Option = new Option(
            Language.getStr('goodWindow'),
            'goodWindow',
            INT,
            0,
            166,
            'MS'
        );
        follow.addOption(option);

        var option:Option = new Option(
            Language.getStr('badWindow'),
            'badWindow',
            INT,
            0,
            166,
            'MS'
        );
        follow.addOption(option);

        var option:Option = new Option(
            Language.getStr('marvelousRating'),
            'marvelousRating',
            BOOL
        );
        follow.addOption(option);

        var option:Option = new Option(
            Language.getStr('marvelousSprite'),
            'marvelousSprite',
            BOOL
        );
        follow.addOption(option);

        ///////////////////////////////

        var option:Option = new Option(
            Language.getStr('Appbackend'),
            TEXT
        );
        follow.addOption(option);

        var option:Option = new Option(
            Language.getStr('discordRPC'),
            'discordRPC',
            BOOL
        );
        follow.addOption(option);

        var option:Option = new Option(
            Language.getStr('checkForUpdates'),
            'checkForUpdates',
            BOOL
        );
        follow.addOption(option);


        #if mobile
        var option:Option = new Option(
            Language.getStr('screensaver'),
            'screensaver',
            BOOL
        );
        follow.addOption(option);
        #end
        
        #if mobile
        var option:Option = new Option(
            'Check game whether miss files',
            'filesCheck',
            BOOL
        );
        follow.addOption(option);
        #end
    }

    static function onChangeHitsound() {
        if (ClientPrefs.data.hitsoundType == ClientPrefs.defaultData.hitsoundType){
            //FlxG.sound.play(Paths.sound(ClientPrefs.data.hitsoundType));   为啥他会有问题啊
        } else {
            //FlxG.sound.play(Paths.sound('hitsounds/' + ClientPrefs.data.hitsoundType));
        }
    }
    
    static function onChangeCwd() {
        Sys.setCwd(SUtil.getStorageDirectory());
    }
}