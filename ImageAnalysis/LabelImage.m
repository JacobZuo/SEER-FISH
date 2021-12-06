function [StrainImageAll, StrainImage] = LabelImage(BW_Image_Segment, Decode)
    [~, Labels] = bwboundaries(BW_Image_Segment, 'noholes');

    [StrainIndex, ~, UniqueIndex] = unique(Labels);
    StrainImageAll = zeros(size(Labels));

    for i = 1:max(Decode(:, 1))
        StrainIndex(2:end) = double(Decode(:, 1) == i);
        StrainImage(:, :, i) = reshape(StrainIndex(UniqueIndex), size(Labels));
        StrainImageAll = StrainImageAll + StrainImage(:, :, i) .* i;
    end

    StrainIndex(2:end) = double(Decode(:, 2) == 0);
    StrainImage(:, :, max(Decode(:, 1)) + 1) = reshape(StrainIndex(UniqueIndex), size(Labels));
    StrainImageAll = StrainImageAll + StrainImage(:, :, (max(Decode(:, 1)) + 1)) .* (max(Decode(:, 1)) + 1);

end
