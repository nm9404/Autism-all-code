addpath('LibreriaNifti');
addpath('collage_utils');
addpath('fdct_wrapping_matlab');

%last run: subbands-region-feb-15-2022-plus.csv

table_data = readtable('subbands-region-sep-10-2022.csv');
pipeline_name = 'pip-spm-ants-rotation';
init_path = '/mnt/md0/ABIDE_PREP';
out_path = 'subbands_reconstruction_10-sep-22';

for i=1:height(table_data)
    row = table_data(i, :);
    subject_id = num2str(row.subject_id);
    site_id = cell2mat(row.center);
    dataset = cell2mat(row.dataset);
    dx_group = uint8(row.dx_group);
    region = uint8(row.region_number);
    regions = [region];
    region_name = cell2mat(row.region);
    region_names = {region_name};
    subs = str2num(cell2mat(row.subbands));
    subbands = {subs};
    group = cell2mat(row.group);
    subBandSingleTest(subject_id, site_id, dataset, pipeline_name, ...
    init_path, dx_group, out_path, regions, region_names, subbands, group);
end