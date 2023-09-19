function y = normalize_center(table, num_features, init_idx, center_idx, region_idx)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here center_idx=6 region_idx=1

    addpath('norm_utils');
    centers=unique(table2cell(table(:,center_idx)));
    regions=unique(table2array(table(:,region_idx)));
    table_copy=table;
    indices={};
    norm_matrices={};
    
    parfor i=1:length(centers)
        center=centers(i);
        
        for j=1:length(regions)
            region=j;
            region_idxs=find(table2array(table(:,region_idx))==region);
            center_idxs=find(strcmp(table2cell(table(:,center_idx)),center));
            query_idxs=intersect(region_idxs, center_idxs);
            subsample_table=table(query_idxs,:);
            indices = [indices, {query_idxs}];
            norm_matrices= [norm_matrices, ...
                {normc(table2array(subsample_table(:,init_idx:init_idx+num_features-1)))}];
            %table_copy(query_idxs,init_idx:init_idx+num_features-1)=array2table(whiten(table2array(subsample_table(:,init_idx:init_idx+num_features-1))));         
        end
        
   
        disp(['center: ',center,' Normalization: OK']);
    end
    
    for j=1:length(indices)
           table_copy(indices{j}, init_idx:init_idx+num_features-1)=array2table(norm_matrices{j});
    end
    
    
    
    y=table_copy;
end

