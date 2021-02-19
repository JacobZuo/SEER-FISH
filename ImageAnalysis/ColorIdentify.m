function [CodexRes] = ColorIdentify(BW_Image_Filtered, FITCImage, TRITCImage, CY5Image, Index)

    CellRegion = regionprops(BW_Image_Filtered > 0, 'Area');
    % Intensity=cell(0);
    FluorescentHyp = zeros(3, size(CellRegion, 1));
    FluorescentProb = zeros(3, size(CellRegion, 1));
    CodexRes = zeros(size(CellRegion, 1), 8);
    IntensityColorAll = zeros(3, size(CellRegion, 1));

    Channel = cell(0);

    for Round = 1:size(Index, 2)

        Channel{1} = FITCImage(:, :, Index(Round));
        Channel{2} = TRITCImage(:, :, Index(Round));
        Channel{3} = CY5Image(:, :, Index(Round));

        for C = 1:3

            %         BackGroundIndensity=Channel{C}(~BW_Image_Filtered);
            %         BackGroundRandPerm=BackGroundIndensity(randperm(size(BackGroundIndensity,1),50000));

            CellRegion = regionprops(BW_Image_Filtered > 0, Channel{C}, 'Area', 'MeanIntensity', 'PixelValues', 'BoundingBox');
            CellRegionCell = struct2cell(CellRegion);
            CellRegionBoundingBox = CellRegionCell(2, :);
            %         Intensity{Round,C}=cell2mat(CellRegionCell(4,:));
            for k = 1:size(CellRegion, 1)
                CellRegionBoxX = max(floor(CellRegionBoundingBox{k}(1)) - 50, 1):min(floor(CellRegionBoundingBox{k}(1)) + CellRegionBoundingBox{k}(3) + 50, size(Channel{C}, 2));
                CellRegionBoxY = max(floor(CellRegionBoundingBox{k}(2)) - 50, 1):min(floor(CellRegionBoundingBox{k}(2)) + CellRegionBoundingBox{k}(4) + 50, size(Channel{C}, 1));
                ChannelImageCut = Channel{C}(CellRegionBoxY, CellRegionBoxX);
                BW_ImageCut = BW_Image_Filtered(CellRegionBoxY, CellRegionBoxX);
                BackGroundCut = ChannelImageCut(~BW_ImageCut);
                IntensityColorAll(C, k) = cell2mat(CellRegionCell(4, k)) - mean(BackGroundCut);
                [FluorescentHyp(C, k), FluorescentProb(C, k)] = ttest2(double(CellRegionCell{3, k}), double(BackGroundCut), 'Tail', 'Right', 'Alpha', 0.001, 'Vartype', 'unequal');
                DisplayBar(k, size(CellRegion, 1));
            end

        end

        NonCellIndex = min(FluorescentProb(:, :), [], 1) > 0.05;
        ProbIndex = sum(FluorescentProb(:, :) == min(FluorescentProb(:, :), [], 1), 1) == 1;
        [ProbColor, ~] = find(FluorescentProb(:, ProbIndex) == min(FluorescentProb(:, ProbIndex), [], 1));
        [HighIndensity, ~] = find(IntensityColorAll(:, :) == max(IntensityColorAll(:, :), [], 1));

        CodexResRound = zeros(size(CellRegion, 1), 1);

        CodexResRound(ProbIndex) = ProbColor;
        CodexResRound(NonCellIndex) = 0;
        CodexResRound(~NonCellIndex & ~ProbIndex) = HighIndensity(~NonCellIndex & ~ProbIndex);
        CodexRes(:, Round) = CodexResRound;

    end

end
