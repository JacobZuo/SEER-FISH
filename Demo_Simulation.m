clear
clc

addpath(genpath(pwd))

%% Generate code book

Color = 3;
Round = 8;
HD = 4;

[CodexMatrix] = CodeGenerator(Color, Round, HD);

load('.\Simulation\Demo\DeltaGoverAll.mat')
DeltaGSpecify30 = zeros(size(DeltaG));
DeltaGSpecify30(DeltaG >- 7.9) = -2;
DeltaGSpecify30(DeltaG <- 13.0) = -0.3;
DeltaGSpecify30(DeltaGSpecify30 == 0) = -0.9;

DeltaGSpecify(:, :, 1) = DeltaGSpecify30;
DeltaGSpecify(:, :, 2) = DeltaGSpecify30;
DeltaGSpecify(:, :, 3) = DeltaGSpecify30;

DeltaGSpecifySTD = zeros(size(DeltaGSpecify));
DeltaGSpecifySTD(:, :, :) = 0.3;

CellNum = 2000;
StrainNum = 30;

for Test = 1:5000
    StrainCode = CodexMatrix(:, randperm(size(CodexMatrix, 2), StrainNum));
    StrainCodeAll(:, :, Test) = StrainCode;
    [F1ScoreHarmMean(Test), ~, Detection(:, :, Test)] = F1ScoreCal(DeltaGSpecify, DeltaGSpecifySTD, StrainCode, CellNum, 2);
    ReCall(:, Test) = sum(Detection(1:4, :, Test)) ./ CellNum;
    UnClass(:, Test) = (Detection(5, :, Test)) ./ CellNum;
    WrCall(:, Test) = (Detection(6, :, Test)) ./ CellNum;
    WrCall2(:, Test) = sum(Detection(7:10, :, Test)) ./ CellNum;

    Precision(:, Test) = ReCall(:, Test) ./ (ReCall(:, Test) + WrCall2(:, Test));
    ReCallRate(:, Test) = ReCall(:, Test);
    DisplayBar(Test, 5000);
end
