function [features, labels] = balanceFeatureClasses(trainingFeatures, trainingLabels, seed)
	c1_idx = find(squeeze(trainingLabels==1));
	size_c1 = length(c1_idx);

	c0_idx = find(squeeze(trainingLabels==0));
	size_c0 = length(c0_idx);
	
	if size_c1>size_c0
		rng(seed);
		sample=randperm(size_c1,size_c0);
		new_labels=[trainingLabels(c1_idx(sample)); trainingLabels(c0_idx)];
		new_features=[trainingFeatures(c1_idx(sample),:); trainingFeatures(c0_idx,:)];
	else
		rng(seed);
		sample=randperm(size_c0, size_c1);
		new_labels=[trainingLabels(c0_idx(sample)); trainingLabels(c1_idx)];
		new_features=[trainingFeatures(c0_idx(sample),:); trainingFeatures(c1_idx,:)];
	end
	features = new_features;
	labels = new_labels;
end