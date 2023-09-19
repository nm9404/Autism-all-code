function y=getCollageImage(brain_vol, segmentationVolume, regionNumber, axis, padding)
    switch(axis)
        case 'axial'
            y=getCollageImageAxial(brain_vol, segmentationVolume, regionNumber, padding);
        case 'sagital'
            y=getCollageImageSagital(brain_vol, segmentationVolume, regionNumber, padding);
        case 'coronal'
            y=getCollageImageFrontal(brain_vol, segmentationVolume, regionNumber, padding);
        case 'axial-transposed'
            y=getCollageImageAxialTransposed(brain_vol, segmentationVolume, regionNumber, padding);
    end
end
            