clear
clc

addpath(genpath(pwd))

%% Load the data
Type = '.nd2';

NameAll = ls(['.\ImageAnalysis\Demo', filesep, '*', Type]);
FileName = ['.\ImageAnalysis\Demo', filesep, NameAll(1, :)];
[Path, ~, ~] = fileparts(FileName);

for i = 1:8

    % FileName=[PathAll,filesep,NameAll(i,:)];
    % [Path,Name,~]=fileparts(FileName);

    if i == 1
        ImageInfo = ND2Info([Path, filesep, num2str(i), Type]);

        ScaleX = ImageInfo.metadata.channels(1).volume.axesCalibration(1);
        ScaleY = ImageInfo.metadata.channels(1).volume.axesCalibration(2);
        ScaleZ = ImageInfo.metadata.channels(1).volume.axesCalibration(3);

        if ScaleX == ScaleY
            ImageScale(i) = ScaleX;
        else
            warning('Scale not fit in X and Y')
        end

    else
    end

    Image = ND2ReadSingle([Path, filesep, num2str(i), Type]);

    FITCImage(:, :, i) = Image{1};
    TRITCImage(:, :, i) = Image{2};
    CY5Image(:, :, i) = Image{3};
    PhaseImage(:, :, i) = Image{4};
end

%% Multiple Image Alignment

[PhaseImageShift, FITCImageShift, TRITCImageShift, CY5ImageShift] = Alignment(PhaseImage, FITCImage, TRITCImage, CY5Image);

PhaseImageMean = mean(PhaseImageShift(:, :, :), 3);
AdaptBG = adaptthresh(mat2gray(PhaseImageMean), 0.5, 'ForegroundPolarity', 'dark');
Normalize_Phase = mat2gray(double(PhaseImageMean) ./ AdaptBG);

imshow(mat2gray(Normalize_Phase))

%% Image segementation

sePattern = strel('disk', 1);
AreaRange = [10, 1000];
Thereshold = 'Auto';
Effectiveness = 0.65;
N = 12;

[BW_Image_Segment] = ImageSegment(Normalize_Phase, 'sePattern', sePattern, 'AreaRange', AreaRange, 'Thereshold', Thereshold, 'Effectiveness', Effectiveness, 'N', N);
% [BW_Image_Filtered,~] = PhaseCheck(BW_Image_Segment,Normalize_Phase);

[~, Labels] = bwboundaries(BW_Image_Segment, 'noholes');
TestImage = labeloverlay(mat2gray(PhaseImageShift(:, :, 1)), Labels, 'Transparency', 0.75);

imshow(TestImage)

%% Strain Identification

CodexRes = ColorIdentify(BW_Image_Segment, FITCImageShift, TRITCImageShift, CY5ImageShift, 1:8);

% % StrainCode
StrainCode(:, 1) = [3, 3, 2, 3, 3, 3, 3, 3];
StrainCode(:, 2) = [1, 2, 1, 2, 1, 1, 3, 3];
StrainCode(:, 3) = [1, 2, 3, 1, 1, 3, 3, 1];
StrainCode(:, 4) = [2, 1, 1, 2, 1, 2, 2, 2];
StrainCode(:, 5) = [1, 2, 2, 1, 2, 1, 2, 1];
StrainCode(:, 6) = [2, 2, 2, 2, 2, 2, 2, 2];
StrainCode(:, 7) = [2, 3, 2, 3, 2, 3, 1, 1];
StrainCode(:, 8) = [3, 1, 3, 1, 1, 3, 2, 2];
StrainCode(:, 9) = [1, 3, 1, 3, 1, 3, 2, 1];
StrainCode(:, 10) = [2, 1, 2, 1, 1, 2, 2, 1];
StrainCode(:, 11) = [3, 3, 3, 2, 2, 2, 2, 1];
StrainCode(:, 12) = [1, 2, 3, 3, 2, 2, 3, 2];

[StrainLikehood, Decode] = StrainIdentify(StrainCode, CodexRes, 2);

%% Data Output
