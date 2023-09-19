function image_reconstructed = getCollageOnBand(imagePath, subBands)
    image=imread(imagePath);
    [h,w]=size(image);
    curvelets=fdct_wrapping(image,1,1,4,16);
    curveletNew=rewriteCurveletSubBands(curvelets, subBands);
    image_reconstructed=ifdct_wrapping(curveletNew,1,h,w);
end