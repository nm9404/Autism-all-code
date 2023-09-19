function R=insertMatrix(B,b)

% INPUT: B: Bigger matrix % b: small matrix that needs to put inside bigger matrix, B %OUTPUT: R: Resultant matrix % Example: % B=zeros(10,10); b=ones(5,5); % R=insertMatrix(B,b);

% this matlab script is written by Hafiz, PhD Student, UNSW, Canberra % hafizurcse@yahoo.com

    [P,Q]=size(B);

    fx=floor(P/2)-floor(size(b,1)/2);

    fy=floor(Q/2)-floor(size(b,2)/2);

    R=B;

    for p=1:size(b,1)
        for q=1:size(b,2)
            R(fx+p,fy+q)=b(p,q);     
        end
    end

return;
