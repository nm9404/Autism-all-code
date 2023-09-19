function y = getCollageInverse(collageImage,volume,recoverData)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
    [h,k]=size(collageImage);
    %volume=uint8(volume);
    for i=1:h
        for j=1:k
            data=recoverData{i,j};
            if length(data)==3
                row=data(1);col=data(2);sl=data(3);
                volume(row,col,sl)=collageImage(i,j);
            end
        end
    end
    y = volume;

