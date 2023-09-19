function y = normalizeCurveletFeatures(Curvelets)
%Gets the feature vector from the Curvelet coefficient structure, those
%features are the parameters beta, alpha and mu of the normalized gaussian
%distribution
%   Detailed explanation goes here

    CurveletsCopy=Curvelets;
    NormalizationCoeffs=getNormalizationCoeffScale(Curvelets);
    [~,sc]=size(Curvelets);
    for i=1:sc
        scale=Curvelets{i};
        [~, ss]=size(scale);
        for j=1:ss
             CurveletsCopy{i}{j} = (1/NormalizationCoeffs(i))*Curvelets{i}{j};
         end
    end
    y=CurveletsCopy;
end