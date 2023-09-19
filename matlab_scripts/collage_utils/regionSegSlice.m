function y = regionSegSlice( index, Img, LUTMatrix, h, w)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
    temporalMask = zeros(h,w);
    pi = ismember(LUTMatrix, index);
    [r,c] = find(pi);
    for i=1:size(r)
        temporalMask(r(i), c(i))=1;
    end
    y = Img.*temporalMask;
end
