clear all;

addpath('LibreriaNifti');
addpath('ToolboxWaveletTexture');
addpath('fdct_wrapping_matlab');
addpath('collage_utils');

table_name='AAL';
regions_data=readtable('AAL/labels_aal_transformed.csv');
regions=height(regions_data)



characterization_path='characterization-AAL';

axis='axial'; %axial, coronal, sagital, axial-transposed
table_output_name=['curvelet_',lower(table_name),'_',axis];

num_elems_table=8;

padding=0;
coef_normalization=false;
num_subjects=1;

features_cell=cell(regions, num_elems_table,num_subjects);
bad_log_cell={};


for i=1:num_subjects
    sub_id="0";
    dataset="ONPRC18";
    site_id="NA";
    age=0;
    dx_group=0;
    
    try 
        volume_struc=load_untouch_nii('AAL/MNI152_T1_1mm_brain.nii.gz');
    
        regions_seg_struc=load_untouch_nii('AAL/aal_transformed_roi.nii.gz');
    catch exception
        bad_sub_cell={'file not found',sub_id, site_id, dataset};
        bad_log_cell=[bad_log_cell; bad_sub_cell];
        continue;
    end
    
    brain_vol=volume_struc.img;
    
    temporal_features_cell=cell(regions, num_elems_table);
    
    for j=1:regions
        segmentation_vol=regions_seg_struc.img;

        region_data_row=regions_data(j, :);
        region_name=cell2mat(region_data_row.name);
        region_index=region_data_row.index;    
        try
	       collageImage=getCollageImage(brain_vol, segmentation_vol, uint8(region_index), axis, padding);
	       collageImageN = collageImage - min(collageImage,[],'all');
	       collageImageN = uint8(255*(collageImageN/max(collageImageN, [], 'all')));
		if ~exist([characterization_path,'/',table_name,'/',region_name], 'dir')
      			 mkdir([characterization_path,'/',table_name,'/',region_name]);
    		end
               imwrite(collageImageN, [characterization_path,'/',table_name,'/',region_name,'/','mosaic.jpg']);
	       curvelets=fdct_wrapping(collageImage,1,1,4,16);
	       if coef_normalization
		      %curvelets=normalizeCurveletFeatures(curvelets);
		      curvelets=normalizeCurveletSubbands(curvelets);
	       end
            curvelet_vector=real(getCurveletFeatureVector(curvelets));
        catch exception
	    disp(exception)
            bad_sub_cell={['characterization issue on region ',num2str(region_index)], sub_id, site_id, dataset};
            bad_log_cell=[bad_log_cell; bad_sub_cell];
            continue;
        end
        
        
        cell_row={region_index, region_name, ...
            sub_id, dx_group, dataset, site_id, age, curvelet_vector};
        
        temporal_features_cell(j,:)=cell_row;
    end
        
    features_cell(:,:,i)=temporal_features_cell; 
end

save(table_output_name, 'features_cell');
table_names={'region_index','region_name','subject_id', 'dx_group', 'dataset','site_id','age','curv'};
table=cell2table(reshape(permute(features_cell, [1 3 2]), [num_subjects*(regions)...
    ,num_elems_table]));
table.Properties.VariableNames=table_names;
writetable(table, [characterization_path,'/',table_output_name, '.csv']);
writetable(cell2table(bad_log_cell), [characterization_path,'/',table_output_name, '-bad-log.csv']);

delete(gcp('nocreate'));

