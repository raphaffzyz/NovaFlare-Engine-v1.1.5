package options.group;

class GameplayGroup
{
    static public function add(follow:OptionBG) {

        var option:Option = new Option(
            Language.getStr('Gameplay'),
            TITLE
        );
        follow.addOption(option);

        var reset:ResetRect = new ResetRect(450, 20, follow);
        follow.add(reset);

        var option:Option = new Option(
            Language.getStr('downScroll'),
            'downScroll',
            BOOL
        );
        follow.addOption(option);

        var option:Option = new Option(
            Language.getStr('middleScroll'),
            'middleScroll',
            BOOL
        );
        follow.addOption(option);

        var option:Option = new Option(
            Language.getStr('flipChart'),
            'flipChart',
            BOOL
        );
        follow.addOption(option);

        var option:Option = new Option(
            Language.getStr('ghostTapping'),
            'ghostTapping',
            BOOL
        );
        follow.addOption(option);

        var option:Option = new Option(
            Language.getStr('guitarHeroSustains'),
            'guitarHeroSustains',
            BOOL
        );
        follow.addOption(option);

        var option:Option = new Option(
            Language.getStr('noReset'),
            'noReset',
            BOOL
        );
        follow.addOption(option);

        ///////////////////////////////

        var option:Option = new Option(
            Language.getStr('Opponent'),
            TEXT
        );
        follow.addOption(option);

        var option:Option = new Option(
            Language.getStr('playOpponent'),
            'playOpponent',
            BOOL
        );
        follow.addOption(option);

        var option:Option = new Option(
            Language.getStr('opponentCodeFix'),
            'opponentCodeFix',
            BOOL
        );
        follow.addOption(option);

        var option:Option = new Option(
            Language.getStr('botOpponentFix'),
            'botOpponentFix',
            BOOL
        );
        follow.addOption(option);    

        var option:Option = new Option(
            Language.getStr('HealthDrainOPPO'),
            'HealthDrainOPPO',
            BOOL
        );
        follow.addOption(option);

        var option:Option = new Option(
            Language.getStr('HealthDrainOPPOMult'),
            'HealthDrainOPPOMult',
            FLOAT,
            0,
            5,
            1
        );
        follow.addOption(option);
    }
}