function subBandSingleTest(subject_id, site_id, dataset, pipeline_name, ...
    init_path, dx_group, out_path, regions, region_names, subbands, group)

    with_zero = true;

    volume_path = getPathFromAbideData(subject_id, site_id, dataset, pipeline_name, ...
        init_path, 'rigid_reg_tempWarped_z_norm.nii.gz');
    
    cortical_segmentation_path = getPathFromAbideData(subject_id, site_id, dataset, pipeline_name, ...
        init_path, 'cortical_mask.nii.gz');
    
    sub_cortical_segmentation_path = getPathFromAbideData(subject_id, site_id, dataset, pipeline_name, ...
        init_path, 'subcortical_mask.nii.gz');
    
    
    if dx_group == 1
        output_path = [out_path '/' group '_' 'asd' ];
        if ~isfolder(output_path)
            mkdir(output_path);
        end
    else
        output_path = [out_path '/' group '_' 'control' ];
        if ~isfolder(output_path)
            mkdir(output_path);
        end
    end
    
    
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

            %imwrite(collage_mod/max(collage_mod, [], 'all'), [output_path,'/', region_names{j} ,'/', 'collage', num2str(subbands{j}), '.jpg']);

	    imwrite(collage_mod/max(collage_mod, [], 'all'), [output_path,'/', region_names{j} ,'/', 'collage', ' original', '.jpg']);

            collage_sub_band=getCollageOnBand([output_path,'/', region_names{j} ,'/', 'collage', ' original', '.jpg'], subbands{j});

            collage_sub_band_mod = real(collage_sub_band);

            collage_sub_band_mod = collage_sub_band_mod + abs(min(collage_sub_band_mod, [], 'all'));

	    collage_sub_band_mod_n = collage_sub_band_mod / max(collage_sub_band_mod, [], 'all');

	    collage_sub_band_mod_rec = collage_sub_band_mod_n.*double(collage > 0.01);

	    %disp(max(collage, [], 'all'));

	    %disp(min(collage, [], 'all'));

            imwrite(collage_sub_band_mod/(max(collage_sub_band_mod, [], 'all')), [output_path,'/', region_names{j} ,'/', 'collage-sub-bands', '-subbands', '.jpg']);

	    imwrite(collage_sub_band_mod_rec, [output_path,'/', region_names{j} ,'/', 'collage-sub-bands', '-subbands-mask', '.jpg']);

            save([output_path,'/', region_names{j} ,'/', 'recoverData.mat'], 'recover_data');

            getCollageInverted([output_path,'/', region_names{j} ,'/', 'recoverData.mat'], collage, volume_path, [output_path,'/', region_names{j} ,'/', 'invertedCollage.nii.gz']);

            getCollageInverted([output_path,'/', region_names{j} ,'/', 'recoverData.mat'], collage_sub_band_mod_rec, volume_path,[output_path,'/', region_names{j} ,'/', 'invertedCollageSubBands.nii.gz']);

            [reconstruction, difference, ~] = get_reconstruction_from_subbands(volume_path, segmentation_path, region, [subbands{j}], with_zero);

            imwrite(uint8(reconstruction),[output_path, '/', region_names{j} , '/' ,'rec-sb-', 'subbands', '.jpg']);

            imwrite(uint8(difference) ,[output_path, '/', region_names{j} ,'/' ,'dif-sb-', 'subbands', '.jpg']);

            copyfile(volume_path, [output_path, '/', region_names{j}, '/', 'volume.nii.gz']);

            copyfile(segmentation_path, [output_path, '/', region_names{j}, '/', 'segmentation.nii.gz']);

            disp(['done: region: ',region_names{j}]);
        end
    end  
end