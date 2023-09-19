function [y,d,c] = get_reconstruction_from_subbands(volume_path, segmentation_vol, region, subbands, zero_sub_band)
	
	volume = load_untouch_nii(volume_path);

	segmentation = load_untouch_nii(segmentation_vol);

	brain_vol = volume.img;

	segmentation_vol=segmentation.img;

	collage_image = getCollageImage(brain_vol, segmentation_vol, region,'axial',0);

	[M,N] = size(collage_image);

	curvelets = fdct_wrapping(collage_image,1,1,4,16);

	curvelets_shut = shut_down_curvelet_bands(curvelets, subbands, zero_sub_band);

	reconstruction = ifdct_wrapping(curvelets_shut, true, M,N);

	rec_uz = reconstruction + abs(min(reconstruction, [], 'all'));

	reconstruction_save = 255*rec_uz/max(rec_uz, [], 'all');

	col_uz = collage_image + abs(min(collage_image, [], 'all'));

	difference = abs(col_uz - rec_uz);

	difference_save = 255*difference/max(difference, [], 'all');

	collage_save = 255*col_uz/max(col_uz, [], 'all');

	difference_b = 255 * (abs(reconstruction_save - collage_save) / (2*max(collage_save, [], 'all')));

	y = reconstruction_save;

	d = difference_b;

	c = collage_save;
end