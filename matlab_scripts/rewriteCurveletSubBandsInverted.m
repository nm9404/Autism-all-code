function y = rewriteCurveletSubBandsInverted(curvBands, bandList)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
    [~,sc]=size(curvBands);
    count=1;
    for i=1:sc
        scale=curvBands{i};
        [~, ss]=size(scale);
        for j=1:ss
            if (find(bandList==count)>0)
                curvBands{i}{j}=0*curvBands{i}{j};
            else
                curvBands{i}{j}=curvBands{i}{j};
            end
            count=count+1;
        end
    end
    y=curvBands;
end