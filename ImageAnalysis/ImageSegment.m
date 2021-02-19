function [BW_Image] = ImageSegment(Image, varargin)

    sePattern = strel('disk', 1);
    AreaRange = [10, 1000];
    Effectiveness = 0.65;
    Threshold = 'Auto';
    N = 10;

    % Reload the parameters input by user
    if isempty(varargin)
    else

        for i = 1:(size(varargin, 2) / 2)
            AssignVar(varargin{i * 2 - 1}, varargin{i * 2})
        end

    end

    % Image = imgaussfilt((Image), 0.2);

    if strcmp(Threshold, 'Auto')
        [counts, ~] = imhist(Image, 128);
        [MaskThreshold, EM] = otsuthresh(counts);

        if EM > Effectiveness
        else

            for i = 1:N

                for j = 1:N
                    [countsAll(:, i, j), ~] = imhist(Image((floor(end / N) * (i - 1) + 1):(floor(end / N) * i), (floor(end / N) * (j - 1) + 1):(floor(end / N) * j)), 64);
                    [ThresholdAll(i, j), EMAll(i, j)] = otsuthresh(countsAll(:, i, j));
                end

            end

            MaskThreshold = min(ThresholdAll(:));
        end

    else
        MaskThreshold = Threshold;
    end

    Mask = (Image < MaskThreshold);
    Mask = imerode(imdilate(Mask, strel('disk', 5)), strel('disk', 2));

    % imshow(Mask)

    Image = adapthisteq(Image);

    Ie = imerode(Image, sePattern);
    Iobr = imreconstruct(Ie, Image);
    Iobrd = imdilate(Iobr, sePattern);
    Iobrcbr = imreconstruct(imcomplement(Iobrd), imcomplement(Iobr));
    Iobrcbr = imcomplement(Iobrcbr);

    L = watershed(Iobrcbr);

    [counts, ~] = imhist(Image, 128);
    ImageThreshold = otsuthresh(counts);

    BW_Image = (Iobrcbr < ImageThreshold);
    BW_Image = BW_Image > 0 & Mask > 0;
    BW_Image = L > 0 & imclose(BW_Image, ones(3));
    BW_Image = imopen(BW_Image, sePattern);
    BW_Image = imfill(BW_Image, 'holes');
    BW_Image = bwpropfilt(BW_Image > 0, 'Area', AreaRange);

    % imshow(BW_Image)
end
