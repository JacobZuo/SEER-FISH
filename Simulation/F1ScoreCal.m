function [F1ScoreHarmMean, F1ScoreMean, Detection] = F1ScoreCal(ColorSpecify, ColorSpecifySTD, StrainCode, CellNum, CorrBit)

    % CellNum=50000;
    Result = ones([size(StrainCode, 1), CellNum, size(StrainCode, 2)]) * 0;

    for i = 1:size(StrainCode, 1)

        for Strain = 1:size(StrainCode, 2)
            FluorescentMatrics = zeros(CellNum, size(StrainCode, 2));
            ColorMatrics = zeros(CellNum, 3);
            Color = StrainCode(i, :);

            for Probe = 1:size(StrainCode, 2)

                if Color(Probe) == 0
                else
                    FluorescentMatrics(:, Probe) = 10.^(normrnd(ColorSpecify(Probe, Strain, Color(Probe)), ColorSpecifySTD(Probe, Strain, Color(Probe)), [1, CellNum]));
                end

            end

            for j = 1:3
                ColorMatrics(:, j) = sum(FluorescentMatrics(:, Color == j), 2);
            end

            if max(ColorMatrics, [], 2) == 0
            else
                [Result(i, :, Strain), ~] = find(ColorMatrics' == max(ColorMatrics, [], 2)');
            end

            %         [Y,X]=hist(log10(ColorMatrics(:)));
            %         [xData, yData] = prepareCurveData( X, Y );
            %         ft = fittype( 'gauss2' );
            %         opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
            %         opts.Display = 'Off';
            %         opts.Lower = [-Inf -Inf 0 -Inf -Inf 0];
            %         [fitresult, ~] = fit( xData, yData, ft, opts );
            BlankThresh = 0.1;
            Result(i, max(ColorMatrics, [], 2) < BlankThresh, Strain) = 0;
        end

    end

    StrainLikehood = zeros([CellNum, size(StrainCode, 2), size(StrainCode, 2)]);
    Decode = zeros([CellNum, 2, size(StrainCode, 2)]);

    for Strain = 1:size(StrainCode, 2)

        for i = 1:size(StrainCode, 2)
            StrainLikehood(:, i, Strain) = sum(Result(:, :, Strain) == StrainCode(:, i));
        end

        [RowExact, ColExact] = find(StrainLikehood(:, :, Strain) == size(StrainCode, 1));
        Decode(RowExact, 1, Strain) = ColExact;
        Decode(RowExact, 2, Strain) = size(StrainCode, 1);

        if CorrBit >= 1
            [RowCorr1] = find(max(StrainLikehood(:, :, Strain), [], 2) == (size(StrainCode, 1) - 1) & sum(StrainLikehood(:, :, Strain) == max(StrainLikehood(:, :, Strain), [], 2), 2) == 1);
            [RowCorr1Index, ColCorr1] = find(StrainLikehood(RowCorr1, :, Strain) == (size(StrainCode, 1) - 1));
            Decode(RowCorr1(RowCorr1Index), 1, Strain) = ColCorr1;
            Decode(RowCorr1(RowCorr1Index), 2, Strain) = size(StrainCode, 1) - 1;
        else
        end

        if CorrBit >= 2
            [RowCorr2] = find(max(StrainLikehood(:, :, Strain), [], 2) == (size(StrainCode, 1) - 2) & sum(StrainLikehood(:, :, Strain) == max(StrainLikehood(:, :, Strain), [], 2), 2) == 1);
            [RowCorr2Index, ColCorr2] = find(StrainLikehood(RowCorr2, :, Strain) == (size(StrainCode, 1) - 2));
            Decode(RowCorr2(RowCorr2Index), 1, Strain) = ColCorr2;
            Decode(RowCorr2(RowCorr2Index), 2, Strain) = size(StrainCode, 1) - 2;
        else
        end

        if CorrBit >= 3
            [RowCorr3] = find(max(StrainLikehood(:, :, Strain), [], 2) == (size(StrainCode, 1) - 3) & sum(StrainLikehood(:, :, Strain) == max(StrainLikehood(:, :, Strain), [], 2), 2) == 1);
            [RowCorr3Index, ColCorr3] = find(StrainLikehood(RowCorr3, :, Strain) == (size(StrainCode, 1) - 3));
            Decode(RowCorr3(RowCorr3Index), 1, Strain) = ColCorr3;
            Decode(RowCorr3(RowCorr3Index), 2, Strain) = size(StrainCode, 1) - 3;
        else
        end

    end

    Detection = zeros(10, size(StrainCode, 2));

    for Strain = 1:size(StrainCode, 2)

        Detection(1, Strain) = sum(Decode(:, 1, Strain) == Strain & Decode(:, 2, Strain) == size(StrainCode, 1));
        Detection(2, Strain) = sum(Decode(:, 1, Strain) == Strain & Decode(:, 2, Strain) == size(StrainCode, 1) - 1);
        Detection(3, Strain) = sum(Decode(:, 1, Strain) == Strain & Decode(:, 2, Strain) == size(StrainCode, 1) - 2);
        Detection(4, Strain) = sum(Decode(:, 1, Strain) == Strain & Decode(:, 2, Strain) == size(StrainCode, 1) - 3);

        Detection(5, Strain) = sum(Decode(:, 1, Strain) == 0);
        Detection(6, Strain) = sum(Decode(:, 1, Strain) ~= 0 & Decode(:, 1, Strain) ~= Strain);

        Detection(7, Strain) = sum(sum(Decode(:, 1, :) == Strain & Decode(:, 2, :) == size(StrainCode, 1))) - sum(Decode(:, 1, Strain) == Strain & Decode(:, 2, Strain) == size(StrainCode, 1));
        Detection(8, Strain) = sum(sum(Decode(:, 1, :) == Strain & Decode(:, 2, :) == size(StrainCode, 1) - 1)) - sum(Decode(:, 1, Strain) == Strain & Decode(:, 2, Strain) == (size(StrainCode, 1) - 1));
        Detection(9, Strain) = sum(sum(Decode(:, 1, :) == Strain & Decode(:, 2, :) == size(StrainCode, 1) - 2)) - sum(Decode(:, 1, Strain) == Strain & Decode(:, 2, Strain) == (size(StrainCode, 1) - 2));
        Detection(10, Strain) = sum(sum(Decode(:, 1, :) == Strain & Decode(:, 2, :) == size(StrainCode, 1) - 3)) - sum(Decode(:, 1, Strain) == Strain & Decode(:, 2, Strain) == (size(StrainCode, 1) - 3));

    end

    ReCall = sum(Detection(1:4, :)) ./ CellNum;
    UnClass = (Detection(5, :)) ./ CellNum;
    WrCall = (Detection(6, :)) ./ CellNum;
    WrCall2 = sum(Detection(7:10, :)) ./ CellNum;

    Precision = ReCall ./ (ReCall + WrCall2);
    ReCallRate = ReCall;

    F1Score = 2 .* Precision .* ReCallRate ./ (Precision + ReCallRate);
    F1ScoreMean = 2 .* mean(Precision) .* mean(ReCallRate) ./ (mean(Precision) + mean(ReCallRate));
    F1ScoreHarmMean = harmmean(F1Score);

end
