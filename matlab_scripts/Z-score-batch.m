clear all;

addpath('LibreriaNifti');
addpath('ToolboxWaveletTexture');
addpath('fdct_wrapping_matlab');
addpath('collage_utils');

table_name='/mnt/md0/nmunerag/Autismo/TABLA_CENTROS_MAQUINA_CORREC';
table_data=readtable([table_name, '.csv']);

pipeline_name='pip-spm-ants';
init_path='/mnt/md0/ABIDE_PREP';

volume_name='mprage_bet_bias.nii.gz';

num_subjects=height(table_data);

bad_log_cell={};

normalized_volume_name='mprage_bet_bias_z_norm.nii.gz';

parpool(20)

parfor i=1:num_subjects
    table_row=table_data(i, :);
    sub_id=num2str(table_row.SUB_ID);
    dataset=cell2mat(table_row.DATASET);
    site_id=cell2mat(table_row.SITE_ID);
    
    try 
        volume_struc=load_untouch_nii(getPathFromAbideData(sub_id, ...
        site_id, dataset, pipeline_name, init_path, volume_name));
        brain_vol=volume_struc.img;
        bain_vol_s=single(brain_vol);
        brain_vol_norm=(brain_vol-mean(brain_vol, 'all'))/std(brain_vol,0,'all');
        volume_struc_copy=volume_struc;
        volume_struc_copy.img=brain_vol_norm;
        save_untouch_nii(volume_struc_copy, getPathFromAbideData(sub_id, ...
        site_id, dataset, pipeline_name, init_path, normalized_volume_name));

    catch
        bad_sub_cell={'file not found',sub_id, site_id, dataset};
        bad_log_cell=[bad_log_cell; bad_sub_cell];
        continue;
    end
end

writetable(cell2table(bad_log_cell), 'z-preprocessing-bad-log.csv');

delete(gcp('nocreate'));

