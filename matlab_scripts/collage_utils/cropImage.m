function y = cropImage( Img)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    [rows, columns] = find(Img);
    row1=min(rows);
    row2=max(rows);
    col1=min(columns);
    col2=max(columns);
    y = Img(row1:row2, col1:col2);
end

