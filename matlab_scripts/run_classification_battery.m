clear all;
table_files={'curvelet_adult_axial_transposed', 'curvelet_adult_sagital', 'curvelet_adult_coronal'};
kernels={'linear', 'rbf'};
datasets={'ABIDE-I', 'ABIDE-II'};
num_cores=12;
params=cell(length(table_files)*length(kernels)*length(datasets),1);
count=1;

for i=1:length(table_files)
    table_file=table_files{i};
    for j=1:length(kernels)
        kernel=kernels{j};
        for k=1:length(datasets)
            dataset=datasets{k};
            params{count}={table_file, kernel, dataset};
            count=count+1;
            %compute_SVM_parallel(table_file, kernel, dataset, num_cores);
        end
    end
end

parpool(num_cores);
parfor i=1:length(params)
    param_row=params{i};
    table_file=param_row{1};
    kernel=param_row{2};
    dataset=param_row{3};
    compute_SVM(table_file,kernel,dataset);
end
delete(gcp('nocreate'));