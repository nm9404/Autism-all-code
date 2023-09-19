function y = getCurveletFeatureVector(Curvelets)
%Gets the feature vector from the Curvelet coefficient structure, those
%features are the parameters beta, alpha and mu of the normalized gaussian
%distribution
%   Detailed explanation goes here
    featureVector=[];
    [~,sc]=size(Curvelets);
    for i=1:sc
        scale=Curvelets{i};
        [~, ss]=size(scale);
        for j=1:ss
             coefficientMatrix = scale{j};
             distributionData=real(coefficientMatrix(:));

             [alpha,beta]=ggmle(distributionData);
             mu=mean(distributionData);

             features=[alpha,beta,mu];
             featureVector = [featureVector features];
         end
    end
    y=featureVector;
end

