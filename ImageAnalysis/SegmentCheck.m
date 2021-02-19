function [BW_Image_Filtered, NonCellRegion] = SegmentCheck(BW_Image, PhaseImage)

    [~, Labels] = bwboundaries(BW_Image, 'noholes');

    CellRegion = regionprops(BW_Image > 0, 'Area', 'BoundingBox');

    CellRegionCell = struct2cell(CellRegion);
    CellRegionBoundingBox = CellRegionCell(2, :);

    NonCellRegion = zeros(size(Labels));

    for i = 1:size(CellRegion, 1)
        CellRegionBoxX = max(floor(CellRegionBoundingBox{i}(1)) - 20, 1):min(floor(CellRegionBoundingBox{i}(1)) + CellRegionBoundingBox{i}(3) + 20, size(Labels, 2));
        CellRegionBoxY = max(floor(CellRegionBoundingBox{i}(2)) - 20, 1):min(floor(CellRegionBoundingBox{i}(2)) + CellRegionBoundingBox{i}(4) + 20, size(Labels, 1));

        PhaseImageCut = PhaseImage(CellRegionBoxY, CellRegionBoxX);
        [counts, ~] = imhist(PhaseImageCut, 32);
        [Thereshold, EM] = otsuthresh(counts);

        if EM < 0.3
            NonCellRegion = NonCellRegion + Labels == i;
            Labels(Labels == i) = 0;
        else
            %     AllMask = Labels(CellRegionBoxY,CellRegionBoxX)>0;
            AllMask = imopen(PhaseImageCut < Thereshold, ones(2));
            CellMask = (Labels(CellRegionBoxY, CellRegionBoxX) == i) & AllMask;

            if sum(CellMask(:)) <= 10
                % noncellregion
                NonCellRegion = NonCellRegion + Labels == i;
                Labels(Labels == i) = 0;
            else
                [PhaseHyp, ~] = ttest2(double(PhaseImageCut(CellMask)), double(PhaseImageCut(~AllMask)), 'Tail', 'Left', 'Alpha', 0.001, 'Vartype', 'unequal');

                if PhaseHyp == 0
                    NonCellRegion = NonCellRegion + Labels == i;
                    Labels(Labels == i) = 0;
                else
                    Labels(Labels == i) = 0;
                    Labels(CellRegionBoxY, CellRegionBoxX) = Labels(CellRegionBoxY, CellRegionBoxX) + CellMask .* i;
                end

            end

        end

        DisplayBar(i, size(CellRegion, 1));
    end

    BW_Image_Filtered = Labels > 0;

end
