function y = computeAndTestSVMModel(featureMatrix, output, kernel, seed, kFolds, normalize)
     if normalize
         featureMatrix_n=normc(featureMatrix);
     else
         featureMatrix_n=featureMatrix;
     end
     
     rng(seed);
     cp = cvpartition(output,'k',kFolds);
     opts = struct('Optimizer','bayesopt','CVPartition',cp,'ShowPlots',false,'AcquisitionFunctionName','expected-improvement-plus');
     svmModel=fitcsvm(featureMatrix_n, output,'KernelFunction', kernel, 'OptimizeHyperparameters','auto','HyperparameterOptimizationOptions',opts);
     svmValidationModel = crossval(svmModel, 'CVpartition', cp);
     svmValidationModel.ScoreTransform='doublelogit';
     [validationPredictions, validationScores] = kfoldPredict(svmValidationModel);
     confusion_matrix=confusionmat(output, validationPredictions);
     [~,~,~,AUCsvm] = perfcurve(output,validationScores(:,2),double(1));
     [precision,recall,FMeasure,Accuracy, Sensitivity, Specificity] = confMatMetrics(confusion_matrix);
     y = {AUCsvm, precision, recall, FMeasure, Accuracy, Sensitivity, Specificity};
     
end