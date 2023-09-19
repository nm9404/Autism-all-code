clear all;

addpath('LibreriaNifti');
addpath('ToolboxWaveletTexture');
addpath('fdct_wrapping_matlab');
addpath('collage_utils');

table_name='ABIDE_ADULTS_SAMPLE_MALE';
table_data=readtable([table_name, '.csv']);
regions_data=readtable('region_names.csv');

characterization_path='characterization-19-ago-aal-difference';

pipeline_name='pip-spm-ants-rotation';
init_path='/mnt/md0/ABIDE_PREP';

volume_name='rigid_reg_tempWarped_z_norm.nii.gz';
segmentation_name='aal_difs_seg.nii.gz';
segmentation_orig_name='aal_seg.nii.gz';

axis='axial'; %axial, coronal, sagital, axial-transposed
table_output_name=['curvelet_',lower(table_name),'_',axis];

num_elems_table=8;
num_subjects=height(table_data);

padding=0;
coef_normalization=false;


seg_path='/mnt/md0/nmunerag/Herramientas/atlas/differences_ho_aal.csv';
orig_seg_path='/mnt/md0/nmunerag/Herramientas/atlas/labels_aal_transformed.csv';

regions_table = readtable(seg_path);
regions_table_orig = readtable(orig_seg_path);

orig_indices =    [45,46,37,153,155,38,154,156,68,85,60,3,5,19,4,6, 20,65,69,21,23,22,24,15];
regions_indices = [1, 2, 3, 3,  3,  4, 4,  4,  5, 6, 7, 8,8,8, 9,9, 9, 10,10,11,11,12,12,13];

regions=length(orig_indices);

features_cell=cell(regions, num_elems_table,num_subjects);
bad_log_cell={};

parpool(15)

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

	orig_seg_struc=load_untouch_nii(getPathFromAbideData(sub_id, ...
        site_id, dataset, pipeline_name, init_path, ...
        segmentation_orig_name));

    catch exception
        bad_sub_cell={'file not found',sub_id, site_id, dataset};
        bad_log_cell=[bad_log_cell; bad_sub_cell];
        continue;
    end
    
    
    
    brain_vol=volume_struc.img;
    
    temporal_features_cell=cell(regions, num_elems_table);
    
    for j=1:regions
	region_num = regions_indices(j);
	orig_region_num = orig_indices(j);

        segmentation_vol=regions_seg_struc.img;
	segmentation_vol_orig=orig_seg_struc.img;

        region_data_row=regions_table_orig(regions_table_orig.index==orig_indices(j), :);
        region_name=cell2mat(region_data_row.name);
        region_index=region_data_row.index;    
        try
	       collageImage=getCollageImageDouble(brain_vol, segmentation_vol_orig, orig_region_num, segmentation_vol, region_num, padding);
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
        catch exception
            bad_sub_cell={['characterization issue on region ',num2str(region_num)], sub_id, site_id, dataset};
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

