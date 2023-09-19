%child volume_path = '/mnt/md0/ABIDE_PREP/ABIDEI/KKI_50776/pip-spm-ants/mprage_bet_bias_z_norm.nii.gz';
%child cortical_segmentation_path = '/mnt/md0/ABIDE_PREP/ABIDEI/KKI_50776/pip-spm-ants/cortical_mask.nii.gz';
%child sub_cortical_segmentation_path = '/mnt/md0/ABIDE_PREP/ABIDEI/KKI_50776/pip-spm-ants/subcortical_mask.nii.gz';

%adol volume_path = '/mnt/md0/ABIDE_PREP/ABIDEI/SDSU_50184/pip-spm-ants/mprage_bet_bias_z_norm.nii.gz';
%adol cortical_segmentation_path = '/mnt/md0/ABIDE_PREP/ABIDEI/SDSU_50184/pip-spm-ants/cortical_mask.nii.gz';
%adol sub_cortical_segmentation_path = '/mnt/md0/ABIDE_PREP/ABIDEI/SDSU_50184/pip-spm-ants/subcortical_mask.nii.gz';

%adul volume_path = '/mnt/md0/ABIDE_PREP/ABIDEI/NYU_51063/pip-spm-ants/mprage_bet_bias_z_norm.nii.gz';
%adul cortical_segmentation_path = '/mnt/md0/ABIDE_PREP/ABIDEI/NYU_51063/pip-spm-ants/cortical_mask.nii.gz';
%adul sub_cortical_segmentation_path = '/mnt/md0/ABIDE_PREP/ABIDEI/NYU_51063/pip-spm-ants/subcortical_mask.nii.gz';

subject='Caltech_51467'

volume_path = ['/mnt/md0/ABIDE_PREP/ABIDEI/', subject, '/pip-spm-ants/mprage_bet_bias_z_norm.nii.gz'];
cortical_segmentation_path = ['/mnt/md0/ABIDE_PREP/ABIDEI/', subject, '/pip-spm-ants/cortical_mask.nii.gz'];
sub_cortical_segmentation_path = ['/mnt/md0/ABIDE_PREP/ABIDEI/', subject, '/pip-spm-ants/subcortical_mask.nii.gz'];


output_path = 'sub-band-reconstructions/adults-asd';
regions = [90];
with_zero = false;
region_names = {'Right Heschis Gyrus'};
%children - {[4,7,12,50,66,68,76],[],[21,22,38,51,67,74],[1,52,53,54,67,68,69,70],[5,8,9,15,16,17,19,20,23,24,26,30,31,32,33,35,36,39,42,43,46,47,48,49,50,51,52,56,57,58,59,60,61,62,66,67,68,72,73,74,76,77,78,79,80,81],[11,12,15,18,19,20,21,22,23,26,27,33,35,40,42,49,58,65,67,74,75,80,81],[50,56,61,66],[]};
%Adolescents - {[],[37,38],[3,4,6,7,8,14,16,26,27,30,42,43,46],[51,54,71],[45,46],[],[76],[]};
%Adults- {[6,28,44,51],[],[10,17],[],[31,40],[2,3,4,5,9,10,12,13,15,16,17,18,19,20,21,22,23,25,26,27,28,31,33,34,35,36,38,39,40,41,42,43,45,46,47,48,49,50,51,56,57,58,59,60,61,62,63,64,65,66,67,72,73,74,75,76,77,78,79,80,81],[39],[]};
subbands = {[71]};

for j = 1:length(regions)
	region = regions(j);
	segmentation_path=cortical_segmentation_path;
	if region>96
		segmentation_path=sub_cortical_segmentation_path;
		region=region-96;
	end
	if ~isempty(subbands{j})
		disp(subbands{j})
		disp([output_path, '/', region_names{j}]);
		mkdir([output_path, '/', region_names{j}]);

		[brain_vol, seg_vol]=get_volumes_from_path(volume_path, segmentation_path);

		[collage,recover_data]=getCollageImageSaving(brain_vol, seg_vol, region);

		collage_mod = collage + abs(min(collage, [], 'all'));

		imwrite(collage_mod/max(collage_mod, [], 'all'), [output_path,'/', region_names{j} ,'/', 'collage', num2str(subbands{j}), '.jpg']);

		collage_sub_band=getCollageOnBand([output_path,'/', region_names{j} ,'/', 'collage', num2str(subbands{j}), '.jpg'], [1, subbands{j}]);

		collage_sub_band_mod = real(collage_sub_band);

		collage_sub_band_mod = collage_sub_band_mod + abs(min(collage_sub_band_mod, [], 'all'));
		
		imwrite(collage_sub_band_mod/(max(collage_sub_band_mod, [], 'all')), [output_path,'/', region_names{j} ,'/', 'collage-sub-bands', '-subbands', '.jpg']);

		save([output_path,'/', region_names{j} ,'/', 'recoverData.mat'], 'recover_data');

		getCollageInverted([output_path,'/', region_names{j} ,'/', 'recoverData.mat'], collage, volume_path, [output_path,'/', region_names{j} ,'/', 'invertedCollage.nii.gz']);

    	getCollageInverted([output_path,'/', region_names{j} ,'/', 'recoverData.mat'], collage_sub_band_mod/max(collage_sub_band_mod, [], 'all'), volume_path,[output_path,'/', region_names{j} ,'/', 'invertedCollageSubBands.nii.gz']);

		[reconstruction, difference, collage] = get_reconstruction_from_subbands(volume_path, segmentation_path, region, [subbands{j}], with_zero);

		imwrite(uint8(reconstruction),[output_path, '/', region_names{j} , '/' ,'rec-sb-', 'subbands', '.jpg']);

		imwrite(uint8(difference) ,[output_path, '/', region_names{j} ,'/' ,'dif-sb-', 'subbands', '.jpg']);

		copyfile(volume_path, [output_path, '/', region_names{j}, '/', 'volume.nii.gz']);

		copyfile(segmentation_path, [output_path, '/', region_names{j}, '/', 'segmentation.nii.gz']);

		disp(['done: region: ',region_names{j}]);
	end
end






