function [StrainLikehood, Decode] = StrainIdentify(StrainCode, CodexRes, CorrBit)

    StrainLikehood = zeros(size(CodexRes));

    for StrainIndex = 1:size(StrainCode, 2)
        StrainLikehood(:, StrainIndex) = sum(CodexRes(:, :) == StrainCode(:, StrainIndex)', 2);
    end

    Decode = zeros([size(CodexRes, 1), 2]);

    RowZero = find(sum(CodexRes(:, :) == 0, 2) > 3);
    Decode(RowZero, 1) = 0;
    Decode(RowZero, 2) = 4;

    [RowExact, ColExact] = find(StrainLikehood(:, :) == size(StrainCode, 1));
    Decode(RowExact, 1) = ColExact;
    Decode(RowExact, 2) = size(StrainCode, 1);

    if CorrBit >= 1
        [RowCorr1] = find(max(StrainLikehood(:, :), [], 2) == (size(StrainCode, 1) - 1) & sum(StrainLikehood(:, :) == max(StrainLikehood(:, :), [], 2), 2) == 1);
        [RowCorr1Index, ColCorr1] = find(StrainLikehood(RowCorr1, :) == (size(StrainCode, 1) - 1));
        Decode(RowCorr1(RowCorr1Index), 1) = ColCorr1;
        Decode(RowCorr1(RowCorr1Index), 2) = size(StrainCode, 1) - 1;
    else
    end

    if CorrBit >= 2
        [RowCorr2] = find(max(StrainLikehood(:, :), [], 2) == (size(StrainCode, 1) - 2) & sum(StrainLikehood(:, :) == max(StrainLikehood(:, :), [], 2), 2) == 1);
        [RowCorr2Index, ColCorr2] = find(StrainLikehood(RowCorr2, :) == (size(StrainCode, 1) - 2));
        Decode(RowCorr2(RowCorr2Index), 1) = ColCorr2;
        Decode(RowCorr2(RowCorr2Index), 2) = size(StrainCode, 1) - 2;
    else
    end

    if CorrBit >= 3
        [RowCorr3] = find(max(StrainLikehood(:, :), [], 2) == (size(StrainCode, 1) - 3) & sum(StrainLikehood(:, :) == max(StrainLikehood(:, :), [], 2), 2) == 1);
        [RowCorr3Index, ColCorr3] = find(StrainLikehood(RowCorr3, :) == (size(StrainCode, 1) - 3));
        Decode(RowCorr3(RowCorr3Index), 1) = ColCorr3;
        Decode(RowCorr3(RowCorr3Index), 2) = size(StrainCode, 1) - 3;
    else
    end

end
