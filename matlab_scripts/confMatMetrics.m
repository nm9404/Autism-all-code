function [precision,recall,FMeasure,Accuracy, Sensitivity, Specificity] = confMatMetrics(confmat)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
    TN=confmat(1,1); FP=confmat(1,2); FN=confmat(2,1); TP=confmat(2,2);
    precision=TP/(TP+FP);
    recall=TP/(TP+FN);
    FMeasure=2*precision*recall/(precision+recall);
    Accuracy=(confmat(1,1)+confmat(2,2))/(sum(sum(confmat)));
    Sensitivity=TP/(TP+FN);
    Specificity=TN/(TN+FP);
end

