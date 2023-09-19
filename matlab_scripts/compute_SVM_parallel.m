function y=compute_SVM_parallel(table_file, kernel, dataset, core_size)

    table_data=readtable([table_file, '.csv']);
    issue_table=readtable([table_file, '-bad-log.csv']);
    exp_name=['SVM_',table_file];
    cortical_regions=96;
    subcortical_regions=21;
    total_regions=cortical_regions+subcortical_regions;

    seed=732;
    kFolds=10;
    num_features=243;

    num_cols=8;

    results_cell=cell(total_regions, num_cols);

    table_data=preprocess_table_all(table_data, issue_table);

    parpool(core_size);
    parfor i=1:total_regions

        table_region=table_data(table_data.region_index==i & strcmp(table_data.dataset, dataset), :);
        dx_group=cell2mat(table2cell(table_region(:,4)));
        featureMatrix=real(cell2mat(table2cell( preprocess_features_table...
            (table_region(:, 8:250), num_features, height(table_region)))));
        output=double(dx_group==1);
        try 
            results=computeAndTestSVMModel(featureMatrix, ...
                output, kernel, seed, kFolds);
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
    writetable(table,[exp_name, '_', dataset, '_', kernel, '.csv']);

    delete(gcp('nocreate'));

    y=0;
end