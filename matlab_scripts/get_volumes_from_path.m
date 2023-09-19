function [brain_vol, seg_vol] = get_volumes_from_path(brain_path, seg_path)
	volume = load_untouch_nii(brain_path);

	segmentation = load_untouch_nii(seg_path);

	brain_vol = volume.img;

	seg_vol=segmentation.img;
end