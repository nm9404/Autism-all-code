clear all;

addpath('LibreriaNifti');
addpath('ToolboxWaveletTexture');
addpath('fdct_wrapping_matlab');
addpath('collage_utils');

pipeline_name='pip-spm-ants-rotation';
init_path='/mnt/md0/ABIDE_PREP';

table_name='ABIDE_ADULTS_SAMPLE_MALE';
table_data=readtable([table_name, '.csv']);
regions_data=readtable('region_names.csv');

num_subject = randperm(length(table_data.SUB_ID), 1);
subject_id = num2str(table_data.SUB_ID(num_subject));
center_id = cell2mat(table_data.SITE_ID(num_subject));
dataset = cell2mat(table_data.DATASET(num_subject));

num_regions = 96;
num_region = randperm(num_regions, 1);

axis='axial';
padding=0;

volume_name='rigid_reg_tempWarped_z_norm.nii.gz';
cortical_vol_name='cortical_mask.nii.gz';

volume_struc=load_untouch_nii(getPathFromAbideData(subject_id, ...
        center_id, dataset, pipeline_name, init_path, volume_name));
    
cortical_seg_struc=load_untouch_nii(getPathFromAbideData(subject_id, ...
        center_id, dataset, pipeline_name, init_path, ...
        cortical_vol_name));

brain_vol=volume_struc.img;
segmentation_vol = cortical_seg_struc.img;

collageImage = getCollageImage(brain_vol, segmentation_vol, num_region, axis, padding);
figure;
imshow(collageImage, []);

curvelets=fdct_wrapping(collageImage,1,1,4,16);

sc = 3;
sb = 25;

coef = curvelets{sc}{sb};
figure;
hist(coef(:), 40)
hist_max = max(hist(coef(:), 40));
hold on

[alpha, beta] = ggmle(coef(:));
mu = mean(coef(:));

x = -7*alpha:0.01:7*alpha;
dist = ggpdf(x, alpha, beta);
dist = hist_max*dist/max(dist);
plot(x, dist, 'red', 'LineWidth',3)
