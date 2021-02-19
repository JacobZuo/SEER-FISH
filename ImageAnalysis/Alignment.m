function [PhaseImageShift, varargout] = Alignment(PhaseImage, varargin)

    if isempty(varargin)
        ImageOutNum = 0;
    else
        ImageOutNum = size(varargin, 2);
    end

    SectionSize = 250;
    CorrectionSize = 400;

    [DistanceX, DistanceY] = ShiftCal(PhaseImage, SectionSize, CorrectionSize);

    if ImageOutNum > 0

        for outnum = 1:ImageOutNum
            varargout{outnum} = [];
        end

    else
    end

    Ymin = max(-min(DistanceY(:)) + 1, 1);
    Ymax = min(size(PhaseImage, 1) - max(DistanceY(:)), size(PhaseImage, 1));

    Xmin = max(-min(DistanceX(:)) + 1, 1);
    Xmax = min(size(PhaseImage, 2) - max(DistanceX(:)), size(PhaseImage, 2));

    for k = 1:size(PhaseImage, 3)
        PhaseImageShift(:, :, k) = PhaseImage(Ymin + DistanceY(k):Ymax + DistanceY(k), Xmin + DistanceX(k):Xmax + DistanceX(k), k);

        if ImageOutNum > 0

            for outnum = 1:ImageOutNum
                varargout{outnum}(:, :, k) = varargin{outnum}(Ymin + DistanceY(k):Ymax + DistanceY(k), Xmin + DistanceX(k):Xmax + DistanceX(k), k);
            end

        else
        end

    end

end
