function [CodexMatrix] = CodeGenerator(Color, Round, HD)

    NUM = Color^Round;
    CodexMatrix = zeros(Round, NUM);

    for i = 1:Round
        CodexMatrix(i, :) = mod(floor((0:NUM - 1) / Color^(Round - i)), Color) + 1;
    end

    k = 1;

    for i = 1:NUM

        if size(CodexMatrix, 2) >= k
            Distance = sum(CodexMatrix ~= CodexMatrix(:, k), 1);
            CodexMatrix(:, Distance < HD & Distance > 0) = [];

            if i == 1
                k = 2;
            else
                k = k + 1;
            end

        else
            break
        end

    end

end
