%Shep logan test...

addpath("shep-logan");
addpath("LibreriaNifti");

[p, ellipse] = phantom3d('Shepp-Logan', 128);

nii_vol = make_nii(p);

save_nii(nii_vol, 'shep-128.nii');

imshow(p(:,:,90));