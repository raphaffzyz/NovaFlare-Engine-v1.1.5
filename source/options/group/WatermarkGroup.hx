package options.group;

class WatermarkGroup
{
    static public function add(follow:OptionBG) {
        var option:Option = new Option(
            Language.getStr('Watermark'),
            TITLE
        );
        follow.addOption(option);

        var reset:ResetRect = new ResetRect(450, 20, follow);
        follow.add(reset);

        ///////////////////////////////

        var option:Option = new Option(
            Language.getStr('FPScounter'),
            TEXT
        );
        follow.addOption(option);

        var option:Option = new Option(
            Language.getStr('showFPS'),
            'showFPS',
            BOOL
        );
        follow.addOption(option);

        var option:Option = new Option(
            Language.getStr('showExtra'),
            'showExtra',
            BOOL
        );
        follow.addOption(option);

        var option:Option = new Option(
            Language.getStr('rainbowFPS'),
            'rainbowFPS',
            BOOL
        );
        follow.addOption(option);

        var memoryTypeArray:Array<String> = ["Usage", "Reserved", "Current", "Large"];

        var option:Option = new Option(
            Language.getStr('memoryType'),
            'memoryType',
            STRING,
            memoryTypeArray
        );
        follow.addOption(option);

        var option:Option = new Option(
            Language.getStr('FPSScale'),
            'FPSScale',
            FLOAT,
            0,
            5,
            1
        );
        follow.addOption(option);

        var option:Option = new Option(
            Language.getStr('Watermark'),
            TEXT
        );
        follow.addOption(option);

        var option:Option = new Option(
            Language.getStr('showWatermark'),
            'showWatermark',
            BOOL
        );
        follow.addOption(option);

        var option:Option = new Option(
            Language.getStr('WatermarkScale'),
            'WatermarkScale',
            FLOAT,
            0,
            5,
            1
        );
        follow.addOption(option); 
    }
}