function getCollageInverted(infoFile, collage, pathBrainVol, outputPath)
    variables=load(infoFile, 'recover_data');
    recover_data=variables.recover_data;
    volume=load_untouch_nii(pathBrainVol);
    [h,w,k]=size(volume.img);
    fullVolume=zeros(h,w,k);
    volReconstruction=getCollageInverse(collage, fullVolume, recover_data{4});
    volume.img=volReconstruction;
    save_untouch_nii(volume, outputPath);
end