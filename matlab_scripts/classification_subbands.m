clear all
table_file='adults_curvelet_sample';
characterization_path='sample_characterization';
table_data=readtable([characterization_path,'/', table_file, '.csv']);
%issue_table=readtable([characterization_path,'/', table_file, '-bad-log.csv']);
exp_name=['SVM_region',table_file];
cortical_regions=96;
subcortical_regions=21;
total_regions=cortical_regions+subcortical_regions;


kernel='rbf';
dataset={'ABIDE-II', 'ABIDE-I', 'ABIDE'};
seed=732;
kFolds=10;
num_features=243;
init_idx=8; 
center_idx=6;
region_idx=90;
normalize_in_svm=true;

num_cols=8;
balance_classes=false;

results_cell=cell(total_regions, num_cols);

%table_data=preprocess_table_all(table_data, issue_table);
center_normalize=false;
results_path='results/sample_classification_subbands';


if center_normalize
	table_data=normalize_center(table_data, num_features, init_idx, center_idx, region_idx);
end

%adults subbands = [1,33,39,44,48,49,50,53,54,55,60,64,69,71,76,77,78,80];
%adolescents subbands = [36,69,71];
%children subbands = [35,56,71];

subbands = [1,33,39,44,48,49,50,53,54,55,60,64,69,71,76,77,78,80];

subband_idx = []
for j = 1:length(subbands)
    sub_s = [(subbands(j)-1)*3 + 1 : (subbands(j)-1)*3 + 3];
    disp(sub_s);
    subband_idx = [subband_idx, sub_s];
end

disp(subband_idx);

i=region_idx;
    
%table_region=table_data(table_data.region_index==i & (strcmp(table_data.dataset, dataset{2}) | strcmp(table_data.dataset, dataset{1}) ), :);
table_region=table_data(table_data.region_index==i, :);
disp(height(table_region));
%table_region=table_data(table_data.region_index==i);
dx_group=cell2mat(table2cell(table_region(:,4)));
featureMatrix=real(cell2mat(table2cell( preprocess_features_table...
    (table_region(:, 8:250), num_features, height(table_region)))));
output=double(dx_group==1);
featureMatrixSub = featureMatrix(:,subband_idx);
if balance_classes
   [featureMatrix, output]=balanceFeatureClasses(featureMatrix, output, seed);
   disp('output');
   disp(output);
end
try 
    results=computeAndTestSVMModel(featureMatrixSub, ...
        output, kernel, seed, kFolds, normalize_in_svm);
    results=[table_region(1,:).region_name,results];

    results_cell(i,:)=results;
catch
    results_cell(i, :)={0,0,0,0,0,0,0,0};
end

results_names={'region','AUCsvm', 'precision',...
    'recall', 'FMeasure', 'Accuracy', 'Sensitivity', 'Specificity'};
table=cell2table(results_cell);
table.Properties.VariableNames=results_names;
writetable(table,[results_path,'/',exp_name, '_', 'region_', num2str(i), '_', dataset{3}, '_', kernel, '.csv']);
