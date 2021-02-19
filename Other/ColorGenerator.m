function [ColorRGB] = ColorGenerator(ColorNum)

    % ColorNum=size(PlateResult,2);
    ColorLevel = floor((ColorNum) ./ 10) + 1;
    ColorS = ((1:ColorLevel) - (ColorLevel + 1) / 2) ./ ColorLevel .* 0.5 + 0.6;
    ColorV = ((ColorLevel:-1:1) - (ColorLevel + 1) / 2) ./ ColorLevel .* 0.15 + 0.9;

    ColorDistance = 1/4;
    ColorSep = floor((floor(ColorNum / ColorLevel) + 1) * ColorDistance);

    for LevelIndex = 1:ColorLevel

        if LevelIndex ~= ColorLevel

            ColorIndex = [];

            for SepIndex = 1:ColorSep
                ColorIndex(end + 1:end + size(SepIndex:ColorSep:(floor(ColorNum / ColorLevel) + 1), 2)) = SepIndex:ColorSep:(floor(ColorNum / ColorLevel) + 1);
            end

            ColorH = ((ColorIndex) - LevelIndex / (ColorLevel + 1)) ./ (floor(ColorNum / ColorLevel) + 1);

            ColorHSV(((LevelIndex - 1) * (floor(ColorNum / ColorLevel) + 1) + 1):(LevelIndex * (floor(ColorNum / ColorLevel) + 1)), 1) = ColorH;
            ColorHSV(((LevelIndex - 1) * (floor(ColorNum / ColorLevel) + 1) + 1):(LevelIndex * (floor(ColorNum / ColorLevel) + 1)), 2) = ColorS(LevelIndex);
            ColorHSV(((LevelIndex - 1) * (floor(ColorNum / ColorLevel) + 1) + 1):(LevelIndex * (floor(ColorNum / ColorLevel) + 1)), 3) = ColorV(LevelIndex);
        else

            ColorIndex = [];

            for SepIndex = 1:ColorSep
                ColorIndex(end + 1:end + size(SepIndex:ColorSep:(ColorNum - (floor(ColorNum / ColorLevel) + 1) * (ColorLevel - 1)), 2)) = SepIndex:ColorSep:(ColorNum - (floor(ColorNum / ColorLevel) + 1) * (ColorLevel - 1));
            end

            ColorH = ((ColorIndex) - LevelIndex / (ColorLevel + 1)) ./ (ColorNum - (floor(ColorNum / ColorLevel) + 1) * (ColorLevel - 1));
            ColorHSV(((LevelIndex - 1) * (floor(ColorNum / ColorLevel) + 1) + 1):ColorNum, 1) = ColorH;
            ColorHSV(((LevelIndex - 1) * (floor(ColorNum / ColorLevel) + 1) + 1):ColorNum, 2) = ColorS(LevelIndex);
            ColorHSV(((LevelIndex - 1) * (floor(ColorNum / ColorLevel) + 1) + 1):ColorNum, 3) = ColorV(LevelIndex);
        end

    end

    ColorRGB = hsv2rgb(ColorHSV);

end
