clear all;

addpath('LibreriaNifti');
addpath('ToolboxWaveletTexture');
addpath('fdct_wrapping_matlab');
addpath('collage_utils');

table_name='ABIDE_ADULTS_SAMPLE_MALE';
table_data=readtable([table_name, '.csv']);
regions_data=readtable('region_names.csv');

characterization_path='characterization-10-sep-2021-aal-combined';

pipeline_name='pip-spm-ants-rotation';
init_path='/mnt/md0/ABIDE_PREP';

volume_name='rigid_reg_tempWarped_z_norm.nii.gz';
segmentation_name='aal_seg_comb.nii.gz';

axis='axial'; %axial, coronal, sagital, axial-transposed
table_output_name=['curvelet_',lower(table_name),'_',axis];

regions=13;

num_elems_table=8;
num_subjects=height(table_data);

padding=0;
coef_normalization=false;

features_cell=cell(regions, num_elems_table,num_subjects);
bad_log_cell={};

seg_path='/mnt/md0/nmunerag/Herramientas/atlas/aal_combined.csv';
regions_table = readtable(seg_path);
regions_indices = uint16(cell2mat(table2cell(regions_table(:, 2))));

parpool(7)

parfor i=1:num_subjects
    table_row=table_data(i, :);
    sub_id=num2str(table_row.SUB_ID);
    dataset=cell2mat(table_row.DATASET);
    site_id=cell2mat(table_row.SITE_ID);
    age=table_row.EDAD;
    dx_group=table_row.DX_GROUP;
    
    try 
        volume_struc=load_untouch_nii(getPathFromAbideData(sub_id, ...
        site_id, dataset, pipeline_name, init_path, volume_name));
    
        regions_seg_struc=load_untouch_nii(getPathFromAbideData(sub_id, ...
        site_id, dataset, pipeline_name, init_path, ...
        segmentation_name));
    
    catch
        bad_sub_cell={'file not found',sub_id, site_id, dataset}
        bad_log_cell=[bad_log_cell; bad_sub_cell];
        continue;
    end
    
    
    
    brain_vol=volume_struc.img;
    
    temporal_features_cell=cell(regions, num_elems_table);
    
    for j=1:regions
	region_num = regions_indices(j)
        segmentation_vol=regions_seg_struc.img;

	region_data_row=regions_table(j, :);
        region_name=cell2mat(region_data_row.name);
        region_index=region_data_row.index;        

        try
	       collageImage=getCollageImage(brain_vol, segmentation_vol, region_num, axis, padding);
	       collageImageN = collageImage - min(collageImage,[],'all');
	       collageImageN = uint8(255*(collageImageN/max(collageImageN, [], 'all')));
		if ~exist([characterization_path,'/',table_name,'/',region_name], 'dir')
      			 mkdir([characterization_path,'/',table_name,'/',region_name]);
    		end
               imwrite(collageImageN, [characterization_path,'/',table_name,'/',region_name,'/',dataset,'_',site_id,'_',sub_id,'.jpg']);

	       curvelets=fdct_wrapping(collageImage,1,1,4,16);
	       if coef_normalization
		      %curvelets=normalizeCurveletFeatures(curvelets);
		      curvelets=normalizeCurveletSubbands(curvelets);
	       end
            curvelet_vector=real(getCurveletFeatureVector(curvelets));
        catch
            bad_sub_cell={['characterization issue on region ',num2str(region_num)], sub_id, site_id, dataset}
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

