function [ColorRGB] = GroupColorGenerator(GroupNum)

    ColorLevel = size(GroupNum,2);
    GroupColors=rgb2hsv(ColorGenerator(ColorLevel));
    ColorH = GroupColors(:,1);
    
    for GroupIndex = 1:ColorLevel
        
        ColorS = ((GroupNum(GroupIndex):-1:1) - (GroupNum(GroupIndex) + 1) / 2) ./ GroupNum(GroupIndex) .* 0.55 + 0.55;
        ColorV = ((1:GroupNum(GroupIndex)) - (GroupNum(GroupIndex) + 1) / 2) ./ GroupNum(GroupIndex) .* 0.25 + 0.75;

        
        
        if GroupIndex==1
            ColorHSV(1:sum(GroupNum(1:GroupIndex)), 1) = ColorH(GroupIndex);
            ColorHSV(1:sum(GroupNum(1:GroupIndex)), 2) = ColorS;
            ColorHSV(1:sum(GroupNum(1:GroupIndex)), 3) = ColorV;
        else
            ColorHSV((sum(GroupNum(1:(GroupIndex-1)))+1):sum(GroupNum(1:GroupIndex)), 1) = ColorH(GroupIndex);
            ColorHSV((sum(GroupNum(1:(GroupIndex-1)))+1):sum(GroupNum(1:GroupIndex)), 2) = ColorS;
            ColorHSV((sum(GroupNum(1:(GroupIndex-1)))+1):sum(GroupNum(1:GroupIndex)), 3) = ColorV;
        end

    end

    ColorRGB = hsv2rgb(ColorHSV);


end

