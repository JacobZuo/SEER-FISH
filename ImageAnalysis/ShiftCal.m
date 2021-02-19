function [DistanceX, DistanceY] = ShiftCal(PhaseImage, SectionSize, CorrectionSize)

    [Hight, Width, Num] = size(PhaseImage);
    DistanceX = [];
    DistanceY = [];

    for i = 1:Num
        Image1 = double(PhaseImage(:, :, max([1, i - 1])));
        Image2 = double(PhaseImage(:, :, i));
        Image1 = Image1 - mean(mean(Image1));
        Image2 = Image2 - mean(mean(Image2));
        SectionImage1 = Image1(floor(Hight / 2) - SectionSize:floor(Hight / 2) + SectionSize, floor(Width / 2) - SectionSize:floor(Width / 2) + SectionSize);
        SectionImage2 = Image2(floor(Hight / 2) - CorrectionSize:floor(Hight / 2) + CorrectionSize, floor(Width / 2) - CorrectionSize:floor(Width / 2) + CorrectionSize);

        CrossCorr = xcorr2(SectionImage2, SectionImage1);
        [~, Location] = max(CrossCorr(:));
        [YY, XX] = ind2sub(size(CrossCorr), Location);

        if i == 1
            DistanceY(i) = YY - SectionSize - CorrectionSize - 1;
            DistanceX(i) = XX - SectionSize - CorrectionSize - 1;
        else
            DistanceY(i) = YY - SectionSize - CorrectionSize - 1 + DistanceY(i - 1);
            DistanceX(i) = XX - SectionSize - CorrectionSize - 1 + DistanceX(i - 1);
        end

        DisplayBar(i, Num);
    end

end
