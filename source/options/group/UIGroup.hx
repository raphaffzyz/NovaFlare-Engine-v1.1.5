package options.group;

class UIGroup
{
    static public function add(follow:OptionBG) {
        var option:Option = new Option(
            Language.getStr('GameUI'),
            TITLE
        );
        follow.addOption(option);

        var reset:ResetRect = new ResetRect(450, 20, follow);
        follow.add(reset);

        ///////////////////////////////

        var option:Option = new Option(
            Language.getStr('Visble'),
            TEXT
        );
        follow.addOption(option);

        var option:Option = new Option(
            Language.getStr('hideHud'),
            'hideHud',
            BOOL
        );
        follow.addOption(option);

        var option:Option = new Option(
            Language.getStr('showComboNum'),
            'showComboNum',
            BOOL
        );
        follow.addOption(option);

        var option:Option = new Option(
            Language.getStr('showRating'),
            'showRating',
            BOOL
        );
        follow.addOption(option);

        var option:Option = new Option(
            Language.getStr('opponentStrums'),
            'opponentStrums',
            BOOL
        );
        follow.addOption(option);

        var option:Option = new Option(
            Language.getStr('judgementCounter'),
            'judgementCounter',
            BOOL
        );
        follow.addOption(option);

        var option:Option = new Option(
            Language.getStr('keyboardDisplay'),
            'keyboardDisplay',
            BOOL
        );
        follow.addOption(option);

        ///////////////////////////////

        var option:Option = new Option(
            Language.getStr('TimeBar'),
            TEXT
        );
        follow.addOption(option);

        var TimeBarArray:Array<String> = ['Time Left', 'Time Elapsed', 'Song Name', 'Disabled'];
        var option:Option = new Option(
            Language.getStr('timeBarType'),
            'timeBarType',
            STRING,
            TimeBarArray
        );
        follow.addOption(option);

        ///////////////////////////////

        var option:Option = new Option(
            Language.getStr('HealthBar'),
            TEXT
        );
        follow.addOption(option);

        var option:Option = new Option(
            Language.getStr('healthBarAlpha'),
            'healthBarAlpha',
            FLOAT,
            0,
            1,
            1
        );
        follow.addOption(option);

        var option:Option = new Option(
            Language.getStr('oldHealthBarVersion'),
            'oldHealthBarVersion',
            BOOL
        );
        follow.addOption(option);

        ///////////////////////////////

        var option:Option = new Option(
            Language.getStr('Combo'),
            TEXT
        );
        follow.addOption(option);

        var option:Option = new Option(
            Language.getStr('comboColor'),
            'comboColor',
            BOOL
        );
        follow.addOption(option);

        var option:Option = new Option(
            Language.getStr('comboOffsetFix'),
            'comboOffsetFix',
            BOOL
        );
        follow.addOption(option);

        ///////////////////////////////

        var option:Option = new Option(
            Language.getStr('KeyBoard'),
            TEXT
        );
        follow.addOption(option);

        var option:Option = new Option(
            Language.getStr('keyboardAlpha'),
            'keyboardAlpha',
            FLOAT,
            0,
            1,
            1
        );
        follow.addOption(option);

        var option:Option = new Option(
            Language.getStr('keyboardTime'),
            'keyboardTime',
            INT,
            0,
            1000,
            0,
            'MS'
        );
        follow.addOption(option);

        var colorStingArray = ['BLACK', 'WHITE', 'GRAY', 'RED', 'GREEN', 'BLUE', 'YELLOW', 'PINK', 'ORANGE', 'PURPLE', 'BROWN', 'CYAN'];

        var option:Option = new Option(
            Language.getStr('keyboardBGColor'),
            'keyboardBGColor',
            STRING,
            colorStingArray
        );
        follow.addOption(option);

        var option:Option = new Option(
            Language.getStr('keyboardTextColor'),
            'keyboardTextColor',
            STRING,
            colorStingArray
        );
        follow.addOption(option);

        ///////////////////////////////

        var option:Option = new Option(
            Language.getStr('Camera'),
            TEXT
        );
        follow.addOption(option);

        var option:Option = new Option(
            Language.getStr('camZooms'),
            'camZooms',
            BOOL
        );
        follow.addOption(option);

        var option:Option = new Option(
            Language.getStr('scoreZoom'),
            'scoreZoom',
            BOOL
        );
        follow.addOption(option);
    }
}