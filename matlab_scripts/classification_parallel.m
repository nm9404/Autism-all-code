clear all
%last run: children groups from QA
table_file='adolescents_curvelet_sample';
characterization_path='sample_characterization_rot/nov_21';
table_data=readtable([characterization_path,'/', table_file, '.csv']);
%issue_table=readtable([characterization_path,'/', table_file, '-bad-log.csv']);
exp_name=['SVM_',table_file];
cortical_regions=96;
subcortical_regions=21;
total_regions=cortical_regions+subcortical_regions;


kernel='rbf';
dataset={'ABIDE-II', 'ABIDE-I', 'ABIDE'};
%seed=732;
seed=94;
kFolds=10;
num_features=243;
init_idx=8; 
center_idx=6;
region_idx=1;
normalize_in_svm=true;

num_cols=8;
balance_classes=true;

results_cell=cell(total_regions, num_cols);

%table_data=preprocess_table_all(table_data, issue_table);
center_normalize=false;
results_path='results/scan_times';


parpool(20)
if center_normalize
	table_data=normalize_center(table_data, num_features, init_idx, center_idx, region_idx);
end

parfor i=1:total_regions
    table_region=table_data(table_data.region_index==i ...
 & (strcmp(table_data.site_id, 'BNI_1') | strcmp(table_data.site_id, 'Caltech') ...
 | strcmp(table_data.site_id, 'CMU') | strcmp(table_data.site_id, 'ETH_1') ... 
 | strcmp(table_data.site_id, 'IP_1') | strcmp(table_data.site_id, 'KKI_1') ...
 | strcmp(table_data.site_id, 'KUL_3') | strcmp(table_data.site_id, 'Leuven') ...
 | strcmp(table_data.site_id, 'MaxMun') | strcmp(table_data.site_id, 'ONRC_2') ...
 | strcmp(table_data.site_id, 'SBL') | strcmp(table_data.site_id, 'TCD_1') ...
 | strcmp(table_data.site_id, 'UCD_1') | strcmp(table_data.site_id, 'UCD_1') ...
 | strcmp(table_data.site_id, 'UCD_1') | strcmp(table_data.site_id, 'UCD_1') ...
 | strcmp(table_data.site_id, 'UCD_1') | strcmp(table_data.site_id, 'UCD_1') ) , :);    disp(height(table_region));
    %table_region=table_data(table_data.region_index==i);
    dx_group=cell2mat(table2cell(table_region(:,4)));
    featureMatrix=real(cell2mat(table2cell( preprocess_features_table...
        (table_region(:, 8:250), num_features, height(table_region)))));
    output=double(dx_group==1);
    if balance_classes
	   [featureMatrix, output]=balanceFeatureClasses(featureMatrix, output, seed);
	   disp('output');
	   disp(output);
    end
    try 
        results=computeAndTestSVMModel(featureMatrix, ...
            output, kernel, seed, kFolds, normalize_in_svm);
        results=[table_region(1,:).region_name,results];

        results_cell(i,:)=results;
    catch
        results_cell(i, :)={0,0,0,0,0,0,0,0};
        continue;
    end
end

results_names={'region','AUCsvm', 'precision',...
    'recall', 'FMeasure', 'Accuracy', 'Sensitivity', 'Specificity'};
table=cell2table(results_cell);
table.Properties.VariableNames=results_names;
writetable(table,[results_path,'/',exp_name, '_', dataset{3}, '_', kernel, '.csv']);

delete(gcp('nocreate'));

